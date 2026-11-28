import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_notifications_client/serverpod_notifications_client.dart'
    as notify;
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Current authorized views only; no persisted inbox or OS notification claim.
class LiveNotifications extends StatefulWidget {
  const LiveNotifications({super.key, required this.client});
  final Client client;
  @override
  State<LiveNotifications> createState() => _LiveNotificationsState();
}

class _LiveNotificationsState extends State<LiveNotifications> {
  StreamSubscription<notify.NotificationHint>? _subscription;
  Timer? _retry, _reconcile;
  List<notify.NotificationView> _items = [];
  bool _paused = false,
      _connected = false,
      _recovering = false,
      _again = false,
      _acting = false;
  int _epoch = 0;
  String? _error;
  @override
  void initState() {
    super.initState();
    widget.client.auth.authInfoListenable.addListener(_authChanged);
    _reconcile = Timer.periodic(const Duration(seconds: 15), (_) => _recover());
    _connect();
  }

  bool get _active => mounted && !_paused && widget.client.auth.isAuthenticated;
  void _authChanged() {
    _epoch++;
    _retry?.cancel();
    unawaited(_subscription?.cancel());
    _subscription = null;
    if (mounted) {
      setState(() {
        _items = [];
        _connected = false;
        _error = null;
      });
    }
    if (_active) _connect();
  }

  @override
  void dispose() {
    _epoch++;
    widget.client.auth.authInfoListenable.removeListener(_authChanged);
    _retry?.cancel();
    _reconcile?.cancel();
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _lost(int epoch) {
    if (!_active || epoch != _epoch) return;
    setState(() {
      _connected = false;
      _items = [];
    });
    _retry?.cancel();
    _retry = Timer(const Duration(seconds: 2), _connect);
  }

  void _connect() {
    if (!_active) return;
    _retry?.cancel();
    final epoch = ++_epoch;
    unawaited(_subscription?.cancel());
    _subscription = widget.client.notificationStream.watch().listen(
      (_) {
        if (!_active || epoch != _epoch) return;
        setState(() => _connected = true);
        _recover();
      },
      onError: (Object error) {
        _lost(epoch);
      },
      onDone: () => _lost(epoch),
    );
  }

  Future<void> _recover() async {
    if (!_active) return;
    if (_recovering) {
      _again = true;
      return;
    }
    _recovering = true;
    try {
      do {
        _again = false;
        final epoch = _epoch;
        final fresh = <notify.NotificationView>[];
        String? cursor;
        for (var page = 0; page < 100; page++) {
          final result = await widget
              .client
              .modules
              .serverpod_notifications
              .notification
              .recover(50, cursor);
          if (!_active || epoch != _epoch) return;
          fresh.addAll(result.notifications);
          cursor = result.nextCursor;
          if (cursor == null) break;
          if (page == 99) throw StateError('Reminder recovery limit');
        }
        if (_active && epoch == _epoch) {
          setState(() {
            _items = fresh;
            _error = null;
          });
        }
      } while (_again && _active);
    } catch (_) {
      if (_active) {
        setState(() {
          _items = [];
          _error = 'Live reminders unavailable. Retrying with current authorization.';
        });
      }
    } finally {
      _recovering = false;
    }
  }

  void _toggle() {
    _epoch++;
    _retry?.cancel();
    unawaited(_subscription?.cancel());
    _subscription = null;
    setState(() {
      _paused = !_paused;
      _connected = false;
      _items = [];
      _error = null;
    });
    if (!_paused) _connect();
  }

  Future<void> _act(
    notify.NotificationView view,
    cal.CalendarAlarmActionKind kind,
  ) async {
    if (_acting ||
        !_active ||
        view.sourceNamespace != 'calendar.alarm' ||
        view.actionReference == null) {
      return;
    }
    DateTime? snooze;
    if (kind == cal.CalendarAlarmActionKind.snooze) {
      snooze = await showDialog<DateTime>(
        context: context,
        builder: (_) => const _SnoozeDialog(),
      );
      if (!mounted || snooze == null) return;
    }
    setState(() {
      _acting = true;
      _error = null;
    });
    try {
      final v = jsonDecode(view.actionReference!) as Map<String, dynamic>;
      await widget.client.modules.serverpod_calendar.calendarAlarm.act(
        cal.CalendarAlarmActionRequest(
          parent: cal.CalendarAlarmParent(
            kind: cal.CalendarAlarmParentKind.values.byName(
              v['parentKind'] as String,
            ),
            id: cal.UuidValue.fromString(v['parentId'] as String),
          ),
          alarmId: cal.UuidValue.fromString(v['alarmId'] as String),
          firingId: cal.UuidValue.fromString(v['firingId'] as String),
          expectedAlarmRevision: v['alarmRevision'] as int,
          expectedActionRevision: v['actionRevision'] as int,
          kind: kind,
          snoozeAt: snooze,
        ),
      );
      await _recover();
    } catch (_) {
      if (_active) {
        setState(() {
          _items = [];
          _error = 'Reminder action rejected. Refresh before retrying.';
        });
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  bool _snoozeAllowed(notify.NotificationView item) {
    try {
      return (jsonDecode(item.actionReference!)
              as Map<String, dynamic>)['snoozeAllowed'] ==
          true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('live-notifications'),
    children: [
      const Text(
        'Live reminders',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        _paused
            ? 'Updates paused; saved alarms remain armed.'
            : _connected
            ? 'Connected'
            : 'Connecting reminders',
        key: const Key('notification-stream-status'),
      ),
      TextButton(
        key: const Key('notifications-toggle'),
        onPressed: _toggle,
        child: Text(_paused ? 'Resume updates' : 'Pause updates'),
      ),
      if (_error != null) Text(_error!, key: const Key('notifications-error')),
      if (!_paused && _items.isEmpty)
        const Text('No current reminders.', key: Key('notifications-empty')),
      for (final item in _items)
        Card(
          key: ValueKey('notification-${item.id}'),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(item.title),
                if (item.body != null) Text(item.body!),
                if (item.sourceNamespace == 'calendar.alarm' &&
                    item.actionReference != null)
                  Wrap(
                    children: [
                      TextButton(
                        key: ValueKey('notification-ack-${item.id}'),
                        onPressed: _acting
                            ? null
                            : () => _act(
                                item,
                                cal.CalendarAlarmActionKind.acknowledge,
                              ),
                        child: const Text('Acknowledge'),
                      ),
                      TextButton(
                        onPressed: _acting
                            ? null
                            : () => _act(
                                item,
                                cal.CalendarAlarmActionKind.dismiss,
                              ),
                        child: const Text('Dismiss'),
                      ),
                      if (_snoozeAllowed(item))
                        TextButton(
                          onPressed: _acting
                              ? null
                              : () => _act(
                                  item,
                                  cal.CalendarAlarmActionKind.snooze,
                                ),
                          child: const Text('Snooze'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _SnoozeDialog extends StatefulWidget {
  const _SnoozeDialog();
  @override
  State<_SnoozeDialog> createState() => _SnoozeDialogState();
}

class _SnoozeDialogState extends State<_SnoozeDialog> {
  late final _text = TextEditingController(
    text: DateTime.fromMillisecondsSinceEpoch(
      (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + 600) * 1000,
      isUtc: true,
    ).toIso8601String(),
  );
  String? _error;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Snooze until UTC'),
    content: TextField(
      controller: _text,
      decoration: InputDecoration(
        labelText: 'Future UTC instant, at most seven days',
        errorText: _error,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final value = DateTime.tryParse(_text.text);
          if (value == null ||
              !value.isUtc ||
              value.microsecondsSinceEpoch % 1000000 != 0) {
            setState(() => _error = 'Enter whole-second UTC.');
            return;
          }
          Navigator.pop(context, value);
        },
        child: const Text('Snooze'),
      ),
    ],
  );
}
