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
  final String courier_phone;
  final String tester_phone;
  final String date;

  AddOrder({
    required this.courier_id,
    required this.tester_id,
    required this.courier_name,
    required this.tester_name,
    required this.date,
    required this.courier_phone,
    required this.tester_phone,
  });
  @override
  List<Object> get props =>
      [tester_id, courier_id, date, courier_name, tester_name];
}

class EditOrder extends OrderEvents {
  final String tester_id;
  final String courier_id;
  final String courier_name;
  final String tester_name;
  final String orderId;

  EditOrder(
      {required this.courier_id,
      required this.tester_id,
      required this.courier_name,
      required this.tester_name,
      required this.orderId});
  @override
  List<Object> get props =>
      [tester_id, courier_id, courier_name, tester_name, this.orderId];
}

class LoadSingleOrder extends OrderEvents {
  final String orderId;

  LoadSingleOrder({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class DeleteOrders extends OrderEvents {
  final Order order;

  DeleteOrders({required this.order});

  @override
  List<Object> get props => [order];
}

class AcceptOrderCourier extends OrderEvents {
  final Order order;
  final String time;
  final String date;

  AcceptOrderCourier(this.order, this.time, this.date);
  @override
  List<Object> get props => [order, time, date];
}

class ApproveArrivalCourier extends OrderEvents {
  final Order order;
  final String receiver;

  ApproveArrivalCourier(this.order, this.receiver);
  @override
  List<Object> get props => [order, receiver];
}

class CourierApproveArrivalToTestCenter extends OrderEvents {
  final Order order;
  final String receiver;
  final String phone;

  CourierApproveArrivalToTestCenter(this.order, this.receiver, this.phone);
  @override
  List<Object> get props => [order, receiver, phone];
}

class PlaceOrder extends OrderEvents {
  final Order order;

  PlaceOrder({required this.order});

  @override
  List<Object> get props => [order];
}

class AddPatientToOrder extends OrderEvents {
  final String orderId;
  final Patient patient;

  AddPatientToOrder({required this.orderId, required this.patient});

  @override
  List<Object> get props => [orderId, patient];
}

class EditPtientInfo extends OrderEvents {
  final String orderId;
  final Patient patient;
  final int index;
  EditPtientInfo(
      {required this.index, required this.patient, required this.orderId});
  @override
  List<Object> get props => [index, patient, patient];
}

class AddTestResult extends OrderEvents {
  final String orderId;
  final Patient patient;
  final int index;
  AddTestResult(
      {required this.index, required this.patient, required this.orderId});
  @override
  List<Object> get props => [index, patient, patient];
}

class EditTestResult extends OrderEvents {
  final String orderId;
  final Patient patient;
  final int index;
  EditTestResult(
      {required this.index, required this.patient, required this.orderId});
  @override
  List<Object> get props => [index, patient, patient];
}

class AddSpecimenToPatient extends OrderEvents {
  final String orderId;
  final String patientId;
  final Specimen specimen;

  AddSpecimenToPatient(
      {required this.orderId, required this.patientId, required this.specimen});
}

class ApproveArrivalTester extends OrderEvents {
  final Order order;
  final String? sputumCondition;
  final String? stoolCondition;
  final String? coldChainStatus;

  ApproveArrivalTester(
      {required this.order,
      required this.stoolCondition,
      required this.sputumCondition,
      required this.coldChainStatus});
}

class LoadOrdersForCourier extends OrderEvents {
  @override
  List<Object> get props => [];
}

class LoadOrdersForTester extends OrderEvents {
  @override
  List<Object> get props => [];
}

class DeletePatient extends OrderEvents {
  final String orderId;
  final int index;

  DeletePatient({required this.orderId, required this.index});
}
