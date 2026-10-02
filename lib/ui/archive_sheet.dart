import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../l10n.dart';
import '../state/todo_store.dart';
import '../theme.dart';

Future<void> showArchiveSheet(BuildContext context, TodoStore store) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Palette.of(context).surface,
    // Own messenger so the undo snackbar shows above the sheet, not under it.
    builder: (context) => ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (context, controller) => ListenableBuilder(
            listenable: store,
            builder: (context, _) => _ArchiveList(store: store, controller: controller),
          ),
        ),
      ),
    ),
  );
}

class _ArchiveList extends StatefulWidget {
  const _ArchiveList({required this.store, required this.controller});

  final TodoStore store;
  final ScrollController controller;

  @override
  State<_ArchiveList> createState() => _ArchiveListState();
}

class _ArchiveListState extends State<_ArchiveList> {
  String _query = '';

  TodoStore get store => widget.store;

  void _delete(int id) {
    final removed = store.deleteArchived(id);
    if (removed == null) return;
    final (task, index) = removed;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(s.deletedFromArchive),
        action:
            SnackBarAction(label: s.undo, onPressed: () => store.undoDeleteArchived(task, index)),
      ));
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.clearArchiveQ),
        content: Text(s.clearArchiveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.keep)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.clearArchive)),
        ],
      ),
    );
    if (ok == true) store.clearArchive();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final all = store.archived;
    final q = _query.toLowerCase();
    final items = q.isEmpty ? all : all.where((t) => t.text.toLowerCase().contains(q)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  s.archive,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontVariations: const [FontVariation('wght', 700)],
                    color: palette.ink,
                  ),
                ),
              ),
              if (all.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClear(context),
                  child: Text(s.clearArchive),
                ),
            ],
          ),
        ),
        if (all.length > 5)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: s.searchArchive,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: palette.glass,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      all.isEmpty ? s.archiveEmpty : s.noArchiveMatch(_query),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.inkSoft, fontSize: 15),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: widget.controller,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final t = items[i];
                    final done = t.completedAt;
                    final tile = ListTile(
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
                          : Text(s.doneOn(formatDay(done)),
                              style: TextStyle(color: palette.inkSoft)),
                      trailing: IconButton(
                        tooltip: s.reopenTask,
                        icon: Icon(Icons.undo_rounded, color: palette.inkSoft),
                        onPressed: () => store.reopenFromArchive(t.id),
                      ),
                    );
                    return Dismissible(
                      key: ValueKey(t.id),
                      onDismissed: (_) => _delete(t.id),
                      background: ColoredBox(color: Theme.of(context).colorScheme.errorContainer),
                      child: Semantics(
                        customSemanticsActions: {
                          CustomSemanticsAction(label: s.delete): () => _delete(t.id),
                        },
                        child: tile,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
