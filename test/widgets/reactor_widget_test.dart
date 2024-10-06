import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reactor/reactor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/counter_bloc.dart';
import '../mock/mock_bloc.dart';
import '../utils/when_emit.dart';

class MockCounterBloc extends MockBloc<CounterEvent, CounterState>
    implements CounterBloc {}

class MockBuildContext extends Mock implements BuildContext {}

class CounterTextWithoutOverrides
    extends ReactorWidget<CounterBloc, CounterState> {
  const CounterTextWithoutOverrides({super.key});

  @override
  Widget build(BuildContext context, CounterState state) {
    return Column(
      children: [
        Text('Counter: ${state.counter}'),
        MaterialButton(
          onPressed: () {
            final bloc = getBloc(context);
            bloc.add(const IncrementEvent());
          },
          child: const Text('Increment'),
        )
      ],
    );
  }
}

class CounterText extends ReactorWidget<CounterBloc, CounterState> {
  const CounterText({
    super.key,
    required this.mockedBloc,
    this.mockedBuildWhen,
    this.mockedObserveWhen,
    this.mockedObserveOnly = false,
    this.mockedCloseOnDispose = true,
    this.mockedObserver,
  });

  final CounterBloc mockedBloc;
  final BlocCondition? mockedBuildWhen;
  final BlocCondition? mockedObserveWhen;
  final bool mockedObserveOnly;
  final bool mockedCloseOnDispose;
  final BlocObserverHandler<CounterState>? mockedObserver;

  @override
  bool get closeOnDispose => mockedCloseOnDispose;

  @override
  bool get observeOnly => mockedObserveOnly;

  @override
  CounterBloc initBloc(BuildContext context) {
    return mockedBloc;
  }

  @override
  bool buildWhen(CounterState previous, CounterState current) {
    return mockedBuildWhen?.call(previous, current) ?? true;
  }

  @override
  bool observeWhen(CounterState previous, CounterState current) {
    return mockedObserveWhen?.call(previous, current) ?? true;
  }

  @override
  void observer(BuildContext context, CounterState state) {
    mockedObserver?.call(context, state);
  }

  @override
  Widget build(BuildContext context, CounterState state) {
    return Text('Counter: ${state.counter}');
  }
}

void main() {
  late MockCounterBloc counterBloc;

  setUp(() {
    counterBloc = MockCounterBloc();
  });

  group('ReactorWidget', () {

    test(
      'should load getters with default values correctly',
      () {
        const widget = CounterTextWithoutOverrides();

        expect(widget.closeOnDispose, isTrue);
        expect(widget.observeOnly, isFalse);
      },
    );

    test(
      'should throws a FlutterError if bloc is not found',
      () {
        const widget = CounterTextWithoutOverrides();

        expect(
          () => widget.initBloc(MockBuildContext()),
          throwsA(isFlutterError),
        );
      },
    );

    testWidgets(
      'build when state is changed and injection is explicit',
      (tester) async {
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
              child: const CounterTextWithoutOverrides(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final counterText = find.text('Counter: 1');

        expect(counterText, findsOneWidget);
      },
    );

    testWidgets(
      'add IncrementEvent when button is tapped and injection is explicit',
      (tester) async {
        whenEmit<CounterEvent, CounterState>(
          counterBloc,
          initialState: const InitialState(0),
          states: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocInjector<CounterBloc>(
              create: (context) => counterBloc,
              child: const CounterTextWithoutOverrides(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byType(MaterialButton));
        await tester.pump();

        verify(() => counterBloc.add(const IncrementEvent())).called(1);
      },
    );

    testWidgets('build when widget is initializated then the counter is 0',
        (tester) async {
      whenEmit(
        counterBloc,
        states: <CounterState>[],
        initialState: const InitialState(0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CounterText(
            mockedBloc: counterBloc,
          ),
        ),
      );

      final counterText = find.text('Counter: 0');

      expect(counterText, findsOneWidget);
    });

    testWidgets(
      'build when widget is initializated with counter in 0 and closeOnDispose is false',
      (tester) async {
        whenEmit(
          counterBloc,
          states: <CounterState>[],
          initialState: const InitialState(0),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CounterText(
              mockedBloc: counterBloc,
              mockedCloseOnDispose: false,
            ),
          ),
        );

        final counterText = find.text('Counter: 0');

        expect(counterText, findsOneWidget);
      },
    );

    testWidgets('build when state is changed then the counter is 1',
        (tester) async {
      whenEmit(
        counterBloc,
        initialState: const InitialState(0),
        states: [
          const IncrementState(1),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CounterText(
            mockedBloc: counterBloc,
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
          home: CounterText(
            mockedBloc: counterBloc,
            mockedBuildWhen: (previous, current) => current is DecrementState,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final counterText = find.text('Counter: 2');

      expect(counterText, findsOneWidget);
    });

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
          home: CounterText(
            mockedBloc: counterBloc,
            mockedObserver: (context, state) {
              if (state is IncrementState) {
                counter = state.counter;
              }
            },
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
            home: CounterText(
              mockedBloc: counterBloc,
              mockedObserveWhen: (previous, current) {
                return current is DecrementState;
              },
              mockedObserver: (context, state) {
                counter = state.counter;
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(counter, equals(2));
      },
    );

    testWidgets(
      'prevent build when observeOnly is true and state is changed then the counter is 1',
      (tester) async {
        whenEmit(
          counterBloc,
          initialState: const InitialState(0),
          states: [
            const IncrementState(1),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CounterText(
              mockedBloc: counterBloc,
              mockedObserveOnly: true,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final counterText = find.text('Counter: 1');

        expect(counterText, findsNothing);
      },
    );
  });
}
