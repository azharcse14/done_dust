import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models/todo.dart';
import '../theme.dart';

/// [texts] has one entry per pasted line when adding; editing always has
/// exactly one. [duplicate] asks for a copy instead of saving the edit.
typedef TaskDraft = ({
  List<String> texts,
  Priority priority,
  DateTime? due,
  String note,
  bool pinned,
  Repeat repeat,
  DateTime? remindAt,
  bool timing,
  bool duplicate,
});

/// Every letter becomes a particle; keeps one task well under the jar's
/// letter limit.
const _maxTaskLength = 200;

Future<TaskDraft?> showTaskEditor(BuildContext context, {Todo? editing}) {
  return showModalBottomSheet<TaskDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Palette.of(context).surface,
    builder: (_) => _TaskEditor(editing: editing),
  );
}

class _TaskEditor extends StatefulWidget {
  const _TaskEditor({this.editing});

  final Todo? editing;

  @override
  State<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<_TaskEditor> {
  late final TextEditingController _text = TextEditingController(text: widget.editing?.text ?? '');
  late Priority _priority = widget.editing?.priority ?? Priority.normal;
  late DateTime? _due = widget.editing?.due;
  late final TextEditingController _note = TextEditingController(text: widget.editing?.note ?? '');
  late bool _pinned = widget.editing?.pinned ?? false;
  late Repeat _repeat = widget.editing?.repeat ?? Repeat.none;
  late DateTime? _remindAt = widget.editing?.remindAt;
  late bool _timing = widget.editing?.timing ?? false;

  @override
  void dispose() {
    _text.dispose();
    _note.dispose();
    super.dispose();
  }

  /// A pasted list becomes one task per line. An edit stays one task.
  List<String> _lines(String value) {
    final lines =
        widget.editing != null ? [value.replaceAll(RegExp(r'\s*\n\s*'), ' ')] : value.split('\n');
    return [
      for (final l in lines.map((l) => l.trim()))
        if (l.isNotEmpty)
          l.characters.length > _maxTaskLength ? l.characters.take(_maxTaskLength).toString() : l,
    ];
  }

  void _submit({bool duplicate = false}) {
    final texts = _lines(_text.text);
    if (texts.isEmpty) return;
    Navigator.of(context).pop<TaskDraft>(
      (
        texts: texts,
        priority: _priority,
        due: _due,
        note: _note.text,
        pinned: _pinned,
        repeat: _repeat,
        remindAt: _remindAt,
        timing: _timing,
        duplicate: duplicate,
      ),
    );
  }

  /// Alarm on the due day (or today); a time already gone means tomorrow.
  Future<void> _pickAlarm() async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_remindAt ?? now.add(const Duration(hours: 1))),
    );
    if (picked == null || !mounted) return;
    final day = _due ?? now;
    var at = DateTime(day.year, day.month, day.day, picked.hour, picked.minute);
    if (_due == null && !at.isAfter(now)) at = at.add(const Duration(days: 1));
    setState(() => _remindAt = at);
  }

  String _alarmLabel(DateTime at) {
    final time = TimeOfDay.fromDateTime(at).format(context);
    final now = DateTime.now();
    final today = at.year == now.year && at.month == now.month && at.day == now.day;
    return s.alarmAt(today ? time : '$time, ${formatDay(at)}');
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final due = _due;
    final yearAgo = DateTime(now.year - 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: due ?? now,
      // An old overdue task must still open on its own date.
      firstDate: due != null && due.isBefore(yearAgo) ? due : yearAgo,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) setState(() => _due = picked);
  }

  String get _hint => switch (_priority) {
        Priority.low => s.lowHint,
        Priority.normal => s.normalHint,
        Priority.high => s.highHint,
      };

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final isEdit = widget.editing != null;

    // Scrolls when the keyboard leaves too little room for every field.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEdit ? s.editTask : s.newTask,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontVariations: const [FontVariation('wght', 700)],
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            // Adding allows a pasted multi-line list; each line is capped
            // in _lines instead.
            maxLength: isEdit ? _maxTaskLength : null,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: taskTextStyle(color: palette.ink, priority: _priority),
            decoration: InputDecoration(
              hintText: isEdit ? s.whatNeedsDoing : s.whatNeedsDoingMany,
              filled: true,
              fillColor: palette.glass,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(color: palette.ink, fontSize: 14),
            decoration: InputDecoration(
              hintText: s.noteHint,
              isDense: true,
              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              filled: true,
              fillColor: palette.glass,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SegmentedButton<Priority>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: Priority.low, label: Text(s.low)),
              ButtonSegment(value: Priority.normal, label: Text(s.normal)),
              ButtonSegment(value: Priority.high, label: Text(s.high)),
            ],
            selected: {_priority},
            onSelectionChanged: (p) => setState(() => _priority = p.first),
          ),
          const SizedBox(height: 8),
          Text(_hint, style: TextStyle(color: palette.inkSoft, fontSize: 13)),
          // Shows the date a trailing "tomorrow"/"fri" will set, or how to use it.
          if (_due == null)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _text,
              builder: (context, value, _) {
                final lines = _lines(value.text);
                final parsed = lines.length == 1 ? parseDue(lines.single, DateTime.now()).$2 : null;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                          parsed == null
                              ? Icons.lightbulb_outline_rounded
                              : Icons.event_available_rounded,
                          size: 15,
                          color: palette.inkSoft),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          parsed == null ? s.smartDateHint : s.due(formatDay(parsed)),
                          style: TextStyle(color: palette.inkSoft, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_due == null)
                for (final (label, days) in [(s.today, 0), (s.tomorrow, 1)])
                  ActionChip(
                    label: Text(label),
                    onPressed: () {
                      final now = DateTime.now();
                      setState(() => _due = DateTime(now.year, now.month, now.day + days));
                    },
                  ),
              InputChip(
                avatar: const Icon(Icons.event_rounded, size: 18),
                label: Text(_due == null ? s.pickDate : s.due(formatDay(_due!))),
                onPressed: _pickDue,
                onDeleted: _due == null ? null : () => setState(() => _due = null),
                deleteButtonTooltipMessage: s.removeDueDate,
              ),
              InputChip(
                avatar: const Icon(Icons.alarm_rounded, size: 18),
                label: Text(_remindAt == null ? s.alarm : _alarmLabel(_remindAt!)),
                onPressed: _pickAlarm,
                onDeleted: _remindAt == null ? null : () => setState(() => _remindAt = null),
                deleteButtonTooltipMessage: s.removeAlarm,
              ),
              FilterChip(
                avatar: const Icon(Icons.timer_outlined, size: 18),
                label: Text(s.stopwatch),
                selected: _timing,
                showCheckmark: false,
                onSelected: (v) => setState(() => _timing = v),
              ),
              FilterChip(
                avatar: const Icon(Icons.push_pin_outlined, size: 18),
                label: Text(s.pinToTop),
                selected: _pinned,
                showCheckmark: false,
                onSelected: (v) => setState(() => _pinned = v),
              ),
              if (isEdit)
                TextButton.icon(
                  onPressed: () => _submit(duplicate: true),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(s.duplicate),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.repeat_rounded, size: 20, color: palette.inkSoft),
              const SizedBox(width: 10),
              Expanded(
                child: SegmentedButton<Repeat>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: Repeat.none, label: Text(s.repeatNever)),
                    ButtonSegment(value: Repeat.daily, label: Text(s.repeatDaily)),
                    ButtonSegment(value: Repeat.weekly, label: Text(s.repeatWeekly)),
                  ],
                  selected: {_repeat},
                  onSelectionChanged: (r) => setState(() => _repeat = r.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _text,
            builder: (context, value, _) {
              final count = _lines(value.text).length;
              return FilledButton(
                onPressed: count == 0 ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(isEdit
                    ? s.saveChanges
                    : count > 1
                        ? s.addMany(count)
                        : s.addTask),
              );
            },
          ),
        ],
      ),
    );
  }
}
