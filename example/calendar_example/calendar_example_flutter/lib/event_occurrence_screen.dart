import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class EventOccurrenceScreen extends StatefulWidget {
  const EventOccurrenceScreen({
    super.key,
    required this.client,
    required this.event,
  });
  final Client client;
  final cal.CalendarEventView event;
  @override
  State<EventOccurrenceScreen> createState() => _EventOccurrenceScreenState();
}

class _EventOccurrenceScreenState extends State<EventOccurrenceScreen> {
  final _from = TextEditingController(), _until = TextEditingController();
  cal.CalendarEventOccurrencePreview? _preview;
  bool _busy = false;
  String? _error;
  bool get _date => widget.event.timing!.kind == cal.CalendarEventTimeKind.date;
  @override
  void initState() {
    super.initState();
    final c = widget.event.timing!.start;
    final year = c.year.toString().padLeft(4, '0');
    final month = c.month.toString().padLeft(2, '0');
    _from.text = '$year-$month-01${_date ? '' : 'T00:00:00Z'}';
    // A short explicit query, bounded even near the final supported date.
    _until.text = '$year-$month-28${_date ? '' : 'T00:00:00Z'}';
  }

  @override
  void dispose() {
    _from.dispose();
    _until.dispose();
    super.dispose();
  }

  cal.CalendarEventCivil _civil(String value) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (m == null) {
      throw const FormatException('Use YYYY-MM-DD for date bounds.');
    }
    return cal.CalendarEventCivil(
      year: int.parse(m[1]!),
      month: int.parse(m[2]!),
      day: int.parse(m[3]!),
    );
  }

  DateTime _utc(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$').hasMatch(value)) {
      throw const FormatException('Use YYYY-MM-DDTHH:MM:SSZ for UTC bounds.');
    }
    final parsed = DateTime.parse(value);
    final normalized = parsed.toIso8601String().replaceFirst('.000Z', 'Z');
    if (normalized != value) throw const FormatException('Invalid UTC fields.');
    return parsed;
  }

  Future<void> _load() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    try {
      final q = cal.CalendarEventOccurrenceQuery(
        eventId: widget.event.id,
        expectedRevision: widget.event.revision,
        fromDate: _date ? _civil(_from.text) : null,
        untilDate: _date ? _civil(_until.text) : null,
        fromUtc: _date ? null : _utc(_from.text),
        untilUtc: _date ? null : _utc(_until.text),
      );
      final result = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .preview(q);
      if (mounted) setState(() => _preview = result);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is cal.CalendarException
              ? e.message
              : e is FormatException
              ? e.message
              : 'Preview failed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _label(cal.CalendarEventCivil c) =>
      '${c.year}-${c.month.toString().padLeft(2, '0')}-${c.day.toString().padLeft(2, '0')}${_date ? '' : ' ${c.hour.toString().padLeft(2, '0')}:${c.minute.toString().padLeft(2, '0')}:${c.second.toString().padLeft(2, '0')}'}';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Occurrence preview')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          _date
              ? 'DATE bounds, end exclusive. Dates have no implicit UTC zone.'
              : 'UTC bounds, end exclusive. Original civil identities retain their named zone.',
        ),
        const Text(
          'Maximum 366 days and 500 results. Work-limit failures return no partial preview. This is not a free/busy result; cancelled and transparent series can appear.',
        ),
        TextField(
          key: const Key('preview-from'),
          controller: _from,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'From'),
        ),
        TextField(
          key: const Key('preview-until'),
          controller: _until,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Until (exclusive)'),
        ),
        FilledButton(
          key: const Key('preview-load'),
          onPressed: _busy ? null : _load,
          child: const Text('Load occurrences'),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('preview-error')),
        if (_preview != null)
          Text(
            '${_preview!.occurrences.length} occurrences',
            key: const Key('preview-count'),
          ),
        for (final o
            in _preview?.occurrences ?? <cal.CalendarEventOccurrence>[])
          ListTile(
            title: Text(_label(o.start)),
            subtitle: Text(
              _date
                  ? 'End ${_label(o.endDate!)} (exclusive)'
                  : '${o.startUtc!.toIso8601String()} to ${o.endUtc!.toIso8601String()} UTC; zone ${_preview!.zoneId ?? 'UTC'}',
            ),
          ),
      ],
    ),
  );
}
