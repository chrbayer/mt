import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Relative luminance, WCAG 2.1.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

/// Contrast between two colours, 1 (none) to 21 (black on white).
double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

/// The pastel tile backgrounds have to be pretty *and* legible. Picking them
/// by eye is how a label ends up at 4.0:1, so the numbers are checked here.
void main() {
  test('there is one tint and one edge for every group', () {
    expect(AppColors.groupTints, hasLength(LessonGroup.values.length));
    expect(AppColors.groupEdges, hasLength(LessonGroup.values.length));
  });

  test('the sanity of the contrast helper itself', () {
    expect(contrast(Colors.black, Colors.white), closeTo(21, 0.1));
    expect(contrast(Colors.white, Colors.white), closeTo(1, 0.01));
  });

  test('every tint carries the small grey label at 4.5:1', () {
    // The tightest of them all: "noch nicht geübt" is ordinary-size text, so
    // it needs the full AA ratio rather than the 3:1 large text may have.
    for (final group in LessonGroup.values) {
      final tint = AppColors.groupTint(group.index);
      expect(
        contrast(AppColors.textMuted, tint),
        greaterThanOrEqualTo(4.5),
        reason: '${groupTitle(group)} / textMuted',
      );
    }
  });

  test('and the lesson title with room to spare', () {
    for (final group in LessonGroup.values) {
      expect(
        contrast(AppColors.text, AppColors.groupTint(group.index)),
        greaterThanOrEqualTo(7),
        reason: groupTitle(group),
      );
    }
  });

  test('the blue example stays legible - it is large, so 3:1 is the bar', () {
    for (final group in LessonGroup.values) {
      expect(
        contrast(AppColors.primary, AppColors.groupTint(group.index)),
        greaterThanOrEqualTo(3),
        reason: groupTitle(group),
      );
    }
  });

  test('the border is visible against its own fill, and darker than it', () {
    for (final group in LessonGroup.values) {
      final tint = AppColors.groupTint(group.index);
      final edge = AppColors.groupEdge(group.index);
      expect(_luminance(edge), lessThan(_luminance(tint)),
          reason: groupTitle(group));
      expect(contrast(edge, tint), greaterThanOrEqualTo(1.2),
          reason: '${groupTitle(group)}: an edge nobody sees is no edge');
    }
  });

  test('neighbouring groups are told apart, not just technically different',
      () {
    // Two groups meet on screen, so the seam has to be visible. A ratio of
    // one would be the same colour; this asks for a real step.
    for (var i = 1; i < LessonGroup.values.length; i++) {
      final before = AppColors.groupTint(i - 1);
      final after = AppColors.groupTint(i);
      expect(before, isNot(after));
      expect(
        (_luminance(before) - _luminance(after)).abs() +
            ((before.r - after.r).abs() +
                (before.g - after.g).abs() +
                (before.b - after.b).abs()),
        greaterThan(0.05),
        reason: 'zwischen ${groupTitle(LessonGroup.values[i - 1])} '
            'und ${groupTitle(LessonGroup.values[i])}',
      );
    }
  });

  test('the muted grey still works on the plain surfaces it came from', () {
    // It was darkened for the tiles; it must not have got worse anywhere.
    for (final background in [AppColors.surface, AppColors.background]) {
      expect(contrast(AppColors.textMuted, background),
          greaterThanOrEqualTo(4.5));
    }
  });
}
