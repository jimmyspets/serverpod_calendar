import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

const taskImportExample = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Calendar Example//Synthetic task//EN
BEGIN:VTODO
UID:example-task@example.invalid
DTSTAMP:20261023T120000Z
DTSTART:20261026T090000Z
DURATION:PT1H
SUMMARY;LANGUAGE=en:Imported example task
PERCENT-COMPLETE:25
ORGANIZER:mailto:synthetic@example.invalid
ATTENDEE:mailto:guest@example.invalid
BEGIN:VALARM
ACTION:DISPLAY
DESCRIPTION:Unarmed source reminder
TRIGGER:-PT5M
END:VALARM
END:VTODO
END:VCALENDAR
''';

class TaskImportScreen extends StatefulWidget {
  const TaskImportScreen({
    super.key,
    required this.client,
    required this.calendarId,
  });
  final Client client;
  final UuidValue calendarId;
  @override
  State<TaskImportScreen> createState() => _TaskImportScreenState();
}

class _TaskImportScreenState extends State<TaskImportScreen> {
  final _source = TextEditingController();
  int? _revision;
  bool _busy = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  void _failed(Object e) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = e is cal.CalendarException ? e.message : 'Task import failed.';
      if (e is cal.CalendarException &&
          e.code == cal.CalendarFailureCode.staleRevision) {
        _revision = null;
      }
    });
  }

  Future<void> _load() async {
    try {
      final parent = await widget.client.modules.serverpod_calendar.calendar
          .getCalendar(widget.calendarId, []);
      if (mounted) {
        setState(() {
          _revision = parent.revision;
          _busy = false;
          _error = null;
        });
      }
    } catch (e) {
      _failed(e);
    }
  }

  Future<void> _import() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // This text editor explicitly converts line endings; the byte API stays strict.
      final text = _source.text
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceAll('\n', '\r\n');
      final bytes = Uint8List.fromList(utf8.encode(text));
      await widget.client.modules.serverpod_calendar.calendarTask.importTasks(
        cal.CalendarTaskImportRequest(
          calendarId: widget.calendarId,
          expectedRevision: _revision!,
          bytes: ByteData.sublistView(bytes),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _failed(e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Import tasks')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Paste a supported standalone task calendar. This creates new series; an existing UID rejects the whole import. Text line endings are converted to CRLF before sending. Source participants assign nobody. Imported alarms remain unarmed; no history, invitations or reminders are created.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('task-import-error')),
        TextButton(
          key: const Key('task-import-example'),
          onPressed: _busy ? null : () => _source.text = taskImportExample,
          child: const Text('Load synthetic example'),
        ),
        TextField(
          key: const Key('task-import-source'),
          controller: _source,
          enabled: !_busy,
          minLines: 12,
          maxLines: 24,
          maxLength: 1048576,
          decoration: const InputDecoration(labelText: 'iCalendar task text'),
        ),
        FilledButton(
          key: const Key('task-import-submit'),
          onPressed: _busy || _revision == null ? null : _import,
          child: const Text('Import new task series'),
        ),
        if (!_busy && _revision == null)
          TextButton(
            key: const Key('task-import-reload'),
            onPressed: () {
              setState(() => _busy = true);
              _load();
            },
            child: const Text('Reload destination revision'),
          ),
      ],
    ),
  );
}
