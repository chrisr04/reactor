part of 'bloc.dart';

/// A class representing an event handler.
final class EventHandler<E, S> {
  /// `EventHandler<E, S>` is a simple utility class designed to handle events and emit states
  /// in a structured manner. It serves as a wrapper around an `EventHandlerCallback`
  /// to facilitate the processing of events in the Bloc.
  EventHandler(this.handle);

  final EventHandlerCallback<E, S> handle;

  FutureOr<void> call(E event, Emitter<S> emit) => handle(event, emit);
}
