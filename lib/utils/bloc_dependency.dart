import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/types/types.dart';
import 'package:reactor/utils/bloc_aspect.dart';

/// The `BlocDependency` class is designed to facilitate dependency management
/// by either providing an existing instance of a [Bloc] or creating a new one
/// when needed. It ensures that either [create] or [instance] is available,
/// asserting that at least one of them is not null.
final class BlocDependency<B extends Bloc> {
  /// Creates a [BlocDependency] instance.
  ///
  /// The [create] function is optional and should be provided when a new
  /// [Bloc] instance needs to be created. The [instance] can be passed
  /// directly if an existing [Bloc] is available.
  ///
  /// At least one of [create] or [instance] must be non-null, otherwise
  /// an assertion error will be thrown.
  BlocDependency({
    B? instance,
    this.create,
    this.onObserve,
  })  : assert(instance != null || create != null),
        _instance = instance;

  /// If provided, this instance will be reused instead of creating a new one.
  B? _instance;

  /// This function is used to lazily instantiate a new [Bloc] if [instance] is null.
  final BlocCreator<B>? create;

  /// This function is used to notify when the instance is observed.
  final ValueChanged<B>? onObserve;

  /// This bool will be `true` when the instance is requested the first time.
  bool _hasRequested = false;

  /// An existing [Bloc] instance.
  ///
  /// If not exist returns null.
  B? get instance => _instance;

  /// Returns the [Bloc] instance, creating it if necessary.
  ///
  /// If [instance] is null, this method will call [create] to generate
  /// a new [Bloc] instance and cache it for future use.
  B getOrCreateInstance(
    BuildContext context, {
    bool observe = false,
    BlocAspect? aspect,
  }) {
    _instance ??= create?.call(context);

    if (observe && aspect != BlocAspect.widget && !_hasRequested) {
      onObserve?.call(_instance!);
    }

    if (!_hasRequested) _hasRequested = true;

    return _instance!;
  }

  @override
  bool operator ==(Object other) =>
      other is BlocDependency<B> &&
      other.runtimeType == runtimeType &&
      ((other.create != null && create != null) ||
          (other._instance != null &&
              _instance != null &&
              other._instance == _instance));

  @override // coverage:ignore-line
  int get hashCode => Object.hash(create, _instance); // coverage:ignore-line
}
