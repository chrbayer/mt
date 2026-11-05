import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps the app's database out of Android's automatic backup.
///
/// Without `android:allowBackup="false"` Android's default applies, and the
/// SQLite file - profile names, results, the salted PIN hash - goes into the
/// system backup and, with Google backup turned on, into the device's Google
/// account. That contradicts DATENSCHUTZ.md ("nichts verlässt das Gerät").
/// Reported by a volunteer reviewer as GitHub issue #1; fixed in 2.15.2.
void main() {
  test('the manifest opts out of Android auto backup', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final application =
        RegExp(r'<application\b[^>]*>', dotAll: true).firstMatch(manifest);
    expect(application, isNotNull);
    expect(application!.group(0), contains('android:allowBackup="false"'));
  });
}
