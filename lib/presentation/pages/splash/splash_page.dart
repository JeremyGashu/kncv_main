import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_states.dart';
import 'package:kncv_flutter/presentation/pages/homepage/homepage.dart';
import 'package:kncv_flutter/presentation/pages/intros/intro_page_one.dart';

class SplashPage extends StatelessWidget {
  static const String splashPageRouteName = 'splash page route name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
        if (state is UnauthenticatedState) {
          Navigator.pushNamedAndRemoveUntil(
              context, IntroPageOne.introPageOneRouteName, (route) => false);
        } else if (state is AuthenticatedState) {
          Navigator.pushNamedAndRemoveUntil(
              context, HomePage.homePageRouteName, (route) => false);
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
