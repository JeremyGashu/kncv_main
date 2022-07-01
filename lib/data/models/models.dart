import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../presentation/pages/notificatins.dart';
part 'models.g.dart';

@HiveType(typeId: 1)
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
      this.notified_arrival = false,
      this.created_at,
      this.courier_name});

  @HiveField(0)
  String? orderId;
  @HiveField(1)
  String? senderId;
  @HiveField(2)
  String? courierId;
  @HiveField(3)
  String? testCenterId;
  @HiveField(4)
  String? courier;
  @HiveField(5)
  String? testCenter;
  @HiveField(6)
  String? sender_name;
  @HiveField(7)
  String? sender;
  @HiveField(8)
  String? timestamp;
  @HiveField(9)
  String? status;
  @HiveField(10)
  List<Patient>? patients;
  @HiveField(11)
  String? tester_name;
  @HiveField(12)
  String? courier_name;
  @HiveField(13)
  String? created_at;
  @HiveField(14)
  String? sender_phone;
  @HiveField(15)
  String? tester_phone;
  @HiveField(16)
  String? courier_phone;
  @HiveField(17)
  bool notified_arrival;
  @HiveField(18)
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
        notified_arrival: json['notified_arrival'] ?? false,
        timestamp: json["timestamp"] ?? '',
        patients: json["patients"] != null ? List<Patient>.from(json["patients"].map((x) => Patient.fromJson(x))) : [],
      );

  factory Order.fromJsonSMS(Map<String, dynamic> json) => Order(
        orderId: json["oid"],
        senderId: json["sid"],
        courierId: json["cid"],
        testCenterId: json["tid"],
        courier: json["courier"],
        testCenter: json["test_center"],
        sender_name: json['sn'],
        sender: json["sn"],
        status: json['status'],
        sender_phone: json['sp'],
        tester_phone: json['tp'],
        courier_phone: json['cp'],
        tester_name: json['tn'],
        courier_name: json['cn'],
        created_at: json['created_at'],
        notified_arrival: json['notified_arrival'] ?? false,
        timestamp: json["timestamp"] ?? '',
        patients: json["p"] != null ? List<Patient>.from(json["p"].map((x) => Patient.fromJson(x))) : [],
      );

  Map<String, dynamic> toJsonSMS() => {
        "oid": orderId,
        "sid": senderId,
        "cid": courierId,
        "tid": testCenterId,
        'sp': sender_phone,
        'tp': tester_phone,
        'cp': courier_phone,
        'sn': sender_name,
        'tn': tester_name,
        'cn': courier_name,
        "p": patients != null ? List<dynamic>.from(patients!.map((x) => x.toJsonSMS())) : [],
      };

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
        'notified_arrival': notified_arrival,
        "sender": sender,
        "timestamp": timestamp,
        "patients": patients != null ? List<dynamic>.from(patients!.map((x) => x.toJson())) : [],
      };
}

@HiveType(typeId: 2)
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
      this.zone_name,
      this.woreda_name,
      this.resultAvaiable = false,
      this.address});

  @HiveField(0)
  String? mr;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? remark;
  @HiveField(3)
  String? sex;
  @HiveField(4)
  String? age;
  @HiveField(5)
  String? ageMonths;
  @HiveField(6)
  String? zone;
  @HiveField(7)
  String? woreda;
  @HiveField(8)
  String? previousDrugUse;
  @HiveField(9)
  String? registrationGroup;
  @HiveField(10)
  String? reasonForTest;
  @HiveField(11)
  String? requestedTest;
  @HiveField(12)
  String? phone;
  @HiveField(13)
  String? tb;
  @HiveField(14)
  String? childhood;
  @HiveField(15)
  String? address;
  @HiveField(16)
  String? hiv;
  @HiveField(17)
  String? pneumonia;
  @HiveField(18)
  String? recurrentPneumonia;
  @HiveField(19)
  String? malnutrition;
  @HiveField(20)
  String? status = 'Draft';
  @HiveField(21)
  String? dm;
  @HiveField(22)
  Region? region;
  @HiveField(23)
  String? doctorInCharge;
  @HiveField(24)
  String? siteOfTB;
  @HiveField(25)
  String? examPurpose;
  @HiveField(26)
  bool resultAvaiable;
  @HiveField(27)
  TestResult? testResult;
  @HiveField(28)
  List<Specimen>? specimens;
  @HiveField(29)
  String? dateOfBirth;
  @HiveField(30)
  String? zone_name;
  @HiveField(31)
  String? woreda_name;
  @HiveField(32)
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
        woreda_name: json['woreda_name'],
        zone_name: json['zone_name'],
        status: json['status'],
        remark: json['remark'],
        childhood: json["childhood"],
        resultAvaiable: json['result_available'] ?? false,
        hiv: json["HIV"],
        pneumonia: json["pneumonia"],
        testResult: json['result'] != null ? TestResult.fromJson(json['result']) : null,
        recurrentPneumonia: json["recurrent_pneumonia"],
        malnutrition: json["malnutrition"],
        dm: json["DM"],
        doctorInCharge: json["doctor_in_charge"],
        siteOfTB: json["anatomic_location"],
        examPurpose: json["exam_purpose"],
        specimens: List<Specimen>.from(json["specimens"].map((x) => Specimen.fromJson(x))),
      );

  // Map<String, dynamic> toJsonSMS() => {
  //       "MR": mr,
  //       "name": name,
  //       'reason_for_test': reasonForTest,
  //       'requested_test': requestedTest,
  //       'result': testResult?.toJson(),
  //       'registration_group': registrationGroup,
  //       'previous_drug_use': previousDrugUse,
  //       'result_available': resultAvaiable,
  //       "anatomic_location": siteOfTB,
  //       "exam_purpose": examPurpose,
  //       "specimens": specimens != null
  //           ? List<dynamic>.from(specimens!.map((x) => x.toJson()))
  //           : [],
  //     };

  Map<String, dynamic> toJsonSMS() => {
        "MR": mr,
        "name": name,
        'status': status,
        // 'reason_for_test': reasonForTest,
        // 'requested_test': requestedTest,
        // 'registration_group': registrationGroup,
        // 'previous_drug_use': previousDrugUse,
        'result': testResult?.toJson(),
        'result_available': resultAvaiable,
        // "anatomic_location": siteOfTB,
        // "exam_purpose": examPurpose,
        "specimens": specimens != null ? List<dynamic>.from(specimens!.map((x) => x.toJson())) : [],
      };

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
        'zone_name': zone_name,
        'woreda_name': woreda_name,
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
        "specimens": specimens != null ? List<dynamic>.from(specimens!.map((x) => x.toJson())) : [],
      };
}

@HiveType(typeId: 3)
class Specimen {
  Specimen({this.type, this.id, this.examinationType, this.assessed = false, this.rejected = false, this.reason, this.testResult, this.testResultAddedAt});

  @HiveField(0)
  String? type;
  @HiveField(1)
  String? id;
  @HiveField(2)
  String? examinationType;
  @HiveField(3)
  bool assessed;
  @HiveField(4)
  bool rejected;
  @HiveField(5)
  String? reason;
  @HiveField(6)
  TestResult? testResult;
  @HiveField(7)
  DateTime? testResultAddedAt;

  factory Specimen.fromJson(Map<String, dynamic> json) {
    // Timestamp? timestamp = json['testResultAddedAt'];
    // DateTime? dateTime = timestamp?.toDate();

    return Specimen(
      type: json["type"],
      id: json["id"],
      examinationType: json['examination_type'],
      reason: json['reason'],
      testResult: json["result"] != null ? TestResult.fromJson(json['result']) : null,
      assessed: json['assessed'] ?? false,
      rejected: json['rejected'] ?? false,
      testResultAddedAt: json["testResultAddedAt"] == null ? null : DateTime.parse(json["testResultAddedAt"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        'examination_type': examinationType,
        'assessed': assessed,
        'rejected': rejected,
        'result': testResult?.toJson(),
        'reason': reason,
        'testResultAddedAt': testResultAddedAt?.toIso8601String(),
      };
}

class TesterCourier {}

@HiveType(typeId: 4)
class Courier extends TesterCourier {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String phone;
  @HiveField(2)
  final String id;
  Courier({required this.name, required this.id, required this.phone});

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(name: json['name'], phone: json['phone_number'], id: json['id']);

  Map<String, dynamic> toJson() => {'name': name, 'phone_number': phone, 'id': id};

  @override
  String toString() {
    return name;
  }
}

@HiveType(typeId: 5)
class Tester extends TesterCourier {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String phone;
  @HiveField(2)
  final String id;
  @HiveField(3)
  final Map? region;
  @HiveField(4)
  final Map? zone;
  Tester({required this.name, required this.id, required this.phone, this.zone, this.region});

  factory Tester.fromJson(Map<String, dynamic> json) => Tester(
        name: json['name'],
        phone: json['phone_number'],
        id: json['id'],
        zone: json['zone'],
        region: json['region'],
      );

  Map<String, dynamic> toJson() => {'name': name, 'phone_number': phone, 'id': id};

  @override
  String toString() {
    return name;
  }
}

@HiveType(typeId: 6)
class TestResult {
  TestResult({
    this.resultDate,
    this.resultTime,
    this.labRegistratinNumber,
    this.mtbResult,
    this.quantity,
    this.resultRr,
  });

  @HiveField(0)
  String? resultDate;
  @HiveField(1)
  String? resultTime;
  @HiveField(2)
  String? labRegistratinNumber;
  @HiveField(3)
  String? mtbResult;
  @HiveField(4)
  String? quantity;
  @HiveField(5)
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

@HiveType(typeId: 7)
class NotificationModel {
  NotificationModel({
    this.userId,
    this.id,
    this.timestamp,
    this.content,
    this.seen = false,
    this.date,
    this.action,
    this.payload,
  });

  @HiveField(0)
  String? userId;
  @HiveField(1)
  String? timestamp;
  @HiveField(2)
  String? content;
  @HiveField(3)
  String? id;
  @HiveField(4)
  bool seen;
  @HiveField(5)
  DateTime? date;
  @HiveField(6)
  NotificationAction? action;
  @HiveField(7)
  Map? payload;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
      userId: json["user_id"],
      timestamp: json["timestamp"],
      content: json["content"],
      seen: json["seen"],
      id: json['id'],
      action: json['action'] != null ? NotificationAction.values.elementAt(json['action']) : null,
      payload: json['payload']);

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "timestamp": timestamp,
        "content": content,
        "seen": seen,
        'id': id,
        'date': date,
        'action': action?.index ?? -1,
        'payload': payload,
      };
}

@HiveType(typeId: 8)
class Region extends Equatable {
  Region({
    required this.code,
    required this.name,
    required this.zones,
  });

  @HiveField(0)
  final String code;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Zone> zones;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        code: json["code"],
        name: json["name"],
        zones: json["zones"] != null ? List<Zone>.from(json["zones"].map((x) => Zone.fromJson(x))) : [],
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

@HiveType(typeId: 9)
class Zone extends Equatable {
  Zone({
    required this.code,
    required this.name,
    required this.woredas,
  });

  @HiveField(0)
  final String code;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Woreda> woredas;

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        code: json["code"],
        name: json["name"],
        woredas: json["woredas"] != null ? List<Woreda>.from(json["woredas"].map((x) => Woreda.fromJson(x))) : [],
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

@HiveType(typeId: 10)
class Woreda extends Equatable {
  Woreda({
    required this.code,
    required this.name,
  });

  @HiveField(0)
  final String code;
  @HiveField(1)
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
