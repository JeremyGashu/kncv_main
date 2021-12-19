import 'package:equatable/equatable.dart';
import 'package:kncv_flutter/data/models/order.dart';

class OrderState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialState extends OrderState {}

class LoadingState extends OrderState {
  @override
  List<Object> get props => [];
}

class LaodedStates extends OrderState {
  final OrderModel order;

  LaodedStates({required this.order});
  @override
  List<Object> get props => [order];
}

class ErrorState extends OrderState {
  final String message;

  ErrorState({required this.message});
  List<Object> get props => [message];
}
