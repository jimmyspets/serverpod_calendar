import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'availability_opening_screen.dart';
import 'availability_metadata_editor.dart';
import 'occurrence_timing_editor.dart' show occurrenceLabel;

String _error(Object e) => e is cal.CalendarException
    ? e.message
    : e is FormatException
    ? e.message
    : 'Working-hours operation failed.';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({
    super.key,
    required this.client,
    required this.calendarId,
    required this.initialZone,
  });
  final Client client;
  final UuidValue calendarId;
  final String initialZone;
  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  List<cal.CalendarAvailabilityView> _rules = [];
  final _category = TextEditingController();
  bool _busy = true;
  String? _failure;
  cal.EndpointCalendarAvailability get _api =>
      widget.client.modules.serverpod_calendar.calendarAvailability;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _category.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _failure = null;
      _rules = [];
    });
    try {
      final rules = await _api.list(
        widget.calendarId,
        category: _category.text.isEmpty ? null : _category.text,
      );
      if (mounted) setState(() => _rules = rules);
    } catch (e) {
      if (mounted) setState(() => _failure = _error(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit([cal.CalendarAvailabilityView? rule]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AvailabilityEditor(
          client: widget.client,
          calendarId: widget.calendarId,
          initialZone: widget.initialZone,
          rule: rule,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _delete(cal.CalendarAvailabilityView rule) async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await _api.deleteRule(rule.id, rule.revision);
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() {
          _failure = _error(e);
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Working hours'),
      actions: [
        IconButton(
          key: const Key('availability-reload'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Openings use their own explicit timezone. Changing the calendar zone does not move these hours. Higher priority definitions replace lower priority hours in their validity range.',
        ),
        if (_failure != null)
          Text(_failure!, key: const Key('availability-error')),
        if (_busy) const LinearProgressIndicator(),
        TextField(
          key: const Key('availability-category-filter'),
          controller: _category,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Exact category filter'),
        ),
        TextButton(
          onPressed: _busy ? null : _load,
          child: const Text('Filter definitions'),
        ),
        ElevatedButton(
          key: const Key('availability-create'),
          onPressed: _busy ? null : () => _edit(),
          child: const Text('Add working-hours definition'),
        ),
        for (final rule in _rules)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rule.content.summary ?? 'Availability definition'),
                  Text(
                    'Priority ${rule.content.priority}; closed: ${rule.content.closedKind.name}',
                  ),
                  Text(
                    'From: ${rule.content.validFrom == null ? 'unbounded' : occurrenceLabel(rule.content.validFrom!.start)}; until: ${rule.content.validUntil == null ? 'unbounded' : occurrenceLabel(rule.content.validUntil!.start)}',
                  ),
                  for (final o in rule.content.openings)
                    Text(
                      '${occurrenceLabel(o.timing.start)} — ${o.timing.end == null ? 'duration' : occurrenceLabel(o.timing.end!)}; ${o.timing.zoneId ?? 'UTC'}; ${o.recurrence?.rule?.frequency.name ?? 'once'}',
                    ),
                  if (rule.content.openings.isEmpty)
                    const Text('Closed throughout the validity range.'),
                  TextButton(
                    key: Key('availability-metadata-${rule.id}'),
                    onPressed: _busy
                        ? null
                        : () async {
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => AvailabilityMetadataEditor(
                                  client: widget.client,
                                  rule: rule,
                                ),
                              ),
                            );
                            if (mounted) await _load();
                          },
                    child: const Text('Edit metadata'),
                  ),
                  for (final o in rule.content.openings) ...[
                    TextButton(
                      key: Key('opening-preview-${o.uid}'),
                      onPressed: _busy
                          ? null
                          : () async {
                              await Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => AvailabilityOpeningScreen(
                                    client: widget.client,
                                    availabilityId: rule.id,
                                    openingUid: o.uid!,
                                  ),
                                ),
                              );
                              if (mounted) await _load();
                            },
                      child: const Text('Opening occurrences'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              await Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => AvailabilityMetadataEditor(
                                    client: widget.client,
                                    rule: rule,
                                    openingUid: o.uid,
                                  ),
                                ),
                              );
                              if (mounted) await _load();
                            },
                      child: const Text('Opening metadata'),
                    ),
                  ],
                  TextButton(
                    key: Key('availability-edit-${rule.id}'),
                    onPressed: _busy ? null : () => _edit(rule),
                    child: const Text('Edit definition'),
                  ),
                  TextButton(
                    key: Key('availability-delete-${rule.id}'),
                    onPressed: _busy ? null : () => _delete(rule),
                    child: const Text('Delete definition'),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

/// Small example editor. More complex native rules remain readable and are
/// never flattened into this single-opening form.
class AvailabilityEditor extends StatefulWidget {
  const AvailabilityEditor({
    super.key,
    required this.client,
    required this.calendarId,
    required this.initialZone,
    this.rule,
  });
  final Client client;
  final UuidValue calendarId;
  final String initialZone;
  final cal.CalendarAvailabilityView? rule;
  @override
  State<AvailabilityEditor> createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  final _summary = TextEditingController(), _zone = TextEditingController();
  final _from = TextEditingController(), _until = TextEditingController();
  final _start = TextEditingController(), _end = TextEditingController();
  final _days = TextEditingController(text: '1,2,3,4,5');
  final _priority = TextEditingController(text: '0');
  final _inclusions = TextEditingController(),
      _exclusions = TextEditingController();
  bool _closed = false,
      _utc = false,
      _busy = false,
      _stale = false,
      _supported = true;
  String _frequency = 'weekly';
  String? _failure;
  cal.CalendarFreeBusyKind _closedKind = cal.CalendarFreeBusyKind.unavailable;
  @override
  void initState() {
    super.initState();
    _zone.text = widget.initialZone;
    final today = DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    _start.text = '${monday.toIso8601String().substring(0, 10)}T09:00:00';
    _end.text = '${monday.toIso8601String().substring(0, 10)}T17:00:00';
    final c = widget.rule?.content;
    if (c == null) return;
    _summary.text = c.summary ?? '';
    _priority.text = c.priority.toString();
    _closedKind = c.closedKind;
    _from.text = c.validFrom == null ? '' : occurrenceLabel(c.validFrom!.start);
    _until.text = c.validUntil == null
        ? ''
        : occurrenceLabel(c.validUntil!.start);
    _supported =
        c.openings.length <= 1 &&
        [
          c.validFrom,
          c.validUntil,
        ].every((v) => v == null || v.kind == cal.CalendarEventTimeKind.utc);
    _closed = c.openings.isEmpty;
    if (_closed) return;
    final o = c.openings.first;
    _start.text = occurrenceLabel(o.timing.start);
    _end.text = o.timing.end == null ? '' : occurrenceLabel(o.timing.end!);
    _zone.text = o.timing.zoneId ?? widget.initialZone;
    _utc = o.timing.kind == cal.CalendarEventTimeKind.utc;
    final r = o.recurrence?.rule;
    _frequency = r?.frequency.name ?? 'once';
    _supported =
        _supported &&
        o.timing.end != null &&
        (r == null ||
            (['daily', 'weekly'].contains(r.frequency.name) &&
                r.interval == 1 &&
                r.count == null &&
                r.untilDate == null &&
                r.untilUtc == null &&
                r.weekStart == 1 &&
                r.byDay.every((d) => d.ordinal == null) &&
                (r.frequency == cal.CalendarEventFrequency.weekly ||
                    r.byDay.isEmpty) &&
                [
                  r.byMonthDay,
                  r.byYearDay,
                  r.byWeekNo,
                  r.byMonth,
                  r.byHour,
                  r.byMinute,
                  r.bySetPosition,
                ].every((l) => l.isEmpty)));
    _days.text = r?.byDay.map((d) => d.weekday).join(',') ?? '1,2,3,4,5';
    _inclusions.text =
        o.recurrence?.inclusions
            .map((v) => occurrenceLabel(v.start))
            .join('\n') ??
        '';
    _exclusions.text =
        o.recurrence?.exclusions
            .map((v) => occurrenceLabel(v.start))
            .join('\n') ??
        '';
  }

  @override
  void dispose() {
    for (final c in [
      _summary,
      _zone,
      _from,
      _until,
      _start,
      _end,
      _days,
      _priority,
      _inclusions,
      _exclusions,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  cal.CalendarEventCivil _civil(String text) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})$')
        .firstMatch(text);
    if (m == null) {
      throw const FormatException(
        'Use YYYY-MM-DDTHH:MM:SS, without fractions.',
      );
    }
    return cal.CalendarEventCivil(
      year: int.parse(m[1]!),
      month: int.parse(m[2]!),
      day: int.parse(m[3]!),
      hour: int.parse(m[4]!),
      minute: int.parse(m[5]!),
      second: int.parse(m[6]!),
    );
  }

  cal.CalendarEventTiming? _bound(String text) => text.isEmpty
      ? null
      : cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: _civil(text),
        );
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final kind = _utc
          ? cal.CalendarEventTimeKind.utc
          : cal.CalendarEventTimeKind.zoned;
      cal.CalendarEventTiming date(String s) => cal.CalendarEventTiming(
        kind: kind,
        zoneId: _utc ? null : _zone.text,
        start: _civil(s),
      );
      List<cal.CalendarEventTiming> dates(String s) =>
          s.isEmpty ? [] : s.split('\n').map(date).toList();
      if (!RegExp(r'^\d$').hasMatch(_priority.text)) {
        throw const FormatException('Priority must be 0–9.');
      }
      final content = cal.CalendarAvailabilityContent(
        summary: _summary.text.isEmpty ? null : _summary.text,
        description: widget.rule?.content.description,
        location: widget.rule?.content.location,
        categories: widget.rule?.content.categories,
        comments: widget.rule?.content.comments,
        url: widget.rule?.content.url,
        classification: widget.rule?.content.classification,
        priority: int.parse(_priority.text),
        closedKind: _closedKind,
        validFrom: _bound(_from.text),
        validUntil: _bound(_until.text),
        openings: _closed
            ? []
            : [
                cal.CalendarAvailabilityOpening(
                  uid: widget.rule?.content.openings.firstOrNull?.uid,
                  summary: widget.rule?.content.openings.firstOrNull?.summary,
                  description:
                      widget.rule?.content.openings.firstOrNull?.description,
                  location: widget.rule?.content.openings.firstOrNull?.location,
                  categories:
                      widget.rule?.content.openings.firstOrNull?.categories,
                  comments: widget.rule?.content.openings.firstOrNull?.comments,
                  timing: date(_start.text).copyWith(end: _civil(_end.text)),
                  recurrence: cal.CalendarEventRecurrence(
                    inclusions: dates(_inclusions.text),
                    exclusions: dates(_exclusions.text),
                    rule: _frequency == 'once'
                        ? null
                        : cal.CalendarEventRule(
                            frequency: cal.CalendarEventFrequency.values.byName(
                              _frequency,
                            ),
                            byDay: _frequency == 'weekly'
                                ? _days.text
                                      .split(',')
                                      .map(
                                        (d) => cal.CalendarEventByDay(
                                          weekday: int.parse(d.trim()),
                                        ),
                                      )
                                      .toList()
                                : [],
                            byMonthDay: [],
                            byYearDay: [],
                            byWeekNo: [],
                            byMonth: [],
                            byHour: [],
                            byMinute: [],
                            bySetPosition: [],
                          ),
                  ),
                ),
              ],
      );
      final api = widget.client.modules.serverpod_calendar.calendarAvailability;
      if (widget.rule == null) {
        await api.create(
          cal.CalendarAvailabilityCreateRequest(
            calendarId: widget.calendarId,
            content: content,
          ),
        );
      } else {
        await api.update(
          cal.CalendarAvailabilityUpdateRequest(
            availabilityId: widget.rule!.id,
            expectedRevision: widget.rule!.revision,
            content: content,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _failure = _error(e);
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
    final locked = _busy || _stale || !_supported;
    Widget field(
      String key,
      String label,
      TextEditingController c, {
      int lines = 1,
    }) => TextField(
      key: Key(key),
      controller: c,
      enabled: !locked,
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Working-hours definition')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_supported)
            const Text(
              'This definition uses advanced timing. This small example cannot edit it safely; use the native API. No values have been changed.',
            ),
          if (_failure != null)
            Text(_failure!, key: const Key('availability-editor-error')),
          if (_stale)
            const Text(
              'Saved values changed. Close and reopen to review them; your draft has not been applied.',
            ),
          field('availability-summary', 'Label', _summary),
          field(
            'availability-priority',
            'Priority: 1 highest; 0 lowest',
            _priority,
          ),
          field('availability-from', 'Valid from UTC (optional)', _from),
          field(
            'availability-until',
            'Valid until UTC, exclusive (optional)',
            _until,
          ),
          DropdownButtonFormField<cal.CalendarFreeBusyKind>(
            initialValue: _closedKind,
            decoration: const InputDecoration(labelText: 'Closed-time type'),
            items: [
              for (final k in cal.CalendarFreeBusyKind.values.where(
                (k) => k != cal.CalendarFreeBusyKind.free,
              ))
                DropdownMenuItem(value: k, child: Text(k.name)),
            ],
            onChanged: locked ? null : (v) => setState(() => _closedKind = v!),
          ),
          SwitchListTile(
            key: const Key('availability-closed'),
            title: const Text('Closed throughout validity range'),
            value: _closed,
            onChanged: locked ? null : (v) => setState(() => _closed = v),
          ),
          if (!_closed) ...[
            SwitchListTile(
              title: const Text('Use UTC instead of a named timezone'),
              value: _utc,
              onChanged: locked ? null : (v) => setState(() => _utc = v),
            ),
            if (!_utc) field('availability-zone', 'Opening timezone', _zone),
            field(
              'availability-start',
              'First opening start (civil date/time)',
              _start,
            ),
            field(
              'availability-end',
              'First opening end, exclusive (civil date/time)',
              _end,
            ),
            DropdownButtonFormField<String>(
              key: const Key('availability-frequency'),
              initialValue: ['once', 'daily', 'weekly'].contains(_frequency)
                  ? _frequency
                  : 'once',
              items: [
                for (final f in ['once', 'daily', 'weekly'])
                  DropdownMenuItem(value: f, child: Text(f)),
              ],
              onChanged: locked ? null : (v) => setState(() => _frequency = v!),
            ),
            if (_frequency == 'weekly')
              field(
                'availability-days',
                'Weekdays: Monday=1 … Sunday=7',
                _days,
              ),
            field(
              'availability-inclusions',
              'Additional starts (one per line)',
              _inclusions,
              lines: 3,
            ),
            field(
              'availability-exclusions',
              'Excluded starts (one per line)',
              _exclusions,
              lines: 3,
            ),
          ],
          ElevatedButton(
            key: const Key('availability-save'),
            onPressed: locked ? null : _save,
            child: const Text('Save working hours'),
          ),
        ],
      ),
    );
  }
}
