import 'package:equatable/equatable.dart';

class Order {
  Order(
      {this.orderId,
      this.senderId,
      this.courierId,
      this.testCenterId,
      this.courier,
      this.testCenter,
      this.sender,
      this.timestamp,
      this.patients,
      this.status,
      this.tester_name,
      this.sender_name,
      this.sender_phone,
      this.courier_phone,
      this.tester_phone,
      this.created_at,
      this.courier_name});

  String? orderId;
  String? senderId;
  String? courierId;
  String? testCenterId;
  String? courier;
  String? testCenter;
  String? sender_name;
  String? sender;
  String? timestamp;
  String? status;
  List<Patient>? patients;
  String? tester_name;
  String? courier_name;
  String? created_at;
  String? sender_phone;
  String? tester_phone;
  String? courier_phone;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["id"],
        senderId: json["sender_id"],
        courierId: json["courier_id"],
        testCenterId: json["test_center_id"],
        courier: json["courier"],
        testCenter: json["test_center"],
        sender_name: json['sender_name'],
        sender: json["sender"],
        status: json['status'],
        sender_phone: json['sender_phone'],
        tester_phone: json['tester_phone'],
        courier_phone: json['courier_phone'],
        tester_name: json['tester_name'],
        courier_name: json['courier_name'],
        created_at: json['created_at'],
        timestamp: json["timestamp"],
        patients: json["patients"] != null
            ? List<Patient>.from(
                json["patients"].map((x) => Patient.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "sender_id": senderId,
        "courier_id": courierId,
        "test_center_id": testCenterId,
        'sender_name': sender_name,
        "courier": courier,
        "test_center": testCenter,
        'sender_phone': sender_phone,
        'tester_phone': tester_phone,
        'courier_phone': courier_phone,
        "sender": sender,
        "timestamp": timestamp,
        "patients": patients != null
            ? List<dynamic>.from(patients!.map((x) => x.toJson()))
            : [],
      };
}

class Patient {
  Patient(
      {this.mr,
      this.name,
      this.sex,
      this.age,
      this.zone,
      this.woreda,
      this.phone,
      this.tb,
      this.childhood,
      this.ageMonths,
      this.hiv,
      this.pneumonia,
      this.recurrentPneumonia,
      this.malnutrition,
      this.dm,
      this.doctorInCharge,
      this.siteOfTB,
      this.examPurpose,
      this.specimens,
      this.testResult,
      this.status,
      this.dateOfBirth,
      this.registrationGroup,
      this.reasonForTest,
      this.previousDrugUse,
      this.requestedTest,
      this.region,
      this.remark,
      this.resultAvaiable = false,
      this.address});

  String? mr;
  String? name;
  String? remark;
  String? sex;
  String? age;
  String? ageMonths;
  String? zone;
  String? woreda;
  String? previousDrugUse;
  String? registrationGroup;
  String? reasonForTest;
  String? requestedTest;
  String? phone;
  String? tb;
  String? childhood;
  String? address;
  String? hiv;
  String? pneumonia;
  String? recurrentPneumonia;
  String? malnutrition;
  String? status = 'Draft';
  String? dm;
  Region? region;
  String? doctorInCharge;
  String? siteOfTB;
  String? examPurpose;
  bool resultAvaiable;
  TestResult? testResult;
  List<Specimen>? specimens;
  String? dateOfBirth;

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        mr: json["MR"],
        name: json["name"],
        sex: json["sex"],
        age: json["age"],
        registrationGroup: json['registration_group'],
        zone: json["zone"],
        ageMonths: json['age_months'],
        woreda: json["woreda"],
        phone: json["phone"],
        region: json['region'] != null ? Region.fromJson(json['region']) : null,
        reasonForTest: json['reason_for_test'],
        address: json['address'],
        dateOfBirth: json['date_of_birth'],
        previousDrugUse: json['previous_drug_use'],
        tb: json["TB"],
        requestedTest: json['requested_test'],
        status: json['status'],
        remark: json['remark'],
        childhood: json["childhood"],
        resultAvaiable: json['result_available'] ?? false,
        hiv: json["HIV"],
        pneumonia: json["pneumonia"],
        testResult:
            json['result'] != null ? TestResult.fromJson(json['result']) : null,
        recurrentPneumonia: json["recurrent_pneumonia"],
        malnutrition: json["malnutrition"],
        dm: json["DM"],
        doctorInCharge: json["doctor_in_charge"],
        siteOfTB: json["anatomic_location"],
        examPurpose: json["exam_purpose"],
        specimens: List<Specimen>.from(
            json["specimens"].map((x) => Specimen.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "MR": mr,
        "name": name,
        "sex": sex,
        "age": age,
        'reason_for_test': reasonForTest,
        "zone": zone,
        "woreda": woreda,
        "phone": phone,
        'region': region?.toJson(),
        // "TB": tb,
        'requested_test': requestedTest,
        'registration_group': registrationGroup,
        'age_months': ageMonths,
        'status': status,
        // "childhood": childhood,
        // "HIV": hiv,
        // "pneumonia": pneumonia,
        'previous_drug_use': previousDrugUse,
        'remark': remark,
        "address": address,
        // "recurrent_pneumonia": recurrentPneumonia,
        // "malnutrition": malnutrition,
        // "DM": dm,
        // 'date_of_birth': dateOfBirth,
        'result': testResult?.toJson(),
        'result_available': resultAvaiable,
        "doctor_in_charge": doctorInCharge,
        "anatomic_location": siteOfTB,
        "exam_purpose": examPurpose,
        "specimens": specimens != null
            ? List<dynamic>.from(specimens!.map((x) => x.toJson()))
            : [],
      };
}

class Specimen {
  Specimen({
    this.type,
    this.id,
    this.examinationType,
    this.assessed = false,
    this.rejected = false,
    this.reason,
  });

  String? type;
  String? id;
  String? examinationType;
  bool assessed;
  bool rejected;
  String? reason;

  factory Specimen.fromJson(Map<String, dynamic> json) => Specimen(
        type: json["type"],
        id: json["id"],
        examinationType: json['examination_type'],
        reason: json['reason'],
        assessed: json['assessed'] ?? false,
        rejected: json['rejected'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        'examination_type': examinationType,
        'assessed': assessed,
        'rejected': rejected,
        'reason': reason,
      };
}

class TesterCourier {}

class Courier extends TesterCourier {
  final String name;
  final String phone;
  final String id;
  Courier({required this.name, required this.id, required this.phone});

  factory Courier.fromJson(Map<String, dynamic> json) =>
      Courier(name: json['name'], phone: json['phone'], id: json['id']);

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'id': id};

  @override
  String toString() {
    return name;
  }
}

class Tester extends TesterCourier {
  final String name;
  final String phone;
  final String id;
  Tester({required this.name, required this.id, required this.phone});

  factory Tester.fromJson(Map<String, dynamic> json) =>
      Tester(name: json['name'], phone: json['phone_number'], id: json['id']);

  Map<String, dynamic> toJson() =>
      {'name': name, 'phone_number': phone, 'id': id};

  @override
  String toString() {
    return name;
  }
}

class TestResult {
  TestResult({
    this.resultDate,
    this.resultTime,
    this.labRegistratinNumber,
    this.mtbResult,
    this.quantity,
    this.resultRr,
  });

  String? resultDate;
  String? resultTime;
  String? labRegistratinNumber;
  String? mtbResult;
  String? quantity;
  String? resultRr;

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
        resultDate: json["result_date"],
        resultTime: json["result_time"],
        labRegistratinNumber: json["lab_registratin_number"],
        mtbResult: json["mtb_result"],
        quantity: json["quantity"],
        resultRr: json["result_rr"],
      );

  Map<String, dynamic> toJson() => {
        "result_date": resultDate,
        "result_time": resultTime,
        "lab_registratin_number": labRegistratinNumber,
        "mtb_result": mtbResult,
        "quantity": quantity,
        "result_rr": resultRr,
      };
}

class NotificationModel {
  NotificationModel({
    this.userId,
    this.id,
    this.timestamp,
    this.content,
    this.seen = false,
    this.date,
  });

  String? userId;
  String? timestamp;
  String? content;
  String? id;
  bool seen;
  DateTime? date;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        userId: json["user_id"],
        timestamp: json["timestamp"],
        content: json["content"],
        seen: json["seen"],
        id: json['id'],
        // date: json['date'],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "timestamp": timestamp,
        "content": content,
        "seen": seen,
        'id': id,
        'date': date
      };
}

class Region extends Equatable {
  Region({
    required this.code,
    required this.name,
    required this.zones,
  });

  final String code;
  final String name;
  final List<Zone> zones;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        code: json["code"],
        name: json["name"],
        zones: json["zones"] != null
            ? List<Zone>.from(json["zones"].map((x) => Zone.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "zones": List<dynamic>.from(zones.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return this.name;
  }

  @override
  List<Object?> get props => [code, name, zones];
}

class Zone extends Equatable {
  Zone({
    required this.code,
    required this.name,
    required this.woredas,
  });

  final String code;
  final String name;
  final List<Woreda> woredas;

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        code: json["code"],
        name: json["name"],
        woredas: json["woredas"] != null
            ? List<Woreda>.from(json["woredas"].map((x) => Woreda.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "woredas": List<dynamic>.from(woredas.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return this.name;
  }

  @override
  List<Object?> get props => [code, name, woredas];
}

class Woreda extends Equatable {
  Woreda({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  factory Woreda.fromJson(Map<String, dynamic> json) => Woreda(
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };

  @override
  String toString() {
    return this.name;
  }

  @override
  List<Object?> get props => [code, name];
}
