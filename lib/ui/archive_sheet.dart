import 'package:flutter/material.dart';

import '../state/todo_store.dart';
import '../theme.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDay(DateTime d) => '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

Future<void> showArchiveSheet(BuildContext context, TodoStore store) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Palette.of(context).surface,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, controller) => ListenableBuilder(
        listenable: store,
        builder: (context, _) => _ArchiveList(store: store, controller: controller),
      ),
    ),
  );
}

class _ArchiveList extends StatelessWidget {
  const _ArchiveList({required this.store, required this.controller});

  final TodoStore store;
  final ScrollController controller;

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear the archive?'),
        content: const Text('Archived tasks will be deleted for good.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear archive')),
        ],
      ),
    );
    if (ok == true) store.clearArchive();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final items = store.archived;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Archive',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontVariations: const [FontVariation('wght', 700)],
                    color: palette.ink,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClear(context),
                  child: const Text('Clear archive'),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Shake your phone to move finished tasks here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.inkSoft, fontSize: 15),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: controller,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final t = items[i];
                    final done = t.completedAt;
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 20, right: 8),
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done == null ? palette.hairline : palette.strataFor(done),
                        ),
                      ),
                      title: Text(t.text, style: TextStyle(color: palette.ink)),
                      subtitle: done == null
                          ? null
                          : Text('Done ${_formatDay(done)}',
                              style: TextStyle(color: palette.inkSoft)),
                      trailing: IconButton(
                        tooltip: 'Reopen task',
                        icon: Icon(Icons.undo_rounded, color: palette.inkSoft),
                        onPressed: () => store.reopenFromArchive(t.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
