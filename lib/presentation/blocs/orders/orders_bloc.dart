import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';

class OrderBloc extends Bloc<OrderEvents, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(InitialState());

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
            tester_name: event.tester_name);
        yield SentOrder(orderId: newOrderId);
      } catch (e) {
        yield ErrorState(message: 'Error sending order!');
      }
    } else if (event is AcceptOrderCourier) {
      yield AcceptingOrderCourier();
      try {
        bool success = await orderRepository.acceptOrder(event.orderId);
        if (success) {
          yield AcceptedOrderCourier();
        } else {
          ErrorState(message: 'Error Accepting Order! Please try Again!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error Accepting Order. Please try Again!');
      }
    } else if (event is ApproveArrivalCourier) {
      yield ApprovingArrivalCourier();
      try {
        bool success =
            await orderRepository.approveArrival(event.orderId, event.receiver);
        if (success) {
          yield ApprovedArrivalCourier();
        } else {
          ErrorState(message: 'Error Accepting Order! Please try Again!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error Accepting Order. Please try Again!');
      }
    } else if (event is DeleteOrders) {
      yield DeletingOrder();
      try {
        var status = await orderRepository.deleteOrder(orderId: event.orderId);
        if (status['success']) {
          yield DeletedOrder();
        } else {
          yield ErrorState(message: status['message']);
        }
      } catch (e) {
        yield ErrorState(message: 'Error deleting order!');
      }
    } else if (event is DeletePatient) {
      yield DeletingOrder();
      try {
        bool success = await orderRepository.deletePatientInfo(
            orderId: event.orderId, index: event.index);
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
        yield ErrorState(message: 'Error Loading Orders!');
      }
    } else if (event is LoadSingleOrder) {
      yield LoadingState();
      try {
        Order? order =
            await orderRepository.loadSingleOrder(orderId: event.orderId);
        if (order != null) {
          yield LoadedSingleOrder(order);
        } else {
          yield ErrorState(message: 'Cannot find order with this id!');
        }
      } catch (e) {
        yield ErrorState(message: 'Error Loading Order!');
      }
    } else if (event is AddPatientToOrder) {
      yield AddingPatient();
      try {
        await orderRepository.addPatient(
            orderId: event.orderId, patient: event.patient);
        yield AddedPatient();
      } catch (e) {
        yield ErrorState(message: 'Error Adding Patient!');
      }
    } else if (event is EditPtientInfo) {
      yield EditingPatientState();
      try {
        bool edited = await orderRepository.editPatientInfo(
            orderId: event.orderId, index: event.index, patient: event.patient);
        if (edited) {
          yield EditedPatientState();
        }
      } catch (e) {
        yield ErrorState(message: 'Error editing user');
      }
    } else if (event is PlaceOrder) {
      yield PlacingOrder();
      try {
        bool success = await orderRepository.placeOrder(orderId: event.orderId);
        if (success) {
          yield PlacedOrder();
        } else {
          yield ErrorState(message: 'Error placing order...');
        }
      } catch (e) {}
    }
  }
}
