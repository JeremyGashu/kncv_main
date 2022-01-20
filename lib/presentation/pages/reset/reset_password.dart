import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String resetPasswordPageName = 'reset password route name';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
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
                    'Specimen Referral System Ethiopia',
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
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone, color: kIconColors),
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ))),
                        ),
                        InkWell(
                          onTap: () {},
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
                                'Reset Password',
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
    );
  }
}
