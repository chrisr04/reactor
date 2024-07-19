import 'package:reactor/nested/nested.dart';

/// Creates a `MultiBlocObserver`.
///
/// The `child` and `observers` parameters must not be null.
class MultiBlocObserver extends Nested {
  /// A `MultiBlocObserver` is a widget that merges multiple `BlocObserver` widgets into one.
  ///
  /// `MultiBlocObserver` is a convenience widget that allows you to observe to
  /// multiple Blocs in a single location.
  ///
  /// It is commonly used in scenarios where you need to react to changes from
  /// multiple Blocs and perform actions such as navigation, showing
  /// dialogs, or updating the UI.
  ///
  ///
  /// ```dart
  /// MultiBlocObserver(
  ///   observers: [
  ///     BlocObserver<BlocA, BlocAState>(
  ///       observer: (context, state) {
  ///         // Handle BlocA state changes
  ///       },
  ///     ),
  ///     BlocObserver<BlocB, BlocBState>(
  ///       observer: (context, state) {
  ///         // Handle BlocB state changes
  ///       },
  ///     ),
  ///   ],
  ///   child: MyChildWidget(),
  /// );
  /// ```
  MultiBlocObserver({
    super.key,
    required List<SingleChildWidget> observers,
    required super.child,
  }) : super(
          children: observers,
        );
}
