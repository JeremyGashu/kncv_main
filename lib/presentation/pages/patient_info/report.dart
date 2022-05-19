import 'package:flutter/material.dart';

import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/core/get_areainfo.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPage extends StatelessWidget {
  final Patient patient;

  static const String reportPage = 'report page route name';

  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  ReportPage({required this.patient});

  void _printScreen() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(top: 50, left: 20, right: 20),
              child: pw.Column(children: [
                pw.Container(
                  // width: double.infinity,
                  child: pw.Text('Test Result for ${patient.name}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 25)),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.max,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Patient Info',
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Name : ${patient.name ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Date of Birth : ${patient.dateOfBirth ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Sex : ${patient.sex ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Address : ${patient.address ?? ''}',
                          style: pw.TextStyle(
                            // color: pw.Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Phone : ${patient.phone ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Region : ${getAreaInfo(patient.region, patient.zone, patient.woreda)['region'] ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Zone : ${getAreaInfo(patient.region, patient.zone, patient.woreda)['zone'] ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Zone : ${getAreaInfo(patient.region, patient.zone, patient.woreda)['woreda'] ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(
                          height: 10,
                        ),
                        pw.Text('Patient History',
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                          'Reason For Test : ${patient.reasonForTest ?? ''}',
                          style: pw.TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Site Of TB : ${patient.siteOfTB ?? ''}',
                          style: pw.TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Registered Group : ${patient.registrationGroup ?? ''}',
                          style: pw.TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Requested Tests : ${patient.requestedTest ?? ''}',
                          style: pw.TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Previous TB Drug Use : ${patient.previousDrugUse ?? ''}',
                          style: pw.TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Remark : ${patient.remark ?? ''}',
                          style: pw.TextStyle(
                            // color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: patient.specimens?.map((e) {
                            return pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('Patient Test Result',
                                      style: pw.TextStyle(
                                          fontSize: 20,
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 10),
                                  pw.Text(
                                    'Specimen Type ${e.type}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                  pw.Text(
                                    'Specimen ID : ${e.id}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                  pw.Text(
                                    'Lab Reg No : ${patient.testResult?.labRegistratinNumber ?? ''}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                  pw.Text(
                                    'MTB Result : ${patient.testResult?.mtbResult ?? ''}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                  pw.Text(
                                    'Quantity: ${patient.testResult?.quantity ?? ''}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                  pw.Text(
                                    'Result Date : ${patient.testResult?.resultDate ?? ''}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                  pw.Text(
                                    'Time : ${patient.testResult?.resultTime ?? ''}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                  pw.Text(
                                    'Result RR : ${patient.testResult?.resultRr ?? ''}',
                                    style: pw.TextStyle(
                                      // color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    height: 10,
                                  ),
                                ]);
                          }).toList() ??
                          [],
                    ),
                  ],
                ),
              ]),
            );
          }));

      return doc.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: _printKey,
        child: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              constraints: BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient Info',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text(
                            'Name : ${patient.name ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Age In Years: ${patient.age ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Age In Months: ${patient.ageMonths ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // SizedBox(height: 10),
                          Text(
                            'Sex : ${patient.sex ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Address : ${patient.address ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Phone : ${patient.phone ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Zone : ${patient.zone ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Woreda : ${patient.woreda ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Patient History',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text(
                            'Reason For Test : ${patient.reasonForTest ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Site Of TB : ${patient.siteOfTB ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Registered Group : ${patient.registrationGroup ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Requested Tests : ${patient.requestedTest ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Previous TB Drug Use : ${patient.previousDrugUse ?? ''}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
          
                          Text(
                            'Remark : ${patient.remark ?? ''}',
                            style: TextStyle(
                              // color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: patient.specimens?.map((specimen) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Patient Test Result',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text(
                                    'Speciemen : ${specimen.type}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Speciemen ID : ${specimen.id}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Lab Reg No : ${specimen.testResult?.labRegistratinNumber ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'MTB Result : ${specimen.testResult?.mtbResult ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Quantity: ${specimen.testResult?.quantity ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Result RR : ${specimen.testResult?.resultRr ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Result Date : ${specimen.testResult?.resultDate ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Time : ${specimen.testResult?.resultTime ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                            }).toList() ??
                            [],
                        // children: [
                        //   patient.specimens.map(val => Text('')).toList(),
                        //   Text('Patient Test Result',
                        //       style: TextStyle(
                        //           fontSize: 20, fontWeight: FontWeight.bold)),
                        //   SizedBox(height: 10),
                        //   Text(
                        //     'Lab Reg No : ${patient.testResult?.labRegistratinNumber ?? ''}',
                        //     style: TextStyle(
                        //       color: Colors.black87,
                        //       fontSize: 13,
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 10,
                        //   ),
                        //   Text(
                        //     'MTB Result : ${patient.testResult?.mtbResult ?? ''}',
                        //     style: TextStyle(
                        //       color: Colors.black87,
                        //       fontSize: 13,
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 10,
                        //   ),
                        //   Text(
                        //     'Quantity: ${patient.testResult?.quantity ?? ''}',
                        //     style: TextStyle(
                        //       color: Colors.black87,
                        //       fontSize: 13,
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 10,
                        //   ),
                        //   Text(
                        //     'Result Date : ${patient.testResult?.resultDate ?? ''}',
                        //     style: TextStyle(
                        //       color: Colors.black87,
                        //       fontSize: 13,
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 10,
                        //   ),
                        //   Text(
                        //     'Result RR : ${patient.testResult?.resultRr ?? ''}',
                        //     style: TextStyle(
                        //       color: Colors.black87,
                        //       fontSize: 13,
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 10,
                        //   ),
                        //   Text(
                        //     'Time : ${patient.testResult?.resultTime ?? ''}',
                        //     style: TextStyle(
                        //       color: Colors.black87,
                        //       fontSize: 13,
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 10,
                        //   ),
                        // ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        backgroundColor: kColorsOrangeLight,
        onPressed: _printScreen,
      ),
    );
  }
}
