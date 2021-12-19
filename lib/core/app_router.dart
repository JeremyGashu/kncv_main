import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kncv_flutter/presentation/pages/homepage/homepage.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_one.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_three.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_two.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';
import 'package:kncv_flutter/presentation/pages/reset/reset_password.dart';
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';

class AppRouter {
  static Route? onGenerateRoute(RouteSettings settings) {
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

      case HomePage.homePageRouteName:
        return MaterialPageRoute(builder: (_) => HomePage());
      case OrderDetailPage.orderDetailPageRouteName:
        return MaterialPageRoute(builder: (_) => OrderDetailPage());
      case SplashPage.splashPageRouteName:
        return MaterialPageRoute(builder: (_) => SplashPage());
    }
  }
}
