import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/nested/nested.dart';
import 'package:reactor/types/types.dart';

/// Creates a `BlocInjector` widget.
///
/// The `bloc` parameter must not be null.
/// The `closeOnDispose` parameter defaults to true.
class BlocInjector<B extends Bloc> extends SingleChildStatefulWidget {
  /// A widget that injects a Bloc into the widget tree.
  ///
  /// The `BlocInjector` widget is used to provide a Bloc to its descendant widgets.
  /// It ensures that the Bloc is properly disposed of when the widget is removed
  /// from the widget tree.
  ///
  /// The `child` parameter is optional.
  ///
  /// The `bloc` parameter is required and represents the Bloc to be provided to the
  /// widget tree.
  ///
  /// Note: The Bloc will be closed when the widget is disposed.
  ///
  /// ```dart
  /// BlocInjector<MyBloc>(
  ///   create: (context) => MyBloc(),
  ///   child: MyChildWidget(),
  /// );
  /// ```
  const BlocInjector({
    super.key,
    super.child,
    required this.create,
  })  : assert(create != null),
        instance = null,
        closeOnDispose = true;

  /// Creates a `BlocInjector` using an existing [instance] of the provided Bloc.
  ///
  /// This constructor allows you to inject an already created instance of a Bloc
  /// into the widget tree. It is useful when you want to reuse a Bloc that has
  /// been created elsewhere, without triggering its creation or closure on
  /// disposal.
  ///
  /// The [instance] parameter is required and represents the Bloc that will be
  /// injected into the widget tree.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// BlocInjector<MyBloc>.instance(
  ///   instance: myBlocInstance,
  ///   child: MyChildWidget(),
  /// )
  /// ```
  const BlocInjector.instance({
    super.key,
    super.child,
    required this.instance,
  })  : assert(instance != null),
        create = null,
        closeOnDispose = false;

  /// The callback function responsible for creating the `Bloc`
  /// instance that will be provided to descendant widgets.
  final BlocCreator<B>? create;

  /// The [Bloc] to be injected into the widget tree.
  final B? instance;

  /// Whether to close the [Bloc] when this widget is disposed.
  ///
  /// Defaults to true.
  final bool closeOnDispose;

  /// Retrieves the [Bloc] from the widget tree.
  ///
  /// The [of] method looks up the widget tree to find the nearest ancestor
  /// [_InheritedBloc] widget and returns its [Bloc]. If [listen] is set to true,
  /// the context will rebuild if the [Bloc] changes.
  static B of<B extends Bloc>(BuildContext context, {bool listen = false}) {
    return _InheritedBloc.of<B>(context, listen: listen).getInstance(context);
  }

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
  late _BlocDependency<B> _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = _createDependency();
  }

  @override
  void didUpdateWidget(covariant BlocInjector<Bloc> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newBloc = _createDependency();
    if (_bloc != newBloc) {
      _bloc.getInstance(context).close();
      _bloc = newBloc;
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return _InheritedBloc<B>(
      bloc: _bloc,
      child: child ?? const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    if (widget.closeOnDispose) {
      _bloc.getInstance(context).close();
    }
    super.dispose();
  }

  _BlocDependency<B> _createDependency() {
    return _BlocDependency<B>(
      instance: widget.instance as B?,
      create: widget.create as BlocCreator<B>?,
    );
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
  final _BlocDependency<B> bloc;

  /// Retrieves the [Bloc] from the nearest ancestor [_InheritedBloc] widget.
  ///
  /// If [listen] is true, the context will rebuild if the [Bloc] changes.
  static _BlocDependency<B> of<B extends Bloc>(
    BuildContext context, {
    bool listen = false,
  }) {
    final bloc = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedBloc<B>>()?.bloc
        : context.getInheritedWidgetOfExactType<_InheritedBloc<B>>()?.bloc;

    if (bloc == null) {
      throw FlutterError(
        'The $B is not registered in the widget tree.\n'
        'Please inject an instance of $B via:\n\n'
        'BlocInjector<$B>(\n'
        ' create: (context) => $B(...),\n'
        ' child: MyChildWidget(),\n'
        ')\n',
      );
    }

    return bloc;
  }

  @override
  bool updateShouldNotify(_InheritedBloc<B> oldWidget) =>
      oldWidget.bloc != bloc;
}

/// The `_BlocDependency` class is designed to facilitate dependency management
/// by either providing an existing instance of a [Bloc] or creating a new one
/// when needed. It ensures that either [create] or [instance] is available,
/// asserting that at least one of them is not null.
class _BlocDependency<B extends Bloc> {
  /// Creates a [_BlocDependency] instance.
  ///
  /// The [create] function is optional and should be provided when a new
  /// [Bloc] instance needs to be created. The [instance] can be passed
  /// directly if an existing [Bloc] is available.
  ///
  /// At least one of [create] or [instance] must be non-null, otherwise
  /// an assertion error will be thrown.
  _BlocDependency({
    this.create,
    this.instance,
  }) : assert(create != null || instance != null);

  /// This function is used to lazily instantiate a new [Bloc] if [instance] is null.
  BlocCreator<B>? create;

  /// An existing [Bloc] instance.
  ///
  /// If provided, this instance will be reused instead of creating a new one.
  B? instance;

  /// Returns the [Bloc] instance, creating it if necessary.
  ///
  /// If [instance] is null, this method will call [create] to generate
  /// a new [Bloc] instance and cache it for future use.
  B getInstance(BuildContext context) {
    instance ??= create?.call(context);
    return instance!;
  }

  @override
  bool operator ==(Object other) =>
      other is _BlocDependency<B> &&
      other.runtimeType == runtimeType &&
      ((other.create != null && create != null && other.create == create) ||
          (other.instance != null &&
              instance != null &&
              other.instance == instance));

  @override // coverage:ignore-line
  int get hashCode => Object.hash(create, instance); // coverage:ignore-line
}
