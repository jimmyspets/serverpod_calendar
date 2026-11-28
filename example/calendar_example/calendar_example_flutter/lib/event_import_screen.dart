import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

const eventImportExample = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Calendar Example//Synthetic event//EN
BEGIN:VEVENT
UID:example-event@example.invalid
DTSTAMP:20261023T120000Z
DTSTART:20261026T090000Z
DURATION:PT1H
SUMMARY;LANGUAGE=en:Imported example event
URL:https://example.invalid/events/example
CLASS:PRIVATE
RELATED-TO:unresolved-source@example.invalid
ATTACH;VALUE=URI;FMTTYPE=application/pdf:urn:source:file
ORGANIZER;CN=Synthetic organizer:mailto:source-organizer@example.invalid
ATTENDEE;PARTSTAT=ACCEPTED:mailto:source-attendee@example.invalid
CATEGORIES;LANGUAGE=en:Demo,Demo
CATEGORIES;LANGUAGE=sv:Exempel
COMMENT;LANGUAGE=en:Read-only source metadata
CONTACT;ALTREP="cid:event-desk@example.invalid":Synthetic event desk
RRULE:FREQ=DAILY;COUNT=3
RDATE;VALUE=PERIOD:20261030T090000Z/PT2H
END:VEVENT
END:VCALENDAR
''';

class EventImportScreen extends StatefulWidget {
  const EventImportScreen({
    super.key,
    required this.client,
    required this.calendarId,
  });
  final Client client;
  final UuidValue calendarId;
  @override
  State<EventImportScreen> createState() => _EventImportScreenState();
}

class _EventImportScreenState extends State<EventImportScreen> {
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
      _error = e is cal.CalendarException ? e.message : 'Event import failed.';
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
      await widget.client.modules.serverpod_calendar.calendarEvent.importEvents(
        cal.CalendarEventImportRequest(
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
    appBar: AppBar(title: const Text('Import events')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Paste a supported standalone event calendar. This creates new series; an existing UID rejects the whole import. Text line endings are converted to CRLF before sending. Imported text/link metadata and organizer/attendee claims stay read-only in native event editors and requires separate source-read permission for export. Source participants map to no host users and send no invitations. Source relationships stay unresolved and attachment URIs are never opened or fetched. CLASS does not grant access; links and contact references are never fetched. No invitations, feeds or reminders are started.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('event-import-error')),
        TextButton(
          key: const Key('event-import-example'),
          onPressed: _busy ? null : () => _source.text = eventImportExample,
          child: const Text('Load synthetic example'),
        ),
        TextField(
          key: const Key('event-import-source'),
          controller: _source,
          enabled: !_busy,
          minLines: 12,
          maxLines: 24,
          maxLength: 1048576,
          decoration: const InputDecoration(labelText: 'iCalendar event text'),
        ),
        FilledButton(
          key: const Key('event-import-submit'),
          onPressed: _busy || _revision == null ? null : _import,
          child: const Text('Import new event series'),
        ),
        if (!_busy && _revision == null)
          TextButton(
            key: const Key('event-import-reload'),
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
