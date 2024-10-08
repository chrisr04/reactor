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
    return BlocObserver<CounterBloc, CounterState>(
      observer: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Counter: ${state.counter}'),
          ),
        );
      },
      child: const Text('Counter'),
    );
  }
}

void main() {
  late MockCounterBloc counterBloc;

  setUp(() {
    counterBloc = MockCounterBloc();
  });

  group('BlocObserver', () {
    testWidgets('observe when state is changed then the counter is 1',
        (tester) async {
      int counter = 0;

      whenEmit(
        counterBloc,
        initialState: const InitialState(0),
        states: <CounterState>[
          const IncrementState(1),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocInjector<CounterBloc>(
            create: (context) => counterBloc,
            child: Scaffold(
              body: Center(
                child: BlocObserver<CounterBloc, CounterState>(
                  observer: (context, state) {
                    if (state is IncrementState) {
                      counter = state.counter;
                    }
                  },
                  child: const Text('Counter:'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(counter, equals(1));
    });

    testWidgets(
      'observe when observeWhen condition is true',
      (tester) async {
        int counter = 0;

        whenEmit(
          counterBloc,
          initialState: const InitialState(0),
          states: <CounterState>[
            const IncrementState(3),
            const DecrementState(2),
            const IncrementState(5),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocInjector<CounterBloc>(
              create: (context) => counterBloc,
              child: Scaffold(
                body: Center(
                  child: BlocObserver<CounterBloc, CounterState>(
                    observeWhen: (previous, current) {
                      return current is DecrementState;
                    },
                    observer: (context, state) {
                      counter = state.counter;
                    },
                    child: const Text('Counter'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(counter, equals(2));
      },
    );

    testWidgets(
      'update BlocObserver when bloc instance was changed',
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
                            child: const Text('Change instance'),
                            onPressed: () {
                              setState(() {
                                bloc = CounterBloc(initialValue: 1);
                              });
                            },
                          ),
                          MaterialButton(
                            child: const Text('Increment'),
                            onPressed: () {
                              bloc.add(const IncrementEvent());
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

        final buttonFinder = find.text('Change instance');

        await tester.tap(buttonFinder);

        await tester.pumpAndSettle();

        final buttonIncrementFinder = find.text('Increment');

        await tester.tap(buttonIncrementFinder);

        await tester.pumpAndSettle();

        final counterText = find.text('Counter: 2');

        expect(counterText, findsOneWidget);
      },
    );
  });
}
