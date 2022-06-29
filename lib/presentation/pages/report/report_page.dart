import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kncv_flutter/presentation/pages/report/report_controller.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../core/colors.dart';

//TODO: DateTime picker ui fix on web

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

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
                                                child: ReportSummaryCard(title: 'Total orders', description: summaryData['totalRequestedOrders'].toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(title: 'Waiting pickup', description: summaryData['ordersWaitingPickup'].toString()),
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
                                                child: ReportSummaryCard(title: 'Accepted', description: summaryData['ordersDeliveredAccepted'].toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(title: 'Rejected', description: summaryData['ordersDeliveredRejected'].toString()),
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
                                                child: ReportSummaryCard(title: 'Total Result', description: summaryData['resultsTotalSent'].toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(title: 'Positive', description: summaryData['resultsTotalPositive'].toString()),
                                              ),
                                              Expanded(
                                                child: ReportSummaryCard(title: 'Negative', description: summaryData['resultsTotalNegative'].toString()),
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
                                                                    title: '${calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble()),
                                                                    radius: size.width > size.height ? size.height * 0.2 : size.width * 0.225,
                                                                    color: Colors.teal,
                                                                  ),
                                                                  PieChartSectionData(
                                                                    title: '${calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(), summaryData['resultsTotalSent'].toDouble()),
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
                                                                    title: '${calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble()),
                                                                    radius: size.width > size.height ? size.height * 0.2 : size.width * 0.225,
                                                                    color: Colors.teal,
                                                                  ),
                                                                  PieChartSectionData(
                                                                    title: '${calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                                                    titleStyle: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                                                    value: calculatePercentageValue(summaryData['resultsTotalNegative'].toDouble(), summaryData['resultsTotalSent'].toDouble()),
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

                                  //!Order Monitoring Table
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Text('Order Monitoring', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
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
                                          DataColumn(label: Text("Number of Patients")),
                                          DataColumn(label: Text("Order Created")),
                                          DataColumn(label: Text("Order Status")),
                                        ],
                                        rows: getOrderMonitoringRows(selectedFilter == 'All' ? reports : filteredReports),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  //!Specimen Referral Report Table
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Text('Specimen Referral Report', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
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
                                        ],
                                        rows: getSpecimenReferalReport(selectedFilter == 'All' ? reports : filteredReports),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  //!Shipment Report Table
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Text('Shipment Report', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
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
                                  SizedBox(height: 20),
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

List<DataRow> getSpecimenReferalReport(List<Map<String, dynamic>> reportsData) {
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
          patientInformation['woreda'] = patient['region']['zones'][0]['woredas'][0]['name'] != null ? patient['region']['zones'][0]['woredas'][0]['name'] : "";
          patientInformation['specimenType'] = specimen['type'] != null ? specimen['type'] : "";
          patientInformation['siteOfTest'] = patient['anatomic_location'] != null ? patient['anatomic_location'] : "";
          patientInformation['requestedTest'] = specimen['examination_type'] != null ? specimen['examination_type'] : "";
          patientInformation['reasonForTest'] = patient['reason_for_test'] != null ? patient['reason_for_test'] : "";
          patientInformation['registrationGroup'] = patient['registration_group'] != null ? patient['registration_group'] : "";
          patientInformation['deliveryStatus'] = reportData['status'] != null ? reportData['status'] : "";
          finalData.add(patientInformation);
          patientInformation = {};
        }
      }
    }
  }

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
        DataCell(Text(data['order_created'].toDate().day.toString() + '/' + data['order_created'].toDate().month.toString() + '/' + data['order_created'].toDate().year.toString())),
        orderReceived == null ? DataCell(Text('N/A')) : DataCell(Text(orderReceived.day.toString() + '/' + orderReceived.month.toString() + '/' + orderReceived.year.toString())),
        shipmentDurationInMinutes == null ? DataCell(Text('N/A')) : DataCell(Text('$shipmentDurationInMinutes Minutes')),
      ],
    );
  }).toList();
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
        DataCell(Text(data['patients'] != null ? data['patients'].length.toString() : '0')),
        DataCell(Text(data['order_created'].toDate().day.toString() + '/' + data['order_created'].toDate().month.toString() + '/' + data['order_created'].toDate().year.toString())),
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
