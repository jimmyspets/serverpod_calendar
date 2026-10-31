import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class InvitationResponseScreen extends StatefulWidget {
  const InvitationResponseScreen({
    super.key,
    required this.client,
    required this.id,
  });
  final Client client;
  final cal.UuidValue id;
  @override
  State<InvitationResponseScreen> createState() =>
      _InvitationResponseScreenState();
}

class _InvitationResponseScreenState extends State<InvitationResponseScreen> {
  cal.CalendarInvitationView? _invitation;
  cal.CalendarInvitationResponseView? _response;
  List<cal.CalendarInvitationResponseActivityView> _activity = [];
  cal.CalendarInvitationResponseChoice? _choice;
  cal.CalendarInvitationResponseRequest? _pending;
  cal.CalendarInvitationResponseReceipt? _receipt;
  bool _busy = true;
  String? _error;
  cal.EndpointCalendarInvitation get _api =>
      widget.client.modules.serverpod_calendar.calendarInvitation;

  @override
  void initState() {
    super.initState();
    _refresh();
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
              : 'Response request failed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _read() async {
    final invitation = await _api.getInvitation(widget.id);
    final response = await _api.response(widget.id);
    final activity = await _api.responseActivity(widget.id);
    if (mounted) {
      setState(() {
        _invitation = invitation;
        _response = response;
        _activity = activity;
      });
    }
  }

  Future<void> _refresh() => _run(_read);
  Future<void> _send() => _run(() async {
    _pending ??= cal.CalendarInvitationResponseRequest(
      invitationId: widget.id,
      expectedInvitationRevision: _invitation!.revision,
      sourceId: _invitation!.sourceId!,
      expectedResponseRevision: _response!.revision,
      commandId: const cal.Uuid().v4obj(),
      choice: _choice!,
    );
    final receipt = await _api.sendResponse(_pending!);
    if (mounted) setState(() => _receipt = receipt);
    await _read();
  });

  Future<void> _another() => _run(() async {
    // Explicitly abandon the previous command before selecting another send.
    await _read();
    if (mounted) {
      setState(() {
        _pending = null;
        _receipt = null;
        _choice = null;
      });
    }
  });

  String _delivery(cal.CalendarInvitationResponseDeliveryState state) =>
      switch (state) {
        cal.CalendarInvitationResponseDeliveryState.accepted =>
          'Transport accepted; organizer receipt is unknown',
        cal.CalendarInvitationResponseDeliveryState.claimed => 'Sending',
        _ => state.name,
      };

  @override
  Widget build(BuildContext context) {
    final eligible =
        _invitation?.kind == cal.CalendarInvitationSourceKind.request &&
        _invitation?.sourceId != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation response'),
        actions: [
          IconButton(
            key: const Key('response-refresh'),
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Send an explicit participation response. Adding to a calendar, applying updates and dismissing the invitation are separate actions. This example records synthetic mail only.',
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_invitation?.recurring == true)
            const Text(
              'Recurring series: this response applies to the whole series.',
            ),
          if (_error != null) Text(_error!, key: const Key('response-error')),
          if (_response != null) ...[
            Text(
              'Response revision: ${_response!.revision}',
              key: const Key('response-revision'),
            ),
            Text('Last choice: ${_response!.choice?.name ?? 'none'}'),
            if (_response!.revision > 0)
              Text(
                _response!.appliesToCurrentSource
                    ? 'Response is based on the current source.'
                    : 'Historical response; it does not accept the current source.',
              ),
            if (_response!.deliveryState != null)
              Text(_delivery(_response!.deliveryState!)),
          ],
          if (!eligible && _invitation != null)
            const Text('This source cannot receive a new response.'),
          DropdownButton<cal.CalendarInvitationResponseChoice>(
            key: const Key('response-choice'),
            value: _choice,
            hint: const Text('Choose a response'),
            items: [
              for (final choice in cal.CalendarInvitationResponseChoice.values)
                DropdownMenuItem(value: choice, child: Text(choice.name)),
            ],
            onChanged: _busy || _pending != null || !eligible
                ? null
                : (value) => setState(() => _choice = value),
          ),
          FilledButton(
            key: const Key('response-send'),
            onPressed:
                _busy ||
                    _response == null ||
                    (_pending == null && (!eligible || _choice == null))
                ? null
                : _send,
            child: Text(
              _pending == null
                  ? 'Send response'
                  : 'Retry the same response command',
            ),
          ),
          if (_receipt != null)
            Text(
              'Queued response ${_receipt!.id}. Queue acceptance does not prove delivery.',
              key: const Key('response-receipt'),
            ),
          if (_pending != null)
            TextButton(
              key: const Key('response-another'),
              onPressed: _busy ? null : _another,
              child: const Text('Start another response (refresh first)'),
            ),
          for (final row in _activity)
            ListTile(
              key: ValueKey('response-activity-${row.id}'),
              title: Text(
                '${row.choice.name}: ${_delivery(row.deliveryState)}',
              ),
              subtitle: Text(
                'Source ${row.sourceId}; attempts ${row.attemptCount}',
              ),
            ),
        ],
      ),
    );
  }
}
