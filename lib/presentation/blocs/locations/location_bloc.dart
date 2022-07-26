import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/data/repositories/locations.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_event.dart';
import 'package:kncv_flutter/presentation/blocs/locations/location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationStates> {
  final LocationsRepository locationRepository;

  LocationBloc(this.locationRepository) : super(InitialState());

  @override
  Stream<LocationStates> mapEventToState(
    LocationEvent event,
  ) async* {
    if (event is LoadLocations) {
      yield LoadingLocationsState();
      var data = await locationRepository.loadRegions();
      print('testers and couriers => ${data}');
      yield LoadedLocationsState(regions: data);
    }
  }
}
