import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';
import 'package:kncv_flutter/presentation/pages/orders/result_page.dart';
import 'package:kncv_flutter/presentation/pages/patient_info/patient_info.dart';

import '../../../service_locator.dart';
import '../notificatins.dart';

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
  bool sendingFeedback = false;

  Region? selectedRegion;
  Zone? selectedZone;
  Woreda? selectedWoreda;

  String? inColdChain;
  String? sputumCondition;
  String? stoolCondition;

  var siteOfTbChoices = [
    'Pulmonary',
    'Extra-pulmonary',
    'Other',
  ];
  var registrationGroupChoices = [
    'New',
    'Relapse',
    'After Default',
    'After failure of 1st treatment',
    'After failure of re treatment',
    'Other'
  ];
  var reasonForTestChoices = [
    'Diagnostic',
    'Presumptive TB',
    'Presumptive RR-TB',
    'Presumptive MDR-TB',
    'At X months during treatment',
    'At X months after treatment'
  ];
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

  Map<String, List<String>> examinationTypesList = {
    'Stool': ['AFB microscopy', 'GeneXpret', 'Culture', 'LPA', 'DST'],
    'Sputum': ['AFB microscopy', 'GeneXpret', 'Culture', 'LPA', 'DST'],
    'Urine': ['LF LAM'],
    'Blood': ['CD4 Count', 'Viral Load'],
    'Swab': ['GeneXpret'],
    'Other': ['GeneXpret']
  };

  //new
  String? siteOfTB;
  String? registrationGroup;
  String? requestedTests;
  final TextEditingController registrationGroupController =
      TextEditingController();
  final TextEditingController siteOfTBController = TextEditingController();
  final TextEditingController xMonthsDuringController = TextEditingController();
  final TextEditingController xMonthsAfterController = TextEditingController();

  String? previousTBDrugUse;
  GlobalKey<FormState> _form = GlobalKey<FormState>();

  String? reasonForTest;

  String? hivStatus;

  List<Specimen> specimens = [];

  OrderBloc orderBloc = sl<OrderBloc>();

  final TextEditingController MRController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageYearsController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController woredaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController doctorInChargeController =
      TextEditingController();
  final TextEditingController ageMonthsController = TextEditingController();

  final TextEditingController patientRemarkController = TextEditingController();
  final TextEditingController examPurposeController = TextEditingController();

  final TextEditingController specimenIdController = TextEditingController();

  @override
  initState() {
    // print('ptient => ${widget.patient.siteOfTB}');
    childhood = widget.patient.childhood;
    tb = widget.patient.tb;
    pneumonia = widget.patient.pneumonia;
    recurrentPneumonia = widget.patient.recurrentPneumonia;
    dm = widget.patient.dm;
    malnutrition = widget.patient.malnutrition;
    anatomicLocation = widget.patient.siteOfTB;
    sex = widget.patient.sex;
    dateOfBirth = widget.patient.dateOfBirth;
    hivStatus = widget.patient.hiv;
    previousTBDrugUse = widget.patient.previousDrugUse;
    requestedTests = widget.patient.requestedTest;

    selectedRegion = widget.patient.region;
    if (selectedRegion != null && selectedRegion?.zones != null) {
      selectedRegion?.zones.forEach((zone) {
        if (zone.code == widget.patient.zone) {
          selectedZone = zone;
        }
      });
    }

    if (selectedZone != null && selectedZone?.woredas != null) {
      selectedZone?.woredas.forEach((woreda) {
        if (woreda.code == widget.patient.woreda) {
          selectedWoreda = woreda;
        }
      });
    }

    // print(selectedRegion?.toJson());
    // print(selectedZone?.toJson());
    // print(selectedWoreda?.toJson());

    MRController.text = widget.patient.mr ?? '';
    nameController.text = widget.patient.name ?? '';
    ageYearsController.text = widget.patient.age ?? '';
    ageMonthsController.text = widget.patient.ageMonths ?? '';
    zoneController.text = widget.patient.zone ?? '';
    woredaController.text = widget.patient.woreda ?? '';
    addressController.text = widget.patient.address ?? '';
    phoneController.text = widget.patient.phone ?? '';
    doctorInChargeController.text = widget.patient.doctorInCharge ?? '';
    examPurposeController.text = widget.patient.examPurpose ?? '';
    patientRemarkController.text = widget.patient.remark ?? '';

    specimens = [...widget.patient.specimens!];
    if (siteOfTbChoices.contains(widget.patient.siteOfTB)) {
      siteOfTB = widget.patient.siteOfTB;
    } else {
      siteOfTB = 'Other';
      siteOfTBController.text = widget.patient.siteOfTB ?? '';
    }

    if (registrationGroupChoices.contains(widget.patient.registrationGroup)) {
      registrationGroup = widget.patient.registrationGroup;
    } else {
      registrationGroup = 'Other';
      registrationGroupController.text = widget.patient.registrationGroup ?? '';
    }

    if (reasonForTestChoices.contains(widget.patient.reasonForTest)) {
      reasonForTest = widget.patient.reasonForTest;
    } else {
      // reasonForTest = 'Other';
      if (widget.patient.reasonForTest != null &&
          widget.patient.reasonForTest!.contains('after')) {
        reasonForTest = 'At X months after treatment';
        xMonthsAfterController.text = widget.patient.reasonForTest ?? '';
      } else if (widget.patient.reasonForTest != null &&
          widget.patient.reasonForTest!.contains('during')) {
        reasonForTest = 'At X months during treatment';
        xMonthsDuringController.text = widget.patient.reasonForTest ?? '';
      }
    }

    orderBloc.add(LoadSingleOrder(
      orderId: widget.orderId,
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Patient Info'),
        centerTitle: true,
        backgroundColor: kColorsOrangeLight,
        elevation: 0,
      ),
      backgroundColor: kPageBackground,
      body: Align(
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 700,
          ),
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
                    padding: EdgeInsets.only(
                        bottom: 15, left: 25, top: 10, right: 25),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _form,
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
                              hint: 'Enter Patient MR',
                              controller: MRController,
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                            ),
                            _buildInputField(
                                label: 'Name',
                                editable:
                                    !(widget.patient.status == 'Tested') &&
                                        widget.canEdit,
                                hint: 'Enter Patient\'s Name',
                                controller: nameController),
                            _buildInputField(
                              label: 'Age In Years',
                              hint: 'Please enter age in years',
                              required: true,
                              controller: ageYearsController,
                              inputType: TextInputType.numberWithOptions(
                                  signed: false, decimal: false),
                              maxCharacters: 2,
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                            ),

                            ageYearsController.value.text == '0'
                                ? _buildInputField(
                                    label: 'Age In Months',
                                    inputType: TextInputType.numberWithOptions(
                                        signed: false, decimal: false),
                                    maxCharacters: 2,
                                    editable:
                                        !(widget.patient.status == 'Tested') &&
                                            widget.canEdit,
                                    maxValue: 12,
                                    hint: 'Age (Months)...',
                                    controller: ageMonthsController,
                                    required: true)
                                : SizedBox(),
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
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    setState(() {
                                      sex = val;
                                    });
                                  },
                                )),
                              ),
                            ),

                            BlocBuilder<LocationBloc, LocationStates>(
                                builder: (ctx, s) {
                              if (s is LoadingLocationsState) {
                                return CircularProgressIndicator();
                              } else if (s is LoadedLocationsState) {
                                return Column(
                                  children: [
                                    //regions
                                    _labelBuilder(
                                      'Region',
                                      required: true,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton<Region>(
                                        value: selectedRegion,
                                        hint: Text('Region'),
                                        items: s.regions.map((Region value) {
                                          return DropdownMenuItem<Region>(
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            selectedRegion = val;
                                            selectedZone = null;
                                            selectedWoreda = null;
                                          });
                                        },
                                      )),
                                    ),

                                    //zones
                                    _labelBuilder('Zone', required: true),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton<Zone>(
                                        value: selectedZone,
                                        hint: Text('Zones'),
                                        items: selectedRegion?.zones
                                            .map((Zone value) {
                                          return DropdownMenuItem<Zone>(
                                            enabled: !widget
                                                    .patient.resultAvaiable &&
                                                widget.canEdit,
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            selectedZone = val;
                                            selectedWoreda = null;
                                          });
                                        },
                                      )),
                                    ),

                                    //woredas
                                    _labelBuilder('Woredas', required: true),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton<Woreda>(
                                        value: selectedWoreda,
                                        hint: Text('Woredas'),
                                        items: selectedZone?.woredas
                                            .map((Woreda value) {
                                          return DropdownMenuItem<Woreda>(
                                            enabled: !widget
                                                    .patient.resultAvaiable &&
                                                widget.canEdit,
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            selectedWoreda = val;
                                          });
                                        },
                                      )),
                                    ),
                                  ],
                                );
                              }
                              return Text('Not One');
                            }),

                            // _tobLabelBuilder('Address'),

                            // _buildInputField(
                            //     label: 'Address',
                            //     editable: !(widget.patient.status == 'Tested') &&
                            //         widget.canEdit,
                            //     hint: 'Enter Your Address',Please
                            //     controller: addressController),
                            _buildInputField(
                              label: 'Phone',
                              editable: !(widget.patient.status == 'Tested') &&
                                  widget.canEdit,
                              hint: 'Enter Patient\'s Phone',
                              controller: phoneController,
                            ),

                            _tobLabelBuilder('Observation'),

                            _labelBuilder('Site of TB'),

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
                                value: siteOfTB,
                                hint: Text('Site of TB'),
                                items: <String>[
                                  'Pulmonary',
                                  'Extra-pulmonary',
                                  'Other'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    enabled: !widget.patient.resultAvaiable &&
                                        widget.canEdit,
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    siteOfTB = val;
                                  });
                                },
                              )),
                            ),

                            !widget.patient.resultAvaiable &&
                                    widget.canEdit &&
                                    siteOfTB == 'Other'
                                ? TextField(
                                    controller: siteOfTBController,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'Enter site of TB...'),
                                  )
                                : SizedBox(),

                            _labelBuilder('Registration Group'),
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
                                value: registrationGroup,
                                hint: Text('Registration Group'),
                                items: <String>[
                                  'New',
                                  'Relapse',
                                  'After Default',
                                  'After failure of 1st treatment',
                                  'After failure of re treatment',
                                  'Other'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    enabled: !widget.patient.resultAvaiable &&
                                        widget.canEdit,
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    registrationGroup = val;
                                  });
                                },
                              )),
                            ),

                            !widget.patient.resultAvaiable &&
                                    widget.canEdit &&
                                    registrationGroup == 'Other'
                                ? TextField(
                                    controller: registrationGroupController,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText:
                                            'Enter registration group...'),
                                  )
                                : SizedBox(),

                            _labelBuilder('Previous TB Drug use'),
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
                                value: previousTBDrugUse,
                                hint: Text('Previous TB Drug use'),
                                items: <String>[
                                  'New',
                                  'First Line',
                                  'Second Line',
                                  'MDR TB Contact'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    enabled: !widget.patient.resultAvaiable &&
                                        widget.canEdit,
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    previousTBDrugUse = val;
                                  });
                                },
                              )),
                            ),

                            _labelBuilder('Reason for Test'),
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
                                value: reasonForTest,
                                hint: Text('Reason for Test'),
                                items: <String>[
                                  'Diagnostic',
                                  'Presumptive TB',
                                  'Presumptive RR-TB',
                                  'Presumptive MDR-TB',
                                  'At X months during treatment',
                                  'At X months after treatment'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    enabled: !widget.patient.resultAvaiable &&
                                        widget.canEdit,
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    reasonForTest = val;
                                  });
                                },
                              )),
                            ),

                            !widget.patient.resultAvaiable &&
                                    widget.canEdit &&
                                    reasonForTest ==
                                        'At X months during treatment'
                                ? TextField(
                                    controller: xMonthsDuringController,
                                    autofocus: false,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false, signed: false),
                                    decoration: InputDecoration(
                                        hintText:
                                            'X Months during treatment...'),
                                  )
                                : SizedBox(),

                            !widget.patient.resultAvaiable &&
                                    widget.canEdit &&
                                    reasonForTest ==
                                        'At X months after treatment'
                                ? TextField(
                                    controller: xMonthsAfterController,
                                    autofocus: false,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false, signed: false),
                                    decoration: InputDecoration(
                                        hintText:
                                            'X Months after treatment...'),
                                  )
                                : SizedBox(),

                            _labelBuilder('Requested Tests'),
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
                                value: requestedTests,
                                hint: Text('Requested Tests'),
                                items: <String>[
                                  'Microscopy',
                                  'Xpert MTB/RIF test',
                                  'Culture',
                                  'Drug Susceptibility Testing (DST)',
                                  'Line probe assay'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                    enabled: !widget.patient.resultAvaiable &&
                                        widget.canEdit,
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    requestedTests = val;
                                  });
                                },
                              )),
                            ),

                            // buildRemarkField(
                            //   label: 'Remark',
                            //   hint: 'Pateint Remark',
                            //   controller: patientRemarkController,
                            //   editable: !widget.patient.resultAvaiable &&
                            //       widget.canEdit,
                            // ),

                            // _buildInputField(
                            //     label: 'Doctor in charge',
                            //     hint: 'Doctor in charge',
                            //     editable: !(widget.patient.status == 'Tested') &&
                            //         widget.canEdit,
                            //     controller: doctorInChargeController),

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
                                                    return SingleChildScrollView(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: 30,
                                                          left: 20,
                                                          right: 20,
                                                          bottom: MediaQuery.of(
                                                                      ctx)
                                                                  .viewInsets
                                                                  .bottom +
                                                              20,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
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
                                                              width: double
                                                                  .infinity,
                                                              child: Text(
                                                                'Create Specimen',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
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
                                                                      vertical:
                                                                          5),
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                      child: DropdownButton<
                                                                          String>(
                                                                value:
                                                                    specimenType,
                                                                hint: Text(
                                                                    'Specimen Type'),
                                                                items: <String>[
                                                                  'Stool',
                                                                  'Sputum',
                                                                  'Urine',
                                                                  'Blood',
                                                                  'Swab',
                                                                  'Other'
                                                                ].map((String
                                                                    value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    enabled: !widget
                                                                            .patient
                                                                            .resultAvaiable &&
                                                                        widget
                                                                            .canEdit,
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                }).toList(),
                                                                onChanged:
                                                                    (val) {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .requestFocus(
                                                                          FocusNode());
                                                                  ss(() =>
                                                                      1 == 1);

                                                                  setState(() {
                                                                    examinationType =
                                                                        null;
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
                                                                      vertical:
                                                                          5),
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                      child: DropdownButton<
                                                                          String>(
                                                                value:
                                                                    examinationType,
                                                                hint: Text(
                                                                    'Examination Type'),
                                                                items: (examinationTypesList[
                                                                            specimenType] ??
                                                                        [])
                                                                    .map((String
                                                                        value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                }).toList(),
                                                                onChanged:
                                                                    (val) {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .requestFocus(
                                                                          FocusNode());
                                                                  ss(() =>
                                                                      1 == 1);

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
                                                                      // print(specimenType);
                                                                      // print(specimenIdController.value.text);
                                                                      if (specimenIdController.value.text ==
                                                                              '' ||
                                                                          specimenType ==
                                                                              null) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                                                                      setState(
                                                                          () {
                                                                        specimens =
                                                                            [
                                                                          ...specimens,
                                                                          specimen
                                                                        ];
                                                                      });
                                                                      // print(specimens.length);
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
                                                                              BorderRadius.circular(10),
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
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 20,
                                                                                color: Colors.white),
                                                                          ),
                                                                        )))
                                                                : Container(),
                                                          ],
                                                        ),
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
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              widget.canEdit
                                                  ? InkWell(
                                                      onTap: () {
                                                        if (!widget.canEdit) {}
                                                        if (_form.currentState !=
                                                                null &&
                                                            _form.currentState!
                                                                .validate()) {
                                                          if (selectedRegion ==
                                                                  null ||
                                                              selectedZone ==
                                                                  null ||
                                                              selectedWoreda ==
                                                                  null) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text('Please enter zone region and woreda')));
                                                            return;
                                                          }
                                                          if (!validatePhoneNumber(
                                                              phoneController
                                                                  .value.text
                                                                  .trim())) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Please enter a valid phone number: start with 09!',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                backgroundColor:
                                                                    Colors.red
                                                                        .shade700,
                                                              ),
                                                            );
                                                            return;
                                                          }

                                                          String mr =
                                                              MRController
                                                                  .value.text;
                                                          String name =
                                                              nameController
                                                                  .value.text;
                                                          //sex, childhood, pneumonic, tb, r pn, mal, dm, loc
                                                          String age =
                                                              ageYearsController
                                                                  .value.text;
                                                          String ageMonths =
                                                              ageMonthsController
                                                                  .value.text;

                                                          String? zone =
                                                              selectedZone
                                                                  ?.code;
                                                          String? woreda =
                                                              selectedWoreda
                                                                  ?.code;

                                                          String address =
                                                              addressController
                                                                  .value.text;
                                                          String phone =
                                                              phoneController
                                                                  .value.text
                                                                  .trim();
                                                          String
                                                              doctorInCharge =
                                                              doctorInChargeController
                                                                  .value.text;
                                                          String patientRemark =
                                                              patientRemarkController
                                                                  .value.text;

                                                          String? regGroup =
                                                              registrationGroup ==
                                                                      'Other'
                                                                  ? registrationGroupController
                                                                      .value
                                                                      .text
                                                                  : registrationGroup;
                                                          regGroup = regGroup ??
                                                              'Other';

                                                          String? reason = reasonForTest ==
                                                                  'At X months during treatment'
                                                              ? 'At ${xMonthsDuringController.value.text} months during treatment'
                                                              : reasonForTest ==
                                                                      'At X months after treatment'
                                                                  ? 'At ${xMonthsAfterController.value.text} month after treatment'
                                                                  : reasonForTest;
                                                          String? site = siteOfTB ==
                                                                  'Other'
                                                              ? siteOfTBController
                                                                  .value.text
                                                              : siteOfTB;

                                                          Patient patient =
                                                              Patient(
                                                            age: age,
                                                            ageMonths:
                                                                age == '0'
                                                                    ? '0'
                                                                    : ageMonths,
                                                            siteOfTB: site,
                                                            doctorInCharge:
                                                                doctorInCharge,
                                                            phone: phone,
                                                            zone: zone,
                                                            zone_name:
                                                                selectedZone
                                                                    ?.name,
                                                            woreda_name:
                                                                selectedWoreda
                                                                    ?.name,
                                                            region:
                                                                selectedRegion,
                                                            woreda: woreda,
                                                            address: address,
                                                            name: name,
                                                            sex: sex,
                                                            specimens:
                                                                specimens,
                                                            mr: mr,
                                                            remark:
                                                                patientRemark,
                                                            registrationGroup:
                                                                regGroup,
                                                            reasonForTest:
                                                                reason,
                                                            requestedTest:
                                                                requestedTests,
                                                            previousDrugUse:
                                                                previousTBDrugUse,
                                                          );

                                                          orderBloc.add(
                                                              EditPtientInfo(
                                                                  orderId: widget
                                                                      .orderId,
                                                                  patient:
                                                                      patient,
                                                                  index: widget
                                                                      .index));
                                                        }
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              37),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
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
                                                            widget.canEdit
                                                                ? 'Update Information'
                                                                : widget.patient
                                                                        .resultAvaiable
                                                                    ? 'View Result'
                                                                    : 'Add Result',
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
                                                    )
                                                  : Container(),

                                              //view result
                                              // widget.patient.resultAvaiable
                                              //     ? InkWell(
                                              //         onTap: () {
                                              //           Navigator.pushNamed(
                                              //               context,
                                              //               AddTestResultPage
                                              //                   .addTestResultPageRouteName,
                                              //               arguments: {
                                              //                 'orderId':
                                              //                     widget.orderId,
                                              //                 'patient':
                                              //                     widget.patient,
                                              //                 'index':
                                              //                     widget.index,
                                              //                 'canEdit': widget
                                              //                     .canAddResult,
                                              //                 // 'specimen': e,
                                              //               });
                                              //         },
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 37),
                                              //         child: Container(
                                              //           decoration: BoxDecoration(
                                              //             borderRadius:
                                              //                 BorderRadius
                                              //                     .circular(10),
                                              //             color:
                                              //                 kColorsOrangeDark,
                                              //           ),
                                              //           height: 62,
                                              //           // margin: EdgeInsets.all(20),
                                              //           child: Center(
                                              //             child: Text(
                                              //               'View Result',
                                              //               style: TextStyle(
                                              //                   fontWeight:
                                              //                       FontWeight
                                              //                           .bold,
                                              //                   fontSize: 20,
                                              //                   color:
                                              //                       Colors.white),
                                              //             ),
                                              //           ),
                                              //         ),
                                              //       )
                                              //     : Container(),
                                            ],
                                          ),
                                  )
                                : Container(),

                            // widget.patient.resultAvaiable
                            //     ? InkWell(
                            //         onTap: () {
                            //           Navigator.pushNamed(
                            //               context,
                            //               AddTestResultPage
                            //                   .addTestResultPageRouteName,
                            //               arguments: {
                            //                 'orderId': widget.orderId,
                            //                 'patient': widget.patient,
                            //                 'index': widget.index,
                            //                 'canEdit': widget.canAddResult,
                            //               });
                            //         },
                            //         borderRadius: BorderRadius.circular(37),
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(10),
                            //             color: kColorsOrangeDark,
                            //           ),
                            //           height: 62,
                            //           // margin: EdgeInsets.all(20),
                            //           child: Center(
                            //             child: Text(
                            //               'View Result',
                            //               style: TextStyle(
                            //                   fontWeight: FontWeight.bold,
                            //                   fontSize: 20,
                            //                   color: Colors.white),
                            //             ),
                            //           ),
                            //         ),
                            //       )
                            //     : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  bool validatePhoneNumber(String phoneNumber) {
    if (phoneNumber != "") {
      if (phoneNumber[0] == "0") {
        if (phoneNumber.length == 10) {
          if (phoneNumber[1] == "9") {
            return true;
          }
        }
      }
      // else if (phoneNumber[0] == "+") {
      //   if (phoneNumber.length == 13) {
      //     if (phoneNumber.substring(1, 5) == "2519") {
      //       return true;
      //     }
      //   }
      // } else if (phoneNumber[0] == "9") {
      //   if (phoneNumber.length == 9) {
      //     return true;
      //   }
      // }
      else {
        return false;
      }
    } else {
      return false;
    }
    return false;
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
                        !e.rejected
                            ? Text('Accepted : ${e.assessed}')
                            : Container(),
                        e.rejected
                            ? Text('Rejected : ${e.rejected}')
                            : Container(),
                        e.rejected ? Text('Reason : ${e.reason}') : Container(),

                        (state is LoadedSingleOrder &&
                                    state.order.status == 'Received') &&
                                (!e.rejected) &&
                                widget.canAddResult &&
                                (e.testResult == null)
                            ? Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: IconButton(
                                    color: Colors.green,
                                    onPressed: () async {
                                      // debugPrint(e.id);
                                      var success = await Navigator.pushNamed(
                                          context,
                                          AddTestResultPage
                                              .addTestResultPageRouteName,
                                          arguments: {
                                            'orderId': widget.orderId,
                                            'patient': widget.patient,
                                            'index': widget.index,
                                            'canEdit': widget.canAddResult,
                                            'specimen': e,
                                          });

                                      if (success == true) {
                                        orderBloc.add(LoadSingleOrder(
                                          orderId: widget.orderId,
                                        ));
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add,
                                    )),
                              )
                            : SizedBox(),

                        (state is LoadedSingleOrder &&
                                    state.order.status == 'Received') &&
                                (!e.rejected) &&
                                (e.testResult != null)
                            ? Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: IconButton(
                                  color: Colors.green,
                                  onPressed: () async {
                                    // debugPrint(e.id);
                                    var success = await Navigator.pushNamed(
                                        context,
                                        AddTestResultPage
                                            .addTestResultPageRouteName,
                                        arguments: {
                                          'orderId': widget.orderId,
                                          'patient': widget.patient,
                                          'index': widget.index,
                                          'canEdit': widget.canAddResult,
                                          'specimen': e,
                                        });

                                    if (success == true) {
                                      orderBloc.add(LoadSingleOrder(
                                        orderId: widget.orderId,
                                      ));
                                    }
                                  },
                                  icon: Icon(Icons.visibility),
                                ),
                              )
                            : SizedBox(),

                        widget.canAddResult &&
                                (state is LoadedSingleOrder &&
                                    state.order.status == 'Received') &&
                                (e.testResult == null)
                            ? Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: IconButton(
                                  color: Colors.green,
                                  onPressed: () async {
                                    bool create = await showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (ctx) {
                                          return AssessSpecimen(ctx, e);
                                        });

                                    print('I have inited the modal $create');

                                    if (create == true && e.type == 'Sputum') {
                                      e.assessed = true;
                                      e.rejected =
                                          'Mucoid Purulent' != sputumCondition;
                                      e.reason =
                                          'Specimen is in $sputumCondition type. Not Mucoid Purulent.';
                                      // e.specimenCondition = sputumCondition ?? '';

                                      setState(() {
                                        sendingFeedback = true;
                                      });

                                      try {
                                        bool success = await OrderRepository
                                            .editSpecimenFeedback(
                                                index: widget.index,
                                                order: state.order,
                                                patient: state.order
                                                    .patients![widget.index]);
                                        print('Success => $success');

                                        if (success) {
                                          addNotification(
                                            orderId: state.order.orderId!,
                                            testerContent:
                                                'You Accepted Sputum specimen for ${state.order.patients![widget.index].name} from ${state.order.sender_name}',
                                            senderContent:
                                                '${state.order.patients![widget.index].name}\'s Sputum Specimen have accepted by ${state.order.tester_name}.',
                                            content:
                                                'One specimen got accepted by courier!',
                                            courier: false,
                                            testerAction: NotificationAction
                                                .NavigateToOrderDetalTester,
                                            senderAction: NotificationAction
                                                .NavigateToOrderDetalSender,
                                            payload: {
                                              'orderId': widget.orderId
                                            },
                                          );
                                          orderBloc.add(LoadSingleOrder(
                                              orderId: widget.orderId));
                                        }

                                        if ('Mucoid Purulent' !=
                                            sputumCondition) {
                                          addNotification(
                                            orderId: state.order.orderId!,
                                            testerContent:
                                                'You Rejected Sputum specimen for ${state.order.patients![widget.index].name} from ${state.order.sender_name}',
                                            senderContent:
                                                '${state.order.patients![widget.index].name}\'s Sputum Specimen have been rejected by ${state.order.tester_name}.',
                                            content:
                                                'One specimen got rejected by tester!',
                                            courier: false,
                                            testerAction: NotificationAction
                                                .NavigateToOrderDetalTester,
                                            senderAction: NotificationAction
                                                .NavigateToOrderDetalSender,
                                            payload: {
                                              'orderId': widget.orderId
                                            },
                                          );
                                        }

                                        setState(() {
                                          inColdChain = null;
                                          stoolCondition = null;
                                          sputumCondition = null;
                                          sendingFeedback = false;
                                        });
                                      } catch (e) {
                                        print(e);
                                      }
                                    } else if (create == true &&
                                        e.type == 'Stool') {
                                      e.assessed = true;
                                      e.rejected = 'Formed' != stoolCondition;
                                      e.reason =
                                          'Stool Specimen is in $stoolCondition type. Not in Formed State!';

                                      setState(() {
                                        sendingFeedback = true;
                                      });

                                      bool success = await OrderRepository
                                          .editSpecimenFeedback(
                                              index: widget.index,
                                              order: state.order,
                                              patient: state.order
                                                  .patients![widget.index]);
                                      print('Here is not the problem $success');

                                      if (success) {
                                        addNotification(
                                          orderId: state.order.orderId!,
                                          testerContent:
                                              'You Accepted Stool specimen for ${state.order.patients![widget.index].name} from ${state.order.sender_name}',
                                          senderContent:
                                              '${state.order.patients![widget.index].name}\'s Stool Specimen is accepted by ${state.order.tester_name}.',
                                          content:
                                              'One specimen got accepted by tester!',
                                          courier: false,
                                          testerAction: NotificationAction
                                              .NavigateToOrderDetalTester,
                                          senderAction: NotificationAction
                                              .NavigateToOrderDetalSender,
                                          payload: {'orderId': widget.orderId},
                                        );
                                        setState(() {
                                          sendingFeedback = false;
                                        });
                                        orderBloc.add(LoadSingleOrder(
                                            orderId: widget.orderId));
                                      }
                                      if ('Formed' != stoolCondition) {
                                        addNotification(
                                          orderId: state.order.orderId!,
                                          testerContent:
                                              'You Rejected Stool specimen for ${state.order.patients![widget.index].name} from ${state.order.sender_name}',
                                          senderContent:
                                              '${state.order.patients![widget.index].name}\'s Stool Specimen have been rejected by ${state.order.tester_name}.',
                                          content:
                                              'One specimen got rejected by tester!',
                                          courier: false,
                                          courierAction: NotificationAction
                                              .NavigateToOrderDetalCourier,
                                          testerAction: NotificationAction
                                              .NavigateToOrderDetalTester,
                                          senderAction: NotificationAction
                                              .NavigateToOrderDetalSender,
                                          payload: {'orderId': widget.orderId},
                                        );

                                        orderBloc.add(LoadSingleOrder(
                                            orderId: widget.orderId));
                                      }

                                      setState(() {
                                        inColdChain = null;
                                        stoolCondition = null;
                                        sendingFeedback = false;
                                        sputumCondition = null;
                                      });
                                    } else if (create == true &&
                                        e.type == 'Urine') {
                                      e.assessed = true;

                                      e.rejected = false;
                                      e.reason = '';

                                      setState(() {
                                        sendingFeedback = true;
                                      });

                                      bool success = await OrderRepository
                                          .editSpecimenFeedback(
                                              index: widget.index,
                                              order: state.order,
                                              patient: state.order
                                                  .patients![widget.index]);

                                      if (success) {
                                        addNotification(
                                          orderId: state.order.orderId!,
                                          testerContent:
                                              'You Accepted Urine specimen for ${state.order.patients![widget.index].name} from ${state.order.sender_name}',
                                          senderContent:
                                              '${state.order.patients![widget.index].name}\'s Urine Specimen is accepted by ${state.order.tester_name}.',
                                          content:
                                              'One specimen got accepted by courier!',
                                          courier: false,
                                          testerAction: NotificationAction
                                              .NavigateToOrderDetalTester,
                                          senderAction: NotificationAction
                                              .NavigateToOrderDetalSender,
                                          payload: {'orderId': widget.orderId},
                                        );
                                        setState(() {
                                          sendingFeedback = false;
                                        });
                                        orderBloc.add(LoadSingleOrder(
                                            orderId: widget.orderId));
                                      }

                                      setState(() {
                                        inColdChain = null;
                                        stoolCondition = null;
                                        sendingFeedback = false;
                                        sputumCondition = null;
                                      });
                                    } else if (create == true) {
                                      e.assessed = true;

                                      e.rejected = false;
                                      e.reason = '';

                                      setState(() {
                                        sendingFeedback = true;
                                      });

                                      bool success = await OrderRepository
                                          .editSpecimenFeedback(
                                              index: widget.index,
                                              order: state.order,
                                              patient: state.order
                                                  .patients![widget.index]);

                                      if (success) {
                                        addNotification(
                                          orderId: state.order.orderId!,
                                          testerContent:
                                              'You Accepted Urine specimen for ${state.order.patients![widget.index].name} from ${state.order.sender_name}',
                                          senderContent:
                                              '${state.order.patients![widget.index].name}\'s Urine Specimen is accepted by ${state.order.tester_name}.',
                                          content:
                                              'One specimen got accepted by courier!',
                                          courier: false,
                                          testerAction: NotificationAction
                                              .NavigateToOrderDetalTester,
                                          senderAction: NotificationAction
                                              .NavigateToOrderDetalSender,
                                          payload: {'orderId': widget.orderId},
                                        );
                                        setState(() {
                                          sendingFeedback = false;
                                        });
                                        orderBloc.add(LoadSingleOrder(
                                            orderId: widget.orderId));
                                      }

                                      setState(() {
                                        inColdChain = null;
                                        stoolCondition = null;
                                        sendingFeedback = false;
                                        sputumCondition = null;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.tune,
                                  ),
                                ),
                              )
                            : SizedBox(),
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

  Widget _labelBuilder(String label, {bool required = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        '$label ${required ? " *" : ""}',
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
    int? maxCharacters,
    TextInputType inputType = TextInputType.text,
    int? maxValue,
    bool required = false,
    bool editable = true,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            '$label ${required ? '*' : ''}',
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
          child: TextFormField(
            enabled: editable,
            autofocus: false,
            // onEditingComplete: () {
            //   print('Finished editing');
            // },

            onChanged: (_) {
              setState(() {});
            },
            validator: (value) {
              if (!required) {
                return null;
              }
              if (maxValue != null && num.parse(value ?? '') > maxValue) {
                return 'Value cannot exceed ${maxValue}';
              }
              if (value == null || value.isEmpty) {
                return 'Value cannot be empty!';
              }
              return null;
            },
            controller: controller,
            style: TextStyle(color: Colors.black),
            keyboardType: inputType,
            maxLength: maxCharacters,
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
