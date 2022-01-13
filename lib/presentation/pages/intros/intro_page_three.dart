import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';

import 'intro_page_two.dart';

class InstroPageThree extends StatelessWidget {
  static const String introPageThreeName = 'intro page three route name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Note: Sensitivity is integer used when you don't want to mess up vertical drag
          int sensitivity = 20;
          if (details.delta.dx > sensitivity) {
            Navigator.pushNamed(context, InstroPageTwo.introPageTwoName);
          } else if (details.delta.dx < -sensitivity) {
            // Navigator.pushNamed(context, InstroPageThree.introPageThreeName);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kColorsOrangeLight,
                kColorsOrangeDark,
              ],
              begin: AlignmentDirectional.topCenter,
              end: AlignmentDirectional.bottomCenter,
            ),
          ),
          height: double.infinity,
          width: double.infinity,
          // color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(
                      child: Image.asset('assets/images/phone_image.png')),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        100,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 25),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // mainAxisAlignment: ,
                          children: [
                            Hero(
                              tag: 'pointer_one',
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(
                                    0.6,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Hero(
                              tag: 'pointer_two',
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(
                                    0.6,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Hero(
                              tag: 'pointer_three',
                              child: Container(
                                width: 55,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: kColorsOrangeLight,
                                  borderRadius: BorderRadius.circular(
                                    23,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20.0, right: 20.0),
                        child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 30),
                            child: Text(
                              'Testing Health Facility',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            )),
                      ),
                      Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          child: Text(
                              'As a receiver the app allows to confirm receipt of samples, inspect the quality of samples, and input the test result.',
                              style: TextStyle(
                                color: kTextColorLight.withOpacity(0.7),
                                fontSize: 18,
                              ))),

                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, LoginPage.loginPageRouteName);
                        },
                        borderRadius: BorderRadius.circular(37),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kColorsOrangeDark,
                          ),
                          height: 62,
                          margin: EdgeInsets.all(20),
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
