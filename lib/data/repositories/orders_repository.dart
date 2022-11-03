import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/core/message_codes.dart';
import 'package:kncv_flutter/core/sms_handler.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepository {
  final FirebaseFirestore database;
  final FirebaseAuth auth;

  OrderRepository(this.database, this.auth);

  Box<Order> cacheBox = Hive.box<Order>('cached_orders');

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
          .orderBy('order_created', descending: true)
          .get();

      List<Order> os = orders.docs
          .map((e) => Order.fromJson({...e.data(), 'order_id': e.id}))
          .toList();

      await ordersBox.clear();
      await ordersBox.addAll(os);
      return os;
    } else {
      List<Order> orders = ordersBox.values.toList();
      orders.sort((a, b) {
        print('Timestamp created ===> ${a.order_created}');
        print('Timestamp created ===> ${b.order_created}');
        return b.order_created.toDate().compareTo(a.order_created.toDate());
        // return DateTime.parse(a.created_at!)
        //     .compareTo(DateTime.parse(b.created_at!));
      });
      return orders;
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
          .orderBy('order_created', descending: true)
          .get();
      List<Order> os = orders.docs
          .map((e) => Order.fromJson({...e.data(), 'order_id': e.id}))
          .toList();
      await ordersBox.clear();
      await ordersBox.addAll(os);
      return os;
    } else {
      List<Order> orders = ordersBox.values.toList();
      orders.sort((a, b) {
        print('Timestamp created ===> ${a.order_created}');
        print('Timestamp created ===> ${b.order_created}');
        return b.order_created.toDate().compareTo(a.order_created.toDate());
        // return DateTime.parse(a.created_at!)
        //     .compareTo(DateTime.parse(b.created_at!));
      });
      return orders;
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

      print('Load order for test center => ${testCenter?['key']}');

      var orders = await ordersCollection
          .where('tester_id', isEqualTo: testCenter?['key'])
          .orderBy('order_created', descending: true)
          .get();
      List<Order> os = orders.docs
          .map((e) => Order.fromJson({...e.data(), 'order_id': e.id}))
          .toList();
      await ordersBox.clear();
      await ordersBox.addAll(os);
      return os;
    } else {
      List<Order> orders = ordersBox.values.toList();
      orders.sort((a, b) {
        print('Timestamp created ===> ${a.order_created}');
        print('Timestamp created ===> ${b.order_created}');
        return b.order_created.toDate().compareTo(a.order_created.toDate());
        // return DateTime.parse(a.created_at!)
        //     .compareTo(DateTime.parse(b.created_at!));
      });
      return orders;
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
      Map<String, dynamic> userData = usersData.docs[0].data();
      print('Test Center ID ===> ${userData['test_center_id']}');
      userData['key'] = userData['test_center_id'];
      // print('test center => ${userData}');
      return userData;
    }

    return null;
  }

  static Future<Map<String, dynamic>?> getTestCenterFromAdminId(
      String id) async {
    //no need to check since it is called when internet is available
    var usersData = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: id)
        .get();
    if (usersData.docs.length > 0) {
      Map<String, dynamic> userData = usersData.docs[0].data();
      print('Test Center ID ===> ${userData['test_center_id']}');
      userData['key'] = userData['test_center_id'];
      // print('test center => ${userData}');
      return userData;
    }

    return null;
  }

  //adding orders for senders
  // @params{courier_id, tester_id, courier_name and tester_name}

  String? getInitials(String val) {
    List<String> names = val.trim().split(" ");
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
    // required Map woreda,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? sender_name = preferences.getString('sender_name');
    String? sender_phone = preferences.getString('sender_phone');

    String id =
        '${getInitials(sender_name ?? "") ?? ""}-${DateTime.now().toIso8601String().replaceAll('T', '_')}';
    id = id.substring(0, id.lastIndexOf('.'));
    id = '${id.substring(0, id.lastIndexOf(':'))}';

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

    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      String sender_id = auth.currentUser!.uid;
      var ordersCollection = await database.collection('orders');

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
        // 'woreda' : woreda,
      });
      return id;
    } else {
      try {
        String sender_id = auth.currentUser!.uid;

        Order order = Order(
            orderId: id,
            region: region,
            zone: zone,
            courierId: courier_id,
            senderId: sender_id,
            sender_name: sender_name,
            testCenterId: tester_id,
            tester_name: tester_name,
            status: 'Draft',
            created_at: '$day ${months[month - 1]} $year',
            courier_name: courier_name,
            tester_phone: tester_phone,
            sender_phone: sender_phone,
            courier_phone: courier_phone,
            order_created: Timestamp.now(),
            patients: []);

        //TODO -
        cacheBox.put(id, order).then((value) {
          print('Added order with value ${cacheBox.get(id)?.toJson()}');
        });

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

        // debugPrint('Sender data from user id  ======== ${userData.docs.length}');

      } catch (e) {
        // print('Error saving to firebase =====$e');
        String id = '${DateTime.now().toIso8601String().replaceAll('T', '_')}';

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

  //load order with id
  //param {order_id : string}
  Future<Order?> loadSingleOrder({required String orderId}) async {
    bool internetAvailable = await isConnectedToTheInternet();
    Box<Order> ordersBox = Hive.box<Order>('orders');

    if (internetAvailable) {
      var orderRef = await database.collection('orders').doc(orderId);
      var order = await orderRef.get();
      return Order.fromJson({...?order.data(), 'order_id': order.id});
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
      try {
        //TODO
        Order? cachedOrder = cacheBox.get(orderId);
        if (cachedOrder != null) {
          List<Patient> patients = cachedOrder.patients ?? [];
          patients[index] = patient;
          cachedOrder.patients = patients;
          cacheBox.put(orderId, cachedOrder);
        }

        // var orderRef = database.collection('orders').doc(orderId);
        // orderRef.get().then((order) {
        //   List patientsList = order.data()?['patients'];
        //   patientsList[index] = patient.toJson();
        //   orderRef.update({'patients': patientsList});
        // });
      } catch (e) {
        // print(err);
      }

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
    try {
      bool internetAvailable = await isConnectedToTheInternet();
      Box<Order> ordersBox = Hive.box<Order>('orders');

      bool assessed = allSpecimensAssessed(order);
      DocumentReference<Map<String, dynamic>> orderRef =
          FirebaseFirestore.instance.collection('orders').doc(order.orderId);

      if (internetAvailable) {
        DocumentSnapshot<Map> or = await orderRef.get();
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
          await orderRef.update({
            'patients': patientsList,
            'status': assessed ? 'Received' : 'Delivered',
          });
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

        // bool assessed = allSpecimensAssessed(order);

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

        //TODO -

        Box<Order> cacheBox = Hive.box<Order>('cached_orders');
        Order? cachedOrder = cacheBox.get(order.orderId);
        if (cachedOrder != null) {
          List<Patient> patients = cachedOrder.patients ?? [];
          bool finishedAssessingPatient = true;

          patient.specimens?.forEach((specimen) {
            if (!specimen.assessed) {
              finishedAssessingPatient = false;
            }

            if (finishedAssessingPatient) {
              patient.status = 'Inspected';
            }

            patients[index] = patient;
            cachedOrder.patients = patients;
            cacheBox.put(order.orderId, cachedOrder);
          });
        }
        return true;
      }
    } catch (e) {
      print(e);
      return false;
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

      //TODO -
      Order? cachedOrder = cacheBox.get(order.orderId);
      if (cachedOrder != null) {
        List<Patient> patients = cachedOrder.patients ?? [];
        patients[index] = patient;
        cachedOrder.patients = patients;
        cacheBox.put(order.orderId, cachedOrder);
      }

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

      //TODO -

      Order? cachedOrder = cacheBox.get(order.orderId);
      if (cachedOrder != null) {
        List<Patient> patients = cachedOrder.patients ?? [];
        patients[index] = patient;
        cachedOrder.patients = patients;
        cacheBox.put(order.orderId, cachedOrder);
      }

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
      await sendSMS(
        // context,
        to: '0931057901',
        payload: {
          'oid': orderId,
          'p': patient.toJsonSMS(),
        },
        action: ADD_PATIENT,
      );

      //TODO -

      Order? cachedOrder = cacheBox.get(orderId);
      if (cachedOrder != null) {
        List<Patient> ps = cachedOrder.patients ?? [];
        ps.add(patient);
        cachedOrder.patients = ps;
        cacheBox.put(orderId, cachedOrder);
      }

      Order order = orders.firstWhere((element) => element.orderId == orderId);
      orders.removeWhere((element) => element.orderId == orderId);
      order.patients?.add(patient);
      orders.add(order);

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
        // print('************************order placed***************');

        order.status = 'Waiting for Confirmation';
        // debugPrint('please sms ${order.orderId}');
        try {
          //RESPONSE ORDER_PLACED
          // await sendSmsViaListenerToEndUser(
          //   to: order.courier_phone ?? '',
          //   payload: {
          //     'o': order.toJsonSMS(),
          //     'response': true,
          //   },
          //   action: ORDER_PLACED,
          // );
          //RESPONSE ORDER_PLACED
          // await sendSmsViaListenerToEndUser(
          //   to: order.tester_phone ?? '',
          //   payload: {'o': order.toJsonSMS(), 'response': true},
          //   action: ORDER_PLACED,
          // );
        } catch (e) {
          print(e);
        }

        // sendCustomSMS(
        //     to: order.courier_phone ?? '',
        //     body:
        //         'New order is plaed for you from ${order.sender_name}. The order contains ${order.patients?.length} patient\'s specimen.');

        // sendCustomSMS(
        //     to: order.tester_phone ?? '',
        //     body:
        //         'New order is being transported to you from ${order.sender_name}. The order contains ${order.patients?.length} patient\'s specimen.');

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
    try {
      bool internetAvailable = await isConnectedToTheInternet();
      Box<Order> ordersBox = Hive.box<Order>('orders');

      if (internetAvailable) {
        // Waiting for Confirmation
        var orderRef = database.collection('orders').doc(orderId);
        var order = await orderRef.get();

        if (order.exists &&
            order.data()!['status'] == 'Waiting for Confirmation') {
          await orderRef.update({
            'status': 'Confirmed',
            'will_reach_at': '$date-$time',
            'order_confirmed': DateTime.now()
          });

          // Order o = Order.fromJson({...?order.data(), 'order_id': order.id});

          //RESPONSE ORDER_ACCEPTED
          // await sendSmsViaListenerToEndUser(
          //   to: o.sender_phone ?? '',
          //   payload: {'oid': orderId, 'response': true},
          //   action: ORDER_ACCEPTED,
          // );

          //RESPONSE ORDER_ACCEPTED
          // await sendSmsViaListenerToEndUser(
          //   to: o.tester_phone ?? '',
          //   payload: {'oid': orderId, 'response': true},
          //   action: ORDER_ACCEPTED,
          // );

          // sendCustomSMS(
          //     to: o.sender_phone ?? '',
          //     body:
          //         'One order got accepted. The selected courier\'s will notify you when they get at your place.');

          return true;
        } else {
          return false;
        }
      } else {
        List<Order> orders = await ordersBox.values.toList();
        Order order =
            orders.firstWhere((element) => element.orderId == orderId);
        if (order.status == 'Waiting for Confirmation') {
          orders.removeWhere((element) => element.orderId == orderId);
          order.status = 'Confirmed';
          orders.add(order);
          await ordersBox.clear();
          await ordersBox.addAll(orders);
          print('Here....');
          try {
            print('$orderId $date $time');
            sendSMS(
                to: '0931057901',
                payload: {
                  'oid': orderId ?? '',
                  'date': date ?? '',
                  'time': time ?? '',
                },
                action: COURIER_ACCEPT_ORDER);
          } catch (e, st) {
            print(st);
            throw new Exception(e);
          }

          return true;
        }
        return true;
      }

      /*

    */
    } catch (e) {
      print(e);
      return false;
    }
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

        // Order o = Order.fromJson({...?order.data(), 'order_id': order.id});

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        // await sendSmsViaListenerToEndUser(
        //   to: o.tester_phone ?? '',
        //   payload: {'oid': orderId},
        //   action: SENDER_APPROVED_COURIER_DEPARTURE,
        // );

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        // await sendSmsViaListenerToEndUser(
        //   to: o.courier_phone ?? '',
        //   payload: {'oid': orderId, 'response': true},
        //   action: SENDER_APPROVED_COURIER_DEPARTURE,
        // );

        // sendCustomSMS(
        //     to: o.tester_phone ?? '',
        //     body:
        //         'One order is picked up. It will be deliverd by ${o.courier_name}');

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

        // Order o = Order.fromJson({...?order.data(), 'order_id': order.id});

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        // await sendSmsViaListenerToEndUser(
        //   to: o.courier_phone ?? '',
        //   payload: {'oid': orderId, 'response': true},
        //   action: TESTER_APPROVED_COURIER_ARRIVAL,
        // );

        //RESPONSE SENDER_APPROVE_COURIER_DEPARTURE
        // await sendSmsViaListenerToEndUser(
        //   to: o.sender_phone ?? '',
        //   payload: {'oid': orderId, 'response': true},
        //   action: TESTER_APPROVED_COURIER_ARRIVAL,
        // );

        // sendCustomSMS(
        //     to: o.sender_phone ?? '',
        //     body: 'The order sent to ${o.tester_name} has been accepted!');

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
