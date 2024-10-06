import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/widgets/widgets.dart';

/// Provides extension methods for `BuildContext` to easily access and check for `Bloc` instances
/// using `BlocInjector`.
extension BlocContextExtension on BuildContext {

  /// Retrieves a `Bloc` instance of type `B` from the nearest `BlocInjector` in the widget tree.
  ///
  /// - The `listen` parameter determines whether the context will listen to changes in the `Bloc` instance.
  ///   If set to `true`, the context will rebuild when the `Bloc` instance changes. Defaults to `false`.
  ///
  /// Throws an exception if the `Bloc` instance is not found.
  ///
  /// Example:
  /// ```dart
  /// final myBloc = context.get<MyBloc>(listen: true);
  /// ```
  B get<B extends Bloc>({bool listen = false}) {
    return BlocInjector.of<B>(this, listen: listen);
  }

  /// Checks whether a `Bloc` of type `B` exists within the current context.
  ///
  /// Returns `true` if the `Bloc` is found, otherwise returns `false`. It internally
  /// attempts to retrieve the `Bloc` using [get] and catches any errors.
  ///
  /// Example:
  /// ```dart
  /// if (context.exist<MyBloc>()) {
  ///   // MyBloc is available
  /// }
  /// ```
  bool exist<B extends Bloc>() {
    try {
      get<B>();
      return true;
    } catch (e) {
      return false;
    }
  }
}
