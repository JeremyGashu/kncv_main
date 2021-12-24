import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
        if (state is UnauthenticatedState || state is InitialState) {
          Navigator.pushNamedAndRemoveUntil(
              context, IntroPageOne.introPageOneRouteName, (route) => false);
        } else if (state is AuthenticatedState) {
          print('type => ${state.type}');
          if (state.type == 'COURIER_ADMIN') {
            Navigator.pushNamedAndRemoveUntil(context,
                CourierHomePage.courierHomePageRouteName, (route) => false);
          } else if (state.type == 'INSTITUTIONAL_ADMIN') {
            Navigator.pushNamedAndRemoveUntil(context,
                SenderHomePage.senderHomePageRouteName, (route) => false);
          } else if (state.type == 'TEST_CENTER_ADMIN') {
            Navigator.pushNamedAndRemoveUntil(context,
                ReceiverHomePage.receiverHomepageRouteName, (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, LoginPage.loginPageRouteName, (route) => false);
          }
        }
      }, builder: (context, state) {
        if (state is LoadingState) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(child: Image.asset('assets/images/hand.png')),
                    SizedBox(
                      width: 10,
                    ),
                    Container(child: Image.asset('assets/images/KNCV.png')),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(child: Image.asset('assets/images/TBtext.png')),
              ],
            ),
          );
        }
        return Container();
      }),
    );
  }
}
