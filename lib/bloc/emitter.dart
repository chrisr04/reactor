part of 'bloc.dart';

/// A class representing a state emitter.
final class Emitter<S> {
  /// `Emitter<S>` is a simple utility class that allows for emitting
  /// new states in the Bloc, commonly used in state management scenarios.
  Emitter(this.emit);

  final EmitterCallback<S> emit;

  void call(S state) => emit(state);
}
