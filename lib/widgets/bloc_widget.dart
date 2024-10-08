import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/nested/nested.dart';
import 'package:reactor/types/types.dart';
import 'package:reactor/widgets/bloc_injector.dart';

/// A base widget class for integrating a `Bloc` into the Flutter widget tree.
///
/// The `BlocWidget` class simplifies the process of observing state changes in
/// a `Bloc` and rebuilding parts of the widget tree accordingly.
///
/// This widget provides a declarative approach to rebuilding the UI based on
/// state changes in the `Bloc`. It also offers an optional observer pattern
/// to react to state transitions in a fine-grained way.
abstract class BlocWidget<B extends Bloc, S> extends SingleChildStatefulWidget {
  const BlocWidget({
    super.key,
    super.child,
    this.observer,
    this.observeWhen,
    this.builder,
    this.buildWhen,
    this.observeOnly = false,
  });

  /// The function which will be called on every state change.
  ///
  /// This function takes the [BuildContext] and the state and is
  /// responsible for performing any side-effects in response to
  /// state changes.
  final BlocObserverHandler<S>? observer;

  /// An optional function that determines whether the [observer]
  /// should be invoked based on the previous and current state.
  ///
  /// If this function returns `true`, the [observer] will be called.
  /// If this function returns `false`, the [observer] will not be
  /// called.
  final BlocCondition<S>? observeWhen;

  /// The builder function which will be invoked to build the widget tree.
  ///
  /// This function is called with the current state of the [Bloc].
  final BlocBuilderHandler<S>? builder;

  /// Optional function that determines whether the widget should be rebuilt.
  ///
  /// This function takes the previous and current state as parameters and
  /// returns a boolean indicating whether to rebuild the widget.
  final BlocCondition<S>? buildWhen;

  /// If `observeOnly` it is true it will behave like a BlocObserver.
  /// By default is false.
  final bool observeOnly;

  @override
  State<BlocWidget<B, S>> createState() => _BlocWidgetState<B, S>();
}

class _BlocWidgetState<B extends Bloc, S>
    extends SingleChildState<BlocWidget<B, S>> {
  late B _bloc = BlocInjector.of<B>(
    context,
    observe: true,
    aspect: BlocAspect.widget,
  );
  late S _state = _bloc.state;
  StreamSubscription? _subscription;

  bool get hasBuilder => widget.builder != null;
  bool get hasObserver => widget.observer != null;
  bool get mustRebuild => !widget.observeOnly && hasBuilder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscription == null) _subscribe();
    final currentBloc = BlocInjector.of<B>(context);
    if (_bloc != currentBloc) {
      _bloc = currentBloc;
      _state = _bloc.state;
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (hasBuilder) return widget.builder!(context, _state);
    return child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() async {
    if (!context.mounted) return;
    _subscription ??= _bloc.stream.listen(_onListen);
  }

  void _onListen(dynamic state) {
    final previousState = _bloc.previousState;
    if (hasObserver) _observe(previousState, state);
    if (mustRebuild) _rebuild(previousState, state);
  }

  void _observe(S previousState, S state) {
    final hasCondition = widget.observeWhen != null;
    if (hasCondition && !widget.observeWhen!(previousState, state)) return;
    widget.observer?.call(context, state);
  }

  void _rebuild(S previousState, S state) {
    final hasCondition = widget.buildWhen != null;
    if (hasCondition && !widget.buildWhen!(previousState, state)) return;
    setState(() {
      _state = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
