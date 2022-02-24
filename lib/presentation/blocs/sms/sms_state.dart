import 'package:equatable/equatable.dart';

class SMSState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitialState extends SMSState {}

class ErrorState extends SMSState {
  final String message;

  ErrorState({required this.message});
  List<Object> get props => [message];
}

class UpdatingDatabase extends SMSState {}

class UpdatedDatabase extends SMSState {}
