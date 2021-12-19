import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';

import 'widgets/item_cart.dart';


class HomePage extends StatelessWidget {
  static const String homePageRouteName = 'home page route name';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: AppBar(
        backgroundColor: kColorsOrangeLight,
        automaticallyImplyLeading: false,
        title: Text(
          'Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                'EG',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            orderCard(),
            orderCard(),
            orderCard(),
            orderCard(),
            orderCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorsOrangeLight,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Container(
                  padding:
                      EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        30,
                      ),
                      topRight: Radius.circular(
                        30,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Create An Order',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                          width: double.infinity,
                          child: Text(
                            'Nearby Couriers',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              color: kTextColorLight,
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            underline: null,
                            focusColor: Colors.white,
                            // value: _chosenValue,
                            //elevation: 5,
                            style: TextStyle(color: Colors.white),
                            iconEnabledColor: Colors.black,
                            items: [
                              'Android',
                              'IOS',
                              'Flutter',
                              'Node',
                              'Java',
                              'Python',
                              'PHP',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            hint: Text(
                              "Please Select Nearby Courier",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                          width: double.infinity,
                          child: Text(
                            'Nearby Test Centers',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              color: kTextColorLight,
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            underline: null,
                            focusColor: Colors.white,
                            // value: _chosenValue,
                            //elevation: 5,
                            style: TextStyle(color: Colors.white),
                            iconEnabledColor: Colors.black,
                            items: [
                              'Android',
                              'IOS',
                              'Flutter',
                              'Node',
                              'Java',
                              'Python',
                              'PHP',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            hint: Text(
                              "Please Select Nearby Test Center",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 40,
                      // ),
                      SizedBox(
                        height: 45,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context,
                              OrderDetailPage.orderDetailPageRouteName);
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
                              'Create Order',
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
                );
              });
        },
      ),
    );
  }
}
