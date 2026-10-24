import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class EventContentEditor extends StatefulWidget {
  const EventContentEditor({super.key, required this.occurrence});
  final cal.CalendarEventOccurrence occurrence;
  @override
  State<EventContentEditor> createState() => _EventContentEditorState();
}

class _EventContentEditorState extends State<EventContentEditor> {
  final _actions = {
    for (final f in cal.CalendarEventContentField.values) f: 'keep',
  };
  late final Map<cal.CalendarEventContentField, TextEditingController> _values;
  String? _error;
  @override
  void initState() {
    super.initState();
    final c = widget.occurrence.content;
    _values = {
      cal.CalendarEventContentField.summary: TextEditingController(
        text: c?.summary ?? '',
      ),
      cal.CalendarEventContentField.description: TextEditingController(
        text: c?.description ?? '',
      ),
      cal.CalendarEventContentField.location: TextEditingController(
        text: c?.location ?? '',
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
      final changes = <cal.CalendarEventOccurrenceContentChange>[];
      for (final field in cal.CalendarEventContentField.values) {
        final selected = _actions[field]!;
        if (selected == 'keep') continue;
        final action = cal.CalendarEventContentAction.values.byName(selected);
        final set = action == cal.CalendarEventContentAction.setValue;
        final text = set ? _values[field]!.text : null;
        if (text?.isEmpty ?? false) {
          throw const FormatException('Use Clear value for empty text.');
        }
        changes.add(
          cal.CalendarEventOccurrenceContentChange(
            field: field,
            action: action,
            text: text,
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
    title: const Text('Edit this event occurrence'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Only selected fields change. Fields without an own value follow the series. Content changes stay on this original even when its timing change applies to future occurrences. Timing and cancellation stay unchanged. Content-only timing inheritance cannot yet be exported faithfully and will reject export. Existing text annotations are retained on set; clear or follow-series removes the own annotations.',
          ),
          if (_error != null)
            Text(_error!, key: const Key('event-content-input-error')),
          for (final field in cal.CalendarEventContentField.values) ...[
            Text(field.name),
            DropdownButton<String>(
              key: ValueKey('event-content-action-${field.name}'),
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
                key: ValueKey('event-content-value-${field.name}'),
                controller: _values[field],
                maxLines: field == cal.CalendarEventContentField.description
                    ? 3
                    : 1,
                decoration: InputDecoration(
                  labelText: field.name,
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
        key: const Key('event-content-save'),
        onPressed: _save,
        child: const Text('Save selected fields'),
      ),
    ],
  );
}
