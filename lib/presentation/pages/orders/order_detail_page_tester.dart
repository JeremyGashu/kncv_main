import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/orders/result_page.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/edit_patient_info.dart';
import 'package:kncv_flutter/service_locator.dart';

class OrderDetailTester extends StatefulWidget {
  final String orderId;
  static const String orderDetailTesterPageRouteName =
      'order detail tester page route name';

  const OrderDetailTester({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailTester> createState() => _OrderDetailTesterState();
}

class _OrderDetailTesterState extends State<OrderDetailTester> {
  String? inColdChain;
  String? sputumCondition;
  String? stoolCondition;

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
          if (state is LoadedSingleOrder) {
            print(state.order.status);
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            await Future.delayed(Duration(seconds: 1));
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          } else if (state is AcceptedOrderCourier) {
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          } else if (state is ApprovedArrivalCourier) {
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
                                            color: kColorsOrangeLight,
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
                                              // showDialog(
                                              //     context: context,
                                              //     builder: (ctx) {
                                              //       return Container(
                                              //         padding:
                                              //             EdgeInsets.all(10),
                                              //         width: double.infinity,
                                              //         height: 300,
                                              //         child: Dialog(
                                              //           child: Column(
                                              //             mainAxisSize:
                                              //                 MainAxisSize.min,
                                              //             children: [
                                              //               Container(
                                              //                 // width: double
                                              //                 //     .infinity,
                                              //                 // height: 300,
                                              //                 child: Wrap(
                                              //                   children: state
                                              //                       .order
                                              //                       .patients![
                                              //                           index]
                                              //                       .specimens!
                                              //                       .map((e) =>
                                              //                           Container(
                                              //                             width:
                                              //                                 120,
                                              //                             height:
                                              //                                 80,
                                              //                             margin:
                                              //                                 EdgeInsets.all(10),
                                              //                             decoration:
                                              //                                 BoxDecoration(
                                              //                               color:
                                              //                                   Colors.grey.withOpacity(0.2),
                                              //                               borderRadius:
                                              //                                   BorderRadius.circular(15),
                                              //                             ),
                                              //                             padding: EdgeInsets.symmetric(
                                              //                                 vertical: 20,
                                              //                                 horizontal: 10),
                                              //                             child:
                                              //                                 Column(
                                              //                               // crossAxisAlignment: CrossAxisAlignment.start,
                                              //                               // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              //                               children: [
                                              //                                 Text(
                                              //                                   e.id ?? '',
                                              //                                   style: TextStyle(
                                              //                                     fontSize: 20,
                                              //                                   ),
                                              //                                 ),
                                              //                                 Text(e.type ?? ''),
                                              //                               ],
                                              //                             ),
                                              //                           ))
                                              //                       .toList(),
                                              //                 ),
                                              //               ),
                                              //               SizedBox(
                                              //                 height: 10,
                                              //               ),
                                              //               TextButton(
                                              //                   onPressed: () {
                                              //                     Navigator.pop(
                                              //                         ctx);
                                              //                   },
                                              //                   child:
                                              //                       Text('OK')),
                                              //             ],
                                              //           ),
                                              //         ),
                                              //       );
                                              //     });

                                              if (state.order.patients![index]
                                                  .resultAvaiable) {
                                                Navigator.pushNamed(
                                                    context,
                                                    EditPatientInfoPage
                                                        .editPatientInfoRouteName,
                                                    arguments: {
                                                      'patient': state.order
                                                          .patients![index],
                                                      'orderId': widget.orderId,
                                                      'index': index
                                                    });
                                              } else {
                                                Navigator.pushNamed(
                                                    context,
                                                    AddTestResultPage
                                                        .addTestResultPageRouteName,
                                                    arguments: {
                                                      'orderId': widget.orderId,
                                                      'patient': state.order
                                                          .patients![index],
                                                      'index': index,
                                                    });
                                              }
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
                        // state.order.status == 'Waiting Confirmation'
                        //     ? Positioned(
                        //         bottom: 0,
                        //         left: 10,
                        //         right: 10,
                        //         child: Container(
                        //           padding: EdgeInsets.all(10),
                        //           color: kPageBackground,
                        //           child: InkWell(
                        //             onTap: () async {
                        //               showDialog(
                        //                   context: context,
                        //                   builder: (ctx) {
                        //                     return AlertDialog(
                        //                       title: Text('Accept Order?'),
                        //                       content: Text(
                        //                           'Are you sure you want to accept this order?'),
                        //                       actions: [
                        //                         TextButton(
                        //                             onPressed: () {
                        //                               Navigator.pop(ctx);
                        //                               ordersBloc.add(
                        //                                   AcceptOrderCourier(
                        //                                       state.order
                        //                                           .orderId!));
                        //                             },
                        //                             child: Text('Yes')),
                        //                         TextButton(
                        //                             onPressed: () {
                        //                               Navigator.pop(ctx);
                        //                             },
                        //                             child: Text('Cancel'))
                        //                       ],
                        //                     );
                        //                   });
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
                        //                   'Accept Order',
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
                        // state.order.status == 'On Delivery'
                        //     ? Positioned(
                        //         bottom: 0,
                        //         left: 10,
                        //         right: 10,
                        //         child: Container(
                        //           padding: EdgeInsets.all(10),
                        //           color: kPageBackground,
                        //           child: InkWell(
                        //             onTap: () async {
                        //               bool confirm = await showModalBottomSheet(
                        //                   backgroundColor: Colors.transparent,
                        //                   isScrollControlled: true,
                        //                   context: context,
                        //                   builder: (ctx) {
                        //                     return StatefulBuilder(
                        //                         builder: (ctx, ss) {
                        //                       return SingleChildScrollView(
                        //                         child: Container(
                        //                           padding: EdgeInsets.only(
                        //                             bottom:
                        //                                 MediaQuery.of(context)
                        //                                         .viewInsets
                        //                                         .bottom +
                        //                                     20,
                        //                             top: 30,
                        //                             left: 20,
                        //                             right: 20,
                        //                           ),
                        //                           // padding: EdgeInsets.only(

                        //                           //     bottom: 20),
                        //                           decoration: BoxDecoration(
                        //                             color: Colors.white,
                        //                             borderRadius:
                        //                                 BorderRadius.only(
                        //                               topLeft: Radius.circular(
                        //                                 30,
                        //                               ),
                        //                               topRight: Radius.circular(
                        //                                 30,
                        //                               ),
                        //                             ),
                        //                           ),
                        //                           child: Column(
                        //                             mainAxisSize:
                        //                                 MainAxisSize.min,
                        //                             crossAxisAlignment:
                        //                                 CrossAxisAlignment
                        //                                     .start,
                        //                             children: [
                        //                               Container(
                        //                                 width: double.infinity,
                        //                                 child: Text(
                        //                                   'Confirm Arrival',
                        //                                   textAlign:
                        //                                       TextAlign.center,
                        //                                   style: TextStyle(
                        //                                     fontSize: 32,
                        //                                     fontWeight:
                        //                                         FontWeight.bold,
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                               SizedBox(
                        //                                 height: 30,
                        //                               ),
                        //                               _buildInputField(
                        //                                   label: 'Receiver',
                        //                                   hint:
                        //                                       'Enter Receiver',
                        //                                   controller:
                        //                                       _receiverController),
                        //                               SizedBox(
                        //                                 height: 30,
                        //                               ),
                        //                               GestureDetector(
                        //                                 onTap: () {
                        //                                   print(
                        //                                       _receiverController
                        //                                           .value.text);

                        //                                   if (_receiverController
                        //                                           .value.text !=
                        //                                       '') {
                        //                                     Navigator.pop(
                        //                                         ctx, true);
                        //                                   }
                        //                                 },
                        //                                 child: Container(
                        //                                   decoration:
                        //                                       BoxDecoration(
                        //                                     borderRadius:
                        //                                         BorderRadius
                        //                                             .circular(
                        //                                                 10),
                        //                                     color:
                        //                                         kColorsOrangeDark,
                        //                                   ),
                        //                                   height: 62,
                        //                                   // margin: EdgeInsets.all(20),
                        //                                   child: Center(
                        //                                     child: Text(
                        //                                       'Confirm',
                        //                                       style: TextStyle(
                        //                                           fontWeight:
                        //                                               FontWeight
                        //                                                   .bold,
                        //                                           fontSize: 20,
                        //                                           color: Colors
                        //                                               .white),
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                             ],
                        //                           ),
                        //                         ),
                        //                       );
                        //                     });
                        //                   });

                        //               if (confirm == true) {
                        //                 ordersBloc.add(ApproveArrivalCourier(
                        //                     state.order.orderId!,
                        //                     _receiverController.value.text));
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
                        //                   'Approve Arrival',
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
                        state.order.status == 'Arrived'
                            ? Positioned(
                                bottom: 0,
                                left: 10,
                                right: 10,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color: kPageBackground,
                                  child: InkWell(
                                    onTap: () async {
                                      var create = await showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (ctx) {
                                            return ArrivalConfirmation(ctx);
                                          });

                                      if (create == true) {
                                        ordersBloc.add(
                                          ApproveArrivalTester(
                                            orderId: state.order.orderId!,
                                            sputumCondition: sputumCondition,
                                            stoolCondition: stoolCondition,
                                            coldChainStatus: inColdChain,
                                          ),
                                        );
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
                                          'Confirm Arrival',
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

  Widget ArrivalConfirmation(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
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
              'Confirm Arrival',
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

          //cold chain status

          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              'Cold Chain Status',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(7),
            ),
            child: StatefulBuilder(builder: (context, ss) {
              return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                value: inColdChain,
                hint: Text('Transported in cold Chain?'),
                items: <String>['Yes', 'No'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    inColdChain = val;
                  });

                  ss(() {});
                },
              ));
            }),
          ),

          //sputum cndition
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              'Sputum Condition',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(7),
            ),
            child: StatefulBuilder(builder: (context, ss) {
              return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                value: sputumCondition,
                hint: Text('Sputum Condition?'),
                items: <String>['Yes', 'No'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    sputumCondition = val;
                  });
                  ss(() {});
                },
              ));
            }),
          ),

          //sputum cndition
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              'Stool Condition',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(7),
            ),
            child: StatefulBuilder(builder: (context, ss) {
              return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                value: stoolCondition,
                hint: Text('Stool Condition?'),
                items: <String>['Yes', 'No'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    stoolCondition = val;
                  });
                  ss(() {});
                },
              ));
            }),
          ),

          SizedBox(
            height: 20,
          ),

          GestureDetector(
            onTap: () {
              if (stoolCondition != null &&
                  sputumCondition != null &&
                  inColdChain != null) {
                print(stoolCondition);
                print(sputumCondition);
                print(inColdChain);
                // ordersBloc.add(event)
                Navigator.pop(context, true);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: kColorsOrangeDark,
              ),
              height: 62,
              // margin: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          // SelectorPage(),
        ],
      ),
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
