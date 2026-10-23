import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'task_screen.dart' show taskError;
import 'task_progress_label.dart';
import 'task_timing_editor.dart';

class TaskOccurrenceScreen extends StatefulWidget {
  const TaskOccurrenceScreen({
    super.key,
    required this.client,
    required this.task,
  });
  final Client client;
  final cal.CalendarTaskView task;
  @override
  State<TaskOccurrenceScreen> createState() => _TaskOccurrenceScreenState();
}

class _TaskOccurrenceScreenState extends State<TaskOccurrenceScreen> {
  final _from = TextEditingController(),
      _until = TextEditingController(),
      _percentage = TextEditingController(text: '50');
  late cal.CalendarTaskView _task;
  cal.CalendarTaskOccurrencePreview? _preview;
  cal.CalendarEventTiming? _historyOriginal;
  final _history = <cal.CalendarTaskHistoryEntry>[];
  String? _cursor, _error;
  bool _busy = false, _stale = false;
  bool get _date => _task.timing!.kind == cal.CalendarTaskTimeKind.date;
  String _civil(cal.CalendarEventCivil c) =>
      '${c.year.toString().padLeft(4, '0')}-${c.month.toString().padLeft(2, '0')}-${c.day.toString().padLeft(2, '0')}${_date ? '' : 'T${c.hour.toString().padLeft(2, '0')}:${c.minute.toString().padLeft(2, '0')}:${c.second.toString().padLeft(2, '0')}'}';
  @override
  void initState() {
    super.initState();
    _task = widget.task;
    final c = _task.timing!.start!;
    final start = DateTime.utc(c.year, c.month, c.day),
        end = start.add(const Duration(days: 30));
    _from.text = _date
        ? start.toIso8601String().substring(0, 10)
        : start.toIso8601String().replaceFirst('.000Z', 'Z');
    _until.text = _date
        ? end.toIso8601String().substring(0, 10)
        : end.toIso8601String().replaceFirst('.000Z', 'Z');
  }

  @override
  void dispose() {
    _from.dispose();
    _until.dispose();
    _percentage.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() body) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await body();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = taskError(e);
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

  cal.CalendarEventCivil _day(String text) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (m == null) throw const FormatException('Use YYYY-MM-DD date bounds.');
    return cal.CalendarEventCivil(
      year: int.parse(m[1]!),
      month: int.parse(m[2]!),
      day: int.parse(m[3]!),
    );
  }

  DateTime _utc(String text) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$').hasMatch(text)) {
      throw const FormatException('Use whole-second UTC bounds ending in Z.');
    }
    final parsed = DateTime.parse(text);
    if (parsed.toIso8601String().replaceFirst('.000Z', 'Z') != text) {
      throw const FormatException('Invalid UTC date/time.');
    }
    return parsed;
  }

  Future<void> _load() async {
    final result = await widget.client.modules.serverpod_calendar.calendarTask
        .previewOccurrences(
          cal.CalendarTaskOccurrenceQuery(
            taskId: _task.id,
            expectedRevision: _task.revision,
            fromDate: _date ? _day(_from.text) : null,
            untilDate: _date ? _day(_until.text) : null,
            fromUtc: _date ? null : _utc(_from.text),
            untilUtc: _date ? null : _utc(_until.text),
          ),
        );
    if (mounted) {
      setState(() {
        _preview = result;
        _historyOriginal = null;
        _history.clear();
        _cursor = null;
      });
    }
  }

  Future<void> _reload() => _run(() async {
    final fresh = await widget.client.modules.serverpod_calendar.calendarTask
        .getTask(_task.id, cal.CalendarTaskFieldGroup.values);
    if (!fresh.disclosedGroups.toSet().containsAll([
          cal.CalendarTaskFieldGroup.timing,
          cal.CalendarTaskFieldGroup.progress,
        ]) ||
        fresh.recurrence == null) {
      throw const FormatException(
        'The current task is no longer available as a visible recurring series.',
      );
    }
    if (mounted) {
      setState(() {
        _task = fresh;
        _stale = false;
        _preview = null;
        _history.clear();
        _historyOriginal = null;
        _cursor = null;
      });
    }
    await _load();
  });
  Future<void> _change(
    cal.CalendarTaskOccurrence occurrence,
    cal.CalendarTaskProgressAction action,
  ) => _run(() async {
    int? percentage;
    if (action == cal.CalendarTaskProgressAction.setPercentage) {
      if (!RegExp(r'^\d+$').hasMatch(_percentage.text)) {
        throw const FormatException(
          'Use a whole percentage from 0 through 99.',
        );
      }
      percentage = int.parse(_percentage.text);
    }
    final expected = _task.revision;
    await widget.client.modules.serverpod_calendar.calendarTask
        .changeOccurrenceProgress(
          cal.CalendarTaskOccurrenceProgressRequest(
            taskId: _task.id,
            expectedRevision: expected,
            originalStart: occurrence.originalStart,
            action: action,
            percentComplete: percentage,
          ),
        );
    final fresh = await widget.client.modules.serverpod_calendar.calendarTask
        .getTask(_task.id, cal.CalendarTaskFieldGroup.values);
    if (fresh.revision != expected + 1) {
      if (mounted) setState(() => _stale = true);
      throw const FormatException(
        'Another change was observed; reload before editing.',
      );
    }
    _task = fresh;
    await _load();
  });
  Future<void> _editTiming(cal.CalendarTaskOccurrence occurrence) async {
    final replacement = await showDialog<cal.CalendarTaskTiming>(
      context: context,
      builder: (_) =>
          TaskTimingEditor(master: _task.timing!, occurrence: occurrence),
    );
    if (replacement != null && mounted) {
      await _timing(occurrence, replacement);
    }
  }

  Future<void> _timing(
    cal.CalendarTaskOccurrence occurrence,
    cal.CalendarTaskTiming? replacement,
  ) => _run(() async {
    final expected = _task.revision;
    await widget.client.modules.serverpod_calendar.calendarTask
        .changeOccurrenceTiming(
          cal.CalendarTaskOccurrenceTimingRequest(
            taskId: _task.id,
            expectedRevision: expected,
            originalStart: occurrence.originalStart,
            replacement: replacement,
          ),
        );
    final fresh = await widget.client.modules.serverpod_calendar.calendarTask
        .getTask(_task.id, cal.CalendarTaskFieldGroup.values);
    if (fresh.revision != expected + 1) {
      if (mounted) {
        setState(() => _stale = true);
      }
      throw const FormatException(
        'Another change was observed; reload before editing.',
      );
    }
    _task = fresh;
    await _load();
  });
  Future<void> _readHistory(
    cal.CalendarEventTiming original, {
    bool more = false,
  }) => _run(() async {
    final page = await widget.client.modules.serverpod_calendar.calendarTask
        .occurrenceHistory(
          cal.CalendarTaskHistoryQuery(
            taskId: _task.id,
            expectedRevision: _task.revision,
            originalStart: original,
            pageSize: 10,
            cursor: more ? _cursor : null,
          ),
        );
    if (mounted) {
      setState(() {
        if (!more) _history.clear();
        _history.addAll(page.entries);
        _historyOriginal = original;
        _cursor = page.nextCursor;
      });
    }
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Task occurrences')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(_error!, key: const Key('task-occurrence-error')),
          const Text(
            'Progress is independent for each original occurrence. This start-based preview does not book time.',
          ),
          TextField(
            key: const Key('task-preview-from'),
            controller: _from,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: _date ? 'From DATE (included)' : 'From UTC (included)',
            ),
          ),
          TextField(
            key: const Key('task-preview-until'),
            controller: _until,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: _date
                  ? 'Until DATE (excluded)'
                  : 'Until UTC (excluded)',
            ),
          ),
          TextButton(
            key: const Key('task-preview-load'),
            onPressed: _busy || _stale ? null : () => _run(_load),
            child: const Text('Preview occurrences'),
          ),
          TextButton(
            key: const Key('task-preview-reload'),
            onPressed: _busy ? null : _reload,
            child: const Text('Reload current series'),
          ),
          TextField(
            key: const Key('task-occurrence-percentage'),
            controller: _percentage,
            enabled: !_busy && !_stale,
            decoration: const InputDecoration(
              labelText: 'Percentage for set-progress action (0–99)',
            ),
          ),
          for (var i = 0; i < (_preview?.occurrences.length ?? 0); i++) ...[
            Text(
              'Original: ${_civil(_preview!.occurrences[i].originalStart.start)}',
            ),
            Text(
              taskProgressLabel(_preview!.occurrences[i].progress),
              key: ValueKey('task-occurrence-state-$i'),
            ),
            Text(
              'Actual start: ${_civil((_preview!.occurrences[i].actualStart ?? _preview!.occurrences[i].originalStart).start)}',
              key: ValueKey('task-occurrence-actual-$i'),
            ),
            if (_preview!.occurrences[i].dueDate != null)
              Text('Due: ${_civil(_preview!.occurrences[i].dueDate!)}'),
            if (_preview!.occurrences[i].dueUtc != null)
              Text('Due UTC: ${_preview!.occurrences[i].dueUtc}'),
            Wrap(
              children: [
                TextButton(
                  key: ValueKey('task-occurrence-$i-timing'),
                  onPressed: _busy || _stale
                      ? null
                      : () => _editTiming(_preview!.occurrences[i]),
                  child: const Text('Move/resize'),
                ),
                if (_preview!.occurrences[i].replacementTiming != null)
                  TextButton(
                    key: ValueKey('task-occurrence-$i-clear-timing'),
                    onPressed: _busy || _stale
                        ? null
                        : () => _timing(_preview!.occurrences[i], null),
                    child: const Text('Follow series timing'),
                  ),
                for (final a in cal.CalendarTaskProgressAction.values)
                  TextButton(
                    key: ValueKey('task-occurrence-$i-${a.name}'),
                    onPressed: _busy || _stale
                        ? null
                        : () => _change(_preview!.occurrences[i], a),
                    child: Text(a.name),
                  ),
                TextButton(
                  key: ValueKey('task-occurrence-$i-history'),
                  onPressed: _busy || _stale
                      ? null
                      : () => _readHistory(
                          _preview!.occurrences[i].originalStart,
                        ),
                  child: const Text('History'),
                ),
              ],
            ),
          ],
          if (_historyOriginal != null) ...[
            Text('History for ${_civil(_historyOriginal!.start)}'),
            for (final h in _history)
              Text(
                '${h.action.name}: ${taskProgressLabel(h.before)} → ${taskProgressLabel(h.after)}; recorded ${h.recordedAt.toIso8601String()}',
                key: ValueKey('task-history-${h.revision}'),
              ),
            if (_history.isEmpty)
              const Text('No recorded progress transitions.'),
            if (_cursor != null)
              TextButton(
                key: const Key('task-history-more'),
                onPressed: _busy || _stale
                    ? null
                    : () => _readHistory(_historyOriginal!, more: true),
                child: const Text('More history'),
              ),
          ],
        ],
      ),
    ),
  );
}
