import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';
import 'package:kncv_flutter/service_locator.dart';
import 'package:kncv_flutter/simple_bloc_observer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:telephony/telephony.dart';
import 'presentation/blocs/orders/orders_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: "AIzaSyAo62ZimMRMjmkwjhzwM-Ux_cpiOPAGT7A",
      appId: '1:669099784203:web:b84c3187f51436382f2f0e',
      messagingSenderId: '669099784203',
      projectId: 'kncv-360',
    ));
  } else {
    await Firebase.initializeApp();
  }

  requestPermission();
  loadFCM();
  listenFCM();

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

  // List<String?> value = await getTestCenterAdminsFromTestCenterId('p05PNEoP0w8Zurbs9JXB');
  // print('Test Center Admin for Test Center 1 $value');

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
        BlocProvider<SMSBloc>(
          create: (_) => sl<SMSBloc>()..add(InitSMSListening()),
          lazy: false,
        ),
      ],
      child: kIsWeb
          ? MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: SplashPage.splashPageRouteName,
            )
          : SMSListener(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRouter.onGenerateRoute,
                initialRoute: SplashPage.splashPageRouteName,
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
        // print('I have received $message from background service i can save it to hive database');
        if (Hive.isBoxOpen('orders')) {
          // print('Yes the box is open you can add data into it ${Hive.box<Order>('orders').values}');
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

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

AndroidNotificationChannel? channel;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

void loadFCM() async {
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      enableVibration: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

void listenFCM() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin?.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel!.id,
            channel!.name,
            icon: 'begize',
          ),
        ),
      );
    }
  });
}
