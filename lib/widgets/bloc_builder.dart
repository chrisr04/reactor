import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/types/types.dart';
import 'package:reactor/widgets/bloc_injector.dart';

/// Creates a `BlocBuilder` widget.
class BlocBuilder<B extends Bloc, S> extends StatefulWidget {
  /// A widget that builds itself based on the latest state of a `Bloc`.
  ///
  /// The `BlocBuilder` widget listens to the state changes of a `Bloc` and
  /// rebuilds its widget tree using the provided `builder` function whenever
  /// a new state is emitted. The rebuilds can be filtered by the optional
  /// `buildWhen` function.
  ///
  /// This is useful for creating reactive UIs where the UI depends on
  /// the state of a `Bloc`.
  ///
  ///
  /// ```dart
  /// BlocBuilder<MyBloc, MyState>(
  ///   builder: (context, state) {
  ///    return Text('Count: ${state.count}');
  ///   },
  /// );
  /// ```
  const BlocBuilder({
    super.key,
    required this.builder,
    this.buildWhen,
  });

  /// The builder function which will be invoked to build the widget tree.
  ///
  /// This function is called with the current state of the [Bloc].
  final BlocBuilderHandler<S> builder;

  /// Optional function that determines whether the widget should be rebuilt.
  ///
  /// This function takes the previous and current state as parameters and
  /// returns a boolean indicating whether to rebuild the widget.
  final BlocCondition<S>? buildWhen;

  @override
  State<BlocBuilder<B, S>> createState() => _BlocBuilderState<B, S>();
}

class _BlocBuilderState<B extends Bloc, S> extends State<BlocBuilder<B, S>> {
  late B _bloc = BlocInjector.of<B>(context, listen: true);
  late S _state = _bloc.state;
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
    if (currentBloc != _bloc) {
      _bloc = currentBloc;
      _state = _bloc.state;
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
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
    final hasCondition = widget.buildWhen != null;
    if (hasCondition && !widget.buildWhen!(_bloc.previousState, state)) return;
    setState(() {
      _state = state;
    });
  }

  void _unsubscribe() {
    _blocSubscription?.cancel();
    _blocSubscription = null;
  }
}
