import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kncv_flutter/data/models/models.dart';

class OrderRepository {
  final FirebaseFirestore database;
  final FirebaseAuth auth;

  OrderRepository(this.database, this.auth);

  //loading orders for senders
  // @params{}
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

  //loading orders for couriers
  // @params{}
  Future<List<Order>> loadOrdersForCourier() async {
    var ordersCollection = await database.collection('orders');
    String? currentUserId = auth.currentUser?.uid;
    var orders = await ordersCollection
        .where('courier_id', isEqualTo: currentUserId)
        .where('status', whereIn: [
      'Waiting for Confirmation',
      'Picked Up',
      'Arrived',
      'Confirmed',
      // 'Received',
    ]).get();
    return orders.docs
        .map((e) => Order.fromJson({...e.data(), 'id': e.id}))
        .toList();
  }

  //loading orders for test centers
  // @params{}
  Future<List<Order>> loadOrdersForTestCenters() async {
    var ordersCollection = await database.collection('orders');
    String? currentUserId = auth.currentUser?.uid;
    Map<String, dynamic>? testCenter =
        await getTestCenterByAdminUID(currentUserId ?? '');

    var orders = await ordersCollection
        .where('tester_id', isEqualTo: testCenter?['key'])
        .where('status', whereIn: [
      'Arrived',
      'Accepted',
      'Confirmed',
      'Received',
      'Picked Up',
      'Delivered'
    ]).get();
    return orders.docs
        .map((e) => Order.fromJson({...e.data(), 'id': e.id}))
        .toList();
  }

  //loading test center using the admin id
  // @params{}
  Future<Map<String, dynamic>?> getTestCenterByAdminUID(String id) async {
    var usersData = await database
        .collection('users')
        .where('user_id', isEqualTo: id)
        .get();
    if (usersData.docs.length > 0) {
      Map<String, dynamic> userData = usersData.docs[0].data()['test_center'];
      print('test center => ${userData}');
      return userData;
    }
  }

  //adding orders for senders
  // @params{courier_id, tester_id, courier_name and tester_name}

  String? getInitials(String val) {
    List<String> names = val.split(" ");
    String initials = '';
    for (var i = 0; i < names.length; i++) {
      initials += '${names[i][0]}';
    }
    return initials;
  }

  Future<String> addOrder({
    required String courier_id,
    required String tester_id,
    required String courier_name,
    required String tester_name,
    required String date,
    required String courier_phone,
    required String tester_phone,
  }) async {
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
    var usersCollection = database.collection('users');
    String? sender_name;
    String? sender_phone;
    var userData =
        await usersCollection.where('user_id', isEqualTo: sender_id).get();
    if (userData.docs.length > 0) {
      sender_name = userData.docs[0].data()['institution']['name'];
      sender_phone = userData.docs[0].data()['phone'];
    }
    var orders =
        await ordersCollection.where('sender_id', isEqualTo: sender_id).get();
    int length = orders.docs.length;

    String id =
        '${getInitials(sender_name ?? "") ?? ""}-${DateTime.now().toIso8601String().replaceAll('T', '_')}';
    id = id.substring(0, id.lastIndexOf('.'));
    id = '${id.substring(0, id.lastIndexOf(':'))}_${length + 1}';
    await ordersCollection.doc(id).set({
      'courier_id': courier_id,
      'sender_id': sender_id,
      'sender_name': sender_name,
      'tester_id': tester_id,
      'status': 'Draft',
      'created_at': '$day ${months[month - 1]} $year',
      'ordered_for': date,
      'tester_name': tester_name,
      'courier_name': courier_name,
      'tester_phone': tester_phone,
      'sender_phone': sender_phone,
      'courier_phone': courier_phone,
      'order_created': DateTime.now()
    });
    // var c = await ordersCollection.add({
    //   'courier_id': courier_id,
    //   'sender_id': sender_id,
    //   'sender_name': sender_name,
    //   'tester_id': tester_id,
    //   'status': 'Draft',
    //   'created_at': '$day ${months[month - 1]} $year',
    //   'ordered_for': date,
    //   'tester_name': tester_name,
    //   'courier_name': courier_name,
    //   'order_created': DateTime.now()
    // });
    return id;
  }

  Future<bool> editCourierInfo(
      {required String courier_id,
      required String tester_id,
      required String courier_name,
      required String tester_name,
      required String orderId}) async {
    var orderRef = await database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists) {
      await orderRef.update({
        'courier_id': courier_id,
        'courier_name': courier_name,
        'tester_id': tester_id,
        'tester_name': tester_name,
      });
      return true;
    }
    return false;
  }

  //loading couriers with the same zone as the sender
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

  //loading test centers with the same zone as the sender
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

  //load order with id
  //param {order_id : string}
  Future<Order?> loadSingleOrder({required String orderId}) async {
    var orderRef = await database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    return Order.fromJson({...?order.data(), 'id': order.id});
  }

  //editing patient info
  //params {order_id : string, patient : Patient and  index of the patient int}
  Future<bool> editPatientInfo(
      {required String orderId,
      required Patient patient,
      required int index}) async {
    var orderRef = await database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists) {
      List patientsList = order.data()?['patients'];
      patientsList[index] = patient.toJson();
      await orderRef.update({'patients': patientsList});
      return true;
    }
    return false;
  }

  static Future<bool> editSpecimenFeedback(
      {required Order order,
      required Patient patient,
      required int index}) async {
    var orderRef = await FirebaseFirestore.instance
        .collection('orders')
        .doc(order.orderId);
    var or = await orderRef.get();
    if (or.exists) {
      List patientsList = or.data()?['patients'];
      bool finishedAssessingPatient = true;
      patient.specimens?.forEach((specimen) {
        if (!specimen.assessed) {
          finishedAssessingPatient = false;
        }
      });

      if (finishedAssessingPatient) {
        patient.status = 'Inspected';
      }

      patientsList[index] = patient.toJson();

      bool assessed = allSpecimensAssessed(order);
      await orderRef.update({
        'patients': patientsList,
        'status': assessed ? 'Received' : 'Delivered',
      });

      return true;
    }
    return false;
  }

  static bool allSpecimensAssessed(Order order) {
    List<Specimen> specimens = [];
    order.patients?.forEach((e) => specimens = [...specimens, ...?e.specimens]);
    for (int i = 0; i < specimens.length; i++) {
      if (!specimens[i].assessed) {
        return false;
      }
    }
    return true;
  }

  static bool? allPatientsAreTested(Order order) {
    var o = order.patients ?? [];
    for (var patient in o) {
      if (patient.status != 'Draft') {
        return true;
      }
    }
    return false;
  }

  //editing patient info
  //params {order_id : string, patient : Patient and  index of the patient int}
  Future<bool> addTestResult(
      {required String? orderId,
      required Patient patient,
      required int index}) async {
    var orderRef = await database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists) {
      List patientsList = order.data()?['patients'];
      patientsList[index] = patient.toJson();
      await orderRef.update(
          {'patients': patientsList, 'test_result_added': DateTime.now()});
      return true;
    }
    return false;
  }

  //editing patient info
  //params {order_id : string, patient : Patient and  index of the patient int}
  Future<bool> editTestResult(
      {required String? orderId,
      required Patient patient,
      required int index}) async {
    var orderRef = await database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists) {
      List patientsList = order.data()?['patients'];
      patientsList[index] = patient.toJson();
      await orderRef.update(
          {'patients': patientsList, 'updated_test_result': DateTime.now()});
      return true;
    }
    return false;
  }

  Future<bool> deletePatientInfo(
      {required String orderId, required int index}) async {
    var orderRef = await database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists) {
      List patientsList = order.data()?['patients'];
      patientsList.removeAt(index);
      await orderRef.update({'patients': patientsList});
      return true;
    }
    return false;
  }

  static Future getTestCenters() async {}

  Future<Map<String, dynamic>> deleteOrder({required String orderId}) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();

    if (order.exists) {
      if (order.data()!['status'] == 'Draft' ||
          order.data()!['status'] == 'Waiting for Confirmation') {
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

  Future placeOrder({required String? orderId}) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists && order.data()!['status'] == 'Draft') {
      await orderRef.update({
        'status': 'Waiting for Confirmation',
        'order_placed': DateTime.now()
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> acceptOrder(String? orderId, String? time, String? date) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists && order.data()!['status'] == 'Waiting for Confirmation') {
      await orderRef.update({
        'status': 'Confirmed',
        'will_reach_at': '$date-$time',
        'order_confirmed': DateTime.now()
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> approveArrival(String? orderId, String receiver) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists && order.data()!['status'] == 'Confirmed') {
      await orderRef.update({
        'status': 'Picked Up',
        'receiver_courier': receiver,
        'order_pickedup': DateTime.now(),
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> courierApproveArrivalTester(
      String? orderId, String receiver, String phone) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists && order.data()!['status'] == 'Picked Up') {
      await orderRef.update({
        'status': 'Delivered',
        'receiver_tester': receiver,
        'receiver_phone_number': phone,
        'order_received': DateTime.now(),
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> approveArrivalTester(
      {required String? orderId,
      String? coldChainStatus,
      String? sputumCondition,
      String? stoolCondition}) async {
    var orderRef = database.collection('orders').doc(orderId);
    var order = await orderRef.get();
    if (order.exists && order.data()!['status'] == 'Received') {
      await orderRef.update({
        'status': 'Accepted',
        'sputumCondition': sputumCondition,
        'stoolCondition': stoolCondition,
        'order_accepted': DateTime.now()
      });
      return true;
    } else {
      return false;
    }
  }
}
