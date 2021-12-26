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
      this.hiv,
      this.pneumonia,
      this.recurrentPneumonia,
      this.malnutrition,
      this.dm,
      this.doctorInCharge,
      this.anatomicLocation,
      this.examPurpose,
      this.specimens,
      this.testResult,
      this.status,
      this.resultAvaiable = false,
      this.address});

  String? mr;
  String? name;
  String? sex;
  String? age;
  String? zone;
  String? woreda;
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
  String? doctorInCharge;
  String? anatomicLocation;
  String? examPurpose;
  bool resultAvaiable;
  TestResult? testResult;
  List<Specimen>? specimens;

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        mr: json["MR"],
        name: json["name"],
        sex: json["sex"],
        age: json["age"],
        zone: json["zone"],
        woreda: json["woreda"],
        phone: json["phone"],
        tb: json["TB"],
        status: json['status'],
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
        anatomicLocation: json["anatomic_location"],
        examPurpose: json["exam_purpose"],
        specimens: List<Specimen>.from(
            json["specimens"].map((x) => Specimen.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "MR": mr,
        "name": name,
        "sex": sex,
        "age": age,
        "zone": zone,
        "woreda": woreda,
        "phone": phone,
        "TB": tb,
        'status': status,
        "childhood": childhood,
        "HIV": hiv,
        "pneumonia": pneumonia,
        "address": address,
        "recurrent_pneumonia": recurrentPneumonia,
        "malnutrition": malnutrition,
        "DM": dm,
        'result': testResult?.toJson(),
        'result_available': resultAvaiable,
        "doctor_in_charge": doctorInCharge,
        "anatomic_location": anatomicLocation,
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
  });

  String? type;
  String? id;

  factory Specimen.fromJson(Map<String, dynamic> json) => Specimen(
        type: json["type"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
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

//Test Rrsult

// To parse this JSON data, do
//
//     final testResult = testResultFromJson(jsonString);

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
  });

  String? userId;
  String? timestamp;
  String? content;
  String? id;
  bool seen;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
          userId: json["user_id"],
          timestamp: json["timestamp"],
          content: json["content"],
          seen: json["seen"],
          id: json['id']);

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "timestamp": timestamp,
        "content": content,
        "seen": seen,
        'id': id,
      };
}
