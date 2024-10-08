import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/counter_bloc.dart';
import '../mock/mock_bloc.dart';

class MockCounterBloc extends MockBloc<CounterEvent, CounterState>
    implements CounterBloc {}

class CounterText extends StatelessWidget {
  const CounterText({super.key, this.useExtension = false});

  final bool useExtension;

  @override
  Widget build(BuildContext context) {
    var bloc = BlocInjector.of<CounterBloc>(context, observe: true);
    if (useExtension) {
      bloc = context.observe<CounterBloc>();
    }
    return Text('Counter text: ${bloc.state.counter}');
  }
}

class CounterTextWithObserve extends StatelessWidget {
  const CounterTextWithObserve({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.observe<CounterBloc>();

    return Column(
      children: [
        Text('Counter text: ${bloc.state.counter}'),
        MaterialButton(
          child: const Text('Increment'),
          onPressed: () {
            context.get<CounterBloc>().add(const IncrementEvent());
          },
        )
      ],
    );
  }
}

void main() {
  group('BlocInjector', () {
    testWidgets(
      'update constant widget when bloc instant is changed and observe is true',
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

        await tester.pump();

        final textFinder = find.text('Counter text: 1');

        expect(textFinder, findsOneWidget);
      },
    );

    testWidgets(
      'update constant widget when bloc instance is changed using observe() extension',
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
                          const CounterText(
                            useExtension: true,
                          ),
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

        await tester.pump();

        final textFinder = find.text('Counter text: 1');

        expect(textFinder, findsOneWidget);
      },
    );

    testWidgets(
      'update constant widget when bloc state is changed using observe() extension',
      (tester) async {
        CounterBloc bloc = CounterBloc();

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              return MaterialApp(
                home: BlocInjector<CounterBloc>.instance(
                  instance: bloc,
                  child: const CounterTextWithObserve(),
                ),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.text('Increment');

        await tester.tap(buttonFinder);

        await tester.pump();

        final textFinder = find.text('Counter text: 1');

        expect(textFinder, findsOneWidget);
      },
    );
  });
}
