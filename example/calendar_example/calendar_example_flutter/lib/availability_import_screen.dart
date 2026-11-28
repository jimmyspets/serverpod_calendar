import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

const availabilityImportExample = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Calendar Example//Synthetic availability//EN
BEGIN:VAVAILABILITY
UID:example-hours@example.invalid
DTSTAMP:20261022T120000Z
SUMMARY:Imported example hours
CONTACT:Example contact only
BEGIN:AVAILABLE
UID:example-opening@example.invalid
DTSTAMP:20261022T120000Z
DTSTART:20261026T090000Z
DURATION:PT8H
RRULE:FREQ=WEEKLY;COUNT=4
END:AVAILABLE
END:VAVAILABILITY
END:VCALENDAR
''';

class AvailabilityImportScreen extends StatefulWidget {
  const AvailabilityImportScreen({
    super.key,
    required this.client,
    required this.calendarId,
    this.replacement,
  });
  final Client client;
  final UuidValue calendarId;
  final cal.CalendarAvailabilityView? replacement;
  @override
  State<AvailabilityImportScreen> createState() =>
      _AvailabilityImportScreenState();
}

class _AvailabilityImportScreenState extends State<AvailabilityImportScreen> {
  final _source = TextEditingController();
  int? _revision;
  bool _busy = true;
  String? _message;
  @override
  void initState() {
    super.initState();
    _loadRevision();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  Future<void> _loadRevision() async {
    try {
      final parent = await widget.client.modules.serverpod_calendar.calendar
          .getCalendar(widget.calendarId, []);
      if (mounted) {
        setState(() {
          _revision = parent.revision;
          _busy = false;
        });
      }
    } catch (e) {
      _failed(e);
    }
  }

  void _failed(Object e) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = e is cal.CalendarException
          ? e.message
          : 'Availability import failed.';
      if (e is cal.CalendarException &&
          e.code == cal.CalendarFailureCode.staleRevision) {
        _revision = null;
      }
    });
  }

  Future<void> _import() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      // Textarea input is explicitly converted to CRLF. The module's byte API
      // remains strict and performs no compatibility repair.
      final text = _source.text
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceAll('\n', '\r\n');
      final bytes = Uint8List.fromList(utf8.encode(text));
      if (widget.replacement != null) {
        await widget.client.modules.serverpod_calendar.calendarAvailability
            .replaceFromImport(
              cal.CalendarAvailabilityReplaceRequest(
                calendarId: widget.calendarId,
                expectedRevision: _revision!,
                selection: [
                  cal.CalendarAvailabilityExportSelection(
                    availabilityId: widget.replacement!.id,
                    expectedRevision: widget.replacement!.revision,
                  ),
                ],
                bytes: ByteData.sublistView(bytes),
              ),
            );
      } else {
        await widget.client.modules.serverpod_calendar.calendarAvailability
            .importCalendar(
              cal.CalendarAvailabilityImportRequest(
                calendarId: widget.calendarId,
                expectedRevision: _revision!,
                bytes: ByteData.sublistView(bytes),
              ),
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _failed(e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.replacement == null
            ? 'Import availability'
            : 'Replace availability',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          widget.replacement == null
              ? 'Paste a supported standalone availability calendar. This creates new definitions; an existing UID rejects the whole import. Text line endings are converted to CRLF before sending. No feeds, invitations or reminders are started.'
              : 'Replace this selected definition from a complete supported source file. A recorded import baseline is required; local edits and stale selections reject. Exact source UIDs must match. Identical updates leave all state unchanged. Text line endings are converted to CRLF.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_message != null)
          Text(_message!, key: const Key('availability-import-error')),
        TextButton(
          key: const Key('availability-import-example'),
          onPressed: _busy
              ? null
              : () => _source.text = availabilityImportExample,
          child: const Text('Load synthetic example'),
        ),
        TextField(
          key: const Key('availability-import-source'),
          controller: _source,
          enabled: !_busy,
          minLines: 12,
          maxLines: 24,
          maxLength: 1048576,
          decoration: const InputDecoration(
            labelText: 'iCalendar availability text',
          ),
        ),
        ElevatedButton(
          key: const Key('availability-import-submit'),
          onPressed: _busy || _revision == null ? null : _import,
          child: Text(
            widget.replacement == null
                ? 'Import new definitions'
                : 'Replace selected definition',
          ),
        ),
        if (!_busy && _revision == null)
          const Text(
            'Close and reopen this screen to reload the calendar revision.',
          ),
      ],
    ),
  );
}
