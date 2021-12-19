import 'package:equatable/equatable.dart';
import 'package:kncv_flutter/data/models/models.dart';

class OrderEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadOrders extends OrderEvents {
  @override
  List<Object> get props => [];
}

class AddOrder extends OrderEvents {
  final String tester_id;
  final String courier_id;
  final String courier_name;
  final String tester_name;

  AddOrder(
      {required this.courier_id,
      required this.tester_id,
      required this.courier_name,
      required this.tester_name});
  @override
  List<Object> get props => [tester_id, courier_id];
}

class LoadSingleOrder extends OrderEvents {
  final String orderId;

  LoadSingleOrder({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class DeleteOrders extends OrderEvents {
  final String orderId;

  DeleteOrders({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class AddPatientToOrder extends OrderEvents {
  final String orderId;
  final Patient patient;

  AddPatientToOrder({required this.orderId, required this.patient});

  @override
  List<Object> get props => [orderId, patient];
}

class EditPtientInfo extends OrderEvents {
  final Order order;
  final String patientId;
  final Patient patient;
  EditPtientInfo(
      {required this.order, required this.patientId, required this.patient});
  @override
  List<Object> get props => [order, patientId, patient];
}

class AddSpecimenToPatient extends OrderEvents {
  final String orderId;
  final String patientId;
  final Specimen specimen;

  AddSpecimenToPatient(
      {required this.orderId, required this.patientId, required this.specimen});
}

class DeletePatient extends OrderEvents {
  final String orderId;
  final String patientId;

  DeletePatient({required this.orderId, required this.patientId});
}
