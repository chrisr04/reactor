import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reactor/nested/nested.dart';

class MyStateful extends SingleChildStatefulWidget {
  const MyStateful({super.key, this.didBuild, this.didInit, super.child});

  final void Function(BuildContext, Widget?)? didBuild;
  final void Function()? didInit;

  @override
  SingleChildState<MyStateful> createState() => _MyStatefulState();
}

class _MyStatefulState extends SingleChildState<MyStateful> {
  @override
  void initState() {
    super.initState();
    widget.didInit?.call();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    widget.didBuild?.call(context, child);
    return child!;
  }
}

class MySizedBox extends SingleChildStatelessWidget {
  const MySizedBox({super.key, this.didBuild, this.height, super.child});

  final double? height;

  final void Function(BuildContext context, Widget? child)? didBuild;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    didBuild?.call(context, child);
    return child!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
  }
}

abstract class BaseStateless extends StatelessWidget {
  const BaseStateless({super.key, this.height});

  final double? height;
}

abstract class BaseStateful extends StatefulWidget {
  const BaseStateful({super.key, required this.height});

  final double height;
  @override
  State<BaseStateful> createState() => _BaseStatefulState();

  Widget build(BuildContext context);
}

class _BaseStatefulState extends State<BaseStateful> {
  double? width;

  @override
  void initState() {
    super.initState();
    width = widget.height * 2;
  }

  @override
  Widget build(BuildContext context) => widget.build(context);
}
