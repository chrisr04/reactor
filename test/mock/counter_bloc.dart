import 'package:reactor/reactor.dart';

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc({
    int? initialValue,
    bool badRegister = false,
  }) : super(InitialState(initialValue ?? 0)) {
    register<IncrementEvent>(_onIncrementEvent);
    register<DecrementEvent>(_onDecrementEvent);
    if (badRegister) {
      register<DecrementEvent>(_onDecrementEvent);
    }
  }

  void _onIncrementEvent(IncrementEvent event, Emitter<CounterState> emit) {
    emit(IncrementState(state.counter + 1));
  }

  void _onDecrementEvent(DecrementEvent event, Emitter<CounterState> emit) {
    emit(DecrementState(state.counter - 1));
  }
}

// Events
sealed class CounterEvent {
  const CounterEvent();
}

final class IncrementEvent extends CounterEvent {
  const IncrementEvent();
}

final class DecrementEvent extends CounterEvent {
  const DecrementEvent();
}

final class UnregisteredEvent extends CounterEvent {
  const UnregisteredEvent();
}

// States
sealed class CounterState {
  const CounterState(this.counter);
  final int counter;
}

final class InitialState extends CounterState {
  const InitialState(super.counter);
}

final class IncrementState extends CounterState {
  const IncrementState(super.counter);
}

final class DecrementState extends CounterState {
  const DecrementState(super.counter);
}
