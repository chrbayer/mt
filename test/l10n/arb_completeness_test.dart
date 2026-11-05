import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// gen-l10n only warns about a missing translation and falls back to the
/// template at run time - a child would meet German in the English app. This
/// fails first. Every language file must have exactly the messages of the
/// template, with the same placeholders in each.
void main() {
  Map<String, dynamic> load(File f) =>
      jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;

  final template = load(File('lib/l10n/app_de.arb'));
  Set<String> messages(Map<String, dynamic> arb) => arb.keys
      .where((k) => !k.startsWith('@')) // also leaves out @@locale
      .toSet();

  /// The index of the brace that closes the one at [open].
  int closing(String s, int open) {
    var depth = 0;
    for (var i = open; i < s.length; i++) {
      if (s[i] == '{') depth++;
      if (s[i] == '}' && --depth == 0) return i;
    }
    throw FormatException('unbalanced braces', s);
  }

  /// The arguments of a message: plain `{name}` and the variable of every
  /// `{name, plural, ...}` or `{name, select, ...}`. The texts inside the
  /// branches of those are messages again and are searched the same way;
  /// their labels (`=1`, `other`, `daily`) are not arguments.
  Set<String> arguments(String message) {
    final found = <String>{};
    var i = message.indexOf('{');
    while (i >= 0) {
      final end = closing(message, i);
      final inner = message.substring(i + 1, end);
      final head = RegExp(r'^\s*(\w+)\s*(?:,\s*(?:plural|select)\s*,)?')
          .firstMatch(inner)!;
      found.add(head.group(1)!);
      var rest = inner.substring(head.end);
      for (var open = rest.indexOf('{'); open >= 0; open = rest.indexOf('{')) {
        final close = closing(rest, open);
        found.addAll(arguments(rest.substring(open + 1, close)));
        rest = rest.substring(close + 1);
      }
      i = message.indexOf('{', end);
    }
    return found;
  }

  final languages = Directory('lib/l10n')
      .listSync()
      .whereType<File>()
      .where((f) => RegExp(r'app_\w+\.arb$').hasMatch(f.path))
      .where((f) => !f.path.endsWith('app_de.arb'))
      .toList();

  test('there is a translation next to the template', () {
    expect(languages, isNotEmpty);
  });

  test('the argument finder understands plural and select', () {
    expect(arguments('{a} of {b}'), {'a', 'b'});
    expect(
      arguments(
        '{n, plural, =1{1 day} other{{n} days}} '
        '{p, select, a{x} other{y}}',
      ),
      {'n', 'p'},
    );
    expect(arguments('no arguments'), isEmpty);
  });

  for (final file in languages) {
    final code = file.path.split('app_').last.replaceAll('.arb', '');
    group('app_$code.arb', () {
      final arb = load(file);

      test('declares its locale', () {
        expect(arb['@@locale'], code);
      });

      test('has exactly the messages of the template', () {
        final want = messages(template);
        final have = messages(arb);
        expect(want.difference(have), isEmpty, reason: 'missing in $code');
        expect(have.difference(want), isEmpty, reason: 'unknown in $code');
      });

      test('uses the same placeholders in every message', () {
        for (final key in messages(template)) {
          expect(
            arguments(arb[key] as String? ?? ''),
            arguments(template[key] as String),
            reason: '$key in $code',
          );
        }
      });

      test('has no empty text', () {
        for (final key in messages(arb)) {
          expect((arb[key] as String).trim(), isNotEmpty, reason: key);
        }
      });
    });
  }
}
