import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/task_count.dart';

/// Three levels, most specific wins.
void main() {
  test('a choice made for the lesson beats everything else', () {
    expect(
      resolveTaskCount(forLesson: 50, forProfile: 20, global: 10),
      50,
    );
  });

  test('without one, the profile decides', () {
    expect(resolveTaskCount(forProfile: 20, global: 10), 20);
  });

  test('without either, the app-wide default applies', () {
    expect(resolveTaskCount(global: 10), 10);
    expect(resolveTaskCount(forLesson: null, forProfile: null, global: 30), 30);
  });

  test('the fallback is ten', () {
    expect(fallbackTaskCount, 10);
  });
}
