import 'package:example/counter_bloc/counter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CounterPage(
        initialValue: 0,
      ),
    );
  }
}

class CounterPage extends ReactorWidget<CounterBloc, CounterState> {
  const CounterPage({
    super.key,
    required this.initialValue,
  });

  final int initialValue;

  @override
  CounterBloc initBloc(BuildContext context) {
    return CounterBloc(initialValue);
  }

  @override
  Widget build(BuildContext context, CounterState state) {
    return Scaffold(
      body: Center(
        child: Text(
          '${state.counter}',
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              final bloc = getBloc(context);
              bloc.add(IncrementEvent());
            },
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            child: const Icon(Icons.remove),
            onPressed: () {
              final bloc = getBloc(context);
              bloc.add(DecrementEvent());
            },
          ),
        ],
      ),
    );
  }
}
