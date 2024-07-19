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

  group('MultiBlocObserver', () {
    testWidgets('build when widget is initializated the counter is 0',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocInjector(
            injectors: [
              BlocInjector<CounterBloc>(
                bloc: counterBloc,
              ),
              BlocInjector<WeatherBloc>(
                bloc: weatherBloc,
              ),
            ],
            child: MultiBlocObserver(
              observers: [
                BlocObserver<CounterBloc, CounterState>(
                  observer: (context, state) {},
                ),
                BlocObserver<WeatherBloc, WeatherState>(
                  observer: (context, state) {},
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
        ),
      );

      await tester.pumpAndSettle();

      final counterListener =
          find.byType(BlocObserver<CounterBloc, CounterState>);
      final weatherListener =
          find.byType(BlocObserver<WeatherBloc, WeatherState>);

      expect(counterListener, findsOneWidget);
      expect(weatherListener, findsOneWidget);
    });
  });
}
