import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/app_router.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';
import 'package:kncv_flutter/service_locator.dart';
import 'package:kncv_flutter/simple_bloc_observer.dart';

import 'presentation/blocs/orders/orders_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await serviceLocatorInit();
  Bloc.observer = SimpleBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()..add(CheckAuth())),
        BlocProvider<OrderBloc>(
            create: (_) => sl<OrderBloc>()..add(LoadOrders())),
        BlocProvider<TesterCourierBloc>(
            create: (_) =>
                sl<TesterCourierBloc>()..add(LoadTestersAndCouriers())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: SplashPage.splashPageRouteName,
      ),
    ),
  );
}
