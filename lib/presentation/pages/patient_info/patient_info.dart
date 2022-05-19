import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';
import 'package:kncv_flutter/service_locator.dart';

class PatientInfoPage extends StatefulWidget {
  final String orderId;
  static const patientInfoPageRouteName = 'patient info page route name';

  const PatientInfoPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<PatientInfoPage> createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  String? childhood = 'Yes';
  String? siteOfTB;
  String? sex = 'Male';
  String? specimenType;
  String? examinationType;
  String? hivStatus;
  String? dateOfBirth;
  String? previousTBDrugUse;
  String? reasonForTest;
  String? registrationGroup;
  String? requestedTests;

  Map<String, List<String>> examinationTypesList = {
    'Stool': ['AFB microscopy', 'GeneXpret', 'Culture', 'LPA', 'DST'],
    'Sputum': ['AFB microscopy', 'GeneXpret', 'Culture', 'LPA', 'DST'],
    'Urine': ['LF LAM'],
    'Blood': ['CD4 Count', 'Viral Load'],
    'Swab': ['GeneXpret'],
    'Other': ['GeneXpret']
  };

  Region? selectedRegion;
  Zone? selectedZone;
  Woreda? selectedWoreda;

  final TextEditingController MRController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageYearsController = TextEditingController();

  final TextEditingController siteOfTBController = TextEditingController();
  final TextEditingController registrationGroupController =
      TextEditingController();

  final TextEditingController xMonthsAfterController = TextEditingController();
  final TextEditingController xMonthsDuringController = TextEditingController();

  final TextEditingController ageMonthsController = TextEditingController();
  // final TextEditingController zoneController = TextEditingController();
  // final TextEditingController woredaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController patientRemarkController = TextEditingController();
  final TextEditingController doctorInChargeController =
      TextEditingController();
  final TextEditingController examPurposeController = TextEditingController();

  final TextEditingController specimenIdController = TextEditingController();

  List<Specimen> specimens = [];

  GlobalKey<FormState> _form = GlobalKey<FormState>();

  OrderBloc orderBloc = sl<OrderBloc>();

  @override
  void initState() {
    orderBloc.add(LoadSingleOrder(
      orderId: widget.orderId,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: AppBar(
        title: Text('Patient Info'),
        centerTitle: true,
        backgroundColor: kColorsOrangeLight,
        elevation: 0,
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(maxWidth: 700),
          height: double.infinity,
      
          child: BlocConsumer<OrderBloc, OrderState>(
              bloc: orderBloc,
              listener: (ctx, state) async {
                if (state is AddedPatient) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Added Patient!')));
                  await Future.delayed(Duration(seconds: 1));
                  Navigator.pop(
                    context,
                    true,
                  );
                }
                if (state is ErrorState) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('${state.message}')));
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: Container(
                    padding:
                        EdgeInsets.only(bottom: 15, left: 25, top: 10, right: 25),
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
                                'Add Patient',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.w500),
                              ),
                            ),
                            _tobLabelBuilder('Basic Info'),
                            _buildInputField(
                              label: 'MRN',
                              hint: 'Enter Patient\'s MRN',
                              controller: MRController,
                              required: true,
                            ),
                            _buildInputField(
                                label: 'Name',
                                hint: 'Enter Patient\'s Name',
                                controller: nameController,
                                required: true),
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
      
                            _buildInputField(
                                label: 'Age in Years',
                                inputType: TextInputType.numberWithOptions(
                                    signed: false, decimal: false),
                                maxCharacters: 2,
                                hint: 'Age (Years)...',
                                controller: ageYearsController,
                                required: true),
      
                            ageYearsController.value.text == '0'
                                ? _buildInputField(
                                    label: 'Age in Months',
                                    inputType: TextInputType.numberWithOptions(
                                        signed: false, decimal: false),
                                    maxCharacters: 2,
                                    maxValue: 12,
                                    hint: 'Age (Months)...',
                                    controller: ageMonthsController,
                                    required: true)
                                : SizedBox(),
      
                            BlocBuilder<LocationBloc, LocationStates>(
                                builder: (ctx, s) {
                              if (s is LoadingLocationsState) {
                                return CircularProgressIndicator();
                              } else if (s is LoadedLocationsState) {
                                return Column(
                                  children: [
                                    //regions
                                    _labelBuilder('Region', required: true),
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
                                    _labelBuilder('Woreda', required: true),
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
                            //   label: 'Zone',
                            //   hint: 'Enter Your Zone',
                            //   controller: zoneController,
                            //   required: true,
                            // ),
                            // _buildInputField(
                            //   label: 'Woreda',
                            //   hint: 'Enter Your Woreda',
                            //   controller: woredaController,
                            //   required: true,
                            // ),
                            // _buildInputField(
                            //   label: 'Address',
                            //   hint: 'Enter Your Address',
                            //   controller: addressController,
                            //   required: true,
                            // ),
                            _buildInputField(
                              label: 'Phone',
                              hint: 'Enter Your Phone',
                              inputType: TextInputType.phone,
                              controller: phoneController,
                            ),
      
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
      
                            registrationGroup == 'Other'
                                ? TextField(
                                    controller: registrationGroupController,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'Enter registration group...'),
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
      
                            reasonForTest == 'At X months during treatment'
                                ? TextField(
                                    controller: xMonthsDuringController,
                                    autofocus: false,
                                    keyboardType: TextInputType.numberWithOptions(
                                        decimal: false, signed: false),
                                    decoration: InputDecoration(
                                        hintText: 'X Months during treatment...'),
                                  )
                                : SizedBox(),
      
                            reasonForTest == 'At X months after treatment'
                                ? TextField(
                                    controller: xMonthsAfterController,
                                    autofocus: false,
                                    keyboardType: TextInputType.numberWithOptions(
                                        decimal: false, signed: false),
                                    decoration: InputDecoration(
                                        hintText: 'X Months after treatment...'),
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
                            // ),
      
                            // _buildInputField(
                            //     label: 'Doctor in charge',
                            //     hint: 'Doctor in charge',
                            //     controller: doctorInChargeController),
      
                            // _buildInputField(
                            //   label: 'Exam Purpose',
                            //   hint: 'Please enter exam pupose',
                            //   controller: examPurposeController,
                            //   required: true,
                            // ),
      
                            SizedBox(
                              height: 15,
                            ),
      
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (ctx) {
                                      return StatefulBuilder(builder: (ctx, ss) {
                                        return SingleChildScrollView(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                              top: 30,
                                              left: 20,
                                              right: 20,
                                              bottom: MediaQuery.of(ctx)
                                                      .viewInsets
                                                      .bottom +
                                                  20,
                                            ),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    'Create Specimen',
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
                                                _buildInputField(
                                                    label: 'Specimen ID',
                                                    hint:
                                                        "Please enter specimen ID",
                                                    controller:
                                                        specimenIdController),
                                                _labelBuilder('Specimen Type'),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(7),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                    value: specimenType,
                                                    hint: Text('Specimen Type'),
                                                    items: <String>[
                                                      'Stool',
                                                      'Sputum',
                                                      'Urine',
                                                      'Blood',
                                                      'Swab',
                                                      'Other'
                                                    ].map((String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              FocusNode());
                                                      ss(() => 1 == 1);
      
                                                      setState(() {
                                                        examinationType = null;
                                                        specimenType = val;
                                                      });
                                                    },
                                                  )),
                                                ),
                                                _labelBuilder('Examination Type'),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(7),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                    value: examinationType,
                                                    hint:
                                                        Text('Examination Type'),
                                                    items: (examinationTypesList[
                                                                specimenType] ??
                                                            [])
                                                        .map((String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              FocusNode());
                                                      ss(() => 1 == 1);
      
                                                      setState(() {
                                                        examinationType = val;
                                                      });
                                                    },
                                                  )),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      print(specimenType);
                                                      print(specimenIdController
                                                          .value.text);
                                                      if (specimenIdController
                                                                  .value.text ==
                                                              '' ||
                                                          specimenType == null ||
                                                          examinationType ==
                                                              null) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'Please enter complete information')));
                                                        Navigator.pop(context);
                                                        return;
                                                      }
      
                                                      if (specimenExists(
                                                          specimens,
                                                          specimenIdController
                                                              .value.text,
                                                          specimenType!)) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'This specimen is already added please try editing fields.')));
                                                        Navigator.pop(context);
                                                        return;
                                                      }
      
                                                      Specimen specimen =
                                                          Specimen(
                                                        id: specimenIdController
                                                            .value.text,
                                                        type: specimenType,
                                                        examinationType:
                                                            examinationType,
                                                      );
                                                      setState(() {
                                                        specimens = [
                                                          ...specimens,
                                                          specimen
                                                        ];
                                                      });
                                                      specimenIdController.text =
                                                          '';
                                                      specimenType = null;
                                                      examinationType = null;
                                                      Navigator.pop(context);
                                                      return;
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
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
                                                            'Add Specimen',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color:
                                                                    Colors.white),
                                                          ),
                                                        ))),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                    });
                              },
                              child: Container(
                                width: double.infinity,
                                height: 110,
                                color: Colors.grey.withOpacity(0.3),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            ),
      
                            SizedBox(
                              height: 15,
                            ),
      
                            _labelBuilder('Specimens'),
      
                            getSpecimensFromState(state),
      
                            SizedBox(
                              height: 15,
                            ),
      
                            Container(
                              // padding: EdgeInsets.all(10),
                              color: kPageBackground,
                              child: state is AddingPatient
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        if (_form.currentState!.validate()) {
                                          if (selectedRegion == null ||
                                              selectedZone == null ||
                                              selectedWoreda == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Please enter zone region and woreda')));
                                            return;
                                          }
                                          String mr = MRController.value.text;
                                          String name = nameController.value.text;
                                          //sex, childhood, pneumonic, tb, r pn, mal, dm, loc
                                          String age =
                                              ageYearsController.value.text;
                                          String ageMonths =
                                              ageMonthsController.value.text;
      
                                          String? zone = selectedZone?.code;
                                          String? woreda = selectedWoreda?.code;
      
                                          String address =
                                              addressController.value.text;
                                          String phone =
                                              phoneController.value.text;
                                          String doctorInCharge =
                                              doctorInChargeController.value.text;
                                          String patientRemark =
                                              patientRemarkController.value.text;
      
                                          String? regGroup =
                                              registrationGroup == 'Other'
                                                  ? registrationGroupController
                                                      .value.text
                                                  : registrationGroup;
                                          regGroup = regGroup ?? 'Other';
      
                                          String? reason = reasonForTest ==
                                                  'At X months during treatment'
                                              ? 'At ${xMonthsDuringController.value.text} months during treatment'
                                              : reasonForTest ==
                                                      'At X months after treatment'
                                                  ? 'At ${xMonthsAfterController.value.text} month after treatment'
                                                  : reasonForTest;
                                          String? site = siteOfTB == 'Other'
                                              ? siteOfTBController.value.text
                                              : siteOfTB;
      
                                          Patient patient = Patient(
                                            age: age,
                                            ageMonths:
                                                age == '0' ? '0' : ageMonths,
                                            siteOfTB: site,
                                            doctorInCharge: doctorInCharge,
                                            phone: phone,
                                            zone: zone,
                                            woreda: woreda,
                                            zone_name: selectedZone?.name,
                                            woreda_name: selectedWoreda?.name,
                                            region: selectedRegion,
                                            address: address,
                                            name: name,
                                            sex: sex,
                                            specimens: specimens,
                                            mr: mr,
                                            remark: patientRemark,
                                            registrationGroup: regGroup,
                                            reasonForTest: reason,
                                            requestedTest: requestedTests,
                                            previousDrugUse: previousTBDrugUse,
                                          );
      
                                          orderBloc.add(AddPatientToOrder(
                                              orderId: widget.orderId,
                                              patient: patient));
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
                                            'Add Patient',
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
                      ),
                    ),
                  ),
                );
              }),
        ),
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
            onChanged: (_) {
              setState(() {});
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

Widget buildRemarkField({
  required String label,
  required String hint,
  required TextEditingController controller,
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
          keyboardType: TextInputType.multiline,
          autofocus: false,
          maxLines: null,
          enabled: editable,
          validator: (value) {
            if (!required) {
              return null;
            }
            if (value == null || value.isEmpty) {
              return 'Value cannot be empty!';
            }
            return null;
          },
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

int calculateAge(DateTime birthDate) {
  DateTime currentDate = DateTime.now();
  int age = currentDate.year - birthDate.year;
  int month1 = currentDate.month;
  int month2 = birthDate.month;
  if (month2 > month1) {
    age--;
  } else if (month1 == month2) {
    int day1 = currentDate.day;
    int day2 = birthDate.day;
    if (day2 > day1) {
      age--;
    }
  }
  return age;
}

bool specimenExists(List<Specimen> specimens, String id, String type) {
  for (var specimen in specimens) {
    if (specimen.id == id && specimen.type == type) {
      return true;
    }
  }
  return false;
}
