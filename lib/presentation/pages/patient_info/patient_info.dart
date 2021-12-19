import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';
import 'package:kncv_flutter/presentation/blocs/orders/orders_bloc.dart';

class PatientInfoPage extends StatefulWidget {
  final String orderId;
  static const patientInfoPageRouteName = 'patient info page route name';

  const PatientInfoPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<PatientInfoPage> createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  String? childhood;
  String? tb;
  String? pneumonia;
  String? recurrentPneumonia;
  String? dm;
  String? malnutrition;
  String? anatomicLocation;
  String? sex;
  // String? childhood;
  final TextEditingController MRController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController woredaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController doctorInChargeController =
      TextEditingController();
  final TextEditingController examPurposeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child:
            BlocConsumer<OrderBloc, OrderState>(listener: (ctx, state) async {
          if (state is AddedPatient) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Added Patient!')));
            await Future.delayed(Duration(seconds: 1));
            Navigator.pop(context, true);
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Errro Adding Patient!')));
            await Future.delayed(Duration(seconds: 1));
          }
        }, builder: (context, state) {
          return Stack(
            children: [
              SafeArea(
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: 100, left: 25, top: 10, right: 25),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //controller, hint, label,
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Patient Info',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w500),
                          ),
                        ),
                        _tobLabelBuilder('Basic Info'),
                        _buildInputField(
                            label: 'MR',
                            hint: 'Enter Your MR',
                            controller: MRController),
                        _buildInputField(
                            label: 'Name',
                            hint: 'Enter Your Name',
                            controller: nameController),
                        _labelBuilder('Sex'),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                            value: sex,
                            hint: Text('Sex'),
                            items:
                                <String>['Male', 'Female'].map((String value) {
                              return DropdownMenuItem<String>(
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
                        _buildInputField(
                            label: 'Age',
                            hint: 'Enter Your Age',
                            controller: ageController),
                        _tobLabelBuilder('Address'),
                        _buildInputField(
                            label: 'Zone',
                            hint: 'Enter Your Zone',
                            controller: zoneController),
                        _buildInputField(
                            label: 'Woreda',
                            hint: 'Enter Your Woreda',
                            controller: woredaController),
                        _buildInputField(
                            label: 'Address',
                            hint: 'Enter Your Address',
                            controller: addressController),
                        _buildInputField(
                            label: 'Phone',
                            hint: 'Enter Your Phone',
                            controller: phoneController),

                        _tobLabelBuilder('Observation'),

                        _labelBuilder('Childhood'),

                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                            value: childhood,
                            hint: Text('Childhood'),
                            items: <String>['Yes', 'No'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                childhood = val;
                              });
                            },
                          )),
                        ),
                        _labelBuilder('Pneumonia'),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

                        _tobLabelBuilder('Specimen Purpose'),
                        _labelBuilder('Anatomic Location'),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            controller: doctorInChargeController),

                        _buildInputField(
                            label: 'Exam Purpose',
                            hint: 'Please enter exam pupose',
                            controller: examPurposeController),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: kPageBackground,
                  child: state is AddingPatient
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : InkWell(
                          onTap: () {
                            String mr = MRController.value.text;
                            String name = nameController.value.text;
                            //sex, childhood, pneumonic, tb, r pn, mal, dm, loc
                            String age = ageController.value.text;
                            String zone = zoneController.value.text;
                            String woreda = woredaController.value.text;
                            String address = addressController.value.text;
                            String phone = phoneController.value.text;
                            String doctorInCharge =
                                doctorInChargeController.value.text;
                            String examinatinPurpose =
                                examPurposeController.value.text;
                            Patient patient = Patient(
                                age: age,
                                anatomicLocation: anatomicLocation,
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
                                pneumonia: pneumonia,
                                tb: tb,
                                recurrentPneumonia: recurrentPneumonia,
                                mr: mr);

                            BlocProvider.of<OrderBloc>(context).add(
                                AddPatientToOrder(
                                    orderId: widget.orderId, patient: patient));
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
              ),
            ],
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
            style: TextStyle(color: Colors.black45),
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
