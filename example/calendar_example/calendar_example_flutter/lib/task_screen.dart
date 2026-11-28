import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    super.key,
    required this.client,
    required this.calendarId,
    required this.initialZone,
  });
  final Client client;
  final cal.UuidValue calendarId;
  final String initialZone;
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

String taskTitle(String? value) =>
    value == null || value.trim().isEmpty ? 'Untitled task' : value;
String taskError(Object e) => e is cal.CalendarException
    ? e.message
    : e is FormatException
    ? e.message
    : 'Task request failed.';

class _TaskScreenState extends State<TaskScreen> {
  final _tasks = <cal.CalendarTaskView>[];
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
      final page = await widget.client.modules.serverpod_calendar.calendarTask
          .list(
            widget.calendarId,
            pageSize: 25,
            fieldGroups: cal.CalendarTaskFieldGroup.values,
            cursor: more ? _cursor : null,
          );
      if (mounted) {
        setState(() {
          if (!more) _tasks.clear();
          _tasks.addAll(page.tasks);
          _cursor = page.nextCursor;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = taskError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open([cal.CalendarTaskView? task]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TaskEditor(
          client: widget.client,
          calendarId: widget.calendarId,
          initialZone: widget.initialZone,
          task: task,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Tasks'),
      actions: [
        IconButton(
          key: const Key('tasks-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('task-create'),
      onPressed: _busy ? null : () => _open(),
      icon: const Icon(Icons.add),
      label: const Text('New task'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        const Text(
          'Task dates and assignments do not reserve calendar time. Recurring tasks follow in a separate increment.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('task-error')),
        if (!_busy && _tasks.isEmpty && _error == null)
          const Text('No visible tasks.'),
        for (final task in _tasks)
          ListTile(
            key: ValueKey('task-${task.id}'),
            title: Text(
              task.disclosedGroups.contains(cal.CalendarTaskFieldGroup.summary)
                  ? taskTitle(task.summary)
                  : 'Task',
            ),
            subtitle: task.progress == null
                ? null
                : Text(
                    '${task.progress!.status.name}: ${task.progress!.percentComplete}%',
                  ),
            onTap: _busy ? null : () => _open(task),
          ),
        if (_cursor != null)
          TextButton(
            key: const Key('tasks-more'),
            onPressed: _busy ? null : () => _load(more: true),
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}

class TaskEditor extends StatefulWidget {
  const TaskEditor({
    super.key,
    required this.client,
    required this.calendarId,
    required this.initialZone,
    this.task,
  });
  final Client client;
  final cal.UuidValue calendarId;
  final String initialZone;
  final cal.CalendarTaskView? task;
  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final _summary = TextEditingController(),
      _description = TextEditingController(),
      _location = TextEditingController(),
      _start = TextEditingController(),
      _due = TextEditingController(),
      _zone = TextEditingController(),
      _priority = TextEditingController(),
      _percent = TextEditingController();
  final _duration = List.generate(5, (_) => TextEditingController());
  cal.CalendarTaskView? _view;
  cal.CalendarTaskTimeKind _kind = cal.CalendarTaskTimeKind.undated;
  bool _durationForm = false, _busy = false, _stale = false, _dirty = false;
  String? _error;
  bool get _locked => _busy || _stale;
  bool get _editable =>
      _view == null ||
      [
        cal.CalendarTaskFieldGroup.summary,
        cal.CalendarTaskFieldGroup.description,
        cal.CalendarTaskFieldGroup.location,
        cal.CalendarTaskFieldGroup.timing,
        cal.CalendarTaskFieldGroup.priority,
      ].every(_view!.disclosedGroups.contains);
  @override
  void initState() {
    super.initState();
    _view = widget.task;
    _reset();
  }

  String _format(cal.CalendarEventCivil c) =>
      '${c.year.toString().padLeft(4, '0')}-${c.month.toString().padLeft(2, '0')}-${c.day.toString().padLeft(2, '0')}${_kind == cal.CalendarTaskTimeKind.date ? '' : 'T${c.hour.toString().padLeft(2, '0')}:${c.minute.toString().padLeft(2, '0')}:${c.second.toString().padLeft(2, '0')}'}';
  void _reset() {
    final t = _view?.timing;
    _kind = t?.kind ?? cal.CalendarTaskTimeKind.undated;
    _summary.text = _view?.summary ?? '';
    _description.text = _view?.description ?? '';
    _location.text = _view?.location ?? '';
    _priority.text = _view?.priority?.toString() ?? '';
    _start.text = t?.start == null ? '' : _format(t!.start!);
    _due.text = t?.due == null ? '' : _format(t!.due!);
    _zone.text = t?.zoneId ?? widget.initialZone;
    final d = t?.duration;
    _durationForm = d != null;
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
    _percent.text = (_view?.progress?.percentComplete ?? 0).toString();
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
      _due,
      _zone,
      _priority,
      _percent,
      ..._duration,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
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

  Future<void> _reload({int? expected}) async {
    final fresh = await widget.client.modules.serverpod_calendar.calendarTask
        .getTask(_view!.id, cal.CalendarTaskFieldGroup.values);
    if (mounted) {
      setState(() {
        if (expected != null && fresh.revision != expected) {
          _stale = true;
          _error = 'Another change was observed. Reload before editing.';
        } else {
          _view = fresh;
          _reset();
        }
      });
    }
  }

  cal.CalendarEventCivil? _civil(String text) {
    if (text.isEmpty) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2}))?$')
        .firstMatch(text);
    if (m == null ||
        (_kind == cal.CalendarTaskTimeKind.date
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

  int _number(String text) {
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      throw const FormatException('Use whole nonnegative numbers.');
    }
    return int.parse(text);
  }

  cal.CalendarTaskContent _content() {
    final units = [
      for (final c in _duration)
        _durationForm && _kind != cal.CalendarTaskTimeKind.undated
            ? _number(c.text)
            : 0,
    ];
    return cal.CalendarTaskContent(
      summary: _summary.text.isEmpty ? null : _summary.text,
      description: _description.text.isEmpty ? null : _description.text,
      location: _location.text.isEmpty ? null : _location.text,
      priority: _priority.text.isEmpty ? null : _number(_priority.text),
      timing: cal.CalendarTaskTiming(
        kind: _kind,
        start: _kind == cal.CalendarTaskTimeKind.undated
            ? null
            : _civil(_start.text),
        due: _kind == cal.CalendarTaskTimeKind.undated || _durationForm
            ? null
            : _civil(_due.text),
        duration: _kind == cal.CalendarTaskTimeKind.undated || !_durationForm
            ? null
            : cal.CalendarEventDuration(
                weeks: units[0],
                days: units[1],
                hours: units[2],
                minutes: units[3],
                seconds: units[4],
              ),
        zoneId: _kind == cal.CalendarTaskTimeKind.zoned ? _zone.text : null,
      ),
    );
  }

  Future<void> _save() => _run(() async {
    final api = widget.client.modules.serverpod_calendar.calendarTask;
    if (_view == null) {
      await api.create(
        cal.CalendarTaskCreateRequest(
          calendarId: widget.calendarId,
          content: _content(),
          assignees: [],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } else {
      final expected = _view!.revision;
      await api.update(
        cal.CalendarTaskUpdateRequest(
          taskId: _view!.id,
          expectedRevision: expected,
          content: _content(),
        ),
      );
      await _reload(expected: expected + 1);
    }
  });
  Future<void> _progress(
    cal.CalendarTaskProgressAction action,
  ) => _run(() async {
    final expected = _view!.revision;
    await widget.client.modules.serverpod_calendar.calendarTask.changeProgress(
      cal.CalendarTaskProgressRequest(
        taskId: _view!.id,
        expectedRevision: expected,
        action: action,
        percentComplete: action == cal.CalendarTaskProgressAction.setPercentage
            ? _number(_percent.text)
            : null,
      ),
    );
    await _reload(expected: expected + 1);
  });
  Future<void> _assign(bool me) => _run(() async {
    final expected = _view!.revision;
    final principal = me ? await widget.client.smoke.whoAmI() : null;
    await widget.client.modules.serverpod_calendar.calendarTask
        .changeAssignments(
          cal.CalendarTaskAssignmentsRequest(
            taskId: _view!.id,
            expectedRevision: expected,
            assignees: principal == null
                ? []
                : [
                    cal.CalendarTaskAssignee(
                      namespace: 'demo',
                      kind: 'user',
                      externalId: principal,
                    ),
                  ],
          ),
        );
    await _reload(expected: expected + 1);
  });
  Future<void> _delete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text(
          'Active task content, progress and assignments will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            key: const Key('task-confirm-delete'),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true) {
      await _run(() async {
        await widget.client.modules.serverpod_calendar.calendarTask.deleteTask(
          _view!.id,
          _view!.revision,
        );
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget field(
      String key,
      String label,
      TextEditingController c, {
      int lines = 1,
    }) => TextField(
      key: Key(key),
      controller: c,
      enabled: !_locked,
      maxLines: lines,
      onChanged: (_) => setState(() => _dirty = true),
      decoration: InputDecoration(labelText: label),
    );
    return Scaffold(
      appBar: AppBar(title: Text(_view == null ? 'New task' : 'Edit task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_busy) const LinearProgressIndicator(),
            if (_error != null) Text(_error!, key: const Key('task-error')),
            if (_view != null)
              TextButton(
                key: const Key('task-reload'),
                onPressed: _busy ? null : () => _run(_reload),
                child: const Text('Reload saved values'),
              ),
            if (_editable) ...[
              field('task-summary', 'Summary (optional)', _summary),
              field('task-description', 'Description', _description, lines: 3),
              field('task-location', 'Location', _location),
              field('task-priority', 'Priority (0–9, optional)', _priority),
              DropdownButtonFormField<cal.CalendarTaskTimeKind>(
                key: ValueKey('task-kind-$_kind'),
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Time meaning'),
                items: [
                  for (final k in cal.CalendarTaskTimeKind.values)
                    DropdownMenuItem(value: k, child: Text(k.name)),
                ],
                onChanged: _locked
                    ? null
                    : (v) => setState(() {
                        _kind = v!;
                        _dirty = true;
                      }),
              ),
              if (_kind != cal.CalendarTaskTimeKind.undated) ...[
                field('task-start', 'Start (optional)', _start),
                if (_kind == cal.CalendarTaskTimeKind.zoned)
                  field('task-zone', 'Named time zone', _zone),
                SwitchListTile(
                  key: const Key('task-duration-form'),
                  title: const Text('Use duration from start instead of due'),
                  value: _durationForm,
                  onChanged: _locked
                      ? null
                      : (v) => setState(() {
                          _durationForm = v;
                          _dirty = true;
                        }),
                ),
                if (!_durationForm) field('task-due', 'Due (optional)', _due),
                if (_durationForm)
                  for (var i = 0; i < 5; i++)
                    field(
                      'task-duration-$i',
                      ['Weeks', 'Days', 'Hours', 'Minutes', 'Seconds'][i],
                      _duration[i],
                    ),
                const Text(
                  'Dates use YYYY-MM-DD; times use YYYY-MM-DDTHH:MM:SS. A due time is never inferred.',
                ),
              ],
              FilledButton(
                key: const Key('task-save'),
                onPressed: _locked ? null : _save,
                child: const Text('Save task'),
              ),
            ] else
              const Text(
                'Some content is withheld. Full content editing is unavailable.',
              ),
            if (_view?.progress != null) ...[
              Text(
                'Status: ${_view!.progress!.status.name}; ${_view!.progress!.percentComplete}%',
                key: const Key('task-progress-state'),
              ),
              if (_view!.progress!.completedAt != null)
                Text(
                  'Completed: ${_view!.progress!.completedAt!.toIso8601String()}',
                ),
              TextField(
                key: const Key('task-percentage'),
                controller: _percent,
                enabled: !_locked && !_dirty,
                decoration: const InputDecoration(labelText: 'Progress (0–99)'),
              ),
              for (final action in cal.CalendarTaskProgressAction.values)
                TextButton(
                  key: ValueKey('task-progress-${action.name}'),
                  onPressed: _locked || _dirty ? null : () => _progress(action),
                  child: Text(switch (action) {
                    cal.CalendarTaskProgressAction.setPercentage =>
                      'Set progress',
                    cal.CalendarTaskProgressAction.complete => 'Complete',
                    cal.CalendarTaskProgressAction.reopen => 'Reopen at 0%',
                    cal.CalendarTaskProgressAction.cancel => 'Cancel task',
                  }),
                ),
            ],
            if (_view?.assignees != null) ...[
              Text(
                '${_view!.assignees!.length} assignee(s)',
                key: const Key('task-assignees'),
              ),
              TextButton(
                key: const Key('task-assign-me'),
                onPressed: _locked || _dirty ? null : () => _assign(true),
                child: const Text('Assign to me'),
              ),
              TextButton(
                key: const Key('task-clear-assignees'),
                onPressed: _locked || _dirty ? null : () => _assign(false),
                child: const Text('Clear assignments'),
              ),
            ],
            if (_view?.protocolUid != null)
              SelectableText('Task UID: ${_view!.protocolUid}'),
            if (_dirty)
              const Text(
                'Save or reload content before changing progress, assignments or deleting.',
              ),
            if (_view != null)
              TextButton(
                key: const Key('task-delete'),
                onPressed: _locked || _dirty ? null : _delete,
                child: const Text('Delete task'),
              ),
          ],
        ),
      ),
    );
  }
}
