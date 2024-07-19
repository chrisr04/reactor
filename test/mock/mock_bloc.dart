import 'package:mocktail/mocktail.dart';
import 'package:reactor/reactor.dart';

class MockBloc<E, S> extends Mock implements Bloc<E, S> {
  @override
  Future<void> close() async {}
}
