import 'package:flutter/material.dart';

import 'quiz_palette.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(QuizPalette.light, Brightness.light);
  static ThemeData get dark => _build(QuizPalette.dark, Brightness.dark);

  static ThemeData _build(QuizPalette palette, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
    ).copyWith(
      primary: palette.accent,
      secondary: palette.brand,
      error: palette.danger,
      surface: palette.card,
      onSurface: palette.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      dividerColor: palette.line,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (states) => IconThemeData(
            size: 26,
            color: states.contains(WidgetState.selected)
                ? palette.accent
                : palette.navIdle,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF30343E)
            : const Color(0xFF33234C),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
