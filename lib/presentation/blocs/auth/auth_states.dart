import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialState extends AuthState {}

class LoadingState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthenticatedState extends AuthState {
  final User user;

  AuthenticatedState({required this.user});
  @override
  List<Object> get props => [user];
}

class UnauthenticatedState extends AuthState {
  @override
  List<Object> get props => [];
}

class ErrorState extends AuthState {
  final String message;

  ErrorState({required this.message});
  List<Object> get props => [message];
}
