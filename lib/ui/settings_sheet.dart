import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n.dart';
import '../services/reminders.dart';
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

class _Settings extends StatefulWidget {
  const _Settings({required this.store});

  final TodoStore store;

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  static const _goals = [0, 1, 3, 5, 10];

  /// Result of the last backup action, shown under its buttons.
  String? _backupStatus;

  TodoStore get store => widget.store;

  Future<void> _copyBackup() async {
    await Clipboard.setData(ClipboardData(text: store.exportBackup()));
    if (mounted) setState(() => _backupStatus = s.backupCopied);
  }

  Future<void> _restore() async {
    final raw = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.restoreQ),
        content: Text(s.restoreBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.keep)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.restore)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _backupStatus = store.importBackup(raw) ? s.restored : s.notABackup);
  }

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
            if (Reminders.supported)
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(s.reminders),
                subtitle: Text(
                  store.remindersBlocked ? s.remindersBlocked : s.remindersHint,
                  style: store.remindersBlocked
                      ? TextStyle(color: Theme.of(context).colorScheme.error)
                      : null,
                ),
                value: store.remindersOn,
                onChanged: store.setReminders,
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
            label('${s.jarStyle} · ${s.jarStyleHint}'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final style in JarStyle.values)
                  ChoiceChip(
                    avatar: _Swatch(Palette.forStyle(Theme.of(context).brightness, style).strata),
                    label: Text(s.jarStyleName(style.index)),
                    selected: store.jarStyle == style,
                    showCheckmark: false,
                    onSelected: (_) => store.setJarStyle(style),
                  ),
              ],
            ),
            label(s.backup),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _copyBackup,
                  icon: const Icon(Icons.content_copy_rounded, size: 18),
                  label: Text(s.copyBackup),
                ),
                OutlinedButton.icon(
                  onPressed: _restore,
                  icon: const Icon(Icons.content_paste_rounded, size: 18),
                  label: Text(s.restoreFromClipboard),
                ),
              ],
            ),
            if (_backupStatus case final status?)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Text(status, style: TextStyle(color: palette.inkSoft, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}

/// A row of three of the style's colours, as a chip avatar.
class _Swatch extends StatelessWidget {
  const _Swatch(this.colors);

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, c) in [colors[0], colors[3], colors[5]].indexed)
          Container(
            width: 5,
            height: 16,
            // Chip avatars get 18px; three bars and two gaps fit in 17.
            margin: EdgeInsets.only(left: i == 0 ? 0 : 1),
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
          ),
      ],
    );
  }
}
