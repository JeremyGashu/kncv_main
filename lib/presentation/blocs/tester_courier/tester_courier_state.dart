import 'package:equatable/equatable.dart';
import 'package:kncv_flutter/data/models/models.dart';

class TesterCourierStates extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialState extends TesterCourierStates {}

class LoadingState extends TesterCourierStates {
  @override
  List<Object> get props => [];
}

class LoadedState extends TesterCourierStates {
  final Map<String, List<TesterCourier>> data;

  LoadedState({required this.data});
  @override
  List<Object> get props => [data];
}

class ErrorState extends TesterCourierStates {
  final String message;

  ErrorState({required this.message});
  List<Object> get props => [message];
}
