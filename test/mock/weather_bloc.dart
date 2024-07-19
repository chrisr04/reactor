import 'package:reactor/reactor.dart';

// Bloc
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(const InitialState('sunny')) {
    register<GetWeatherEvent>((event, emit) {
      emit(const WeatherLoadedState('snow'));
    });
  }
}

// Events
sealed class WeatherEvent {}

final class GetWeatherEvent extends WeatherEvent {}

// States
sealed class WeatherState {
  const WeatherState(this.weather);
  final String weather;
}

final class InitialState extends WeatherState {
  const InitialState(super.weather);
}

final class WeatherLoadedState extends WeatherState {
  const WeatherLoadedState(super.weather);
}
