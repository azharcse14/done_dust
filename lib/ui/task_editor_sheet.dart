import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../theme.dart';

typedef TaskDraft = ({String text, Priority priority});

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
  late final TextEditingController _text =
      TextEditingController(text: widget.editing?.text ?? '');
  late Priority _priority = widget.editing?.priority ?? Priority.normal;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop<TaskDraft>((text: value, priority: _priority));
  }

  String get _hint => switch (_priority) {
        Priority.low => 'Light letters that bounce when they land.',
        Priority.normal => 'Letters settle like sand.',
        Priority.high => 'Bold, heavy letters that push others aside.',
      };

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final isEdit = widget.editing != null;

    return Padding(
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
            isEdit ? 'Edit task' : 'New task',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontVariations: [FontVariation('wght', 700)],
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: taskTextStyle(color: palette.ink, priority: _priority),
            decoration: InputDecoration(
              hintText: 'What needs doing?',
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
            segments: const [
              ButtonSegment(value: Priority.low, label: Text('Low')),
              ButtonSegment(value: Priority.normal, label: Text('Normal')),
              ButtonSegment(value: Priority.high, label: Text('High')),
            ],
            selected: {_priority},
            onSelectionChanged: (s) => setState(() => _priority = s.first),
          ),
          const SizedBox(height: 8),
          Text(_hint, style: TextStyle(color: palette.inkSoft, fontSize: 13)),
          const SizedBox(height: 20),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _text,
            builder: (context, value, _) => FilledButton(
              onPressed: value.text.trim().isEmpty ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(isEdit ? 'Save changes' : 'Add task'),
            ),
          ),
        ],
      ),
    );
  }
}
