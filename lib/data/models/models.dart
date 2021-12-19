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
      this.created_at,
      this.courier_name});

  String? orderId;
  String? senderId;
  String? courierId;
  String? testCenterId;
  String? courier;
  String? testCenter;
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
  Patient({
    this.mr,
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
    this.address
  });

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
  String? dm;
  String? doctorInCharge;
  String? anatomicLocation;
  String? examPurpose;
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
        childhood: json["childhood"],
        hiv: json["HIV"],
        pneumonia: json["pneumonia"],
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
        "childhood": childhood,
        "HIV": hiv,
        "pneumonia": pneumonia,
        "address": address,
        "recurrent_pneumonia": recurrentPneumonia,
        "malnutrition": malnutrition,
        "DM": dm,
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
