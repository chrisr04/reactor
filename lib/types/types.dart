import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';

/// A function that emits a state of type [S].
typedef EmitterCallback<S> = void Function(S state);

/// A function that handles an event of type [E] and emits a state of type [S].
typedef EventHandlerCallback<E, S> = FutureOr<void> Function(
  E event,
  Emitter<S> emit,
);

/// A function that observes to state changes of type [S].
typedef BlocObserverHandler<S> = void Function(BuildContext context, S state);

/// A function that builds a widget based on the state of type [S] in a [BuildContext].
typedef BlocBuilderHandler<S> = Widget Function(BuildContext context, S state);

/// A function that determines whether the [Bloc] should rebuild based on the previous and current states of type [S].
typedef BlocCondition<S> = bool Function(S previous, S current);
