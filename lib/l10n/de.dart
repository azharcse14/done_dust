part of '../l10n.dart';

class SDe extends S {
  const SDe();

  @override
  String get code => 'de';

  @override
  String _tasks(int c) => '$c ${c == 1 ? 'Aufgabe' : 'Aufgaben'}';

  // Dates
  @override
  List<String> get weekdays =>
      const ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
  @override
  List<String> get weekdaysShort => const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  @override
  List<String> get weekdayInitials => const ['M', 'D', 'M', 'D', 'F', 'S', 'S'];
  @override
  List<String> get months => const [
        'Jan.',
        'Feb.',
        'März',
        'Apr.',
        'Mai',
        'Juni',
        'Juli',
        'Aug.',
        'Sept.',
        'Okt.',
        'Nov.',
        'Dez.'
      ];

  /// Fr., 2. Okt.
  @override
  String formatDay(DateTime d) =>
      '${weekdaysShort[d.weekday - 1]}., ${d.day}. ${months[d.month - 1]}';
  @override
  String due(String day) => 'Fällig am $day';
  @override
  String get dueToday => 'Heute fällig';
  @override
  String get dueTomorrow => 'Morgen fällig';
  @override
  String overdue(int days) => '$days ${days == 1 ? 'Tag' : 'Tage'} überfällig';

  // Common
  @override
  String get undo => 'Rückgängig';
  @override
  String get delete => 'Löschen';
  @override
  String get archive => 'Archiv';
  @override
  String get stats => 'Statistik';
  @override
  String get addTask => 'Aufgabe hinzufügen';
  @override
  String streak(int d) => '$d-Tage-Serie';

  // Main screen
  @override
  String get myTasks => 'Meine Aufgaben';
  @override
  String get emptyJar => 'Leeres Glas';
  @override
  String jarWith(int c) => 
      'Glas mit Buchstaben von $c erledigten ${c == 1 ? 'Aufgabe' : 'Aufgaben'}';
  @override
  String get allDone => 'Alles erledigt. Genieß die Ruhe.';
  @override
  String goalReached(int g) => 'Tagesziel erreicht: heute $g erledigt.';
  @override
  String added(int c) => '${_tasks(c)} hinzugefügt';
  @override
  String duplicated(String t) => '„$t“ dupliziert';
  @override
  String deleted(String t) => '„$t“ gelöscht';
  @override
  String get nothingToArchive => 'Noch nichts zu archivieren. Erledige zuerst eine Aufgabe.';
  @override
  String archived(int c) => '${_tasks(c)} archiviert';
  @override
  String jarFull(int c) => c == 1
      ? 'Das Glas ist voll. Die älteste Aufgabe wurde ins Archiv verschoben.'
      : 'Das Glas ist voll. Die $c ältesten Aufgaben wurden ins Archiv verschoben.';
  @override
  String get listEmpty => 'Die Liste ist leer.';
  @override
  String copied(int c) => '${_tasks(c)} in die Zwischenablage kopiert';
  @override
  String get noMatch => 'Keine passende Aufgabe.';
  @override
  String get clearSearch => 'Suche löschen';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Hell';
  @override
  String get themeDark => 'Dunkel';
  @override
  String doneOfGoal(int d, int g) => 'Heute $d von $g erledigt';
  @override
  String get nothingToday => 'Heute noch nichts erledigt';
  @override
  String doneToday(int d) => 'Heute $d erledigt';
  @override
  String goalPercent(int p) => '$p Prozent des Tagesziels';
  @override
  String listPercent(int p) => '$p Prozent der Liste erledigt';
  @override
  String get closeSearch => 'Suche schließen';
  @override
  String get searchAndSort => 'Suchen und sortieren';
  @override
  String get more => 'Mehr';
  @override
  String get copyList => 'Liste kopieren';
  @override
  String get emptyTheJar => 'Erledigte archivieren';
  @override
  String get sound => 'Ton';
  @override
  String get vibration => 'Vibration';
  @override
  String get settings => 'Einstellungen';
  @override
  String get dailyGoal => 'Tagesziel';
  @override
  String get dailyGoalHint => 'Aufgaben, die du täglich erledigen willst';
  @override
  String get off => 'Aus';
  @override
  String get theme => 'Design';
  @override
  String get language => 'Sprache';
  @override
  String get soundHint => 'Ticken und Rauschen';
  @override
  String get vibrationHint => 'Spür, wie Buchstaben landen';
  @override
  String legend(String day) => 'Am $day erledigte Buchstaben setzen sich in dieser Farbe ab';
  @override
  String get searchTasks => 'Aufgaben suchen';
  @override
  String get showAll => 'Alle';
  @override
  String get showOpen => 'Offen';
  @override
  String get showDone => 'Erledigt';
  @override
  String get sortNewest => 'Neueste';
  @override
  String get sortPriority => 'Priorität';
  @override
  String get sortDue => 'Fälligkeit';
  @override
  String get nothingOnList => 'Nichts auf der Liste';
  @override
  String get emptyHint =>
      'Füge eine Aufgabe hinzu und hak sie ab, damit ihre Buchstaben ins Glas fallen.';
  @override
  String get gestureHint =>
      'Lange drücken zum Bearbeiten · wischen zum Löschen · schütteln, um das Glas zu leeren';

  // Task editor
  @override
  String get lowHint => 'Leichte Buchstaben, die beim Landen hüpfen.';
  @override
  String get normalHint => 'Buchstaben setzen sich wie Sand.';
  @override
  String get highHint => 'Fette, schwere Buchstaben, die andere beiseiteschieben.';
  @override
  String get editTask => 'Aufgabe bearbeiten';
  @override
  String get newTask => 'Neue Aufgabe';
  @override
  String get whatNeedsDoing => 'Was ist zu tun?';
  @override
  String get whatNeedsDoingMany => 'Was ist zu tun? Füge eine Liste ein, um mehrere hinzuzufügen.';
  @override
  String get low => 'Niedrig';
  @override
  String get normal => 'Normal';
  @override
  String get high => 'Hoch';
  @override
  String get today => 'Heute';
  @override
  String get tomorrow => 'Morgen';
  @override
  String get pickDate => 'Datum wählen';
  @override
  String get removeDueDate => 'Fälligkeit entfernen';
  @override
  String get duplicate => 'Duplizieren';
  @override
  String get saveChanges => 'Änderungen speichern';
  @override
  String addMany(int c) => '${_tasks(c)} hinzufügen';

  @override
  String get noteHint => 'Notiz (optional)';
  @override
  String get pinToTop => 'Oben anheften';
  @override
  String get unpin => 'Loslösen';
  @override
  String get repeatNever => 'Einmalig';
  @override
  String get repeatDaily => 'Täglich';
  @override
  String get repeatWeekly => 'Wöchentlich';

  @override
  String get showOverdue => 'Überfällig';
  @override
  String overdueCount(int c) => '$c überfällig';
  @override
  String get reminders => 'Erinnerungen an Fälligkeiten';
  @override
  String get remindersHint => 'Eine Benachrichtigung um 9:00 Uhr am Fälligkeitstag';
  @override
  String get remindersBlocked =>
      'Benachrichtigungen sind blockiert. Erlaube sie in den Systemeinstellungen.';
  @override
  String get smartDateHint => 'Tipp: Mit „morgen“ oder „Freitag“ am Ende setzt du ein Datum';

  @override
  String get jarStyle => 'Glasfarben';
  @override
  String get jarStyleHint => 'für neu erledigte Aufgaben';
  @override
  String jarStyleName(int i) => const ['Wochentage', 'Sonnenuntergang', 'Ozean', 'Mono'][i];
  @override
  String get backup => 'Backup';
  @override
  String get copyBackup => 'Backup kopieren';
  @override
  String get restoreFromClipboard => 'Aus Zwischenablage wiederherstellen';
  @override
  String get backupCopied => 'Backup kopiert. Füge es an einem sicheren Ort ein.';
  @override
  String get restoreQ => 'Dieses Backup wiederherstellen?';
  @override
  String get restoreBody =>
      'Deine aktuelle Liste und dein Archiv werden durch das Backup aus der Zwischenablage ersetzt.';
  @override
  String get restore => 'Wiederherstellen';
  @override
  String get restored => 'Backup wiederhergestellt.';
  @override
  String get notABackup => 'In der Zwischenablage ist kein Done-Dust-Backup.';
  @override
  String get restoreAll => 'Alle wiederherstellen';
  @override
  String get restoreAllQ => 'Alle archivierten Aufgaben zurückholen?';
  @override
  String get restoreAllBody => 'Sie kommen als offene Aufgaben zurück auf deine Liste.';

  @override
  String get alarm => 'Wecker';
  @override
  String alarmAt(String time) => 'Wecker $time';
  @override
  String get removeAlarm => 'Wecker entfernen';
  @override
  String get stopwatch => 'Stoppuhr';
  @override
  String get startStopwatch => 'Stoppuhr starten';
  @override
  String get pauseStopwatch => 'Stoppuhr anhalten';

  // Archive
  @override
  String get deletedFromArchive => 'Aus dem Archiv gelöscht';
  @override
  String get clearArchiveQ => 'Archiv leeren?';
  @override
  String get clearArchiveBody => 'Archivierte Aufgaben werden endgültig gelöscht.';
  @override
  String get keep => 'Behalten';
  @override
  String get clearArchive => 'Archiv leeren';
  @override
  String get searchArchive => 'Archiv durchsuchen';
  @override
  String get archiveEmpty =>
      'Erledigte Aufgaben landen hier, wenn du dein Handy schüttelst oder auf ⋮ › Erledigte archivieren tippst.';
  @override
  String noArchiveMatch(String q) => 'Keine archivierte Aufgabe passt zu „$q“.';
  @override
  String doneOn(String day) => 'Erledigt am $day';
  @override
  String get reopenTask => 'Aufgabe wieder öffnen';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      '$total insgesamt erledigt · $open offen · ${streak(streakDays)}';
  @override
  String milestone(int d) => '$d-Tage-Serie! Lass den Staub weiter rieseln.';
  @override
  String bestStreak(int d) => 'Längste Serie: $d ${d == 1 ? 'Tag' : 'Tage'}';
  @override
  String weekLine(String now, String last) => 'Diese Woche $now · letzte Woche $last';
  @override
  String get last12Weeks => 'Letzte 12 Wochen';
  @override
  String heatCell(String day, int c) => '$day: $c erledigt';
  @override
  String bestDay(String day) => 'Bester Tag: $day';
  @override
  String finishedOn(String day, int c) => '$day: $c erledigt';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'Hak mich ab und sieh die Buchstaben fallen',
        'Neig dein Handy, um den Haufen zu verschieben',
        'Wichtige Aufgaben sind fett und fallen wie Steine',
        'Zieh einen gefallenen Buchstaben oder tipp auf den Haufen',
        'Wisch eine Aufgabe zur Seite, um sie wegzupusten',
        'Schüttel das Handy, um das Glas ins Archiv zu leeren',
      ];
}
