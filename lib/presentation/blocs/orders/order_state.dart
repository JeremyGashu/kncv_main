import 'package:equatable/equatable.dart';
import 'package:kncv_flutter/data/models/models.dart';

class OrderState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialState extends OrderState {}

class LoadingState extends OrderState {
  @override
  List<Object> get props => [];
}

class AddingPatient extends OrderState {}

class AddedPatient extends OrderState {}

class DeletingOrder extends OrderState {}

class DeletedOrder extends OrderState {}

class AcceptingOrderCourier extends OrderState {}

class AcceptedOrderCourier extends OrderState {}

class ApprovingArrivalCourier extends OrderState {}

class ApprovedArrivalCourier extends OrderState {}

class ApprovingArrivalTester extends OrderState {}

class ApprovedArrivalTester extends OrderState {}

class DeletingPatient extends OrderState {}

class LoadedOrdersForCourier extends OrderState {
  final List<Order> orders;

  LoadedOrdersForCourier({required this.orders});
  @override
  List<Object> get props => [orders];
}

class LoadingOrderForCourier extends OrderState {}

class LoadedOrdersForTester extends OrderState {
  final List<Order> orders;

  LoadedOrdersForTester({required this.orders});
  @override
  List<Object> get props => [orders];
}

class LoadingOrderForTester extends OrderState {}

class DeletedPatient extends OrderState {}

class PlacingOrder extends OrderState {}

class PlacedOrder extends OrderState {}

class AddingTestResult extends OrderState {}

class AddedTestResult extends OrderState {}

class LoadingSingleOrder extends OrderState {}

class LoadedSingleOrder extends OrderState {
  final Order order;

  LoadedSingleOrder(this.order);
  @override
  List<Object> get props => [order];
}

class SentOrder extends OrderState {
  final String orderId;

  SentOrder({required this.orderId});
  @override
  List<Object> get props => [orderId];
}

class SendingOrder extends OrderState {
  @override
  List<Object> get props => [];
}

class EditingPatientState extends OrderState {
  @override
  List<Object> get props => [];
}

class EditedPatientState extends OrderState {
  @override
  List<Object> get props => [];
}

class LaodedState extends OrderState {
  final List<Order> orders;

  LaodedState({required this.orders});
  @override
  List<Object> get props => [orders];
}

class ErrorState extends OrderState {
  final String message;

  ErrorState({required this.message});
  List<Object> get props => [message];
}
