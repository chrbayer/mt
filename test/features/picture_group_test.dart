import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/practice/widgets/picture_group.dart';

import '../support/real_font.dart';

/// The scatter has to hold still. Pictures that move while a child counts
/// them would make the lesson impossible.
void main() {
  // Real glyph metrics: the test font is square, and the overflow this file
  // guards against only happens with a font whose glyphs are taller than
  // their point size - which every real one is.
  setUpAll(loadRealFont);

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

  testWidgets('nothing is cut off at the edge of a cloud', (tester) async {
    // The bottom row used to poke out of the Stack, which clips - the last
    // pictures were sliced off although the screen had room to spare.
    for (var count = 1; count <= 5; count++) {
      for (var seed = 0; seed < 20; seed++) {
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

        final group = tester.getRect(find.byType(PictureGroup));
        for (final element in find.text('🐝').evaluate()) {
          final box = element.renderObject! as RenderBox;
          final rect = box.localToGlobal(Offset.zero) & box.size;
          expect(group.contains(rect.topLeft), isTrue,
              reason: '$count Bilder, seed $seed');
          expect(
            group.contains(rect.bottomRight - const Offset(0.01, 0.01)),
            isTrue,
            reason: '$count Bilder, seed $seed',
          );
        }
      }
    }
  });

  testWidgets('a heap draws no number of its own', (tester) async {
    // The count moved to CountedPair, so that two heaps can share one line
    // of numbers instead of hanging them at two different heights.
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
    await tester.pump();
    expect(find.text('4'), findsNothing);
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
