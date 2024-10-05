import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/widgets/bloc_widget.dart';

/// Creates a `BlocBuilder` widget.
class BlocBuilder<B extends Bloc, S> extends BlocWidget<B, S> {
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
    required super.builder,
    super.buildWhen,
  });
}
