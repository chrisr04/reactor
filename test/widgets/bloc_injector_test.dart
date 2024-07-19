import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/counter_bloc.dart';
import '../mock/mock_bloc.dart';

class MockCounterBloc extends MockBloc<CounterEvent, CounterState>
    implements CounterBloc {}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocInjector.of<CounterBloc>(context, listen: true);
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
                home: BlocInjector<CounterBloc>(
                  bloc: bloc,
                  child: Scaffold(
                    body: Center(
                      child: Column(
                        children: [
                          const CounterText(),
                          MaterialButton(
                            child: const Text('change instance'),
                            onPressed: () {
                              setState(() {
                                bloc = CounterBloc(1);
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
