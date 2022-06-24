import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/colors.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> reports = [];
  bool loadingReports = true;

  @override
  void initState() {
    //!get firebase user id
    getUserReport();
    super.initState();
  }

  void getUserReport() async {
    List<Map<String, dynamic>> allOrders = [];
    final FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> ordersQuerySnapshot = await firestore.collection("orders").get();
    ordersQuerySnapshot.docs.forEach((doc) {
      allOrders.add(doc.data());
    });
    // print('all orders: $allOrders');
    //!get current user
    final User? user = auth.currentUser;
    final userId = user!.uid;

    //!get user detail from firestore
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore.collection("users").where('user_id', isEqualTo: userId).get();
    final userData = querySnapshot.docs[0].data();
    Map<String, dynamic> userReportPermissions = userData['permission'];
    // print('permission: $userReportPermissions');

    //!get order report based on permission
    switch (userReportPermissions['type']) {
      case 'Region':
        {
          // statements;
          String permissionRegion = userReportPermissions['region'];
          for (Map<String, dynamic> order in allOrders) {
            Map<String, dynamic> region = order['region'];
            // ignore: unnecessary_null_comparison
            if (region != null) {
              // print('permissionRegion: ${permissionRegion.replaceAll("\"", "")}  || zone name: ${region['name']}');
              if (permissionRegion.replaceAll("\"", "") == region['name']) {
                reports.add(order);
              }
            }
            // print(region);
          }
          setState(() {});
          // print(permissionRegion);
        }
        break;

      case 'Zone':
        {
          //statements;
          String permissionZone = userReportPermissions['zone'];
          for (Map<String, dynamic> order in allOrders) {
            Map<String, dynamic> region = order['region'];
            // ignore: unnecessary_null_comparison
            if (region != null) {
              // print(region['zones']);
              for (Map<String, dynamic> zone in region['zones']) {
                // print('zone: $zone');
                // print('permissionZone: ${permissionZone.replaceAll("\"", "")}  || zone name: ${zone['name']}');
                if (zone['name'] == permissionZone.replaceAll("\"", "")) {
                  reports.add(order);
                }
              }
            }
          }
          setState(() {});
          // print(permissionZone);
        }
        break;
      case 'Woreda':
        {
          //statements;
          String permissionWoreda = userReportPermissions['woreda'];
          for (Map<String, dynamic> order in allOrders) {
            Map<String, dynamic> region = order['region'];
            // ignore: unnecessary_null_comparison
            if (region != null) {
              // print(region['zones']);
              for (Map<String, dynamic> zone in region['zones']) {
                // print('zone: $zone');
                for (Map<String, dynamic> woreda in zone['woredas']) {
                  // print('permissionWoreda: ${permissionWoreda.replaceAll("\"", "")}  || woreda name: ${woreda['name']}');
                  if (permissionWoreda.replaceAll("\"", "") == woreda['name']) {
                    reports.add(order);
                  }
                }
              }
            }
          }
          setState(() {});
          // print(permissionWoreda);
        }
        break;
      default:
        {
          //statements;
          print('Something wrong happened');
        }
        break;
    }

    // print('reports: ${reports.length}');
    setState(() {
      loadingReports = false;
    });
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
      body: loadingReports
          ? Container(
              height: size.height,
              width: size.width,
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              // decoration: BoxDecoration(color: Colors.red),
              height: size.height,
              width: size.width,
              child: reports.length == 0 && !loadingReports
                  ? Center(
                      child: Container(child: Text('No Report Found', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                    )
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: 600,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: Offset(2, 7), blurRadius: 20)],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Created At', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['created_at']),
                                  ],
                                ),
                                SizedBox(height: 10),
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Sender Name', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['sender_name']),
                                  ],
                                ),
                                SizedBox(height: 10),
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Sender Phone', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['sender_phone']),
                                  ],
                                ),
                                SizedBox(height: 10),
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tester Name', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['tester_name']),
                                  ],
                                ),
                                SizedBox(height: 10),
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Receiver Courier', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['receiver_courier']),
                                  ],
                                ),
                                SizedBox(height: 10),
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Ordered For', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['ordered_for']),
                                  ],
                                ),
                                SizedBox(height: 10),
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Courier Name', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['courier_name']),
                                  ],
                                ),
                                SizedBox(height: 10),
                                //!
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Courier Phone', style: TextStyle(fontSize: 16.0)),
                                    Text(reports[index]['courier_phone']),
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
    );
  }
}
