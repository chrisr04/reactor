part of 'bloc.dart';

/// `Emitter<S>` is a simple utility class that allows for emitting
/// new states in the Bloc, commonly used in state management scenarios.
final class Emitter<S> {
  Emitter({required this.emit});

  final EmitterCallback<S> emit;

  void call(S state) => emit(state);
}
