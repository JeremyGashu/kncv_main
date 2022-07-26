import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/app_router.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_event.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_event.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_one.dart';
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';
import 'package:kncv_flutter/service_locator.dart';
import 'package:kncv_flutter/simple_bloc_observer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:telephony/telephony.dart';

import 'presentation/blocs/orders/orders_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();

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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()..add(CheckAuth())),
        BlocProvider<OrderBloc>(create: (_) => sl<OrderBloc>()..add(LoadOrders())),
        BlocProvider<TesterCourierBloc>(
          create: (_) => sl<TesterCourierBloc>()..add(LoadTestersAndCouriers()),
          lazy: false,
        ),
        BlocProvider<LocationBloc>(
          create: (_) => sl<LocationBloc>()..add(LoadLocations()),
          lazy: false,
        ),
        BlocProvider<SMSBloc>(
          create: (_) => sl<SMSBloc>()..add(InitSMSListening()),
          lazy: false,
        ),
      ],
      child: kIsWeb
          ? MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateRoute: AppRouter.onGenerateRoute,
              // initialRoute: SplashPage.splashPageRouteName,
              initialRoute: IntroPageOne.introPageOneRouteName,
            )
          : SMSListener(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRouter.onGenerateRoute,
                // initialRoute: SplashPage.splashPageRouteName,
                initialRoute: IntroPageOne.introPageOneRouteName,
              ),
            ),
    ),
  );
}

class SMSListener extends StatefulWidget {
  final Widget child;
  final Function? onResume;

  SMSListener({Key? key, required this.child, this.onResume}) : super(key: key);
  @override
  _SMSListenerState createState() => _SMSListenerState();
}

class _SMSListenerState extends State<SMSListener> with WidgetsBindingObserver {
  SMSBloc smsBloc = sl<SMSBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    ReceivePort receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main_port');

    receivePort.listen((message) {
      if (message is SmsMessage) {
        print('I have received $message from background service i can save it to hive database');
        if (Hive.isBoxOpen('orders')) {
          print('Yes the box is open you can add data into it ${Hive.box<Order>('orders').values}');
        }

        smsBloc.updateDataOnSms(message);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // debugPrint('===========Resumed and updating data============');
      // BlocProvider.of<SMSBloc>(context)
      //     .add(UpdateDatabaseFromSharedPreferenceEvent());

      //Open all the boxes from here and navigate tm homepage then load all the things we have loaded again so that we can get updated data
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
    //this widget will render everytime the app loads
  }
}
