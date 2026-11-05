import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The ARB template is what a translator gets. A message with placeholders
/// says nothing about what goes into them unless it carries a description.
void main() {
  final arb = jsonDecode(File('lib/l10n/app_de.arb').readAsStringSync())
      as Map<String, dynamic>;

  test('every message with placeholders explains itself to a translator', () {
    for (final entry in arb.entries) {
      if (!entry.key.startsWith('@') || entry.key == '@@locale') continue;
      final meta = entry.value as Map<String, dynamic>;
      if (!meta.containsKey('placeholders')) continue;
      expect(meta['description'], isA<String>(),
          reason: '${entry.key} has placeholders but no description');
    }
  });

  test('every key of the template has a message', () {
    for (final key in arb.keys) {
      if (key.startsWith('@')) {
        expect(arb.containsKey(key.substring(1)) || key == '@@locale', isTrue,
            reason: key);
      }
    }
  });
}
