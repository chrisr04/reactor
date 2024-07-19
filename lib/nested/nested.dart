import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

part 'nested_hook.dart';
part 'single_child_widget.dart';
part 'single_child_stateless_widget.dart';
part 'single_child_stateful_widget.dart';

/// Original Source: https://github.com/rrousselGit/nested
///
/// A widget that simplify the writing of deeply nested widget trees.
///
/// It relies on the new kind of widget [SingleChildWidget], which has two
/// concrete implementations:
/// - [SingleChildStatelessWidget]
/// - [SingleChildStatefulWidget]
///
/// They are both respectively a [SingleChildWidget] variant of [StatelessWidget]
/// and [StatefulWidget].
///
/// The difference between a widget and its single-child variant is that they have
/// a custom `build` method that takes an extra parameter.
///
/// As such, a `StatelessWidget` would be:
///
/// ```dart
/// class MyWidget extends StatelessWidget {
///   MyWidget({Key key, this.child}): super(key: key);
///
///   final Widget child;
///
///   @override
///   Widget build(BuildContext context) {
///     return SomethingWidget(child: child);
///   }
/// }
/// ```
///
/// Whereas a [SingleChildStatelessWidget] would be:
///
/// ```dart
/// class MyWidget extends SingleChildStatelessWidget {
///   MyWidget({Key key, Widget child}): super(key: key, child: child);
///
///   @override
///   Widget buildWithChild(BuildContext context, Widget child) {
///     return SomethingWidget(child: child);
///   }
/// }
/// ```
///
/// This allows our new `MyWidget` to be used both with:
///
/// ```dart
/// MyWidget(
///   child: AnotherWidget(),
/// )
/// ```
///
/// and to be placed inside `children` of [Nested] like so:
///
/// ```dart
/// Nested(
///   children: [
///     MyWidget(),
///     ...
///   ],
///   child: AnotherWidget(),
/// )
/// ```
class Nested extends StatelessWidget implements SingleChildWidget {
  /// Allows configuring key, children and child
  Nested({
    super.key,
    required List<SingleChildWidget> children,
    Widget? child,
  })  : assert(children.isNotEmpty),
        _children = children,
        _child = child;

  final List<SingleChildWidget> _children;
  final Widget? _child;

  // coverage:ignore-start
  @override
  Widget build(BuildContext context) =>
      throw StateError('implemented internally');
  // coverage:ignore-end

  @override
  NestedElement createElement() => NestedElement(this);
}

class NestedElement extends StatelessElement
    with SingleChildWidgetElementMixin {
  NestedElement(super.widget);

  @override
  Nested get widget => super.widget as Nested;

  final nodes = <_NestedHookElement>{};

  @override
  Widget build() {
    _NestedHook? nestedHook;
    Widget? nextNode = _parent?.injectedChild ?? widget._child;

    for (final child in widget._children.reversed) {
      nextNode = nestedHook = _NestedHook(
        owner: this,
        wrappedWidget: child,
        injectedChild: nextNode,
      );
    }

    if (nestedHook != null) {
      // We manually update _NestedHookElement instead of letter widgets do their thing
      // because an item N may be constant but N+1 not. So, if we used widgets
      // then N+1 wouldn't rebuild because N didn't change
      for (final node in nodes) {
        node
          ..wrappedChild = nestedHook!.wrappedWidget
          ..injectedChild = nestedHook.injectedChild;

        final next = nestedHook.injectedChild;
        if (next is _NestedHook) {
          nestedHook = next;
        } else {
          break;
        }
      }
    }

    return nextNode!;
  }
}
