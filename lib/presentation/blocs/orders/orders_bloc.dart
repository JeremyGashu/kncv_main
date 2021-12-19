import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/data/repositories/orders_repository.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_events.dart';
import 'package:kncv_flutter/presentation/blocs/orders/order_state.dart';

class OrderBloc extends Bloc<OrderEvents, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(InitialState());

  @override
  Stream<OrderState> mapEventToState(
    OrderEvents event,
  ) async* {
    if (event is LoadOrders) {
      yield LoadingState();
      //TODO
    } else if (event is AddOrder) {
      yield LoadingState();
      //TODO
    } else if (event is DeleteOrders) {
      yield LoadingState();
      //TODO
    } else if (event is AddPatientToOrder) {
      yield LoadingState();
      //TODO
    } else if (event is EditPtientInfo) {
      yield LoadingState();
      //TODO
    } else if (event is AddSpecimenToPatient) {
      yield LoadingState();
      //TODO
    } else if (event is DeletePatient) {
      yield LoadingState();
      //TODO
    }
  }
}
