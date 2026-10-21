import 'package:flutter/material.dart';

import 'occurrence_timing_editor.dart';

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
  bool _busy = false, _stale = false;
  late cal.CalendarEventView _event;
  String? _error;
  bool get _date => _event.timing!.kind == cal.CalendarEventTimeKind.date;
  @override
  void initState() {
    super.initState();
    _event = widget.event;
    final c = _event.timing!.start;
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

  Future<void> _load({bool refresh = false}) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    try {
      if (refresh) {
        final fresh = await widget
            .client
            .modules
            .serverpod_calendar
            .calendarEvent
            .getEvent(_event.id, cal.CalendarEventFieldGroup.values);
        if (!fresh.disclosedGroups.contains(
          cal.CalendarEventFieldGroup.timing,
        )) {
          throw StateError('Timing is no longer disclosed');
        }
        _event = fresh;
        _stale = false;
      }
      final q = cal.CalendarEventOccurrenceQuery(
        eventId: _event.id,
        expectedRevision: _event.revision,
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
      if (e is cal.CalendarException &&
          e.code == cal.CalendarFailureCode.staleRevision) {
        _stale = true;
      }
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

  cal.CalendarEventTiming _anchor(cal.CalendarEventCivil c) =>
      cal.CalendarEventTiming(
        kind: _event.timing!.kind,
        zoneId: _event.timing!.zoneId,
        start: c,
      );
  Future<void> _act(
    cal.CalendarEventTiming anchor,
    cal.CalendarEventOccurrenceAction action,
  ) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.modules.serverpod_calendar.calendarEvent
          .changeOccurrence(
            cal.CalendarEventOccurrenceChange(
              eventId: _event.id,
              expectedRevision: _event.revision,
              originalStart: anchor,
              action: action,
            ),
          );
      await _load(refresh: true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = occurrenceError(e);
          _stale = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(
    cal.CalendarEventOccurrence occurrence, {
    bool future = false,
  }) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OccurrenceTimingEditor(
          client: widget.client,
          event: _event,
          occurrence: occurrence,
          future: future,
        ),
      ),
    );
    if (changed == true && mounted) await _load(refresh: true);
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
          onPressed: _busy || _stale ? null : () => _load(),
          child: const Text('Load occurrences'),
        ),
        TextButton(
          key: const Key('preview-reload-series'),
          onPressed: _busy ? null : () => _load(refresh: true),
          child: const Text('Reload saved series'),
        ),
        if (_stale)
          const Text(
            'Saved series changed. Reload it before editing or querying again.',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(_label(o.start)),
                subtitle: Text(
                  _date
                      ? 'End ${_label(o.endDate!)} (exclusive); original ${_label(o.originalStart)}'
                      : '${o.startUtc!.toIso8601String()} to ${o.endUtc!.toIso8601String()} UTC; original ${_label(o.originalStart)}; zone ${_preview!.zoneId ?? 'UTC'}',
                ),
              ),
              Wrap(
                children: [
                  TextButton(
                    key: ValueKey(
                      'occurrence-edit-${occurrenceKey(o.originalStart)}',
                    ),
                    onPressed: _busy || _stale ? null : () => _edit(o),
                    child: const Text('Edit this timing'),
                  ),
                  TextButton(
                    key: ValueKey(
                      'occurrence-future-${occurrenceKey(o.originalStart)}',
                    ),
                    onPressed: _busy || _stale
                        ? null
                        : () => _edit(o, future: true),
                    child: const Text('Edit this and future timing'),
                  ),
                  TextButton(
                    key: ValueKey(
                      'occurrence-cancel-${occurrenceKey(o.originalStart)}',
                    ),
                    onPressed: _busy || _stale
                        ? null
                        : () => _act(
                            _anchor(o.originalStart),
                            cal.CalendarEventOccurrenceAction.cancelSingle,
                          ),
                    child: const Text('Cancel this occurrence'),
                  ),
                ],
              ),
            ],
          ),
        if (_event.timingOverrides != null)
          const Text(
            'Saved timing overrides (including cancelled occurrences)',
          ),
        for (final single
            in _event.timingOverrides?.singles ??
                <cal.CalendarEventSingleOverride>[])
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original ${_label(single.originalStart.start)}${single.cancelled ? ' — cancelled' : ''}',
              ),
              if (single.cancelled)
                TextButton(
                  key: ValueKey(
                    'occurrence-restore-${occurrenceKey(single.originalStart.start)}',
                  ),
                  onPressed: _busy || _stale
                      ? null
                      : () => _act(
                          single.originalStart,
                          cal.CalendarEventOccurrenceAction.restoreSingle,
                        ),
                  child: const Text('Restore occurrence'),
                ),
              if (single.replacement != null)
                TextButton(
                  key: ValueKey(
                    'occurrence-clear-single-${occurrenceKey(single.originalStart.start)}',
                  ),
                  onPressed: _busy || _stale
                      ? null
                      : () => _act(
                          single.originalStart,
                          cal.CalendarEventOccurrenceAction.clearSingleTiming,
                        ),
                  child: const Text('Clear single timing override'),
                ),
            ],
          ),
        for (final future
            in _event.timingOverrides?.future ??
                <cal.CalendarEventFutureOverride>[])
          TextButton(
            key: ValueKey(
              'occurrence-clear-future-${occurrenceKey(future.originalStart.start)}',
            ),
            onPressed: _busy || _stale
                ? null
                : () => _act(
                    future.originalStart,
                    cal.CalendarEventOccurrenceAction.clearFutureTiming,
                  ),
            child: Text(
              'Clear future timing from ${_label(future.originalStart.start)}',
            ),
          ),
      ],
    ),
  );
}
