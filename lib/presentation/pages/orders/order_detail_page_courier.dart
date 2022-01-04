import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kncv_flutter/core/colors.dart';
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
  String? inColdChain;
  String? sputumCondition;
  String? stoolCondition;
  String? time;

  TextEditingController _receiverController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  OrderBloc ordersBloc = sl<OrderBloc>();
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
                  'Courier coming to fetch order to ${state.order.tester_name}. Will reach at your place at ${state.time}.',
              testerContent:
                  'Courier going to fetch order from ${state.order.sender_name}.',
              content: 'One order got accepted by courier!',
            );
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          } else if (state is CourierApprovedArrivalTester) {
            addNotification(
              orderId: widget.orderId,
              content: 'Courier reached at destination to pick order!',
              courierContent:
                  'You have confirmed arrival to ${state.order.tester_name} from ${state.order.sender_name}.',
              senderContent:
                  'Your specimen has arrived to ${state.order.tester_name}.',
              testerContent:
                  'Courier ${state.order.courier_name} has just arrived from ${state.order.sender_name}.',
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
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  '${widget.orderId.substring(0, 5)}',
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
                                        'Sender',
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
                                        'Test Center',
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
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    width: double.infinity,
                                    child: Text(
                                      'Current Status = ${state.order.status}',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
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
                                      // showDialog(
                                      //     context: context,
                                      //     builder: (ctx) {
                                      //       return AlertDialog(
                                      //         title: Text('Accept Order?'),
                                      //         content: Text(
                                      //             'Are you sure you want to accept this order?'),
                                      //         actions: [
                                      //           TextButton(
                                      //               onPressed: () {
                                      //                 Navigator.pop(ctx);
                                      //                 ordersBloc.add(
                                      //                     AcceptOrderCourier(
                                      //                         state.order));
                                      //               },
                                      //               child: Text('Yes')),
                                      //           TextButton(
                                      //               onPressed: () {
                                      //                 Navigator.pop(ctx);
                                      //               },
                                      //               child: Text('Cancel'))
                                      //         ],
                                      //       );
                                      //     });

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
                                                          Navigator.pop(
                                                              ctx, true);
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
                                        ordersBloc.add(AcceptOrderCourier(
                                            state.order, time ?? ''));
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
                        state.order.status == 'Picked Up'
                            ? Positioned(
                                bottom: 0,
                                left: 10,
                                right: 10,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color: kPageBackground,
                                  child: InkWell(
                                    onTap: () async {
                                      bool confirm = await showModalBottomSheet(
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
                                                          'Confirm Arrival',
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
                                                      _buildInputField(
                                                          label: 'Receiver',
                                                          hint:
                                                              'Enter Receiver',
                                                          controller:
                                                              _receiverController),
                                                      _buildInputField(
                                                          label: 'Phone',
                                                          hint:
                                                              'Enter Receiver\'s Phone',
                                                          controller:
                                                              _phoneController),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          print(
                                                              _receiverController
                                                                  .value.text);

                                                          if (_receiverController
                                                                  .value.text !=
                                                              '') {
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
                                                              'Confirm',
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

                                      if (confirm == true) {
                                        ordersBloc.add(
                                            CourierApproveArrivalToTestCenter(
                                                state.order,
                                                _receiverController.value.text,
                                                _phoneController.value.text));
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
                                          'Approve Arrival',
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
                                      bool success = await addNotification(
                                        orderId: widget.orderId,
                                        courierContent:
                                            'You have notified arrival at ${state.order.sender_name} to transport specimen to ${state.order.tester_name}.',
                                        senderContent:
                                            'Courier ${state.order.courier_name} is at your place to collect specimen to ${state.order.tester_name}.',
                                        testerContent:
                                            'Courier is at ${state.order.sender_name} to bring specimen to you.',
                                        content:
                                            'Courier Reached at health facility to fetch order!',
                                      );

                                      if (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Sent notification to health facility!')));
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
                        // state.order.status == 'Arrived'
                        //     ? Positioned(
                        //         bottom: 0,
                        //         left: 10,
                        //         right: 10,
                        //         child: Container(
                        //           padding: EdgeInsets.all(10),
                        //           color: kPageBackground,
                        //           child: InkWell(
                        //             onTap: () async {
                        //               var create = await showModalBottomSheet(
                        //                   backgroundColor: Colors.transparent,
                        //                   isScrollControlled: true,
                        //                   context: context,
                        //                   builder: (ctx) {
                        //                     return ArrivalConfirmation(ctx);
                        //                   });

                        //               if (create == true) {
                        //                 ordersBloc.add(
                        //                   ApproveArrivalTester(
                        //                     orderId: state.order.orderId!,
                        //                     sputumCondition: sputumCondition,
                        //                     stoolCondition: stoolCondition,
                        //                     coldChainStatus: inColdChain,
                        //                   ),
                        //                 );
                        //               }
                        //             },
                        //             borderRadius: BorderRadius.circular(37),
                        //             child: Container(
                        //               decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(10),
                        //                 color: kColorsOrangeDark,
                        //               ),
                        //               height: 62,
                        //               // margin: EdgeInsets.all(20),
                        //               child: Center(
                        //                 child: Text(
                        //                   'Confirm Arrival',
                        //                   style: TextStyle(
                        //                       fontWeight: FontWeight.bold,
                        //                       fontSize: 20,
                        //                       color: Colors.white),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        //     : Container(),
                        // state.order.status == 'Accepted'
                        //     ? Positioned(
                        //         bottom: 0,
                        //         left: 10,
                        //         right: 10,
                        //         child: Container(
                        //           padding: EdgeInsets.all(10),
                        //           color: kPageBackground,
                        //           child: InkWell(
                        //             onTap: () async {},
                        //             borderRadius: BorderRadius.circular(37),
                        //             child: Container(
                        //               decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(10),
                        //                 color: kColorsOrangeDark,
                        //               ),
                        //               height: 62,
                        //               // margin: EdgeInsets.all(20),
                        //               child: Center(
                        //                 child: Text(
                        //                   'Add Test Result',
                        //                   style: TextStyle(
                        //                       fontWeight: FontWeight.bold,
                        //                       fontSize: 20,
                        //                       color: Colors.white),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        //     : Container(),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          );
        });
  }

  Widget _buildInputField(
      {required String label,
      required String hint,
      required TextEditingController controller}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 4, top: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 3)),
          ),
        ),
      ],
    );
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
