// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 1;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      orderId: fields[0] as String?,
      senderId: fields[1] as String?,
      courierId: fields[2] as String?,
      testCenterId: fields[3] as String?,
      courier: fields[4] as String?,
      testCenter: fields[5] as String?,
      sender: fields[7] as String?,
      timestamp: fields[8] as String?,
      patients: (fields[10] as List?)?.cast<Patient>(),
      status: fields[9] as String?,
      tester_name: fields[11] as String?,
      sender_name: fields[6] as String?,
      sender_phone: fields[14] as String?,
      courier_phone: fields[16] as String?,
      tester_phone: fields[15] as String?,
      notified_arrival: fields[17] as bool,
      created_at: fields[13] as String?,
      courier_name: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.courierId)
      ..writeByte(3)
      ..write(obj.testCenterId)
      ..writeByte(4)
      ..write(obj.courier)
      ..writeByte(5)
      ..write(obj.testCenter)
      ..writeByte(6)
      ..write(obj.sender_name)
      ..writeByte(7)
      ..write(obj.sender)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.patients)
      ..writeByte(11)
      ..write(obj.tester_name)
      ..writeByte(12)
      ..write(obj.courier_name)
      ..writeByte(13)
      ..write(obj.created_at)
      ..writeByte(14)
      ..write(obj.sender_phone)
      ..writeByte(15)
      ..write(obj.tester_phone)
      ..writeByte(16)
      ..write(obj.courier_phone)
      ..writeByte(17)
      ..write(obj.notified_arrival);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 2;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      mr: fields[0] as String?,
      name: fields[1] as String?,
      sex: fields[3] as String?,
      age: fields[4] as String?,
      zone: fields[6] as String?,
      woreda: fields[7] as String?,
      phone: fields[12] as String?,
      tb: fields[13] as String?,
      childhood: fields[14] as String?,
      ageMonths: fields[5] as String?,
      hiv: fields[16] as String?,
      pneumonia: fields[17] as String?,
      recurrentPneumonia: fields[18] as String?,
      malnutrition: fields[19] as String?,
      dm: fields[21] as String?,
      doctorInCharge: fields[23] as String?,
      siteOfTB: fields[24] as String?,
      examPurpose: fields[25] as String?,
      specimens: (fields[28] as List?)?.cast<Specimen>(),
      testResult: fields[27] as TestResult?,
      status: fields[20] as String?,
      dateOfBirth: fields[29] as String?,
      registrationGroup: fields[9] as String?,
      reasonForTest: fields[10] as String?,
      previousDrugUse: fields[8] as String?,
      requestedTest: fields[11] as String?,
      region: fields[22] as Region?,
      remark: fields[2] as String?,
      zone_name: fields[30] as String?,
      woreda_name: fields[31] as String?,
      resultAvaiable: fields[26] as bool,
      address: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(32)
      ..writeByte(0)
      ..write(obj.mr)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.remark)
      ..writeByte(3)
      ..write(obj.sex)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.ageMonths)
      ..writeByte(6)
      ..write(obj.zone)
      ..writeByte(7)
      ..write(obj.woreda)
      ..writeByte(8)
      ..write(obj.previousDrugUse)
      ..writeByte(9)
      ..write(obj.registrationGroup)
      ..writeByte(10)
      ..write(obj.reasonForTest)
      ..writeByte(11)
      ..write(obj.requestedTest)
      ..writeByte(12)
      ..write(obj.phone)
      ..writeByte(13)
      ..write(obj.tb)
      ..writeByte(14)
      ..write(obj.childhood)
      ..writeByte(15)
      ..write(obj.address)
      ..writeByte(16)
      ..write(obj.hiv)
      ..writeByte(17)
      ..write(obj.pneumonia)
      ..writeByte(18)
      ..write(obj.recurrentPneumonia)
      ..writeByte(19)
      ..write(obj.malnutrition)
      ..writeByte(20)
      ..write(obj.status)
      ..writeByte(21)
      ..write(obj.dm)
      ..writeByte(22)
      ..write(obj.region)
      ..writeByte(23)
      ..write(obj.doctorInCharge)
      ..writeByte(24)
      ..write(obj.siteOfTB)
      ..writeByte(25)
      ..write(obj.examPurpose)
      ..writeByte(26)
      ..write(obj.resultAvaiable)
      ..writeByte(27)
      ..write(obj.testResult)
      ..writeByte(28)
      ..write(obj.specimens)
      ..writeByte(29)
      ..write(obj.dateOfBirth)
      ..writeByte(30)
      ..write(obj.zone_name)
      ..writeByte(31)
      ..write(obj.woreda_name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpecimenAdapter extends TypeAdapter<Specimen> {
  @override
  final int typeId = 3;

  @override
  Specimen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Specimen(
      type: fields[0] as String?,
      id: fields[1] as String?,
      examinationType: fields[2] as String?,
      assessed: fields[3] as bool,
      rejected: fields[4] as bool,
      reason: fields[5] as String?,
      testResult: fields[6] as TestResult?,
      testResultAddedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Specimen obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.examinationType)
      ..writeByte(3)
      ..write(obj.assessed)
      ..writeByte(4)
      ..write(obj.rejected)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.testResult)
      ..writeByte(7)
      ..write(obj.testResultAddedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecimenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CourierAdapter extends TypeAdapter<Courier> {
  @override
  final int typeId = 4;

  @override
  Courier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Courier(
      name: fields[0] as String,
      id: fields[2] as String,
      phone: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Courier obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TesterAdapter extends TypeAdapter<Tester> {
  @override
  final int typeId = 5;

  @override
  Tester read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tester(
      name: fields[0] as String,
      id: fields[2] as String,
      phone: fields[1] as String,
      zone: (fields[4] as Map?)?.cast<dynamic, dynamic>(),
      region: (fields[3] as Map?)?.cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Tester obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.region)
      ..writeByte(4)
      ..write(obj.zone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TesterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TestResultAdapter extends TypeAdapter<TestResult> {
  @override
  final int typeId = 6;

  @override
  TestResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestResult(
      resultDate: fields[0] as String?,
      resultTime: fields[1] as String?,
      labRegistratinNumber: fields[2] as String?,
      mtbResult: fields[3] as String?,
      quantity: fields[4] as String?,
      resultRr: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TestResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.resultDate)
      ..writeByte(1)
      ..write(obj.resultTime)
      ..writeByte(2)
      ..write(obj.labRegistratinNumber)
      ..writeByte(3)
      ..write(obj.mtbResult)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.resultRr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 7;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      userId: fields[0] as String?,
      id: fields[3] as String?,
      timestamp: fields[1] as String?,
      content: fields[2] as String?,
      seen: fields[4] as bool,
      date: fields[5] as DateTime?,
      action: fields[6] as NotificationAction?,
      payload: (fields[7] as Map?)?.cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.seen)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.action)
      ..writeByte(7)
      ..write(obj.payload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RegionAdapter extends TypeAdapter<Region> {
  @override
  final int typeId = 8;

  @override
  Region read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Region(
      code: fields[0] as String,
      name: fields[1] as String,
      zones: (fields[2] as List).cast<Zone>(),
    );
  }

  @override
  void write(BinaryWriter writer, Region obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.zones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ZoneAdapter extends TypeAdapter<Zone> {
  @override
  final int typeId = 9;

  @override
  Zone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Zone(
      code: fields[0] as String,
      name: fields[1] as String,
      woredas: (fields[2] as List).cast<Woreda>(),
    );
  }

  @override
  void write(BinaryWriter writer, Zone obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.woredas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WoredaAdapter extends TypeAdapter<Woreda> {
  @override
  final int typeId = 10;

  @override
  Woreda read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Woreda(
      code: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Woreda obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WoredaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
