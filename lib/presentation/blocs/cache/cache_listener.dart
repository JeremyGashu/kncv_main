import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kncv_flutter/data/models/models.dart';

reflectCacheChangesOnFirebase(String orderId) async {
  Box<Order> cacheBox = Hive.box<Order>('cached_orders');
  DocumentReference<Map<String, dynamic>> orderRef =
      await FirebaseFirestore.instance.collection('orders').doc(orderId);
  DocumentSnapshot<Map<String, dynamic>> orderData = await orderRef.get();

  Order savedOrder = Order.fromJson(orderData.data() ?? {});
  Order? cachedOrder = cacheBox.get(orderId);
  List<Patient> patients = [];
  savedOrder.patients?.forEach((patient) {
    if (!(cachedOrder?.patients ?? []).any((p) => p.mr == patient.mr)) {
      // means the patient info is sent over the internet and it is not saved in cahce so save the one in firebase
      patients.add(patient);
    } else {
      // the patient info is also saved in cache and the remaining fields can be updated
      Patient? p = cachedOrder?.patients?.firstWhere((p) => p.mr == patient.mr);
      patient.address = patient.address ?? p?.address;
      patient.age = patient.age ?? p?.age;
      patient.ageMonths = patient.ageMonths ?? p?.ageMonths;
      patient.childhood = patient.childhood ?? p?.childhood;
      patient.dateOfBirth = patient.dateOfBirth ?? p?.dateOfBirth;
      patient.dm = patient.dm ?? p?.dm;
      patient.doctorInCharge = patient.doctorInCharge ?? p?.doctorInCharge;
      patient.examPurpose = patient.examPurpose ?? p?.examPurpose;
      patient.hiv = patient.hiv ?? p?.hiv;
      patient.malnutrition = patient.malnutrition ?? p?.malnutrition;
      patient.mr = patient.mr ?? p?.mr;
      patient.name = patient.name ?? p?.name;
      patient.phone = patient.phone ?? p?.phone;
      patient.pneumonia = patient.pneumonia ?? p?.pneumonia;
      patient.previousDrugUse = patient.previousDrugUse ?? p?.previousDrugUse;
      patient.reasonForTest = patient.reasonForTest ?? p?.reasonForTest;
      patient.recurrentPneumonia =
          patient.recurrentPneumonia ?? p?.recurrentPneumonia;
      patient.region = patient.region ?? p?.region;
      patient.registrationGroup =
          patient.registrationGroup ?? p?.registrationGroup;
      patient.remark = patient.remark ?? p?.remark;
      patient.requestedTest = patient.requestedTest ?? p?.requestedTest;
      patient.resultAvaiable = patient.resultAvaiable;
      patient.sex = patient.sex ?? p?.sex;
      patient.siteOfTB = patient.siteOfTB ?? p?.siteOfTB;
      patient.specimens = patient.specimens ?? p?.specimens;
      patient.status = patient.status ?? p?.status;
      patient.tb = patient.tb ?? p?.tb;
      patient.testResult = patient.testResult ?? p?.testResult;
      patient.woreda = patient.woreda ?? p?.woreda;
      patient.woreda_name = patient.woreda_name ?? p?.woreda_name;
      patient.zone = patient.zone ?? p?.zone;
      patient.zone_name = patient.woreda ?? p?.zone_name;
    }
  });

  Order mergedOrder = Order(
      courier: savedOrder.courier ?? cachedOrder?.courier,
      courierId: savedOrder.courierId ?? cachedOrder?.courierId,
      courier_name: savedOrder.courier_name ?? cachedOrder?.courier_name,
      courier_phone: savedOrder.courier_phone ?? cachedOrder?.courier_phone,
      created_at: savedOrder.created_at ?? cachedOrder?.created_at,
      notified_arrival: savedOrder.notified_arrival,
      orderId: savedOrder.orderId ?? cachedOrder?.orderId,
      region: savedOrder.region ?? cachedOrder?.region,
      sender: savedOrder.sender ?? cachedOrder?.sender,
      senderId: savedOrder.senderId ?? cachedOrder?.senderId,
      sender_name: savedOrder.sender_name ?? cachedOrder?.sender_name,
      sender_phone: savedOrder.sender_phone ?? cachedOrder?.sender_phone,
      status: savedOrder.status ?? cachedOrder?.status,
      testCenter: savedOrder.testCenter ?? cachedOrder?.testCenter,
      testCenterId: savedOrder.testCenterId ?? cachedOrder?.testCenterId,
      tester_name: savedOrder.tester_name ?? cachedOrder?.tester_name,
      tester_phone: savedOrder.tester_phone ?? cachedOrder?.tester_phone,
      zone: savedOrder.zone ?? cachedOrder?.zone,
      timestamp: savedOrder.timestamp ?? cachedOrder?.timestamp,
      order_created: savedOrder.order_created,
      patients: patients);

  orderRef.update(mergedOrder.toJson()).then((value) async {
    await cacheBox.delete(orderId);
    print('Updated order with ID $orderId and removed from cache.');
  });
}

StreamSubscription<ConnectivityResult> startListeningInternet() {
  print("Started listening to Internet availability check.");
  StreamSubscription<ConnectivityResult> subscription =
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet) {
      Box<Order> cacheBox = Hive.box<Order>('cached_orders');

      print(
          'Reflecting changes on orders === ${cacheBox.values.map((e) => e.toJson()).toList()}');
      cacheBox.values.map((order) {
        if (order.orderId != null) {}
        reflectCacheChangesOnFirebase(order.orderId!);
      });
    }
  });

  return subscription;
}
