part of 'counter_bloc.dart';

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
