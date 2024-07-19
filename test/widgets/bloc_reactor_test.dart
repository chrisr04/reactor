import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/counter_bloc.dart';
import '../mock/mock_bloc.dart';
import '../utils/when_emit.dart';

class MockCounterBloc extends MockBloc<CounterEvent, CounterState>
    implements CounterBloc {}

void main() {
  late MockCounterBloc counterBloc;

  setUp(() {
    counterBloc = MockCounterBloc();
  });

  group('BlocReactor', () {
    testWidgets('observe and build when counter is incremented',
        (tester) async {
      whenEmit(
        counterBloc,
        initialState: const InitialState(0),
        states: <CounterState>[
          const IncrementState(1),
        ],
      );

      bool wasObserved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocInjector<CounterBloc>(
            bloc: counterBloc,
            child: Scaffold(
              body: Center(
                child: BlocReactor<CounterBloc, CounterState>(
                  observer: (context, state) {
                    if (state is IncrementState) {
                      wasObserved = true;
                    }
                  },
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
      expect(wasObserved, isTrue);
    });
  });
}
