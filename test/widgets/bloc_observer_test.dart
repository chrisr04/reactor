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
    testWidgets('observe when state is changed the counter is 1',
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
            bloc: counterBloc,
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
              bloc: counterBloc,
              child: Scaffold(
                body: Center(
                  child: BlocObserver<CounterBloc, CounterState>(
                    observeWhen: (previous, current) =>
                        current is DecrementState,
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
                home: BlocInjector<CounterBloc>(
                  bloc: bloc..add(IncrementEvent()),
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

        final counterText = find.text('Counter: 2');

        expect(counterText, findsOneWidget);
      },
    );
  });
}
