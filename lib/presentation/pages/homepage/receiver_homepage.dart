import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/homepage/widgets/item_cart.dart';
import 'package:kncv_flutter/presentation/pages/notificatins.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_tester.dart';
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';

import '../../../service_locator.dart';

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
    return BlocConsumer<OrderBloc, OrderState>(
        bloc: orderBloc,
        listener: (ctx, state) async {},
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              orderBloc.add(LoadOrdersForTester());
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
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        int counter = 0;
                        if (snapshot.hasData) {
                          counter = getUnseenNotificationsCount(snapshot.data);
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
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context,
                          SplashPage.splashPageRouteName, (route) => false);
                      BlocProvider.of<AuthBloc>(context).add(LogOutUser());
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
                              ? Center(
                                  child: Text('No Orders Available!'),
                                )
                              : ListView.builder(
                                  itemCount: state.orders.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () async {
                                          print(
                                              '${state.orders[index].orderId}');
                                          var load = await Navigator.pushNamed(
                                              context,
                                              OrderDetailTester
                                                  .orderDetailTesterPageRouteName,
                                              arguments:
                                                  state.orders[index].orderId);
                                          if (load == true) {
                                            orderBloc.add(LoadOrders());
                                          }
                                        },
                                        child: orderCard(state.orders[index]));
                                  }),
                        )
                      : Container(),
            ),
          );
        });
  }
}

int getUnseenNotificationsCount(QuerySnapshot? snapshot) {
  int counter = 0;
  String? currentUser = FirebaseAuth.instance.currentUser?.uid;

  snapshot?.docs.forEach((e) {
    Map? d = e.data() as Map;
    print('current user ${currentUser == d['user_id']}');
    print('current user ${currentUser == d['user_id']}');
    if ((currentUser == d['user_id']) && (d['seen'] == false)) {
      counter++;
    }
  });

  return counter;
}
