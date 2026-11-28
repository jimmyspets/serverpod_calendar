import 'package:flutter/material.dart';

import 'personal_alarm_activity_screen.dart';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class PersonalAlarmScreen extends StatefulWidget {
  const PersonalAlarmScreen({
    super.key,
    required this.client,
    required this.parent,
    required this.initialZone,
  });
  final Client client;
  final cal.CalendarAlarmParent parent;
  final String initialZone;
  @override
  State<PersonalAlarmScreen> createState() => _PersonalAlarmScreenState();
}

class _PersonalAlarmScreenState extends State<PersonalAlarmScreen> {
  List<cal.CalendarAlarmView> _alarms = [];
  bool _busy = true;
  cal.CalendarAlarmSourceTimings? _source;
  late final TextEditingController _sourceZone;
  String? _error;
  @override
  void initState() {
    super.initState();
    _sourceZone = TextEditingController(text: widget.initialZone);
    _load();
  }

  @override
  void dispose() {
    _sourceZone.dispose();
    super.dispose();
  }

  String? get _zone =>
      _sourceZone.text.trim().isEmpty ? null : _sourceZone.text.trim();
  Future<void> _reviewSource() async {
    setState(() {
      _busy = true;
      _error = null;
      _source = null;
    });
    try {
      final source = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarAlarm
          .sourceTimings(widget.parent, _zone);
      if (mounted) setState(() => _source = source);
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _adopt(int index) async {
    final source = _source;
    if (source == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.modules.serverpod_calendar.calendarAlarm.adopt(
        widget.parent,
        source.parentRevision,
        index,
        _zone,
      );
      if (mounted) await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final values = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarAlarm
          .list(widget.parent);
      if (mounted) setState(() => _alarms = values);
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit([cal.CalendarAlarmView? alarm]) async {
    final definition = await Navigator.of(context)
        .push<cal.CalendarAlarmDefinition>(
          MaterialPageRoute(
            builder: (_) => PersonalAlarmEditor(
              initialZone: widget.initialZone,
              definition: alarm?.definition,
            ),
          ),
        );
    if (!mounted || definition == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = widget.client.modules.serverpod_calendar.calendarAlarm;
      if (alarm == null) {
        await api.create(
          cal.CalendarAlarmCreateRequest(
            parent: widget.parent,
            definition: definition,
          ),
        );
      } else {
        await api.update(
          cal.CalendarAlarmUpdateRequest(
            parent: widget.parent,
            alarmId: alarm.id,
            expectedRevision: alarm.revision,
            definition: definition,
          ),
        );
      }
      if (mounted) await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setArmed(cal.CalendarAlarmView alarm) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.modules.serverpod_calendar.calendarAlarm.setArmed(
        widget.parent,
        alarm.id,
        alarm.revision,
        !alarm.armed,
      );
      if (mounted) await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(cal.CalendarAlarmView alarm) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.modules.serverpod_calendar.calendarAlarm.delete(
        widget.parent,
        alarm.id,
        alarm.revision,
      );
      if (mounted) await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Personal alarms'),
      actions: [
        IconButton(
          key: const Key('alarms-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh personal alarms',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('alarm-create'),
      onPressed: _busy || _alarms.length >= 16 ? null : () => _edit(),
      icon: const Icon(Icons.add_alarm),
      label: const Text('Add alarm'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        const Text(
          'Private timing definitions for your current host recipient. '
          'Save first, then explicitly arm to request planning. '
          'Live reminder text comes from the current authorized item. '
          'Copying imported timing does not copy source text, acknowledgement or snooze state.',
        ),
        TextField(
          controller: _sourceZone,
          key: const Key('alarm-source-zone'),
          enabled: !_busy,
          decoration: const InputDecoration(
            labelText: 'Zone for imported DATE-relative timing',
          ),
          onChanged: (_) => setState(() => _source = null),
        ),
        OutlinedButton(
          key: const Key('alarm-source-review'),
          onPressed: _busy ? null : _reviewSource,
          child: const Text('Review imported alarm timing'),
        ),
        if (_source != null) ...[
          Text(
            'Source revision ${_source!.parentRevision}. Copies remain unarmed.',
          ),
          if (_source!.definitions.isEmpty)
            const Text('No imported master alarm timing.'),
          for (var i = 0; i < _source!.definitions.length; i++)
            ListTile(
              title: Text(_label(_source!.definitions[i])),
              subtitle: Text(_sourceRepeats(_source!.definitions[i])),
              trailing: TextButton(
                key: Key('alarm-source-adopt-$i'),
                onPressed: _busy || _alarms.length >= 16
                    ? null
                    : () => _adopt(i),
                child: const Text('Copy as unarmed'),
              ),
            ),
        ],
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('alarm-error')),
        if (!_busy && _alarms.isEmpty)
          const Text('No personal alarm definitions.'),
        for (final alarm in _alarms)
          ListTile(
            key: ValueKey('alarm-${alarm.id}'),
            title: Text(_label(alarm.definition)),
            subtitle: Text(
              !alarm.anchorCompatible
                  ? 'Needs attention: current master anchor unavailable'
                  : !alarm.armed
                  ? 'Unarmed: current master anchor available'
                  : 'Armed: ${alarm.planningStatus?.name ?? "pending"}',
            ),
            onTap: _busy ? null : () => _edit(alarm),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Personal alarm activity',
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => PersonalAlarmActivityScreen(
                              client: widget.client,
                              alarm: alarm,
                            ),
                          ),
                        ),
                ),
                IconButton(
                  icon: Icon(alarm.armed ? Icons.alarm_off : Icons.alarm_on),
                  tooltip: alarm.armed
                      ? 'Disarm personal alarm'
                      : 'Arm personal alarm',
                  onPressed: _busy ? null : () => _setArmed(alarm),
                ),
                IconButton(
                  key: ValueKey('alarm-delete-${alarm.id}'),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete personal alarm',
                  onPressed: _busy ? null : () => _delete(alarm),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

String _sourceRepeats(cal.CalendarAlarmDefinition d) {
  if (d.repeat == null) return 'No automatic repeats';
  final v = d.repeatInterval!;
  return '${d.repeat} repeats every ${v.weeks}w ${v.days}d ${v.hours}h ${v.minutes}m ${v.seconds}s';
}

String _message(Object e) =>
    e is cal.CalendarException ? e.message : 'Alarm request failed.';
String _label(cal.CalendarAlarmDefinition d) {
  if (d.absoluteUtc != null) {
    return 'Absolute item anchor: ${d.absoluteUtc!.toIso8601String()}';
  }
  final v = d.relativeDuration!;
  return '${v.sign < 0 ? "Before" : "After"} ${d.anchor!.name}: '
      '${v.weeks}w ${v.days}d ${v.hours}h ${v.minutes}m ${v.seconds}s per occurrence';
}

class PersonalAlarmEditor extends StatefulWidget {
  const PersonalAlarmEditor({
    super.key,
    required this.initialZone,
    this.definition,
  });
  final String initialZone;
  final cal.CalendarAlarmDefinition? definition;
  @override
  State<PersonalAlarmEditor> createState() => _PersonalAlarmEditorState();
}

class _PersonalAlarmEditorState extends State<PersonalAlarmEditor> {
  final _absolute = TextEditingController(),
      _zone = TextEditingController(),
      _repeat = TextEditingController();
  final _offset = List.generate(5, (_) => TextEditingController());
  final _interval = List.generate(5, (_) => TextEditingController());
  bool _relative = true, _before = true;
  cal.CalendarAlarmAnchor _anchor = cal.CalendarAlarmAnchor.start;
  String? _error;
  @override
  void initState() {
    super.initState();
    final d = widget.definition;
    _relative = d?.absoluteUtc == null;
    _absolute.text =
        d?.absoluteUtc?.toIso8601String().replaceFirst('.000Z', 'Z') ??
        '2026-10-25T12:00:00Z';
    _zone.text = d?.dateZoneId ?? widget.initialZone;
    _anchor = d?.anchor ?? cal.CalendarAlarmAnchor.start;
    _before = (d?.relativeDuration?.sign ?? -1) < 0;
    _repeat.text = d?.repeat?.toString() ?? '';
    void fill(
      List<TextEditingController> fields,
      cal.CalendarAlarmDuration? v, {
      int minutes = 0,
    }) {
      final values = [
        v?.weeks ?? 0,
        v?.days ?? 0,
        v?.hours ?? 0,
        v?.minutes ?? minutes,
        v?.seconds ?? 0,
      ];
      for (var i = 0; i < 5; i++) {
        fields[i].text = '${values[i]}';
      }
    }

    fill(_offset, d?.relativeDuration, minutes: 5);
    fill(_interval, d?.repeatInterval);
  }

  @override
  void dispose() {
    for (final c in [_absolute, _zone, _repeat, ..._offset, ..._interval]) {
      c.dispose();
    }
    super.dispose();
  }

  cal.CalendarAlarmDuration _duration(
    List<TextEditingController> fields, {
    int sign = 1,
  }) {
    final values = fields.map((c) => int.parse(c.text)).toList();
    if (values.any((v) => v < 0)) {
      throw const FormatException('Units must be nonnegative.');
    }
    return cal.CalendarAlarmDuration(
      sign: sign,
      weeks: values[0],
      days: values[1],
      hours: values[2],
      minutes: values[3],
      seconds: values[4],
    );
  }

  void _save() {
    try {
      DateTime? absolute;
      if (!_relative) {
        final text = _absolute.text;
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$').hasMatch(text)) {
          throw const FormatException(
            'Use whole-second UTC: YYYY-MM-DDTHH:MM:SSZ.',
          );
        }
        absolute = DateTime.parse(text);
        if (absolute.toIso8601String().replaceFirst('.000Z', 'Z') != text) {
          throw const FormatException('Invalid UTC date/time.');
        }
      }
      final repeat = _repeat.text.isEmpty ? null : int.parse(_repeat.text);
      if (repeat == null && _interval.any((c) => c.text != '0')) {
        throw const FormatException(
          'Supply a repeat count or clear interval units.',
        );
      }
      Navigator.of(context).pop(
        cal.CalendarAlarmDefinition(
          absoluteUtc: absolute,
          relativeDuration: _relative
              ? _duration(_offset, sign: _before ? -1 : 1)
              : null,
          anchor: _relative ? _anchor : null,
          dateZoneId: _relative && _zone.text.isNotEmpty ? _zone.text : null,
          repeat: repeat,
          repeatInterval: repeat == null ? null : _duration(_interval),
        ),
      );
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Widget _units(String prefix, List<TextEditingController> fields) => Wrap(
    spacing: 12,
    children: [
      for (var i = 0; i < 5; i++)
        SizedBox(
          width: 100,
          child: TextField(
            key: ValueKey('alarm-$prefix-$i'),
            controller: fields[i],
            decoration: InputDecoration(
              labelText: ['Weeks', 'Days', 'Hours', 'Minutes', 'Seconds'][i],
            ),
            keyboardType: TextInputType.number,
          ),
        ),
    ],
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alarm timing definition')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Save an unarmed definition. This does not schedule or send a notification.',
        ),
        SwitchListTile(
          key: const Key('alarm-relative'),
          title: const Text('Relative to each occurrence'),
          subtitle: const Text(
            'Off: one absolute UTC anchor for the whole item, plus optional repeats.',
          ),
          value: _relative,
          onChanged: (v) => setState(() => _relative = v),
        ),
        if (_relative) ...[
          DropdownButton<cal.CalendarAlarmAnchor>(
            key: const Key('alarm-anchor'),
            value: _anchor,
            items: [
              for (final a in cal.CalendarAlarmAnchor.values)
                DropdownMenuItem(
                  value: a,
                  child: Text(a.name == 'end' ? 'Explicit end / due' : 'Start'),
                ),
            ],
            onChanged: (v) => setState(() => _anchor = v!),
          ),
          SwitchListTile(
            key: const Key('alarm-before'),
            title: const Text('Before anchor'),
            value: _before,
            onChanged: (v) => setState(() => _before = v),
          ),
          _units('offset', _offset),
          TextField(
            key: const Key('alarm-date-zone'),
            controller: _zone,
            decoration: const InputDecoration(
              labelText: 'Explicit DATE midnight zone',
              helperText: 'Required for DATE anchors. Retained but unused for timed anchors.',
            ),
          ),
          const Text(
            'Weeks/days use calendar units before elapsed clock units across DST.',
          ),
        ] else
          TextField(
            key: const Key('alarm-absolute'),
            controller: _absolute,
            decoration: const InputDecoration(
              labelText: 'Absolute UTC (YYYY-MM-DDTHH:MM:SSZ)',
            ),
          ),
        TextField(
          key: const Key('alarm-repeat'),
          controller: _repeat,
          decoration: const InputDecoration(
            labelText: 'Additional repeats (optional, 0–100)',
          ),
          keyboardType: TextInputType.number,
        ),
        _units('interval', _interval),
        const Text(
          'A repeat needs a positive interval. Offset and repeat span are capped at 366 days.',
        ),
        if (_error != null) Text(_error!, key: const Key('alarm-editor-error')),
        FilledButton(
          key: const Key('alarm-save'),
          onPressed: _save,
          child: const Text('Save unarmed definition'),
        ),
      ],
    ),
  );
}
