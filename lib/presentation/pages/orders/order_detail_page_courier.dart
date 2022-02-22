import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/core/message_codes.dart';
import 'package:kncv_flutter/core/sms_handler.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/notificatins.dart';
import 'package:kncv_flutter/service_locator.dart';

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
    return BlocConsumer<OrderBloc, OrderState>(
        bloc: ordersBloc,
        listener: (ctx, state) async {
          if (state is ErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
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
            );
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          }
          //  else if (state is CourierApprovedArrivalTester) {
          //   addNotification(
          //     orderId: widget.orderId,
          //     content: 'Courier reached at destination to pick order!',
          //     courierContent:
          //         'You have confirmed arrival to ${state.order.tester_name} from ${state.order.sender_name}.',
          //     senderContent:
          //         'Your specimen has arrived to ${state.order.tester_name}.',
          //     testerContent:
          //         'Courier ${state.order.courier_name} has just arrived from ${state.order.sender_name}.',
          //   );
          //   ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          // }
          else if (state is ApprovedArrivalTester) {
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          }
        },
        builder: (ctx, state) {
          return RefreshIndicator(
            onRefresh: () async {
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
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
                  ? Stack(
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
                                        '${state.order.sender_name}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        'Referring Health Facilty',
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 14),
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
                                        '${state.order.courier_name}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        'Courier',
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 14),
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
                                        '${state.order.tester_name}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        'Testing Health Center',
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 14),
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
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    width: double.infinity,
                                    child: Text(
                                      'Order ID = ${state.order.orderId}',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.left,
                                    )),
                              ),

                              SliverToBoxAdapter(
                                child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    width: double.infinity,
                                    child: Text(
                                      'Current Status = ${state.order.status}',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.left,
                                    )),
                              ),

                              SliverToBoxAdapter(
                                child: state.order.patients!.length > 0
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: state.order.patients!.length,
                                        itemBuilder: (ctx, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return Container(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      width: double.infinity,
                                                      height: 300,
                                                      child: Dialog(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
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
                                                                          width:
                                                                              120,
                                                                          height:
                                                                              80,
                                                                          margin:
                                                                              EdgeInsets.all(10),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.2),
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                          ),
                                                                          padding: EdgeInsets.symmetric(
                                                                              vertical: 20,
                                                                              horizontal: 10),
                                                                          child:
                                                                              Column(
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
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      ctx);
                                                                },
                                                                child:
                                                                    Text('OK')),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: buildPatients(
                                              context,
                                              state.order.patients![index],
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
                        state.order.status == 'Waiting for Confirmation'
                            ? Positioned(
                                bottom: 0,
                                left: 10,
                                right: 10,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color: kPageBackground,
                                  child: InkWell(
                                    onTap: () async {
                                      bool success = await showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (ctx) {
                                            return StatefulBuilder(
                                                builder: (ctx, ss) {
                                              return SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .viewInsets
                                                                .bottom +
                                                            20,
                                                    top: 30,
                                                    left: 20,
                                                    right: 20,
                                                  ),
                                                  // padding: EdgeInsets.only(

                                                  //     bottom: 20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        30,
                                                      ),
                                                      topRight: Radius.circular(
                                                        30,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        child: Text(
                                                          'Accept Order',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 32,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                              minTime: DateTime
                                                                  .now(),
                                                              onConfirm: (t) {
                                                                int day = t.day;
                                                                int month =
                                                                    t.month;
                                                                int year =
                                                                    t.year;
                                                                ss(() {});
                                                                setState(() {
                                                                  date =
                                                                      '$day-$month-$year';
                                                                });
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 54,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Center(
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20),
                                                                child: Text(
                                                                  date ??
                                                                      'Please Select Date',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black87
                                                                          .withOpacity(
                                                                              0.8),
                                                                      fontSize:
                                                                          15),
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
                                                              onConfirm: (t) {
                                                                int hour =
                                                                    t.hour;
                                                                int minutes =
                                                                    t.minute;
                                                                ss(() {});
                                                                setState(() {
                                                                  time =
                                                                      '$hour:$minutes';
                                                                });
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 54,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Center(
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20),
                                                                child: Text(
                                                                  time ??
                                                                      'Please Select Time',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black87
                                                                          .withOpacity(
                                                                              0.8),
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                              ),
                                                            ),
                                                          )),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (date != null &&
                                                              time != null) {
                                                            Navigator.pop(
                                                                ctx, true);
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white),
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

                                      if (success == true) {
                                        if (!(await isConnectedToTheInternet())) {
                                          await sendSMS(context : context,
                                              to: '0936951272',
                                              payload: {
                                                'oid': state.order.orderId,
                                                'date': date ?? '',
                                                'time': time ?? '',
                                              },
                                              action: COURIER_ACCEPT_ORDER);
                                          return;
                                        }
                                        ordersBloc.add(AcceptOrderCourier(
                                            state.order,
                                            time ?? '',
                                            date ?? ''));
                                      }
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
                                          print('Notifying Arrival');
                                          setState(() {
                                            notifiyingArrival = true;
                                          });
                                          if (!(await isConnectedToTheInternet())) {
                                            await sendSMS(
                                              context: context,
                                              to: '0936951272',
                                              payload: {
                                                'oid': state.order.orderId,
                                              },
                                              action:
                                                  COURIER_NOTIFY_ARRIVAL_TESTER,
                                            );
                                            setState(() {
                                              notifiyingArrival = true;
                                            });
                                            return;
                                          }
                                          bool success = await OrderBloc
                                              .approveArrivalFromCourier(
                                                  state.order);
                                          if (success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Notified Arrivel to Test Center!')));
                                            await Future.delayed(
                                                Duration(seconds: 1));

                                            ordersBloc.add(LoadSingleOrder(
                                                orderId: widget.orderId));

                                            setState(() {
                                              notifiyingArrival = false;
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Error Notifiying Test Center!')));

                                            setState(() {
                                              notifiyingArrival = false;
                                            });
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(37),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: kColorsOrangeDark,
                                          ),
                                          height: 62,
                                          // margin: EdgeInsets.all(20),
                                          child: Center(
                                            child: notifiyingArrival
                                                ? CircularProgressIndicator(
                                                    color: Colors.white,
                                                  )
                                                : Text(
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
                            ? Positioned(
                                bottom: 0,
                                left: 10,
                                right: 10,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color: kPageBackground,
                                  child: InkWell(
                                    onTap: () async {
                                      setState(() {
                                        notifyingArrival = true;
                                      });
                                      if (!(await isConnectedToTheInternet())) {
                                        await sendSMS(
                                          context : context,
                                          to: '0936951272',
                                          payload: {
                                            'oid': state.order.orderId,
                                          },
                                          action: COURIER_NOTIFY_ARRIVAL_SENDER,
                                        );
                                        setState(() {
                                          notifiyingArrival = true;
                                        });
                                        return;
                                      }
                                      bool success = await addNotification(
                                        orderId: widget.orderId,
                                        courierContent:
                                            'You have notified arrival at ${state.order.sender_name} to transport specimen to ${state.order.tester_name}.',
                                        senderContent:
                                            'Courier ${state.order.courier_name} is at your place to collect specimen to ${state.order.tester_name}.',
                                        testerContent:
                                            'Courier is at ${state.order.sender_name} to bring specimen to you.',
                                        content:
                                            'Courier Reached at health facility to collect order!',
                                      );

                                      if (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Sent notification to health facility!')));
                                      }
                                      setState(() {
                                        notifyingArrival = false;
                                      });
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
                                        child: notifyingArrival
                                            ? CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Text(
                                                'Notify Arrival At Health Facility',
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
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          );
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
