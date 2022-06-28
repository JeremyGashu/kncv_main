import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kncv_flutter/presentation/pages/report/report_controller.dart';
import 'package:lazy_data_table/lazy_data_table.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../core/colors.dart';

enum Filters { All, Today, ThisWeek, ThisMonth, ThisYear, CustomDate }

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

  //TODO: specimen enroute
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
      for (var patient in reportData['patients']) {
        for (var specimen in patient['specimens']) {
          // print(specimen.length);
          if (!specimen['rejected']) {
            ordersDeliveredAccepted++;
          }
        }
      }
    }
    return ordersDeliveredAccepted;
  }

  int getOrdersDeliveredRejected(List<Map<String, dynamic>>? reportsData) {
    int ordersDeliveredRejected = 0;
    for (var reportData in reportsData!) {
      for (var patient in reportData['patients']) {
        for (var specimen in patient['specimens']) {
          // print(specimen.length);
          if (specimen['rejected']) {
            ordersDeliveredRejected++;
          }
        }
      }
    }
    return ordersDeliveredRejected;
  }

  int getTotalSpecimens(List<Map<String, dynamic>>? reportsData) {
    int totalSpecimens = 0;
    for (var reportData in reportsData!) {
      for (var patient in reportData['patients']) {
        for (var specimen in patient['specimens']) {
          totalSpecimens++;
        }
        // totalSpecimens += patient['specimens'].length.toInt();
      }
    }
    // print('totalSpecimens: $totalSpecimens');
    return totalSpecimens;
  }

  int getOrdersDeliveredTestedResulted(List<Map<String, dynamic>>? reportsData) {
    int ordersDeliveredTestedResulted = 0;
    for (var reportData in reportsData!) {
      for (var patient in reportData['patients']) {
        for (var specimen in patient['specimens']) {
          // print(specimen.length);
          if (specimen['result'] != null) {
            ordersDeliveredTestedResulted++;
          }
        }
      }
    }
    // print('orders tested resulted: $ordersDeliveredTestedResulted');
    return ordersDeliveredTestedResulted;
  }

  int getOrdersTestedPositive(List<Map<String, dynamic>>? reportsData) {
    int ordersTestedPositive = 0;
    for (var reportData in reportsData!) {
      for (var patient in reportData['patients']) {
        for (var specimen in patient['specimens']) {
          // print(specimen.length);
          // if (!specimen['rejected']) {
          if (specimen['result'] != null) {
            if (specimen['result']['mtb_result'] == 'MTB Detected') {
              ordersTestedPositive++;
            }
          }
          // }
        }
      }
    }
    return ordersTestedPositive;
  }

  int getOrdersTestedNegative(List<Map<String, dynamic>>? reportsData) {
    int ordersTestedNegative = 0;
    for (var reportData in reportsData!) {
      for (var patient in reportData['patients']) {
        for (var specimen in patient['specimens']) {
          // print(specimen.length);
          // if (!specimen['rejected']) {
          if (specimen['result'] != null) {
            if (specimen['result']['mtb_result'] == 'MTB Not Detected') {
              ordersTestedNegative++;
            }
          }
          // }
        }
      }
    }
    return ordersTestedNegative;
  }

  //!update summary data
  void updateSummaryData(List<Map<String, dynamic>>? reportsData) {
    setState(() {
      totalSpecimens = getTotalSpecimens(reportsData);
    });
    summaryData['totalRequestedOrders'] = reportsData!.length;
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
    // summaryData['orderDeliveredAcceptedPercentage'] = calculatePercentageValue(value, total).toString();
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
    //!
    showMaterialModalBottomSheet(
      context: context,
      duration: Duration(milliseconds: 250),
      isDismissible: false,
      enableDrag: false,
      animationCurve: Curves.bounceIn,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20.0),
        height: size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: size.height * 0.1),
            Text('Start Date', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Container(
              height: 200,
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
              height: 200,
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
            SizedBox(height: 20),
            MaterialButton(
              //TODO:fix issue where custom date selected and back button pressed
              onPressed: () {
                // print('Start Date: $filterStartDate');
                // print('End Date: $filterEndDate');
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
              minWidth: double.infinity,
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
    // print('Value: $value');
    // print('Total: $total');
    double result = ((value / total) * 100).roundToDouble();
    // print('Result: $result');
    return result;
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
        actions: [
          //BlocProvider.of<AuthBloc>(context).add(LogOutUser());
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
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
                    // print('selectedFilter: $selectedFilter');
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
                  : (selectedFilter != 'All' && filteredReports.length == 0 && !loadingReports)
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 50),
                          child: Center(child: Text('No Report Found', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                        )
                      : Expanded(
                          child: ListView(
                            // crossAxisAlignment: CrossAxisAlignment.start,
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
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: 20),
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
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Text('Test Result', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text('Specimens', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                              ),
                              SizedBox(height: 5),
                              Container(
                                // height: 240,
                                child: Row(
                                  children: [
                                    Container(
                                      // decoration: BoxDecoration(color: Colors.yellow),
                                      height: size.height * 0.35,
                                      width: size.width / 2,
                                      margin: const EdgeInsets.all(10),
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 0,
                                          sections: [
                                            PieChartSectionData(
                                              title: '${calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble())} %',
                                              titleStyle: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                              value: calculatePercentageValue(summaryData['resultsTotalPositive'].toDouble(), summaryData['resultsTotalSent'].toDouble()),
                                              radius: size.width > size.height ? size.height * 0.2 : size.width * 0.2,
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
                                    Container(
                                      // decoration: BoxDecoration(color: Colors.yellow),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ChartIndicator(indicatorColor: Colors.teal, label: 'Positive'),
                                          SizedBox(height: 10),
                                          ChartIndicator(indicatorColor: Colors.blue, label: 'Negative'),
                                        ],
                                      ),
                                    ),

                                    // PieChart(
                                    //   PieChartData(
                                    //     sectionsSpace: 8,
                                    //     sections: [
                                    //       PieChartSectionData(
                                    //         title: "Accepted",
                                    //         titleStyle: TextStyle(color: Colors.black),
                                    //         value: summaryData['ordersDeliveredAccepted'].toDouble(),
                                    //         radius: 88,
                                    //         color: Colors.yellow.shade400,
                                    //       ),
                                    //       PieChartSectionData(
                                    //         title: "Rejected",
                                    //         titleStyle: TextStyle(color: Colors.black),
                                    //         value: summaryData['ordersDeliveredRejected'].toDouble(),
                                    //         radius: 88,
                                    //         color: Colors.red,
                                    //       ),
                                    //     ],
                                    //   ),
                                    //   swapAnimationDuration: Duration(milliseconds: 250),
                                    //   swapAnimationCurve: Curves.linear,
                                    // ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),

                              //TODO: add a data table
                              //!Order Monitoring Table

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  LazyDataTableTheme MyTableTheme() {
    return LazyDataTableTheme(
      rowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.grey.shade300)),
      alternateCellBorder: Border.fromBorderSide(BorderSide(color: Colors.grey.shade300)),
      cellBorder: Border.fromBorderSide(BorderSide(color: Colors.grey.shade300)),
      cornerBorder: Border.fromBorderSide(BorderSide(color: Colors.grey.shade300)),
      columnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.grey.shade300)),
      alternateRowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.grey.shade300)),
      alternateColumnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.grey.shade300)),
      rowHeaderColor: Colors.white,
      columnHeaderColor: Colors.white,
      cornerColor: Colors.white,
      cellColor: Colors.white,
      alternateCellColor: Colors.white,
      alternateRowHeaderColor: Colors.white,
      alternateColumnHeaderColor: Colors.white,
    );
  }
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
        Text(label, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
          Text(description, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
