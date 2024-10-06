import 'package:flutter/material.dart';
import 'package:reactor/reactor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/counter_bloc.dart';
import '../mock/weather_bloc.dart';

void main() {
  late CounterBloc counterBloc;
  late WeatherBloc weatherBloc;

  setUp(() {
    counterBloc = CounterBloc();
    weatherBloc = WeatherBloc();
  });

  group('MultiBlocInjector', () {
    testWidgets('build when widget is initializated the counter is 0',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocInjector(
            injectors: [
              BlocInjector<CounterBloc>(
                create: (context) => counterBloc,
              ),
              BlocInjector<WeatherBloc>(
                create: (context) => weatherBloc,
              ),
            ],
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

      final counterInjector = find.byType(BlocInjector<CounterBloc>);
      final weatherInjector = find.byType(BlocInjector<WeatherBloc>);

      expect(counterInjector, findsOneWidget);
      expect(weatherInjector, findsOneWidget);
    });
  });
}
