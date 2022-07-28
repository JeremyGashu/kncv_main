import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_states.dart';
import 'package:kncv_flutter/presentation/pages/homepage/courier_homepage.dart';
import 'package:kncv_flutter/presentation/pages/homepage/receiver_homepage.dart';
import 'package:kncv_flutter/presentation/pages/homepage/sender_homepage.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_one.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';

class SplashPage extends StatefulWidget {
  static const String splashPageRouteName = 'splash page route name';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    initMessaging();
    super.initState();
  }

  //seconds
  final int splashTime = 3;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is UnauthenticatedState || state is InitialState) {
            await Future.delayed(Duration(seconds: splashTime));
            Navigator.pushNamedAndRemoveUntil(context, IntroPageOne.introPageOneRouteName, (route) => false);
          } else if (state is AuthenticatedState) {
            // print('type => ${state.type}');
            if (state.type == 'COURIER_ADMIN') {
              await Future.delayed(Duration(seconds: splashTime));
              Navigator.pushNamedAndRemoveUntil(context, CourierHomePage.courierHomePageRouteName, (route) => false);
            } else if (state.type == 'INSTITUTIONAL_ADMIN') {
              await Future.delayed(Duration(seconds: splashTime));
              Navigator.pushNamedAndRemoveUntil(context, SenderHomePage.senderHomePageRouteName, (route) => false);
            } else if (state.type == 'TEST_CENTER_ADMIN') {
              await Future.delayed(Duration(seconds: splashTime));
              Navigator.pushNamedAndRemoveUntil(context, ReceiverHomePage.receiverHomepageRouteName, (route) => false);
            } else {
              await Future.delayed(Duration(seconds: splashTime));
              Navigator.pushNamedAndRemoveUntil(context, LoginPage.loginPageRouteName, (route) => false);
            }
          }
        },
        builder: (context, state) {
          // return Center(
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Container(child: Image.asset('assets/images/hand.png')),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Container(child: Image.asset('assets/images/KNCV.png')),
          //         ],
          //       ),
          //       SizedBox(
          //         height: 15,
          //       ),
          //       Container(child: Image.asset('assets/images/TBtext.png')),
          //     ],
          //   ),
          // );
          return Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.2),
                  SvgPicture.asset(
                    'assets/Begize.svg',
                    height: size.height * 0.15,
                    // width: size.width * 0.4,
                  ),
                  Spacer(),
                  size.width < 330
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Powered By", style: TextStyle(fontSize: size.width * 0.06, fontWeight: FontWeight.bold)),
                            SizedBox(width: size.width * 0.04),
                            Image(image: AssetImage('assets/ephi_logo.jpg'), width: size.width * 0.1),
                            SizedBox(width: size.width * 0.04),
                            SvgPicture.asset('assets/Knvc.svg', width: size.width * 0.1),
                          ],
                        )
                      : size.width < 420
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Powered By", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                SizedBox(width: 20),
                                Image(image: AssetImage('assets/ephi_logo.jpg'), width: size.width * 0.2),
                                SizedBox(width: 20),
                                SvgPicture.asset(
                                  'assets/Knvc.svg',
                                  width: size.width * 0.2,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Powered By", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(width: 20),
                                Image(image: AssetImage('assets/ephi_logo.jpg'), width: 80),
                                SizedBox(width: 20),
                                SvgPicture.asset(
                                  'assets/Knvc.svg',
                                  width: 80,
                                ),
                              ],
                            ),
                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void onSelectNotification(String? payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  void showNotification(String? title, String? body) async {
    await _demoNotification(title ?? '', body ?? '');
  }

  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails('FLUTTER_STREAMING_APP', 'STREAMING_APP', importance: Importance.max, playSound: true, showProgress: true, priority: Priority.high, ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

  initMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    String? token = await messaging.getToken();
    // print("USER TOKEN:" + token!);

    FirebaseMessaging.onMessage.listen((message) {
      //todo => use flutter local notification to show notification in the background
      // print('NOTIFICATION RECEIVED');
      showNotification(message.notification?.title, message.notification?.body);
      // print('TITLE => ${message.notification?.title}');
      // print('TITLE => ${message.notification?.body}');
    });
  }
}
