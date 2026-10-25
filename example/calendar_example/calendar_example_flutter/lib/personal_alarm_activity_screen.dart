import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class PersonalAlarmActivityScreen extends StatefulWidget {
  const PersonalAlarmActivityScreen({
    super.key,
    required this.client,
    required this.alarm,
  });
  final Client client;
  final cal.CalendarAlarmView alarm;
  @override
  State<PersonalAlarmActivityScreen> createState() =>
      _PersonalAlarmActivityScreenState();
}

class _PersonalAlarmActivityScreenState
    extends State<PersonalAlarmActivityScreen> {
  var _kind = cal.CalendarAlarmActivityKind.firings;
  final _firings = <cal.CalendarAlarmFiringView>[];
  final _actions = <cal.CalendarAlarmActionView>[];
  String? _cursor, _error;
  bool _busy = false;
  late cal.CalendarAlarmView _alarm;
  @override
  void initState() {
    super.initState();
    _alarm = widget.alarm;
    _load();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = widget.client.modules.serverpod_calendar.calendarAlarm;
      final alarm = (await api.list(_alarm.parent))
          .firstWhere((a) => a.id == _alarm.id);
      final page = await api.activity(
        _alarm.parent,
        _alarm.id,
        _kind,
        20,
        more ? _cursor : null,
      );
      if (!mounted) return;
      setState(() {
        _alarm = alarm;
        if (!more) {
          _firings.clear();
          _actions.clear();
        }
        _firings.addAll(page.firings);
        _actions.addAll(page.actions);
        _cursor = page.nextCursor;
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is cal.CalendarException
              ? e.message
              : 'Activity request failed. Refresh to retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _act(
    cal.CalendarAlarmActionKind kind, {
    cal.CalendarAlarmFiringView? firing,
    cal.CalendarAlarmActionView? action,
  }) async {
    DateTime? snooze;
    if (kind == cal.CalendarAlarmActionKind.snooze) {
      final field = TextEditingController(
        text: DateTime.fromMillisecondsSinceEpoch(
          (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + 600) * 1000,
          isUtc: true,
        ).toIso8601String(),
      );
      final value = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Snooze until UTC'),
          content: TextField(
            controller: field,
            key: const Key('alarm-snooze-utc'),
            decoration: const InputDecoration(
              labelText: 'Future UTC instant, at most seven days',
              helperText: 'Example: 2026-10-25T12:30:00Z',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('alarm-snooze-confirm'),
              onPressed: () => Navigator.pop(context, field.text),
              child: const Text('Snooze'),
            ),
          ],
        ),
      );
      field.dispose();
      if (!mounted || value == null) return;
      snooze = DateTime.tryParse(value);
      if (snooze == null || !snooze.isUtc) {
        setState(() => _error = 'Enter a UTC instant ending in Z.');
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.modules.serverpod_calendar.calendarAlarm.act(
        cal.CalendarAlarmActionRequest(
          parent: _alarm.parent,
          alarmId: _alarm.id,
          expectedAlarmRevision: _alarm.revision,
          expectedActionRevision:
              action?.revision ?? firing?.action?.revision ?? 0,
          kind: kind,
          firingId: firing?.id,
          actionId: action?.id,
          snoozeAt: snooze,
        ),
      );
      if (mounted) await _load();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is cal.CalendarException
              ? e.message
              : 'Action failed. Refresh before retrying.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Personal alarm activity'),
      actions: [
        IconButton(
          key: const Key('alarm-activity-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh activity',
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Acceptance is transport acceptance, not display or acknowledgement. '
          'Delivery is not connected in this example. Activity uses live pages in ID order; '
          'refresh to include concurrent changes. Reset cancels snooze and allows future firings only.',
        ),
        SegmentedButton<cal.CalendarAlarmActivityKind>(
          segments: const [
            ButtonSegment(
              value: cal.CalendarAlarmActivityKind.firings,
              label: Text('Firings'),
            ),
            ButtonSegment(
              value: cal.CalendarAlarmActivityKind.actions,
              label: Text('Persistent actions'),
            ),
          ],
          selected: {_kind},
          onSelectionChanged: _busy
              ? null
              : (v) {
                  setState(() => _kind = v.single);
                  _load();
                },
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, key: const Key('alarm-activity-error')),
        if (!_busy &&
            (_kind == cal.CalendarAlarmActivityKind.firings
                ? _firings.isEmpty
                : _actions.isEmpty))
          const Text('No activity in this list.'),
        for (final f in _firings)
          if (_kind == cal.CalendarAlarmActivityKind.firings)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${f.kind.name}: ${f.state.name}'),
                    Text(f.dueAt.toIso8601String()),
                    Text('Original: ${f.originalKey}'),
                    if (f.action != null)
                      Text('Action revision ${f.action!.revision}'),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _act(
                                  cal.CalendarAlarmActionKind.acknowledge,
                                  firing: f,
                                ),
                          child: const Text('Acknowledge'),
                        ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _act(
                                  cal.CalendarAlarmActionKind.dismiss,
                                  firing: f,
                                ),
                          child: const Text('Dismiss'),
                        ),
                        TextButton(
                          onPressed:
                              _busy ||
                                  f.kind !=
                                      cal.CalendarAlarmFiringKind.automatic
                              ? null
                              : () => _act(
                                  cal.CalendarAlarmActionKind.snooze,
                                  firing: f,
                                ),
                          child: const Text('Snooze'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        for (final a in _actions)
          if (_kind == cal.CalendarAlarmActivityKind.actions)
            ListTile(
              title: Text('Original: ${a.originalKey}'),
              subtitle: Text(
                'Acknowledged: ${a.acknowledgedAt?.toIso8601String() ?? "no"}\n'
                'Dismissed: ${a.dismissedAt?.toIso8601String() ?? "no"}\n'
                'Pending snooze: ${a.pendingSnoozeAt?.toIso8601String() ?? "none"}\n'
                'Reset cutoff: ${a.resetAt?.toIso8601String() ?? "none"}',
              ),
              trailing: TextButton(
                onPressed: _busy
                    ? null
                    : () => _act(cal.CalendarAlarmActionKind.reset, action: a),
                child: const Text('Reset'),
              ),
            ),
        if (_cursor != null)
          TextButton(
            onPressed: _busy ? null : () => _load(more: true),
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}
