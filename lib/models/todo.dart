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
    );
  }
}

/// Due date of the copy that replaces a finished repeating task: one step
/// after its due date, or after today if that is later.
DateTime nextDue(Repeat repeat, DateTime? due, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final base = due == null || due.isBefore(today) ? today : due;
  return DateTime(base.year, base.month, base.day + (repeat == Repeat.weekly ? 7 : 1));
}

final _dueWord = RegExp(
  r'\s+(?:(?:on|by|due)\s+)?'
  r'(today|tonight|tomorrow|tmrw|tmr|next week|'
  r'mon(?:day)?|tue(?:s|sday)?|wed(?:nesday)?|thu(?:r|rs|rsday)?|fri(?:day)?|sat(?:urday)?|sun(?:day)?|'
  r'আজ|আজকে|আজই|আগামীকাল|কাল|কালকে|সামনের সপ্তাহে|'
  r'সোম|মঙ্গল|বুধ|বৃহস্পতি|শুক্র|শনি|রবি)(?:বার)?\s*$',
  caseSensitive: false,
);

/// "call mom tomorrow" → ("call mom", tomorrow). Only a word at the very
/// end counts, so "Today's report" stays as typed. A weekday means the next
/// one after today. English and Bangla both work in either UI language.
(String, DateTime?) parseDue(String text, DateTime now) {
  final m = _dueWord.firstMatch(text);
  if (m == null || m.start == 0) return (text, null);
  final word = m[1]!.toLowerCase();
  final days = switch (word) {
    'today' || 'tonight' || 'আজ' || 'আজকে' || 'আজই' => 0,
    'tomorrow' || 'tmrw' || 'tmr' || 'আগামীকাল' || 'কাল' || 'কালকে' => 1,
    'next week' || 'সামনের সপ্তাহে' => 7,
    _ => () {
        const en = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
        const bn = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি', 'রবি'];
        var i = en.indexWhere(word.startsWith);
        if (i < 0) i = bn.indexOf(word);
        final ahead = (i + 1 - now.weekday) % 7;
        return ahead == 0 ? 7 : ahead;
      }(),
  };
  return (text.substring(0, m.start).trim(), DateTime(now.year, now.month, now.day + days));
}
