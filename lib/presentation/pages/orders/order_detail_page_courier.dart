import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kncv_flutter/core/colors.dart';
// import 'package:kncv_flutter/core/hear_beat.dart';
// import 'package:kncv_flutter/core/message_codes.dart';
// import 'package:kncv_flutter/core/sms_handler.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_state.dart' as smsState;
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/pages/notificatins.dart';
import 'package:kncv_flutter/service_locator.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailCourier extends StatefulWidget {
  final String orderId;
  static const String orderDetailCourierPageRouteName =
      'order detail courier page route name';

  const OrderDetailCourier({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailCourier> createState() => _OrderDetailCourierState();
}

class _OrderDetailCourierState extends State<OrderDetailCourier> {
  bool notifiyingArrival = false;
  String? inColdChain;
  String? sputumCondition;
  String? stoolCondition;
  String? time;
  String? date;

  OrderBloc ordersBloc = sl<OrderBloc>();
  bool notifyingArrival = false;
  @override
  void initState() {
    ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SMSBloc, smsState.SMSState>(listener: (ctx, state) {
      if (state is smsState.UpdatedDatabase) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order has been Updated!')));
        ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
      }
    }, builder: (context, snapshot) {
      return BlocConsumer<OrderBloc, OrderState>(
          bloc: ordersBloc,
          listener: (ctx, state) async {
            if (state is ErrorState) {
              // ScaffoldMessenger.of(context)
              //     .showSnackBar(SnackBar(content: Text(state.message)));
              await Future.delayed(Duration(seconds: 1));
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
            } else if (state is AcceptedOrderCourier) {
              addNotification(
                orderId: widget.orderId,
                courierContent:
                    'You have accepted order from ${state.order.sender_name} to ${state.order.tester_name}.',
                senderContent:
                    'Courier coming to collect order to ${state.order.tester_name}. Will reach at your place on ${state.date} at ${state.time}.',
                testerContent:
                    'Courier going to collect order from ${state.order.sender_name}.',
                content: 'One order got accepted by courier!',
                courierAction: NotificationAction.NavigateToOrderDetalCourier,
                testerAction: NotificationAction.NavigateToOrderDetalTester,
                senderAction: NotificationAction.NavigateToOrderDetalSender,
                payload: {'orderId': widget.orderId},
              );
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
            } else if (state is ApprovedArrivalTester) {
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
            }
          },
          builder: (ctx, state) {
            return RefreshIndicator(
              onRefresh: () async {
                ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
                sl<TesterCourierBloc>()..add(LoadTestersAndCouriers());
              },
              child: Scaffold(
                backgroundColor: kPageBackground,
                appBar: AppBar(
                  backgroundColor: kColorsOrangeLight,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                  title: Text(
                    '${widget.orderId}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  elevation: 0,
                ),
                body: state is LoadedSingleOrder
                    ? Align(
                        alignment: Alignment.center,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 700),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 100, left: 10, top: 10, right: 10),
                                child: CustomScrollView(
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: ListView(
                                        primary: false,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(10),
                                        physics: NeverScrollableScrollPhysics(),
                                        children: [
                                          //sender
                                          //courier
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue,
                                              radius: 18,
                                              child: Text(
                                                'S',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              '${state.order.sender_name ?? ""}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: Text(
                                              'Referring Health Facility',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 14),
                                            ),
                                          ),

                                          //courier
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue,
                                              radius: 18,
                                              child: Text(
                                                'C',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              '${state.order.courier_name ?? ""}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: Text(
                                              'Courier',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          //test center
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue,
                                              radius: 18,
                                              child: Text(
                                                'T',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              '${state.order.tester_name ?? ""}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: Text(
                                              'Testing Health Center',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //
                                    SliverToBoxAdapter(
                                      child: Divider(),
                                    ),

                                    SliverToBoxAdapter(
                                      child: Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          width: double.infinity,
                                          child: Text(
                                            'Order ID = ${state.order.orderId}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                            textAlign: TextAlign.left,
                                          )),
                                    ),

                                    SliverToBoxAdapter(
                                      child: Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          width: double.infinity,
                                          child: Text(
                                            'Current Status = ${state.order.status}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                            textAlign: TextAlign.left,
                                          )),
                                    ),

                                    SliverToBoxAdapter(
                                      child: state.order.patients!.length > 0
                                          ? ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  state.order.patients!.length,
                                              itemBuilder: (ctx, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (ctx) {
                                                          return Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            width:
                                                                double.infinity,
                                                            height: 300,
                                                            child: Dialog(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Container(
                                                                    // width: double
                                                                    //     .infinity,
                                                                    // height: 300,
                                                                    child: Wrap(
                                                                      children: state
                                                                          .order
                                                                          .patients![
                                                                              index]
                                                                          .specimens!
                                                                          .map((e) =>
                                                                              Container(
                                                                                width: 120,
                                                                                height: 80,
                                                                                margin: EdgeInsets.all(10),
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey.withOpacity(0.2),
                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                ),
                                                                                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                                                child: Column(
                                                                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      e.id ?? '',
                                                                                      style: TextStyle(
                                                                                        fontSize: 20,
                                                                                      ),
                                                                                    ),
                                                                                    Text(e.type ?? ''),
                                                                                  ],
                                                                                ),
                                                                              ))
                                                                          .toList(),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            ctx);
                                                                      },
                                                                      child: Text(
                                                                          'OK')),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: buildPatients(
                                                    context,
                                                    state
                                                        .order.patients![index],
                                                    widget.orderId,
                                                    index,
                                                    false,
                                                  ),
                                                );
                                              })
                                          : Center(
                                              child: Text('No patient added!'),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              state.order.status ==
                                          'Waiting for Confirmation' &&
                                      !(state.order.notified_referrer ?? false)
                                  ? Positioned(
                                      bottom: 0,
                                      left: 10,
                                      right: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        color: kPageBackground,
                                        child: InkWell(
                                          onTap: () async {
                                            try {
                                              await showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (ctx) {
                                                    return StatefulBuilder(
                                                        builder: (ctx, ss) {
                                                      return SingleChildScrollView(
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                            bottom: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom +
                                                                20,
                                                            top: 30,
                                                            left: 20,
                                                            right: 20,
                                                          ),
                                                          // padding: EdgeInsets.only(

                                                          //     bottom: 20),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                30,
                                                              ),
                                                              topRight: Radius
                                                                  .circular(
                                                                30,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                child: Text(
                                                                  'Accept Order',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        32,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    DatePicker
                                                                        .showDatePicker(
                                                                      context,
                                                                      minTime:
                                                                          DateTime
                                                                              .now(),
                                                                      onConfirm:
                                                                          (t) {
                                                                        int day =
                                                                            t.day;
                                                                        int month =
                                                                            t.month;
                                                                        int year =
                                                                            t.year;
                                                                        ss(() {});
                                                                        setState(
                                                                            () {
                                                                          date =
                                                                              '$day-$month-$year';
                                                                        });
                                                                      },
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: 54,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        padding:
                                                                            EdgeInsets.only(left: 20),
                                                                        child:
                                                                            Text(
                                                                          date ??
                                                                              'Please Select Date',
                                                                          style: TextStyle(
                                                                              color: Colors.black87.withOpacity(0.8),
                                                                              fontSize: 15),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    DatePicker
                                                                        .showTimePicker(
                                                                      context,
                                                                      currentTime:
                                                                          DateTime
                                                                              .now(),
                                                                      onConfirm:
                                                                          (t) {
                                                                        int hour =
                                                                            t.hour;
                                                                        int minutes =
                                                                            t.minute;
                                                                        ss(() {});
                                                                        setState(
                                                                            () {
                                                                          time =
                                                                              '$hour:$minutes';
                                                                        });
                                                                      },
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: 54,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        padding:
                                                                            EdgeInsets.only(left: 20),
                                                                        child:
                                                                            Text(
                                                                          time ??
                                                                              'Please Select Time',
                                                                          style: TextStyle(
                                                                              color: Colors.black87.withOpacity(0.8),
                                                                              fontSize: 15),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  if (date !=
                                                                          null &&
                                                                      time !=
                                                                          null) {
                                                                    Navigator.pop(
                                                                        ctx,
                                                                        true);
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color:
                                                                        kColorsOrangeDark,
                                                                  ),
                                                                  height: 62,
                                                                  // margin: EdgeInsets.all(20),
                                                                  child: Center(
                                                                    child: Text(
                                                                      'Accept Order',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  });

                                              ordersBloc.add(AcceptOrderCourier(
                                                  state.order,
                                                  time ?? '',
                                                  date ?? ''));
                                            } catch (e) {
                                              print(e);
                                            }
                                          },
                                          borderRadius:
                                              BorderRadius.circular(37),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: kColorsOrangeDark,
                                            ),
                                            height: 62,
                                            // margin: EdgeInsets.all(20),
                                            child: Center(
                                              child: Text(
                                                'Accept Order',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              state.order.status == 'Picked Up' &&
                                      !state.order.notified_arrival
                                  ? Positioned(
                                      bottom: 0,
                                      left: 10,
                                      right: 10,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            color: kPageBackground,
                                            child: InkWell(
                                              onTap: () async {
                                                try {
                                                  // print('Notifying Arrival');

                                                  bool success = await OrderBloc
                                                      .approveArrivalFromCourier(
                                                          state.order);
                                                  if (success) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Notified Arrivel to Test Center!')));
                                                    await Future.delayed(
                                                        Duration(seconds: 1));

                                                    ordersBloc.add(
                                                        LoadSingleOrder(
                                                            orderId: widget
                                                                .orderId));

                                                    setState(() {
                                                      notifiyingArrival = false;
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Error Notifiying Test Center!')));

                                                    setState(() {
                                                      notifiyingArrival = false;
                                                    });
                                                  }
                                                } catch (e) {
                                                  print(e);
                                                }
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(37),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: kColorsOrangeDark,
                                                ),
                                                height: 62,
                                                // margin: EdgeInsets.all(20),
                                                child: Center(
                                                  child: Text(
                                                    'Notify Arrival',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              state.order.status == 'Confirmed'
                                  ? ValueListenableBuilder(
                                      valueListenable:
                                          Hive.box('referrer_notified')
                                              .listenable(),
                                      builder:
                                          (BuildContext context, Box box, _) {
                                        // debugPrint('${box.values.contains(state.order.orderId)}');
                                        return !box.values
                                                .contains(state.order.orderId)
                                            ? Positioned(
                                                bottom: 0,
                                                left: 10,
                                                right: 10,
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  color: kPageBackground,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      try {
                                                        // print('Notifying Arrival');

                                                        bool success =
                                                            await OrderBloc
                                                                .approveArrivalFromCourierToReferrer(
                                                                    state
                                                                        .order);
                                                        if (success) {
                                                          Box notified_box =
                                                              Hive.box(
                                                                  'referrer_notified');
                                                          // debugPrint('Before ${notified_box.values.length}');

                                                          await notified_box
                                                              .add(state.order
                                                                  .orderId);

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      'Notified Arrivel to Referring facility!')));

                                                          ordersBloc.add(
                                                              LoadSingleOrder(
                                                                  orderId: widget
                                                                      .orderId));

                                                          setState(() {
                                                            notifiyingArrival =
                                                                false;
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      'Error Notifiying Referring facility!')));

                                                          setState(() {
                                                            notifiyingArrival =
                                                                false;
                                                          });
                                                        }
                                                      } catch (e) {
                                                        print(e);
                                                      }
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            37),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color:
                                                            kColorsOrangeDark,
                                                      ),
                                                      height: 62,
                                                      // margin: EdgeInsets.all(20),
                                                      child: Center(
                                                        child: Text(
                                                          'Notify Arrival At Health Facility',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox();
                                      })
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            );
          });
    });
  }

  Container buildPatients(
      BuildContext context, Patient patient, String orderId, int index,
      [bool isFromCourier = false]) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patient.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTextColorLight.withOpacity(0.8),
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  '${patient.specimens?.length} Specimens',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                    color: Colors.green,
                  ),
                  child: Text(
                    patient.status ?? 'Draft',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  color: kColorsOrangeDark,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
