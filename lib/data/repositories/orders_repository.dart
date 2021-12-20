import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kncv_flutter/data/models/models.dart';

class OrderRepository {
  final FirebaseFirestore database;
  final FirebaseAuth auth;

  OrderRepository(this.database, this.auth);
  Future<List<Order>> loadOrders() async {
    var ordersCollection = await database.collection('orders');
    String? currentUserId = auth.currentUser?.uid;
    var orders = await ordersCollection
        .where('sender_id', isEqualTo: currentUserId)
        .get();
    return orders.docs
        .map((e) => Order.fromJson({...e.data(), 'id': e.id}))
        .toList();
  }

  Future addOrder(
      {required String courier_id,
      required String tester_id,
      required String courier_name,
      required String tester_name}) async {
    String sender_id = auth.currentUser!.uid;
    var ordersCollection = await database.collection('orders');
    int month = DateTime.now().month;
    int day = DateTime.now().day;
    int year = DateTime.now().year;
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    await ordersCollection.add({
      'courier_id': courier_id,
      'sender_id': sender_id,
      'tester_id': tester_id,
      'status': 'Draft',
      'created_at': '$day ${months[month - 1]} $year',
      'tester_name': tester_name,
      'courier_name': courier_name,
    });
  }

  Future<List> getCouriersWithSameZone() async {
    var usersCollection = await database.collection('users');
    String? currentUserId = auth.currentUser?.uid;
    var userData =
        await usersCollection.where('user_id', isEqualTo: currentUserId).get();
    List filteredUser = userData.docs.map((e) => e.data()).toList();
    if (filteredUser.length > 0) {
      Map user = filteredUser[0];
      var usersData = await database
          .collection('users')
          .where('type', isEqualTo: 'COURIER_ADMIN')
          .where('zone', isEqualTo: user['institution.zone'])
          .get();
      return usersData.docs.map((e) => {...e.data(), 'id': e.id}).toList();
      //           .where('type', isEqualTo: "COURIER_ADMIN")
      // .where('zone', isEqualTo: user["institution"]["zone"])
    }
    return [];
  }

  Future<List> getTestCentersWithSameZone() async {
    var usersCollection = await database.collection('users');
    String? currentUserId = auth.currentUser?.uid;
    var userData =
        await usersCollection.where('user_id', isEqualTo: currentUserId).get();
    List filteredUser = userData.docs.map((e) => e.data()).toList();
    if (filteredUser.length > 0) {
      Map user = filteredUser[0];
      var testCenterData = await database
          .collection('test_centers')
          .where('zone', isEqualTo: user["institution.zone"])
          .get();
      return testCenterData.docs.map((e) => {...e.data(), 'id': e.id}).toList();
    }
    return [];
  }

  Future<Order?> loadSingleOrder({required String orderId}) async {
    var order = await database.collection('orders').doc(orderId).get();
    return Order.fromJson({...?order.data(), 'id': order.id});
  }

  static Future getTestCenters() async {}

  Future<Map<String, dynamic>> deleteOrder({required String orderId}) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();

    if (order.exists) {
      if (order.data()!['status'] == 'Draft' ||
          order.data()!['status'] == 'Waiting Confirmation') {
        await orderRef.delete();
        return {'success': true};
      } else {
        return {'success': false, 'message': 'You cant delete this order!'};
      }
    }
    return {'success': false, 'message': 'No data with the given ID!'};
  }

  Future addPatient({required String orderId, required Patient patient}) async {
    await database.collection('orders').doc(orderId).update({
      "patients": FieldValue.arrayUnion([patient.toJson()])
    });
  }

  Future deletePatient(
      {required String orderId, required Patient patient}) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();

    if (order.exists) {
      if (order.data()!['status'] == 'Draft' ||
          order.data()!['status'] == 'Waiting Confirmation') {
        await orderRef.update({
          "patients": FieldValue.arrayRemove([patient.toJson()]),
        });
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Cant delete patient!!'};
      }
    }
    return {'success': false, 'message': 'No data with the given ID!'};
  }

  Future<Map<String, dynamic>?> getInstitutionDataFromUserId() async {
    String? currentUserId = auth.currentUser?.uid;
    var user = await database
        .collection('users')
        .where('user_id', isEqualTo: currentUserId)
        .limit(1)
        .get();
    if (user.docs.length > 0) {
      return user.docs[0].data();
    }
    return null;
  }

  Future placeOrder({required String orderId}) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists && order.data()!['status'] == 'Draft') {
      await orderRef.update({'status': 'Waiting Confirmation'});
      return true;
    } else {
      return false;
    }
  }

  Future editPatientInfo(
      {required Order order,
      required String patientId,
      required Patient patient}) async {
    //TODO edit existing patient information to order
  }

}
