part of 'nested.dart';

/// A [StatelessWidget] that implements [SingleChildWidget] and is therefore
/// compatible with [Nested].
///
/// Its [build] method must **not** be overriden. Instead use [buildWithChild].
abstract class SingleChildStatelessWidget extends StatelessWidget
    implements SingleChildWidget {
  /// Creates a widget that has exactly one child widget.
  const SingleChildStatelessWidget({super.key, Widget? child}) : _child = child;

  final Widget? _child;

  /// A [build] method that receives an extra `child` parameter.
  ///
  /// This method may be called with a `child` different from the parameter
  /// passed to the constructor of [SingleChildStatelessWidget].
  /// It may also be called again with a different `child`, without this widget
  /// being recreated.
  Widget buildWithChild(BuildContext context, Widget? child);

  @override
  Widget build(BuildContext context) => buildWithChild(context, _child);

  @override
  SingleChildStatelessElement createElement() {
    return SingleChildStatelessElement(this);
  }
}

/// An [Element] that uses a [SingleChildStatelessWidget] as its configuration.
class SingleChildStatelessElement extends StatelessElement
    with SingleChildWidgetElementMixin {
  /// Creates an element that uses the given widget as its configuration.
  SingleChildStatelessElement(super.widget);

  @override
  Widget build() {
    if (_parent != null) {
      return widget.buildWithChild(this, _parent!.injectedChild);
    }
    return super.build();
  }

  @override
  SingleChildStatelessWidget get widget =>
      super.widget as SingleChildStatelessWidget;
}
