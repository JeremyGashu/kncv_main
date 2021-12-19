import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_states.dart';
import 'package:kncv_flutter/presentation/pages/homepage/homepage.dart';
import 'package:kncv_flutter/presentation/pages/reset/reset_password.dart';

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
                      child: Text(
                    'e-Specimen e-Referral System Ethiopia',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
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
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person, color: kIconColors),
                              labelText: 'Username',
                              labelStyle: TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ))),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.vpn_key, color: kIconColors),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility_rounded,
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            // width: double.infinity,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context,
                                    ResetPasswordPage.resetPasswordPageName);
                              },
                              child: Text(
                                'Forgot Password',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: kColorsOrangeLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                          if (state is AuthenticatedState) {
                            Navigator.pushNamedAndRemoveUntil(context,
                                HomePage.homePageRouteName, (route) => false);
                          } else if (state is UnauthenticatedState ||
                              state is ErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid Credential')));
                          }
                        }, builder: (context, state) {
                          return state is LoadingState
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : InkWell(
                                  onTap: () {
                                    String email =
                                        _usernameController.value.text;
                                    String password =
                                        _passwordController.value.text;
                                    BlocProvider.of<AuthBloc>(context).add(
                                        LoginUser(
                                            email: email, password: password));
                                  },
                                  borderRadius: BorderRadius.circular(37),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: kColorsOrangeDark,
                                    ),
                                    height: 62,
                                    // margin: EdgeInsets.all(20),
                                    child: Center(
                                      child: Text(
                                        'Log In',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
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
