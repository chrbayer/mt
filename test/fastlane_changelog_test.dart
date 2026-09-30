import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps the "Was ist neu" text where F-Droid will actually find it.
///
/// fdroidserver attaches `changelogs/<n>.txt` only when `n` is one of the
/// versionCodes it publishes - and for this app those are the per-ABI codes,
/// `10 * versionCode + 1/2/3`, not the one in `pubspec.yaml`. The files were
/// named after the latter for every release up to 2.15.1, so F-Droid showed
/// no changelog for any of them. A reviewer found it, not a test.
///
/// Checked here and not only in `build_android.sh`: the script runs after the
/// tag, and F-Droid reads the files from the tagged commit, so by then a
/// missing file can only be fixed by moving a tag that is already public.
void main() {
  test('every release has its changelog under all three ABI codes', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    final code = RegExp(r'\+(\d+)\s*$').firstMatch(line)!.group(1)!;

    for (final lang in ['de-DE', 'en-US']) {
      final texts = [
        for (final abi in [1, 2, 3])
          File('fastlane/metadata/android/$lang/changelogs/$code$abi.txt'),
      ];
      for (final file in texts) {
        expect(file.existsSync(), isTrue,
            reason: '${file.path} fehlt (siehe RELEASE.md, Schritt 2)');
      }
      final first = texts.first.readAsStringSync();
      // One text per version, three names for it - an APK must not say
      // something different depending on the processor it was built for.
      for (final file in texts.skip(1)) {
        expect(file.readAsStringSync(), first,
            reason: '${file.path} weicht von ${texts.first.path} ab');
      }
      // F-Droid's limit for "Was ist neu".
      expect(first.length, lessThanOrEqualTo(500),
          reason: '${texts.first.path} hat ${first.length} Zeichen');
    }
  });
}
