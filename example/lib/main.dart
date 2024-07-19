import 'package:example/counter_bloc/counter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return BlocInjector<CounterBloc>(
      bloc: counterBloc,
      child: const MaterialApp(
        home: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          return Center(
            child: Text(
              '${state.counter}',
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              BlocInjector.of<CounterBloc>(context).add(IncrementEvent());
            },
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            child: const Icon(Icons.remove),
            onPressed: () {
              BlocInjector.of<CounterBloc>(context).add(DecrementEvent());
            },
          ),
        ],
      ),
    );
  }
}
