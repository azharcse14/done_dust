part of '../l10n.dart';

class SRu extends S {
  const SRu();

  @override
  String get code => 'ru';

  /// Russian plural: 1 задача, 2 задачи, 5 задач (11–14 take the "many" form).
  String _pl(int c, String one, String few, String many) {
    final m10 = c % 10, m100 = c % 100;
    final w = m10 == 1 && m100 != 11
        ? one
        : m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)
            ? few
            : many;
    return '$c $w';
  }

  String _days(int d) => _pl(d, 'день', 'дня', 'дней');

  @override
  String _tasks(int c) => _pl(c, 'задача', 'задачи', 'задач');

  // Dates
  @override
  List<String> get weekdays =>
      const ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'];
  @override
  List<String> get weekdaysShort => const ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
  @override
  List<String> get weekdayInitials => const ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'];

  /// Genitive abbreviations, so formatDay reads "пт, 2 окт.".
  @override
  List<String> get months => const [
        'янв.',
        'февр.',
        'мар.',
        'апр.',
        'мая',
        'июн.',
        'июл.',
        'авг.',
        'сент.',
        'окт.',
        'нояб.',
        'дек.'
      ];
  @override
  String due(String day) => 'Срок: $day';
  @override
  String get dueToday => 'Срок: сегодня';
  @override
  String get dueTomorrow => 'Срок: завтра';
  @override
  String overdue(int days) => 'Просрочено на ${_days(days)}';

  // Common
  @override
  String get undo => 'Отменить';
  @override
  String get delete => 'Удалить';
  @override
  String get archive => 'Архив';
  @override
  String get stats => 'Статистика';
  @override
  String get addTask => 'Добавить задачу';
  @override
  String streak(int d) => 'Серия: ${_days(d)}';

  // Main screen
  @override
  String get myTasks => 'Мои задачи';
  @override
  String get emptyJar => 'Пустая банка';
  @override
  String jarWith(int c) => 'Банка с буквами выполненных задач: $c';
  @override
  String get allDone => 'Всё сделано. Наслаждайтесь тишиной.';
  @override
  String goalReached(int g) => 'Дневная цель достигнута: сегодня выполнено $g.';
  @override
  String added(int c) => 'Добавлено: ${_tasks(c)}';
  @override
  String duplicated(String t) => 'Создана копия «$t»';
  @override
  String deleted(String t) => 'Удалено: «$t»';
  @override
  String get nothingToArchive => 'Пока нечего архивировать. Сначала выполните задачу.';
  @override
  String archived(int c) => 'В архиве: ${_tasks(c)}';
  @override
  String jarFull(int c) => c == 1
      ? 'Банка заполнена. Самая старая задача перемещена в архив.'
      : 'Банка заполнена. Самые старые задачи ($c) перемещены в архив.';
  @override
  String get listEmpty => 'Список пуст.';
  @override
  String copied(int c) => 'Скопировано в буфер обмена: ${_tasks(c)}';
  @override
  String get noMatch => 'Ничего не найдено.';
  @override
  String get clearSearch => 'Очистить поиск';
  @override
  String get themeSystem => 'Системная';
  @override
  String get themeLight => 'Светлая';
  @override
  String get themeDark => 'Тёмная';
  @override
  String doneOfGoal(int d, int g) => 'Сегодня выполнено $d из $g';
  @override
  String get nothingToday => 'Сегодня пока ничего не выполнено';
  @override
  String doneToday(int d) => 'Сегодня выполнено: $d';
  @override
  String goalPercent(int p) => '$p% дневной цели';
  @override
  String listPercent(int p) => 'Список выполнен на $p%';
  @override
  String get closeSearch => 'Закрыть поиск';
  @override
  String get searchAndSort => 'Поиск и сортировка';
  @override
  String get more => 'Ещё';
  @override
  String get copyList => 'Копировать список';
  @override
  String get emptyTheJar => 'Архивировать выполненные';
  @override
  String get sound => 'Звук';
  @override
  String get vibration => 'Вибрация';
  @override
  String get settings => 'Настройки';
  @override
  String get dailyGoal => 'Дневная цель';
  @override
  String get dailyGoalHint => 'Сколько задач выполнять в день';
  @override
  String get off => 'Выкл.';
  @override
  String get theme => 'Тема';
  @override
  String get language => 'Язык';
  @override
  String get soundHint => 'Щелчки и шорохи';
  @override
  String get vibrationHint => 'Чувствовать, как падают буквы';
  @override
  String legend(String day) => '$day: буквы выполненных задач оседают этим цветом';
  @override
  String get searchTasks => 'Поиск задач';
  @override
  String get showAll => 'Все';
  @override
  String get showOpen => 'Открытые';
  @override
  String get showDone => 'Выполненные';
  @override
  String get sortNewest => 'Новые';
  @override
  String get sortPriority => 'Приоритет';
  @override
  String get sortDue => 'Срок';
  @override
  String get nothingOnList => 'Список пуст';
  @override
  String get emptyHint => 'Добавьте задачу, затем отметьте её, и буквы упадут в банку.';
  @override
  String get gestureHint =>
      'Удерживайте задачу, чтобы изменить · смахните, чтобы удалить · встряхните, чтобы опустошить банку';

  // Task editor
  @override
  String get lowHint => 'Лёгкие буквы, которые подпрыгивают при падении.';
  @override
  String get normalHint => 'Буквы оседают, как песок.';
  @override
  String get highHint => 'Жирные, тяжёлые буквы, которые расталкивают другие.';
  @override
  String get editTask => 'Изменить задачу';
  @override
  String get newTask => 'Новая задача';
  @override
  String get whatNeedsDoing => 'Что нужно сделать?';
  @override
  String get whatNeedsDoingMany => 'Что нужно сделать? Вставьте список, чтобы добавить несколько.';
  @override
  String get low => 'Низкий';
  @override
  String get normal => 'Обычный';
  @override
  String get high => 'Высокий';
  @override
  String get today => 'Сегодня';
  @override
  String get tomorrow => 'Завтра';
  @override
  String get pickDate => 'Выбрать дату';
  @override
  String get removeDueDate => 'Убрать срок';
  @override
  String get duplicate => 'Копировать';
  @override
  String get saveChanges => 'Сохранить';
  @override
  String addMany(int c) => 'Добавить: ${_tasks(c)}';

  @override
  String get noteHint => 'Заметка (необязательно)';
  @override
  String get pinToTop => 'Закрепить';
  @override
  String get unpin => 'Открепить';
  @override
  String get repeatNever => 'Однократно';
  @override
  String get repeatDaily => 'Ежедневно';
  @override
  String get repeatWeekly => 'Еженедельно';

  @override
  String get showOverdue => 'Просроченные';
  @override
  String overdueCount(int c) => 'Просрочено: $c';
  @override
  String get reminders => 'Напоминания о сроке';
  @override
  String get remindersHint => 'Уведомление в 9:00 в день срока';
  @override
  String get remindersBlocked => 'Уведомления заблокированы. Разрешите их в настройках системы.';
  @override
  String get smartDateHint => 'Совет: допишите в конце «завтра» или «пятницу», чтобы задать дату';

  @override
  String get jarStyle => 'Цвета банки';
  @override
  String get jarStyleHint => 'для новых выполненных задач';
  @override
  String jarStyleName(int i) => const ['Дни недели', 'Закат', 'Океан', 'Моно'][i];
  @override
  String get backup => 'Резервная копия';
  @override
  String get copyBackup => 'Скопировать резервную копию';
  @override
  String get restoreFromClipboard => 'Восстановить из буфера обмена';
  @override
  String get backupCopied => 'Резервная копия скопирована. Сохраните её в надёжном месте.';
  @override
  String get restoreQ => 'Восстановить эту резервную копию?';
  @override
  String get restoreBody => 'Текущий список и архив будут заменены резервной копией из буфера обмена.';
  @override
  String get restore => 'Восстановить';
  @override
  String get restored => 'Резервная копия восстановлена.';
  @override
  String get notABackup => 'В буфере обмена нет резервной копии Done Dust.';
  @override
  String get restoreAll => 'Восстановить все';
  @override
  String get restoreAllQ => 'Вернуть все задачи из архива?';
  @override
  String get restoreAllBody => 'Они вернутся в список как открытые задачи.';

  @override
  String get alarm => 'Будильник';
  @override
  String alarmAt(String time) => 'Будильник $time';
  @override
  String get removeAlarm => 'Убрать будильник';
  @override
  String get stopwatch => 'Секундомер';
  @override
  String get startStopwatch => 'Запустить секундомер';
  @override
  String get pauseStopwatch => 'Приостановить секундомер';

  // Archive
  @override
  String get deletedFromArchive => 'Удалено из архива';
  @override
  String get clearArchiveQ => 'Очистить архив?';
  @override
  String get clearArchiveBody => 'Задачи в архиве будут удалены навсегда.';
  @override
  String get keep => 'Оставить';
  @override
  String get clearArchive => 'Очистить архив';
  @override
  String get searchArchive => 'Поиск в архиве';
  @override
  String get archiveEmpty =>
      'Выполненные задачи попадают сюда, когда вы встряхиваете телефон или нажимаете ⋮ › Архивировать выполненные.';
  @override
  String noArchiveMatch(String q) => 'В архиве нет задач по запросу «$q».';
  @override
  String doneOn(String day) => 'Выполнено $day';
  @override
  String get reopenTask => 'Вернуть задачу';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      'Всего выполнено: $total · открыто: $open · ${streak(streakDays)}';
  @override
  String milestone(int d) => 'Серия: ${_days(d)}! Пусть пыль продолжает падать.';
  @override
  String bestStreak(int d) => 'Лучшая серия: ${_days(d)}';
  @override
  String weekLine(String now, String last) => 'На этой неделе $now · на прошлой $last';
  @override
  String get last12Weeks => 'Последние 12 недель';
  @override
  String heatCell(String day, int c) => '$day: выполнено $c';
  @override
  String bestDay(String day) => 'Лучший день: $day';
  @override
  String finishedOn(String day, int c) => '$day: выполнено $c';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'Отметьте меня и смотрите, как падают буквы',
        'Наклоните телефон, чтобы сдвинуть кучу',
        'Важные задачи жирные и падают как камень',
        'Потяните упавшую букву или коснитесь кучи',
        'Смахните задачу в сторону, чтобы сдуть её',
        'Встряхните телефон, чтобы высыпать банку в архив',
      ];
}
