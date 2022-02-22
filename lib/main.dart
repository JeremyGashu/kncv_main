import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/app_router.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_event.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';
import 'package:kncv_flutter/service_locator.dart';
import 'package:kncv_flutter/simple_bloc_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/blocs/orders/orders_bloc.dart';

backgrounMessageHandler(SmsMessage message) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print('Before saving ${await preferences.getString('messages')}');
  await preferences.setString('messages', message.toString());
  print('After saving ${await preferences.getString('messages')}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();

  Hive.registerAdapter(WoredaAdapter());
  Hive.registerAdapter(ZoneAdapter());
  Hive.registerAdapter(RegionAdapter());
  Hive.registerAdapter(TestResultAdapter());
  Hive.registerAdapter(TesterAdapter());
  Hive.registerAdapter(CourierAdapter());
  Hive.registerAdapter(SpecimenAdapter());
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(OrderAdapter());

  await serviceLocatorInit();

  Bloc.observer = SimpleBlocObserver();
  bool? permissionsGranted = await Telephony.instance.requestSmsPermissions;
  print('SMS Persmission => $permissionsGranted');

  SharedPreferences preferences = await SharedPreferences.getInstance();
  print('Saved messages ${await preferences.getString('messages')}');

  Telephony.instance.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.body);
      },
      onBackgroundMessage: backgrounMessageHandler);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()..add(CheckAuth())),
        BlocProvider<OrderBloc>(
            create: (_) => sl<OrderBloc>()..add(LoadOrders())),
        BlocProvider<TesterCourierBloc>(
          create: (_) => sl<TesterCourierBloc>()..add(LoadTestersAndCouriers()),
          lazy: false,
        ),
        BlocProvider<LocationBloc>(
          create: (_) => sl<LocationBloc>()..add(LoadLocations()),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: SplashPage.splashPageRouteName,
      ),
    ),
  );
}

class SMSListener extends StatefulWidget {
  final Widget child;
  final Function? onResume;

  const SMSListener({Key? key, required this.child, this.onResume})
      : super(key: key);
  @override
  _SMSListenerState createState() => _SMSListenerState();
}

class _SMSListenerState extends State<SMSListener> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.onResume != null ? widget.onResume!() : () {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
