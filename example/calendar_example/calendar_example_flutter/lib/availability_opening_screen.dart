import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'occurrence_timing_editor.dart'
    show occurrenceLabel, occurrenceKey, occurrenceError;
import 'opening_timing_editor.dart';

class AvailabilityOpeningScreen extends StatefulWidget {
  const AvailabilityOpeningScreen({
    super.key,
    required this.client,
    required this.availabilityId,
    required this.openingUid,
  });
  final Client client;
  final UuidValue availabilityId, openingUid;
  @override
  State<AvailabilityOpeningScreen> createState() =>
      _AvailabilityOpeningScreenState();
}

class _AvailabilityOpeningScreenState extends State<AvailabilityOpeningScreen> {
  final _from = TextEditingController(), _until = TextEditingController();
  cal.CalendarAvailabilityView? _rule;
  cal.CalendarAvailabilityOccurrencePreview? _preview;
  String? _error;
  bool _busy = true, _stale = false;
  cal.EndpointCalendarAvailability get _api =>
      widget.client.modules.serverpod_calendar.calendarAvailability;
  cal.CalendarAvailabilityOpening get _opening =>
      _rule!.content.openings.singleWhere((o) => o.uid == widget.openingUid);
  cal.CalendarEventTimingOverrides? get _edits {
    for (final e
        in _rule?.timingOverrides ?? <cal.CalendarAvailabilityOpeningEdits>[]) {
      if (e.openingUid == widget.openingUid) return e.overrides;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    final day = DateTime.utc(now.year, now.month, now.day);
    _from.text = day.toIso8601String().replaceFirst('.000Z', 'Z');
    _until.text = day
        .add(const Duration(days: 7))
        .toIso8601String()
        .replaceFirst('.000Z', 'Z');
    _reload();
  }

  @override
  void dispose() {
    _from.dispose();
    _until.dispose();
    super.dispose();
  }

  DateTime _utc(String text) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$').hasMatch(text)) {
      throw const FormatException('Use YYYY-MM-DDTHH:MM:SSZ.');
    }
    final d = DateTime.parse(text);
    if (d.toIso8601String().replaceFirst('.000Z', 'Z') != text) {
      throw const FormatException('Invalid UTC date/time.');
    }
    return d;
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = occurrenceError(e);
          _stale =
              e is cal.CalendarException &&
              e.code == cal.CalendarFailureCode.staleRevision;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reload() => _run(() async {
    final saved = await _api.getRule(widget.availabilityId);
    if (mounted) {
      setState(() {
        _rule = saved;
        _preview = null;
        _stale = false;
      });
    }
  });
  Future<void> _load() => _run(() async {
    setState(() => _preview = null);
    final preview = await _api.preview(
      cal.CalendarAvailabilityOccurrenceQuery(
        availabilityId: widget.availabilityId,
        openingUid: widget.openingUid,
        expectedRevision: _rule!.revision,
        fromUtc: _utc(_from.text),
        untilUtc: _utc(_until.text),
      ),
    );
    if (mounted) setState(() => _preview = preview);
  });
  Future<void> _change(
    cal.CalendarEventOccurrenceAction action,
    cal.CalendarEventTiming original,
  ) => _run(() async {
    await _api.changeOccurrence(
      cal.CalendarAvailabilityOccurrenceChange(
        availabilityId: widget.availabilityId,
        openingUid: widget.openingUid,
        expectedRevision: _rule!.revision,
        originalStart: original,
        action: action,
      ),
    );
    final saved = await _api.getRule(widget.availabilityId);
    if (mounted) {
      setState(() {
        _rule = saved;
        _preview = null;
      });
    }
  });
  Future<void> _edit(
    cal.CalendarEventOccurrence occurrence,
    bool future,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => OpeningTimingEditor(
          client: widget.client,
          rule: _rule!,
          opening: _opening,
          overrides: _edits,
          occurrence: occurrence,
          future: future,
        ),
      ),
    );
    if (mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final locked = _busy || _stale || _rule == null;
    return Scaffold(
      appBar: AppBar(title: const Text('Opening occurrences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Preview the opening series. Final availability clips openings to the definition’s validity range and overlays bookings. Edits retain original occurrence identity.',
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null) Text(_error!, key: const Key('opening-error')),
            if (_stale)
              const Text('Saved definition changed. Reload before editing.'),
            TextButton(
              key: const Key('opening-reload'),
              onPressed: _busy ? null : _reload,
              child: const Text('Reload saved definition'),
            ),
            TextField(
              key: const Key('opening-from'),
              controller: _from,
              enabled: !locked,
              decoration: const InputDecoration(labelText: 'UTC from'),
              onChanged: (_) => setState(() => _preview = null),
            ),
            TextField(
              key: const Key('opening-until'),
              controller: _until,
              enabled: !locked,
              decoration: const InputDecoration(
                labelText: 'UTC until, exclusive (at most 31 days)',
              ),
              onChanged: (_) => setState(() => _preview = null),
            ),
            ElevatedButton(
              key: const Key('opening-load'),
              onPressed: locked ? null : _load,
              child: const Text('Preview openings'),
            ),
            for (final s
                in _edits?.singles ?? <cal.CalendarEventSingleOverride>[]) ...[
              Text(
                'Single ${occurrenceLabel(s.originalStart.start)}${s.cancelled ? ' — skipped' : ''}',
              ),
              if (s.cancelled)
                TextButton(
                  key: Key(
                    'opening-restore-${occurrenceKey(s.originalStart.start)}',
                  ),
                  onPressed: locked
                      ? null
                      : () => _change(
                          cal.CalendarEventOccurrenceAction.restoreSingle,
                          s.originalStart,
                        ),
                  child: const Text('Restore opening'),
                ),
              if (s.replacement != null)
                TextButton(
                  key: Key(
                    'opening-clear-single-${occurrenceKey(s.originalStart.start)}',
                  ),
                  onPressed: locked
                      ? null
                      : () => _change(
                          cal.CalendarEventOccurrenceAction.clearSingleTiming,
                          s.originalStart,
                        ),
                  child: const Text('Clear single timing'),
                ),
            ],
            for (final f
                in _edits?.future ?? <cal.CalendarEventFutureOverride>[])
              TextButton(
                key: Key(
                  'opening-clear-future-${occurrenceKey(f.originalStart.start)}',
                ),
                onPressed: locked
                    ? null
                    : () => _change(
                        cal.CalendarEventOccurrenceAction.clearFutureTiming,
                        f.originalStart,
                      ),
                child: Text(
                  'Clear future timing from ${occurrenceLabel(f.originalStart.start)}',
                ),
              ),
            if (_preview != null) ...[
              const Text(
                'Preview complete',
                key: Key('opening-preview-complete'),
              ),
              for (final o in _preview!.occurrences)
                Card(
                  child: Column(
                    children: [
                      Text(
                        '${occurrenceLabel(o.start)} — ${o.endUtc?.toIso8601String()}',
                      ),
                      Text('Original: ${occurrenceLabel(o.originalStart)}'),
                      TextButton(
                        key: Key(
                          'opening-single-${occurrenceKey(o.originalStart)}',
                        ),
                        onPressed: locked ? null : () => _edit(o, false),
                        child: const Text('Move/resize this opening'),
                      ),
                      TextButton(
                        key: Key(
                          'opening-future-${occurrenceKey(o.originalStart)}',
                        ),
                        onPressed: locked ? null : () => _edit(o, true),
                        child: const Text('Move/resize this and future'),
                      ),
                      TextButton(
                        key: Key(
                          'opening-skip-${occurrenceKey(o.originalStart)}',
                        ),
                        onPressed: locked
                            ? null
                            : () => _change(
                                cal.CalendarEventOccurrenceAction.cancelSingle,
                                cal.CalendarEventTiming(
                                  kind: _opening.timing.kind,
                                  zoneId: _opening.timing.zoneId,
                                  start: o.originalStart,
                                ),
                              ),
                        child: const Text('Skip this opening'),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
