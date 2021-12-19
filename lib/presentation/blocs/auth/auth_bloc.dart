import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(InitialState());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is LoginUser) {
      yield LoadingState();
      try {
        User? user = await authRepository.loginUser(
            email: event.email, password: event.password);
        if (user != null) {
          yield AuthenticatedState(user: user);
        } else {
          yield UnauthenticatedState();
        }
      } catch (e) {
        yield ErrorState(message: 'Incorrect username and password');
      }
    } else if (event is CheckAuth) {
      yield LoadingState();
      try {
        User? user = await authRepository.currentUser();

        if (user != null) {
          yield AuthenticatedState(user: user);
        } else {
          yield UnauthenticatedState();
        }
      } catch (e) {
        yield ErrorState(message: 'Incorrect username and password');
      }
    }

    if (event is LogOutUser) {
      yield LoadingState();
      await authRepository.logoutUser();
    }
  }
}
