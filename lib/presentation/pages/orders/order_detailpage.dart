import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/patient_info.dart';
import 'package:kncv_flutter/service_locator.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  static const String orderDetailPageRouteName = 'order detail page route name';

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
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
          if (state is DeletedOrder) {
            await Future.delayed(Duration(seconds: 1));
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(SnackBar(content: Text('Order Delted!')));
            Navigator.pop(context, true);
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
          }
          if (state is PlacedOrder) {
            await Future.delayed(Duration(seconds: 1));
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(SnackBar(content: Text('Order Placed!')));
            ordersBloc.add(LoadOrders());
          }
        },
        builder: (ctx, state) {
          return RefreshIndicator(
            onRefresh: () async {
              ordersBloc.add(LoadSingleOrder(orderId: widget.orderId));
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
                actions: [
                  state is DeletingOrder
                      ? Container()
                      : IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.black,
                          ),
                          onPressed: () {
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
                                                orderId: widget.orderId));
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
                        ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                  ),
                ],
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
                                    FutureBuilder(
                                        future: sl<OrderRepository>()
                                            .getInstitutionDataFromUserId(),
                                        builder: (context,
                                            AsyncSnapshot<Map<String, dynamic>?>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.blue,
                                                radius: 25,
                                                child: Text(
                                                  'S',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                '${snapshot.data?['institution']['name']}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: Text(
                                                'Sender',
                                                style: TextStyle(
                                                    color: kColorsOrangeLight,
                                                    fontSize: 14),
                                              ),
                                            );
                                          }
                                          return Container();
                                        }),

                                    //courier
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        radius: 25,
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
                                        radius: 25,
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
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FloatingActionButton(
                                      tooltip: 'Add Patient',
                                      backgroundColor: kColorsOrangeLight,
                                      elevation: 0,
                                      onPressed: () async {
                                        var added = await Navigator.pushNamed(
                                            context,
                                            PatientInfoPage
                                                .patientInfoPageRouteName,
                                            arguments: widget.orderId);
                                        if (added == true) {
                                          ordersBloc.add(LoadSingleOrder(
                                              orderId: widget.orderId));
                                        }
                                      },
                                      child:
                                          Icon(Icons.app_registration_rounded)),
                                ],
                              )),

                              SliverToBoxAdapter(
                                child: state.order.patients!.length > 0
                                    ? ListView(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        children: state.order.patients!
                                            .map((e) => buildPatients(
                                                e, widget.orderId))
                                            .toList(),
                                      )
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
                                    onTap: () {
                                      if (state.order.patients!.length == 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Please add patients first!')));
                                        return;
                                      }

                                      ordersBloc.add(
                                          PlaceOrder(orderId: widget.orderId));
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
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          );
        });
  }

  Container buildPatients(Patient patient, String orderId) {
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
                    'Draft',
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ordersBloc.add(
                          DeletePatient(orderId: orderId, patient: patient));
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
                  Container(
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
