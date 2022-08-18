import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_state.dart' as smsState;
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/pages/homepage/sender_homepage.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/edit_patient_info.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/patient_info.dart';
import 'package:kncv_flutter/presentation/pages/tester_courier_selector/tester_courier_selector.dart';
import 'package:kncv_flutter/service_locator.dart';

import '../notificatins.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  static const String orderDetailPageRouteName = 'order detail page route name';

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  // TextEditingController _receiverController = TextEditingController();

  OrderBloc ordersBloc = sl<OrderBloc>();
  @override
  void initState() {
    ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SMSBloc, smsState.SMSState>(listener: (ctx, state) {
      if (state is smsState.UpdatedDatabase) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Order has been Updated!')));
        ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
      }
    }, builder: (context, snapshot) {
      return BlocConsumer<OrderBloc, OrderState>(
          bloc: ordersBloc,
          listener: (ctx, state) async {
            if (state is DeletedOrder) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Order deleted!')));
              await Future.delayed(Duration(seconds: 1));

              Navigator.pushReplacementNamed(
                  context, SenderHomePage.senderHomePageRouteName);
            } else if (state is ErrorState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
              // Navigator.pop(context, true);
            } else if (state is DeletedPatient) {
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
              // ScaffoldMessenger.of(context)
              //     .showSnackBar(SnackBar(content: Text()));
              // Navigator.pop(context, true);
            } else if (state is PlacedOrder) {
              await Future.delayed(Duration(seconds: 1));
              // ScaffoldMessenger.of(context)
              //     .showSnackBar(SnackBar(content: Text('Order Placed!')));
              ordersBloc.add(LoadOrders());
              Navigator.pop(context, true);

              addNotification(
                orderId: widget.orderId,
                senderContent:
                    'You have added new order for courier ${state.order.courier_name ?? ""} and testing center ${state.order.tester_name}.',
                testerContent:
                    'New order is ready from ${state.order.sender_name} & will be transported by ${state.order.courier_name}.',
                courierContent:
                    'New order is created for you to accept it from ${state.order.sender_name} to ${state.order.tester_name}.',
                content: 'New order from ${state.order.sender} is ready.!',
                courierAction: NotificationAction.NavigateToOrderDetalCourier,
                testerAction: NotificationAction.NavigateToOrderDetalTester,
                senderAction: NotificationAction.NavigateToOrderDetalSender,
                payload: {'orderId': widget.orderId},
              );
            } else if (state is ApprovedArrivalCourier) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Courier collected Order!')));
              addNotification(
                orderId: widget.orderId,
                courierContent:
                    'Order collected from ${state.order.sender_name} to be transported to ${state.order.tester_name}.',
                senderContent:
                    'You have approved departure of specimen from you to ${state.order.tester_name}.',
                testerContent:
                    'Specimen collected from ${state.order.sender_name} by courier ${state.order.courier_name}.',
                content: 'New order from ${state.order.sender} is ready.!',
                courierAction: NotificationAction.NavigateToOrderDetalCourier,
                testerAction: NotificationAction.NavigateToOrderDetalTester,
                senderAction: NotificationAction.NavigateToOrderDetalSender,
                payload: {'orderId': widget.orderId},
              );
              await Future.delayed(Duration(seconds: 1));
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
            } else if (state is EditedOrder) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Changed order info!')));
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
                // floatingActionButton: FloatingActionButton(
                //   child: Icon(Icons.add),
                //   backgroundColor: kColorsOrangeLight,
                //   onPressed: () {},
                // ),
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
                  actions: [
                    state is DeletingOrder
                        ? Container()
                        : state is LoadedSingleOrder
                            ? IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  if (state.order.status !=
                                          'Waiting for Confirmation' &&
                                      state.order.status != 'Draft') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Cant delete this order! It is already accepted!')));
                                    return;
                                  }
                                  showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: Text('Delete Order'),
                                          content: Text(
                                              'Are you sure you want to delete this order?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  ordersBloc.add(DeleteOrders(
                                                    order: state.order,
                                                  ));
                                                  Navigator.pop(ctx);
                                                },
                                                child: Text('Yes')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                },
                                                child: Text('No')),
                                          ],
                                        );
                                      });
                                  // AlertDialog(),
                                },
                              )
                            : Container(),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.edit_outlined,
                    //     color: Colors.black,
                    //   ),
                    //   onPressed: () {},
                    // ),
                  ],
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
                                    state.order.status == 'Draft'
                                        ? SliverToBoxAdapter(
                                            child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  tooltip: 'Edit',
                                                  // backgroundColor: kColorsOrangeLight,
                                                  // elevation: 0,
                                                  onPressed: () async {
                                                    // print('here');
                                                    var create =
                                                        await showModalBottomSheet(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isScrollControlled:
                                                                true,
                                                            context: context,
                                                            builder: (ctx) {
                                                              return Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets
                                                                          .bottom +
                                                                      20,
                                                                  top: 20,
                                                                  left: 20,
                                                                  right: 20,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
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
                                                                      child:
                                                                          Text(
                                                                        'Create An Order',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              32,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          30,
                                                                    ),
                                                                    SelectorPage(
                                                                      buttonText:
                                                                          'Edit Order',
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            });

                                                    // print('create');
                                                    if (create == true) {
                                                      Tester? tester = BlocProvider
                                                              .of<TesterCourierBloc>(
                                                                  context)
                                                          .tester;
                                                      Courier? courier =
                                                          BlocProvider.of<
                                                                      TesterCourierBloc>(
                                                                  context)
                                                              .courier;
                                                      // String? date = BlocProvider.of<TesterCourierBloc>(context).date;
                                                      // print(tester?.name);
                                                      // print(courier?.name);
                                                      // print(date);
                                                      ordersBloc.add(
                                                        EditOrder(
                                                          courier_id:
                                                              courier!.id,
                                                          tester_id: tester!.id,
                                                          courier_name:
                                                              courier.name,
                                                          tester_name:
                                                              tester.name,
                                                          orderId:
                                                              widget.orderId,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.red,
                                                  )),
                                            ],
                                          ))
                                        : SliverToBoxAdapter(),
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
                                              'Referring Health Facilty',
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
                                              'Testing Health Facility',
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

                                    state.order.status == 'Draft'
                                        ? SliverToBoxAdapter(
                                            child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              FloatingActionButton(
                                                  tooltip: 'Add Patient',
                                                  backgroundColor:
                                                      kColorsOrangeLight,
                                                  elevation: 0,
                                                  onPressed: () async {
                                                    if (state.order.patients!
                                                            .length >=
                                                        4) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Maximum sample quantity is reached!',
                                                          ),
                                                        ),
                                                      );

                                                      return;
                                                    }
                                                    var added = await Navigator
                                                        .pushNamed(
                                                            context,
                                                            PatientInfoPage
                                                                .patientInfoPageRouteName,
                                                            arguments:
                                                                widget.orderId);
                                                    if (added == true) {
                                                      ordersBloc.add(
                                                          LoadSingleOrder(
                                                              orderId: widget
                                                                  .orderId));
                                                    }
                                                  },
                                                  child: Icon(Icons.add)),
                                            ],
                                          ))
                                        : SliverToBoxAdapter(),

                                    SliverToBoxAdapter(
                                      child: state.order.patients!.length > 0
                                          ?
                                          // ListView(
                                          //     shrinkWrap: true,
                                          //     physics: NeverScrollableScrollPhysics(),
                                          //     children: state.order.patients!
                                          //         .map((e) => buildPatients(
                                          //             e, widget.orderId))
                                          //         .toList(),
                                          //   )
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  state.order.patients!.length,
                                              itemBuilder: (ctx, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context,
                                                        EditPatientInfoPage
                                                            .editPatientInfoRouteName,
                                                        arguments: {
                                                          'patient': state.order
                                                              .patients![index],
                                                          'orderId':
                                                              widget.orderId,
                                                          'index': index,
                                                          'canEdit': state.order
                                                                  .status ==
                                                              'Draft',
                                                        });
                                                  },
                                                  child: buildPatients(
                                                    context,
                                                    state
                                                        .order.patients![index],
                                                    widget.orderId,
                                                    index,
                                                    deletable: state
                                                                .order.status ==
                                                            'Waiting for Confirmation' ||
                                                        state.order.status ==
                                                            'Draft',
                                                    order: state.order,
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
                              state.order.status == 'Draft'
                                  ? Positioned(
                                      bottom: 0,
                                      left: 10,
                                      right: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        color: kPageBackground,
                                        child: InkWell(
                                          onTap: () async {
                                            if (state.order.patients!.length ==
                                                0) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Please add patients first!')));
                                              return;
                                            }

                                            // debugPrint('${Order.fromJsonSMS(state.order.toJsonSMS()).orderId}');

                                            ordersBloc.add(
                                                PlaceOrder(order: state.order));
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
                                                'Place Order',
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
                                            // bool confirm =
                                            //     await showModalBottomSheet(
                                            //         backgroundColor:
                                            //             Colors.transparent,
                                            //         isScrollControlled: true,
                                            //         context: context,
                                            //         builder: (ctx) {
                                            //           return StatefulBuilder(
                                            //               builder: (ctx, ss) {
                                            //             return SingleChildScrollView(
                                            //               child: Container(
                                            //                 padding:
                                            //                     EdgeInsets.only(
                                            //                   bottom: MediaQuery.of(
                                            //                               context)
                                            //                           .viewInsets
                                            //                           .bottom +
                                            //                       20,
                                            //                   top: 30,
                                            //                   left: 20,
                                            //                   right: 20,
                                            //                 ),
                                            //                 // padding: EdgeInsets.only(

                                            //                 //     bottom: 20),
                                            //                 decoration:
                                            //                     BoxDecoration(
                                            //                   color: Colors.white,
                                            //                   borderRadius:
                                            //                       BorderRadius
                                            //                           .only(
                                            //                     topLeft: Radius
                                            //                         .circular(
                                            //                       30,
                                            //                     ),
                                            //                     topRight: Radius
                                            //                         .circular(
                                            //                       30,
                                            //                     ),
                                            //                   ),
                                            //                 ),
                                            //                 child: Column(
                                            //                   mainAxisSize:
                                            //                       MainAxisSize
                                            //                           .min,
                                            //                   crossAxisAlignment:
                                            //                       CrossAxisAlignment
                                            //                           .start,
                                            //                   children: [
                                            //                     Container(
                                            //                       width: double
                                            //                           .infinity,
                                            //                       child: Text(
                                            //                         'Confirm',
                                            //                         textAlign:
                                            //                             TextAlign
                                            //                                 .center,
                                            //                         style:
                                            //                             TextStyle(
                                            //                           fontSize:
                                            //                               32,
                                            //                           fontWeight:
                                            //                               FontWeight
                                            //                                   .bold,
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                     SizedBox(
                                            //                       height: 30,
                                            //                     ),
                                            //                     _buildInputField(
                                            //                         label:
                                            //                             'Receiver',
                                            //                         hint:
                                            //                             'Enter Receiver',
                                            //                         controller:
                                            //                             _receiverController),
                                            //                     SizedBox(
                                            //                       height: 30,
                                            //                     ),
                                            //                     GestureDetector(
                                            //                       onTap: () {
                                            //                         print(
                                            //                             _receiverController
                                            //                                 .value
                                            //                                 .text);

                                            //                         if (_receiverController
                                            //                                 .value
                                            //                                 .text !=
                                            //                             '') {
                                            //                           Navigator.pop(
                                            //                               ctx,
                                            //                               true);
                                            //                         }
                                            //                       },
                                            //                       child:
                                            //                           Container(
                                            //                         decoration:
                                            //                             BoxDecoration(
                                            //                           borderRadius:
                                            //                               BorderRadius.circular(
                                            //                                   10),
                                            //                           color:
                                            //                               kColorsOrangeDark,
                                            //                         ),
                                            //                         height: 62,
                                            //                         // margin: EdgeInsets.all(20),
                                            //                         child: Center(
                                            //                           child: Text(
                                            //                             'Confirm',
                                            //                             style: TextStyle(
                                            //                                 fontWeight: FontWeight
                                            //                                     .bold,
                                            //                                 fontSize:
                                            //                                     20,
                                            //                                 color:
                                            //                                     Colors.white),
                                            //                           ),
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                   ],
                                            //                 ),
                                            //               ),
                                            //             );
                                            //           });
                                            //         });

                                            showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return AlertDialog(
                                                    title: Text('Confirm'),
                                                    content: Text(
                                                        'Are you sure you want to confirm order departure?'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            ordersBloc.add(
                                                                ApproveArrivalCourier(
                                                                    state.order,
                                                                    state.order
                                                                            .courier_name ??
                                                                        ''));

                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('Yes')),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('No'))
                                                    ],
                                                  );
                                                });
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
                                                'Approve Courier Arrival',
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
      {bool deletable = true, required Order order}) {
    String message = '';
    int counter = 0;
    patient.specimens?.forEach((specimen) {
      if (specimen.testResult != null) {
        counter++;
      }
    });
    message = 'Tested: $counter/${patient.specimens?.length ?? ''}';

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
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!deletable) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Cannot delete this order anymore!')));
                        return;
                      }

                      showDialog(
                          context: context,
                          builder: (context) {
                            //check status

                            return AlertDialog(
                              title: Text('Delete Patient?'),
                              content: Text('Delete patient ${patient.name}'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      ordersBloc.add(DeletePatient(
                                          orderId: orderId, index: index));
                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No')),
                              ],
                            );
                          });

                      // print(orderId);
                      // print('${patient.toJson()}');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kColorsOrangeLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      // print(index);
                      // print(patient);
                      // print(orderId);
                      // if (!deletable) {
                      //             ScaffoldMessenger.of(context).showSnackBar(
                      //                 SnackBar(
                      //                     content: Text(
                      //                         'Cant edit this order! It is already accepted!')));
                      //                         return;
                      //           }

                      Navigator.pushNamed(
                          context, EditPatientInfoPage.editPatientInfoRouteName,
                          arguments: {
                            'patient': order.patients![index],
                            'orderId': widget.orderId,
                            'index': index,
                            'canEdit': order.status == 'Draft',
                          });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kColorsOrangeLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
