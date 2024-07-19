import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/types/types.dart';
import 'package:reactor/widgets/bloc_builder.dart';
import 'package:reactor/widgets/bloc_observer.dart';

/// Creates a `BlocReactor` widget.
///
/// The `observer` and `builder` parameters must not be null.
///
/// - [observer]: A callback that gets invoked when the `Bloc`'s state changes.
/// - [observeWhen]: An optional callback that can control whether the listener
///   function should be invoked based on the previous and current states.
/// - [builder]: A function that builds a widget based on the `Bloc`'s state.
/// - [buildWhen]: An optional callback that can control whether the builder
///   function should be invoked based on the previous and current states.
class BlocReactor<B extends Bloc, S> extends StatelessWidget {
  /// A `BlocReactor` is a Flutter widget that combines a `BlocObserver` and a
  /// `BlocBuilder`. It allows you to define both a observer and a builder in one
  /// widget, ensuring that the observer and builder are consistently defined for
  /// the same `Bloc` and `State`.
  ///
  /// This widget is useful for scenarios where you need to both listen to state
  /// changes and rebuild your UI based on the new state.
  ///
  /// The `BlocReactor` widget requires a `observer` and a `builder`, and optionally
  /// accepts `observeWhen` and `buildWhen` conditions.
  ///
  ///
  /// ```dart
  /// BlocReactor<CounterBloc, CounterState>(
  ///   observeWhen: (previous, current) {
  ///     // Return true or false based on whether you want to listen for state changes
  ///     return true;
  ///   },
  ///   observer: (context, state) {
  ///     // Do something based on the state
  ///   },
  ///   buildWhen: (previous, current) {
  ///     // Return true or false based on whether you want to rebuild the widget
  ///     return true;
  ///   },
  ///   builder: (context, state) {
  ///     // Return a widget based on the state
  ///     return Text('Count: ${state.count}');
  ///   },
  /// );
  /// ```
  const BlocReactor({
    super.key,
    this.observeWhen,
    required this.observer,
    this.buildWhen,
    required this.builder,
  });

  /// An optional function that can be used to determine whether the `observer`
  /// should be invoked.
  ///
  /// If `observeWhen` returns true, the `observer` will be called with the
  /// `previous` and `current` state.
  final BlocCondition<S>? observeWhen;

  /// The function that gets called whenever the `Bloc`'s state changes and
  /// `observeWhen` returns true.
  final BlocObserverHandler<S> observer;

  /// An optional function that can be used to determine whether the `builder`
  /// should be invoked.
  ///
  /// If `buildWhen` returns true, the `builder` will be called with the
  /// `previous` and `current` state.
  final BlocCondition<S>? buildWhen;

  /// The function that builds a widget whenever the `Bloc`'s state changes and
  /// `buildWhen` returns true.
  final BlocBuilderHandler<S> builder;

  @override
  Widget build(BuildContext context) {
    return BlocObserver<B, S>(
      observer: observer,
      observeWhen: observeWhen,
      child: BlocBuilder<B, S>(
        buildWhen: buildWhen,
        builder: builder,
      ),
    );
  }
}
