import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kncv_flutter/presentation/pages/report/report_controller.dart';
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
  Map<String, dynamic> summaryData = {
    'totalRequestedOrders': null,
    'ordersWaitingPickup': null,
    'ordersEnRoute': null,
    'ordersDeliveredAccepted': null,
    'ordersDeliveredRejected': null,
    'ordersDeliveredTestResultSent': null,
    'resultsTotalSent': null,
    'resultsTotalPositive': null,
    'resultsTotalNegative': null
  };

  //

  @override
  void initState() {
    //!get firebase user id
    getReports();
    super.initState();
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
      // isDismissible: false,
      // enableDrag: false,
      // expand: true,
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
                onDateTimeChanged: (DateTime newDateTime) {
                  // Do something
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
                onDateTimeChanged: (DateTime newDateTime) {
                  // Do something
                  setState(() {
                    filterEndDate = newDateTime;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                print('Start Date: $filterStartDate');
                print('End Date: $filterEndDate');
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
                setState(() {
                  loadingReports = false;
                });
                Navigator.pop(context);
              },
              color: Colors.red,
              minWidth: double.infinity,
              height: 50.0,
              child: Text('Filter', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  void filterData(Object? choice, BuildContext context) async {
    switch (choice) {
      case "All":
        // print('all selected');
        getReports();
        break;
      case "Today":
        // print('today selected');
        getTodayReports();
        break;
      case "This Week":
        // print('this week selected');
        getWeeklyReports();
        break;
      case "This Month":
        // print('this month selected');
        getMonthlyReports(context);
        break;
      case "This Year":
        // print('this year selected');
        getYearlyReports();
        break;
      case "Custom Date":
        // print('custom date selected');
        getCustomDateReports(context);
        break;
      default:
        print('something happend');
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
        actions: [
          //BlocProvider.of<AuthBloc>(context).add(LogOutUser());
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          // decoration: BoxDecoration(color: Colors.red),
          height: size.height,
          width: size.width,
          child: reports.length == 0 && !loadingReports
              ? Container(
                  margin: const EdgeInsets.symmetric(vertical: 50),
                  child: Text('No Report Found', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                )
              : Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 20.0),

                      //!Filter Button
                      DropDown(
                        items: ["All", "Today", "This Week", "This Month", "This Year", "Custom Date"],
                        dropDownType: DropDownType.Button,
                        showUnderline: false,
                        hint: Text('All'),
                        icon: Container(
                          width: 100,
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.filter),
                              SizedBox(width: 10),
                              Text('Filter', style: TextStyle(fontSize: 18.0)),
                            ],
                          ),
                        ),
                        onChanged: (choice) {
                          // print(choice);
                          setState(() {
                            selectedFilter = choice.toString();
                          });
                          print('selectedFilter: $selectedFilter');
                          filterData(choice, context);
                        },
                      ),
                      SizedBox(height: 5.0),

                      loadingReports
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 50),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: selectedFilter != 'All' ? filteredReports.length : reports.length,
                                itemBuilder: (context, index) {
                                  List<Map<String, dynamic>> finalReports = selectedFilter != 'All' ? filteredReports : reports;
                                  return Center(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                      width: 600,
                                      padding: const EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: Offset(2, 7), blurRadius: 20)],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('Order', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                                          Divider(),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Created At', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['created_at']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Sender Name', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['sender_name']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Sender Phone', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['sender_phone']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Tester Name', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['tester_name']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Receiver Courier', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['receiver_courier']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Ordered For', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['ordered_for']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Courier Name', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['courier_name']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //!
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Courier Phone', style: TextStyle(fontSize: 16.0)),
                                              Text(finalReports[index]['courier_phone']),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
        ),
      ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 7), blurRadius: 20)],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Text(title),
          Divider(),
          Text(description),
        ],
      ),
    );
  }
}
