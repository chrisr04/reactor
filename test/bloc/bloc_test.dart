import 'package:flutter_test/flutter_test.dart';

import '../mock/counter_bloc.dart';

void main() {
  late CounterBloc myBloc;

  setUp(() {
    myBloc = CounterBloc();
  });

  test(
    'MyBloc should emit an [NewTestState] when the [InitialTestEvent] is added',
    () async {
      myBloc.add(IncrementEvent());

      await expectLater(myBloc.stream, emits(isA<IncrementState>()));
      expect(myBloc.state, isA<IncrementState>());
      expect(myBloc.previousState, isA<InitialState>());
    },
  );

  test(
    'MyBloc.isClosed should return true after the close method is called',
    () async {
      await myBloc.close();

      expect(myBloc.isClosed, isTrue);
    },
  );

  test(
    'MyBloc.add should throw a StateError when add an unregistered [UnregisteredTestEvent] ',
    () async {
      expect(
        () => myBloc.add(UnregisteredEvent()),
        throwsA(isStateError),
      );
    },
  );

  test(
    'MyBloc.add should throw a StateError when add is called with and isClosed is True ',
    () async {
      await myBloc.close();

      expect(myBloc.isClosed, isTrue);
      expect(
        () => myBloc.add(DecrementEvent()),
        throwsA(isStateError),
      );
    },
  );
}
