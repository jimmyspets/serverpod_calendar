import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'occurrence_timing_editor.dart'
    show occurrenceLabel, occurrenceKey, occurrenceError;

class OpeningTimingEditor extends StatefulWidget {
  const OpeningTimingEditor({
    super.key,
    required this.client,
    required this.rule,
    required this.opening,
    this.overrides,
    required this.occurrence,
    required this.future,
  });
  final Client client;
  final cal.CalendarAvailabilityView rule;
  final cal.CalendarAvailabilityOpening opening;
  final cal.CalendarEventTimingOverrides? overrides;
  final cal.CalendarEventOccurrence occurrence;
  final bool future;
  @override
  State<OpeningTimingEditor> createState() => _OpeningTimingEditorState();
}

class _OpeningTimingEditorState extends State<OpeningTimingEditor> {
  final _start = TextEditingController(), _end = TextEditingController();
  final _units = List.generate(5, (_) => TextEditingController(text: '0'));
  String _form = 'end';
  String? _error;
  bool _busy = false, _stale = false;
  bool get _date =>
      widget.opening.timing.kind == cal.CalendarEventTimeKind.date;
  @override
  void initState() {
    super.initState();
    final key = occurrenceKey(widget.occurrence.originalStart);
    cal.CalendarEventTiming template = widget.opening.timing;
    for (final r
        in widget.overrides?.future ?? <cal.CalendarEventFutureOverride>[]) {
      if (occurrenceKey(r.originalStart.start).compareTo(key) <= 0) {
        template = r.replacement;
      }
    }
    for (final r
        in widget.overrides?.singles ?? <cal.CalendarEventSingleOverride>[]) {
      if (occurrenceKey(r.originalStart.start) == key &&
          r.replacement != null) {
        template = r.replacement!;
      }
    }
    _start.text = occurrenceLabel(widget.occurrence.start, date: _date);
    _form = template.end != null
        ? 'end'
        : template.duration != null
        ? 'duration'
        : 'end';
    // DATE previews retain exact civil ends. Timed explicit ends need explicit
    // user input rather than guessing a zone offset from the UTC projection.
    _end.text = _date
        ? occurrenceLabel(widget.occurrence.endDate!, date: true)
        : '';
    final d = template.duration;
    final values = [
      d?.weeks ?? 0,
      d?.days ?? 0,
      d?.hours ?? 0,
      d?.minutes ?? 0,
      d?.seconds ?? 0,
    ];
    for (var i = 0; i < 5; i++) {
      _units[i].text = values[i].toString();
    }
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    for (final c in _units) {
      c.dispose();
    }
    super.dispose();
  }

  cal.CalendarEventCivil _civil(String value) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2}))?$')
        .firstMatch(value);
    if (m == null || (_date ? m[4] != null : m[4] == null)) {
      throw const FormatException(
        'Use YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS for this timing profile.',
      );
    }
    return cal.CalendarEventCivil(
      year: int.parse(m[1]!),
      month: int.parse(m[2]!),
      day: int.parse(m[3]!),
      hour: int.parse(m[4] ?? '0'),
      minute: int.parse(m[5] ?? '0'),
      second: int.parse(m[6] ?? '0'),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final values = [
        for (final c in _units)
          if (_form != 'duration')
            0
          else if (RegExp(r'^\d+$').hasMatch(c.text))
            int.parse(c.text)
          else
            throw const FormatException(
              'Duration units must be nonnegative whole numbers.',
            ),
      ];
      final t = widget.opening.timing;
      await widget.client.modules.serverpod_calendar.calendarAvailability
          .changeOccurrence(
            cal.CalendarAvailabilityOccurrenceChange(
              availabilityId: widget.rule.id,
              openingUid: widget.opening.uid!,
              expectedRevision: widget.rule.revision,
              originalStart: cal.CalendarEventTiming(
                kind: t.kind,
                zoneId: t.zoneId,
                start: widget.occurrence.originalStart,
              ),
              action: widget.future
                  ? cal.CalendarEventOccurrenceAction.replaceFutureTiming
                  : cal.CalendarEventOccurrenceAction.replaceSingleTiming,
              replacement: cal.CalendarEventTiming(
                kind: t.kind,
                zoneId: t.zoneId,
                start: _civil(_start.text),
                end: _form == 'end' ? _civil(_end.text) : null,
                duration: _form == 'duration'
                    ? cal.CalendarEventDuration(
                        weeks: values[0],
                        days: values[1],
                        hours: values[2],
                        minutes: values[3],
                        seconds: values[4],
                      )
                    : null,
              ),
            ),
          );
      if (mounted) Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    final locked = _busy || _stale;
    Widget field(String key, String label, TextEditingController controller) =>
        TextField(
          key: Key(key),
          controller: controller,
          enabled: !locked,
          decoration: InputDecoration(labelText: label),
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.future ? 'This and future timing' : 'Occurrence timing',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Original occurrence: ${occurrenceLabel(widget.occurrence.originalStart, date: _date)}',
          ),
          Text(
            'Timing profile: ${widget.opening.timing.kind.name} ${widget.opening.timing.zoneId ?? ''}',
          ),
          const Text(
            'Opening metadata stays on the series. Future timing applies in original occurrence order; separate single edits remain independent.',
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(_error!, key: const Key('occurrence-edit-error')),
          if (_stale)
            const Text(
              'Saved data changed. Your draft is retained here. Close this editor and reload the saved series before retrying.',
            ),
          field('occurrence-start', 'Replacement start', _start),
          DropdownButtonFormField<String>(
            key: ValueKey('occurrence-end-form-$_form'),
            initialValue: _form,
            decoration: const InputDecoration(labelText: 'End form'),
            items: [
              for (final f in ['end', 'duration'])
                DropdownMenuItem(value: f, child: Text(f)),
            ],
            onChanged: locked ? null : (v) => setState(() => _form = v!),
          ),
          if (_form == 'end')
            field(
              'occurrence-end',
              'Exclusive end (enter civil fields explicitly)',
              _end,
            ),
          if (_form == 'duration')
            for (var i = 0; i < 5; i++)
              field(
                'occurrence-unit-$i',
                ['Weeks', 'Days', 'Hours', 'Minutes', 'Seconds'][i],
                _units[i],
              ),
          const Text(
            'Openings require a positive end or duration. Named-zone clock fields are local civil fields, not UTC.',
          ),
          FilledButton(
            key: const Key('occurrence-save'),
            onPressed: locked ? null : _save,
            child: const Text('Save timing'),
          ),
        ],
      ),
    );
  }
}
