import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_event.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_response_codes.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_state.dart';
import 'package:kncv_flutter/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

backgrounMessageHandler(SmsMessage message) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print('Before saving ${await preferences.getStringList('messages')}');
  List<String> values = preferences.getStringList('messages') ?? [];
  await preferences.setStringList('messages', [...values, message.body ?? '']);
  print('After saving ${preferences.getStringList('messages')}');
}

class SMSBloc extends Bloc<SMSEvent, SMSState> {
  SMSBloc() : super(InitialState());
  SharedPreferences preferences = sl<SharedPreferences>();
  Box<Order> ordersBox = Hive.box<Order>('orders');

  @override
  Stream<SMSState> mapEventToState(
    SMSEvent event,
  ) async* {
    if (event is InitSMSListening) {
      debugPrint('============Listening to SMS============');
      try {
        bool? permissionsGranted =
            await Telephony.instance.requestSmsPermissions;
        print('SMS Persmission => $permissionsGranted');

        print('Saved messages ${await preferences.getString('messages')}');

        Telephony.instance.listenIncomingSms(
            onNewMessage: (SmsMessage message) {
              debugPrint('Received message => ${message.body}');
              updateDataOnSms(message);
            },
            onBackgroundMessage: backgrounMessageHandler);

        print('Listening to SMS Entry');
      } catch (e) {}
    } else if (event is UpdatingDatabaseEvent) {
      yield UpdatingDatabase();
    } else if (event is UpdatedDatabaseEvent) {
      yield UpdatedDatabase();
    } else if (event is ErrorEvent) {
      yield ErrorState(message: event.error);
    } else if (event is UpdateDatabaseFromSharedPreferenceEvent) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      debugPrint(
          'Read and update data ${preferences.getStringList('messages')}');

      List<String>? messages = preferences.getStringList('messages');
      messages?.forEach((message) async {
        try {
          var body = jsonDecode(message);

          try {
            // var body = jsonDecode(message.body ?? "{\"action\" : \"-1\"}");
            if (body['action'] == ORDER_PLACED) {
              debugPrint('Create order ${body}');
              bool internetAvailable = await isConnectedToTheInternet();
              if (!internetAvailable) {
                print('Listening to SMS Entry');
                Order? order = Order.fromJsonSMS(body['payload']['o']);
                order.status = 'Waiting for Confirmation';

                if (await canEditResult(
                    orderId: order.orderId ?? '', action: ORDER_PLACED)) {
                  List<Order> orders = await ordersBox.values.toList();
                  orders.removeWhere(
                      (element) => element.orderId == order.orderId);
                  orders.add(order);
                  await ordersBox.clear();
                  await ordersBox.addAll(orders);
                }

                // add(UpdatedDatabaseEvent());
              }
            } else if (body['action'] == ORDER_ACCEPTED) {
              bool internetAvailable = await isConnectedToTheInternet();
              if (!internetAvailable &&
                  (await canEditResult(
                      orderId: body['payload']['oid'],
                      action: ORDER_ACCEPTED))) {
                print('Listening to SMS Entry');
                List<Order> orders = await ordersBox.values.toList();
                Order order = orders.firstWhere(
                    (element) => element.orderId == body['payload']['oid']);
                orders
                    .removeWhere((element) => element.orderId == order.orderId);
                order.status = 'Confirmed';
                orders.add(order);
                await ordersBox.clear();
                await ordersBox.addAll(orders);
                // add(UpdatedDatabaseEvent());
              }
            } else if (body['action'] == SENDER_APPROVED_COURIER_DEPARTURE) {
              bool internetAvailable = await isConnectedToTheInternet();
              if (!internetAvailable &&
                  (await canEditResult(
                      orderId: body['payload']['oid'],
                      action: SENDER_APPROVED_COURIER_DEPARTURE))) {
                print('Listening to SMS Entry');
                List<Order> orders = await ordersBox.values.toList();
                Order order = orders.firstWhere(
                    (element) => element.orderId == body['payload']['oid']);
                orders
                    .removeWhere((element) => element.orderId == order.orderId);
                order.status = 'Picked Up';
                orders.add(order);
                await ordersBox.clear();
                await ordersBox.addAll(orders);
                // add(UpdatedDatabaseEvent());
              }
            } else if (body['action'] == TESTER_APPROVED_COURIER_ARRIVAL) {
              bool internetAvailable = await isConnectedToTheInternet();
              if (!internetAvailable &&
                  (await canEditResult(
                      orderId: body['payload']['oid'],
                      action: TESTER_APPROVED_COURIER_ARRIVAL))) {
                print('Listening to SMS Entry');
                List<Order> orders = await ordersBox.values.toList();
                Order order = orders.firstWhere(
                    (element) => element.orderId == body['payload']['oid']);
                orders
                    .removeWhere((element) => element.orderId == order.orderId);
                order.status = 'Deliverd';
                orders.add(order);
                await ordersBox.clear();
                await ordersBox.addAll(orders);
                // add(UpdatedDatabaseEvent());
              }
            } else if (body['action'] == SPECIMEN_EDITED) {
              print('Listening to SMS Entry');
              List<Order> orders = await ordersBox.values.toList();
              Order order = orders.firstWhere(
                  (element) => element.orderId == body['payload']['oid']);
              orders.removeWhere((element) => element.orderId == order.orderId);
              order.patients![body['payload']?['i']] =
                  Patient.fromJson(body['payload']['p']);

              bool assessed = allSpecimensAssessed(order);

              order.status = assessed ? 'Received' : 'Delivered';
              orders.add(order);
              await ordersBox.clear();
              await ordersBox.addAll(orders);
              // add(UpdatedDatabaseEvent());
            } else {
              debugPrint('received another sms');
            }
          } catch (e) {
            add(ErrorEvent(error: e.toString()));
          }

          // ===?
        } catch (e) {
          debugPrint('Decoded Error  $e');
        }
      });

      await preferences.remove('messages');

      yield UpdatedDatabase();

      // var decoded = messages?.map((e) => jsonDecode(e)).toList();
    }
  }

  static bool allSpecimensAssessed(Order order) {
    List<Specimen> specimens = [];
    order.patients?.forEach((e) => specimens = [...specimens, ...?e.specimens]);
    for (int i = 0; i < specimens.length; i++) {
      if (!specimens[i].assessed) {
        return false;
      }
    }
    return true;
  }

  Future<bool> canEditResult(
      {required String orderId, required int action}) async {
    List<Order> orders = await ordersBox.values.toList();
    int orderIndex = orders.indexWhere((element) => element.orderId == orderId);
    //if it has not been created
    if (orderIndex == -1) {
      return true;
    }

    Order order = orders[orderIndex];

    switch (action) {
      case ORDER_PLACED:
        return orderIndex == -1;
      case ORDER_ACCEPTED:
        return order.status == 'Waiting for Confirmation' ||
            order.status == 'Confirmed';
      case SENDER_APPROVED_COURIER_DEPARTURE:
        return order.status == 'Confirmed';
      case TESTER_APPROVED_COURIER_ARRIVAL:
        return order.status == 'Picked Up';
      case SPECIMEN_EDITED:
        return ['Delivered', 'Accepted', 'Inspected', 'Tested', 'Received']
            .contains(order.status);
    }
    return false;
  }

  updateDataOnSms(SmsMessage message) async {
    add(UpdatingDatabaseEvent());
    try {
      var body = jsonDecode(message.body ?? "{\"action\" : \"-1\"}");
      debugPrint('');
      if (body['action'] == ORDER_PLACED) {
        debugPrint('Create order ${body}');
        bool internetAvailable = await isConnectedToTheInternet();
        if (!internetAvailable) {
          print('Listening to SMS Entry');
          Order? order = Order.fromJsonSMS(body['payload']['o']);
          order.status = 'Waiting for Confirmation';

          List<Order> orders = await ordersBox.values.toList();
          orders.removeWhere((element) => element.orderId == order.orderId);
          orders.add(order);
          await ordersBox.clear();
          await ordersBox.addAll(orders);
          add(UpdatedDatabaseEvent());
        }
      } else if (body['action'] == ORDER_ACCEPTED) {
        bool internetAvailable = await isConnectedToTheInternet();
        if (!internetAvailable) {
          print('Listening to SMS Entry');
          List<Order> orders = await ordersBox.values.toList();
          Order order = orders.firstWhere(
              (element) => element.orderId == body['payload']['oid']);
          orders.removeWhere((element) => element.orderId == order.orderId);
          order.status = 'Confirmed';
          orders.add(order);
          await ordersBox.clear();
          await ordersBox.addAll(orders);
          add(UpdatedDatabaseEvent());
        }
      } else if (body['action'] == SENDER_APPROVED_COURIER_DEPARTURE) {
        bool internetAvailable = await isConnectedToTheInternet();
        if (!internetAvailable) {
          print('Listening to SMS Entry');
          List<Order> orders = await ordersBox.values.toList();
          Order order = orders.firstWhere(
              (element) => element.orderId == body['payload']['oid']);
          orders.removeWhere((element) => element.orderId == order.orderId);
          order.status = 'Picked Up';
          orders.add(order);
          await ordersBox.clear();
          await ordersBox.addAll(orders);
          add(UpdatedDatabaseEvent());
        }
      } else if (body['action'] == TESTER_APPROVED_COURIER_ARRIVAL) {
        bool internetAvailable = await isConnectedToTheInternet();
        if (!internetAvailable) {
          print('Listening to SMS Entry');
          List<Order> orders = await ordersBox.values.toList();
          Order order = orders.firstWhere(
              (element) => element.orderId == body['payload']['oid']);
          orders.removeWhere((element) => element.orderId == order.orderId);
          order.status = 'Deliverd';
          orders.add(order);
          await ordersBox.clear();
          await ordersBox.addAll(orders);
          add(UpdatedDatabaseEvent());
        }
      } else if (body['action'] == SPECIMEN_EDITED) {
        print('Listening to SMS Entry');
        List<Order> orders = await ordersBox.values.toList();
        Order order = orders
            .firstWhere((element) => element.orderId == body['payload']['oid']);
        orders.removeWhere((element) => element.orderId == order.orderId);
        order.patients![body['payload']?['i']] =
            Patient.fromJson(body['payload']['p']);
        orders.add(order);
        await ordersBox.clear();
        await ordersBox.addAll(orders);
        add(UpdatedDatabaseEvent());
      } else {
        debugPrint('received another sms');
      }
    } catch (e) {
      add(ErrorEvent(error: e.toString()));
    }
  }
}
