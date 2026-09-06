import 'package:flutter/material.dart';

/// Colours and type scale for a distraction-free, large-format tablet UI.
///
/// The app deliberately ships one calm light theme: children use it in
/// daylight at school or at the kitchen table, and a switchable theme is one
/// more thing to fiddle with instead of practising.
abstract final class AppColors {
  static const background = Color(0xFFF7F6F1);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF2D6CDF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const text = Color(0xFF1D2330);
  static const textMuted = Color(0xFF6B7280);
  static const correct = Color(0xFF1E9E5A);
  static const correctSoft = Color(0xFFDFF3E7);
  static const wrong = Color(0xFFD64545);
  static const wrongSoft = Color(0xFFFBE3E3);
  static const divider = Color(0xFFE3E1DA);

  /// For the "verliebte Zahlen" lesson, where a heart stands in for the
  /// operator that first-graders cannot read yet.
  static const heart = Color(0xFFE5559B);

  /// Palette a child picks from when creating a profile.
  static const profile = <Color>[
    Color(0xFF2D6CDF),
    Color(0xFFE2761B),
    Color(0xFF1E9E5A),
    Color(0xFF9B51E0),
    Color(0xFFD64545),
    Color(0xFF0F9BA8),
    Color(0xFFE0A800),
    Color(0xFFE5559B),
  ];

  static Color profileColor(int index) => profile[index % profile.length];

  /// Warm accent for the practice streak - the one place the app cheers.
  static const profile1 = Color(0xFFE2761B);

  /// Earned and unearned stars. The empty one stays visible rather than
  /// vanishing: it is what tells a child there is something left to do.
  static const star = Color(0xFFE0A800);
  static const starEmpty = Color(0xFFD8D4C6);
}

/// Emoji a child can pick as an avatar. Emoji instead of images keeps the app
/// asset-free and instantly recognisable for non-readers.
const avatarChoices = <String>[
  '🦊', '🐼', '🐧', '🦁', '🐢', '🐳', '🦉', '🐝',
  '🦄', '🐙', '🦖', '🐨', '🦔', '🐬', '🦋', '🐸',
];

ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.correct,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.wrong,
    onError: Colors.white,
  );

  // Tabular figures keep digits from jumping around while a child types.
  const tabular = [FontFeature.tabularFigures()];

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.divider,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 108,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
        fontFeatures: tabular,
      ),
      displayMedium: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
        fontFeatures: tabular,
      ),
      headlineLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(fontSize: 20, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 17, color: AppColors.textMuted),
    ),
    // Selected chips in the app's blue: green is reserved for "correct".
    chipTheme: ChipThemeData(
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.text),
      secondaryLabelStyle: const TextStyle(color: AppColors.onPrimary),
      checkmarkColor: AppColors.onPrimary,
      side: const BorderSide(color: AppColors.divider, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      iconTheme: IconThemeData(color: AppColors.text, size: 32),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 68),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 68),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
  );
}
