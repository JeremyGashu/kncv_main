import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:kncv_flutter/core/colors.dart';
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
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.max,
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
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
                        'Age : ${patient.age ?? ''}',
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
                        'Zone : ${patient.zone ?? ''}',
                        style: pw.TextStyle(
                          // color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Woreda : ${patient.woreda ?? ''}',
                        style: pw.TextStyle(
                          // color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(
                        height: 10,
                      ),
                      pw.Text('Specimen Info',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'MR : ${patient.mr ?? ''}',
                        style: pw.TextStyle(
                          // color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Anatomic Location : ${patient.anatomicLocation ?? ''}',
                        style: pw.TextStyle(
                          // color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'DM : ${patient.dm ?? ''}',
                        style: pw.TextStyle(
                          // color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Malnutrition : ${patient.malnutrition ?? ''}',
                        style: pw.TextStyle(
                          // color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Pneumonia : ${patient.recurrentPneumonia ?? ''}',
                        style: pw.TextStyle(
                          // color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Patient Test Result',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
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
                        'Result RR : ${patient.testResult?.resultRr ?? ''}',
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
                    ],
                  ),
                ],
              ),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      'Age : ${patient.age ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10),
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
                    Text('Specimen Info',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      'MR : ${patient.mr ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Anatomic Location : ${patient.anatomicLocation ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'DM : ${patient.dm ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Malnutrition : ${patient.malnutrition ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pneumonia : ${patient.recurrentPneumonia ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patient Test Result',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      'Lab Reg No : ${patient.testResult?.labRegistratinNumber ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'MTB Result : ${patient.testResult?.mtbResult ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Quantity: ${patient.testResult?.quantity ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Result Date : ${patient.testResult?.resultDate ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Result RR : ${patient.testResult?.resultRr ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Time : ${patient.testResult?.resultTime ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
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
