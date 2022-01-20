import 'package:equatable/equatable.dart';
import 'package:kncv_flutter/data/models/models.dart';

class LocationStates extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialState extends LocationStates {}

class LoadingLocationsState extends LocationStates {
  @override
  List<Object> get props => [];
}

class LoadedLocationsState extends LocationStates {
  final List<Region> regions;

  LoadedLocationsState({required this.regions});
  @override
  List<Object> get props => [regions];
}

class ErrorLoadingLocationsState extends LocationStates {
  final String message;

  ErrorLoadingLocationsState({required this.message});
  List<Object> get props => [message];
}
