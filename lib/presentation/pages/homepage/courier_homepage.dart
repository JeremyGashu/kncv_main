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
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_courier.dart';

import '../../../service_locator.dart';
import '../report/report_page.dart';

class CourierHomePage extends StatefulWidget {
  static const courierHomePageRouteName = 'courier home page';

  @override
  State<CourierHomePage> createState() => _CourierHomePageState();
}

class _CourierHomePageState extends State<CourierHomePage> {
  OrderBloc orderBloc = sl<OrderBloc>();

  @override
  void initState() {
    orderBloc.add(LoadOrdersForCourier());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<SMSBloc, SMSState>(listener: (ctx, state) {
      if (state is UpdatedDatabase) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Order has been Updated!')));
        orderBloc.add(LoadOrdersForCourier());
      }
    }, builder: (context, snapshot) {
      return BlocConsumer<OrderBloc, OrderState>(
          bloc: orderBloc,
          listener: (ctx, state) async {},
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                orderBloc.add(LoadOrdersForCourier());
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
                      color: Colors.white,
                    ),
                  ),
                  elevation: 0,
                  actions: [
                    kIsWeb
                        ? IconButton(
                            onPressed: () {
                              orderBloc.add(LoadOrdersForCourier());
                              sl<TesterCourierBloc>()
                                ..add(LoadTestersAndCouriers());
                            },
                            icon: Icon(
                              Icons.refresh,
                            ),
                            color: Colors.white,
                          )
                        : SizedBox(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ReportScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.bar_chart),
                      color: Colors.white,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          int counter = 0;
                          if (snapshot.hasData) {
                            counter =
                                getUnseenNotificationsCount(snapshot.data);
                          }

                          return Container(
                            padding: EdgeInsets.only(top: 10, right: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context,
                                    NotificationsPage.notificationsRouteName);
                              },
                              child: Badge(
                                badgeContent: Text('${counter}'),

                                badgeColor: Colors.white,
                                // padding: EdgeInsets.only(top: 10),

                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                    Center(
                      child: FutureBuilder(
                          future: AuthRepository.currentUser(),
                          builder: (context,
                              AsyncSnapshot<Map<String, dynamic>> snapshot) {
                            if (snapshot.hasData) {
                              return size.width < 191
                                  ? SizedBox.shrink()
                                  : Text(
                                      snapshot.data!['name'] != null
                                          ? 'Logged in  as: \n${snapshot.data!['name'] ?? ''}'
                                          : '',
                                      style: TextStyle(
                                        // fontSize: 12,
                                        fontSize: size.width < 290
                                            ? size.width * 0.03
                                            : size.width > 320
                                                ? 12
                                                : size.width * 0.03,
                                      ),
                                    );
                            }
                            return Container();
                          }),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (builder) {
                              return AlertDialog(
                                title: Text('Log Out'),
                                content:
                                    Text('Are you sure you want to Log Out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          LoginPage.loginPageRouteName,
                                          (route) => false);
                                      BlocProvider.of<AuthBloc>(context)
                                          .add(LogOutUser());
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
                body: state is LoadingOrderForCourier
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : state is LoadedOrdersForCourier
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
                                      constraints:
                                          BoxConstraints(maxWidth: 700),
                                      child: Center(
                                        child: ListView.builder(
                                            itemCount: state.orders.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                  onTap: () async {
                                                    // print('${state.orders[index].orderId}');
                                                    var load = await Navigator
                                                        .pushNamed(
                                                            context,
                                                            OrderDetailCourier
                                                                .orderDetailCourierPageRouteName,
                                                            arguments: state
                                                                .orders[index]
                                                                .orderId);
                                                    if (load == true) {
                                                      orderBloc.add(
                                                          LoadOrdersForCourier());
                                                    } else {
                                                      orderBloc.add(
                                                          LoadOrdersForCourier());
                                                    }
                                                  },
                                                  child: orderCard(
                                                      state.orders[index]));
                                            }),
                                      ),
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
