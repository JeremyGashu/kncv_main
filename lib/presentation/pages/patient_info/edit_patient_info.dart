import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';
import 'package:kncv_flutter/presentation/pages/orders/result_page.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/patient_info.dart';

import '../../../service_locator.dart';

class EditPatientInfoPage extends StatefulWidget {
  final String orderId;
  final Patient patient;
  final int index;
  final bool canEdit;
  final bool canAddResult;

  static const String editPatientInfoRouteName = 'edit patient info route name';

  const EditPatientInfoPage({
    Key? key,
    required this.orderId,
    required this.patient,
    required this.index,
    this.canEdit = false,
    this.canAddResult = false,
  }) : super(key: key);

  @override
  State<EditPatientInfoPage> createState() => _EditPatientInfoPageState();
}

class _EditPatientInfoPageState extends State<EditPatientInfoPage> {
  String? childhood = 'Yes';
  String? tb;
  String? pneumonia;
  String? recurrentPneumonia;
  String? dm;
  String? malnutrition;
  String? anatomicLocation;
  String? sex;
  String? specimenType;
  String? dateOfBirth;
  String? examinationType;

  String? hivStatus;

  List<Specimen> specimens = [];

  OrderBloc orderBloc = sl<OrderBloc>();

  final TextEditingController MRController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController woredaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController doctorInChargeController =
      TextEditingController();
  final TextEditingController patientRemarkController = TextEditingController();
  final TextEditingController examPurposeController = TextEditingController();

  final TextEditingController specimenIdController = TextEditingController();

  @override
  initState() {
    childhood = widget.patient.childhood;
    tb = widget.patient.tb;
    pneumonia = widget.patient.pneumonia;
    recurrentPneumonia = widget.patient.recurrentPneumonia;
    dm = widget.patient.dm;
    malnutrition = widget.patient.malnutrition;
    anatomicLocation = widget.patient.anatomicLocation;
    sex = widget.patient.sex;
    dateOfBirth = widget.patient.dateOfBirth;
    hivStatus = widget.patient.hiv;

    MRController.text = widget.patient.mr ?? '';
    nameController.text = widget.patient.name ?? '';
    ageController.text = widget.patient.age ?? '';
    zoneController.text = widget.patient.zone ?? '';
    woredaController.text = widget.patient.woreda ?? '';
    addressController.text = widget.patient.address ?? '';
    phoneController.text = widget.patient.phone ?? '';
    doctorInChargeController.text = widget.patient.doctorInCharge ?? '';
    examPurposeController.text = widget.patient.examPurpose ?? '';
    patientRemarkController.text = widget.patient.remark ?? '';

    specimens = [...widget.patient.specimens!];

    orderBloc.add(LoadSingleOrder(
      orderId: widget.orderId,
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: BlocConsumer<OrderBloc, OrderState>(
            bloc: orderBloc,
            listener: (ctx, state) async {
              if (state is EditedPatientState) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edited Patient Data!')));
                await Future.delayed(Duration(seconds: 1));
                Navigator.pushReplacementNamed(
                    context, OrderDetailPage.orderDetailPageRouteName,
                    arguments: widget.orderId);
              } else if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errro Adding Patient!')));
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Container(
                  padding:
                      EdgeInsets.only(bottom: 15, left: 25, top: 10, right: 25),
                  child: SingleChildScrollView(
                    child: Form(
                      child: Column(
                        children: [
                          //controller, hint, label,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              widget.patient.resultAvaiable || !widget.canEdit
                                  ? 'Patient Info'
                                  : 'Edit Patient Info',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w500),
                            ),
                          ),
                          _tobLabelBuilder('Basic Info'),
                          _buildInputField(
                            label: 'MRN',
                            hint: 'Enter Your MR',
                            controller: MRController,
                            editable: !(widget.patient.status == 'Tested') &&
                                widget.canEdit,
                          ),
                          _buildInputField(
                              label: 'Name',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              hint: 'Enter Your Name',
                              controller: nameController),
                          _labelBuilder('Sex'),
                          GestureDetector(
                            onTap: () {
                              // FocusScope.of(context).requestFocus(new FocusNode());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                value: sex,
                                hint: Text('Sex'),
                                items: <String>['Male', 'Female']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    enabled: !widget.patient.resultAvaiable &&
                                        widget.canEdit,
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    sex = val;
                                  });
                                },
                              )),
                            ),
                          ),

                          _labelBuilder('Date Of Birth'),

                          GestureDetector(
                              onTap: (widget.patient.resultAvaiable ||
                                      !widget.canEdit)
                                  ? () {}
                                  : () {
                                      DatePicker.showDatePicker(
                                        context,
                                        showTitleActions: true,
                                        maxTime: DateTime.now(),
                                        minTime: DateTime.now().subtract(
                                            Duration(days: (365 * 200))),
                                        onConfirm: (d) {
                                          int month = d.month;
                                          int year = d.year;
                                          int day = d.day;
                                          setState(() {
                                            dateOfBirth = '$day-$month-$year';
                                            ageController.text =
                                                calculateAge(d).toString();
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
                                      dateOfBirth ?? 'Please Select Date',
                                      style: TextStyle(
                                          color:
                                              Colors.black87.withOpacity(0.5),
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              )),

                          _buildInputField(
                            editable: false,
                            label: 'Age',
                            hint: 'Please enter Date of Birth',
                            controller: ageController,
                          ),

                          _tobLabelBuilder('Address'),
                          _buildInputField(
                              label: 'Zone',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              hint: 'Enter Your Zone',
                              controller: zoneController),
                          _buildInputField(
                              label: 'Woreda',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              hint: 'Enter Your Woreda',
                              controller: woredaController),
                          _buildInputField(
                              label: 'Address',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              hint: 'Enter Your Address',
                              controller: addressController),
                          _buildInputField(
                              label: 'Phone',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              hint: 'Enter Your Phone',
                              controller: phoneController),

                          _tobLabelBuilder('Observation'),

                          // _labelBuilder('Childhood'),

                          // Container(
                          //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          //   width: double.infinity,
                          //   decoration: BoxDecoration(
                          //     color: Colors.grey.withOpacity(0.2),
                          //     borderRadius: BorderRadius.circular(7),
                          //   ),
                          //   child: DropdownButtonHideUnderline(
                          //       child: DropdownButton<String>(
                          //     value: childhood,
                          //     hint: Text('Childhood'),
                          //     items: <String>['Yes', 'No'].map((String value) {
                          //       return DropdownMenuItem<String>(
                          //         value: value,
                          //         child: Text(value),
                          //       );
                          //     }).toList(),
                          //     onChanged: (val) {
                          //       setState(() {
                          //         childhood = val;
                          //       });
                          //     },
                          //   )),
                          // ),
                          _labelBuilder('Pneumonia'),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: pneumonia,
                              hint: Text('Pneumonia'),
                              items: <String>['Yes', 'No'].map((String value) {
                                return DropdownMenuItem<String>(
                                  enabled: !widget.patient.resultAvaiable &&
                                      widget.canEdit,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  pneumonia = val;
                                });
                              },
                            )),
                          ),
                          _labelBuilder('TB'),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: tb,
                              hint: Text('TB'),
                              items: <String>['Yes', 'No'].map((String value) {
                                return DropdownMenuItem<String>(
                                  enabled: !widget.patient.resultAvaiable &&
                                      widget.canEdit,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  tb = val;
                                });
                              },
                            )),
                          ),
                          _labelBuilder('Recurrent Pneumonia'),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: recurrentPneumonia,
                              hint: Text('Recurrent Pneuomonia'),
                              items: <String>['Yes', 'No'].map((String value) {
                                return DropdownMenuItem<String>(
                                  enabled: !widget.patient.resultAvaiable &&
                                      widget.canEdit,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  recurrentPneumonia = val;
                                });
                              },
                            )),
                          ),

                          _labelBuilder('Malnutrition'),

                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: malnutrition,
                              hint: Text('Malnutrition'),
                              items: <String>['Yes', 'No'].map((String value) {
                                return DropdownMenuItem<String>(
                                  enabled: !widget.patient.resultAvaiable &&
                                      widget.canEdit,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  malnutrition = val;
                                });
                              },
                            )),
                          ),
                          _labelBuilder('DM'),

                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: dm,
                              hint: Text('DM'),
                              items: <String>['Yes', 'No'].map((String value) {
                                return DropdownMenuItem<String>(
                                  enabled: !widget.patient.resultAvaiable &&
                                      widget.canEdit,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  dm = val;
                                });
                              },
                            )),
                          ),

                          _labelBuilder('HIV'),

                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: hivStatus,
                              hint: Text('HIV'),
                              items: <String>['Negative', 'Positive', 'Unknown']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  enabled: !widget.patient.resultAvaiable &&
                                      widget.canEdit,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  hivStatus = val;
                                });
                              },
                            )),
                          ),

                          buildRemarkField(
                            label: 'Remark',
                            hint: 'Pateint Remark',
                            controller: patientRemarkController,
                            editable: !widget.patient.resultAvaiable &&
                                widget.canEdit,
                          ),

                          _tobLabelBuilder('Specimen Purpose'),
                          _labelBuilder('Anatomic Location'),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: anatomicLocation,
                              hint: Text('Anatomic Location'),
                              items: <String>['Pulmonary', 'Extra-pulmonary']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  enabled: !widget.patient.resultAvaiable &&
                                      widget.canEdit,
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  anatomicLocation = val;
                                });
                              },
                            )),
                          ),

                          _buildInputField(
                              label: 'Doctor in charge',
                              hint: 'Doctor in charge',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              controller: doctorInChargeController),

                          _buildInputField(
                              label: 'Exam Purpose',
                              hint: 'Please enter exam pupose',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              controller: examPurposeController),

                          SizedBox(
                            height: 15,
                          ),

                          !widget.patient.resultAvaiable
                              ? widget.canEdit
                                  ? GestureDetector(
                                      onTap: () {
                                        if (widget.canEdit) {
                                          showModalBottomSheet(
                                              backgroundColor:
                                                  Colors.transparent,
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (ctx) {
                                                return StatefulBuilder(
                                                    builder: (ctx, ss) {
                                                  return Container(
                                                    padding: EdgeInsets.only(
                                                        top: 30,
                                                        left: 20,
                                                        right: 20,
                                                        bottom: 20),
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
                                                            'Create Specimen',
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
                                                            label:
                                                                'Specimen ID',
                                                            hint:
                                                                "Please enter specimen ID",
                                                            controller:
                                                                specimenIdController),
                                                        _labelBuilder(
                                                            'Specimen Type'),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                            value: specimenType,
                                                            hint: Text(
                                                                'Specimen Type'),
                                                            items: <String>[
                                                              'Stool',
                                                              'Sputum',
                                                              'Urine'
                                                            ].map(
                                                                (String value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                enabled: !widget
                                                                        .patient
                                                                        .resultAvaiable &&
                                                                    widget
                                                                        .canEdit,
                                                                value: value,
                                                                child:
                                                                    Text(value),
                                                              );
                                                            }).toList(),
                                                            onChanged: (val) {
                                                              ss(() => 1 == 1);

                                                              setState(() {
                                                                specimenType =
                                                                    val;
                                                              });
                                                            },
                                                          )),
                                                        ),
                                                        _labelBuilder(
                                                            'Examination Type'),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                            value:
                                                                examinationType,
                                                            hint: Text(
                                                                'Examination Type'),
                                                            items: <String>[
                                                              'GeneXpert',
                                                              'AFB Microscopy',
                                                              'Other',
                                                            ].map(
                                                                (String value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child:
                                                                    Text(value),
                                                              );
                                                            }).toList(),
                                                            onChanged: (val) {
                                                              ss(() => 1 == 1);

                                                              setState(() {
                                                                examinationType =
                                                                    val;
                                                              });
                                                            },
                                                          )),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        !widget.patient
                                                                .resultAvaiable
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  print(
                                                                      specimenType);
                                                                  print(
                                                                      specimenIdController
                                                                          .value
                                                                          .text);
                                                                  if (specimenIdController
                                                                              .value
                                                                              .text ==
                                                                          '' ||
                                                                      specimenType ==
                                                                          null) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(SnackBar(
                                                                            content:
                                                                                Text('Please enter complete information')));
                                                                    Navigator.pop(
                                                                        context);
                                                                    return;
                                                                  }

                                                                  if (specimenExists(
                                                                      specimens,
                                                                      specimenIdController
                                                                          .value
                                                                          .text,
                                                                      specimenType!)) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(SnackBar(
                                                                            content:
                                                                                Text('This specimen is already added please try editing fields.')));
                                                                    Navigator.pop(
                                                                        context);
                                                                    return;
                                                                  }

                                                                  Specimen specimen = Specimen(
                                                                      id: specimenIdController
                                                                          .value
                                                                          .text,
                                                                      type:
                                                                          specimenType,
                                                                      examinationType:
                                                                          examinationType);
                                                                  setState(() {
                                                                    specimens =
                                                                        [
                                                                      ...specimens,
                                                                      specimen
                                                                    ];
                                                                  });
                                                                  print(specimens
                                                                      .length);
                                                                  specimenIdController
                                                                      .text = '';
                                                                  specimenType =
                                                                      null;
                                                                  // ScaffoldMessenger.of(context)
                                                                  //     .showSnackBar(SnackBar(
                                                                  //         content: Text(
                                                                  //             'Added Specimen')));
                                                                  Navigator.pop(
                                                                      context);
                                                                  return;
                                                                },
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color:
                                                                          kColorsOrangeDark,
                                                                    ),
                                                                    height: 62,
                                                                    // margin: EdgeInsets.all(20),
                                                                    child: Center(
                                                                      child:
                                                                          Text(
                                                                        'Add Specimen',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                20,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    )))
                                                            : Container(),
                                                      ],
                                                    ),
                                                  );
                                                });
                                              });
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 110,
                                        color: Colors.grey.withOpacity(0.3),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: kColorsOrangeLight,
                                              size: 30,
                                            ),
                                            Text('Add Specimen'),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container()
                              : Container(),

                          SizedBox(
                            height: 15,
                          ),

                          _labelBuilder('Specimens'),

                          getSpecimensFromState(state),

                          SizedBox(
                            height: 10,
                          ),

                          !widget.patient.resultAvaiable
                              ? Container(
                                  // padding: EdgeInsets.all(10),
                                  color: kPageBackground,
                                  child: state is EditingPatientState
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (!widget.canEdit) {
                                              Navigator.pushNamed(
                                                  context,
                                                  AddTestResultPage
                                                      .addTestResultPageRouteName,
                                                  arguments: {
                                                    'orderId': widget.orderId,
                                                    'patient': widget.patient,
                                                    'index': widget.index,
                                                  });
                                            } else {
                                              String mr =
                                                  MRController.value.text;
                                              String name =
                                                  nameController.value.text;
                                              //sex, childhood, pneumonic, tb, r pn, mal, dm, loc
                                              String age =
                                                  ageController.value.text;
                                              String zone =
                                                  zoneController.value.text;
                                              String woreda =
                                                  woredaController.value.text;
                                              String address =
                                                  addressController.value.text;
                                              String phone =
                                                  phoneController.value.text;
                                              String doctorInCharge =
                                                  doctorInChargeController
                                                      .value.text;
                                              String examinatinPurpose =
                                                  examPurposeController
                                                      .value.text;
                                              String patientRemark =
                                                  patientRemarkController
                                                      .value.text;
                                              Patient patient = Patient(
                                                age: age,
                                                anatomicLocation:
                                                    anatomicLocation,
                                                childhood: childhood,
                                                dm: dm,
                                                doctorInCharge: doctorInCharge,
                                                examPurpose: examinatinPurpose,
                                                malnutrition: malnutrition,
                                                phone: phone,
                                                zone: zone,
                                                woreda: woreda,
                                                address: address,
                                                name: name,
                                                sex: sex,
                                                specimens: specimens,
                                                pneumonia: pneumonia,
                                                tb: tb,
                                                hiv: hivStatus,
                                                remark: patientRemark,
                                                recurrentPneumonia:
                                                    recurrentPneumonia,
                                                mr: mr,
                                                dateOfBirth: dateOfBirth,
                                              );

                                              orderBloc.add(EditPtientInfo(
                                                  orderId: widget.orderId,
                                                  patient: patient,
                                                  index: widget.index));
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
                                                widget.canEdit
                                                    ? 'Edit Patient'
                                                    : widget.patient
                                                            .resultAvaiable
                                                        ? 'View Result'
                                                        : 'Add Result',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                )
                              : Container(),

                          widget.patient.resultAvaiable
                              ? InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AddTestResultPage
                                          .addTestResultPageRouteName,
                                      arguments: {
                                        'orderId': widget.orderId,
                                        'patient': widget.patient,
                                        'index': widget.index,
                                      },
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
                                        'View Result',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget getSpecimensFromState(
    OrderState state,
  ) {
    if (state is LoadedSingleOrder && state.order.status == 'Draft') {
      return Container(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          direction: Axis.horizontal,
          children: specimens
              .map(
                (e) => Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type : ${e.type}'),
                          Text('ID : ${e.id}'),
                          Text('Examination Type : ${e.examinationType}'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          specimens.remove(e);
                        });
                      },
                      icon: Icon(
                        Icons.close,
                      ),
                    )
                  ],
                ),
              )
              .toList(),
        ),
      );
    }
    return Container(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        direction: Axis.horizontal,
        children: specimens
            .map(
              (e) => Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type : ${e.type}'),
                        Text('ID : ${e.id}'),
                        Text('Examination Type : ${e.examinationType}'),
                        // Text('Assessed : ${e.assessed}'),
                        !e.rejected ? Text('Accepted : ${!e.rejected}') : Container(),
                        e.rejected ? Text('Rejected : ${e.rejected}') : Container(),
                        e.rejected ? Text('Reason : ${e.reason}') : Container(),
                      
                      ],
                    ),
                  ),
                ],
              ),
            )
            .toList(),
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

  Widget _buildInputField(
      {required String label,
      required String hint,
      required TextEditingController controller,
      bool editable = true}) {
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
            readOnly: !editable,
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
}
