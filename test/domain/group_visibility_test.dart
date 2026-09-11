import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/group_visibility.dart';
import 'package:mathe_trainer/domain/lesson.dart';

/// A group added in a later version must not simply turn up everywhere: a
/// child working in "Bis 20" has no business being handed "Einmaleins
/// rückwärts" because the catalogue grew somewhere above them.
void main() {
  /// Every group except the ones named - the shape "this profile's setting
  /// has seen everything but these" takes, which is what makes them new.
  Set<LessonGroup> allBut(List<LessonGroup> newOnes) =>
      LessonGroup.values.toSet()..removeAll(newOnes);

  group('groups the setting has seen', () {
    test('are shown unless they were switched off', () {
      final visible = visibleGroups(
        hidden: {LessonGroup.upTo1000},
        known: LessonGroup.values.toSet(),
      );
      expect(visible, isNot(contains(LessonGroup.upTo1000)));
      expect(visible, contains(LessonGroup.upTo100));
      expect(visible, hasLength(LessonGroup.values.length - 1));
    });
  });

  group('a group the setting has never seen', () {
    test('comes along when it borders one the child already has', () {
      // Up to 1000 is on, and the times tables sit right next to it.
      final visible = visibleGroups(
        hidden: const {},
        known: allBut([LessonGroup.timesTables]),
      );
      expect(visible, contains(LessonGroup.timesTables));
    });

    test('stays away when both its neighbours are switched off', () {
      final visible = visibleGroups(
        hidden: {LessonGroup.upTo1000, LessonGroup.reverseTimesTables},
        known: allBut([LessonGroup.timesTables]),
      );
      expect(visible, isNot(contains(LessonGroup.timesTables)));
      // And it really is only that one group that is missing.
      expect(visible, contains(LessonGroup.upTo100));
      expect(visible, contains(LessonGroup.timesAndDivision));
    });

    test('at the very front has only the one neighbour to go by', () {
      expect(
        visibleGroups(
          hidden: {LessonGroup.upTo10},
          known: allBut([LessonGroup.firstSteps]),
        ),
        isNot(contains(LessonGroup.firstSteps)),
      );
      expect(
        visibleGroups(
          hidden: const {},
          known: allBut([LessonGroup.firstSteps]),
        ),
        contains(LessonGroup.firstSteps),
      );
    });

    test('does not ride in behind another new one', () {
      // Two groups arrive at once. The later one borders something the child
      // has and comes along; the earlier one borders only its hidden
      // neighbour and its brand-new one, and stays away.
      final visible = visibleGroups(
        hidden: {LessonGroup.upTo1000},
        known: allBut([LessonGroup.timesTables, LessonGroup.reverseTimesTables]),
      );
      expect(visible, contains(LessonGroup.reverseTimesTables));
      expect(visible, isNot(contains(LessonGroup.timesTables)));
    });
  });

  test('a setting from before the rule existed knows everything', () {
    // Empty is what a profile written before the column says. Read as "no
    // group is known" it would hide the whole catalogue from that child.
    expect(
      visibleGroups(hidden: const {}, known: const {}),
      LessonGroup.values,
    );
    expect(
      visibleGroups(hidden: {LessonGroup.upTo20}, known: const {}),
      LessonGroup.values.where((g) => g != LessonGroup.upTo20),
    );
  });

  test('names survive a round trip, and an unknown one is skipped', () {
    const some = {LessonGroup.upTo20, LessonGroup.everyday};
    expect(groupsByName(groupNames(some)), some);
    // A name from a newer version, read by an older one.
    expect(groupsByName('upTo20,bruchrechnen'), {LessonGroup.upTo20});
    expect(groupsByName(''), isEmpty);
  });

  test('the written order is the catalogue order, whatever went in', () {
    expect(
      groupNames({LessonGroup.everyday, LessonGroup.firstSteps}),
      'firstSteps,everyday',
    );
  });
}
