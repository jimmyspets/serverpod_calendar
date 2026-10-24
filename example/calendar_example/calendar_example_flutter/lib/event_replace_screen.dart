import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Explicit single-selection example of the atomic batch replacement API.
class EventReplaceScreen extends StatefulWidget {
  const EventReplaceScreen({
    super.key,
    required this.client,
    required this.event,
  });
  final Client client;
  final cal.CalendarEventView event;
  @override
  State<EventReplaceScreen> createState() => _EventReplaceScreenState();
}

class _EventReplaceScreenState extends State<EventReplaceScreen> {
  final _source = TextEditingController();
  int? _calendarRevision;
  bool _busy = true, _submitted = false;
  String? _error, _result;
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

  Future<void> _load() async {
    try {
      final calendar = await widget.client.modules.serverpod_calendar.calendar
          .getCalendar(widget.event.calendarId, []);
      final bytes = await widget.client.modules.serverpod_calendar.calendarEvent
          .exportEvents(
            cal.CalendarEventExportRequest(
              calendarId: calendar.id,
              expectedRevision: calendar.revision,
              selection: [
                cal.CalendarEventExportSelection(
                  eventId: widget.event.id,
                  expectedRevision: widget.event.revision,
                ),
              ],
            ),
          );
      if (!mounted) return;
      _source.text = utf8.decode(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      setState(() => _calendarRevision = calendar.revision);
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(Object e) =>
      e is cal.CalendarException ? e.message : 'Event replacement failed.';
  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      // The text editor explicitly converts newlines; the byte API stays strict.
      final text = _source.text
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceAll('\n', '\r\n');
      final result = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .replaceFromImport(
            cal.CalendarEventReplaceRequest(
              calendarId: widget.event.calendarId,
              expectedRevision: _calendarRevision!,
              selection: [
                cal.CalendarEventExportSelection(
                  eventId: widget.event.id,
                  expectedRevision: widget.event.revision,
                ),
              ],
              bytes: ByteData.sublistView(
                Uint8List.fromList(utf8.encode(text)),
              ),
            ),
          );
      if (!mounted) return;
      setState(() {
        // A disclosed no-op leaves the expected revision valid for editing.
        // A changed or undisclosed result requires reopening a fresh revision.
        _submitted =
            result.receipts.isEmpty || result.receipts.any((r) => r.changed);
        _result = result.receipts.isEmpty
            ? 'Replacement accepted.'
            : result.receipts.single.changed
            ? 'Event replaced.'
            : 'Identical source; nothing changed.';
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => _error =
              '${_message(e)} Return to the event list and reopen to review a fresh revision before retrying.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Replace event source')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Replace this complete imported series with the same protocol UID. Local source edits conflict. Lifecycle changes require separate host authority; no scheduling message or subscription is created. No automatic overwrite or stale retry.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, key: const Key('event-replace-error')),
        if (_result != null)
          Text(_result!, key: const Key('event-replace-result')),
        TextField(
          key: const Key('event-replace-source'),
          controller: _source,
          readOnly: _busy || _submitted,
          minLines: 10,
          maxLines: 24,
          maxLength: 1048576,
          decoration: const InputDecoration(
            labelText: 'Complete replacement iCalendar',
          ),
        ),
        ElevatedButton(
          key: const Key('event-replace-submit'),
          onPressed: _busy || _submitted || _calendarRevision == null
              ? null
              : _submit,
          child: const Text('Replace selected event'),
        ),
      ],
    ),
  );
}
