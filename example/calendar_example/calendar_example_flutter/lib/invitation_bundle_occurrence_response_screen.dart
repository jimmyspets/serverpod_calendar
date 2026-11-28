import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'invitation_response_screen.dart';
import 'invitation_timing_label.dart';

class InvitationBundleOccurrenceResponseScreen extends StatefulWidget {
  const InvitationBundleOccurrenceResponseScreen({
    super.key,
    required this.client,
    required this.id,
  });
  final Client client;
  final cal.UuidValue id;
  @override
  State<InvitationBundleOccurrenceResponseScreen> createState() =>
      _SelectorState();
}

class _SelectorState extends State<InvitationBundleOccurrenceResponseScreen> {
  final _date = TextEditingController(),
      _time = TextEditingController(),
      _zone = TextEditingController();
  cal.CalendarEventTimeKind _kind = cal.CalendarEventTimeKind.utc;
  cal.CalendarInvitationBundleOccurrenceResponseView? _view;
  cal.CalendarEventTiming? _original;
  String? _error;
  bool _busy = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _date.dispose();
    _time.dispose();
    _zone.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is cal.CalendarException
              ? e.message
              : 'Enter a valid original date and whole-second time.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _load() => _run(() async {
    final invitation = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .getInvitation(widget.id);
    final timing = invitation.timing;
    if (mounted && timing != null) {
      String two(int n) => n.toString().padLeft(2, '0');
      final c = timing.start;
      _date.text =
          '${c.year.toString().padLeft(4, '0')}-${two(c.month)}-${two(c.day)}';
      _time.text = '${two(c.hour)}:${two(c.minute)}:${two(c.second)}';
      _zone.text = timing.zoneId ?? '';
      setState(() => _kind = timing.kind);
    }
  });
  void _changed() {
    setState(() {
      _view = null;
      _original = null;
      _error = null;
    });
  }

  Future<void> _check() => _run(() async {
    final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$')
        .firstMatch(_date.text.trim());
    final time = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$')
        .firstMatch(_time.text.trim());
    if (date == null ||
        _kind != cal.CalendarEventTimeKind.date && time == null) {
      throw const FormatException();
    }
    final original = cal.CalendarEventTiming(
      kind: _kind,
      zoneId: _kind == cal.CalendarEventTimeKind.zoned ? _zone.text : null,
      start: cal.CalendarEventCivil(
        year: int.parse(date[1]!),
        month: int.parse(date[2]!),
        day: int.parse(date[3]!),
        hour: _kind == cal.CalendarEventTimeKind.date
            ? 0
            : int.parse(time![1]!),
        minute: _kind == cal.CalendarEventTimeKind.date
            ? 0
            : int.parse(time![2]!),
        second: _kind == cal.CalendarEventTimeKind.date
            ? 0
            : int.parse(time![3]!),
      ),
    );
    final view = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .bundleOccurrenceResponse(widget.id, original);
    if (mounted) {
      setState(() {
        _original = original;
        _view = view;
      });
    }
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Select an original occurrence')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (_busy) const LinearProgressIndicator(),
        const Text(
          'Enter the original start, before any move. An occurrence need not have its own exception component. Checking selects no participation response and changes no calendar.',
        ),
        DropdownButton<cal.CalendarEventTimeKind>(
          key: const Key('bundle-occurrence-kind'),
          value: _kind,
          items: [
            for (final kind in cal.CalendarEventTimeKind.values)
              DropdownMenuItem(value: kind, child: Text(kind.name)),
          ],
          onChanged: _busy
              ? null
              : (kind) {
                  if (kind != null) {
                    setState(() => _kind = kind);
                    _changed();
                  }
                },
        ),
        TextField(
          key: const Key('bundle-occurrence-date'),
          controller: _date,
          enabled: !_busy,
          decoration: const InputDecoration(
            labelText: 'Original date (YYYY-MM-DD)',
          ),
          onChanged: (_) => _changed(),
        ),
        if (_kind != cal.CalendarEventTimeKind.date)
          TextField(
            key: const Key('bundle-occurrence-time'),
            controller: _time,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Original civil time (HH:MM:SS)',
            ),
            onChanged: (_) => _changed(),
          ),
        if (_kind == cal.CalendarEventTimeKind.zoned)
          TextField(
            key: const Key('bundle-occurrence-zone'),
            controller: _zone,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Exact source timezone',
            ),
            onChanged: (_) => _changed(),
          ),
        if (_error != null)
          Text(_error!, key: const Key('bundle-occurrence-error')),
        FilledButton(
          key: const Key('bundle-occurrence-check'),
          onPressed: _busy ? null : _check,
          child: const Text('Validate original'),
        ),
        if (_original != null && _view != null) ...[
          Text(
            invitationTimingLabel(_original!),
            key: const Key('bundle-occurrence-original'),
          ),
          if (_view!.componentVersion case final component?)
            Text(
              'Effective invitation SEQUENCE: ${component.sequence?.toString() ?? 'omitted'}',
              key: const Key('bundle-occurrence-version'),
            ),
          TextButton(
            key: const Key('bundle-occurrence-open'),
            onPressed: _busy
                ? null
                : () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => InvitationResponseScreen(
                        client: widget.client,
                        id: widget.id,
                        bundleOriginal: _original!,
                      ),
                    ),
                  ),
            child: const Text('Occurrence response / activity'),
          ),
        ],
      ],
    ),
  );
}
