import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class AvailabilityExportScreen extends StatefulWidget {
  const AvailabilityExportScreen({
    super.key,
    required this.client,
    required this.rule,
  });
  final Client client;
  final cal.CalendarAvailabilityView rule;
  @override
  State<AvailabilityExportScreen> createState() =>
      _AvailabilityExportScreenState();
}

class _AvailabilityExportScreenState extends State<AvailabilityExportScreen> {
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
          .getCalendar(widget.rule.calendarId, []);
      final data = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarAvailability
          .exportCalendar(
            cal.CalendarAvailabilityExportRequest(
              calendarId: widget.rule.calendarId,
              expectedRevision: calendar.revision,
              selection: [
                cal.CalendarAvailabilityExportSelection(
                  availabilityId: widget.rule.id,
                  expectedRevision: widget.rule.revision,
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
              : 'Availability export failed.';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Export availability')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'This exports the selected definition with its openings and supported metadata. No subscription URL or scheduling message is created. Unsupported native state rejects the entire export.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, key: const Key('availability-export-error')),
        if (_text != null) ...[
          ElevatedButton(
            key: const Key('availability-export-copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _text!));
            },
            child: const Text('Copy iCalendar'),
          ),
          SelectableText(_text!, key: const Key('availability-export-source')),
        ],
      ],
    ),
  );
}
