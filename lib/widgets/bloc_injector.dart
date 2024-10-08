import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/nested/nested.dart';
import 'package:reactor/types/types.dart';

/// Creates a `BlocInjector` widget.
///
/// The `bloc` parameter must not be null.
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
        instance = null;

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
        create = null;

  /// The callback function responsible for creating the `Bloc`
  /// instance that will be provided to descendant widgets.
  final BlocCreator<B>? create;

  /// The [Bloc] to be injected into the widget tree.
  final B? instance;

  /// Retrieves the [Bloc] from the widget tree.
  ///
  /// The [of] method looks up the widget tree to find the nearest ancestor
  /// [_InheritedBloc] widget and returns its [Bloc]. If [listen] is set to true,
  /// the context will rebuild if the [Bloc] changes.
  static B of<B extends Bloc>(
    BuildContext context, {
    bool observe = false,
    BlocAspect? aspect,
  }) {
    return _InheritedBloc.of<B>(
      context,
      observe: observe,
      aspect: aspect,
    );
  }

  @override
  SingleChildState<BlocInjector> createState() => _BlocInjectorState<B>();
}

class _BlocInjectorState<B extends Bloc>
    extends SingleChildState<BlocInjector> {
  late _BlocDependency<B> _bloc;
  StreamSubscription? _subscription;

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
      _unsubscribe();
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
    _unsubscribe();
    if (widget.create != null) {
      _bloc.getInstance(context).close();
    }
    super.dispose();
  }

  _BlocDependency<B> _createDependency() {
    return _BlocDependency<B>(
      instance: widget.instance as B?,
      create: widget.create as BlocCreator<B>?,
      onObserve: _onObserve,
    );
  }

  void _onObserve(B instance) async {
    _subscription ??= instance.stream.listen((_) => setState(() {}));
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// This enum allow identify when a widget should be rebuilt.
enum BlocAspect { widget, contextExtension }

/// Creates an [_InheritedBloc] widget.
///
/// The [bloc] and [child] parameters must not be null.
class _InheritedBloc<B extends Bloc> extends InheritedModel<BlocAspect> {
  /// An inherited widget that provides a [Bloc] to its descendants.
  ///
  /// The [_InheritedBloc] widget stores a [Bloc] and ensures that its descendants
  /// can access it. This widget is used internally by the [BlocInjector] to
  /// provide the [Bloc] to the widget tree.
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
  static B of<B extends Bloc>(
    BuildContext context, {
    bool observe = false,
    BlocAspect? aspect,
  }) {
    final inheritedBloc = observe
        ? InheritedModel.inheritFrom<_InheritedBloc<B>>(context, aspect: aspect)
        : context.getInheritedWidgetOfExactType<_InheritedBloc<B>>();

    final bloc = inheritedBloc?.bloc;

    if (bloc == null) {
      throw FlutterError(
        'The $B is not registered in the widget tree. '
        'Please inject an instance of $B via:\n\n'
        'BlocInjector<$B>(\n'
        ' create: (context) {\n'
        '   return $B(...);\n'
        ' }\n'
        ' child: MyChildWidget(),\n'
        ')\n',
      );
    }

    return bloc.getInstance(
      context,
      observe: observe,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotify(_InheritedBloc<B> oldWidget) {
    return oldWidget.bloc != bloc ||
        bloc.instance?.previousState != bloc.instance?.state;
  }

  @override
  bool updateShouldNotifyDependent(
    _InheritedBloc<B> oldWidget,
    Set<BlocAspect> dependencies,
  ) {
    return dependencies.contains(BlocAspect.widget)
        ? oldWidget.bloc != bloc
        : false;
  }
}

/// The `_BlocDependency` class is designed to facilitate dependency management
/// by either providing an existing instance of a [Bloc] or creating a new one
/// when needed. It ensures that either [create] or [instance] is available,
/// asserting that at least one of them is not null.
final class _BlocDependency<B extends Bloc> {
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
    this.onObserve,
  }) : assert(create != null || instance != null);

  /// This function is used to lazily instantiate a new [Bloc] if [instance] is null.
  final BlocCreator<B>? create;

  /// This function is used to notify the Injector when the instance is required.
  final ValueChanged<B>? onObserve;

  /// An existing [Bloc] instance.
  ///
  /// If provided, this instance will be reused instead of creating a new one.
  B? instance;

  /// This bool will be `true` when the instance is requested the first time.
  bool _hasRequested = false;

  /// Returns the [Bloc] instance, creating it if necessary.
  ///
  /// If [instance] is null, this method will call [create] to generate
  /// a new [Bloc] instance and cache it for future use.
  B getInstance(
    BuildContext context, {
    bool observe = false,
    BlocAspect? aspect,
  }) {
    instance ??= create?.call(context);
    if (observe && aspect != BlocAspect.widget && !_hasRequested) {
      onObserve?.call(instance!);
    }
    if (!_hasRequested) _hasRequested = true;
    return instance!;
  }

  @override
  bool operator ==(Object other) =>
      other is _BlocDependency<B> &&
      other.runtimeType == runtimeType &&
      ((other.create != null && create != null) ||
          (other.instance != null &&
              instance != null &&
              other.instance == instance));

  @override // coverage:ignore-line
  int get hashCode => Object.hash(create, instance); // coverage:ignore-line
}
