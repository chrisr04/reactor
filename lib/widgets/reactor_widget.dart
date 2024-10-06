import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';

/// An abstract class that simplifies the creation of a `Widget`
/// which reacts to changes in a `Bloc` state.
///
/// The `ReactorWidget` provides hooks for initializing the bloc,
/// controlling when the widget should rebuild, and observing state changes.
/// It abstracts the common logic required when working with a Bloc,
/// allowing the developer to focus on handling state and UI updates.
///
/// ### Example
/// ```dart
/// class MyReactorWidget extends ReactorWidget<MyBloc, MyState> {
///   @override
///   Widget build(BuildContext context, MyState state) {
///     return Text('Current state: ${state.value}');
///   }
/// }
/// ```
abstract class ReactorWidget<B extends Bloc, S> extends StatefulWidget {
  /// Creates a [ReactorWidget].
  ///
  /// The widget is expected to observe the provided Bloc and react
  /// to its state changes.
  const ReactorWidget({super.key});

  @override
  ReactorWidgetState<B, S> createState() => ReactorWidgetState<B, S>();

  /// Whether the Bloc should be closed when the widget is disposed.
  ///
  /// If true, the Bloc will automatically be closed when the widget is
  /// removed from the widget tree. By default, this is set to true.
  ///
  /// Override this method to prevent closing the Bloc on dispose.
  bool get closeOnDispose => true; 

  /// Whether this widget should only observe the Bloc's state without
  /// rebuilding the UI.
  ///
  /// When set to true, the widget will listen to state changes but will not
  /// trigger a rebuild. Use this for observing state transitions without
  /// affecting the widget's visual representation. Defaults to false.
  bool get observeOnly => false;

  /// Finds the Bloc in the widget tree.
  ///
  /// This method uses `BuildContext` to locate the Bloc instance.
  /// It is marked as `@nonVirtual` to prevent overriding, ensuring
  /// consistent behavior across all subclasses.
  @nonVirtual
  @protected
  B getBloc(BuildContext context) => context.get<B>();

  /// Provides the Bloc instance that this widget depends on.
  ///
  /// Override this method to supply a specific Bloc from the widget's context.
  /// By default, this will be use `getBloc` to locate the Bloc instance.
  B initBloc(BuildContext context) => getBloc(context);

  /// Describes the part of the UI that depends on the [Bloc]'s state.
  ///
  /// The `build` method is called whenever the Bloc's state changes,
  /// if `buildWhen` returns true.
  Widget build(BuildContext context, S state);

  /// Determines whether the widget should rebuild when the Bloc's state changes.
  ///
  /// This method is called with the previous and current states of the Bloc.
  /// Returning true will cause the widget to rebuild; returning false will
  /// prevent the rebuild. By default, it always returns true.
  bool buildWhen(S previous, S current) => true;

  /// Observes the current Bloc state without triggering a rebuild.
  ///
  /// This method is called whenever the Bloc's state changes, regardless
  /// of whether `buildWhen` returns true. Use this to observe transitions
  /// and perform side effects like logging or analytics.
  void observer(BuildContext context, S state) {}

  /// Determines whether the `observer` method should be called when the
  /// Bloc's state changes.
  ///
  /// This method works similarly to `buildWhen`, but controls whether
  /// `observer` should react to state transitions. By default, it returns true.
  bool observeWhen(S previous, S current) => true;
}

class ReactorWidgetState<B extends Bloc, S> extends State<ReactorWidget<B, S>> {

  @override
  Widget build(BuildContext context) {
    final blocReactor = BlocReactor<B, S>(
      observeWhen: widget.observeWhen,
      observer: widget.observer,
      buildWhen: widget.buildWhen,
      observeOnly: widget.observeOnly,
      builder: widget.build,
    );

    if (context.exist<B>()) return blocReactor;

    if (widget.closeOnDispose) {
      return BlocInjector<B>(
        create: widget.initBloc,
        child: blocReactor,
      );
    }

    return BlocInjector<B>.instance(
      instance: widget.initBloc(context),
      child: blocReactor,
    );
  }
}
