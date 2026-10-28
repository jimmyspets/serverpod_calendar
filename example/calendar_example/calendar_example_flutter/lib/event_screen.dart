import 'event_descriptive_editor.dart';
import 'personal_alarm_screen.dart';
import 'event_scheduling_screen.dart';

import 'package:flutter/material.dart';

import 'event_occurrence_screen.dart';
import 'event_import_screen.dart';
import 'event_export_screen.dart';
import 'event_replace_screen.dart';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class EventScreen extends StatefulWidget {
  const EventScreen({
    super.key,
    required this.client,
    required this.calendarId,
    required this.initialZone,
  });
  final Client client;
  final cal.UuidValue calendarId;
  final String initialZone;
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _events = <cal.CalendarEventView>[];
  String? _cursor, _error;
  bool _busy = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final page = await widget.client.modules.serverpod_calendar.calendarEvent
          .list(
            widget.calendarId,
            pageSize: 25,
            fieldGroups: cal.CalendarEventFieldGroup.values,
            cursor: more ? _cursor : null,
          );
      if (mounted) {
        setState(() {
          if (!more) _events.clear();
          _events.addAll(page.events);
          _cursor = page.nextCursor;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open([cal.CalendarEventView? event]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => EventEditor(
          client: widget.client,
          calendarId: widget.calendarId,
          initialZone: widget.initialZone,
          event: event,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Events'),
      actions: [
        TextButton(
          key: const Key('event-import'),
          onPressed: _busy
              ? null
              : () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => EventImportScreen(
                        client: widget.client,
                        calendarId: widget.calendarId,
                      ),
                    ),
                  );
                  if (mounted) await _load();
                },
          child: const Text('Import events'),
        ),
        IconButton(
          key: const Key('events-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('event-create'),
      onPressed: _busy ? null : () => _open(),
      icon: const Icon(Icons.add),
      label: const Text('New event'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        const Text(
          'Event series and single events. This detail list does not establish free time.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('event-error')),
        if (!_busy && _events.isEmpty && _error == null)
          const Text('No visible events.'),
        for (final e in _events)
          ListTile(
            key: ValueKey('event-${e.id}'),
            title: Text(
              e.disclosedGroups.contains(cal.CalendarEventFieldGroup.summary)
                  ? _title(e.summary)
                  : 'Event',
            ),
            subtitle: e.status == null ? null : Text(e.status!.name),
            trailing: IconButton(
              key: ValueKey('event-alarms-${e.id}'),
              tooltip: 'Personal alarms',
              icon: const Icon(Icons.alarm),
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => PersonalAlarmScreen(
                          client: widget.client,
                          parent: cal.CalendarAlarmParent(
                            kind: cal.CalendarAlarmParentKind.event,
                            id: e.id,
                          ),
                          initialZone: widget.initialZone,
                        ),
                      ),
                    ),
            ),
            onTap: _busy ? null : () => _open(e),
          ),
        if (_cursor != null)
          TextButton(
            key: const Key('events-more'),
            onPressed: _busy ? null : () => _load(more: true),
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}

String _title(String? value) =>
    value == null || value.trim().isEmpty ? 'Untitled event' : value;
String _message(Object e) => e is cal.CalendarException
    ? e.message
    : e is FormatException
    ? e.message
    : 'Event request failed.';

class EventEditor extends StatefulWidget {
  const EventEditor({
    super.key,
    required this.client,
    required this.calendarId,
    required this.initialZone,
    this.event,
  });
  final Client client;
  final cal.UuidValue calendarId;
  final String initialZone;
  final cal.CalendarEventView? event;
  @override
  State<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  final _summary = TextEditingController(),
      _description = TextEditingController(),
      _location = TextEditingController(),
      _start = TextEditingController(),
      _end = TextEditingController(),
      _zone = TextEditingController();
  final _duration = List.generate(5, (_) => TextEditingController());
  final _interval = TextEditingController(),
      _count = TextEditingController(),
      _weekStart = TextEditingController(),
      _inclusions = TextEditingController(),
      _exclusions = TextEditingController();
  cal.CalendarEventFrequency? _frequency;
  bool _datesDirty = false, _clearPeriods = false, _clearParameters = false;
  cal.CalendarEventView? _view;
  cal.CalendarEventTimeKind _kind = cal.CalendarEventTimeKind.date;
  cal.CalendarEventTransparency _transparency =
      cal.CalendarEventTransparency.opaque;
  String _endForm = 'omitted';
  bool _busy = false, _stale = false, _dirty = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _view = widget.event;
    _reset();
  }

  String _format(cal.CalendarEventCivil c) =>
      '${c.year.toString().padLeft(4, '0')}-${c.month.toString().padLeft(2, '0')}-${c.day.toString().padLeft(2, '0')}${_kind == cal.CalendarEventTimeKind.date ? '' : 'T${c.hour.toString().padLeft(2, '0')}:${c.minute.toString().padLeft(2, '0')}:${c.second.toString().padLeft(2, '0')}'}';
  void _reset() {
    final t = _view?.timing;
    _kind = t?.kind ?? cal.CalendarEventTimeKind.date;
    _summary.text = _view?.summary ?? '';
    _description.text = _view?.description ?? '';
    _location.text = _view?.location ?? '';
    final today = DateTime.now();
    _start.text = _format(
      t?.start ??
          cal.CalendarEventCivil(
            year: today.year,
            month: today.month,
            day: today.day,
          ),
    );
    _end.text = t?.end == null ? '' : _format(t!.end!);
    final recurrence = _view?.recurrence;
    final rule = recurrence?.rule;
    _frequency = rule?.frequency;
    _interval.text = (rule?.interval ?? 1).toString();
    _count.text = rule?.count?.toString() ?? '';
    _weekStart.text = (rule?.weekStart ?? 1).toString();
    _inclusions.text =
        recurrence?.inclusions.map((v) => _format(v.start)).join('\n') ?? '';
    _exclusions.text =
        recurrence?.exclusions.map((v) => _format(v.start)).join('\n') ?? '';
    _datesDirty = false;
    _clearPeriods = false;
    _clearParameters = false;
    _zone.text = t?.zoneId ?? widget.initialZone;
    final d = t?.duration;
    final units = [
      d?.weeks ?? 0,
      d?.days ?? 0,
      d?.hours ?? 0,
      d?.minutes ?? 0,
      d?.seconds ?? 0,
    ];
    for (var i = 0; i < 5; i++) {
      _duration[i].text = units[i].toString();
    }
    _endForm = t?.end != null
        ? 'end'
        : d != null
        ? 'duration'
        : 'omitted';
    _transparency = _view?.transparency ?? cal.CalendarEventTransparency.opaque;
    _dirty = false;
    _stale = false;
  }

  @override
  void dispose() {
    for (final c in [
      _summary,
      _description,
      _location,
      _start,
      _end,
      _zone,
      ..._duration,
      _interval,
      _count,
      _weekStart,
      _inclusions,
      _exclusions,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _editable =>
      _view == null ||
      [
        cal.CalendarEventFieldGroup.summary,
        cal.CalendarEventFieldGroup.description,
        cal.CalendarEventFieldGroup.location,
        cal.CalendarEventFieldGroup.timing,
        cal.CalendarEventFieldGroup.state,
      ].every(_view!.disclosedGroups.contains);
  Future<void> _run(Future<void> Function() action) async {
    // End the editing connection before temporarily disabling the form.
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _message(e);
          if (e is cal.CalendarException &&
              e.code == cal.CalendarFailureCode.staleRevision) {
            _stale = true;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reload({int? expected}) async {
    final fresh = await widget.client.modules.serverpod_calendar.calendarEvent
        .getEvent(_view!.id, cal.CalendarEventFieldGroup.values);
    if (!mounted) return;
    setState(() {
      if (expected != null && fresh.revision != expected) {
        _stale = true;
        _error =
            'Another change was observed. Reload saved values before editing.';
      } else {
        _view = fresh;
        _reset();
      }
    });
  }

  cal.CalendarEventCivil _civil(String text) {
    final m = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2}))?)?$',
    ).firstMatch(text);
    if (m == null ||
        (_kind == cal.CalendarEventTimeKind.date
            ? m[4] != null
            : m[4] == null)) {
      throw const FormatException(
        'Use YYYY-MM-DD for dates or YYYY-MM-DDTHH:MM:SS for times.',
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

  cal.CalendarEventContent _content() {
    final units = [
      for (final c in _duration)
        if (_endForm != 'duration')
          0
        else if (RegExp(r'^\d+$').hasMatch(c.text))
          int.parse(c.text)
        else
          throw const FormatException(
            'Duration units must be nonnegative whole numbers.',
          ),
    ];
    return cal.CalendarEventContent(
      summary: _summary.text.isEmpty ? null : _summary.text,
      description: _description.text.isEmpty ? null : _description.text,
      location: _location.text.isEmpty ? null : _location.text,
      timing: cal.CalendarEventTiming(
        kind: _kind,
        start: _civil(_start.text),
        end: _endForm == 'end' ? _civil(_end.text) : null,
        duration: _endForm == 'duration'
            ? cal.CalendarEventDuration(
                weeks: units[0],
                days: units[1],
                hours: units[2],
                minutes: units[3],
                seconds: units[4],
              )
            : null,
        zoneId: _kind == cal.CalendarEventTimeKind.zoned ? _zone.text : null,
      ),
      status: _view?.status ?? cal.CalendarEventStatus.confirmed,
      transparency: _transparency,
      recurrence: _recurrence(),
      periods: _clearPeriods ? null : _view?.periods,
      textParameters: _clearParameters ? null : _view?.textParameters,
    );
  }

  cal.CalendarEventRecurrence? _recurrence() {
    final previous = _view?.recurrence;
    cal.CalendarEventRule? rule;
    if (_frequency != null) {
      int number(String value) {
        if (!RegExp(r'^\d+$').hasMatch(value)) {
          throw const FormatException(
            'Recurrence numbers must be whole positive numbers.',
          );
        }
        return int.parse(value);
      }

      final template =
          previous?.rule ??
          cal.CalendarEventRule(
            frequency: _frequency!,
            byDay: [],
            byMonthDay: [],
            byYearDay: [],
            byWeekNo: [],
            byMonth: [],
            byHour: [],
            byMinute: [],
            bySetPosition: [],
          );
      rule = template.copyWith(
        frequency: _frequency!,
        interval: number(_interval.text),
        count: _count.text.isEmpty ? null : number(_count.text),
        weekStart: number(_weekStart.text),
      );
    }
    List<cal.CalendarEventTiming> dates(String text) => [
      for (final line in text.split('\n'))
        if (line.isNotEmpty)
          cal.CalendarEventTiming(
            kind: _kind,
            start: _civil(line),
            zoneId: _kind == cal.CalendarEventTimeKind.zoned
                ? _zone.text
                : null,
          ),
    ];
    final inclusions = _datesDirty
        ? dates(_inclusions.text)
        : previous?.inclusions ?? <cal.CalendarEventTiming>[];
    final exclusions = _datesDirty
        ? dates(_exclusions.text)
        : previous?.exclusions ?? <cal.CalendarEventTiming>[];
    if (rule == null && inclusions.isEmpty && exclusions.isEmpty) return null;
    return cal.CalendarEventRecurrence(
      rule: rule,
      inclusions: inclusions,
      exclusions: exclusions,
    );
  }

  Future<void> _save() => _run(() async {
    final content = _content();
    if (_view == null) {
      await widget.client.modules.serverpod_calendar.calendarEvent.create(
        cal.CalendarEventCreateRequest(
          calendarId: widget.calendarId,
          content: content,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } else {
      final expected = _view!.revision;
      await widget.client.modules.serverpod_calendar.calendarEvent.update(
        cal.CalendarEventUpdateRequest(
          eventId: _view!.id,
          expectedRevision: expected,
          content: content,
          replaceRecurrenceDates: _datesDirty,
          replacePeriods: _clearPeriods,
          replaceTextParameters: _clearParameters,
        ),
      );
      await _reload(expected: expected + 1);
    }
  });
  Future<void> _status(cal.CalendarEventStatus status) => _run(() async {
    final expected = _view!.revision;
    await widget.client.modules.serverpod_calendar.calendarEvent.changeStatus(
      cal.CalendarEventStatusRequest(
        eventId: _view!.id,
        expectedRevision: expected,
        status: status,
      ),
    );
    await _reload(expected: expected + 1);
  });
  Future<void> _delete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text(
          'Active content will be removed. Cancellation keeps the event instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            key: const Key('event-confirm-delete'),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true) {
      await _run(() async {
        await widget.client.modules.serverpod_calendar.calendarEvent
            .deleteEvent(_view!.id, _view!.revision);
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _busy || _stale;
    Widget text(
      String key,
      String label,
      TextEditingController c, {
      int lines = 1,
    }) => TextField(
      key: Key(key),
      controller: c,
      enabled: !locked,
      maxLines: lines,
      onChanged: (_) => setState(() => _dirty = true),
      decoration: InputDecoration(labelText: label),
    );
    return Scaffold(
      appBar: AppBar(title: Text(_view == null ? 'New event' : 'Edit event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_busy) const LinearProgressIndicator(),
            if (_error != null) Text(_error!, key: const Key('event-error')),
            if (_view != null)
              TextButton(
                key: const Key('event-reload'),
                onPressed: _busy ? null : () => _run(_reload),
                child: const Text('Reload saved values'),
              ),
            if (_view?.protocolUid != null)
              SelectableText('Event UID: ${_view!.protocolUid}'),
            if (_view?.protocolVersion != null)
              Text(
                'Protocol sequence: ${_view!.protocolVersion!.sequence ?? 0}; stamp: ${_view!.protocolVersion!.stamp.toIso8601String()}',
              ),
            if (_editable) ...[
              if (_view?.textParameters != null) ...[
                const Text(
                  'Language and alternative-representation annotations are retained when editing text. Links are stored without fetching them.',
                ),
                for (final entry in {
                  'Summary': _view!.textParameters!.summary,
                  'Description': _view!.textParameters!.description,
                  'Location': _view!.textParameters!.location,
                }.entries)
                  if (entry.value != null)
                    SelectableText(
                      '${entry.key}: language ${entry.value!.language ?? "unspecified"}; alternative ${entry.value!.alternativeUri ?? "none"}',
                    ),
                CheckboxListTile(
                  key: const Key('event-clear-parameters'),
                  title: const Text('Clear text annotations on save'),
                  value: _clearParameters,
                  onChanged: locked
                      ? null
                      : (v) => setState(() {
                          _clearParameters = v!;
                          _dirty = true;
                        }),
                ),
              ],
              if (_view?.periods?.isNotEmpty ?? false) ...[
                Text(
                  '${_view!.periods!.length} inclusion periods with their own end or duration are retained on save.',
                ),
                CheckboxListTile(
                  key: const Key('event-clear-periods'),
                  title: const Text('Remove inclusion periods on save'),
                  value: _clearPeriods,
                  onChanged: locked
                      ? null
                      : (v) => setState(() {
                          _clearPeriods = v!;
                          _dirty = true;
                        }),
                ),
              ],
              text('event-summary', 'Summary (optional)', _summary),
              text('event-description', 'Description', _description, lines: 3),
              text('event-location', 'Location', _location),
              DropdownButtonFormField<cal.CalendarEventTimeKind>(
                key: ValueKey('event-kind-$_kind'),
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Time meaning'),
                items: [
                  for (final k in [
                    cal.CalendarEventTimeKind.date,
                    cal.CalendarEventTimeKind.utc,
                    cal.CalendarEventTimeKind.zoned,
                  ])
                    DropdownMenuItem(value: k, child: Text(k.name)),
                ],
                onChanged: locked
                    ? null
                    : (v) => setState(() {
                        _kind = v!;
                        _dirty = true;
                      }),
              ),
              text(
                'event-start',
                'Start (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS)',
                _start,
              ),
              if (_kind == cal.CalendarEventTimeKind.zoned)
                text('event-zone', 'Named time zone', _zone),
              DropdownButtonFormField<String>(
                key: ValueKey('event-end-form-$_endForm'),
                initialValue: _endForm,
                decoration: const InputDecoration(labelText: 'End form'),
                items: [
                  for (final v in ['omitted', 'end', 'duration'])
                    DropdownMenuItem(value: v, child: Text(v)),
                ],
                onChanged: locked
                    ? null
                    : (v) => setState(() {
                        _endForm = v!;
                        _dirty = true;
                      }),
              ),
              if (_endForm == 'end') text('event-end', 'Exclusive end', _end),
              if (_endForm == 'duration')
                for (var i = 0; i < 5; i++)
                  text(
                    'event-duration-$i',
                    ['Weeks', 'Days', 'Hours', 'Minutes', 'Seconds'][i],
                    _duration[i],
                  ),
              const Text(
                'Omitted end means one day for dates, or a point for timed events. Floating times are unsupported.',
              ),
              DropdownButtonFormField<String>(
                key: ValueKey('event-frequency-${_frequency?.name ?? 'none'}'),
                initialValue: _frequency?.name ?? 'none',
                decoration: const InputDecoration(
                  labelText: 'Recurrence frequency',
                ),
                items: [
                  for (final name in [
                    'none',
                    ...cal.CalendarEventFrequency.values.map((v) => v.name),
                  ])
                    DropdownMenuItem(value: name, child: Text(name)),
                ],
                onChanged: locked
                    ? null
                    : (name) => setState(() {
                        _frequency = name == 'none'
                            ? null
                            : cal.CalendarEventFrequency.values.byName(name!);
                        _dirty = true;
                      }),
              ),
              if (_frequency != null) ...[
                text('event-rule-interval', 'Recurrence interval', _interval),
                text('event-rule-count', 'COUNT (optional)', _count),
                text(
                  'event-rule-week-start',
                  'WKST: Monday 1 to Sunday 7',
                  _weekStart,
                ),
                const Text(
                  'Display week numbers remain ISO Monday-first. WKST affects the rule and its week numbers. Existing UNTIL and advanced filters are preserved; edit those through the typed API.',
                ),
              ],
              TextField(
                key: const Key('event-inclusions'),
                controller: _inclusions,
                enabled: !locked,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Inclusion dates/times (one per line)',
                ),
                onChanged: (_) => setState(() {
                  _dirty = true;
                  _datesDirty = true;
                }),
              ),
              TextField(
                key: const Key('event-exclusions'),
                controller: _exclusions,
                enabled: !locked,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Exclusion dates/times (one per line)',
                ),
                onChanged: (_) => setState(() {
                  _dirty = true;
                  _datesDirty = true;
                }),
              ),
              const Text(
                'Pattern edits retain explicit dates. Editing either date list explicitly replaces both lists in the selected timing profile. Exclusions take precedence.',
              ),
              DropdownButtonFormField<cal.CalendarEventTransparency>(
                key: ValueKey('event-transparency-$_transparency'),
                initialValue: _transparency,
                decoration: const InputDecoration(labelText: 'Transparency'),
                items: [
                  for (final t in cal.CalendarEventTransparency.values)
                    DropdownMenuItem(value: t, child: Text(t.name)),
                ],
                onChanged: locked
                    ? null
                    : (v) => setState(() {
                        _transparency = v!;
                        _dirty = true;
                      }),
              ),
              FilledButton(
                key: const Key('event-save'),
                onPressed: locked ? null : _save,
                child: const Text('Save event'),
              ),
            ] else
              const Text(
                'Some fields are withheld. Full editing is unavailable.',
              ),
            if (_view != null)
              TextButton(
                key: const Key('event-descriptive'),
                onPressed: locked || _dirty
                    ? null
                    : () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => EventDescriptiveEditor(
                              client: widget.client,
                              event: _view!,
                            ),
                          ),
                        );
                        if (mounted) {
                          await _run(_reload);
                        }
                      },
                child: const Text('Priority, coordinates and resources'),
              ),
            if (_view != null &&
                _view!.disclosedGroups.toSet().containsAll(
                  cal.CalendarEventFieldGroup.values,
                ))
              TextButton(
                key: const Key('event-scheduling'),
                onPressed: locked || _dirty
                    ? null
                    : () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => EventSchedulingScreen(
                              client: widget.client,
                              event: _view!,
                            ),
                          ),
                        );
                        if (mounted) await _run(_reload);
                      },
                child: const Text('Meeting invitations'),
              ),
            if (_view != null &&
                _view!.disclosedGroups.contains(
                  cal.CalendarEventFieldGroup.timing,
                ))
              TextButton(
                key: const Key('event-preview'),
                onPressed: locked || _dirty
                    ? null
                    : () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => EventOccurrenceScreen(
                              client: widget.client,
                              event: _view!,
                            ),
                          ),
                        );
                        if (mounted) await _run(_reload);
                      },
                child: const Text('Preview saved occurrences'),
              ),
            if (_view != null)
              TextButton(
                key: const Key('event-export'),
                onPressed: locked || _dirty
                    ? null
                    : () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => EventExportScreen(
                            client: widget.client,
                            event: _view!,
                          ),
                        ),
                      ),
                child: const Text('Export event series'),
              ),
            if (_view != null)
              TextButton(
                key: const Key('event-replace'),
                onPressed: locked || _dirty
                    ? null
                    : () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => EventReplaceScreen(
                              client: widget.client,
                              event: _view!,
                            ),
                          ),
                        );
                        if (mounted) await _run(_reload);
                      },
                child: const Text('Replace event source'),
              ),
            if (_view?.status != null) ...[
              Text(
                'Status: ${_view!.status!.name}',
                key: const Key('event-status'),
              ),
              if (_dirty)
                const Text(
                  'Save or reload draft edits before changing status or deleting.',
                ),
              for (final s in cal.CalendarEventStatus.values)
                if (s != _view!.status)
                  TextButton(
                    key: ValueKey('event-status-${s.name}'),
                    onPressed: locked || _dirty ? null : () => _status(s),
                    child: Text('Set ${s.name}'),
                  ),
            ],
            if (_view != null)
              TextButton(
                key: const Key('event-delete'),
                onPressed: locked || _dirty ? null : _delete,
                child: const Text('Delete event'),
              ),
          ],
        ),
      ),
    );
  }
}
