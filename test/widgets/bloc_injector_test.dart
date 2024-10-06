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
    var bloc = BlocInjector.of<CounterBloc>(context, listen: true);
    if (useExtension) {
      bloc = context.get<CounterBloc>(listen: true);
    }
    return Text('Counter text: ${bloc.state.counter}');
  }
}

void main() {
  group('BlocInjector', () {
    testWidgets(
      'update constant widget when bloc instant is changed and listen is true',
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
      'update constant widget when bloc instant is changed and listen is true using get() extension',
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
  });
}
