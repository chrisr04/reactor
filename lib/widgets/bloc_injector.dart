import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/nested/nested.dart';

/// Creates a `BlocInjector` widget.
///
/// The `bloc` parameter must not be null.
/// The `closeOnDispose` parameter defaults to true.
class BlocInjector<B extends Bloc> extends SingleChildStatefulWidget {
  /// A widget that injects a [Bloc] into the widget tree.
  ///
  /// The `BlocInjector` widget is used to provide a [Bloc] to its descendant widgets.
  /// It ensures that the [Bloc] is properly disposed of when the widget is removed
  /// from the widget tree.
  ///
  /// The `child` parameter is optional.
  ///
  /// The `bloc` parameter is required and represents the [Bloc] to be provided to the
  /// widget tree. The [closeOnDispose] parameter is optional and defaults to true,
  /// indicating whether the [Bloc] should be closed when the widget is disposed.
  ///
  /// ```dart
  /// BlocInjector<MyBloc>(
  ///   bloc: MyBloc(),
  ///   child: MyChildWidget(),
  /// );
  /// ```
  const BlocInjector({
    super.key,
    super.child,
    required this.bloc,
    this.closeOnDispose = true,
  });

  /// The [Bloc] to be injected into the widget tree.
  final B bloc;

  /// Whether to close the [Bloc] when this widget is disposed.
  ///
  /// Defaults to true.
  final bool closeOnDispose;

  /// Retrieves the [Bloc] from the widget tree.
  ///
  /// The [of] method looks up the widget tree to find the nearest ancestor
  /// [_InheritedBloc] widget and returns its [Bloc]. If [listen] is set to true,
  /// the context will rebuild if the [Bloc] changes.
  static B of<B extends Bloc>(BuildContext context, {bool listen = false}) =>
      _InheritedBloc.of<B>(context, listen);

  @override
  SingleChildState<BlocInjector> createState() => _BlocInjectorState<B>();
}

/// The state for the [BlocInjector] widget.
///
/// This state handles the creation of the [_InheritedBloc] widget that
/// provides the [Bloc] to the widget tree. It also ensures that the [Bloc]
/// is closed when the widget is disposed if [closeOnDispose] is true.
class _BlocInjectorState<B extends Bloc>
    extends SingleChildState<BlocInjector> {
  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return _InheritedBloc<B>(
      bloc: widget.bloc as B,
      child: child ?? const SizedBox.shrink(),
    );
  }

  @override
  void didUpdateWidget(covariant BlocInjector<Bloc> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc != widget.bloc) oldWidget.bloc.close();
  }

  @override
  void dispose() {
    if (widget.closeOnDispose) widget.bloc.close();
    super.dispose();
  }
}

/// An inherited widget that provides a [Bloc] to its descendants.
///
/// The [_InheritedBloc] widget stores a [Bloc] and ensures that its descendants
/// can access it. This widget is used internally by the [BlocInjector] to
/// provide the [Bloc] to the widget tree.
class _InheritedBloc<B extends Bloc> extends InheritedWidget {
  /// Creates an [_InheritedBloc] widget.
  ///
  /// The [bloc] and [child] parameters must not be null.
  const _InheritedBloc({
    super.key,
    required this.bloc,
    required super.child,
  });

  /// The [Bloc] provided to the widget tree.
  final B bloc;

  /// Retrieves the [Bloc] from the nearest ancestor [_InheritedBloc] widget.
  ///
  /// If [listen] is true, the context will rebuild if the [Bloc] changes.
  static B of<B extends Bloc>(BuildContext context, bool listen) => listen
      ? context.dependOnInheritedWidgetOfExactType<_InheritedBloc<B>>()!.bloc
      : context.findAncestorWidgetOfExactType<_InheritedBloc<B>>()!.bloc;

  @override
  bool updateShouldNotify(_InheritedBloc<B> oldWidget) =>
      oldWidget.bloc != bloc;
}
