import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../service_locator.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(InitialState());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is LoginUser) {
      yield LoadingState();
      try {
        User? user = await authRepository.loginUser(
            email: event.email, password: event.password);
        String? type;
        String? uid = user?.uid;
        if (uid != null) {
          var userData = await authRepository.database
              .collection('users')
              .where('user_id', isEqualTo: uid)
              .get();
          if (userData.docs.isNotEmpty) {
            type = userData.docs[0].data()['type'];
          }
        }
        if (user != null) {
          SharedPreferences preferences = sl<SharedPreferences>();
          await preferences.setString('user_type', type ?? '');
          await preferences.setString(
              'authData',
              jsonEncode({
                'email': user.email,
                'displayName': user.displayName,
                'uid': user.uid
              }));
          if (type == 'COURIER_ADMIN' && kIsWeb) {
            yield UnauthenticatedState();
            return;
          }
          yield AuthenticatedState(user: user, type: type ?? '', uid: user.uid);
        } else {
          yield UnauthenticatedState();
        }
      } catch (e) {
        yield ErrorState(message: 'Incorrect username and password');
      }
    } else if (event is CheckAuth) {
      yield LoadingState();
      try {
        if (kIsWeb) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String? userJson = preferences.getString('authData');

          if (userJson == null) {
            yield UnauthenticatedState();
          } else {
            print('Her.... ${jsonDecode(userJson)}');
            Map user = jsonDecode(userJson);
            String? uid = user['uid'];
            String? type;

            if (uid != null) {
              var userData = await authRepository.database
                  .collection('users')
                  .where('user_id', isEqualTo: uid)
                  .get();

              if (userData.docs.isNotEmpty) {
                type = userData.docs[0].data()['type'];
                print('User type for $uid is $type');
              }
            }

            if (type == 'COURIER_ADMIN' && kIsWeb) {
              yield UnauthenticatedState();
              return;
            }
            print('Authenticated state with data $type');
            yield AuthenticatedState(type: type ?? '', uid: uid ?? '');
          }
        } else {
          User? user = authRepository.auth.currentUser;
          print('User email => ${user?.email}');
          String? type;
          String? uid = user?.uid;

          if (uid != null) {
            var userData = await authRepository.database
                .collection('users')
                .where('user_id', isEqualTo: uid)
                .get();

            if (userData.docs.isNotEmpty) {
              type = userData.docs[0].data()['type'];
            }
          }

          if (user != null) {
            if (type == 'COURIER_ADMIN' && kIsWeb) {
              yield UnauthenticatedState();
              return;
            }
            yield AuthenticatedState(
                user: user, type: type ?? '', uid: user.uid);
          } else {
            yield UnauthenticatedState();
          }
        }
      } catch (e) {
        print(e.toString());
        yield ErrorState(message: 'Incorrect username and password');
      }
    }

    if (event is LogOutUser) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.remove('authData');
      yield LoadingState();
      await authRepository.logoutUser();
      yield InitialState();
    }
  }
}
