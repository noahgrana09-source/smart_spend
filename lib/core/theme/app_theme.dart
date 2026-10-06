import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_text_styles.dart';

/// SmartSpend's theme: grayscale surfaces (light/dark) plus a green brand
/// color for buttons and highlighted elements, as described in
/// `context/CLAUDE.md`.
abstract final class AppTheme {
  /// Brand seed color — a jade green, distinct from Material's stock
  /// green, meant to read as "growth" for a finance app.
  static const Color brandGreen = Color(0xFF0E9F6E);

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: brandGreen,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: brandGreen,
    brightness: Brightness.dark,
  );

  static ThemeData get light => ThemeData(
    colorScheme: _lightScheme,
    textTheme: AppTextStyles.textTheme,
  );

  static ThemeData get dark => ThemeData(
    colorScheme: _darkScheme,
    textTheme: AppTextStyles.textTheme,
  );

  /// Cupertino widgets (iOS branches) ignore the Material [ThemeData] and
  /// fall back to Cupertino's own system blue and background. This mirrors
  /// the active Material theme so buttons and page backgrounds match Android.
  static CupertinoThemeData cupertino(ThemeData theme) => CupertinoThemeData(
    brightness: theme.brightness,
    primaryColor: theme.colorScheme.primary,
    scaffoldBackgroundColor: theme.colorScheme.surface,
  );
}
