part of 'nested.dart';

class _NestedHook extends StatelessWidget {
  const _NestedHook({
    this.injectedChild,
    required this.wrappedWidget,
    required this.owner,
  });

  final SingleChildWidget wrappedWidget;
  final Widget? injectedChild;
  final NestedElement owner;

  @override
  _NestedHookElement createElement() => _NestedHookElement(this);

  // coverage:ignore-start
  @override
  Widget build(BuildContext context) => throw StateError('handled internally');
  // coverage:ignore-end
}

class _NestedHookElement extends StatelessElement {
  _NestedHookElement(super.widget);

  @override
  _NestedHook get widget => super.widget as _NestedHook;

  Widget? _injectedChild;
  Widget? get injectedChild => _injectedChild;
  set injectedChild(Widget? value) {
    final previous = _injectedChild;
    if (value is _NestedHook &&
        previous is _NestedHook &&
        Widget.canUpdate(value.wrappedWidget, previous.wrappedWidget)) {
      // no need to rebuild the wrapped widget just for a _NestedHook.
      // The widget doesn't matter here, only its Element.
      return;
    }
    if (previous != value) {
      _injectedChild = value;
      visitChildren((e) => e.markNeedsBuild());
    }
  }

  SingleChildWidget? _wrappedChild;
  SingleChildWidget? get wrappedChild => _wrappedChild;
  set wrappedChild(SingleChildWidget? value) {
    if (_wrappedChild != value) {
      _wrappedChild = value;
      markNeedsBuild();
    }
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    widget.owner.nodes.add(this);
    _wrappedChild = widget.wrappedWidget;
    _injectedChild = widget.injectedChild;
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    widget.owner.nodes.remove(this);
    super.unmount();
  }

  @override
  Widget build() {
    return wrappedChild!;
  }
}
