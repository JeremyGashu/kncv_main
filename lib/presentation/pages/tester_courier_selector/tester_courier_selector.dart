import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_state.dart';
import 'package:kncv_flutter/service_locator.dart';

class SelectorPage extends StatefulWidget {
  final String? buttonText;
  static const String selectorPageRouteName = 'selector page route name';

  const SelectorPage({
    Key? key,
    this.buttonText = 'Create Order',
  }) : super(key: key);
  @override
  _SelectorPageState createState() => _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
  Tester? tester;
  Courier? courier;
  String? date;
  TesterCourierBloc testerCourierBloc = sl<TesterCourierBloc>();

  @override
  void initState() {
    BlocProvider.of<TesterCourierBloc>(context).courier = null;
    BlocProvider.of<TesterCourierBloc>(context).tester = null;
    // BlocProvider.of<TesterCourierBloc>(context).date = null;

    DateTime t = DateTime.now();

    int month = t.month;
    int day = t.day;
    int year = t.year;

    String d = '$day-$month-$year';
    setState(() {
      date = d;
      BlocProvider.of<TesterCourierBloc>(context).date = date;
    });
    testerCourierBloc.add(LoadTestersAndCouriers());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TesterCourierBloc, TesterCourierStates>(
        bloc: testerCourierBloc,
        listener: (ctx, state) {
          // print(state);
        },
        builder: (context, state) {
          if (state is LoadedState) {
            return Column(
              children: [
                _labelBuilder('Select Time'),
                GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        minTime: DateTime.now(),
                        currentTime: DateTime.now(),
                        onConfirm: (t) {
                          int month = t.month;
                          int day = t.day;
                          int year = t.year;

                          String d = '$day-$month-$year';
                          // print(d);
                          setState(() {
                            date = d;
                            BlocProvider.of<TesterCourierBloc>(context).date =
                                date;
                          });

                          // setState(() {
                          //   date = t;
                          // });
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            date ?? 'Please Select Date',
                            style: TextStyle(
                                color: Colors.black87.withOpacity(0.8),
                                fontSize: 15),
                          ),
                        ),
                      ),
                    )),
                SizedBox(
                  height: 30,
                ),
                Container(
                    width: double.infinity,
                    child: Text(
                      'Nearby Couriers',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: kTextColorLight,
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<Courier>(
                          onChanged: (val) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              courier = val;
                              BlocProvider.of<TesterCourierBloc>(context)
                                  .courier = val;
                            });
                          },
                          value: courier,
                          hint: Text('Select Courier'),
                          items: state.data['couriers']!
                              .map(
                                (e) => DropdownMenuItem<Courier>(
                                  value: e as Courier,
                                  child: Text(
                                    e.toString(),
                                  ),
                                ),
                              )
                              .toList())),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                    width: double.infinity,
                    child: Text(
                      'Nearby Test Centers',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: kTextColorLight,
                      ),
                    )),
                SizedBox(
                  height: 5,
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: Colors.grey.withOpacity(0.2),
                //     borderRadius: BorderRadius.circular(7),
                //   ),
                //   child: DropdownButtonHideUnderline(
                //       child: DropdownButton<Tester>(
                //           onChanged: (val) {
                //             FocusScope.of(context).requestFocus(FocusNode());
                //             setState(() {
                //               tester = val;
                //               BlocProvider.of<TesterCourierBloc>(context).tester = tester;
                //             });
                //           },
                //           value: tester,
                //           hint: Text('Select Tester'),
                //           items: state.data['testers']!
                //               .map(
                //                 (e) => DropdownMenuItem<Tester>(
                //                   value: e as Tester,
                //                   child: Text(
                //                     e.toString(),
                //                   ),
                //                 ),
                //               )
                //               .toList())),
                // ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Autocomplete<Tester>(
                    displayStringForOption: (t) => t.name,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<Tester>.empty();
                      }
                      return (state.data['testers']! as List<Tester>)
                          .where((tester) {
                        return tester.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (Tester selection) {
                      setState(() {
                        tester = selection;
                        BlocProvider.of<TesterCourierBloc>(context).tester =
                            tester;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 45,
                ),
                InkWell(
                  onTap: () {
                    // print('Popping');
                    if (BlocProvider.of<TesterCourierBloc>(context).tester !=
                            null &&
                        BlocProvider.of<TesterCourierBloc>(context).courier !=
                            null) {
                      Navigator.pop(context, true);
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
                        widget.buttonText ?? 'Create Order',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _labelBuilder(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        label,
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
