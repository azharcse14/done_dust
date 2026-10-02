/// Priority doubles as the physical material of a task's letters:
/// low = light and bouncy, normal = sand, high = heavy stone.
enum Priority { low, normal, high }

class Todo {
  const Todo({
    required this.id,
    required this.text,
    required this.createdAt,
    this.priority = Priority.normal,
    this.completedAt,
  });

  final int id;
  final String text;
  final Priority priority;
  final DateTime createdAt;

  /// Null while the task is still open. The weekday of this date decides
  /// which sediment colour the letters turn into.
  final DateTime? completedAt;

  bool get completed => completedAt != null;

  Todo copyWith({
    String? text,
    Priority? priority,
    DateTime? completedAt,
    bool reopen = false,
  }) {
    return Todo(
      id: id,
      text: text ?? this.text,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      completedAt: reopen ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'priority': priority.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'completedAt': completedAt?.millisecondsSinceEpoch,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    final completed = json['completedAt'];
    return Todo(
      id: json['id'] as int,
      text: json['text'] as String,
      priority: Priority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => Priority.normal,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedAt: completed == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completed as int),
    );
  }
}
