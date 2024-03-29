import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_states.dart';
import 'package:kncv_flutter/presentation/pages/homepage/courier_homepage.dart';
import 'package:kncv_flutter/presentation/pages/homepage/receiver_homepage.dart';
import 'package:kncv_flutter/presentation/pages/homepage/sender_homepage.dart';

class LoginPage extends StatefulWidget {
  static const String loginPageRouteName = 'login page route name';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Begize',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Specimen Referral System Ethiopia',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextField(
                            controller: _usernameController,
                            autofocus: false,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person, color: kIconColors),
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                ))),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextField(
                            controller: _passwordController,
                            autofocus: false,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.vpn_key, color: kIconColors),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible ? Icons.visibility_off : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.8),
                                ),
                              ),
                              // border: UnderlineInputBorder(
                              //   borderSide: BorderSide(
                              //     color: Colors.grey.withOpacity(0.1),
                              //   ),
                              // ),
                            ),
                          ),
                        ),
                        // Container(
                        //   constraints: BoxConstraints(
                        //     maxWidth: 500
                        //   ),
                        //   child: Align(
                        //     alignment: Alignment.centerRight,
                        //     child: Container(
                        //       // width: double.infinity,
                        //       child: InkWell(
                        //         onTap: () {
                        //           Navigator.pushNamed(context,
                        //               ResetPasswordPage.resetPasswordPageName);
                        //         },
                        //         child: Text(
                        //           'Forgot Password',
                        //           textAlign: TextAlign.end,
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 14,
                        //             color: kColorsOrangeLight,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
                          if (state is AuthenticatedState) {
                            // print('type => ${state.type}');
                            if (state.type == 'COURIER_ADMIN') {
                              Navigator.pushNamedAndRemoveUntil(context, CourierHomePage.courierHomePageRouteName, (route) => false);
                            } else if (state.type == 'INSTITUTIONAL_ADMIN') {
                              Navigator.pushNamedAndRemoveUntil(context, SenderHomePage.senderHomePageRouteName, (route) => false);
                            } else if (state.type == 'TEST_CENTER_ADMIN') {
                              Navigator.pushNamedAndRemoveUntil(context, ReceiverHomePage.receiverHomepageRouteName, (route) => false);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Credential!')));
                            }
                          } else if (state is UnauthenticatedState || state is ErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Credential')));
                          }
                        }, builder: (context, state) {
                          return state is LoadingState
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  constraints: BoxConstraints(maxWidth: 500),
                                  child: InkWell(
                                    onTap: () {
                                      String email = _usernameController.value.text;
                                      String password = _passwordController.value.text;
                                      BlocProvider.of<AuthBloc>(context).add(LoginUser(email: '$email@kncv.com', password: password));
                                    },
                                    borderRadius: BorderRadius.circular(37),
                                    child: Container(
                                      constraints: BoxConstraints(maxWidth: 500),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: kColorsOrangeDark,
                                      ),
                                      height: 62,
                                      // margin: EdgeInsets.all(20),
                                      child: Center(
                                        child: Text(
                                          'Log In',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                        }),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
