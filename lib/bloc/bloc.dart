import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reactor/types/types.dart';

part 'emitter.dart';
part 'event_handler.dart';

/// An abstract class representing a Bloc that handles events of type `E` and manages states of type `S`.
///
///
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> {
///  MyBloc() : super(const InitialState()){
///   register<InitialEvent>(_onInitialEvent)
///  }
///
///  void _onInitialEvent(InitialEvent event, Emitter<MyState> emit){
///    // Add your business logic
///  }
/// }
/// ```
abstract class Bloc<E, S> {
  /// Initialize a `Bloc` with the given `initialState`.
  Bloc(S initialState) {
    _currentState = initialState;
    _previousState = initialState;
    _states.add(_currentState);
    _eventsSubscription = _events.stream.listen(onMapEventToState);
    _statesSubscription = _states.stream.listen(onChangeState);
  }

  final _events = StreamController<E>();
  final _states = StreamController<S>.broadcast();
  late StreamSubscription<E> _eventsSubscription;
  late StreamSubscription<S> _statesSubscription;
  final _eventHandlers = <Type, EventHandler<E, S>>{};
  final _emitters = <Type, Emitter<S>>{};
  late S _currentState;
  late S _previousState;
  bool _isClosed = false;

  /// A stream of states.
  Stream<S> get stream => _states.stream;

  /// The current state emitted.
  S get state => _currentState;

  /// The previous state emitted.
  S get previousState => _previousState;

  /// Indicates whether the `Bloc` is closed.
  bool get isClosed => _isClosed;

  /// Called when the state changes to `newState`.
  @protected
  @mustCallSuper
  void onChangeState(S newState) {
    _previousState = _currentState;
    _currentState = newState;
  }

  /// Registers an `eventHandler` for specified Event.
  @protected
  @mustCallSuper
  void register<T extends E>(EventHandlerCallback<T, S> handle) {
    _eventHandlers[T] = EventHandler<T, S>(handle: handle);
    _emitters[T] = Emitter<S>(emit: _states.add);
  }

  /// Maps the given `event` to a state using the registered event handlers.
  @protected
  @mustCallSuper
  void onMapEventToState(E event) async {
    final eventHandler = _eventHandlers[event.runtimeType];
    final emitter = _emitters[event.runtimeType];
    if (eventHandler != null && emitter != null) {
      await eventHandler(event, emitter);
    }
  }

  /// Adds an `event` to the `Bloc` for processing.
  ///
  /// Throws a `StateError` if the `Bloc` is closed or if the event is not registered.
  void add(E event) {
    if (_isClosed) {
      throw StateError(
        'Can\'t add ${event.runtimeType} because the Bloc is closed',
      );
    }

    final eventHandler = _eventHandlers[event.runtimeType];

    if (eventHandler == null) {
      throw StateError(
        'The event ${event.runtimeType} must be registered with: '
        'register<${event.runtimeType}>((event, emit){...})',
      );
    }

    _events.add(event);
  }

  /// Closes the `Bloc` and releases all resources.
  ///
  /// Once closed, the `Bloc` cannot process any more events.
  @mustCallSuper
  Future<void> close() async {
    if (_isClosed) return;
    await _eventsSubscription.cancel();
    await _statesSubscription.cancel();
    await _events.close();
    await _states.close();
    _eventHandlers.clear();
    _emitters.clear();
    _isClosed = true;
  }
}
