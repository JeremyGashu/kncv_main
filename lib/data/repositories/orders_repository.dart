import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kncv_flutter/data/models/order.dart';
import 'package:kncv_flutter/data/models/patient.dart';
import 'package:kncv_flutter/data/models/specimen.dart';

class OrderRepository {
  final FirebaseFirestore database;

  OrderRepository(this.database);
  Future loadOrders({required String userId}) async {
    //TODO loads orders that belongs to the logged in user
  }

  Future addOrder({required OrderModel order}) async {
    //TODO add new order
  }
  Future deleteOrder({required String orderId}) async {
    //TODO delete saved order if it has not been fetched by the courier
  }

  Future addPatient(
      {required String orderId, required PatientModel patient}) async {
    //TODO add new patient information to order
  }

  Future editPatientInfo(
      {required OrderModel order,
      required String patientId,
      required PatientModel patient}) async {
    //TODO edit existing patient information to order
  }

  Future addSpecimenToPatient(
      {required String orderId,
      required String patientId,
      required SpecimenType specimen}) async {
    //TODO add new specimen type of the three types
  }

  Future deletePatient(
      {required String orderId, required String patientId}) async {
    //TODO delete user from order including its speciments and all the others
  }
}
