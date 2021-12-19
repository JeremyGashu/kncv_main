import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String id;
  final String name;
  final String age;

  OrderModel({required this.name, required this.age, required this.id});
  @override
  List<Object> get props => [id, name, age];
}
