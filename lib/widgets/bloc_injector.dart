import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/nested/nested.dart';
import 'package:reactor/types/types.dart';
import 'package:reactor/utils/utils.dart';

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
  late BlocDependency<B> _bloc;
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
      _bloc.getOrCreateInstance(context).close();
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
      _bloc.getOrCreateInstance(context).close();
    }
    super.dispose();
  }

  BlocDependency<B> _createDependency() {
    return BlocDependency<B>(
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
  final BlocDependency<B> bloc;

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

    return bloc.getOrCreateInstance(
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
    if (dependencies.contains(BlocAspect.widget)) return oldWidget.bloc != bloc;
    return dependencies.contains(BlocAspect.contextExtension);
  }
}
