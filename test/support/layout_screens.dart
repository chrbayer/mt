import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/admin/admin_screen.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/features/leaderboard/leaderboard_screen.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/profiles/profile_select_screen.dart';
import 'package:mathe_trainer/features/result/result_screen.dart';
import 'package:mathe_trainer/features/settings/settings_screen.dart';
import 'package:mathe_trainer/features/stats/global_stats_screen.dart';
import 'package:mathe_trainer/features/stats/stats_screen.dart';
import 'package:mathe_trainer/providers.dart';

/// What the layout tests of every language have in common: three profiles
/// with some history, and the list of screens that are rendered at each size.

/// Three children, the first (Mia) signed in, with four finished rounds so
/// the statistics and leaderboards have something to show. Returns Mia.
Future<User> seedLayoutData(ProviderContainer container) async {
  final users = container.read(userRepositoryProvider);
  final miaId = await users.createUser(
    name: 'Mia',
    avatar: '🦊',
    colorIndex: 0,
  );
  await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
  await users.createUser(name: 'Jonas', avatar: '🦖', colorIndex: 2);
  final mia = (await users.findUser(miaId))!;
  container.read(activeUserProvider.notifier).select(mia);

  // Some history so statistics and leaderboards have something to show.
  final sessions = container.read(sessionRepositoryProvider);
  for (final (index, ms) in [7200, 6100, 5400, 4800].indexed) {
    final id = await sessions.startSession(
      userId: mia.id,
      lessonId: 'add_100_carry',
      taskCount: 10,
      seed: index,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: true,
      results: [
        for (var i = 0; i < 10; i++)
          TaskResult(
            task: Task(
              a: 47 + i,
              b: 38,
              op: Operation.add,
              form: TaskForm.result,
            ),
            elapsedMs: ms + i * 120,
            wrongAttempts: i == 3 ? 1 : 0,
          ),
      ],
    );
  }
  return mia;
}

/// Every screen that is laid out at each tablet size.
Map<String, Widget Function()> layoutScreens() => <String, Widget Function()>{
  '01-profile-auswahl': () => const ProfileSelectScreen(),
  '02-lektionen': () => const LessonHomeScreen(),
  '03-uebung': () =>
      PracticeScreen(lesson: lessonById('add_100_carry'), taskCount: 10),
  // Not written as an equation, so it lays out differently: a question line
  // above, and a heart where the operator would be.
  '03b-verliebte-zahlen': () =>
      PracticeScreen(lesson: lessonById('partners_of_ten'), taskCount: 10),
  // The widest task there is: two answer boxes plus the word "Rest".
  '03c-geteilt-mit-rest': () =>
      PracticeScreen(lesson: lessonById('div_remainder'), taskCount: 10),
  // The tallest task there is: up to four named places, one per line.
  '03d-stellenwerte': () =>
      PracticeScreen(lesson: lessonById('place_value_10000'), taskCount: 10),
  // Pictures to count, dice to read, two heaps to compare, a number line.
  '02a-zaehlen': () =>
      PracticeScreen(lesson: lessonById('count_pictures'), taskCount: 5),
  '02b-wuerfel': () =>
      PracticeScreen(lesson: lessonById('dice_add'), taskCount: 5),
  '02a2-zaehlen-wolke': () =>
      PracticeScreen(lesson: lessonById('count_pictures_cloud'), taskCount: 5),
  '02b3-bienchen-wolke': () =>
      PracticeScreen(lesson: lessonById('bees_add_cloud'), taskCount: 5),
  '02b2-bienchen': () =>
      PracticeScreen(lesson: lessonById('bees_add'), taskCount: 5),
  '02c-vergleichen': () =>
      PracticeScreen(lesson: lessonById('compare_more'), taskCount: 5),
  '02c2-vergleichen-wolke': () =>
      PracticeScreen(lesson: lessonById('compare_more_cloud'), taskCount: 5),
  '03e-uhrzeit-sagen': () =>
      PracticeScreen(lesson: lessonById('clock_words'), taskCount: 5),
  '03f-uhrzeit-24': () =>
      PracticeScreen(lesson: lessonById('clock_24'), taskCount: 5),
  '03g-geld-legen': () =>
      PracticeScreen(lesson: lessonById('money_compose'), taskCount: 5),
  '03h-rueckgeld': () =>
      PracticeScreen(lesson: lessonById('money_change'), taskCount: 5),
  '02d-zahlenreihe': () =>
      PracticeScreen(lesson: lessonById('count_next'), taskCount: 5),
  // A drawn clock next to two boxes.
  '03d-uhrzeit': () =>
      PracticeScreen(lesson: lessonById('clock_five'), taskCount: 10),
  // Two amounts, two boxes and two units.
  '03e-geld': () =>
      PracticeScreen(lesson: lessonById('money_add'), taskCount: 10),
  '04-ergebnis': () => ResultScreen(
    lesson: lessonById('add_100_carry'),
    sessionId: null,
    taskCount: 10,
    totalMs: 48000,
    wrongAttempts: 1,
  ),
  '05-bestenliste': () =>
      LeaderboardScreen(lesson: lessonById('add_100_carry')),
  '06-statistik': () => const StatsScreen(),
  '07-einstellungen': () => const SettingsScreen(),
  '09-alle-ergebnisse': () => const GlobalStatsScreen(),
  '10-elternbereich': () => const AdminScreen(),
};
