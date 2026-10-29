import 'invitation_update_screen.dart';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:flutter/material.dart';

class InvitationAdoptionScreen extends StatefulWidget {
  const InvitationAdoptionScreen({
    super.key,
    required this.client,
    required this.entry,
  });
  final Client client;
  final cal.CalendarInvitationView entry;
  @override
  State<InvitationAdoptionScreen> createState() =>
      _InvitationAdoptionScreenState();
}

class _InvitationAdoptionScreenState extends State<InvitationAdoptionScreen> {
  late cal.CalendarInvitationView _entry = widget.entry;
  cal.CalendarInvitationAdoptionReceipt? _link;
  cal.CalendarInvitationAdoptionRequest? _request;
  final _calendars = <cal.CalendarView>[];
  cal.UuidValue? _selected;
  String? _cursor, _error;
  bool _busy = true, _checked = false;
  @override
  void initState() {
    super.initState();
    _load();
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
              : 'Calendar addition failed.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _page() async {
    final page = await widget.client.modules.serverpod_calendar.calendar.list(
      pageSize: 25,
      fieldGroups: [cal.CalendarFieldGroup.metadata],
      cursor: _cursor,
    );
    if (mounted) {
      setState(() {
        _calendars.addAll(page.calendars);
        _cursor = page.nextCursor;
      });
    }
  }

  Future<void> _load() => _run(() async {
    // Explicit reload abandons uncertain request identity; ordinary retry below
    // retains the original frozen body, even if the source/parent changed.
    setState(() {
      _request = null;
      _checked = false;
      _selected = null;
      _calendars.clear();
      _cursor = null;
    });
    final link = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .link(_entry.id);
    if (mounted) {
      setState(() {
        _link = link;
        _checked = true;
      });
    }
    if (link == null) {
      final current = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarInvitation
          .getInvitation(_entry.id);
      if (mounted) {
        setState(() => _entry = current);
      }
      if (current.kind == cal.CalendarInvitationSourceKind.request) {
        await _page();
      }
    }
  });
  Future<void> _add() => _run(() async {
    final calendar = _calendars.singleWhere((c) => c.id == _selected);
    _request ??= cal.CalendarInvitationAdoptionRequest(
      invitationId: _entry.id,
      expectedRevision: _entry.revision,
      sourceId: _entry.sourceId!,
      calendarId: calendar.id,
      expectedCalendarRevision: calendar.revision,
    );
    final receipt = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .adopt(_request!);
    if (mounted) {
      setState(() {
        _link = receipt;
        _request = null;
      });
    }
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Add invitation to calendar'),
      actions: [
        IconButton(
          key: const Key('invitation-adoption-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Adds one local event. It may block time under the calendar rules. This does not accept participation or send a reply. Later invitations do not automatically update it.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, key: const Key('invitation-adoption-error')),
        if (_link != null)
          SelectableText(
            'Linked event: ${_link!.eventId}\nCalendar: ${_link!.calendarId}',
            key: const Key('invitation-linked-event'),
          ),
        if (_link != null)
          TextButton(
            key: const Key('invitation-review-update'),
            onPressed: _busy
                ? null
                : () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => InvitationUpdateScreen(
                        client: widget.client,
                        invitationId: _entry.id,
                      ),
                    ),
                  ),
            child: const Text('Review incoming update'),
          ),
        if (_checked && _link == null) ...[
          if (_entry.kind != cal.CalendarInvitationSourceKind.request ||
              _entry.dismissedAt != null ||
              _entry.sourceId == null)
            const Text('This version is not available for calendar addition.')
          else ...[
            DropdownButtonFormField<cal.UuidValue>(
              key: const Key('invitation-calendar'),
              initialValue: _selected,
              decoration: const InputDecoration(labelText: 'Choose a calendar'),
              items: [
                for (final calendar in _calendars)
                  DropdownMenuItem(
                    value: calendar.id,
                    child: Text(calendar.displayName ?? calendar.id.toString()),
                  ),
              ],
              onChanged: _busy || _request != null
                  ? null
                  : (value) => setState(() => _selected = value),
            ),
            if (_cursor != null)
              TextButton(
                key: const Key('invitation-more-calendars'),
                onPressed: _busy || _request != null ? null : () => _run(_page),
                child: const Text('More calendars'),
              ),
            ElevatedButton(
              key: const Key('invitation-add-confirm'),
              onPressed: _busy || _selected == null ? null : _add,
              child: Text(
                _request == null
                    ? 'Add to selected calendar'
                    : 'Retry the same calendar addition',
              ),
            ),
            if (_request != null)
              const Text(
                'Retry keeps the same request. Refresh explicitly reloads the current source and calendars.',
              ),
          ],
        ],
      ],
    ),
  );
}
