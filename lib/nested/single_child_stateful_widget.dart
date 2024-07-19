part of 'nested.dart';

/// A [StatefulWidget] that is compatible with [Nested].
abstract class SingleChildStatefulWidget extends StatefulWidget
    implements SingleChildWidget {
  /// Creates a widget that has exactly one child widget.
  const SingleChildStatefulWidget({super.key, Widget? child}) : _child = child;

  final Widget? _child;

  @override
  SingleChildStatefulElement createElement() {
    return SingleChildStatefulElement(this);
  }
}

/// A [State] for [SingleChildStatefulWidget].
///
/// Do not override [build] and instead override [buildWithChild].
abstract class SingleChildState<T extends SingleChildStatefulWidget>
    extends State<T> {
  /// A [build] method that receives an extra `child` parameter.
  ///
  /// This method may be called with a `child` different from the parameter
  /// passed to the constructor of [SingleChildStatelessWidget].
  /// It may also be called again with a different `child`, without this widget
  /// being recreated.
  Widget buildWithChild(BuildContext context, Widget? child);

  @override
  Widget build(BuildContext context) => buildWithChild(context, widget._child);
}

/// An [Element] that uses a [SingleChildStatefulWidget] as its configuration.
class SingleChildStatefulElement extends StatefulElement
    with SingleChildWidgetElementMixin {
  /// Creates an element that uses the given widget as its configuration.
  SingleChildStatefulElement(super.widget);

  @override
  SingleChildStatefulWidget get widget =>
      super.widget as SingleChildStatefulWidget;

  @override
  SingleChildState<SingleChildStatefulWidget> get state =>
      super.state as SingleChildState<SingleChildStatefulWidget>;

  @override
  Widget build() {
    if (_parent != null) {
      return state.buildWithChild(this, _parent!.injectedChild!);
    }
    return super.build();
  }
}
