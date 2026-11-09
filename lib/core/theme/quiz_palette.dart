import 'package:flutter/material.dart';

@immutable
class QuizPalette {
  const QuizPalette._({
    required this.background,
    required this.card,
    required this.field,
    required this.textPrimary,
    required this.textMuted,
    required this.brand,
    required this.accent,
    required this.success,
    required this.danger,
    required this.warning,
    required this.skip,
    required this.track,
    required this.line,
    required this.navIdle,
  });

  final Color background;
  final Color card;
  final Color field;
  final Color textPrimary;
  final Color textMuted;
  final Color brand;
  final Color accent;
  final Color success;
  final Color danger;
  final Color warning;
  final Color skip;
  final Color track;
  final Color line;
  final Color navIdle;

  static const light = QuizPalette._(
    background: Colors.white,
    card: Colors.white,
    field: Color(0xFFF5F3F8),
    textPrimary: Color(0xFF24152B),
    textMuted: Color(0xFF827B87),
    brand: Color(0xFF6875F5),
    accent: Color(0xFFC44CF2),
    success: Color(0xFF42D9A5),
    danger: Color(0xFFFF4B50),
    warning: Color(0xFFFFB547),
    skip: Color(0xFFFF5F83),
    track: Color(0xFFE9E7EB),
    line: Color(0xFFF0F0F0),
    navIdle: Color(0xFFD4CFD9),
  );

  static const dark = QuizPalette._(
    background: Color(0xFF17191F),
    card: Color(0xFF20232B),
    field: Color(0xFF252831),
    textPrimary: Color(0xFFE5E3EA),
    textMuted: Color(0xFFA8AAB7),
    brand: Color(0xFF8490C8),
    accent: Color(0xFFC298DF),
    success: Color(0xFF79C6A4),
    danger: Color(0xFFE58C91),
    warning: Color(0xFFD8B174),
    skip: Color(0xFFD68DA8),
    track: Color(0xFF3B3E48),
    line: Color(0xFF353841),
    navIdle: Color(0xFF777985),
  );

  static QuizPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension QuizPaletteContext on BuildContext {
  QuizPalette get palette => QuizPalette.of(this);
}
