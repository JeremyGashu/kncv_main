import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/tester_courier_receiver_repository.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_event.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_state.dart';

class TesterCourierBloc extends Bloc<TesterCourierEvent, TesterCourierStates> {
  final TesterCourierRepository testerCourierRepository;
  Tester? tester;
  Courier? courier;
  String? date;

  TesterCourierBloc(this.testerCourierRepository) : super(InitialState());

  @override
  Stream<TesterCourierStates> mapEventToState(
    TesterCourierEvent event,
  ) async* {
    if (event is LoadTestersAndCouriers) {
      yield LoadingState();
      var data = await testerCourierRepository.loadTestersAndCouriers();
      print('testers and couriers => ${data}');
      yield LoadedState(data: data);
    }
  }
}
