import 'dart:convert';
import 'dart:ui';

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
  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // print('Before saving ${await preferences.getStringList('messages')}');
  // List<String> values = preferences.getStringList('messages') ?? [];
  // await preferences.setStringList('messages', [...values, message.body ?? '']);
  // print('After saving ${preferences.getStringList('messages')}');

  //send from background isolate
  // print('I have send $message from background isolate');
  IsolateNameServer.lookupPortByName('main_port')?.send(message);
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
      // debugPrint('============Listening to SMS============');
      try {
        bool? permissionsGranted = await Telephony.instance.requestSmsPermissions;
        print('SMS Persmission => $permissionsGranted');

        // print('Saved messages ${await preferences.getString('messages')}');

        Telephony.instance.listenIncomingSms(
            onNewMessage: (SmsMessage message) {
              // debugPrint('Received message => ${message.body}');
              updateDataOnSms(message);
            },
            onBackgroundMessage: backgrounMessageHandler);

        // print('Listening to SMS Entry');
      } catch (e) {}
    } else if (event is UpdatingDatabaseEvent) {
      yield UpdatingDatabase();
    } else if (event is UpdatedDatabaseEvent) {
      yield UpdatedDatabase();
    } else if (event is ErrorEvent) {
      yield ErrorState(message: event.error);
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

  updateDataOnSms(SmsMessage message) async {
    add(UpdatingDatabaseEvent());
    try {
      var body = jsonDecode(message.body ?? "{\"action\" : \"-1\"}");
      // debugPrint('');
      if (body['action'] == ORDER_PLACED) {
        // debugPrint('Create order ${body}');
        bool internetAvailable = await isConnectedToTheInternet();
        if (!internetAvailable) {
          // print('Listening to SMS Entry');
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
          // print('Listening to SMS Entry');
          List<Order> orders = await ordersBox.values.toList();
          Order order = orders.firstWhere((element) => element.orderId == body['payload']['oid']);
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
          // print('Listening to SMS Entry');
          List<Order> orders = await ordersBox.values.toList();
          Order order = orders.firstWhere((element) => element.orderId == body['payload']['oid']);
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
          // print('Listening to SMS Entry');
          List<Order> orders = await ordersBox.values.toList();
          Order order = orders.firstWhere((element) => element.orderId == body['payload']['oid']);
          orders.removeWhere((element) => element.orderId == order.orderId);
          order.status = 'Delivered';
          orders.add(order);
          await ordersBox.clear();
          await ordersBox.addAll(orders);
          add(UpdatedDatabaseEvent());
        }
      } else if (body['action'] == SPECIMEN_EDITED) {
        // print('Listening to SMS Entry');
        List<Order> orders = await ordersBox.values.toList();
        Order order = orders.firstWhere((element) => element.orderId == body['payload']['oid']);
        orders.removeWhere((element) => element.orderId == order.orderId);
        order.patients![body['payload']?['i']] = Patient.fromJson(body['payload']['p']);

        bool finishedAssessingPatient = true;
        order.patients![body['payload']?['i']].specimens?.forEach((specimen) {
          if (!specimen.assessed) {
            finishedAssessingPatient = false;
          }
        });

        if (finishedAssessingPatient) {
          order.patients![body['payload']?['i']].status = 'Inspected';
        }

        bool assessed = allSpecimensAssessed(order);

        order.status = assessed ? 'Received' : 'Delivered';

        orders.add(order);
        await ordersBox.clear();
        await ordersBox.addAll(orders);
        add(UpdatedDatabaseEvent());
      } else {
        debugPrint('received another sms');
      }
    } catch (e) {
      add(UpdatedDatabaseEvent());
      // throw Exception(e);
      // add(ErrorEvent(error: e.toString()));
    }
  }
}
