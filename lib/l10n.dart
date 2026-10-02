import 'dart:ui';

part 'l10n/ar.dart';
part 'l10n/bn.dart';
part 'l10n/de.dart';
part 'l10n/es.dart';
part 'l10n/fr.dart';
part 'l10n/hi.dart';
part 'l10n/id.dart';
part 'l10n/pt.dart';
part 'l10n/ru.dart';
part 'l10n/ur.dart';
part 'l10n/zh.dart';

/// UI strings for the chosen language; the store swaps this when it changes.
// ponytail: "system" reads the phone's language at startup, so changing it there needs a restart.
var s = S.forLanguage('system');

/// Each language named in itself, for the picker.
const languageNames = {
  'en': 'English',
  'bn': 'বাংলা',
  'zh': '中文',
  'hi': 'हिन्दी',
  'es': 'Español',
  'fr': 'Français',
  'ar': 'العربية',
  'pt': 'Português',
  'ru': 'Русский',
  'ur': 'اردو',
  'id': 'Indonesia',
  'de': 'Deutsch',
};

final supportedLocales = [for (final c in languageNames.keys) Locale(c)];

/// English strings; each language overrides them in `l10n/<code>.dart`.
class S {
  const S();

  /// [code] is 'system' or a key of [languageNames].
  factory S.forLanguage(String code) =>
      switch (code == 'system' ? PlatformDispatcher.instance.locale.languageCode : code) {
        'bn' => const SBn(),
        'zh' => const SZh(),
        'hi' => const SHi(),
        'es' => const SEs(),
        'fr' => const SFr(),
        'ar' => const SAr(),
        'pt' => const SPt(),
        'ru' => const SRu(),
        'ur' => const SUr(),
        'id' => const SId(),
        'de' => const SDe(),
        _ => const S(),
      };

  String get code => 'en';

  Locale get locale => Locale(code);

  /// A number in the language's own digits.
  String n(num v) => '$v';

  String _tasks(int c) => '$c ${c == 1 ? 'task' : 'tasks'}';

  // Dates
  List<String> get weekdays =>
      const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> get weekdaysShort => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> get weekdayInitials => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> get months =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String formatDay(DateTime d) =>
      '${weekdaysShort[d.weekday - 1]}, ${n(d.day)} ${months[d.month - 1]}';
  String due(String day) => 'Due $day';
  String get dueToday => 'Due today';
  String get dueTomorrow => 'Due tomorrow';
  String overdue(int days) => 'Overdue $days ${days == 1 ? 'day' : 'days'}';

  // Common
  String get undo => 'Undo';
  String get delete => 'Delete';
  String get archive => 'Archive';
  String get stats => 'Stats';
  String get addTask => 'Add task';
  String streak(int d) => '$d-day streak';

  // Main screen
  String get myTasks => 'My tasks';
  String get emptyJar => 'Empty jar';
  String jarWith(int c) => 'Jar with letters of ${_tasks(c)} finished';
  String get allDone => 'All done. Enjoy the quiet.';
  String goalReached(int g) => 'Daily goal reached: $g done today.';
  String added(int c) => 'Added ${_tasks(c)}';
  String duplicated(String t) => 'Duplicated “$t”';
  String deleted(String t) => 'Deleted “$t”';
  String get nothingToArchive => 'Nothing to archive yet. Finish a task first.';
  String archived(int c) => 'Archived ${_tasks(c)}';
  String jarFull(int c) =>
      'Jar is full. Moved ${_tasks(c).replaceFirst(' ', ' oldest ')} to the archive.';
  String get listEmpty => 'The list is empty.';
  String copied(int c) => 'Copied ${_tasks(c)} to the clipboard';
  String get noMatch => 'No task matches.';
  String get clearSearch => 'Clear search';
  String get themeSystem => 'System';
  String get themeLight => 'Light';
  String get themeDark => 'Dark';
  String doneOfGoal(int d, int g) => '$d of $g done today';
  String get nothingToday => 'Nothing done today yet';
  String doneToday(int d) => '$d done today';
  String goalPercent(int p) => '$p percent of the daily goal';
  String listPercent(int p) => '$p percent of the list finished';
  String get closeSearch => 'Close search';
  String get searchAndSort => 'Search and sort';
  String get more => 'More';
  String archiveCount(int c) => c == 0 ? archive : '$archive (${n(c)})';
  String get copyList => 'Copy list';
  String get emptyTheJar => 'Archive finished tasks';
  String get sound => 'Sound';
  String get vibration => 'Vibration';
  String get settings => 'Settings';
  String get dailyGoal => 'Daily goal';
  String get dailyGoalHint => 'Tasks to finish each day';
  String get off => 'Off';
  String get theme => 'Theme';
  String get language => 'Language';
  String get soundHint => 'Ticks and whooshes';
  String get vibrationHint => 'Feel letters land';
  String legend(String day) => 'Letters finished on $day settle in this colour';
  String get searchTasks => 'Search tasks';
  String get showAll => 'All';
  String get showOpen => 'Open';
  String get showDone => 'Done';
  String get sortNewest => 'Newest';
  String get sortPriority => 'Priority';
  String get sortDue => 'Due date';
  String get nothingOnList => 'Nothing on the list';
  String get emptyHint => 'Add a task, then check it off to drop its letters into the jar.';
  String get gestureHint => 'Long-press a task to edit · swipe to delete · shake to empty the jar';

  // Task editor
  String get lowHint => 'Light letters that bounce when they land.';
  String get normalHint => 'Letters settle like sand.';
  String get highHint => 'Bold, heavy letters that push others aside.';
  String get editTask => 'Edit task';
  String get newTask => 'New task';
  String get whatNeedsDoing => 'What needs doing?';
  String get whatNeedsDoingMany => 'What needs doing? Paste a list to add many.';
  String get low => 'Low';
  String get normal => 'Normal';
  String get high => 'High';
  String get today => 'Today';
  String get tomorrow => 'Tomorrow';
  String get pickDate => 'Pick date';
  String get removeDueDate => 'Remove due date';
  String get duplicate => 'Duplicate';
  String get saveChanges => 'Save changes';
  String addMany(int c) => 'Add ${_tasks(c)}';

  String get noteHint => 'Note (optional)';
  String get pinToTop => 'Pin to top';
  String get unpin => 'Unpin';
  String get repeatNever => 'Once';
  String get repeatDaily => 'Daily';
  String get repeatWeekly => 'Weekly';

  String get showOverdue => 'Overdue';
  String overdueCount(int c) => '$c overdue';
  String get reminders => 'Due date reminders';
  String get remindersHint => 'A notification at 9 AM on the due day';
  String get remindersBlocked => 'Notifications are blocked. Allow them in system settings.';
  String get smartDateHint => 'Tip: end with “tomorrow” or “fri” to set a date';

  String get jarStyle => 'Jar colours';
  String get jarStyleHint => 'for newly finished tasks';
  String jarStyleName(int i) => const ['Weekdays', 'Sunset', 'Ocean', 'Mono'][i];
  String get backup => 'Backup';
  String get copyBackup => 'Copy backup';
  String get restoreFromClipboard => 'Restore from clipboard';
  String get backupCopied => 'Backup copied. Paste it somewhere safe.';
  String get restoreQ => 'Restore this backup?';
  String get restoreBody =>
      'Your current list and archive will be replaced by the backup on the clipboard.';
  String get restore => 'Restore';
  String get restored => 'Backup restored.';
  String get notABackup => 'The clipboard has no Done Dust backup.';
  String get restoreAll => 'Restore all';
  String get restoreAllQ => 'Put every archived task back?';
  String get restoreAllBody => 'They return to your list as open tasks.';

  String get alarm => 'Alarm';
  String alarmAt(String time) => 'Alarm $time';
  String get removeAlarm => 'Remove alarm';
  String get stopwatch => 'Stopwatch';
  String get startStopwatch => 'Start stopwatch';
  String get pauseStopwatch => 'Pause stopwatch';

  /// 4:05 or 1:02:09, the way a stopwatch shows it.
  String clock(Duration d) {
    String two(int v) => n(v).padLeft(2, n(0));
    final h = d.inHours, m = d.inMinutes % 60, sec = d.inSeconds % 60;
    return h > 0 ? '${n(h)}:${two(m)}:${two(sec)}' : '${n(m)}:${two(sec)}';
  }

  // Archive
  String get deletedFromArchive => 'Deleted from archive';
  String get clearArchiveQ => 'Clear the archive?';
  String get clearArchiveBody => 'Archived tasks will be deleted for good.';
  String get keep => 'Keep';
  String get clearArchive => 'Clear archive';
  String get searchArchive => 'Search archive';
  String get archiveEmpty =>
      'Finished tasks come here when you shake your phone, or tap ⋮ › Archive finished tasks.';
  String noArchiveMatch(String q) => 'No archived task matches “$q”.';
  String doneOn(String day) => 'Done $day';
  String get reopenTask => 'Reopen task';

  // Stats
  String statsLine(int total, int open, int streakDays) =>
      '$total finished in total · $open open · ${streak(streakDays)}';
  String milestone(int d) => '$d-day streak! Keep the dust falling.';
  String bestStreak(int d) => 'Best streak: $d ${d == 1 ? 'day' : 'days'}';
  String weekCompare(int now, int last) {
    final diff = now - last;
    final trend = last == 0 || diff == 0
        ? ''
        : ' (${diff > 0 ? '+' : '−'}${n((diff.abs() * 100 / last).round())}%)';
    return '${weekLine(n(now), n(last))}$trend';
  }

  /// [now] and [last] arrive already in the language's digits.
  String weekLine(String now, String last) => 'This week $now · last week $last';

  String get last12Weeks => 'Last 12 weeks';
  String heatCell(String day, int c) => '$day: $c finished';
  String bestDay(String day) => 'Best day: $day';
  String finishedOn(String day, int c) => '$day: $c finished';

  // First-launch tasks
  List<String> get starterTasks => const [
        'Check me off and watch the letters fall',
        'Tilt your phone to slide the pile',
        'Important tasks are bold and fall like stone',
        'Drag a fallen letter, or tap the pile',
        'Swipe a task sideways to blow it away',
        'Shake the phone to empty the jar into the archive',
      ];
}
