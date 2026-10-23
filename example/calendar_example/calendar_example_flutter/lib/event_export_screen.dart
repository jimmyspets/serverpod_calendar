import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class EventExportScreen extends StatefulWidget {
  const EventExportScreen({
    super.key,
    required this.client,
    required this.event,
  });
  final Client client;
  final cal.CalendarEventView event;
  @override
  State<EventExportScreen> createState() => _EventExportScreenState();
}

class _EventExportScreenState extends State<EventExportScreen> {
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
          .getCalendar(widget.event.calendarId, []);
      final data = await widget.client.modules.serverpod_calendar.calendarEvent
          .exportEvents(
            cal.CalendarEventExportRequest(
              calendarId: widget.event.calendarId,
              expectedRevision: calendar.revision,
              selection: [
                cal.CalendarEventExportSelection(
                  eventId: widget.event.id,
                  expectedRevision: widget.event.revision,
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
              : 'Event export failed.';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Export events')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'This exports the selected event series with supported occurrences and metadata. No subscription URL or scheduling message is created. Unsupported native state rejects the entire export.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('event-export-error')),
        if (_text != null) ...[
          ElevatedButton(
            key: const Key('event-export-copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _text!));
            },
            child: const Text('Copy iCalendar'),
          ),
          SelectableText(_text!, key: const Key('event-export-source')),
        ],
      ],
    ),
  );
}
