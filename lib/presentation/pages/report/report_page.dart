import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:download/download.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kncv_flutter/presentation/pages/report/report_controller.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/colors.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsx;

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

enum reportType { orderMonitoringReport, specimenReferralReport, shipmentReport }

class _ReportScreenState extends State<ReportScreen> {
  bool loadingReports = true;
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  DateTime? filterStartDate = DateTime(2000, 1, 1);
  DateTime? filterEndDate = DateTime.now();
  String selectedFilter = 'All';
  int totalSpecimens = 0;
  Map<String, dynamic> summaryData = {
    'totalRequestedOrders': null,
    'ordersWaitingPickup': null,
    'ordersEnRoute': null,
    'ordersDeliveredAccepted': null,
    'orderDeliveredAcceptedPercentage': null,
    'ordersDeliveredRejected': null,
    'orderDeliveredRejectedPercentage': null,
    'ordersDeliveredTestResultSent': null,
    //!specimens
    'resultsTotalSent': null,
    'resultsTotalPositive': null,
    'resultsTotalNegative': null,
  };

  //

  @override
  void initState() {
    //!get firebase user id
    getReports();
    super.initState();
  }

  //!order monitoring
  void exportOrderMonitoringReport(List<Map<String, dynamic>> reportsData) {
    List<Map<String, dynamic>> filteredReportsData = getFilteredReports(reportsData);
    // print('filtered reports $filteredReportsData');

// Create a new Excel document.
    final xlsx.Workbook workbook = new xlsx.Workbook();
//Accessing worksheet via index.
    final xlsx.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Order No');
    sheet.getRangeByName('B1').setText('Referring Health Facility');
    sheet.getRangeByName('C1').setText('Courier Name');
    sheet.getRangeByName('D1').setText('Testing Health Facility');
    sheet.getRangeByName('E1').setText('Region');
    sheet.getRangeByName('F1').setText('Zone/Sub City');
    sheet.getRangeByName('G1').setText('Woreda');
    sheet.getRangeByName('H1').setText('Number of Sample');
    sheet.getRangeByName('I1').setText('Order Created');
    sheet.getRangeByName('J1').setText('Order Status');

    for (int i = 0; i < filteredReportsData.length; i++) {
      sheet.getRangeByName('A${i + 2}').setText(filteredReportsData[i]['orderId'].toString());
      sheet.getRangeByName('B${i + 2}').setText(filteredReportsData[i]['sender_name'].toString());
      sheet.getRangeByName('C${i + 2}').setText(filteredReportsData[i]['courier_name'].toString());
      sheet.getRangeByName('D${i + 2}').setText(filteredReportsData[i]['tester_name'].toString());
      sheet.getRangeByName('E${i + 2}').setText(filteredReportsData[i]['region']['name'].toString());
      sheet.getRangeByName('F${i + 2}').setText(filteredReportsData[i]['region']['zones'][0]['name'].toString());
      sheet.getRangeByName('G${i + 2}').setText(filteredReportsData[i]['region']['zones'][0]['woredas'][0]['name'].toString());
      // sheet
      //     .getRangeByName('H${i + 2}')
      //     .setText(filteredReportsData[i]['patients'] != null ? filteredReportsData[i]['patients'].length.toString() : '0');
      sheet
          .getRangeByName('H${i + 2}')
          .setText(filteredReportsData[i]['patients'] != null ? getOrderSpecimenCount(filteredReportsData[i]).toString() : '0');
      sheet.getRangeByName('I${i + 2}').setText(filteredReportsData[i]['order_created'].toDate().day.toString() +
          '/' +
          filteredReportsData[i]['order_created'].toDate().month.toString() +
          '/' +
          filteredReportsData[i]['order_created'].toDate().year.toString());
      sheet.getRangeByName('J${i + 2}').setText(filteredReportsData[i]['status'].toString());
    }
    final List<int> bytes = workbook.saveAsStream();
    String date = DateTime.now().toString();
    String outPutFileName = 'Order_Monitoring_Report_$date.xlsx';
    downloadXlsXFile(outPutFileName, bytes);
    workbook.dispose();
  }

  //!specimen referral
  void exportSpecimenReferralReport(List<Map<String, dynamic>> reportsData) {
    final xlsx.Workbook workbook = new xlsx.Workbook();
//Accessing worksheet via index.
    final xlsx.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Order ID');
    sheet.getRangeByName('B1').setText('Courier Name');
    sheet.getRangeByName('C1').setText('Referring Health Facility');
    sheet.getRangeByName('D1').setText('Testing Health Facility');
    sheet.getRangeByName('E1').setText('Order Created');
    sheet.getRangeByName('F1').setText('Patient\'s Name');
    sheet.getRangeByName('G1').setText('MRN');
    sheet.getRangeByName('H1').setText('Sex');
    sheet.getRangeByName('I1').setText('Age');
    sheet.getRangeByName('J1').setText('Age(Months)');
    sheet.getRangeByName('K1').setText('Phone');
    sheet.getRangeByName('L1').setText('Region');
    sheet.getRangeByName('M1').setText('Zone');
    sheet.getRangeByName('N1').setText('Woreda');
    sheet.getRangeByName('O1').setText('Specimen Type');
    sheet.getRangeByName('P1').setText('Site of Test');
    sheet.getRangeByName('Q1').setText('Requested Test');
    sheet.getRangeByName('R1').setText('Reason for Test');
    sheet.getRangeByName('S1').setText('Registration Group');
    sheet.getRangeByName('T1').setText('Delivery Status');
    sheet.getRangeByName('U1').setText('Turn around Time');
    sheet.getRangeByName('V1').setText('MTB Result');
    sheet.getRangeByName('W1').setText('RR Result');
    sheet.getRangeByName('X1').setText('Lab Registration Number');

    List<Map<String, dynamic>> finalData = getDataForSpecimenReferralReport(reportsData);
    for (int i = 0; i < finalData.length; i++) {
      sheet.getRangeByName('A${i + 2}').setText(finalData[i]['orderId'].toString());
      sheet.getRangeByName('B${i + 2}').setText(finalData[i]['courier_name'].toString());
      sheet.getRangeByName('C${i + 2}').setText(finalData[i]['sender_name'].toString());
      sheet.getRangeByName('D${i + 2}').setText(finalData[i]['tester_name'].toString());
      sheet.getRangeByName('E${i + 2}').setText(finalData[i]['order_created'].toString());
      sheet.getRangeByName('F${i + 2}').setText(finalData[i]['patientName'].toString());
      sheet.getRangeByName('G${i + 2}').setText(finalData[i]['mrn'].toString());
      sheet.getRangeByName('H${i + 2}').setText(finalData[i]['sex'].toString());
      sheet.getRangeByName('I${i + 2}').setText(finalData[i]['age'].toString());
      sheet.getRangeByName('J${i + 2}').setText(finalData[i]['ageInMonths'].toString());
      sheet.getRangeByName('K${i + 2}').setText(finalData[i]['phone'].toString());
      sheet.getRangeByName('L${i + 2}').setText(finalData[i]['region'].toString());
      sheet.getRangeByName('M${i + 2}').setText(finalData[i]['zone'].toString());
      sheet.getRangeByName('N${i + 2}').setText(finalData[i]['woreda'].toString());
      sheet.getRangeByName('O${i + 2}').setText(finalData[i]['specimenType'].toString());
      sheet.getRangeByName('P${i + 2}').setText(finalData[i]['siteOfTest'].toString());
      sheet.getRangeByName('Q${i + 2}').setText(finalData[i]['requestedTest'].toString());
      sheet.getRangeByName('R${i + 2}').setText(finalData[i]['reasonForTest'].toString());
      sheet.getRangeByName('S${i + 2}').setText(finalData[i]['registrationGroup'].toString());
      sheet.getRangeByName('T${i + 2}').setText(finalData[i]['deliveryStatus'].toString());
      sheet.getRangeByName('U${i + 2}').setText(finalData[i]['turnAroundTime'].toString());
      sheet.getRangeByName('V${i + 2}').setText(finalData[i]['mtb_result'].toString());
      sheet.getRangeByName('W${i + 2}').setText(finalData[i]['result_rr'].toString());
      sheet.getRangeByName('X${i + 2}').setText(finalData[i]['lab_registration_number'].toString());
      //TODO: add the remaining column data

    }
    final List<int> bytes = workbook.saveAsStream();
    String date = DateTime.now().toString();
    String outPutFileName = 'Specimen_Referral_Report_$date.xlsx';
    downloadXlsXFile(outPutFileName, bytes);
    workbook.dispose();
  }

  //!Shipment report
  void exportShipmentReport(List<Map<String, dynamic>> reportsData) {
    List<Map<String, dynamic>> filteredReportsData = getFilteredReports(reportsData);
    print('filtered reports $filteredReportsData');
// Create a new Excel document.
    final xlsx.Workbook workbook = new xlsx.Workbook();
//Accessing worksheet via index.
    final xlsx.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Order ID');
    sheet.getRangeByName('B1').setText('Pick up Site');
    sheet.getRangeByName('C1').setText('Region');
    sheet.getRangeByName('D1').setText('Zone');
    sheet.getRangeByName('E1').setText('Woreda');
    sheet.getRangeByName('F1').setText('Courier Name');
    sheet.getRangeByName('G1').setText('Recipient Site');
    sheet.getRangeByName('H1').setText('Number of Patients');
    sheet.getRangeByName('I1').setText('Order Created');
    sheet.getRangeByName('J1').setText('Order Accepted');
    sheet.getRangeByName('K1').setText('Shipment Duration');

    for (int i = 0; i < filteredReportsData.length; i++) {
      DateTime? orderReceived;
      DateTime? orderPickedUp;
      int? shipmentDurationInMinutes;
      if (filteredReportsData[i]['order_received'] != null) {
        orderReceived = filteredReportsData[i]['order_received'].toDate();
      }
      if (filteredReportsData[i]['order_pickedup'] != null) {
        orderPickedUp = filteredReportsData[i]['order_pickedup'].toDate();
      }

      if (orderReceived != null && orderPickedUp != null) {
        shipmentDurationInMinutes = orderReceived.difference(orderPickedUp).inMinutes;
      }
      sheet.getRangeByName('A${i + 2}').setText(filteredReportsData[i]['orderId'].toString());
      sheet.getRangeByName('B${i + 2}').setText(filteredReportsData[i]['sender_name'].toString());
      sheet.getRangeByName('C${i + 2}').setText(filteredReportsData[i]['region']['name'].toString());
      sheet.getRangeByName('D${i + 2}').setText(filteredReportsData[i]['region']['zones'][0]['name'].toString());
      sheet.getRangeByName('E${i + 2}').setText(filteredReportsData[i]['region']['zones'][0]['woredas'][0]['name'].toString());
      sheet.getRangeByName('F${i + 2}').setText(filteredReportsData[i]['courier_name'].toString());
      sheet.getRangeByName('G${i + 2}').setText(filteredReportsData[i]['tester_name'].toString());
      sheet
          .getRangeByName('H${i + 2}')
          .setText(filteredReportsData[i]['patients'] != null ? filteredReportsData[i]['patients'].length.toString() : '0');
      sheet.getRangeByName('I${i + 2}').setText(filteredReportsData[i]['order_created'].toDate().day.toString() +
          '/' +
          filteredReportsData[i]['order_created'].toDate().month.toString() +
          '/' +
          filteredReportsData[i]['order_created'].toDate().year.toString());
      orderReceived == null
          ? sheet.getRangeByName('J${i + 2}').setText('N/A')
          : sheet
              .getRangeByName('J${i + 2}')
              .setText(orderReceived.day.toString() + '/' + orderReceived.month.toString() + '/' + orderReceived.year.toString());
      shipmentDurationInMinutes == null
          ? sheet.getRangeByName('K${i + 2}').setText('N/A')
          : sheet.getRangeByName('K${i + 2}').setText('$shipmentDurationInMinutes Minutes');
    }
    final List<int> bytes = workbook.saveAsStream();
    String date = DateTime.now().toString();
    String outPutFileName = 'Shipment_Report_$date.xlsx';
    downloadXlsXFile(outPutFileName, bytes);
    workbook.dispose();
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<String> getStoragePath() async {
    final String extDirectory = (await getApplicationSupportDirectory()).path;
    print(extDirectory);
    return extDirectory;
  }

  void downloadXlsXFile(String outPutFileName, List<int> bytes) async {
    if (kIsWeb) {
      download(Stream.fromIterable(bytes), outPutFileName);
    } else {
      //!do for mobile
      try {
        String storageFolderPath = await getStoragePath();
        final String fileName = '$storageFolderPath/$outPutFileName';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        OpenFile.open(fileName);
      } catch (e) {
        print(e);
      }
    }
  }

  int getOrdersWaitingForPickup(List<Map<String, dynamic>>? reportsData) {
    int ordersWaitingPickup = 0;
    for (var i = 0; i < reportsData!.length; i++) {
      if (reportsData[i]['status'] == 'Waiting for Confirmation') {
        ordersWaitingPickup++;
      }
    }
    return ordersWaitingPickup;
  }

  int getOrdersEnRoute(List<Map<String, dynamic>>? reportsData) {
    int ordersEnRoute = 0;
    for (var i = 0; i < reportsData!.length; i++) {
      if (reportsData[i]['status'] == 'Confirmed') {
        ordersEnRoute++;
      }
    }
    return ordersEnRoute;
  }

  int getOrdersDeliveredAccepted(List<Map<String, dynamic>>? reportsData) {
    int ordersDeliveredAccepted = 0;
    for (var reportData in reportsData!) {
      if (reportData['status'] != "Draft") {
        if (reportData['patients'] != null) {
          for (var patient in reportData['patients']) {
            for (var specimen in patient['specimens']) {
              if (!specimen['rejected']) {
                ordersDeliveredAccepted++;
              }
            }
          }
        }
      }
    }
    return ordersDeliveredAccepted;
  }

  int getOrdersDeliveredRejected(List<Map<String, dynamic>>? reportsData) {
    int ordersDeliveredRejected = 0;
    for (var reportData in reportsData!) {
      if (reportData['status'] != "Draft") {
        if (reportData['patients'] != null) {
          for (var patient in reportData['patients']) {
            for (var specimen in patient['specimens']) {
              if (specimen['rejected']) {
                ordersDeliveredRejected++;
              }
            }
          }
        }
      }
    }
    return ordersDeliveredRejected;
  }

  int getTotalSpecimens(List<Map<String, dynamic>>? reportsData) {
    int totalSpecimens = 0;
    for (var reportData in reportsData!) {
      if (reportData['status'] != "Draft") {
        if (reportData['patients'] != null) {
          for (var patient in reportData['patients']) {
            // ignore: unused_local_variable
            for (var specimen in patient['specimens']) {
              totalSpecimens++;
            }
          }
        }
      }
    }
    return totalSpecimens;
  }

  int getOrdersDeliveredTestedResulted(List<Map<String, dynamic>>? reportsData) {
    int ordersDeliveredTestedResulted = 0;
    for (var reportData in reportsData!) {
      if (reportData['patients'] != null) {
        for (var patient in reportData['patients']) {
          for (var specimen in patient['specimens']) {
            if (specimen['result'] != null) {
              ordersDeliveredTestedResulted++;
            }
          }
        }
      }
    }
    return ordersDeliveredTestedResulted;
  }

  int getOrdersTestedPositive(List<Map<String, dynamic>>? reportsData) {
    int ordersTestedPositive = 0;
    for (var reportData in reportsData!) {
      if (reportData['patients'] != null) {
        for (var patient in reportData['patients']) {
          for (var specimen in patient['specimens']) {
            if (specimen['result'] != null) {
              if (specimen['result']['mtb_result'] == 'MTB Detected') {
                ordersTestedPositive++;
              }
            }
          }
        }
      }
    }
    return ordersTestedPositive;
  }

  int getOrdersTestedNegative(List<Map<String, dynamic>>? reportsData) {
    int ordersTestedNegative = 0;
    for (var reportData in reportsData!) {
      if (reportData['patients'] != null) {
        for (var patient in reportData['patients']) {
          for (var specimen in patient['specimens']) {
            if (specimen['result'] != null) {
              if (specimen['result']['mtb_result'] == 'MTB Not Detected') {
                ordersTestedNegative++;
              }
            }
          }
        }
      }
    }
    return ordersTestedNegative;
  }

  int getTotalOrders(List<Map<String, dynamic>>? reportsData) {
    int ordersTotal = 0;
    for (var reportData in reportsData!) {
      if (reportData['status'] != "Draft") {
        ordersTotal++;
      }
    }
    return ordersTotal;
  }

  //!update summary data
  void updateSummaryData(List<Map<String, dynamic>>? reportsData) {
    setState(() {
      totalSpecimens = getTotalSpecimens(reportsData);
    });
    summaryData['totalRequestedOrders'] = getTotalOrders(reportsData);
    summaryData['ordersWaitingPickup'] = getOrdersWaitingForPickup(reportsData);
    summaryData['ordersEnRoute'] = getOrdersEnRoute(reportsData);
    summaryData['ordersDeliveredAccepted'] = getOrdersDeliveredAccepted(reportsData);
    summaryData['ordersDeliveredRejected'] = getOrdersDeliveredRejected(reportsData);
    summaryData['ordersDeliveredTestResultSent'] = getOrdersDeliveredTestedResulted(reportsData);
    //
    summaryData['resultsTotalSent'] = getOrdersDeliveredTestedResulted(reportsData);
    summaryData['resultsTotalPositive'] = getOrdersTestedPositive(reportsData);
    summaryData['resultsTotalNegative'] = getOrdersTestedNegative(reportsData);

    //!percentage
  }

  //!get all reports
  void getReports() async {
    setState(() {
      reports = [];
      loadingReports = true;
    });
    List<Map<String, dynamic>>? reportsData = await getUserReport();
    if (reportsData != null) {
      setState(() {
        reports = reportsData;
        loadingReports = false;
      });
      updateSummaryData(reportsData);
    }
  }

  void getTodayReports() {
    setState(() {
      loadingReports = true;
      filteredReports = [];
    });
    for (var report in reports) {
      bool isTheSame = isReportDateSameAsToday(report);
      if (isTheSame) filteredReports.add(report);
    }
    updateSummaryData(filteredReports);
    setState(() {
      loadingReports = false;
    });
  }

  void getWeeklyReports() {
    setState(() {
      loadingReports = true;
      filteredReports = [];
    });
    for (var report in reports) {
      bool isTheSame = isReportDateWithInThePast7Days(report);
      if (isTheSame) filteredReports.add(report);
    }
    updateSummaryData(filteredReports);
    setState(() {
      loadingReports = false;
    });
  }

  void getMonthlyReports(BuildContext context) {
    //!
    setState(() {
      loadingReports = true;
      filteredReports = [];
    });
    for (var report in reports) {
      bool isTheSame = isReportDateSameAsThisMonth(report);
      if (isTheSame) filteredReports.add(report);
    }
    updateSummaryData(filteredReports);
    setState(() {
      loadingReports = false;
    });
  }

  void getYearlyReports() {
    //!
    setState(() {
      loadingReports = true;
      filteredReports = [];
    });
    for (var report in reports) {
      bool isTheSame = isReportDateSameAsThisYear(report);
      if (isTheSame) filteredReports.add(report);
    }
    updateSummaryData(filteredReports);
    setState(() {
      loadingReports = false;
    });
  }

  void getCustomDateReports(BuildContext context) {
    final size = MediaQuery.of(context).size;
    setState(() {
      filterStartDate = DateTime(2000, 1, 1);
      filterEndDate = DateTime.now();
    });
    //!
    showMaterialModalBottomSheet(
      context: context,

      duration: Duration(milliseconds: 350),
      isDismissible: false,
      enableDrag: false,
      animationCurve: Curves.linear,
      // shape: RoundedRectangleBorder(),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20.0),
        height: size.height * 0.75,
        // width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Start Date', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            SizedBox(height: size.height * 0.02),
            Container(
              height: size.height * 0.2,
              width: size.width > 450 ? 400 : 300,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime(2000, 1, 1),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    filterStartDate = newDateTime;
                  });
                },
              ),
            ),
            Text('End Date', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Container(
              height: size.height * 0.2,
              width: size.width > 450 ? 400 : 300,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    filterEndDate = newDateTime;
                  });
                },
              ),
            ),
            SizedBox(height: size.height * 0.02),
            MaterialButton(
              onPressed: () {
                setState(() {
                  loadingReports = true;
                  filteredReports = [];
                });
                for (var report in reports) {
                  DateTime reportDate = report['order_created'].toDate();
                  if (reportDate.isBefore(filterEndDate!) && reportDate.isAfter(filterStartDate!)) {
                    filteredReports.add(report);
                  }
                }
                updateSummaryData(filteredReports);
                setState(() {
                  loadingReports = false;
                });
                Navigator.pop(context);
              },
              color: Colors.red,
              minWidth: size.width > 450 ? 400 : 300,
              height: 50.0,
              child: Text('Filter', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void filterData(Object? choice, BuildContext context) async {
    switch (choice) {
      case "All":
        getReports();
        break;
      case "Today":
        getTodayReports();
        break;
      case "This Week":
        getWeeklyReports();
        break;
      case "This Month":
        getMonthlyReports(context);
        break;
      case "This Year":
        getYearlyReports();
        break;
      case "Custom Date":
        getCustomDateReports(context);
        break;
      default:
        getReports();
    }
  }

  double calculatePercentageValue(double value, double total) {
    double result = ((value / total) * 100).roundToDouble();
    return result;
  }

  bool isReportDataEmpty() {
    //!if filter is not All and filtred reports is empty
    if (selectedFilter != 'All' && filteredReports.isEmpty && !loadingReports) {
      return true;
      //!if filter is not All and filtred reports is not empty
    } else if (selectedFilter != 'All' && filteredReports.isNotEmpty && !loadingReports) {
      return false;
    } else if (selectedFilter == 'All' && reports.isEmpty && !loadingReports) {
      return true;
    } else if (selectedFilter == 'All' && reports.isNotEmpty && !loadingReports) {
      return false;
    } else {
      return true;
    }
  }

  reportType currentReportType = reportType.orderMonitoringReport;
  String selectedReportType = "Order Monitoring";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: AppBar(
        backgroundColor: kColorsOrangeLight,
        title: Text(
          'Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Container(
            height: size.height,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 20.0),
                  //!Filter Button
                  Container(
                    decoration: BoxDecoration(),
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropDown(
                      items: ["All", "Today", "This Week", "This Month", "This Year", "Custom Date"],
                      dropDownType: DropDownType.Button,
                      showUnderline: false,
                      hint: Text('All', style: TextStyle(fontSize: 20.0)),
                      icon: Container(
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.filter),
                            SizedBox(width: 10),
                            Text('Filter', style: TextStyle(fontSize: 18.0)),
                          ],
                        ),
                      ),
                      onChanged: (choice) {
                        setState(() {
                          selectedFilter = choice.toString();
                        });
                        filterData(choice, context);
                      },
                    ),
                  ),
                  loadingReports
                      ? Expanded(
                          child: Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : isReportDataEmpty()
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 50),
                              child: Center(child: Text('No Report Found', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                            )
                          : Expanded(
                              child: ListView(
                                children: [
                                  SizedBox(height: 10.0),
                                  //!report summary cards
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 5),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text('Orders', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                        ),
                                        SizedBox(
                                          height: 140,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ReportSummaryCard(
                                                    title: 'Total orders', description: summaryData['totalRequestedOrders'].toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(
                                                    title: 'Waiting pickup', description: summaryData['ordersWaitingPickup'].toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(title: 'En route', description: summaryData['ordersEnRoute'].toString()),
                                              ),
                                              // SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text('Specimens', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                        ),
                                        SizedBox(
                                          height: 140,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ReportSummaryCard(title: 'Total', description: totalSpecimens.toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(
                                                    title: 'Accepted', description: summaryData['ordersDeliveredAccepted'].toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(
                                                    title: 'Rejected', description: summaryData['ordersDeliveredRejected'].toString()),
                                              ),
                                              // SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text('Test Results', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                        ),
                                        SizedBox(
                                          height: 140,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    ReportSummaryCard(title: 'Total Result', description: summaryData['resultsTotalSent'].toString()),
                                              ),
                                              Expanded(
                                                child:
                                                    ReportSummaryCard(title: 'Positive', description: summaryData['resultsTotalPositive'].toString()),
                                              ),
                                              Expanded(
                                                child:
                                                    ReportSummaryCard(title: 'Negative', description: summaryData['resultsTotalNegative'].toString()),
                                              ),
                                              // SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  //!charts
                                  //!pie chart
                                  SizedBox(height: 5),
                                  summaryData['resultsTotalSent'] == 0
                                      ? SizedBox.shrink()
                                      : Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                child: Text('Specimens', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                child: size.width < 370
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            height: size.width > 500 ? 300 : 150,
                                                            width: size.width > 500 ? 300 : 150,
                                                            margin: const EdgeInsets.all(10),
                                                            child: PieChart(
                                                              PieChartData(
                                                                sectionsSpace: 0,
                                                                sections: [
                                                                  PieChartSectionData(
                                                                    title:
                                                                        '${calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle:
                                                                        TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(),
                                                                        summaryData['resultsTotalSent'].toDouble()),
                                                                    radius: size.width > size.height ? size.height * 0.2 : size.width * 0.225,
                                                                    color: Colors.teal,
                                                                  ),
                                                                  PieChartSectionData(
                                                                    title:
                                                                        '${calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle:
                                                                        TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(),
                                                                        summaryData['resultsTotalSent'].toDouble()),
                                                                    radius: size.width > size.height ? size.height * 0.2 : size.width * 0.2,
                                                                    color: Colors.blue,
                                                                  ),
                                                                ],
                                                              ),
                                                              swapAnimationDuration: Duration(milliseconds: 250),
                                                              swapAnimationCurve: Curves.linear,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Container(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                ChartIndicator(indicatorColor: Colors.teal, label: 'MTB Detected'),
                                                                SizedBox(height: 10),
                                                                ChartIndicator(indicatorColor: Colors.blue, label: 'MTB Not Detected'),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [
                                                          Container(
                                                            height: size.width > 450 ? 300 : 200,
                                                            width: size.width > 450 ? 300 : 200,
                                                            margin: const EdgeInsets.all(10),
                                                            child: PieChart(
                                                              PieChartData(
                                                                sectionsSpace: 0,
                                                                sections: [
                                                                  PieChartSectionData(
                                                                    title:
                                                                        '${calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle:
                                                                        TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(),
                                                                        summaryData['resultsTotalSent'].toDouble()),
                                                                    radius: size.width > size.height ? size.height * 0.2 : size.width * 0.225,
                                                                    color: Colors.teal,
                                                                  ),
                                                                  PieChartSectionData(
                                                                    title:
                                                                        '${calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle:
                                                                        TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(),
                                                                        summaryData['resultsTotalSent'].toDouble()),
                                                                    radius: size.width > size.height ? size.height * 0.2 : size.width * 0.2,
                                                                    color: Colors.blue,
                                                                  ),
                                                                ],
                                                              ),
                                                              swapAnimationDuration: Duration(milliseconds: 250),
                                                              swapAnimationCurve: Curves.linear,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Container(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                ChartIndicator(indicatorColor: Colors.teal, label: 'MTB Detected'),
                                                                SizedBox(height: 10),
                                                                ChartIndicator(indicatorColor: Colors.blue, label: 'MTB Not Detected'),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),

                                  SizedBox(height: 20),

                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        //   child: Text('Reports', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                        // ),
                                        SizedBox(height: 20),

                                        //
                                        Container(
                                          decoration: BoxDecoration(),
                                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: DropDown(
                                            items: ["Order Monitoring", "Specimen Referral", "Shipment"],
                                            dropDownType: DropDownType.Button,
                                            showUnderline: false,
                                            hint: Text(selectedReportType, style: TextStyle(fontSize: 20.0)),
                                            icon: Container(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.bar_chart),
                                                  SizedBox(width: 10),
                                                  Text('Select Report', style: TextStyle(fontSize: 18.0)),
                                                ],
                                              ),
                                            ),
                                            onChanged: (choice) {
                                              switch (choice) {
                                                case "Order Monitoring":
                                                  setState(() {
                                                    currentReportType = reportType.orderMonitoringReport;
                                                    selectedReportType = choice.toString();
                                                  });
                                                  break;
                                                case "Specimen Referral":
                                                  setState(() {
                                                    currentReportType = reportType.specimenReferralReport;
                                                    selectedReportType = choice.toString();
                                                  });
                                                  break;
                                                case "Shipment":
                                                  setState(() {
                                                    currentReportType = reportType.shipmentReport;
                                                    selectedReportType = choice.toString();
                                                  });
                                                  break;
                                                default:
                                                  break;
                                              }
                                            },
                                          ),
                                        ),

                                        SizedBox(height: 20),
//TODO: change report export data
                                        //!Order Monitoring Table
                                        currentReportType != reportType.orderMonitoringReport
                                            ? SizedBox.shrink()
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('Order Monitoring', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                                        IconButton(
                                                          onPressed: () {
                                                            print('Exporting order monitoring report');
                                                            exportOrderMonitoringReport(selectedFilter == 'All' ? reports : filteredReports);
                                                          },
                                                          icon: FaIcon(FontAwesomeIcons.fileExport),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: SingleChildScrollView(
                                                      child: DataTable(
                                                        border: TableBorder(
                                                          left: BorderSide(color: Colors.grey.shade400),
                                                          top: BorderSide(color: Colors.grey.shade400),
                                                          right: BorderSide(color: Colors.grey.shade400),
                                                          bottom: BorderSide(color: Colors.grey.shade400),
                                                          horizontalInside: BorderSide(color: Colors.grey.shade400),
                                                          verticalInside: BorderSide(color: Colors.grey.shade400),
                                                        ),
                                                        columns: [
                                                          DataColumn(label: Text("Order No")),
                                                          DataColumn(label: Text("Referring Health Facility")),
                                                          DataColumn(label: Text("Courier Name")),
                                                          DataColumn(label: Text("Testing Health Facility")),
                                                          DataColumn(label: Text("Region")),
                                                          DataColumn(label: Text("Zone/Sub City")),
                                                          DataColumn(label: Text("Woreda")),
                                                          DataColumn(label: Text("Number of Sample")),
                                                          DataColumn(label: Text("Order Created")),
                                                          DataColumn(label: Text("Order Status")),
                                                        ],
                                                        rows: getOrderMonitoringRows(selectedFilter == 'All' ? reports : filteredReports),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 40),
                                                ],
                                              ),

                                        //!Specimen Referral Report Table
                                        currentReportType != reportType.specimenReferralReport
                                            ? SizedBox.shrink()
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('Specimen Referral Report',
                                                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                                        IconButton(
                                                          onPressed: () {
                                                            print('Exporting Specimen Referring report');
                                                            exportSpecimenReferralReport(selectedFilter == 'All' ? reports : filteredReports);
                                                          },
                                                          icon: FaIcon(FontAwesomeIcons.fileExport),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: SingleChildScrollView(
                                                      child: DataTable(
                                                        border: TableBorder(
                                                          left: BorderSide(color: Colors.grey.shade400),
                                                          top: BorderSide(color: Colors.grey.shade400),
                                                          right: BorderSide(color: Colors.grey.shade400),
                                                          bottom: BorderSide(color: Colors.grey.shade400),
                                                          horizontalInside: BorderSide(color: Colors.grey.shade400),
                                                          verticalInside: BorderSide(color: Colors.grey.shade400),
                                                        ),
                                                        columns: [
                                                          DataColumn(label: Text("Order ID")),
                                                          DataColumn(label: Text("Courier Name")),
                                                          DataColumn(label: Text("Referring Health Facility")),
                                                          DataColumn(label: Text("Testing Health Facility")),
                                                          DataColumn(label: Text("Order Created")),
                                                          DataColumn(label: Text("Patient's Name")),
                                                          DataColumn(label: Text("MRN")),
                                                          DataColumn(label: Text("Sex")),
                                                          DataColumn(label: Text("Age")),
                                                          DataColumn(label: Text("Age(Months)")),
                                                          DataColumn(label: Text("Phone")),
                                                          DataColumn(label: Text("Region")),
                                                          DataColumn(label: Text("Zone")),
                                                          DataColumn(label: Text("Woreda")),
                                                          DataColumn(label: Text("Specimen Type")),
                                                          DataColumn(label: Text("Site of Test")),
                                                          DataColumn(label: Text("Requested Test")),
                                                          DataColumn(label: Text("Reason for Test")),
                                                          DataColumn(label: Text("Registration Group")),
                                                          DataColumn(label: Text("Delivery Status")),
                                                          // getDataForSpecimenReferralReport
                                                          //TODO: add remaining columns
                                                          DataColumn(label: Text("Turn around Time")),
                                                          DataColumn(label: Text("MTB Result")),
                                                          DataColumn(label: Text("RR Result")),
                                                          DataColumn(label: Text("Lab Registration Number")),
                                                        ],
                                                        rows: getSpecimenReferalReport(selectedFilter == 'All' ? reports : filteredReports),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 40),
                                                ],
                                              ),

                                        //!Shipment Report Table

                                        currentReportType != reportType.shipmentReport
                                            ? SizedBox.shrink()
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('Shipment Report', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                                        IconButton(
                                                          onPressed: () {
                                                            print('Exporting Specimen Referring report');
                                                            exportShipmentReport(selectedFilter == 'All' ? reports : filteredReports);
                                                          },
                                                          icon: FaIcon(FontAwesomeIcons.fileExport),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: SingleChildScrollView(
                                                      child: DataTable(
                                                        border: TableBorder(
                                                          left: BorderSide(color: Colors.grey.shade400),
                                                          top: BorderSide(color: Colors.grey.shade400),
                                                          right: BorderSide(color: Colors.grey.shade400),
                                                          bottom: BorderSide(color: Colors.grey.shade400),
                                                          horizontalInside: BorderSide(color: Colors.grey.shade400),
                                                          verticalInside: BorderSide(color: Colors.grey.shade400),
                                                        ),
                                                        columns: [
                                                          DataColumn(label: Text("Order ID")),
                                                          DataColumn(label: Text("Pick up Site")),
                                                          DataColumn(label: Text("Region")),
                                                          DataColumn(label: Text("Zone")),
                                                          DataColumn(label: Text("Woreda")),
                                                          DataColumn(label: Text("Courier Name")),
                                                          DataColumn(label: Text("Recipient Site")),
                                                          DataColumn(label: Text("Number of Patients")),
                                                          DataColumn(label: Text("Order Created")),
                                                          DataColumn(label: Text("Order Accepted")),
                                                          DataColumn(label: Text("Shipment Duration")),
                                                        ],
                                                        rows: getShipmentReport(selectedFilter == 'All' ? reports : filteredReports),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 40),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String getDateFormatted(Timestamp? time) {
  if (time == null) {
    return "";
  } else {
    return time.toDate().day.toString() + '/' + time.toDate().month.toString() + '/' + time.toDate().year.toString();
  }
}

String getAgeInMonth(int? age) {
  if (age == null) {
    return "";
  } else {
    return (age * 12).toString();
  }
}

int? getOrderTurnAroundTime(Map<String, dynamic> order) {
  int? time;
  DateTime? orderPickedUp;
  DateTime? orderReceived;
  if (order['order_pickedup'] != null && order['order_received'] != null) {
    orderReceived = order['order_received'].toDate();
    orderPickedUp = order['order_pickedup'].toDate();

    if (orderReceived != null && orderPickedUp != null) {
      time = orderReceived.difference(orderPickedUp).inMinutes;
    }
  }
  return time;
}

String getSpecimenMtbResult(Map<String, dynamic> specimen) {
  String res = "N/A";
  if (specimen['result'] != null) {
    Map<String, dynamic> result = specimen['result'];
    if (result['mtb_result'] != null) {
      res = result['mtb_result'].toString();
    }
  }
  return res;
}

String getSpecimenRrResult(Map<String, dynamic> specimen) {
  String res = "N/A";
  if (specimen['result'] != null) {
    Map<String, dynamic> result = specimen['result'];
    if (result['result_rr'] != null) {
      res = result['result_rr'].toString();
    }
  }
  return res;
}

String getSpecimenLabRegistrationNum(Map<String, dynamic> specimen) {
  String res = "N/A";
  if (specimen['result'] != null) {
    Map<String, dynamic> result = specimen['result'];
    if (result['lab_registratin_number'] != null) {
      res = result['lab_registratin_number'].toString();
    }
  }
  return res;
}

List<Map<String, dynamic>> getDataForSpecimenReferralReport(List<Map<String, dynamic>> reportsData) {
  List<Map<String, dynamic>> finalData = [];
  Map<String, dynamic> patientInformation = {};
//!data collector
  for (Map<String, dynamic> reportData in reportsData) {
    if (reportData['patients'] != null) {
      for (Map<String, dynamic> patient in reportData['patients']) {
        for (Map<String, dynamic> specimen in patient['specimens']) {
          patientInformation['orderId'] = reportData['orderId'] != null ? reportData['orderId'] : "";
          patientInformation['courier_name'] = reportData['courier_name'] != null ? reportData['courier_name'] : "";
          patientInformation['sender_name'] = reportData['sender_name'] != null ? reportData['sender_name'] : "";
          patientInformation['tester_name'] = reportData['tester_name'] != null ? reportData['tester_name'] : "";
          patientInformation['order_created'] = getDateFormatted(reportData['order_created']);
          patientInformation['patientName'] = patient['name'] != null ? patient['name'] : "";
          patientInformation['mrn'] = patient['MR'] != null ? patient['MR'] : "";
          patientInformation['sex'] = patient['sex'] != null ? patient['sex'] : "";
          patientInformation['age'] = patient['age'] != null ? patient['age'] : "";
          patientInformation['ageInMonths'] = patient['age'] != null ? getAgeInMonth(int.parse(patient['age'])) : "";
          patientInformation['phone'] = patient['phone'] != null ? patient['phone'] : "";
          patientInformation['region'] = patient['region']['name'] != null ? patient['region']['name'] : "";
          patientInformation['zone'] = patient['region']['zones'][0]['name'] != null ? patient['region']['zones'][0]['name'] : "";
          patientInformation['woreda'] =
              patient['region']['zones'][0]['woredas'][0]['name'] != null ? patient['region']['zones'][0]['woredas'][0]['name'] : "";
          patientInformation['specimenType'] = specimen['type'] != null ? specimen['type'] : "";
          patientInformation['siteOfTest'] = patient['anatomic_location'] != null ? patient['anatomic_location'] : "";
          patientInformation['requestedTest'] = specimen['examination_type'] != null ? specimen['examination_type'] : "";
          patientInformation['reasonForTest'] = patient['reason_for_test'] != null ? patient['reason_for_test'] : "";
          patientInformation['registrationGroup'] = patient['registration_group'] != null ? patient['registration_group'] : "";
          patientInformation['deliveryStatus'] = reportData['status'] != null ? reportData['status'] : "";
          patientInformation['turnAroundTime'] =
              getOrderTurnAroundTime(reportData) != null ? getOrderTurnAroundTime(reportData).toString() + " Minute" : "N/A";
          patientInformation['mtb_result'] = getSpecimenMtbResult(specimen);
          patientInformation['result_rr'] = getSpecimenRrResult(specimen);
          patientInformation['lab_registration_number'] = getSpecimenLabRegistrationNum(specimen);

          //TODO: add remaining columns

          finalData.add(patientInformation);
          patientInformation = {};
        }
      }
    }
  }
  return finalData;
}

List<DataRow> getSpecimenReferalReport(List<Map<String, dynamic>> reportsData) {
  List<Map<String, dynamic>> finalData = getDataForSpecimenReferralReport(reportsData);

  return finalData.map((data) {
    return DataRow(
      cells: [
        DataCell(Text(data['orderId'].toString())),
        DataCell(Text(data['courier_name'].toString())),
        DataCell(Text(data['sender_name'].toString())),
        DataCell(Text(data['tester_name'].toString())),
        DataCell(Text(data['order_created'].toString())),
        DataCell(Text(data['patientName'].toString())),
        DataCell(Text(data['mrn'].toString())),
        DataCell(Text(data['sex'].toString())),
        DataCell(Text(data['age'].toString())),
        DataCell(Text(data['ageInMonths'].toString())),
        DataCell(Text(data['phone'].toString())),
        DataCell(Text(data['region'].toString())),
        DataCell(Text(data['zone'].toString())),
        DataCell(Text(data['woreda'].toString())),
        DataCell(Text(data['specimenType'].toString())),
        DataCell(Text(data['siteOfTest'].toString())),
        DataCell(Text(data['requestedTest'].toString())),
        DataCell(Text(data['reasonForTest'].toString())),
        DataCell(Text(data['registrationGroup'].toString())),
        DataCell(Text(data['deliveryStatus'].toString())),
        DataCell(Text(data['turnAroundTime'].toString())),
        DataCell(Text(data['mtb_result'].toString())),
        DataCell(Text(data['result_rr'].toString())),
        DataCell(Text(data['lab_registration_number'].toString())),
      ],
    );
  }).toList();
}

List<Map<String, dynamic>> getFilteredReports(List<Map<String, dynamic>> reportsData) {
  List<Map<String, dynamic>> filteredReportsData = reportsData.where((data) {
    if (data['status'] != 'Draft') {
      return true;
    } else {
      return false;
    }
  }).toList();
  return filteredReportsData;
}

List<DataRow> getShipmentReport(List<Map<String, dynamic>> reportsData) {
  List<Map<String, dynamic>> filteredReportsData = getFilteredReports(reportsData);

  return filteredReportsData.map((data) {
    DateTime? orderReceived;
    DateTime? orderPickedUp;
    int? shipmentDurationInMinutes;
    if (data['order_received'] != null) {
      orderReceived = data['order_received'].toDate();
    }
    if (data['order_pickedup'] != null) {
      orderPickedUp = data['order_pickedup'].toDate();
    }

    if (orderReceived != null && orderPickedUp != null) {
      shipmentDurationInMinutes = orderReceived.difference(orderPickedUp).inMinutes;
    }

    return DataRow(
      cells: [
        DataCell(Text(data['orderId'])),
        DataCell(Text(data['sender_name'].toString())),
        DataCell(Text(data['region']['name'].toString())),
        DataCell(Text(data['region']['zones'][0]['name'].toString())),
        DataCell(Text(data['region']['zones'][0]['woredas'][0]['name'].toString())),
        DataCell(Text(data['courier_name'].toString())),
        DataCell(Text(data['tester_name'].toString())),
        DataCell(Text(data['patients'] != null ? data['patients'].length.toString() : '0')),
        DataCell(Text(data['order_created'].toDate().day.toString() +
            '/' +
            data['order_created'].toDate().month.toString() +
            '/' +
            data['order_created'].toDate().year.toString())),
        orderReceived == null
            ? DataCell(Text('N/A'))
            : DataCell(Text(orderReceived.day.toString() + '/' + orderReceived.month.toString() + '/' + orderReceived.year.toString())),
        shipmentDurationInMinutes == null ? DataCell(Text('N/A')) : DataCell(Text('$shipmentDurationInMinutes Minutes')),
      ],
    );
  }).toList();
}

int getOrderSpecimenCount(Map<String, dynamic> order) {
  int count = 0;
  for (int i = 0; i < order['patients'].length; i++) {
    Map<String, dynamic> patient = order['patients'][i];
    // print('specimen count: ${patient['specimens'].length}');
    count += int.parse(patient['specimens'].length.toString());
  }
  return count;
}

List<DataRow> getOrderMonitoringRows(List<Map<String, dynamic>> reportsData) {
  List<Map<String, dynamic>> filteredReportsData = getFilteredReports(reportsData);

  return filteredReportsData.map((data) {
    return DataRow(
      cells: [
        DataCell(Text(data['orderId'])),
        DataCell(Text(data['sender_name'].toString())),
        DataCell(Text(data['courier_name'].toString())),
        DataCell(Text(data['tester_name'].toString())),
        DataCell(Text(data['region']['name'].toString())),
        DataCell(Text(data['region']['zones'][0]['name'].toString())),
        DataCell(Text(data['region']['zones'][0]['woredas'][0]['name'].toString())),
        // DataCell(Text(data['patients'] != null ? data['patients'].length.toString() : '0')),
        DataCell(Text(data['patients'] != null ? getOrderSpecimenCount(data).toString() : '0')),

        DataCell(Text(data['order_created'].toDate().day.toString() +
            '/' +
            data['order_created'].toDate().month.toString() +
            '/' +
            data['order_created'].toDate().year.toString())),
        DataCell(Text(data['status'].toString())),
      ],
    );
  }).toList();
}

class ChartIndicator extends StatelessWidget {
  const ChartIndicator({Key? key, required this.indicatorColor, required this.label}) : super(key: key);
  final Color indicatorColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(color: indicatorColor, borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({Key? key, required this.title, required this.description}) : super(key: key);
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(left: 8, right: size.width > 900 ? 100 : 10, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 7), blurRadius: 20)],
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
          Divider(),
          SizedBox(height: 20),
          Text(description, style: TextStyle(fontSize: size.width > 900 ? 26 : 24.0, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
