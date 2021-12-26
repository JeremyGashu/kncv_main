import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/patient_info.dart';
import 'package:kncv_flutter/presentation/pages/splash/splash_page.dart';
import 'package:kncv_flutter/presentation/pages/tester_courier_selector/tester_courier_selector.dart';

import '../../../service_locator.dart';
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
    return BlocConsumer<OrderBloc, OrderState>(
        bloc: orderBloc,
        listener: (ctx, state) async {
          if (state is SentOrder) {
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(SnackBar(content: Text('Created order!')));
            orderBloc.add(LoadOrders());
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pushNamed(
                context, PatientInfoPage.patientInfoPageRouteName,
                arguments: state.orderId);
          } else if (state is SendingOrder) {
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(SnackBar(content: Text('Creating order...')));
          } else if (state is LaodedState) {
            print(state.orders);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              orderBloc.add(LoadOrders());
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
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                  ),
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
                              ? Center(
                                  child: Text('No order is created!'),
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
                                              OrderDetailPage
                                                  .orderDetailPageRouteName,
                                              arguments:
                                                  state.orders[index].orderId);
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
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Order Deleted')));

                                              orderBloc.add(LoadOrders());
                                            },
                                            confirmDismiss: (_) async {
                                              OrderRepository r =
                                                  sl<OrderRepository>();
                                              var status = await r.deleteOrder(
                                                  orderId: state
                                                      .orders[index].orderId!);
                                              return status['success'];
                                            },
                                            key: Key(
                                                state.orders[index].orderId ??
                                                    Random()
                                                        .nextDouble()
                                                        .toString()),
                                            child: orderCard(
                                                state.orders[index])));
                                  }),
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
                    orderBloc.add(AddOrder(
                        courier_id: courier!.id,
                        tester_id: tester!.id,
                        courier_name: courier.name,
                        tester_name: tester.name));
                  }
                },
              ),
            ),
          );
        });
  }
}