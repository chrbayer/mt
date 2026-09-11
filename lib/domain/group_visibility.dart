/// Which lesson groups a child is offered. No Flutter dependency.
library;

import 'lesson.dart';

/// Works out the groups a child sees from the two things that are stored:
/// which groups a parent switched **off**, and which groups that decision
/// had in front of it at the time.
///
/// A group the decision has seen is simply on unless it was switched off.
/// A group it has **not** seen is new - the app has gained it in an update
/// since a parent last looked - and then it is only switched on if it
/// **borders** a group this child already has.
///
/// The enum runs from the first steps up to a thousand and on through the
/// times tables, so neighbours are neighbours in difficulty too. A child who
/// is working in "Bis 20" should be offered "Bis 100" when it appears; the
/// same child should not silently be handed "Einmaleins rückwärts" because
/// the catalogue grew somewhere far above them.
///
/// Bordering is measured against the **known** groups only, never against
/// another new one. Two groups added at once would otherwise let the first
/// one drag the second in behind it, and a chain like that reaches places
/// nobody chose.
///
/// An empty [known] means every group is known. That is the reading a
/// profile written before this rule existed needs - and the only safe one,
/// since the alternative would hide the entire catalogue from a child whose
/// backup simply predates the column.
List<LessonGroup> visibleGroups({
  required Set<LessonGroup> hidden,
  required Set<LessonGroup> known,
}) {
  final seen = known.isEmpty ? LessonGroup.values.toSet() : known;
  final onAlready = {
    for (final group in seen)
      if (!hidden.contains(group)) group,
  };

  bool bordersSomethingOn(LessonGroup group) => onAlready.any(
      (other) => (other.index - group.index).abs() == 1);

  return [
    for (final group in LessonGroup.values)
      if (seen.contains(group)
          ? !hidden.contains(group)
          : bordersSomethingOn(group))
        group,
  ];
}

/// Reads a stored comma-separated list of group names.
///
/// Names this version no longer has are skipped rather than rejected, the
/// same caution [LessonGroup] names get everywhere: a downgrade must not
/// destroy the setting.
Set<LessonGroup> groupsByName(String names) => {
      for (final name in names.split(','))
        for (final group in LessonGroup.values)
          if (group.name == name) group,
    };

/// Writes a set back, always in enum order so the stored string is stable
/// and two equal settings compare equal.
String groupNames(Set<LessonGroup> groups) =>
    LessonGroup.values.where(groups.contains).map((g) => g.name).join(',');

/// Every group this version has, for the moment a decision is written down:
/// whatever a parent has just looked at, they have seen all of it.
String get allGroupNames => groupNames(LessonGroup.values.toSet());
