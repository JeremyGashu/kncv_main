import 'dart:math';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_state.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/patient_info.dart';
import 'package:kncv_flutter/presentation/pages/report/report_page.dart';
import 'package:kncv_flutter/presentation/pages/reset/reset_password.dart';
import 'package:kncv_flutter/presentation/pages/tester_courier_selector/tester_courier_selector.dart';
import '../../../service_locator.dart';
import '../../../utils/string_utils.dart';
import '../notificatins.dart';
import 'widgets/item_cart.dart';

class SenderHomePage extends StatefulWidget {
  static const String senderHomePageRouteName = 'home page route name';

  @override
  State<SenderHomePage> createState() => _SenderHomePageState();
}

class _SenderHomePageState extends State<SenderHomePage> {
  OrderBloc orderBloc = sl<OrderBloc>();
  @override
  void initState() {
    orderBloc.add(LoadOrders());
    super.initState();
  }

  String courierId = 'Select Courier...';
  String testId = 'Select Tester...';
  String courierName = '';
  String testerName = '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<SMSBloc, SMSState>(listener: (ctx, state) {
      if (state is UpdatedDatabase) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Order has been Updated!')));
        orderBloc.add(LoadOrders());
      }
    }, builder: (context, snapshot) {
      return BlocConsumer<OrderBloc, OrderState>(
          bloc: orderBloc,
          listener: (ctx, state) async {
            if (state is SentOrder) {
              // ScaffoldMessenger.of(context)
              //     .showSnackBar(SnackBar(content: Text('Created order!')));
              orderBloc.add(LoadOrders());
              await Future.delayed(Duration(milliseconds: 500));
              var success = await Navigator.pushNamed(
                  context, PatientInfoPage.patientInfoPageRouteName,
                  arguments: state.orderId);
              if (success == true) {
                orderBloc.add(LoadOrders());
              }
            } else if (state is SendingOrder) {
              // ScaffoldMessenger.of(context)
              //     .showSnackBar(SnackBar(content: Text('Creating order...')));
            } else if (state is LaodedState) {
              // print(state.orders);
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                orderBloc.add(LoadOrders());
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
                              orderBloc.add(LoadOrders());
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
                    kIsWeb
                        ? Container(
                            margin: EdgeInsets.only(top: 7),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context,
                                      ResetPasswordPage.resetPasswordPageName);
                                },
                                icon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                )))
                        : SizedBox(),
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
                              // print('snapshot data:');
                              // print(snapshot.data);
                              return size.width < 191
                                  ? SizedBox.shrink()
                                  : Text(
                                      // 'Logged in  as: \n${getUserName(snapshot.data) ?? ''}',
                                      snapshot.data!['user'].email != null
                                          ? 'Logged in  as: \n${getUserName(snapshot.data) ?? ''}'
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
                    // Container(
                    //   padding: EdgeInsets.all(5),
                    //   child: CircleAvatar(
                    //     radius: 20,
                    //     backgroundColor: Colors.white,
                    //     child: Text(
                    //       'EG',
                    //       style: TextStyle(
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                body: state is LoadingState
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : state is LaodedState
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            // child: ListView(
                            //   children: [
                            //     orderCard(),
                            //     orderCard(),
                            //     orderCard(),
                            //     orderCard(),
                            //     orderCard(),
                            //   ],
                            // ),
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
                                      child: ListView.builder(
                                          itemCount: state.orders.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                                onTap: () async {
                                                  // print('${state.orders[index].orderId}');
                                                  var load =
                                                      await Navigator.pushNamed(
                                                          context,
                                                          OrderDetailPage
                                                              .orderDetailPageRouteName,
                                                          arguments: state
                                                              .orders[index]
                                                              .orderId);
                                                  if (load == true) {
                                                    orderBloc.add(LoadOrders());
                                                  }
                                                },
                                                child: Dismissible(
                                                    background: Container(
                                                        width: 20,
                                                        height: 20,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator())),
                                                    onDismissed: (_) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Order Deleted')));

                                                      orderBloc
                                                          .add(LoadOrders());
                                                    },
                                                    confirmDismiss: (_) async {
                                                      OrderRepository r =
                                                          sl<OrderRepository>();
                                                      var status =
                                                          await r.deleteOrder(
                                                              orderId: state
                                                                  .orders[index]
                                                                  .orderId!);
                                                      return status['success'];
                                                    },
                                                    key: Key(state.orders[index]
                                                            .orderId ??
                                                        Random()
                                                            .nextDouble()
                                                            .toString()),
                                                    child: orderCard(
                                                        state.orders[index])));
                                          }),
                                    ),
                                  ),
                          )
                        : Container(),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: kColorsOrangeLight,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    var create = await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        context: context,
                        builder: (ctx) {
                          return Container(
                            padding: EdgeInsets.only(
                                top: 30, left: 20, right: 20, bottom: 20),
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
                                SelectorPage(),
                              ],
                            ),
                          );
                        });
                    if (create == true) {
                      Tester? tester =
                          BlocProvider.of<TesterCourierBloc>(context).tester;
                      Courier? courier =
                          BlocProvider.of<TesterCourierBloc>(context).courier;
                      String? date =
                          BlocProvider.of<TesterCourierBloc>(context).date;
                      orderBloc.add(
                        AddOrder(
                          courier_id: courier!.id,
                          tester_id: tester!.id,
                          courier_name: courier.name,
                          tester_name: tester.name,
                          date: date!,
                          courier_phone: courier.phone,
                          tester_phone: tester.phone,
                          zone: tester.zone ?? {},
                          region: tester.region ?? {},
                          // woreda: tester.wo
                        ),
                      );
                    }
                  },
                ),
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
