import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/utils/bloc_aspect.dart';
import 'package:reactor/widgets/widgets.dart';

/// Provides extension methods for `BuildContext` to easily access and check for `Bloc` instances
/// using `BlocInjector`.
extension BlocContextExtension on BuildContext {
  /// Retrieves a `Bloc` instance of type `B` from the nearest `BlocInjector` in the widget tree.
  ///
  /// Throws an exception if the `Bloc` instance is not found.
  ///
  /// Example:
  /// ```dart
  /// final myBloc = context.get<MyBloc>();
  /// ```
  B get<B extends Bloc>() {
    return BlocInjector.of<B>(this, observe: false);
  }

  /// Retrieves a `Bloc` instance of type `B` from the nearest `BlocInjector` in the widget tree
  /// and rebuild widget when state is changed.
  ///
  /// Throws an exception if the `Bloc` instance is not found.
  ///
  /// Example:
  /// ```dart
  /// final myBloc = context.observe<MyBloc>();
  /// ```
  B observe<B extends Bloc>() {
    return BlocInjector.of<B>(
      this,
      observe: true,
      aspect: BlocAspect.contextExtension,
    );
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
