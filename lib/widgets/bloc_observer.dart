import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/widgets/bloc_widget.dart';

/// Creates a `BlocObserver` widget.
///
/// The `observer`parameter is required.
class BlocObserver<B extends Bloc, S> extends BlocWidget<B, S> {
  /// A widget that observes to state changes in a `Bloc` and invokes a
  /// `observer` callback whenever the Bloc's state changes.
  ///
  /// `BlocObserver` is a Flutter widget which takes a [Bloc] and a
  /// `BlocObserverHandler` and invokes the `observer` in response to
  /// state changes in the `Bloc`. It should be used for any code which
  /// needs to execute in response to a state change such as navigation,
  /// showing a `SnackBar`, showing a `Dialog`, etc.
  ///
  /// If the `observeWhen` callback is specified, the `observer` will
  /// only be called on state changes where `observeWhen` returns true.
  /// If `observeWhen` is not specified, the `observer` will be called
  /// on every state change.
  ///
  ///
  /// ```dart
  /// BlocObserver<MyBloc, MyState>(
  ///  observer: (context, state) {
  ///     if(state is SuccessState){
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(content: Text('Operation Success!')),
  ///       );
  ///     }
  ///   },
  ///   child: MyChildWidget(),
  /// );
  /// ```
  const BlocObserver({
    super.key,
    super.child,
    required super.observer,
    super.observeWhen,
    super.observeOnly = true,
  });
}
