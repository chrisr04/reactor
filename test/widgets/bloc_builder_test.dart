import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/counter_bloc.dart';
import '../mock/mock_bloc.dart';
import '../utils/when_emit.dart';

class MockCounterBloc extends MockBloc<CounterEvent, CounterState>
    implements CounterBloc {}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Text('Counter: ${state.counter}');
      },
    );
  }
}

void main() {
  late MockCounterBloc counterBloc;

  setUp(() {
    counterBloc = MockCounterBloc();
  });

  group('BlocBuilder', () {
    testWidgets('build when widget is initializated the counter is 0',
        (tester) async {
      whenEmit(
        counterBloc,
        states: <CounterState>[],
        initialState: const InitialState(0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocInjector<CounterBloc>(
            create: (context) => counterBloc,
            child: Scaffold(
              body: Center(
                child: BlocBuilder<CounterBloc, CounterState>(
                  builder: (context, state) {
                    return Text('Counter: ${state.counter}');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final counterText = find.text('Counter: 0');

      expect(counterText, findsOneWidget);
    });

    testWidgets('build when state is changed the counter is 1', (tester) async {
      whenEmit(
        counterBloc,
        initialState: const InitialState(0),
        states: [
          const IncrementState(1),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocInjector<CounterBloc>(
            create: (context) => counterBloc,
            child: Scaffold(
              body: Center(
                child: BlocBuilder<CounterBloc, CounterState>(
                  builder: (context, state) {
                    return Text('Counter: ${state.counter}');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final counterText = find.text('Counter: 1');

      expect(counterText, findsOneWidget);
    });

    testWidgets('build when buildWhen condition is true', (tester) async {
      whenEmit(
        counterBloc,
        initialState: const InitialState(0),
        states: [
          const IncrementState(1),
          const IncrementState(2),
          const IncrementState(3),
          const DecrementState(2),
          const IncrementState(3),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocInjector<CounterBloc>(
            create: (context) => counterBloc,
            child: Scaffold(
              body: Center(
                child: BlocBuilder<CounterBloc, CounterState>(
                  buildWhen: (previous, current) => current is DecrementState,
                  builder: (context, state) {
                    return Text('Counter: ${state.counter}');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final counterText = find.text('Counter: 2');

      expect(counterText, findsOneWidget);
    });

    testWidgets(
      'update BlocBuilder when bloc instance was changed',
      (tester) async {
        CounterBloc bloc = CounterBloc();

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              return MaterialApp(
                home: BlocInjector<CounterBloc>.instance(
                  instance: bloc,
                  child: Scaffold(
                    body: Center(
                      child: Column(
                        children: [
                          const CounterText(),
                          MaterialButton(
                            child: const Text('change instance'),
                            onPressed: () {
                              setState(() {
                                bloc = CounterBloc(initialValue: 1);
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.text('change instance');

        await tester.tap(buttonFinder);

        await tester.pumpAndSettle();

        final counterText = find.text('Counter: 1');

        expect(counterText, findsOneWidget);
      },
    );
  });
}
