import 'package:equatable/equatable.dart';

class PatientModel extends Equatable {
  final String id;
  final String code;
  final String name;
  final String age;

  PatientModel(
      {required this.name,
      required this.age,
      required this.code,
      required this.id});
  @override
  List<Object> get props => [id, code, name, age];
}
