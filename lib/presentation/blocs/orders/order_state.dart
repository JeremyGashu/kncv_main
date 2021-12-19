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

class LoadingSingleOrder extends OrderState {}

class LoadedSingleOrder extends OrderState {
  final Order order;

  LoadedSingleOrder(this.order);
  @override
  List<Object> get props => [order];
}

class SentOrder extends OrderState {
  @override
  List<Object> get props => [];
}

class SendingOrder extends OrderState {
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
