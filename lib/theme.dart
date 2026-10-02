import 'package:flutter/material.dart';

import 'models/todo.dart';

/// Visual tokens. The jar of coloured letters is the one loud element,
/// so everything else stays in quiet ink-on-glass tones.
class Palette {
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

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatDay(DateTime d) => '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

/// "Due today", "Overdue 2 days", "Due Fri, 3 Oct".
String dueLabel(int days, DateTime due) => switch (days) {
      0 => 'Due today',
      1 => 'Due tomorrow',
      -1 => 'Overdue 1 day',
      < 0 => 'Overdue ${-days} days',
      _ => 'Due ${formatDay(due)}',
    };

const kFontFamily = 'Bricolage';
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
    fontSize: kTaskFontSize,
    height: 1.25,
    color: color,
    fontWeight: fontWeightFor(priority),
    fontVariations: [FontVariation('wght', weightAxisFor(priority))],
  );
}

ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;
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
    dividerColor: p.hairline,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(fontFamily: kFontFamily, color: p.glass),
      actionTextColor: p.glass,
    ),
  );
}
