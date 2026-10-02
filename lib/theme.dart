import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models/todo.dart';

/// Colour sets for the letters in the jar; weekdays is the original.
enum JarStyle { weekdays, sunset, ocean, mono }

/// Visual tokens. The jar of coloured letters is the one loud element,
/// so everything else stays in quiet ink-on-glass tones.
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.glass,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.hairline,
    required this.strata,
  });

  final Color glass; // page background
  final Color surface; // sheets
  final Color ink; // open task text
  final Color inkSoft; // secondary text
  final Color hairline; // dividers, jar outline

  /// One mineral colour per weekday, Monday first. Letters of tasks finished
  /// on that day settle as a layer of this colour.
  final List<Color> strata;

  Color strataFor(DateTime day) => strata[day.weekday - 1];

  static const light = Palette(
    glass: Color(0xFFE8EDF0),
    surface: Color(0xFFF5F7F8),
    ink: Color(0xFF1E2B36),
    inkSoft: Color(0xFF5E6C77),
    hairline: Color(0xFFC6D0D6),
    strata: [
      Color(0xFF4F6D9A), // Mon  slate
      Color(0xFF5E7F45), // Tue  moss
      Color(0xFFC38B2E), // Wed  ochre
      Color(0xFFB04A32), // Thu  rust
      Color(0xFF7B4B7F), // Fri  plum
      Color(0xFF2F8A84), // Sat  verdigris
      Color(0xFF6B6157), // Sun  umber
    ],
  );

  static const dark = Palette(
    glass: Color(0xFF16202A),
    surface: Color(0xFF1E2A35),
    ink: Color(0xFFE2E8EC),
    inkSoft: Color(0xFF93A1AB),
    hairline: Color(0xFF34434F),
    strata: [
      Color(0xFF8BA7D4),
      Color(0xFF9DBE7F),
      Color(0xFFE2B45E),
      Color(0xFFE07F63),
      Color(0xFFB98ABD),
      Color(0xFF6CC3BC),
      Color(0xFFB3A698),
    ],
  );

  static const _styles = {
    JarStyle.sunset: (
      light: [0xFFB5543C, 0xFFC66B3D, 0xFFD08A3A, 0xFFB98F2C, 0xFFA8573F, 0xFF8E4A5A, 0xFF6E3F63],
      dark: [0xFFE88B6F, 0xFFEFA06B, 0xFFF0BC6A, 0xFFE2C36A, 0xFFD98A73, 0xFFC7859A, 0xFFB08AB0],
    ),
    JarStyle.ocean: (
      light: [0xFF1F5F8B, 0xFF2A7AA0, 0xFF2F8FA0, 0xFF2F8A7E, 0xFF2F7466, 0xFF3F6B8F, 0xFF4F5C8A],
      dark: [0xFF6FA8D6, 0xFF6EC0E0, 0xFF6CCFD9, 0xFF6CCBB8, 0xFF79C2A8, 0xFF8DAED4, 0xFF9BA6D6],
    ),
    JarStyle.mono: (
      light: [0xFF2E3A45, 0xFF3B4752, 0xFF48545F, 0xFF55616C, 0xFF626E79, 0xFF6F7B86, 0xFF7C8893],
      dark: [0xFFE2E8EC, 0xFFD3DAE0, 0xFFC4CDD4, 0xFFB5BFC7, 0xFFA6B1BA, 0xFF97A3AD, 0xFF8995A0],
    ),
  };

  static Palette forStyle(Brightness brightness, JarStyle style) {
    final dark = brightness == Brightness.dark;
    final base = dark ? Palette.dark : Palette.light;
    final colors = _styles[style];
    if (colors == null) return base;
    return base.copyWith(strata: [for (final c in dark ? colors.dark : colors.light) Color(c)]);
  }

  static Palette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<Palette>() ??
        (theme.brightness == Brightness.dark ? Palette.dark : Palette.light);
  }

  @override
  Palette copyWith({List<Color>? strata}) => Palette(
        glass: glass,
        surface: surface,
        ink: ink,
        inkSoft: inkSoft,
        hairline: hairline,
        strata: strata ?? this.strata,
      );

  @override
  Palette lerp(Palette? other, double t) => t < 0.5 || other == null ? this : other;
}

String formatDay(DateTime d) => s.formatDay(d);

/// "Due today", "Overdue 2 days", "Due Fri, 3 Oct".
String dueLabel(int days, DateTime due) => switch (days) {
      0 => s.dueToday,
      1 => s.dueTomorrow,
      < 0 => s.overdue(-days),
      _ => s.due(formatDay(due)),
    };

const kFontFamily = 'Bricolage';
const kFontFallback = ['HindSiliguri'];
const kTaskFontSize = 17.0;

/// Heavier tasks are drawn heavier: the font weight matches the physical
/// mass their letters get in the jar.
double weightAxisFor(Priority priority) => switch (priority) {
      Priority.low => 380.0,
      Priority.normal => 500.0,
      Priority.high => 760.0,
    };

FontWeight fontWeightFor(Priority priority) => switch (priority) {
      Priority.low => FontWeight.w400,
      Priority.normal => FontWeight.w500,
      Priority.high => FontWeight.w800,
    };

/// The bundled typeface is variable, so weight is set through the `wght`
/// axis. [TextStyle.fontWeight] is set too so fallback fonts (e.g. Bangla)
/// follow along.
TextStyle taskTextStyle({
  required Color color,
  required Priority priority,
}) {
  return TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: kTaskFontSize,
    height: 1.25,
    color: color,
    fontWeight: fontWeightFor(priority),
    fontVariations: [FontVariation('wght', weightAxisFor(priority))],
  );
}

ThemeData buildTheme(Brightness brightness, [JarStyle style = JarStyle.weekdays]) {
  final p = Palette.forStyle(brightness, style);
  final scheme = ColorScheme.fromSeed(
    seedColor: p.ink,
    brightness: brightness,
    surface: p.surface,
  ).copyWith(primary: p.ink, onPrimary: p.glass);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.glass,
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    dividerColor: p.hairline,
    extensions: [p],
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle:
          TextStyle(fontFamily: kFontFamily, fontFamilyFallback: kFontFallback, color: p.glass),
      actionTextColor: p.glass,
    ),
  );
}
