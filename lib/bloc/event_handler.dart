part of 'bloc.dart';

/// `EventHandler<E, S>` is a utility class designed to handle events and emit states
/// in a structured manner. It serves as a wrapper around an `EventHandlerCallback`
/// to facilitate the processing of events in the Bloc.
final class EventHandler<E, S> {
  EventHandler({required this.handle});

  final EventHandlerCallback<E, S> handle;

  FutureOr<void> call(E event, Emitter<S> emit) => handle(event, emit);
}
