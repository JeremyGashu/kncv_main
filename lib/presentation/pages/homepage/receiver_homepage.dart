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
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../data/repositories/orders_repository.dart';
import '../../../service_locator.dart';
import '../report/report_page.dart';

const String URL = 'https://frozen-tundra-74972.herokuapp.com';

IO.Socket socket = IO.io(URL, <String, dynamic>{
  "transports": ["websocket"],
});

class ReceiverHomePage extends StatefulWidget {
  static const receiverHomepageRouteName = 'receiver home page rout ename';

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage>
    with WidgetsBindingObserver {
  OrderBloc orderBloc = sl<OrderBloc>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('State ==> $state');
    if (state == AppLifecycleState.resumed) {
      print('Reconnect the socket');
    }
  }

  @override
  void initState() {
    // socket.io
    print('test center called');

    orderBloc.add(LoadOrdersForTester());
    sl<TesterCourierBloc>()..add(LoadTestersAndCouriers());
    super.initState();

    socket.onConnect((_) {
      print('===== Connected to socket =====');
      print('Connected => ${socket.connected}');

      AuthRepository.currentUser().then((value) {
        String type = value['type'];
        if (type != 'TEST_CENTER_ADMIN') {
          socket.emit('SEND_USER_STATUS', value['phone']);
          print('Update phone number status of ${value['phone']}');
        } else {
          OrderRepository.getTestCenterFromAdminId(value['uid']).then((tc) {
            socket.emit('SEND_USER_STATUS', tc?['phone']);
            print('Update phone number status of ${tc?['phone']}');
          });
        }
      });
    });

    socket.on('UPDATE_TIMER', (data) {
      debugPrint('Timer updated $data');
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket');
    });
  }

  @override
  void dispose() {
    // socket.disconnect();
    // print('test center closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<SMSBloc, SMSState>(listener: (ctx, state) {
      if (state is UpdatedDatabase) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Order has been Updated!')));
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
                      color: Colors.white,
                    ),
                  ),
                  elevation: 0,
                  actions: [
                    kIsWeb
                        ? IconButton(
                            onPressed: () {
                              orderBloc.add(LoadOrdersForTester());
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
                              print('Snapshot data => ${snapshot.data}:');

                              // print(snapshot.data['']);
                              return size.width < 191
                                  ? SizedBox.shrink()
                                  : Text(
                                      // 'Logged in  as: \n${getUserName(snapshot.data) ?? ''}',
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
                        color: Colors.black,
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
                                      Navigator.pushNamed(context,
                                          LoginPage.loginPageRouteName);
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
                                                        OrderDetailTester
                                                            .orderDetailTesterPageRouteName,
                                                        arguments: state
                                                            .orders[index]
                                                            .orderId);
                                                if (load == true) {
                                                  orderBloc.add(
                                                      LoadOrdersForTester());
                                                } else {
                                                  orderBloc.add(
                                                      LoadOrdersForTester());
                                                }
                                              },
                                              child: orderCard(
                                                state.orders[index],
                                                isTester: true,
                                              ),
                                            );
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
