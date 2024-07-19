import 'package:reactor/reactor.dart';

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc([int? initialValue]) : super(InitialState(initialValue ?? 0)) {
    register<IncrementEvent>((event, emit) {
      emit(IncrementState(state.counter + 1));
    });

    register<DecrementEvent>((event, emit) {
      emit(DecrementState(state.counter - 1));
    });
  }
}

// Events
sealed class CounterEvent {}

final class IncrementEvent extends CounterEvent {}

final class DecrementEvent extends CounterEvent {}

final class UnregisteredEvent extends CounterEvent {}

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
