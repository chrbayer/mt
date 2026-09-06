import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/practice/widgets/picture_group.dart';

/// The scatter has to hold still. Pictures that move while a child counts
/// them would make the lesson impossible.
void main() {
  Future<List<Offset>> positions(
    WidgetTester tester, {
    required int count,
    required int seed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PictureGroup(
              count: count,
              picture: '🐝',
              arrangement: PictureArrangement.scattered,
              seed: seed,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return tester
        .widgetList<Text>(find.text('🐝'))
        .map((_) => Offset.zero)
        .toList()
      ..clear()
      ..addAll(find
          .text('🐝')
          .evaluate()
          .map((e) => (e.renderObject! as RenderBox).localToGlobal(Offset.zero)));
  }

  testWidgets('a cloud draws exactly as many pictures as asked',
      (tester) async {
    for (var count = 1; count <= 5; count++) {
      await positions(tester, count: count, seed: 3);
      expect(find.text('🐝'), findsNWidgets(count));
    }
  });

  testWidgets('the same task scatters the same way every time',
      (tester) async {
    final first = await positions(tester, count: 5, seed: 12);
    final again = await positions(tester, count: 5, seed: 12);
    expect(again, first);
  });

  testWidgets('different tasks scatter differently', (tester) async {
    final one = await positions(tester, count: 5, seed: 1);
    final other = await positions(tester, count: 5, seed: 2);
    expect(other, isNot(one));
  });

  testWidgets('no two pictures land on top of each other', (tester) async {
    for (var count = 2; count <= 5; count++) {
      for (var seed = 0; seed < 20; seed++) {
        final spots = await positions(tester, count: count, seed: seed);
        for (var i = 0; i < spots.length; i++) {
          for (var j = i + 1; j < spots.length; j++) {
            expect(
              (spots[i] - spots[j]).distance,
              greaterThan(30),
              reason: '$count Bilder, seed $seed',
            );
          }
        }
      }
    }
  });

  testWidgets('a cloud is never accidentally a straight line', (tester) async {
    // If every picture shared one line the lesson would be the row again.
    var straight = 0;
    for (var seed = 0; seed < 30; seed++) {
      final spots = await positions(tester, count: 4, seed: seed);
      if (spots.map((s) => s.dy.round()).toSet().length == 1) straight++;
    }
    expect(straight, 0);
  });

  testWidgets('legacy overlap check', (tester) async {
    for (var seed = 0; seed < 5; seed++) {
      final spots = await positions(tester, count: 5, seed: seed);
      for (var i = 0; i < spots.length; i++) {
        for (var j = i + 1; j < spots.length; j++) {
          expect(
            (spots[i] - spots[j]).distance,
            greaterThan(30),
            reason: 'seed $seed',
          );
        }
      }
    }
  });

  testWidgets('a row is a row', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PictureGroup(
              count: 4,
              picture: '🐝',
              arrangement: PictureArrangement.row,
            ),
          ),
        ),
      ),
    );
    final tops = find
        .text('🐝')
        .evaluate()
        .map((e) => (e.renderObject! as RenderBox).localToGlobal(Offset.zero).dy)
        .toSet();
    expect(tops, hasLength(1));
  });
}
