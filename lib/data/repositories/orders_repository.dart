import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/core/message_codes.dart';
import 'package:kncv_flutter/core/sms_handler.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/sms/sms_response_codes.dart';

class OrderRepository {
  final FirebaseFirestore database;
  final FirebaseAuth auth;

  OrderRepository(this.database, this.auth);

  //loading orders for senders
  // @params{}
  Future<List<Order>> loadOrders() async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');
    if (internetAvailable) {
      var ordersCollection = await database.collection('orders');
      String? currentUserId = auth.currentUser?.uid;
      var orders = await ordersCollection
          .where('sender_id', isEqualTo: currentUserId)
          .get();

      List<Order> os = orders.docs
          .map((e) => Order.fromJson({...e.data(), 'id': e.id}))
          .toList();

      await ordersBox.clear();
      await ordersBox.addAll(os);
      return os;
    } else {
      return ordersBox.values.toList();
    }
  }

  //loading orders for couriers
  // @params{}
  Future<List<Order>> loadOrdersForCourier() async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var ordersCollection = await database.collection('orders');
      String? currentUserId = auth.currentUser?.uid;
      var orders = await ordersCollection
          .where('courier_id', isEqualTo: currentUserId)
          .where('status', whereIn: [
        'Waiting for Confirmation',
        'Picked Up',
        'Arrived',
        'Confirmed',
        'Received',
        'Delivered',
        'Tested',
        'Accepted',
      ]).get();
      List<Order> os = orders.docs
          .map((e) => Order.fromJson({...e.data(), 'id': e.id}))
          .toList();
      await ordersBox.clear();
      await ordersBox.addAll(os);
      return os;
    } else {
      return ordersBox.values.toList();
    }
  }

  //loading orders for test centers
  // @params{}
  Future<List<Order>> loadOrdersForTestCenters() async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var ordersCollection = await database.collection('orders');
      String? currentUserId = auth.currentUser?.uid;
      Map<String, dynamic>? testCenter =
          await getTestCenterByAdminUID(currentUserId ?? '');

      var orders = await ordersCollection
          .where('tester_id', isEqualTo: testCenter?['key'])
          .get();
      List<Order> os = orders.docs
          .map((e) => Order.fromJson({...e.data(), 'id': e.id}))
          .toList();
      await ordersBox.clear();
      await ordersBox.addAll(os);
      return os;
    } else {
      return ordersBox.values.toList();
    }
  }

  //loading test center using the admin id
  // @params{}
  Future<Map<String, dynamic>?> getTestCenterByAdminUID(String id) async {
    //no need to check since it is called when internet is available
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
    required String sender_id,
    required Map region,
    required Map zone,
  }) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
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
      debugPrint('Sender data from user id  ======== ${userData.docs.length}');

      if (userData.docs.length > 0) {
        sender_name = userData.docs[0].data()['institution']['name'];
        sender_phone = userData.docs[0].data()['phone_number'];
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
        'order_created': DateTime.now(),
        'region': region,
        'zone': zone,
      });
      return id;
    } else {
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

      String id = '${DateTime.now().toIso8601String().replaceAll('T', '_')}';

      Order order = Order(
        orderId: id,
        courierId: courier_id,
        senderId: sender_id,
        // sender_name: sender_name,
        testCenterId: tester_id,
        status: 'Draft',
        created_at: '$day ${months[month - 1]} $year',
        tester_name: tester_name,
        courier_name: courier_name,
        tester_phone: tester_phone,
        // sender_phone: sender_phone,
        courier_phone: courier_phone,
        patients: [],
        sender: '',
        timestamp: '$day ${months[month - 1]} $year',
      );
      await ordersBox.add(order);

      //send sms here
      await sendSMS(
        // context,
        to: '0931057901',
        payload: {
          'oid': id,
          'cid': courier_id,
          'tid': tester_id,
          'cn': courier_name,
          'tn': tester_name,
          'd': '$day ${months[month - 1]} $year',
          'cp': courier_phone,
          'tp': tester_phone,
          'sid': sender_id,
        },
        action: ADD_ORDER,
      );

      return id;
    }
  }

  Future<bool> editShipmentInfo(
      {required String courier_id,
      required String tester_id,
      required String courier_name,
      required String tester_name,
      required String orderId}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
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
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((order) => order.orderId == orderId);
      orders.removeWhere((order) => order.orderId == orderId);
      order.courierId = courier_id;
      order.courier_name = courier_name;
      order.testCenterId = tester_id;
      order.tester_name = tester_name;
      orders.add(order);
      await ordersBox.clear();
      await ordersBox.addAll(orders);
      await sendSMS(
        // context,
        to: '0931057901',
        payload: {
          'oid': orderId,
          'cid': courier_id,
          'tid': tester_id,
          'cn': courier_name,
          'tn': tester_name,
        },
        action: EDIT_SHIPMENT_INFO,
      );

      return true;
    }
  }

  //loading couriers with the same zone as the sender
  // Future<List> getCouriersWithSameZone() async {
  //   var usersCollection = await database.collection('users');
  //   String? currentUserId = auth.currentUser?.uid;
  //   var userData =
  //       await usersCollection.where('user_id', isEqualTo: currentUserId).get();
  //   List filteredUser = userData.docs.map((e) => e.data()).toList();
  //   if (filteredUser.length > 0) {
  //     Map user = filteredUser[0];
  //     var usersData = await database
  //         .collection('users')
  //         .where('type', isEqualTo: 'COURIER_ADMIN')
  //         .where('zone', isEqualTo: user['institution.zone'])
  //         .get();
  //     return usersData.docs.map((e) => {...e.data(), 'id': e.id}).toList();
  //     //           .where('type', isEqualTo: "COURIER_ADMIN")
  //     // .where('zone', isEqualTo: user["institution"]["zone"])
  //   }
  //   return [];
  // }

  //loading test centers with the same zone as the sender
  // Future<List> getTestCentersWithSameZone() async {
  //   var usersCollection = await database.collection('users');
  //   String? currentUserId = auth.currentUser?.uid;
  //   var userData =
  //       await usersCollection.where('user_id', isEqualTo: currentUserId).get();
  //   List filteredUser = userData.docs.map((e) => e.data()).toList();
  //   if (filteredUser.length > 0) {
  //     Map user = filteredUser[0];
  //     var testCenterData = await database
  //         .collection('test_centers')
  //         .where('zone', isEqualTo: user["institution.zone"])
  //         .get();
  //     return testCenterData.docs.map((e) => {...e.data(), 'id': e.id}).toList();
  //   }
  //   return [];
  // }

  //load order with id
  //param {order_id : string}
  Future<Order?> loadSingleOrder({required String orderId}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = await database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      return Order.fromJson({...?order.data(), 'id': order.id});
    } else {
      List<Order> orders = await ordersBox.values.toList();
      return orders.firstWhere((order) => order.orderId == orderId);
    }
  }

  //editing patient info
  //params {order_id : string, patient : Patient and  index of the patient int}
  Future<bool> editPatientInfo(
      {required String orderId,
      required Patient patient,
      required int index}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = await database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      if (order.exists) {
        List patientsList = order.data()?['patients'];
        patientsList[index] = patient.toJson();
        await orderRef.update({'patients': patientsList});
        return true;
      }
      return false;
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((order) => order.orderId == orderId);
      orders.removeWhere((order) => order.orderId == orderId);
      order.patients?[index] = patient;
      orders.add(order);
      await ordersBox.clear();
      await ordersBox.addAll(orders);
      //send sms
      await sendSMS(
        // context,
        to: '0931057901',
        payload: {
          'oid': orderId,
          'p': patient.toJsonSMS(),
          'i': index,
        },
        action: EDIT_PATIENT_INFO,
      );
      return true;
    }
  }

  static Future<bool> editSpecimenFeedback(
      {required Order order,
      required Patient patient,
      required int index}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
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

        //RESPONSE SPECIMEN_EDITED
        await sendSmsViaListenerToEndUser(
          to: order.sender_phone ?? '',
          payload: {
            'oid': order.orderId,
            'p': patient.toJsonSMS(),
            'i': index,
          },
          action: SPECIMEN_EDITED,
        );

        return true;
      }
      return false;
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order =
          orders.firstWhere((order) => order.orderId == order.orderId);
      orders.removeWhere((order) => order.orderId == order.orderId);

      List<Patient>? patientsList = order.patients;
      bool finishedAssessingPatient = true;
      patient.specimens?.forEach((specimen) {
        if (!specimen.assessed) {
          finishedAssessingPatient = false;
        }
      });

      if (finishedAssessingPatient) {
        patient.status = 'Inspected';
      }

      patientsList?[index] = patient;

      bool assessed = allSpecimensAssessed(order);

      order.status = assessed ? 'Received' : 'Delivered';
      order.patients = patientsList;

      order.patients?[index] = patient;
      orders.add(order);
      await ordersBox.clear();
      await ordersBox.addAll(orders);

      await sendSMS(
        to: '0931057901',
        payload: {
          'oid': order.orderId,
          'p': patient.toJsonSMS(),
          'i': index,
        },
        action: EDIT_SPECIMEN_FEEDBACK,
      );

      return true;
    }
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
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = await database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      if (order.exists) {
        List patientsList = order.data()?['patients'];
        patientsList[index] = patient.toJson();
        await orderRef.update(
            {'patients': patientsList, 'test_result_added': DateTime.now()});

        Order o = Order.fromJson(order.data()!);

        //RESPONSE SPECIMEN_EDITED
        await sendSmsViaListenerToEndUser(
          to: o.sender_phone ?? '',
          payload: {
            'oid': orderId,
            'p': patient.toJsonSMS(),
            'i': index,
          },
          action: SPECIMEN_EDITED,
        );

        sendCustomSMS(
            to: o.sender_phone ?? '',
            body: 'Test Result has been added to patient ${patient.name}.');

        return true;
      }
      return false;
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order =
          orders.firstWhere((order) => order.orderId == order.orderId);
      orders.removeWhere((order) => order.orderId == order.orderId);
      order.patients?[index] = patient;

      orders.add(order);
      await ordersBox.clear();
      await ordersBox.addAll(orders);

      await sendSMS(
          to: '0931057901',
          payload: {
            'oid': orderId,
            'i': index,
            'p': patient.toJsonSMS(),
          },
          action: TESTER_ADD_TEST_RESULT);

      return true;
    }
  }

  //editing patient info
  //params {order_id : string, patient : Patient and  index of the patient int}
  Future<bool> editTestResult(
      {required String? orderId,
      required Patient patient,
      required int index}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');
    if (internetAvailable) {
      var orderRef = await database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      if (order.exists) {
        List patientsList = order.data()?['patients'];
        patientsList[index] = patient.toJson();
        await orderRef.update(
            {'patients': patientsList, 'updated_test_result': DateTime.now()});

        Order o = Order.fromJson(order.data()!);

        await sendSmsViaListenerToEndUser(
          to: o.sender_phone ?? '',
          payload: {
            'oid': orderId,
            'p': patient.toJsonSMS(),
            'i': index,
          },
          action: SPECIMEN_EDITED,
        );

        sendCustomSMS(
            to: o.sender_phone ?? '',
            body: 'Test Result has been edited to patient ${patient.name}.');

        return true;
      }
      return false;
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order =
          orders.firstWhere((order) => order.orderId == order.orderId);
      orders.removeWhere((order) => order.orderId == order.orderId);
      order.patients?[index] = patient;

      orders.add(order);
      await ordersBox.clear();
      await ordersBox.addAll(orders);

      await sendSMS(
          to: '0931057901',
          payload: {
            'oid': orderId,
            'i': index,
            'p': patient.toJsonSMS(),
          },
          action: EDIT_TEST_RESULT);

      return true;
    }
  }

  Future<bool> deletePatientInfo(
      {required String orderId, required int index}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = await database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      if (order.exists) {
        List patientsList = order.data()?['patients'];
        patientsList.removeAt(index);
        await orderRef.update({'patients': patientsList});
        return true;
      }
      return false;
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((order) => orderId == order.orderId);
      orders.removeWhere((element) => element.orderId == orderId);
      order.patients?.removeAt(index);
      orders.add(order);

      await ordersBox.clear();
      await ordersBox.addAll(orders);

      await sendSMS(
        // context,
        to: '0931057901',
        payload: {
          'oid': orderId,
          'i': index,
        },
        action: DELETE_PATIENT,
      );

      return true;
    }
  }

  static Future getTestCenters() async {}

  Future<Map<String, dynamic>> deleteOrder({required String orderId}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
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
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((element) => element.orderId == orderId);
      if (order.status == 'Draft' ||
          order.status == 'Waiting for Confirmation') {
        orders.removeWhere((element) => element.orderId == orderId);

        await ordersBox.clear();
        await ordersBox.addAll(orders);
        await sendSMS(
          // context,
          to: '0931057901',
          payload: {
            'oid': orderId,
          },
          action: DELETE_ORDER,
        );
        return {'success': true};
      } else {
        return {'success': false, 'message': 'No data with the given ID!'};
      }
    }
  }

  Future addPatient({required String orderId, required Patient patient}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');
    List<Order> orders = await ordersBox.values.toList();

    if (internetAvailable) {
      await database.collection('orders').doc(orderId).update({
        "patients": FieldValue.arrayUnion([patient.toJson()])
      });

      Order order = orders.firstWhere((element) => element.orderId == orderId);
      orders.removeWhere((element) => element.orderId == orderId);
      order.patients?.add(patient);
      orders.add(order);

      await ordersBox.clear();
      await ordersBox.addAll(orders);
    } else {
      Order order = orders.firstWhere((element) => element.orderId == orderId);
      orders.removeWhere((element) => element.orderId == orderId);
      order.patients?.add(patient);
      orders.add(order);

      await sendSMS(
        // context,
        to: '0931057901',
        payload: {
          'oid': orderId,
          'p': patient.toJsonSMS(),
        },
        action: ADD_PATIENT,
      );

      await ordersBox.clear();
      await ordersBox.addAll(orders);
    }
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

  Future placeOrder({required Order order}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');
    if (internetAvailable) {
      var orderRef = database.collection('orders').doc(order.orderId);
      if (order.status == 'Draft') {
        await orderRef.update({
          'status': 'Waiting for Confirmation',
          'order_placed': DateTime.now()
        });

        order.status = 'Waiting for Confirmation';
        debugPrint('please sms ${order.orderId}');
        //RESPONSE ORDER_PLACED
        await sendSmsViaListenerToEndUser(
          to: order.courier_phone ?? '',
          payload: {
            'o': order.toJsonSMS(),
            'response': true,
          },
          action: ORDER_PLACED,
        );

        //RESPONSE ORDER_PLACED
        await sendSmsViaListenerToEndUser(
          to: order.tester_phone ?? '',
          payload: {'o': order.toJsonSMS(), 'response': true},
          action: ORDER_PLACED,
        );

        sendCustomSMS(
            to: order.courier_phone ?? '',
            body:
                'New order is plaed for you from ${order.sender_name}. The order contains ${order.patients?.length} patient\'s specimen.');

        sendCustomSMS(
            to: order.tester_phone ?? '',
            body:
                'New order is being transported to you from ${order.sender_name}. The order contains ${order.patients?.length} patient\'s specimen.');

        return true;
      } else {
        return false;
      }
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order or =
          orders.firstWhere((element) => element.orderId == order.orderId);
      if (or.status == 'Draft' || or.status == 'Waiting for Confirmation') {
        orders.removeWhere((element) => element.orderId == or.orderId);
        or.status = 'Waiting for Confirmation';
        orders.add(or);
        await ordersBox.clear();
        await ordersBox.addAll(orders);
        await sendSMS(
            to: '0931057901',
            payload: {
              'oid': order.orderId,
            },
            action: PLACE_ORDER);

        return true;
      }
      return false;
    }
  }

  Future<bool> acceptOrder(String? orderId, String? time, String? date) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      if (order.exists &&
          order.data()!['status'] == 'Waiting for Confirmation') {
        await orderRef.update({
          'status': 'Confirmed',
          'will_reach_at': '$date-$time',
          'order_confirmed': DateTime.now()
        });

        Order o = Order.fromJson(order.data()!);

        //RESPONSE ORDER_ACCEPTED
        await sendSmsViaListenerToEndUser(
          to: o.sender_phone ?? '',
          payload: {'oid': orderId, 'response': true},
          action: ORDER_ACCEPTED,
        );

        //RESPONSE ORDER_ACCEPTED
        await sendSmsViaListenerToEndUser(
          to: o.tester_phone ?? '',
          payload: {'oid': orderId, 'response': true},
          action: ORDER_ACCEPTED,
        );

        sendCustomSMS(
            to: o.sender_phone ?? '',
            body:
                'One order got accepted. The selected courier\'s will notify you when they get at your place.');

        return true;
      } else {
        return false;
      }
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((element) => element.orderId == orderId);
      if (order.status == 'Waiting for Confirmation') {
        orders.removeWhere((element) => element.orderId == orderId);
        order.status = 'Confirmed';
        orders.add(order);
        await ordersBox.clear();
        await ordersBox.addAll(orders);
        await sendSMS(
            to: '0931057901',
            payload: {
              'oid': orderId,
              'date': date ?? '',
              'time': time ?? '',
            },
            action: COURIER_ACCEPT_ORDER);

        return true;
      }
      return false;
    }

    /*

    */
  }

  Future<bool> approveArrival(String? orderId, String receiver) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');
    if (internetAvailable) {
      var orderRef = database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      if (order.exists && order.data()!['status'] == 'Confirmed') {
        await orderRef.update({
          'status': 'Picked Up',
          'receiver_courier': receiver,
          'order_pickedup': DateTime.now(),
        });

        Order o = Order.fromJson(order.data()!);

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        await sendSmsViaListenerToEndUser(
          to: o.tester_phone ?? '',
          payload: {'oid': orderId},
          action: SENDER_APPROVED_COURIER_DEPARTURE,
        );

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        await sendSmsViaListenerToEndUser(
          to: o.courier_phone ?? '',
          payload: {'oid': orderId, 'response': true},
          action: SENDER_APPROVED_COURIER_DEPARTURE,
        );

        sendCustomSMS(
            to: o.tester_phone ?? '',
            body:
                'One order is picked up. It will be deliverd by ${o.courier_name}');

        return true;
      } else {
        return false;
      }
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((element) => element.orderId == orderId);
      if (order.status == 'Confirmed') {
        orders.removeWhere((element) => element.orderId == orderId);
        order.status = 'Picked Up';
        orders.add(order);
        await ordersBox.clear();
        await ordersBox.addAll(orders);

        await sendSMS(
            to: '0931057901',
            payload: {'oid': orderId, 'cn': receiver},
            action: SENDER_APPROVE_COURIER_ARRIVAL);
      }
      return true;
    }
  }

  Future<bool> courierApproveArrivalTester(
      String? orderId, String receiver, String phone) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      if (order.exists && order.data()!['status'] == 'Picked Up') {
        await orderRef.update({
          'status': 'Delivered',
          'receiver_tester': receiver,
          'receiver_phone_number': phone,
          'order_received': DateTime.now(),
        });

        Order o = Order.fromJson(order.data()!);

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        await sendSmsViaListenerToEndUser(
          to: o.courier_phone ?? '',
          payload: {'oid': orderId, 'response': true},
          action: TESTER_APPROVED_COURIER_ARRIVAL,
        );

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        await sendSmsViaListenerToEndUser(
          to: o.sender_phone ?? '',
          payload: {'oid': orderId, 'response': true},
          action: TESTER_APPROVED_COURIER_ARRIVAL,
        );

        sendCustomSMS(
            to: o.sender_phone ?? '',
            body: 'The order sent to ${o.tester_name} has been accepted!');

        return true;
      } else {
        return false;
      }
    } else {
      List<Order> orders = await ordersBox.values.toList();
      Order order = orders.firstWhere((element) => element.orderId == orderId);
      if (order.status == 'Picked Up') {
        orders.removeWhere((element) => element.orderId == orderId);
        order.status = 'Delivered';
        orders.add(order);
        await ordersBox.clear();
        await ordersBox.addAll(orders);

        await sendSMS(
            to: '0931057901',
            payload: {
              'oid': orderId,
              'rn': receiver,
              'rp': phone,
            },
            action: TESTER_APPROVE_COURIER_ARRIVAL);
        return true;
      }
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
