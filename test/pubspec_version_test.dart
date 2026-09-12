import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps the two halves of `version:` in step.
///
/// The build scripts used to work the versionCode out from the version alone,
/// and nothing but the scripts ever knew it. F-Droid reads it out of
/// `pubspec.yaml` instead - that is how it tells whether a new tag is a newer
/// version - so the number has to stand there, and now it can drift from the
/// name beside it. Two builds claiming the same code are not an upgrade to
/// Android's package manager, and one installed over the other can leave the
/// app unable to start; that has happened once already.
void main() {
  test('the versionCode follows the version', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    final match =
        RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$').firstMatch(line);
    expect(match, isNotNull,
        reason: 'erwartet "version: X.Y.Z+N", gelesen "$line"');

    final [major, minor, patch, code] =
        [for (var i = 1; i <= 4; i++) int.parse(match!.group(i)!)];
    expect(code, major * 10000 + minor * 100 + patch,
        reason: 'der versionCode gehört zur Version: '
            '$major.$minor.$patch heißt ${major * 10000 + minor * 100 + patch}');
  });
}
