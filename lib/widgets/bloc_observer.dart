import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/nested/nested.dart';
import 'package:reactor/types/types.dart';
import 'package:reactor/widgets/bloc_injector.dart';

/// Creates a `BlocObserver` widget.
///
/// The `observer`parameter is required.
class BlocObserver<B extends Bloc, S> extends SingleChildStatefulWidget {
  /// A widget that observes to state changes in a `Bloc` and invokes a
  /// `observer` callback whenever the Bloc's state changes.
  ///
  /// `BlocObserver` is a Flutter widget which takes a [Bloc] and a
  /// `BlocObserverHandler` and invokes the `observer` in response to
  /// state changes in the `Bloc`. It should be used for any code which
  /// needs to execute in response to a state change such as navigation,
  /// showing a `SnackBar`, showing a `Dialog`, etc.
  ///
  /// If the `observeWhen` callback is specified, the `observer` will
  /// only be called on state changes where `observeWhen` returns true.
  /// If `observeWhen` is not specified, the `observer` will be called
  /// on every state change.
  ///
  ///
  /// ```dart
  /// BlocObserver<MyBloc, MyState>(
  ///  observer: (context, state) {
  ///     if(state is SuccessState){
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(content: Text('Operation Success!')),
  ///       );
  ///     }
  ///   },
  ///   child: MyChildWidget(),
  /// );
  /// ```
  const BlocObserver({
    super.key,
    super.child,
    required this.observer,
    this.observeWhen,
  });

  /// The function which will be called on every state change.
  ///
  /// This function takes the [BuildContext] and the state and is
  /// responsible for performing any side-effects in response to
  /// state changes.
  final BlocObserverHandler<S> observer;

  /// An optional function that determines whether the [observer]
  /// should be invoked based on the previous and current state.
  ///
  /// If this function returns `true`, the [observer] will be called.
  /// If this function returns `false`, the [observer] will not be
  /// called.
  final BlocCondition<S>? observeWhen;

  @override
  SingleChildState<BlocObserver<B, S>> createState() =>
      _BlocObserverState<B, S>();
}

class _BlocObserverState<B extends Bloc, S>
    extends SingleChildState<BlocObserver<B, S>> {
  late B _bloc = BlocInjector.of<B>(context, listen: true);
  StreamSubscription? _blocSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(_subscribe);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBloc = BlocInjector.of<B>(context);
    if (_bloc != currentBloc) {
      _bloc = currentBloc;
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _blocSubscription = _bloc.stream.listen(_onListen);
  }

  void _onListen(dynamic state) {
    final hasCondition = widget.observeWhen != null;
    if (hasCondition && !widget.observeWhen!(_bloc.previousState, state)) {
      return;
    }
    widget.observer(context, state);
  }

  void _unsubscribe() {
    _blocSubscription?.cancel();
    _blocSubscription = null;
  }
}
