import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/core/message_codes.dart';
import 'package:kncv_flutter/core/sms_handler.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/edit_patient_info.dart';
import 'package:kncv_flutter/service_locator.dart';

import '../notificatins.dart';

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

  TextEditingController _receiverController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  bool sendingFeedback = false;

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
          }

          if (state is ErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            await Future.delayed(Duration(seconds: 1));
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          } else if (state is AcceptedOrderCourier) {
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
          } else if (state is ApprovedArrivalCourier) {
          } else if (state is ApprovedArrivalTester) {
            ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
            addNotification(
              orderId: widget.orderId,
              content: 'Tester approved arrival of order!',
              courierContent:
                  'Tester center ${state.order.tester_name} accepted the order from ${state.order.sender_name}',
              senderContent:
                  'Speciment sent to ${state.order.tester_name} via courier ${state.order.courier_name} has been deliverd successfully!',
              testerContent:
                  'You have accepted order sent from ${state.order.sender_name} transported by ${state.order.courier_name}.',
            );
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
                                        'Testing Health Facility',
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

                              //change the way to be
                              SliverToBoxAdapter(
                                child: state.order.status == 'Delivered'
                                    ? sendingFeedback
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : buildSpecimensList(state.order)
                                    : state.order.patients!.length > 0
                                        ? ListView.builder(
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
                                                        'canEdit': false,
                                                        'canAddResult': true,
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
                        state.order.status == 'Picked Up'
                            ? Positioned(
                                left: 10,
                                bottom: 0,
                                right: 10,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      color: kPageBackground,
                                      child: InkWell(
                                        onTap: () async {
                                          bool confirm =
                                              await showModalBottomSheet(
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
                                                        topLeft:
                                                            Radius.circular(
                                                          30,
                                                        ),
                                                        topRight:
                                                            Radius.circular(
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
                                                          width:
                                                              double.infinity,
                                                          child: Text(
                                                            'Confirm Arrival',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 32,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                                    .value
                                                                    .text);

                                                            if (_receiverController
                                                                        .value
                                                                        .text !=
                                                                    '' &&
                                                                _phoneController
                                                                        .value
                                                                        .text !=
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
                                                                    fontSize:
                                                                        20,
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
                                            },
                                          );

                                          if (confirm == true) {
                                            if (!(await isConnectedToTheInternet())) {
                                              await sendSMS(context,
                                                  to: '0931057901',
                                                  payload: {
                                                    'oid': state.order.orderId,
                                                    'rn': _receiverController
                                                        .value.text,
                                                    'rp': _phoneController
                                                        .value.text,
                                                  },
                                                  action:
                                                      TESTER_APPROVE_COURIER_ARRIVAL);
                                              return;
                                            }
                                            ordersBloc.add(
                                              CourierApproveArrivalToTestCenter(
                                                state.order,
                                                _receiverController.value.text,
                                                _phoneController.value.text,
                                              ),
                                            );
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
                                  ],
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
            autofocus: false,
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

  Widget buildSpecimensList(Order order) {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: order.patients?.length ?? 0,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              child: Text(
                '${order.patients?[index].name ?? ''}\'s Specimens',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: order.patients![index].specimens?.length ?? 0,
              itemBuilder: (ctx, i) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: order.patients![index].specimens![i].assessed
                        ? Colors.green.withOpacity(0.2)
                        : Colors.yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      order.patients![index].specimens![i].type ?? '',
                    ),
                    subtitle: Text(
                        'ID : ${order.patients![index].specimens![i].id ?? ''}'),
                    trailing: !order.patients![index].specimens![i].assessed
                        ? TextButton(
                            onPressed: () async {
                              bool create = await showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (ctx) {
                                    return AssessSpecimen(ctx,
                                        order.patients![index].specimens![i]);
                                  });

                              if (create == true &&
                                  order.patients![index].specimens![i].type ==
                                      'Sputum') {
                                order.patients![index].specimens![i].assessed =
                                    true;
                                order.patients![index].specimens![i].rejected =
                                    'Mucoid Purulent' != sputumCondition;
                                order.patients![index].specimens![i].reason =
                                    'Specimen is in $sputumCondition type. Not Mucoid Purulent.';

                                setState(() {
                                  sendingFeedback = true;
                                });

                                bool success =
                                    await OrderRepository.editSpecimenFeedback(
                                        index: index,
                                        order: order,
                                        patient: order.patients![index]);

                                if (success) {
                                  addNotification(
                                      orderId: order.orderId!,
                                      testerContent:
                                          'You Accepted Sputum specimen for ${order.patients![index].name} from ${order.sender_name}',
                                      senderContent:
                                          '${order.patients![index].name}\'s Sputum Specimen have accepted by ${order.tester_name}.',
                                      content:
                                          'One specimen got accepted by courier!',
                                      courier: false);
                                  ordersBloc.add(
                                      LoadSingleOrder(orderId: widget.orderId));
                                }

                                if ('Mucoid Purulent' != sputumCondition) {
                                  addNotification(
                                      orderId: order.orderId!,
                                      testerContent:
                                          'You Rejected Sputum specimen for ${order.patients![index].name} from ${order.sender_name}',
                                      senderContent:
                                          '${order.patients![index].name}\'s Sputum Specimen have been rejected by ${order.tester_name}.',
                                      content:
                                          'One specimen got rejected by tester!',
                                      courier: false);
                                }

                                setState(() {
                                  inColdChain = null;
                                  stoolCondition = null;
                                  sputumCondition = null;
                                  sendingFeedback = false;
                                });
                              } else if (create == true &&
                                  order.patients![index].specimens![i].type ==
                                      'Stool') {
                                order.patients![index].specimens![i].assessed =
                                    true;
                                order.patients![index].specimens![i].rejected =
                                    'Formed' != stoolCondition;
                                order.patients![index].specimens![i].reason =
                                    'Stool Specimen is in $stoolCondition type. Not in Formed State!';

                                setState(() {
                                  sendingFeedback = true;
                                });

                                bool success =
                                    await OrderRepository.editSpecimenFeedback(
                                        index: index,
                                        order: order,
                                        patient: order.patients![index]);

                                if (success) {
                                  addNotification(
                                      orderId: order.orderId!,
                                      testerContent:
                                          'You Accepted Stool specimen for ${order.patients![index].name} from ${order.sender_name}',
                                      senderContent:
                                          '${order.patients![index].name}\'s Stool Specimen is accepted by ${order.tester_name}.',
                                      content:
                                          'One specimen got accepted by tester!',
                                      courier: false);
                                  setState(() {
                                    sendingFeedback = false;
                                  });
                                  ordersBloc.add(
                                      LoadSingleOrder(orderId: widget.orderId));
                                }
                                if ('Formed' != stoolCondition) {
                                  addNotification(
                                      orderId: order.orderId!,
                                      testerContent:
                                          'You Rejected Stool specimen for ${order.patients![index].name} from ${order.sender_name}',
                                      senderContent:
                                          '${order.patients![index].name}\'s Stool Specimen have been rejected by ${order.tester_name}.',
                                      content:
                                          'One specimen got rejected by tester!',
                                      courier: false);

                                  ordersBloc.add(
                                      LoadSingleOrder(orderId: widget.orderId));
                                }

                                setState(() {
                                  inColdChain = null;
                                  stoolCondition = null;
                                  sendingFeedback = false;
                                  sputumCondition = null;
                                });
                              } else if (create == true &&
                                  order.patients![index].specimens![i].type ==
                                      'Urine') {
                                order.patients![index].specimens![i].assessed =
                                    true;

                                order.patients![index].specimens![i].rejected =
                                    false;
                                order.patients![index].specimens![i].reason =
                                    '';

                                setState(() {
                                  sendingFeedback = true;
                                });

                                bool success =
                                    await OrderRepository.editSpecimenFeedback(
                                        index: index,
                                        order: order,
                                        patient: order.patients![index]);

                                if (success) {
                                  addNotification(
                                      orderId: order.orderId!,
                                      testerContent:
                                          'You Accepted Urine specimen for ${order.patients![index].name} from ${order.sender_name}',
                                      senderContent:
                                          '${order.patients![index].name}\'s Urine Specimen is accepted by ${order.tester_name}.',
                                      content:
                                          'One specimen got accepted by courier!',
                                      courier: false);
                                  setState(() {
                                    sendingFeedback = false;
                                  });
                                  ordersBloc.add(
                                      LoadSingleOrder(orderId: widget.orderId));
                                }

                                setState(() {
                                  inColdChain = null;
                                  stoolCondition = null;
                                  sendingFeedback = false;
                                  sputumCondition = null;
                                });
                              }
                            },
                            child: Text(
                              'Assess',
                              style: TextStyle(
                                color: kColorsOrangeLight,
                              ),
                            ),
                          )
                        : Icon(
                            order.patients![index].specimens![i].rejected
                                ? Icons.close
                                : Icons.check,
                          ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget AssessSpecimen(BuildContext context, Specimen specimen) {
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
              'Assess Specimen',
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
                items: <String>[
                  'Yes, end to end',
                  'Yes, partly',
                  'No, not at all'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    inColdChain = val;
                  });

                  ss(() {});
                },
              ));
            }),
          ),

          //sputum cndition
          specimen.type == 'Sputum'
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Sputum Condition',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                )
              : specimen.type == 'Stool'
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        'Stool Condition',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    )
                  : Container(),
          specimen.type == 'Sputum'
              ? Container(
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
                      items: <String>[
                        'Mucoid Purulent',
                        'Bloodstreak',
                        'Saliva'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        FocusScope.of(context).requestFocus(FocusNode());

                        setState(() {
                          sputumCondition = val;
                        });
                        ss(() {});
                      },
                    ));
                  }),
                )
              : specimen.type == 'Stool'
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          items: <String>['Formed', 'Unformed', 'Liquid']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              stoolCondition = val;
                            });
                            ss(() {});
                          },
                        ));
                      }),
                    )
                  : Container(),

          SizedBox(
            height: 20,
          ),

          GestureDetector(
            onTap: () {
              if (inColdChain != null) {
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
                  'Assess',
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
                items: <String>[
                  'Yes, end to end',
                  'Yes, partly',
                  'No, not at all'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  FocusScope.of(context).requestFocus(FocusNode());
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
                items: <String>['Mucoid Purulent', 'Bloodstreak', 'Saliva']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  FocusScope.of(context).requestFocus(FocusNode());
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
                items: <String>['Formed', 'Unformed', 'Liquid']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  FocusScope.of(context).requestFocus(FocusNode());
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
