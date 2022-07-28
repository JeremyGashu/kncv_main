import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/report.dart';
import 'package:kncv_flutter/service_locator.dart';
import '../notificatins.dart';

class AddTestResultPage extends StatefulWidget {
  final String orderId;
  final Patient patient;
  final Specimen specimen;
  final int index;
  final bool accepted;
  final bool canEdit;
  static const String addTestResultPageRouteName = 'add test result page';

  const AddTestResultPage({Key? key, required this.orderId, required this.index, required this.specimen, this.accepted = false, this.canEdit = false, required this.patient}) : super(key: key);

  @override
  State<AddTestResultPage> createState() => _AddTestResultPageState();
}

class _AddTestResultPageState extends State<AddTestResultPage> {
  bool editingResult = false;
  final TextEditingController resitrationNumberController = TextEditingController();
  OrderBloc orderBloc = sl<OrderBloc>();

  String? resultRR;
  String? mtbResult;
  String? quantity;

  String? time;
  String? date;

  @override
  void initState() {
    // debugPrint('Selected specimen ${widget.specimen.id}');

    var d = DateTime.now();
    int month = d.month;
    int year = d.year;
    int day = d.day;

    int minute = d.hour;
    int seconds = d.minute;

    resitrationNumberController.text = widget.specimen.testResult?.labRegistratinNumber ?? '';

    time = widget.specimen.testResult?.resultTime ?? '$minute:$seconds';
    date = widget.specimen.testResult?.resultDate ?? '$day-$month-$year';

    mtbResult = widget.specimen.testResult?.mtbResult;
    quantity = widget.specimen.testResult?.quantity;
    resultRR = widget.specimen.testResult?.resultRr;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: widget.patient.resultAvaiable
          ? AppBar(
              backgroundColor: kColorsOrangeLight,
              title: Text('Test Result'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ReportPage.reportPage, arguments: widget.patient);
                  },
                  icon: Icon(
                    Icons.save,
                  ),
                )
              ],
            )
          : AppBar(
              backgroundColor: kColorsOrangeLight,
              title: Text('Test Result'),
            ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: BlocConsumer<OrderBloc, OrderState>(
            bloc: orderBloc,
            listener: (ctx, state) async {
              if (state is AddedTestResult) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added Result!')));

                addNotification(
                  orderId: widget.orderId,
                  content: 'Added Test Result!',
                  senderContent: 'Patient result has been added to patient ${state.patient.name}',
                  testerContent: 'You have added test result to patient ${state.patient.name}.',
                  courier: false,
                  testerAction: NotificationAction.NavigateToOrderDetalTester,
                  senderAction: NotificationAction.NavigateToOrderDetalSender,
                  payload: {'orderId': widget.orderId},
                );
                await Future.delayed(Duration(seconds: 1));

                Navigator.pop(context, true);
              } else if (state is EditedTestResult) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edited Result!')));

                addNotification(
                  orderId: widget.orderId,
                  content: 'Added Test Result!',
                  senderContent: 'Patient result has been edited to patient ${state.patient.name}',
                  testerContent: 'You have edited test result to patient ${state.patient.name}.',
                  courier: false,
                  testerAction: NotificationAction.NavigateToOrderDetalTester,
                  senderAction: NotificationAction.NavigateToOrderDetalSender,
                  payload: {'orderId': widget.orderId},
                );
                await Future.delayed(Duration(seconds: 1));

                Navigator.pop(context, true);
              }

              if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                await Future.delayed(Duration(seconds: 1));
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 700),
                    padding: EdgeInsets.only(bottom: 15, left: 25, top: 10, right: 25),
                    child: ListView(
                      shrinkWrap: true,
                      children: !editingResult && widget.specimen.testResult != null
                          ? [
                              // _labelBuilder('Test Date'),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      widget.patient.resultAvaiable ? 'Test Result' : 'Add Test Result',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                                    ),
                                    widget.canEdit
                                        ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                editingResult = !editingResult;
                                                // print('plrase');
                                              });
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: kColorsOrangeDark,
                                            ))
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                              _labelBuilder('Test Date'),

                              Container(
                                width: double.infinity,
                                height: 54,
                                // margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      widget.specimen.testResult?.resultDate ?? 'Please Select Date',
                                      style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                              _labelBuilder('Test Time'),
                              Container(
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
                                      widget.specimen.testResult?.resultTime ?? 'Please Select Time',
                                      style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),

                              _labelBuilder('MTB Result'),

                              Container(
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
                                      widget.specimen.testResult?.mtbResult ?? '',
                                      style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),

                              _labelBuilder('Quantity'),

                              Container(
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
                                      widget.specimen.testResult?.quantity ?? '',
                                      style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),

                              _labelBuilder('Result RR'),

                              Container(
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
                                      widget.specimen.testResult?.resultRr ?? '',
                                      style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          : [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      widget.patient.resultAvaiable ? 'Test Result' : 'Add Test Result',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                                    ),
                                    widget.canEdit && (widget.specimen.testResult != null)
                                        ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                editingResult = !editingResult;
                                                // print('plrase');
                                              });
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: kColorsOrangeDark,
                                            ))
                                        : SizedBox(),
                                  ],
                                ),
                              ),

                              _tobLabelBuilder('Test Result'),

                              _labelBuilder('Select Date'),

                              GestureDetector(
                                  onTap: !widget.canEdit
                                      ? () {}
                                      : () {
                                          DatePicker.showDatePicker(
                                            context,
                                            showTitleActions: true,
                                            minTime: DateTime.now(),
                                            onConfirm: (d) {
                                              int month = d.month;
                                              int year = d.year;
                                              int day = d.day;
                                              setState(() {
                                                date = '$day-$month-$year';
                                              });
                                            },
                                            currentTime: DateTime.now(),
                                            locale: LocaleType.en,
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
                                          style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  )),

                              _labelBuilder('Select Time'),

                              GestureDetector(
                                onTap: !widget.canEdit
                                    ? () {}
                                    : () {
                                        DatePicker.showTime12hPicker(
                                          context,
                                          currentTime: DateTime.now(),
                                          onConfirm: (t) {
                                            int hour = t.hour;
                                            int minutes = t.minute;
                                            setState(() {
                                              time = '$hour:$minutes';
                                            });
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
                                        time ?? 'Please Select Time',
                                        style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              _buildInputField(
                                label: 'Lab Resitration Number',
                                hint: 'Lab Registration Number',
                                controller: resitrationNumberController,
                                disabled: !widget.canEdit,
                              ),

                              _labelBuilder('MTB Result'),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                  value: mtbResult,
                                  hint: Text('MTB Result'),
                                  items: <String>['MTB Not Detected', 'MTB Detected'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      enabled: widget.canEdit,
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    setState(() {
                                      if (val == 'MTB Not Detected ') {
                                        resultRR = null;
                                        quantity = null;
                                      }
                                      // print(val == 'MTB Not Detected');
                                      mtbResult = val;
                                    });
                                  },
                                )),
                              ),

                              mtbResult == 'MTB Detected' ? _labelBuilder('Quantity') : SizedBox(),
                              mtbResult == 'MTB Detected'
                                  ? Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                        value: quantity,
                                        hint: Text('Quantity'),
                                        items: <String>['High', 'Medium', 'Low', 'Very Low', 'Trace'].map((String value) {
                                          return DropdownMenuItem<String>(
                                            enabled: widget.canEdit,
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          setState(() {
                                            quantity = val;
                                          });
                                        },
                                      )),
                                    )
                                  : SizedBox(),

                              mtbResult == 'MTB Detected' ? _labelBuilder('Result RR') : SizedBox(),
                              mtbResult == 'MTB Detected'
                                  ? Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                        value: resultRR,
                                        hint: Text('Result RR'),
                                        items: <String>[
                                          'Rif Res Detected',
                                          'Rif Res Not Detected',
                                          'Rif Res Indeterminate',
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            enabled: widget.canEdit,
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          setState(() {
                                            resultRR = val;
                                          });
                                        },
                                      )),
                                    )
                                  : SizedBox(),

                              // _buildInputField(
                              //   label: 'MTB Result',
                              //   hint: 'MTB Result',
                              //   controller: mtbResultController,
                              //   disabled: widget.patient.resultAvaiable,
                              // ),
                              // _buildInputField(
                              //   label: 'Quantity',
                              //   hint: 'Quantity',
                              //   controller: quantityController,
                              //   disabled: widget.patient.resultAvaiable,
                              // ),

                              // _buildInputField(
                              //   label: 'Result RR',
                              //   hint: 'Result RR',
                              //   controller: resultRRController,
                              //   disabled: widget.patient.resultAvaiable,
                              // ),

                              SizedBox(
                                height: 35,
                              ),

                              !widget.patient.resultAvaiable
                                  ? Container(
                                      // padding: EdgeInsets.all(10),
                                      color: kPageBackground,
                                      child: state is AddingTestResult
                                          ? Center(
                                              child: CircularProgressIndicator(),
                                            )
                                          : InkWell(
                                              onTap: () async {
                                                // String resultRR =
                                                //     resultRRController.value.text;
                                                // String mtbResult =
                                                //     mtbResultController.value.text;
                                                // String quantity =
                                                //     quantityController.value.text;
                                                String registrationNumber = resitrationNumberController.value.text;

                                                // print('$date \n $time $resultRR \n $mtbResult \n $quantity \n $registrationNumber');
                                                TestResult result = TestResult(
                                                  labRegistratinNumber: registrationNumber,
                                                  resultDate: date,
                                                  resultTime: time,
                                                  mtbResult: mtbResult,
                                                  quantity: quantity,
                                                  resultRr: resultRR,
                                                );
                                                widget.patient.testResult = result;
                                                widget.patient.resultAvaiable = true;
                                                widget.patient.status = 'Tested';

                                                int? specimentIndex = widget.patient.specimens?.indexWhere((element) => element.id == widget.specimen.id);

                                                if (specimentIndex != null) {
                                                  widget.patient.specimens?[specimentIndex].testResult = result;

                                                  widget.patient.specimens?[specimentIndex].testResultAddedAt = DateTime.now();
                                                }

                                                orderBloc.add(
                                                  AddTestResult(orderId: widget.orderId, index: widget.index, patient: widget.patient),
                                                );
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
                                                    'Add Test Result',
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    )
                                  : Container(),

                              widget.patient.resultAvaiable && widget.canEdit
                                  ? Container(
                                      // padding: EdgeInsets.all(10),
                                      color: kPageBackground,
                                      child: state is EditingTestResult
                                          ? Center(
                                              child: CircularProgressIndicator(),
                                            )
                                          : InkWell(
                                              onTap: () async {
                                                String registrationNumber = resitrationNumberController.value.text;

                                                // print('$date \n $time $resultRR \n $mtbResult \n $quantity \n $registrationNumber');
                                                TestResult result = TestResult(
                                                  labRegistratinNumber: registrationNumber,
                                                  resultDate: date,
                                                  resultTime: time,
                                                  mtbResult: mtbResult,
                                                  quantity: quantity,
                                                  resultRr: resultRR,
                                                );
                                                widget.patient.testResult = result;
                                                widget.patient.resultAvaiable = true;
                                                widget.patient.status = 'Tested';

                                                int? specimentIndex = widget.patient.specimens?.indexWhere((element) => element.id == widget.specimen.id);

                                                if (specimentIndex != null) {
                                                  widget.patient.specimens?[specimentIndex].testResult = result;
                                                }

                                                orderBloc.add(
                                                  EditTestResult(orderId: widget.orderId, index: widget.index, patient: widget.patient),
                                                );
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
                                                    widget.specimen.testResult != null ? 'Edit Test Result' : 'Add Test Result',
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    )
                                  : Container(),
                            ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
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

  Widget _tobLabelBuilder(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 23, bottom: 13),
      child: Text(
        label,
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool disabled = false,
  }) {
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
            readOnly: disabled,
            decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 3)),
          ),
        ),
      ],
    );
  }
}
