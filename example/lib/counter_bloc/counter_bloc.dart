import 'package:reactor/reactor.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const InitialState(0)) {
    register<IncrementEvent>(_onIncrementEvent);
    register<DecrementEvent>(_onDecrementEvent);
  }

  void _onIncrementEvent(
    IncrementEvent event,
    Emitter<CounterState> emit,
  ) {
    emit(IncrementState(state.counter + 1));
  }

  void _onDecrementEvent(
    DecrementEvent event,
    Emitter<CounterState> emit,
  ) {
    emit(DecrementState(state.counter - 1));
  }
}
