import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/widgets/bloc_widget.dart';

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
/// - [observeOnly]: An optional property that if it's true it will behave like a `BlocObserver`.
class BlocReactor<B extends Bloc, S> extends BlocWidget<B, S> {
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
    super.observeWhen,
    required super.observer,
    super.buildWhen,
    required super.builder,
    super.observeOnly,
  });
}
