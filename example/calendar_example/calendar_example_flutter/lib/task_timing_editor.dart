import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class TaskTimingEditor extends StatefulWidget {
  const TaskTimingEditor({
    super.key,
    required this.master,
    required this.occurrence,
  });
  final cal.CalendarTaskTiming master;
  final cal.CalendarTaskOccurrence occurrence;
  @override
  State<TaskTimingEditor> createState() => _TaskTimingEditorState();
}

class _TaskTimingEditorState extends State<TaskTimingEditor> {
  final _start = TextEditingController(), _due = TextEditingController();
  final _units = List.generate(5, (_) => TextEditingController(text: '0'));
  String _form = 'startOnly';
  String? _error;
  bool get _date => widget.master.kind == cal.CalendarTaskTimeKind.date;
  String _format(cal.CalendarEventCivil c) =>
      '${c.year.toString().padLeft(4, '0')}-${c.month.toString().padLeft(2, '0')}-${c.day.toString().padLeft(2, '0')}${_date ? '' : 'T${c.hour.toString().padLeft(2, '0')}:${c.minute.toString().padLeft(2, '0')}:${c.second.toString().padLeft(2, '0')}'}';
  @override
  void initState() {
    super.initState();
    final t = widget.occurrence.replacementTiming ?? widget.master;
    _start.text = _format(
      widget.occurrence.actualStart?.start ??
          widget.occurrence.originalStart.start,
    );
    if (t.duration != null) {
      _form = 'duration';
      final d = t.duration!;
      final n = [d.weeks, d.days, d.hours, d.minutes, d.seconds];
      for (var i = 0; i < 5; i++) {
        _units[i].text = '${n[i]}';
      }
    } else if (t.due != null) {
      _form = 'due';
      final due =
          widget.occurrence.replacementTiming?.due ?? widget.occurrence.dueDate;
      if (due != null) {
        _due.text = _format(due);
      } else if (widget.master.kind == cal.CalendarTaskTimeKind.utc &&
          widget.occurrence.dueUtc != null) {
        final d = widget.occurrence.dueUtc!;
        _due.text = _format(
          cal.CalendarEventCivil(
            year: d.year,
            month: d.month,
            day: d.day,
            hour: d.hour,
            minute: d.minute,
            second: d.second,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _start.dispose();
    _due.dispose();
    for (final c in _units) {
      c.dispose();
    }
    super.dispose();
  }

  cal.CalendarEventCivil _parse(String text) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2}))?$')
        .firstMatch(text);
    if (m == null || (_date ? m[4] != null : m[4] == null)) {
      throw const FormatException(
        'Use YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS for this profile.',
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

  void _save() {
    try {
      final n = [
        for (final c in _units)
          if (_form == 'duration') int.parse(c.text) else 0,
      ];
      Navigator.of(context).pop(
        cal.CalendarTaskTiming(
          kind: widget.master.kind,
          zoneId: widget.master.zoneId,
          start: _parse(_start.text),
          due: _form == 'due' ? _parse(_due.text) : null,
          duration: _form == 'duration'
              ? cal.CalendarEventDuration(
                  weeks: n[0],
                  days: n[1],
                  hours: n[2],
                  minutes: n[3],
                  seconds: n[4],
                )
              : null,
        ),
      );
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Move or resize this task occurrence'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Original identity, progress and completion history are preserved. This replaces the complete timing for one occurrence.',
          ),
          if (_error != null)
            Text(_error!, key: const Key('task-timing-input-error')),
          TextField(
            key: const Key('task-timing-start'),
            controller: _start,
            decoration: InputDecoration(
              labelText: _date
                  ? 'Start DATE'
                  : 'Start civil time (${widget.master.zoneId ?? 'UTC'})',
            ),
          ),
          DropdownButton<String>(
            key: const Key('task-timing-form'),
            value: _form,
            items: const [
              DropdownMenuItem(value: 'startOnly', child: Text('No deadline')),
              DropdownMenuItem(value: 'due', child: Text('Explicit deadline')),
              DropdownMenuItem(value: 'duration', child: Text('Duration')),
            ],
            onChanged: (v) => setState(() => _form = v!),
          ),
          if (_form == 'due')
            TextField(
              key: const Key('task-timing-due'),
              controller: _due,
              decoration: const InputDecoration(
                labelText: 'Deadline in the same date/time profile',
              ),
            ),
          if (_form == 'duration')
            for (var i = 0; i < 5; i++)
              TextField(
                key: ValueKey('task-timing-unit-$i'),
                controller: _units[i],
                decoration: InputDecoration(
                  labelText: const [
                    'Weeks',
                    'Days',
                    'Hours',
                    'Minutes',
                    'Seconds',
                  ][i],
                ),
              ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('task-timing-save'),
        onPressed: _save,
        child: const Text('Save timing'),
      ),
    ],
  );
}
