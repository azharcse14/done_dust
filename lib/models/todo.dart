/// Priority doubles as the physical material of a task's letters:
/// low = light and bouncy, normal = sand, high = heavy stone.
enum Priority { low, normal, high }

/// A repeating task comes back, due one step later, when it is finished.
enum Repeat { none, daily, weekly }

class Todo {
  const Todo({
    required this.id,
    required this.text,
    required this.createdAt,
    this.priority = Priority.normal,
    this.completedAt,
    this.due,
    this.note = '',
    this.pinned = false,
    this.repeat = Repeat.none,
    this.remindAt,
    this.spent = Duration.zero,
    this.startedAt,
  });

  final int id;
  final String text;
  final Priority priority;
  final DateTime createdAt;

  /// Null while the task is still open. The weekday of this date decides
  /// which sediment colour the letters turn into.
  final DateTime? completedAt;

  /// Optional day the task should be done by (time of day is ignored).
  final DateTime? due;

  /// Optional detail shown under the task; never turned into letters.
  final String note;

  /// Pinned tasks stay at the top of the list.
  final bool pinned;
  final Repeat repeat;

  /// Alarm: a notification at this exact moment.
  final DateTime? remindAt;

  /// Stopwatch: time banked so far, plus the run since [startedAt] if it
  /// is going.
  final Duration spent;
  final DateTime? startedAt;

  bool get timing => startedAt != null;

  Duration elapsed(DateTime now) =>
      spent + (startedAt == null ? Duration.zero : now.difference(startedAt!));

  /// Same task with the stopwatch paused and its run banked.
  Todo stopTimer(DateTime now) =>
      timing ? copyWith(spent: elapsed(now), clearStartedAt: true) : this;

  bool get completed => completedAt != null;

  /// Whole days from [now] until [due]: negative = overdue, 0 = today.
  int? daysUntilDue(DateTime now) {
    final d = due;
    if (d == null) return null;
    return DateTime.utc(d.year, d.month, d.day)
        .difference(DateTime.utc(now.year, now.month, now.day))
        .inDays;
  }

  Todo copyWith({
    String? text,
    Priority? priority,
    DateTime? completedAt,
    bool reopen = false,
    DateTime? due,
    bool clearDue = false,
    String? note,
    bool? pinned,
    Repeat? repeat,
    DateTime? remindAt,
    bool clearRemindAt = false,
    Duration? spent,
    DateTime? startedAt,
    bool clearStartedAt = false,
  }) {
    return Todo(
      id: id,
      text: text ?? this.text,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      completedAt: reopen ? null : (completedAt ?? this.completedAt),
      due: clearDue ? null : (due ?? this.due),
      note: note ?? this.note,
      pinned: pinned ?? this.pinned,
      repeat: repeat ?? this.repeat,
      remindAt: clearRemindAt ? null : (remindAt ?? this.remindAt),
      spent: spent ?? this.spent,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'priority': priority.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'completedAt': completedAt?.millisecondsSinceEpoch,
        if (due != null) 'due': due!.millisecondsSinceEpoch,
        if (note.isNotEmpty) 'note': note,
        if (pinned) 'pinned': true,
        if (repeat != Repeat.none) 'repeat': repeat.name,
        if (remindAt != null) 'remindAt': remindAt!.millisecondsSinceEpoch,
        if (spent > Duration.zero) 'spent': spent.inSeconds,
        if (startedAt != null) 'startedAt': startedAt!.millisecondsSinceEpoch,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    final completed = json['completedAt'];
    final due = json['due'];
    return Todo(
      id: json['id'] as int,
      text: json['text'] as String,
      priority: Priority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => Priority.normal,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedAt: completed == null ? null : DateTime.fromMillisecondsSinceEpoch(completed as int),
      due: due == null ? null : DateTime.fromMillisecondsSinceEpoch(due as int),
      note: json['note'] as String? ?? '',
      pinned: json['pinned'] == true,
      repeat: Repeat.values.firstWhere((r) => r.name == json['repeat'], orElse: () => Repeat.none),
      remindAt: _date(json['remindAt']),
      spent: Duration(seconds: json['spent'] as int? ?? 0),
      startedAt: _date(json['startedAt']),
    );
  }
}

DateTime? _date(Object? ms) => ms is int ? DateTime.fromMillisecondsSinceEpoch(ms) : null;

/// Due date of the copy that replaces a finished repeating task: one step
/// after its due date, or after today if that is later.
DateTime nextDue(Repeat repeat, DateTime? due, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final base = due == null || due.isBefore(today) ? today : due;
  return DateTime(base.year, base.month, base.day + (repeat == Repeat.weekly ? 7 : 1));
}

/// Words that set a due date, in every UI language, lowercase: 0, 1 or 7 are
/// days ahead, 10 + i is weekday i (Monday 0).
const _dueWords = {
  // English
  'today': 0, 'tonight': 0, 'tomorrow': 1, 'tmrw': 1, 'tmr': 1, 'next week': 7,
  'mon': 10, 'monday': 10, 'tue': 11, 'tues': 11, 'tuesday': 11, 'wed': 12, 'wednesday': 12,
  'thu': 13, 'thur': 13, 'thurs': 13, 'thursday': 13, 'fri': 14, 'friday': 14,
  'sat': 15, 'saturday': 15, 'sun': 16, 'sunday': 16,
  // Bangla, "বার" is optional after a weekday
  'আজ': 0, 'আজকে': 0, 'আজই': 0, 'আগামীকাল': 1, 'কাল': 1, 'কালকে': 1, 'সামনের সপ্তাহে': 7,
  'সোম': 10, 'মঙ্গল': 11, 'বুধ': 12, 'বৃহস্পতি': 13, 'শুক্র': 14, 'শনি': 15, 'রবি': 16,
  // Chinese
  '今天': 0, '明天': 1, '下周': 7, '下星期': 7,
  '周一': 10, '周二': 11, '周三': 12, '周四': 13, '周五': 14, '周六': 15, '周日': 16, '周天': 16,
  '星期一': 10, '星期二': 11, '星期三': 12, '星期四': 13, '星期五': 14, '星期六': 15,
  '星期日': 16, '星期天': 16,
  // Hindi
  'आज': 0, 'कल': 1, 'अगले हफ़्ते': 7, 'अगले हफ्ते': 7, 'अगले सप्ताह': 7,
  'सोमवार': 10, 'मंगलवार': 11, 'बुधवार': 12, 'गुरुवार': 13, 'शुक्रवार': 14, 'शनिवार': 15,
  'रविवार': 16,
  // Spanish
  'hoy': 0, 'mañana': 1, 'manana': 1, 'la próxima semana': 7, 'la proxima semana': 7,
  'la semana que viene': 7,
  'lunes': 10, 'martes': 11, 'miércoles': 12, 'miercoles': 12, 'jueves': 13, 'viernes': 14,
  'sábado': 15, 'sabado': 15, 'domingo': 16,
  // French
  "aujourd'hui": 0, 'aujourd’hui': 0, 'demain': 1, 'la semaine prochaine': 7,
  'lundi': 10, 'mardi': 11, 'mercredi': 12, 'jeudi': 13, 'vendredi': 14, 'samedi': 15,
  'dimanche': 16,
  // Arabic
  'اليوم': 0, 'غدا': 1, 'غدًا': 1, 'غداً': 1, 'بكرة': 1, 'الأسبوع القادم': 7, 'الاسبوع القادم': 7,
  'الاثنين': 10, 'الإثنين': 10, 'الثلاثاء': 11, 'الأربعاء': 12, 'الاربعاء': 12, 'الخميس': 13,
  'الجمعة': 14, 'السبت': 15, 'الأحد': 16, 'الاحد': 16,
  // Portuguese, "-feira" is optional after a weekday
  'hoje': 0, 'amanhã': 1, 'amanha': 1, 'semana que vem': 7, 'próxima semana': 7,
  'proxima semana': 7,
  'segunda': 10, 'terça': 11, 'terca': 11, 'quarta': 12, 'quinta': 13, 'sexta': 14,
  // (sábado and domingo are shared with Spanish)
  // Russian
  'сегодня': 0, 'завтра': 1, 'на следующей неделе': 7,
  'понедельник': 10, 'вторник': 11, 'среда': 12, 'среду': 12, 'четверг': 13, 'пятница': 14,
  'пятницу': 14, 'суббота': 15, 'субботу': 15, 'воскресенье': 16,
  // Urdu
  'آج': 0, 'کل': 1, 'اگلے ہفتے': 7,
  'پیر': 10, 'منگل': 11, 'بدھ': 12, 'جمعرات': 13, 'جمعہ': 14, 'ہفتہ': 15, 'اتوار': 16,
  // Indonesian
  'hari ini': 0, 'besok': 1, 'minggu depan': 7,
  'senin': 10, 'selasa': 11, 'rabu': 12, 'kamis': 13, 'jumat': 14, "jum'at": 14, 'sabtu': 15,
  'minggu': 16,
  // German
  'heute': 0, 'morgen': 1, 'nächste woche': 7, 'naechste woche': 7,
  'montag': 10, 'dienstag': 11, 'mittwoch': 12, 'donnerstag': 13, 'freitag': 14,
  'samstag': 15, 'sonntag': 16,
};

final _dueWord = RegExp(
  // Chinese needs no space before the word.
  r'(?:\s+|(?=[一-鿿]))'
  r'(?:(?:on|by|due|el|para el|para|le|pour|am|bis|na|no|até|в|во|до|pada hari|pada|hari|يوم)\s+)?'
  '(${(_dueWords.keys.toList()..sort((a, b) => b.length - a.length)).map(RegExp.escape).join('|')})'
  r'(?:বার|-feira)?\s*$',
  caseSensitive: false,
);

/// "call mom tomorrow" → ("call mom", tomorrow). Only a word at the very
/// end counts, so "Today's report" stays as typed. A weekday means the next
/// one after today. Every UI language's words work in any UI language.
(String, DateTime?) parseDue(String text, DateTime now) {
  final m = _dueWord.firstMatch(text);
  if (m == null || m.start == 0) return (text, null);
  final v = _dueWords[m[1]!.toLowerCase()]!;
  final ahead = (v - 10 + 1 - now.weekday) % 7;
  final days = v < 10 ? v : (ahead == 0 ? 7 : ahead);
  return (text.substring(0, m.start).trim(), DateTime(now.year, now.month, now.day + days));
}
