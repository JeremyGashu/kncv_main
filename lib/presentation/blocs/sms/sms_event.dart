import 'package:equatable/equatable.dart';

class SMSEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitSMSListening extends SMSEvent {}

class UpdatingDatabaseEvent extends SMSEvent {}

class UpdatedDatabaseEvent extends SMSEvent {}

class ErrorEvent extends SMSEvent {
  final String error;

  ErrorEvent({required this.error});
  @override
  List<Object?> get props => [error];
}
