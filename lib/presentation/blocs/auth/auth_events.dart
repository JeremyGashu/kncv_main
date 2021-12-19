import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginUser extends AuthEvent {
  final String email;
  final String password;

  LoginUser({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogOutUser extends AuthEvent {
  @override
  List<Object> get props => [];
}

class CheckAuth extends AuthEvent {}
