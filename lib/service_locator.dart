import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';

final sl = GetIt.instance;

Future<void> serviceLocatorInit() async {
  /// Blocs
  sl.registerFactory(() => OrderBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl()));

  /// Repositories
  sl.registerFactory<OrderRepository>(() => OrderRepository(sl(), sl()));
  sl.registerFactory<AuthRepository>(() => AuthRepository(sl()));

  /// FirebaseAuth instance
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  sl.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);
  sl.registerLazySingleton<FirebaseFirestore>(() => firebaseFirestore);
  print('Initialized all elements');
}
