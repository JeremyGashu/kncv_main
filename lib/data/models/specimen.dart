import 'package:equatable/equatable.dart';

class SpecimenType extends Equatable {
  final String name;
  final String code;

  SpecimenType({required this.name, required this.code});
  @override
  List<Object> get props => [name, code];
}
