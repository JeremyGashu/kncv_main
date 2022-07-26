import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';

import 'intro_page_two.dart';

class IntroPageOne extends StatelessWidget {
  static const String introPageOneRouteName = 'intro page one route name';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Note: Sensitivity is integer used when you don't want to mess up vertical drag
          int sensitivity = 20;
          if (details.delta.dx > sensitivity) {
            print('left');
          } else if (details.delta.dx < -sensitivity) {
            Navigator.pushNamed(context, InstroPageTwo.introPageTwoName);
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
          // height: double.infinity,
          height: size.height,
          width: double.infinity,
          // color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(child: Image.asset('assets/images/phone_image.png', height: size.height * 0.35)),
                  // child: Center(child: Image.asset('assets/images/phone_image.png')),
                ),
              ),
              Expanded(
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
                              tag: 'pointrt_one',
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
                          ],
                        ),
                      ),
                      //
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                        child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 30),
                            child: Text(
                              'Referring Health Facility',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: size.width < 563 ? size.width * 0.04 : 25,
                              ),
                            )),
                      ),
                      Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          child: Text(
                              'As a Referring Health Facilty this is a mobile app allows to create sample orders (i.e Sputum , Stool , Blood , Urine , etc.) , send the orders , confirm collection and view the status of samples.',
                              style: TextStyle(
                                color: kTextColorLight.withOpacity(0.7),
                                fontSize: size.width < 563 ? size.width * 0.04 : 18,
                              ))),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, LoginPage.loginPageRouteName);
                              },
                              child: Text(
                                'Skip Now',
                                style: TextStyle(
                                  fontSize: size.width < 563 ? size.width * 0.04 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: kTextColorLight,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, InstroPageTwo.introPageTwoName);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Container(
                                width: size.width < 563 ? size.width * 0.08 : 74,
                                height: size.width < 563 ? size.width * 0.08 : 74,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(37),
                                  color: kColorsOrangeDark,
                                ),
                                child: Center(
                                  child: Container(
                                    width: size.width < 563 ? size.width * 0.04 : 36,
                                    height: size.width < 563 ? size.width * 0.04 : 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(37),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_right_alt,
                                        color: kColorsOrangeDark,
                                        size: size.width < 563 ? size.width * 0.04 : 36,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01)
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
