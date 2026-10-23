import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class TaskExportScreen extends StatefulWidget {
  const TaskExportScreen({
    super.key,
    required this.client,
    required this.task,
  });
  final Client client;
  final cal.CalendarTaskView task;
  @override
  State<TaskExportScreen> createState() => _TaskExportScreenState();
}

class _TaskExportScreenState extends State<TaskExportScreen> {
  bool _busy = true;
  String? _text, _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final calendar = await widget.client.modules.serverpod_calendar.calendar
          .getCalendar(widget.task.calendarId, []);
      final data = await widget.client.modules.serverpod_calendar.calendarTask
          .exportTasks(
            cal.CalendarTaskExportRequest(
              calendarId: widget.task.calendarId,
              expectedRevision: calendar.revision,
              selection: [
                cal.CalendarTaskExportSelection(
                  taskId: widget.task.id,
                  expectedRevision: widget.task.revision,
                ),
              ],
            ),
          );
      final text = utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      if (mounted) {
        setState(() {
          _text = text;
          _busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is cal.CalendarException
              ? e.message
              : 'Task export failed.';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Export tasks')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'This exports the selected task series with supported occurrences and source metadata, including participants, attachments and unarmed alarms. Native assignments and history are excluded. No subscription URL or scheduling message is created. Unsupported native state rejects the entire export.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('task-export-error')),
        if (_text != null) ...[
          ElevatedButton(
            key: const Key('task-export-copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _text!));
            },
            child: const Text('Copy iCalendar'),
          ),
          SelectableText(_text!, key: const Key('task-export-source')),
        ],
      ],
    ),
  );
}
