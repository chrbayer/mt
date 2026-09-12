import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Font files to borrow from the machine the tests run on, in order.
const _candidates = [
  '/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf',
  '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  '/usr/share/fonts/google-noto-vf/NotoSans[wght].ttf',
  '/usr/share/fonts/liberation-sans-fonts/LiberationSans-Regular.ttf',
  '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
];

/// The families Flutter falls back through, so whichever one the theme ends
/// up asking for gets the real file.
const _families = ['Roboto', '.SF UI Text', '.SF UI Display', 'sans-serif'];

/// Loads a real font for the test, and says whether it found one.
///
/// **Why this matters.** Flutter's own test font is square: every glyph is
/// exactly as wide as the point size. A real one is roughly half that. Any
/// test that measures how wide a string is - whether a time fits beside six
/// symbols, at what width an app bar runs out of room - is therefore off by
/// about a factor of two without this, and in the direction that invents
/// problems. It cost a wrong bug report once: the header was said to overflow
/// at 960 dp when on a device it only does below 900.
///
/// The machine may have none of these files. Then the square font stays and
/// the layout tests still guard against overflow - they just cannot be
/// trusted on widths. Callers that measure a width should say so rather than
/// assert into the dark; [loadRealFont] returning false is how they find out.
Future<bool> loadRealFont() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final path in _candidates) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    for (final family in _families) {
      await (FontLoader(family)
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
    }
    return true;
  }
  return false;
}
