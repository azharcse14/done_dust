import 'package:flutter/material.dart';

import '../l10n.dart';
import '../state/todo_store.dart';
import '../theme.dart';

/// Every setting on one sheet, so nothing hides behind a tap-to-cycle menu row.
Future<void> showSettingsSheet(BuildContext context, TodoStore store) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Palette.of(context).surface,
    // Rebuilds live, so a language switch shows at once.
    builder: (context) => ListenableBuilder(
      listenable: store,
      builder: (context, _) => _Settings(store: store),
    ),
  );
}

class _Settings extends StatelessWidget {
  const _Settings({required this.store});

  final TodoStore store;

  static const _goals = [0, 1, 3, 5, 10];

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    Widget label(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Text(text, style: TextStyle(color: palette.inkSoft, fontSize: 13)),
        );
    Widget choice<T>(Map<T, String> options, T selected, ValueChanged<T> onChanged) => SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            showSelectedIcon: false,
            segments: [
              for (final MapEntry(:key, :value) in options.entries)
                ButtonSegment(value: key, label: Text(value, maxLines: 1)),
            ],
            selected: {selected},
            onSelectionChanged: (v) => onChanged(v.first),
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.settings,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontVariations: const [FontVariation('wght', 700)],
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              secondary: const Icon(Icons.volume_up_rounded),
              title: Text(s.sound),
              subtitle: Text(s.soundHint),
              value: store.soundOn,
              onChanged: store.setSound,
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              secondary: const Icon(Icons.vibration_rounded),
              title: Text(s.vibration),
              subtitle: Text(s.vibrationHint),
              value: store.hapticsOn,
              onChanged: store.setHaptics,
            ),
            label('${s.dailyGoal} · ${s.dailyGoalHint}'),
            choice({for (final g in _goals) g: g == 0 ? s.off : s.n(g)}, store.dailyGoal,
                store.setDailyGoal),
            label(s.theme),
            choice({
              ThemeMode.system: s.themeSystem,
              ThemeMode.light: s.themeLight,
              ThemeMode.dark: s.themeDark,
            }, store.themeMode, store.setThemeMode),
            label(s.language),
            choice({'system': s.themeSystem, 'en': 'English', 'bn': 'বাংলা'}, store.language,
                store.setLanguage),
          ],
        ),
      ),
    );
  }
}
