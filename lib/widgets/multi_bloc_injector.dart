import 'package:reactor/nested/nested.dart';

/// Creates a `MultiBlocInjector`.
///
/// The `child` and `injectors` parameters must not be null.
class MultiBlocInjector extends Nested {
  /// A `MultiBlocInjector` is a widget that merges multiple `BlocInjector`
  /// injectors into a single widget tree.
  ///
  /// This is particularly useful for injecting multiple Blocs
  /// into the widget tree at a higher level, thereby making them available
  /// throughout the subtree.
  ///
  /// ```dart
  /// MultiBlocInjector(
  ///   injectors: [
  ///     BlocInjector<MyBlocA>(
  ///       bloc: MyBlocA(),
  ///     ),
  ///     BlocInjector<MyBlocB>(
  ///       bloc: MyBlocB(),
  ///     ),
  ///   ],
  ///   child: MyChildWidget(),
  /// );
  /// ```
  ///
  MultiBlocInjector({
    super.key,
    required List<SingleChildWidget> injectors,
    required super.child,
  }) : super(
          children: injectors,
        );
}
