import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_state.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/pages/homepage/widgets/item_cart.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';
import 'package:kncv_flutter/presentation/pages/notificatins.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_tester.dart';
import 'package:kncv_flutter/presentation/pages/reset/reset_password.dart';

import '../../../service_locator.dart';
import '../report/report_page.dart';

class ReceiverHomePage extends StatefulWidget {
  static const receiverHomepageRouteName = 'receiver home page rout ename';

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage> {
  OrderBloc orderBloc = sl<OrderBloc>();

  @override
  void initState() {
    orderBloc.add(LoadOrdersForTester());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SMSBloc, SMSState>(listener: (ctx, state) {
      if (state is UpdatedDatabase) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order has been Updated!')));
        orderBloc.add(LoadOrdersForTester());
      }
    }, builder: (context, snapshot) {
      return BlocConsumer<OrderBloc, OrderState>(
          bloc: orderBloc,
          listener: (ctx, state) async {},
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                orderBloc.add(LoadOrdersForTester());
                sl<TesterCourierBloc>()..add(LoadTestersAndCouriers());
              },
              child: Scaffold(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ReportScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.report),
                      color: Colors.black,
                    ),
                    kIsWeb
                        ? Container(
                            margin: EdgeInsets.only(top: 7),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, ResetPasswordPage.resetPasswordPageName);
                                },
                                icon: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                )))
                        : SizedBox(),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          int counter = 0;
                          if (snapshot.hasData) {
                            counter = getUnseenNotificationsCount(snapshot.data);
                          }

                          return Container(
                            padding: EdgeInsets.only(top: 10, right: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, NotificationsPage.notificationsRouteName);
                              },
                              child: Badge(
                                badgeContent: Text('${counter}'),

                                badgeColor: Colors.white,
                                // padding: EdgeInsets.only(top: 10),

                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                    Center(
                      child: FutureBuilder(
                          future: AuthRepository.currentUser(),
                          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                'Logged in  as: ${snapshot.data?['name'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              );
                            }
                            return Container();
                          }),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (builder) {
                              return AlertDialog(
                                title: Text('Log Out'),
                                content: Text('Are you sure you want to Log Out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, LoginPage.loginPageRouteName);
                                      BlocProvider.of<AuthBloc>(context).add(LogOutUser());
                                    },
                                    child: Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No'),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ],
                ),
                body: state is LoadingOrderForTester
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : state is LoadedOrdersForTester
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: state.orders.length == 0
                                ? ListView(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 500,
                                        // color: Colors.red,
                                        child: Center(
                                          child: Text(
                                            'No order is created!',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      constraints: BoxConstraints(maxWidth: 700),
                                      child: ListView.builder(
                                          itemCount: state.orders.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                                onTap: () async {
                                                  print('${state.orders[index].orderId}');
                                                  var load = await Navigator.pushNamed(context, OrderDetailTester.orderDetailTesterPageRouteName, arguments: state.orders[index].orderId);
                                                  if (load == true) {
                                                    orderBloc.add(LoadOrdersForTester());
                                                  } else {
                                                    orderBloc.add(LoadOrdersForTester());
                                                  }
                                                },
                                                child: orderCard(state.orders[index]));
                                          }),
                                    ),
                                  ),
                          )
                        : Container(),
              ),
            );
          });
    });
  }
}

int getUnseenNotificationsCount(QuerySnapshot? snapshot) {
  int counter = 0;
  String? currentUser = FirebaseAuth.instance.currentUser?.uid;

  snapshot?.docs.forEach((e) {
    Map? d = e.data() as Map;
    // print('current user ${currentUser == d['user_id']}');
    // print('current user ${currentUser == d['user_id']}');
    if ((currentUser == d['user_id']) && (d['seen'] == false)) {
      counter++;
    }
  });

  return counter;
}
