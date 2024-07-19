part of 'nested.dart';

/// A [Widget] that takes a single descendant.
///
/// See also:
/// - [SingleChildStatelessWidget]
/// - [SingleChildStatefulWidget]
abstract class SingleChildWidget implements Widget {
  @override
  SingleChildWidgetElementMixin createElement();
}

mixin SingleChildWidgetElementMixin on Element {
  _NestedHookElement? _parent;

  @override
  void mount(Element? parent, dynamic newSlot) {
    if (parent is _NestedHookElement?) {
      _parent = parent;
    }
    super.mount(parent, newSlot);
  }

  @override
  void activate() {
    super.activate();
    visitAncestorElements((parent) {
      if (parent is _NestedHookElement) {
        _parent = parent;
      }
      return false;
    });
  }
}
