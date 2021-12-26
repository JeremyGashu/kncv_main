import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/data/repositories/tester_courier_receiver_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';

final sl = GetIt.instance;

Future<void> serviceLocatorInit() async {
  /// Blocs
  sl.registerFactory(() => OrderBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => TesterCourierBloc(sl()));

  /// Repositories
  sl.registerFactory<OrderRepository>(() => OrderRepository(sl(), sl()));
  sl.registerFactory<AuthRepository>(() => AuthRepository(sl(), sl()));
  sl.registerFactory<TesterCourierRepository>(
      () => TesterCourierRepository(sl(), sl()));

  /// FirebaseAuth instance
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  sl.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);
  sl.registerLazySingleton<FirebaseFirestore>(() => firebaseFirestore);
  sl.registerLazySingleton<FirebaseMessaging>(() => messaging);

  print('Initialized all elements');
}
