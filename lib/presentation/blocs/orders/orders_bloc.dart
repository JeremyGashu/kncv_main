import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/core/message_codes.dart';
import 'package:kncv_flutter/core/sms_handler.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/pages/notificatins.dart';

class OrderBloc extends Bloc<OrderEvents, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(InitialState());

  static Future<bool> approveArrivalFromCourier(Order order) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = await FirebaseFirestore.instance.collection('orders').doc(order.orderId);
      await orderRef.update({'notified_arrival': true});
      return await addNotification(
        orderId: order.orderId!,
        courierContent: 'You notified the order arrival to ${order.tester_name} from ${order.sender_name}.',
        testerContent: 'Courier arrived from ${order.sender_name} at your test center to deliver specimens.',
        content: 'One order got accepted by courier!',
        sender: false,
        courierAction: NotificationAction.NavigateToOrderDetalCourier,
        testerAction: NotificationAction.NavigateToOrderDetalTester,
        payload: {'orderId': order.orderId},
      );
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((order) => order.orderId == order.orderId);
      orders.removeWhere((order) => order.orderId == order.orderId);

      order.notified_arrival = true;

      orders.add(order);
      await ordersBox.clear();
      await ordersBox.addAll(orders);

      await sendSMS(
        to: '0941998907',
        payload: {
          'oid': order.orderId,
        },
        action: COURIER_NOTIFY_ARRIVAL_TESTER,
      );
      return true;
    }
  }

  @override
  Stream<OrderState> mapEventToState(
    OrderEvents event,
  ) async* {
    if (event is LoadOrders) {
      yield LoadingState();
      List<Order> orders = await orderRepository.loadOrders();
      yield LaodedState(orders: orders);
    } else if (event is AddOrder) {
      yield SendingOrder();
      try {
        String newOrderId = await orderRepository.addOrder(
            courier_id: event.courier_id,
            tester_id: event.tester_id,
            courier_name: event.courier_name,
            tester_name: event.tester_name,
            date: event.date,
            courier_phone: event.courier_phone,
            tester_phone: event.tester_phone,
            zone: event.zone,
            region: event.region,
            // woreda: event.woreda,
            sender_id: (await FirebaseAuth.instance.currentUser?.uid ?? ''));
        yield SentOrder(orderId: newOrderId);
      } catch (e) {
        yield ErrorState(message: '$e');
      }
    } else if (event is AcceptOrderCourier) {
      yield AcceptingOrderCourier();
      try {
        bool success = await orderRepository.acceptOrder(
          event.order.orderId,
          event.time,
          event.date,
        );
        if (success) {
          yield AcceptedOrderCourier(event.order, event.time, event.date);
        } else {
          ErrorState(message: 'Error Accepting Order! Please try Again!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error Accepting Order. Please try Again!');
      }
    } else if (event is ApproveArrivalCourier) {
      yield ApprovingArrivalCourier();
      try {
        bool success = await orderRepository.approveArrival(event.order.orderId, event.receiver);
        if (success) {
          yield ApprovedArrivalCourier(event.order);
        } else {
          ErrorState(message: 'Error Accepting Order! Please try Again!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error Accepting Order. Please try Again!');
      }
    } else if (event is ApproveArrivalTester) {
      yield ApprovingArrivalTester();
      try {
        bool success = await orderRepository.approveArrivalTester(
          orderId: event.order.orderId,
          coldChainStatus: event.coldChainStatus,
          sputumCondition: event.sputumCondition,
          stoolCondition: event.stoolCondition,
        );
        if (success) {
          yield ApprovedArrivalTester(event.order);
        } else {
          ErrorState(message: 'Error Approving Arrival! Please try Again!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error Approving Arrival! Please try Again!');
      }
    } else if (event is CourierApproveArrivalToTestCenter) {
      yield CourierApprovingArrivalTester();
      try {
        bool success = await orderRepository.courierApproveArrivalTester(
          event.order.orderId,
          event.receiver,
          event.phone,
        );
        if (success) {
          yield CourierApprovedArrivalTester(event.order);
        } else {
          ErrorState(message: 'Error Approving Arrival! Please try Again!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error Approving Arrival! Please try Again!');
      }
    } else if (event is DeleteOrders) {
      yield DeletingOrder();
      try {
        var status = await orderRepository.deleteOrder(orderId: event.order.orderId ?? 'null');
        if (status['success']) {
          yield DeletedOrder(event.order);
        } else {
          yield ErrorState(message: status['message']);
        }
      } catch (e) {
        yield ErrorState(message: 'Error deleting order!');
      }
    } else if (event is DeletePatient) {
      yield DeletingOrder();
      try {
        bool success = await orderRepository.deletePatientInfo(orderId: event.orderId, index: event.index);
        if (success) {
          yield DeletedPatient();
        } else {
          yield ErrorState(message: 'Erro deleting patinet!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error deleting patient!');
      }
    } else if (event is LoadOrdersForCourier) {
      yield LoadingOrderForCourier();
      try {
        List<Order> orders = await orderRepository.loadOrdersForCourier();
        yield LoadedOrdersForCourier(orders: orders);
      } catch (e) {
        debugPrint('Error loading order =>${e.toString()}');
        // throw Exception(e);
        yield ErrorState(message: 'Error Loading Orders!');
      }
    } else if (event is LoadOrdersForTester) {
      yield LoadingOrderForTester();
      try {
        List<Order> orders = await orderRepository.loadOrdersForTestCenters();
        yield LoadedOrdersForTester(orders: orders);
      } catch (e) {
        debugPrint('Error loading order =>${e.toString()}');

        yield ErrorState(message: 'Error Loading Orders!');
      }
    } else if (event is LoadSingleOrder) {
      yield LoadingState();
      try {
        Order? order = await orderRepository.loadSingleOrder(orderId: event.orderId);
        if (order != null) {
          yield LoadedSingleOrder(order);
        } else {
          yield ErrorState(message: 'Cannot find order with this id!');
        }
      } catch (e) {
        // throw Exception(e);
        debugPrint('Error loading order =>${e.toString()}');

        yield ErrorState(message: 'Error Loading Order!');
      }
    } else if (event is AddPatientToOrder) {
      yield AddingPatient();
      try {
        await orderRepository.addPatient(orderId: event.orderId, patient: event.patient);
        yield AddedPatient();
      } catch (e) {
        yield ErrorState(message: 'Error Adding Patient!');
      }
    } else if (event is EditOrder) {
      yield EditingOrder();
      try {
        await orderRepository.editShipmentInfo(
          orderId: event.orderId,
          courier_name: event.courier_name,
          courier_id: event.courier_id,
          tester_id: event.tester_id,
          tester_name: event.tester_name,
        );
        yield EditedOrder();
      } catch (e) {
        yield ErrorState(message: 'Error Editing Patient!');
      }
    } else if (event is EditPtientInfo) {
      yield EditingPatientState();
      try {
        bool edited = await orderRepository.editPatientInfo(orderId: event.orderId, index: event.index, patient: event.patient);
        if (edited) {
          yield EditedPatientState();
        }
      } catch (e) {
        yield ErrorState(message: 'Error editing user');
      }
    } else if (event is AddTestResult) {
      yield AddingTestResult();
      try {
        bool edited = await orderRepository.addTestResult(orderId: event.orderId, index: event.index, patient: event.patient);
        if (edited) {
          yield AddedTestResult(event.patient);
        }
      } catch (e) {
        throw Exception(e);
        // yield ErrorState(message: 'Error adding test result');
      }
    } else if (event is EditTestResult) {
      yield EditingTestResult();
      try {
        bool edited = await orderRepository.editTestResult(orderId: event.orderId, index: event.index, patient: event.patient);
        if (edited) {
          yield EditedTestResult(event.patient);
        }
      } catch (e) {
        throw Exception(e);
        debugPrint('$e');
        // yield ErrorState(message: 'Error editing test result');
      }
    } else if (event is PlaceOrder) {
      yield PlacingOrder();
      try {
        bool success = await orderRepository.placeOrder(order: event.order);
        if (success) {
          yield PlacedOrder(event.order);
        } else {
          yield ErrorState(message: 'Error placing order...');
        }
      } catch (e) {}
    }
  }
}
