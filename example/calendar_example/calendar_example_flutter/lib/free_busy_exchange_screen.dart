import 'dart:convert';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class FreeBusyExchangeScreen extends StatefulWidget {
  const FreeBusyExchangeScreen({
    super.key,
    required this.client,
    required this.calendarId,
  });
  final Client client;
  final cal.UuidValue calendarId;
  @override
  State<FreeBusyExchangeScreen> createState() => _FreeBusyExchangeScreenState();
}

class _FreeBusyExchangeScreenState extends State<FreeBusyExchangeScreen> {
  final _from = TextEditingController(), _until = TextEditingController();
  final _recipients = TextEditingController(
    text: 'mailto:respondent@example.invalid',
  );
  bool _busy = false;
  String? _error, _message, _wire, _inCursor, _outCursor, _activityCursor;
  List<cal.CalendarFreeBusyMessageView> _inbox = [];
  List<cal.CalendarFreeBusyOutgoingView> _outgoing = [];
  List<cal.CalendarFreeBusyDeliveryView> _activity = [];
  cal.UuidValue? _activityParent;
  cal.CalendarFreeBusyPublishRequest? _pendingPublication;
  cal.CalendarFreeBusyReplyRequest? _pendingReply;
  String? _pendingAction;
  (cal.UuidValue, DateTime, DateTime, bool)? _pendingSimulation;
  cal.EndpointCalendarFreeBusyExchange get _api =>
      widget.client.modules.serverpod_calendar.calendarFreeBusyExchange;
  String _format(DateTime value) =>
      value.toIso8601String().replaceFirst('.000Z', 'Z');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    _from.text = _format(today);
    _until.text = _format(today.add(const Duration(days: 1)));
    _run(_load);
  }

  @override
  void dispose() {
    _from.dispose();
    _until.dispose();
    _recipients.dispose();
    super.dispose();
  }

  DateTime _utc(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.0+)?Z$')
        .hasMatch(value)) {
      throw const FormatException('Use YYYY-MM-DDTHH:MM:SSZ.');
    }
    final normalized = value.replaceFirst(RegExp(r'\.0+Z$'), 'Z');
    final parsed = DateTime.parse(normalized);
    if (_format(parsed) != normalized) {
      throw const FormatException('Invalid UTC fields.');
    }
    return parsed;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _wire = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _inbox = [];
      _outgoing = [];
      _activity = [];
      _inCursor = null;
      _outCursor = null;
      _activityCursor = null;
      _activityParent = null;
    });
    final inbox = await _api.listFreeBusyInbox(pageSize: 20);
    final outgoing = await _api.listFreeBusyOutgoing(pageSize: 20);
    if (mounted) {
      setState(() {
        _inbox = inbox.items;
        _inCursor = inbox.cursor;
        _outgoing = outgoing.items;
        _outCursor = outgoing.cursor;
      });
    }
  }

  Future<void> _moreInbox() async {
    try {
      final page = await _api.listFreeBusyInbox(
        pageSize: 20,
        cursor: _inCursor,
      );
      if (mounted) {
        setState(() {
          _inbox = [..._inbox, ...page.items];
          _inCursor = page.cursor;
        });
      }
    } catch (_) {
      setState(() {
        _inbox = [];
        _inCursor = null;
      });
      rethrow;
    }
  }

  Future<void> _moreOutgoing() async {
    try {
      final page = await _api.listFreeBusyOutgoing(
        pageSize: 20,
        cursor: _outCursor,
      );
      if (mounted) {
        setState(() {
          _outgoing = [..._outgoing, ...page.items];
          _outCursor = page.cursor;
        });
      }
    } catch (_) {
      setState(() {
        _outgoing = [];
        _outCursor = null;
      });
      rethrow;
    }
  }

  void _checkPending(String action) {
    if (_pendingAction != null && _pendingAction != action) {
      throw StateError(
        'Retry the pending action or choose Start another message.',
      );
    }
  }

  Future<void> _send(bool request) async {
    final action = request ? 'request' : 'publish';
    _checkPending(action);
    _pendingPublication ??= cal.CalendarFreeBusyPublishRequest(
      commandId: cal.Uuid().v4obj(),
      calendarId: widget.calendarId,
      fromUtc: _utc(_from.text),
      untilUtc: _utc(_until.text),
      recipients: _recipients.text.split(',').map((s) => s.trim()).toList(),
    );
    _pendingAction = action;
    if (request) {
      await _api.requestFreeBusy(_pendingPublication!);
    } else {
      await _api.publishFreeBusy(_pendingPublication!);
    }
    _pendingPublication = null;
    _pendingAction = null;
    setState(
      () => _message =
          'Message queued. Transport acceptance appears in delivery activity.',
    );
    await _load();
  }

  Future<void> _respond(
    cal.CalendarFreeBusyMessageView source,
    bool refuse,
  ) async {
    final action = '${refuse ? 'refuse' : 'share'}:${source.id}';
    _checkPending(action);
    _pendingReply ??= cal.CalendarFreeBusyReplyRequest(
      commandId: cal.Uuid().v4obj(),
      sourceId: source.id,
      expectedSourceRevision: source.sourceRevision!,
      expectedReplyRevision: source.replyRevision!,
    );
    _pendingAction = action;
    if (refuse) {
      await _api.refuseFreeBusy(_pendingReply!);
    } else {
      await _api.replyFreeBusy(_pendingReply!);
    }
    _pendingReply = null;
    _pendingAction = null;
    setState(
      () => _message = refuse
          ? 'Refusal queued. No busy data was shared.'
          : 'Busy snapshot queued.',
    );
    await _load();
  }

  Future<void> _simulate(bool publish) async {
    final action = 'simulate:$publish';
    _checkPending(action);
    _pendingSimulation ??= (
      cal.Uuid().v4obj(),
      _utc(_from.text),
      _utc(_until.text),
      publish,
    );
    _pendingAction = action;
    final p = _pendingSimulation!;
    await widget.client.freeBusyDemo.simulate(
      widget.calendarId,
      p.$1,
      p.$2,
      p.$3,
      publish: p.$4,
    );
    _pendingSimulation = null;
    _pendingAction = null;
    setState(
      () => _message =
          'Synthetic input received for review. Calendar data is unchanged.',
    );
    await _load();
  }

  Future<void> _showActivity(cal.UuidValue command, {bool more = false}) async {
    try {
      final page = await _api.freeBusyDeliveryActivity(
        command,
        pageSize: 20,
        cursor: more ? _activityCursor : null,
      );
      if (mounted) {
        setState(() {
          _activityParent = command;
          _activity = [
            ...(more ? _activity : <cal.CalendarFreeBusyDeliveryView>[]),
            ...page.items,
          ];
          _activityCursor = page.cursor;
        });
      }
    } catch (_) {
      setState(() {
        _activity = [];
        _activityCursor = null;
        _activityParent = null;
      });
      rethrow;
    }
  }

  String _header(cal.CalendarFreeBusyMessageView source) {
    final h = jsonDecode(source.header) as Map<String, dynamic>;
    return [
      h['mailbox'],
      for (final part in h['components'] as List)
        '${part['organizer']}\n${part['fromUtc']} – ${part['untilUtc']}',
    ].join('\n');
  }

  String _delivery(String state) => switch (state) {
    'accepted' =>
      'Accepted by synthetic transport; receipt/display unconfirmed',
    'withdrawn' => 'Withdrawn',
    'expired' => 'Expired',
    'failed' => 'Delivery failed',
    'submitting' => 'Submitting',
    'unavailable' => 'Waiting for current authorization or timezone data',
    _ => 'Queued',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Busy-time messages'),
      actions: [
        IconButton(
          key: const Key('freebusy-refresh'),
          onPressed: _busy ? null : () => _run(_load),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    bottomNavigationBar: _busy
        ? const LinearProgressIndicator(key: Key('freebusy-progress'))
        : null,
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Snapshots describe this calendar only. Incoming reports are informational and never change availability or bookings.',
        ),
        TextField(
          key: const Key('freebusy-from'),
          controller: _from,
          enabled: !_busy && _pendingAction == null,
          decoration: const InputDecoration(labelText: 'From UTC (inclusive)'),
        ),
        TextField(
          key: const Key('freebusy-until'),
          controller: _until,
          enabled: !_busy && _pendingAction == null,
          decoration: const InputDecoration(
            labelText: 'Until UTC (exclusive, at most 31 days)',
          ),
        ),
        TextField(
          key: const Key('freebusy-recipients'),
          controller: _recipients,
          enabled: !_busy && _pendingAction == null,
          decoration: const InputDecoration(
            labelText:
                'Synthetic recipient mailto addresses, separated by commas',
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              key: const Key('freebusy-publish'),
              onPressed: _busy ? null : () => _run(() => _send(false)),
              child: const Text('Publish busy snapshot'),
            ),
            OutlinedButton(
              key: const Key('freebusy-request'),
              onPressed: _busy ? null : () => _run(() => _send(true)),
              child: const Text('Request busy time'),
            ),
          ],
        ),
        if (_pendingAction != null) ...[
          const Text(
            'A previous submission may already be queued. Retry its action, or refresh before starting another message.',
          ),
          TextButton(
            key: const Key('freebusy-new-command'),
            onPressed: _busy
                ? null
                : () => setState(() {
                    _pendingAction = null;
                    _pendingPublication = null;
                    _pendingReply = null;
                    _pendingSimulation = null;
                  }),
            child: const Text('Start another message'),
          ),
        ],
        if (_error != null)
          SelectableText(_error!, key: const Key('freebusy-error')),
        if (_message != null)
          Text(_message!, key: const Key('freebusy-message')),
        const Divider(),
        const Text('Example fixtures'),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              key: const Key('freebusy-simulate-request'),
              onPressed: _busy ? null : () => _run(() => _simulate(false)),
              child: const Text('Simulate incoming request'),
            ),
            TextButton(
              key: const Key('freebusy-simulate-publish'),
              onPressed: _busy ? null : () => _run(() => _simulate(true)),
              child: const Text('Simulate incoming report'),
            ),
          ],
        ),
        const Divider(),
        const Text('Private incoming messages'),
        for (final source in _inbox)
          Card(
            key: Key('freebusy-source-${source.id}'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.method == 'request'
                        ? source.conflicted
                              ? 'Conflicting request'
                              : source.isCurrent
                              ? 'Current request'
                              : 'Earlier request'
                        : 'Informational report',
                  ),
                  SelectableText(_header(source)),
                  if (source.dismissedAt != null) const Text('Dismissed'),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (source.method == 'request' &&
                          source.isCurrent &&
                          !source.conflicted) ...[
                        TextButton(
                          key: Key('freebusy-share-${source.id}'),
                          onPressed: _busy
                              ? null
                              : () => _run(() => _respond(source, false)),
                          child: const Text('Share busy snapshot'),
                        ),
                        TextButton(
                          key: Key('freebusy-refuse-${source.id}'),
                          onPressed: _busy
                              ? null
                              : () => _run(() => _respond(source, true)),
                          child: const Text('Refuse request'),
                        ),
                      ],
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => _run(() async {
                                await _api.dismissFreeBusyMessage(source.id);
                                await _load();
                              }),
                        child: const Text('Dismiss'),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => _run(() async {
                                final bytes = await _api.getFreeBusySource(
                                  source.id,
                                );
                                if (mounted) {
                                  setState(
                                    () => _wire = utf8.decode(
                                      bytes.buffer.asUint8List(
                                        bytes.offsetInBytes,
                                        bytes.lengthInBytes,
                                      ),
                                    ),
                                  );
                                }
                              }),
                        child: const Text('View iCalendar source'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (_inCursor != null)
          TextButton(
            onPressed: _busy ? null : () => _run(_moreInbox),
            child: const Text('More incoming messages'),
          ),
        const Divider(),
        const Text('Private outgoing messages'),
        for (final command in _outgoing)
          Card(
            key: Key('freebusy-command-${command.id}'),
            child: ListTile(
              title: Text(
                '${command.method.toUpperCase()} · ${_format(command.stamp)}',
              ),
              subtitle: Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    key: Key('freebusy-activity-${command.id}'),
                    onPressed: _busy
                        ? null
                        : () => _run(() => _showActivity(command.id)),
                    child: const Text('Delivery activity'),
                  ),
                  TextButton(
                    key: Key('freebusy-withdraw-${command.id}'),
                    onPressed: _busy
                        ? null
                        : () => _run(() async {
                            await _api.withdrawFreeBusyCommand(command.id);
                            await _load();
                          }),
                    child: const Text('Withdraw unsent'),
                  ),
                  if (command.method == 'request')
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                              await widget.client.freeBusyDemo.simulateReply(
                                command.id,
                                cal.Uuid().v4obj(),
                              );
                              await _load();
                            }),
                      child: const Text('Simulate respondent report'),
                    ),
                ],
              ),
            ),
          ),
        if (_outCursor != null)
          TextButton(
            onPressed: _busy ? null : () => _run(_moreOutgoing),
            child: const Text('More outgoing messages'),
          ),
        for (final delivery in _activity)
          Text(
            _delivery(delivery.state),
            key: Key('freebusy-delivery-${delivery.id}'),
          ),
        if (_activityCursor != null && _activityParent != null)
          TextButton(
            onPressed: _busy
                ? null
                : () => _run(() => _showActivity(_activityParent!, more: true)),
            child: const Text('More delivery activity'),
          ),
        if (_wire != null)
          SelectableText(_wire!, key: const Key('freebusy-source-text')),
      ],
    ),
  );
}
