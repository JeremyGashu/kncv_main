import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<List<Map<String, dynamic>>?> getUserReport() async {
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> reports = [];
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    QuerySnapshot<Map<String, dynamic>> ordersQuerySnapshot =
        await firestore.collection("orders").get();
    ordersQuerySnapshot.docs.forEach((doc) {
      Map<String, dynamic> documentData = doc.data();
      documentData['orderId'] = doc.id;
      allOrders.add(documentData);
    });
    // print('all orders: $allOrders');
    //!get current user
    final User? user = auth.currentUser;
    final userId = user!.uid;

    //!get user detail from firestore
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection("users")
        .where('user_id', isEqualTo: userId)
        .get();
    final userData = querySnapshot.docs[0].data();
    Map<String, dynamic> userReportPermissions = userData['permission'];
    print('permission type : ${userReportPermissions['type']}');

    //!get order report based on permission
    // ignore: unnecessary_null_comparison
    if (userReportPermissions != null) {
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
            // setState(() {});
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
            // setState(() {});
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
                    if (permissionWoreda.replaceAll("\"", "") ==
                        woreda['name']) {
                      reports.add(order);
                    }
                  }
                }
              }
            }
            // setState(() {});
            // print(permissionWoreda);
          }
          break;
        case 'Facility':
          Map<String, dynamic>? permissionFacility =
              userReportPermissions['facility'] as Map<String, dynamic>;
          print('Permission Facility === > $userReportPermissions');
          for (Map<String, dynamic> order in allOrders) {
            String testCenterName = order['tester_name'];
            String senderName = order['sender_name'];
            // ignore: unnecessary_null_comparison
            if (testCenterName != null && senderName != null) {
              if ((permissionFacility['name'] == testCenterName) ||
                  (permissionFacility['name'] == senderName)) {
                reports.add(order);
              }
              // print(region['zones']);
              // for (Map<String, dynamic> zone in region['zones']) {
              // print('zone: $zone');
              // print('permissionZone: ${permissionZone.replaceAll("\"", "")}  || zone name: ${zone['name']}');

              // }
            }
          }
          break;

        case null:
          Map<String, dynamic>? permissionFacility =
              userReportPermissions['facility'] as Map<String, dynamic>;
          // print('Permission Facility === > $userReportPermissions');
          for (Map<String, dynamic> order in allOrders) {
            String testCenterName = order['tester_name'];
            String senderName = order['sender_name'];
            // ignore: unnecessary_null_comparison
            if (testCenterName != null && senderName != null) {
              if ((permissionFacility['name'] == testCenterName) ||
                  (permissionFacility['name'] == senderName)) {
                reports.add(order);
              }
              // print(region['zones']);
              // for (Map<String, dynamic> zone in region['zones']) {
              // print('zone: $zone');
              // print('permissionZone: ${permissionZone.replaceAll("\"", "")}  || zone name: ${zone['name']}');

              // }
            }
          }
          break;

        case 'Federal':
          {
            return allOrders;
          }
        // break;
        default:
          return [];
        // break;
      }
    } else {
      return [];
    }

    // print('reports: ${reports.length}');
    // setState(() {
    //   loadingReports = false;
    // });
    return reports;
  } catch (e, src) {
    print(src);
    throw Exception(e);
    // return null;
  }
}

//!
bool isReportDateSameAsToday(report) {
  final todaysDate = DateTime.now();
  DateTime reportDate = report['order_created'].toDate();
  // print("Today Year: ${todaysDate.year}  || Report Year: ${reportDate.year}");
  // print("Today Month: ${todaysDate.month}  || Report Month: ${reportDate.month}");
  // print("Today Day: ${todaysDate.day}  || Report Day: ${reportDate.day}");
  if (reportDate.year == todaysDate.year) {
    if (reportDate.month == todaysDate.month) {
      if (reportDate.day == todaysDate.day) {
        return true;
      }
    }
  }
  return false;
}

bool isReportDateSameAsThisMonth(report) {
  final todaysDate = DateTime.now();
  DateTime reportDate = report['order_created'].toDate();
  if (reportDate.year == todaysDate.year) {
    if (reportDate.month == todaysDate.month) {
      return true;
    }
  }
  return false;
}

bool isReportDateSameAsThisYear(report) {
  final todaysDate = DateTime.now();
  DateTime reportDate = report['order_created'].toDate();
  if (reportDate.year == todaysDate.year) {
    return true;
  }
  return false;
}

bool isReportDateWithInThePast7Days(report) {
  final todayDate = DateTime.now();
  DateTime reportDate = report['order_created'].toDate();
  DateTime date7DaysAgo = todayDate.subtract(Duration(days: 7));
  if (reportDate.isAfter(date7DaysAgo) && reportDate.isBefore(todayDate)) {
    return true;
  }
  return false;
}
