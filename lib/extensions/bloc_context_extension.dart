import 'package:flutter/material.dart';
import 'package:reactor/bloc/bloc.dart';
import 'package:reactor/widgets/widgets.dart';

extension BlocContextExtension on BuildContext {
  B get<B extends Bloc>({bool listen = false}) {
    return BlocInjector.of<B>(this, listen: listen);
  }

  bool exist<B extends Bloc>() {
    try {
      get<B>();
      return true;
    } catch (e) {
      return false;
    }
  }
}
