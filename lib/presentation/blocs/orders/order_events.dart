import 'package:equatable/equatable.dart';
import 'package:kncv_flutter/data/models/order.dart';
import 'package:kncv_flutter/data/models/patient.dart';
import 'package:kncv_flutter/data/models/specimen.dart';

class OrderEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadOrders extends OrderEvents {
  final String userId;

  LoadOrders({required this.userId});

  @override
  List<Object> get props => [userId];
}

class AddOrder extends OrderEvents {
  final OrderModel order;

  AddOrder({required this.order});
  @override
  List<Object> get props => [order];
}

class DeleteOrders extends OrderEvents {
  final String orderId;

  DeleteOrders({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class AddPatientToOrder extends OrderEvents {
  final String orderId;
  final PatientModel patient;

  AddPatientToOrder({required this.orderId, required this.patient});

  @override
  List<Object> get props => [orderId, patient];
}

class EditPtientInfo extends OrderEvents {
  final OrderModel order;
  final String patientId;
  final PatientModel patient;
  EditPtientInfo(
      {required this.order, required this.patientId, required this.patient});
  @override
  List<Object> get props => [order, patientId, patient];
}

class AddSpecimenToPatient extends OrderEvents {
  final String orderId;
  final String patientId;
  final SpecimenType specimen;

  AddSpecimenToPatient(
      {required this.orderId, required this.patientId, required this.specimen});
}

class DeletePatient extends OrderEvents {
  final String orderId;
  final String patientId;

  DeletePatient({required this.orderId, required this.patientId});
}
