import 'package:mocktail/mocktail.dart';
import 'package:reactor/reactor.dart';

void whenEmit<E, S>(
  Bloc<E, S> bloc, {
  required S initialState,
  required List<S> states,
}) {
  final mockStream = Stream<S>.fromIterable(states).asBroadcastStream();

  when(() => bloc.state).thenReturn(initialState);
  when(() => bloc.previousState).thenReturn(bloc.state);

  when(() => bloc.stream).thenAnswer(
    (_) => mockStream.map((state) {
      when(() => bloc.previousState).thenReturn(bloc.state);
      when(() => bloc.state).thenReturn(state);
      return state;
    }),
  );
}
