import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/auth/auth_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/homepage/widgets/item_cart.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_courier.dart';
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
