import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/repositories/auth_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/homepage/widgets/item_cart.dart';
import 'package:kncv_flutter/presentation/pages/login/login_page.dart';
import 'package:kncv_flutter/presentation/pages/notificatins.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_courier.dart';

import '../../../service_locator.dart';

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
    return BlocConsumer<OrderBloc, OrderState>(
        bloc: orderBloc,
        listener: (ctx, state) async {},
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              orderBloc.add(LoadOrdersForCourier());
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
                  Center(
                    child: FutureBuilder(
                        future: AuthRepository.currentUser(),
                        builder: (context,
                            AsyncSnapshot<Map<String, dynamic>> snapshot) {
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
                              ? Center(
                                  child: Text('No Waiting Order!'),
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
                                              OrderDetailCourier
                                                  .orderDetailCourierPageRouteName,
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
