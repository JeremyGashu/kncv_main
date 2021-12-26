import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kncv_flutter/presentation/pages/homepage/courier_homepage.dart';
import 'package:kncv_flutter/presentation/pages/homepage/receiver_homepage.dart';
import 'package:kncv_flutter/presentation/pages/homepage/sender_homepage.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_one.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_three.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_two.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_courier.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_tester.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';
import 'package:kncv_flutter/presentation/pages/orders/result_page.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/edit_patient_info.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/patient_info.dart';
import 'package:kncv_flutter/presentation/pages/reset/reset_password.dart';
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';
import 'package:kncv_flutter/presentation/pages/tester_courier_selector/tester_courier_selector.dart';

class AppRouter {
  static Route? onGenerateRoute(RouteSettings settings) {
    dynamic args = settings.arguments;
    print(args);
    switch (settings.name) {
      case IntroPageOne.introPageOneRouteName:
        return PageRouteBuilder(
          pageBuilder: (c, a1, a2) => IntroPageOne(),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 200),
        );

      case InstroPageTwo.introPageTwoName:
        return PageRouteBuilder(
          pageBuilder: (c, a1, a2) => InstroPageTwo(),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 200),
        );

      case InstroPageThree.introPageThreeName:
        return PageRouteBuilder(
          pageBuilder: (c, a1, a2) => InstroPageThree(),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 200),
        );

      case LoginPage.loginPageRouteName:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case ResetPasswordPage.resetPasswordPageName:
        return MaterialPageRoute(builder: (_) => ResetPasswordPage());

      case SenderHomePage.senderHomePageRouteName:
        return MaterialPageRoute(builder: (_) => SenderHomePage());
      case OrderDetailPage.orderDetailPageRouteName:
        return MaterialPageRoute(
            builder: (_) => OrderDetailPage(
                  orderId: args,
                ));
      case SplashPage.splashPageRouteName:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case PatientInfoPage.patientInfoPageRouteName:
        return MaterialPageRoute(
            builder: (_) => PatientInfoPage(orderId: args));

      case SelectorPage.selectorPageRouteName:
        return MaterialPageRoute(
            builder: (_) => Scaffold(body: SelectorPage()));

      case EditPatientInfoPage.editPatientInfoRouteName:
        return MaterialPageRoute(
          builder: (_) => EditPatientInfoPage(
            orderId: args['orderId'],
            patient: args['patient'],
            index: args['index'],
          ),
        );

      case CourierHomePage.courierHomePageRouteName:
        return MaterialPageRoute(builder: (_) => CourierHomePage());
      case ReceiverHomePage.receiverHomepageRouteName:
        return MaterialPageRoute(builder: (_) => ReceiverHomePage());
      case OrderDetailCourier.orderDetailCourierPageRouteName:
        return MaterialPageRoute(
            builder: (_) => OrderDetailCourier(
                  orderId: args,
                ));

      case OrderDetailTester.orderDetailTesterPageRouteName:
        return MaterialPageRoute(
            builder: (_) => OrderDetailTester(orderId: args));

      case AddTestResultPage.addTestResultPageRouteName:
        return MaterialPageRoute(
          builder: (_) => AddTestResultPage(
            orderId: args['orderId'],
            patient: args['patient'],
            index: args['index'],
          ),
        );
    }
  }
}
