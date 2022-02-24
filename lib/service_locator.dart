import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/data/repositories/locations.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/data/repositories/tester_courier_receiver_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> serviceLocatorInit() async {
  /// Blocs
  sl.registerFactory(() => OrderBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => TesterCourierBloc(sl()));
  sl.registerFactory(() => LocationBloc(sl()));
  sl.registerLazySingleton(() => SMSBloc());

  /// Repositories
  sl.registerFactory<OrderRepository>(() => OrderRepository(sl(), sl()));
  sl.registerFactory<AuthRepository>(() => AuthRepository(sl(), sl()));
  sl.registerFactory<TesterCourierRepository>(
      () => TesterCourierRepository(sl(), sl()));
  sl.registerFactory<LocationsRepository>(() => LocationsRepository(sl()));

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

  ///Hive Database and shared preference
  ///orders
  ///couriers
  ///test centers
  ///regions
  await Hive.openBox<Order>('orders');
  debugPrint('Opened order box!');

  await Hive.openBox<Courier>('couriers');
  debugPrint('Opened courier box!');

  await Hive.openBox<Tester>('test_centers');
  debugPrint('Opened test center box!');

  await Hive.openBox<Region>('regions');
  debugPrint('Opened region box!');

  SharedPreferences preferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => preferences);

  print('Initialized all elements');
}
