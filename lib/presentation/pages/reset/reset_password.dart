import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String resetPasswordPageName = 'reset password route name';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool changingPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kColorsOrangeDark,
        title: Text(
          'Reset Password',
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            child: Container(
              constraints: BoxConstraints(maxWidth: 700),
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
                        'Specimen Referral System Ethiopia',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 40,
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
                                'Reset Password',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                ),
                              ),
                            ),
                            TextField(
                              autofocus: false,
                              obscureText: true,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.phone, color: kIconColors),
                                  labelText: 'New Password',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                  ))),
                            ),
                            TextField(
                              controller: _confirmPasswordController,
                              autofocus: false,
                              obscureText: true,
                              decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.phone, color: kIconColors),
                                  labelText: 'Confirm New Password',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                  ))),
                            ),
                            changingPassword
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        changingPassword = true;
                                      });

                                      String _password =
                                          _passwordController.value.text;
                                      String _confirmPassword =
                                          _confirmPasswordController.value.text;
                                      if (_password.length < 6) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Password must be at least 6 characters.')));
                                        setState(() {
                                          changingPassword = false;
                                        });
                                        return;
                                      }
                                      if (_password != _confirmPassword) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Password did not match.')));
                                        setState(() {
                                          changingPassword = false;
                                        });
                                        return;
                                      }

                                      FirebaseAuth.instance.currentUser
                                          ?.updatePassword(_password)
                                          .then((value) async {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Password changed successfully.')));

                                        setState(() {
                                          changingPassword = false;
                                        });

                                        await Future.delayed(
                                            Duration(seconds: 1));
                                        Navigator.pop(context);
                                      });

                                      // setState(() {
                                      //   changingPassword = false;
                                      // });
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
                                          'Change Password',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
