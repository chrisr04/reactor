import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactor/nested/nested.dart';

import '../mock/mock_nested_widgets.dart';
import '../utils/matches_in_order.dart';

void main() {
  testWidgets('insert widgets in natural order', (tester) async {
    await tester.pumpWidget(
      Nested(
        children: const [
          MySizedBox(height: 0),
          MySizedBox(height: 1),
        ],
        child: const Text('foo', textDirection: TextDirection.ltr),
      ),
    );

    expect(find.text('foo'), findsOneWidget);

    expect(
      find.byType(MySizedBox),
      matchesInOrder([
        isA<MySizedBox>().having((s) => s.height, 'height', 0),
        isA<MySizedBox>().having((s) => s.height, 'height', 1),
      ]),
    );

    await tester.pumpWidget(
      Nested(
        children: const [
          MySizedBox(height: 10),
          MySizedBox(height: 11),
        ],
        child: const Text('bar', textDirection: TextDirection.ltr),
      ),
    );

    expect(find.text('bar'), findsOneWidget);

    expect(
      find.byType(MySizedBox),
      matchesInOrder([
        isA<MySizedBox>().having((s) => s.height, 'height', 10),
        isA<MySizedBox>().having((s) => s.height, 'height', 11),
      ]),
    );
  });
  testWidgets('nested inside nested', (tester) async {
    await tester.pumpWidget(Nested(
      children: [
        const MySizedBox(height: 0),
        Nested(
          children: const [
            MySizedBox(height: 1),
            MySizedBox(height: 2),
          ],
        ),
        const MySizedBox(height: 3),
      ],
      child: const Text('foo', textDirection: TextDirection.ltr),
    ));

    expect(find.text('foo'), findsOneWidget);

    expect(
      find.byType(MySizedBox),
      matchesInOrder([
        isA<MySizedBox>().having((s) => s.height, 'height', 0),
        isA<MySizedBox>().having((s) => s.height, 'height', 1),
        isA<MySizedBox>().having((s) => s.height, 'height', 2),
        isA<MySizedBox>().having((s) => s.height, 'height', 3),
      ]),
    );

    await tester.pumpWidget(Nested(
      children: [
        const MySizedBox(height: 10),
        Nested(
          children: const [
            MySizedBox(height: 11),
            MySizedBox(height: 12),
          ],
        ),
        const MySizedBox(height: 13),
      ],
      child: const Text('bar', textDirection: TextDirection.ltr),
    ));

    expect(find.text('bar'), findsOneWidget);

    expect(
      find.byType(MySizedBox),
      matchesInOrder([
        isA<MySizedBox>().having((s) => s.height, 'height', 10),
        isA<MySizedBox>().having((s) => s.height, 'height', 11),
        isA<MySizedBox>().having((s) => s.height, 'height', 12),
        isA<MySizedBox>().having((s) => s.height, 'height', 13),
      ]),
    );
  });

  test('children is required', () {
    expect(
      () => Nested(
        children: const [],
        child: const Text('foo', textDirection: TextDirection.ltr),
      ),
      throwsAssertionError,
    );

    Nested(
      children: const [MySizedBox()],
      child: const Text('foo', textDirection: TextDirection.ltr),
    );
  });

  testWidgets('no unnecessary rebuild #2', (tester) async {
    var buildCount = 0;
    final child = Nested(
      children: [
        MySizedBox(didBuild: (_, __) => buildCount++),
      ],
      child: Container(),
    );

    await tester.pumpWidget(child);

    expect(buildCount, equals(1));
    await tester.pumpWidget(child);

    expect(buildCount, equals(1));
  });

  testWidgets(
    'if only one node, the previous and next nodes may not rebuild',
    (tester) async {
      var buildCount1 = 0;
      final first = MySizedBox(didBuild: (_, __) => buildCount1++);
      var buildCount2 = 0;
      var buildCount3 = 0;
      final third = MySizedBox(didBuild: (_, __) => buildCount3++);

      const child = Text('foo', textDirection: TextDirection.ltr);

      await tester.pumpWidget(
        Nested(
          children: [
            first,
            MySizedBox(
              didBuild: (_, __) => buildCount2++,
            ),
            third,
          ],
          child: child,
        ),
      );

      expect(buildCount1, equals(1));
      expect(buildCount2, equals(1));
      expect(buildCount3, equals(1));
      expect(find.text('foo'), findsOneWidget);

      await tester.pumpWidget(
        Nested(
          children: [
            first,
            MySizedBox(
              didBuild: (_, __) => buildCount2++,
            ),
            third,
          ],
          child: child,
        ),
      );

      expect(buildCount1, equals(1));
      expect(buildCount2, equals(2));
      expect(buildCount3, equals(1));
      expect(find.text('foo'), findsOneWidget);
    },
  );

  testWidgets(
    'if child changes, rebuild the previous widget',
    (tester) async {
      var buildCount1 = 0;
      final first = MySizedBox(didBuild: (_, __) => buildCount1++);
      var buildCount2 = 0;
      final second = MySizedBox(didBuild: (_, __) => buildCount2++);

      await tester.pumpWidget(
        Nested(
          children: [first, second],
          child: const Text('foo', textDirection: TextDirection.ltr),
        ),
      );

      expect(buildCount1, equals(1));
      expect(buildCount2, equals(1));
      expect(find.text('foo'), findsOneWidget);

      await tester.pumpWidget(
        Nested(
          children: [
            first,
            second,
          ],
          child: const Text('bar', textDirection: TextDirection.ltr),
        ),
      );

      expect(buildCount1, equals(1));
      expect(buildCount2, equals(2));
      expect(find.text('bar'), findsOneWidget);
    },
  );

  testWidgets('SingleChildWidget can be used by itself', (tester) async {
    await tester.pumpWidget(
      const MySizedBox(
        height: 42,
        child: Text('foo', textDirection: TextDirection.ltr),
      ),
    );

    expect(find.text('foo'), findsOneWidget);

    expect(
      find.byType(MySizedBox),
      matchesInOrder([
        isA<MySizedBox>().having((e) => e.height, 'height', equals(42)),
      ]),
    );
  });
  testWidgets('SingleChildStatefulWidget can be used alone', (tester) async {
    Widget? child;
    BuildContext? context;

    const text = Text('foo', textDirection: TextDirection.ltr);

    await tester.pumpWidget(
      MyStateful(
        didBuild: (ctx, c) {
          child = c;
          context = ctx;
        },
        child: text,
      ),
    );

    expect(find.text('foo'), findsOneWidget);
    expect(context, equals(tester.element(find.byType(MyStateful))));
    expect(child, equals(text));
  });
  testWidgets('SingleChildStatefulWidget can be used in nested',
      (tester) async {
    Widget? child;
    BuildContext? context;

    const text = Text('foo', textDirection: TextDirection.ltr);

    await tester.pumpWidget(
      Nested(
        children: [
          MyStateful(
            didBuild: (ctx, c) {
              child = c;
              context = ctx;
            },
          ),
        ],
        child: text,
      ),
    );

    expect(find.text('foo'), findsOneWidget);
    expect(context, equals(tester.element(find.byType(MyStateful))));
    expect(child, equals(text));
  });

  testWidgets('Nested with globalKeys', (tester) async {
    final firstKey = GlobalKey(debugLabel: 'first');
    final secondKey = GlobalKey(debugLabel: 'second');

    await tester.pumpWidget(
      Nested(
        children: [
          MyStateful(key: firstKey),
          MyStateful(key: secondKey),
        ],
        child: Container(),
      ),
    );

    expect(
      find.byType(MyStateful),
      matchesInOrder([
        isA<MyStateful>().having((s) => s.key, 'key', firstKey),
        isA<MyStateful>().having((s) => s.key, 'key', secondKey),
      ]),
    );

    await tester.pumpWidget(
      Nested(
        children: [
          MyStateful(key: secondKey, didInit: () => throw Error()),
          MyStateful(key: firstKey, didInit: () => throw Error()),
        ],
        child: Container(),
      ),
    );

    expect(
      find.byType(MyStateful),
      matchesInOrder([
        isA<MyStateful>().having((s) => s.key, 'key', secondKey),
        isA<MyStateful>().having((s) => s.key, 'key', firstKey),
      ]),
    );
  });
}
