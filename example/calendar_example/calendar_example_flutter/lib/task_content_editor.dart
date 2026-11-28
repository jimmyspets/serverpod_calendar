import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class TaskContentEditor extends StatefulWidget {
  const TaskContentEditor({super.key, required this.occurrence});
  final cal.CalendarTaskOccurrence occurrence;
  @override
  State<TaskContentEditor> createState() => _TaskContentEditorState();
}

class _TaskContentEditorState extends State<TaskContentEditor> {
  final _actions = {
    for (final f in cal.CalendarTaskContentField.values) f: 'keep',
  };
  late final Map<cal.CalendarTaskContentField, TextEditingController> _values;
  String? _error;
  @override
  void initState() {
    super.initState();
    final c = widget.occurrence.content;
    _values = {
      cal.CalendarTaskContentField.summary: TextEditingController(
        text: c?.summary ?? '',
      ),
      cal.CalendarTaskContentField.description: TextEditingController(
        text: c?.description ?? '',
      ),
      cal.CalendarTaskContentField.location: TextEditingController(
        text: c?.location ?? '',
      ),
      cal.CalendarTaskContentField.priority: TextEditingController(
        text: c?.priority?.toString() ?? '0',
      ),
    };
  }

  @override
  void dispose() {
    for (final c in _values.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    try {
      final changes = <cal.CalendarTaskOccurrenceContentChange>[];
      for (final field in cal.CalendarTaskContentField.values) {
        final selected = _actions[field]!;
        if (selected == 'keep') continue;
        final action = cal.CalendarTaskContentAction.values.byName(selected);
        final set = action == cal.CalendarTaskContentAction.setValue;
        final text = set && field != cal.CalendarTaskContentField.priority
            ? _values[field]!.text
            : null;
        if (text?.isEmpty ?? false) {
          throw const FormatException('Use Clear value for empty text.');
        }
        changes.add(
          cal.CalendarTaskOccurrenceContentChange(
            field: field,
            action: action,
            text: text,
            priority: set && field == cal.CalendarTaskContentField.priority
                ? int.parse(_values[field]!.text)
                : null,
          ),
        );
      }
      if (changes.isEmpty) {
        throw const FormatException('Select at least one field action.');
      }
      Navigator.of(context).pop(changes);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit this task occurrence'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Only selected fields change. Fields without an own value follow the series. Content changes stay on this original even when its timing change applies to future occurrences. Progress and history stay unchanged. Existing text annotations are retained on set; clear or follow-series removes the own annotations.',
          ),
          if (_error != null)
            Text(_error!, key: const Key('task-content-input-error')),
          for (final field in cal.CalendarTaskContentField.values) ...[
            Text(field.name),
            DropdownButton<String>(
              key: ValueKey('task-content-action-${field.name}'),
              value: _actions[field],
              items: const [
                DropdownMenuItem(value: 'keep', child: Text('No change')),
                DropdownMenuItem(
                  value: 'setValue',
                  child: Text('Set own value'),
                ),
                DropdownMenuItem(
                  value: 'clearValue',
                  child: Text('Clear value'),
                ),
                DropdownMenuItem(
                  value: 'inheritSeries',
                  child: Text('Follow series'),
                ),
              ],
              onChanged: (v) => setState(() => _actions[field] = v!),
            ),
            if (_actions[field] == 'setValue')
              TextField(
                key: ValueKey('task-content-value-${field.name}'),
                controller: _values[field],
                maxLines: field == cal.CalendarTaskContentField.description
                    ? 3
                    : 1,
                decoration: InputDecoration(
                  labelText: field == cal.CalendarTaskContentField.priority
                      ? 'Priority (0–9)'
                      : field.name,
                ),
              ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('task-content-save'),
        onPressed: _save,
        child: const Text('Save selected fields'),
      ),
    ],
  );
}
