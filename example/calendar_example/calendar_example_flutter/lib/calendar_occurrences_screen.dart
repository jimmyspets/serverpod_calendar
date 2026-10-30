import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class CalendarOccurrencesScreen extends StatefulWidget {
  const CalendarOccurrencesScreen({
    super.key,
    required this.client,
    required this.calendarId,
    this.initialFromUtc,
    this.initialUntilUtc,
    this.pageSize = 25,
  });
  final Client client;
  final cal.UuidValue calendarId;
  final DateTime? initialFromUtc, initialUntilUtc;
  final int pageSize;
  @override
  State<CalendarOccurrencesScreen> createState() =>
      _CalendarOccurrencesScreenState();
}

class _CalendarOccurrencesScreenState extends State<CalendarOccurrencesScreen> {
  final _from = TextEditingController(), _until = TextEditingController();
  final _rows = <cal.CalendarEventOccurrenceListItem>[];
  cal.CalendarEventOccurrenceListQuery? _active;
  String? _next, _error;
  bool _cancelled = true, _dirty = false, _busy = false;
  String _utc(DateTime value) =>
      value.toIso8601String().replaceFirst('.000Z', 'Z');
  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    final from = widget.initialFromUtc ?? DateTime.utc(now.year, now.month);
    _from.text = _utc(from);
    _until.text = _utc(
      widget.initialUntilUtc ?? DateTime.utc(from.year, from.month + 1),
    );
    _load();
  }

  @override
  void dispose() {
    _from.dispose();
    _until.dispose();
    super.dispose();
  }

  void _changed() => setState(() => _dirty = true);
  DateTime _parseUtc(String text) {
    final match = text.length <= 128
        ? RegExp(
            r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:[.,]0+)?Z$',
          ).firstMatch(text)
        : null;
    final value = match == null ? null : DateTime.tryParse(text);
    if (value == null ||
        [
          value.year,
          value.month,
          value.day,
          value.hour,
          value.minute,
          value.second,
        ].asMap().entries.any(
          (e) => e.value != int.parse(match!.group(e.key + 1)!),
        )) {
      throw const FormatException('Whole-second UTC fields required');
    }
    return value;
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final q = more
          ? _active!.copyWith(cursor: _next)
          : cal.CalendarEventOccurrenceListQuery(
              calendarId: widget.calendarId,
              fromUtc: _parseUtc(_from.text),
              untilUtc: _parseUtc(_until.text),
              pageSize: widget.pageSize,
              includeCancelled: _cancelled,
              fieldGroups: [
                cal.CalendarEventFieldGroup.summary,
                cal.CalendarEventFieldGroup.description,
                cal.CalendarEventFieldGroup.location,
              ],
            );
      final result = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .listOccurrences(q);
      if (mounted) {
        setState(() {
          if (!more) {
            _rows.clear();
            _active = q;
            _dirty =
                DateTime.tryParse(_from.text) != q.fromUtc ||
                DateTime.tryParse(_until.text) != q.untilUtc ||
                _cancelled != q.includeCancelled;
          }
          _rows.addAll(result.occurrences);
          _next = result.nextCursor;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is cal.CalendarException
              ? e.message
              : 'Enter valid UTC window bounds and try again.';
          if (e is cal.CalendarException &&
              {
                cal.CalendarFailureCode.invalidCursor,
                cal.CalendarFailureCode.accessDenied,
              }.contains(e.code)) {
            _rows.clear();
            _next = null;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _civil(cal.CalendarEventCivil v, {bool dateOnly = false}) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${v.year.toString().padLeft(4, '0')}-${two(v.month)}-${two(v.day)}';
    return dateOnly
        ? date
        : '$date ${two(v.hour)}:${two(v.minute)}:${two(v.second)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Calendar occurrences'),
      actions: [
        IconButton(
          key: const Key('occurrences-refresh'),
          onPressed: _busy ? null : () => _load(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Event details in a bounded window. This list does not establish free time. DATE events retain calendar dates; matching uses the calendar’s saved timezone.',
        ),
        TextField(
          enabled: !_busy,
          key: const Key('occurrences-from'),
          controller: _from,
          onChanged: (_) => _changed(),
          decoration: const InputDecoration(labelText: 'From UTC (inclusive)'),
        ),
        TextField(
          enabled: !_busy,
          key: const Key('occurrences-until'),
          controller: _until,
          onChanged: (_) => _changed(),
          decoration: const InputDecoration(labelText: 'Until UTC (exclusive)'),
        ),
        CheckboxListTile(
          key: const Key('occurrences-cancelled'),
          value: _cancelled,
          onChanged: _busy
              ? null
              : (value) => setState(() {
                  _cancelled = value!;
                  _dirty = true;
                }),
          title: const Text('Include cancelled occurrences'),
        ),
        FilledButton(
          key: const Key('occurrences-apply'),
          onPressed: _busy ? null : () => _load(),
          child: const Text('Apply window'),
        ),
        if (_active != null)
          Text(
            'Results for ${_utc(_active!.fromUtc)} to ${_utc(_active!.untilUtc)} (exclusive).',
          ),
        if (_dirty) const Text('Apply changes to query the edited window.'),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('occurrences-error')),
        if (!_busy && _active != null && _rows.isEmpty && _error == null)
          const Text('No visible matching occurrences.'),
        for (final row in _rows)
          Card(
            key: ValueKey(
              'occurrence-${row.eventId}-${_civil(row.originalStart.start)}',
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.disclosedGroups.contains(
                          cal.CalendarEventFieldGroup.summary,
                        )
                        ? (row.occurrence.content?.summary?.isNotEmpty ?? false)
                              ? row.occurrence.content!.summary!
                              : 'Untitled event'
                        : 'Summary withheld',
                  ),
                  Text(
                    row.originalStart.kind == cal.CalendarEventTimeKind.date
                        ? 'DATE ${_civil(row.occurrence.start, dateOnly: true)} → ${_civil(row.occurrence.endDate!, dateOnly: true)} (exclusive)'
                        : '${row.originalStart.zoneId ?? 'UTC'} ${_civil(row.occurrence.start)}; UTC ${_utc(row.occurrence.startUtc!)} → ${_utc(row.occurrence.endUtc!)}',
                  ),
                  Text(
                    'Original: ${_civil(row.originalStart.start, dateOnly: row.originalStart.kind == cal.CalendarEventTimeKind.date)}',
                  ),
                  if (row.occurrence.start != row.originalStart.start)
                    const Text('Moved occurrence'),
                  if (row.cancelled) const Text('Cancelled occurrence'),
                  Text(
                    'Status: ${row.status.name}; transparency: ${row.transparency.name}',
                  ),
                  if (row.occurrence.content?.description != null)
                    Text(row.occurrence.content!.description!),
                  if (row.occurrence.content?.location != null)
                    Text(row.occurrence.content!.location!),
                ],
              ),
            ),
          ),
        if (_next != null)
          TextButton(
            key: const Key('occurrences-more'),
            onPressed: _busy || _dirty ? null : () => _load(more: true),
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}
