import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'invitation_timing_label.dart';

class InvitationResponseScreen extends StatefulWidget {
  const InvitationResponseScreen({
    super.key,
    required this.client,
    required this.id,
    this.bundleMaster = false,
    this.bundleOriginal,
    this.recurringOriginal,
  });
  final Client client;
  final cal.UuidValue id;
  final bool bundleMaster;
  final cal.CalendarEventTiming? bundleOriginal, recurringOriginal;
  @override
  State<InvitationResponseScreen> createState() =>
      _InvitationResponseScreenState();
}

class _InvitationResponseScreenState extends State<InvitationResponseScreen> {
  cal.CalendarInvitationView? _invitation;
  cal.CalendarInvitationBundleOccurrenceResponseView? _bundleView;
  cal.CalendarInvitationRecurringOccurrenceResponseView? _recurringView;
  cal.CalendarInvitationRecurringOccurrenceResponseRequest? _recurringPending;
  cal.CalendarEventTiming? _recurringOriginal;
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
    final recurringOriginal =
        widget.recurringOriginal ??
        (!widget.bundleMaster &&
                widget.bundleOriginal == null &&
                invitation.recurring
            ? invitation.originalStart
            : null);
    final recurring = recurringOriginal == null
        ? null
        : await _api.recurringOccurrenceResponse(widget.id, recurringOriginal);
    final target = widget.bundleOriginal;
    final selected = target == null
        ? null
        : await _api.bundleOccurrenceResponse(widget.id, target);
    final response =
        recurring?.response ??
        selected?.response ??
        await (widget.bundleMaster
            ? _api.bundleResponse(widget.id)
            : _api.response(widget.id));
    final activity = await (recurringOriginal != null
        ? _api.recurringOccurrenceResponseActivity(widget.id, recurringOriginal)
        : target != null
        ? _api.bundleOccurrenceResponseActivity(widget.id, target)
        : widget.bundleMaster
        ? _api.bundleResponseActivity(widget.id)
        : _api.responseActivity(widget.id));
    if (mounted) {
      setState(() {
        _invitation = invitation;
        _bundleView = selected;
        _recurringView = recurring;
        _recurringOriginal = recurringOriginal;
        _response = response;
        _activity = activity;
      });
    }
  }

  Future<void> _refresh() => _run(_read);
  Future<void> _send() => _run(() async {
    _pending ??= cal.CalendarInvitationResponseRequest(
      invitationId: _recurringView?.masterInvitationId ?? widget.id,
      expectedInvitationRevision:
          _recurringView?.masterInvitationRevision ??
          _bundleView?.invitationRevision ??
          _invitation!.revision,
      sourceId:
          _recurringView?.membershipSourceId ??
          _bundleView?.currentSourceId ??
          _invitation!.sourceId!,
      expectedResponseRevision: _response!.revision,
      commandId: const cal.Uuid().v4obj(),
      choice: _choice!,
    );
    final target = widget.bundleOriginal;
    if (_recurringOriginal != null) {
      final view = _recurringView!;
      _recurringPending ??=
          cal.CalendarInvitationRecurringOccurrenceResponseRequest(
            request: _pending!,
            openedInvitationId: widget.id,
            originalStart: _recurringOriginal!,
            selectionHeadId: view.selectionHeadId,
            expectedSelectionRevision: view.selectionRevision,
            selectionEvidenceId: view.selectionEvidenceId!,
            selectionDigest: view.selectionDigest!,
          );
    }
    final receipt = await (_recurringPending != null
        ? _api.sendRecurringOccurrenceResponse(_recurringPending!)
        : target != null
        ? _api.sendBundleOccurrenceResponse(
            cal.CalendarInvitationBundleOccurrenceResponseRequest(
              request: _pending!,
              originalStart: target,
            ),
          )
        : widget.bundleMaster
        ? _api.sendBundleResponse(_pending!)
        : _api.sendResponse(_pending!));
    if (mounted) setState(() => _receipt = receipt);
    await _read();
  });

  Future<void> _another() => _run(() async {
    // Explicitly abandon the previous command before selecting another send.
    await _read();
    if (mounted) {
      setState(() {
        _pending = null;
        _recurringPending = null;
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
    final eligible = _response?.canSend ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bundleOriginal != null
              ? 'Respond to original occurrence'
              : widget.bundleMaster
              ? 'Respond to series master'
              : 'Invitation response',
        ),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
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
          if (widget.bundleMaster)
            const Text(
              'Series master only: this response identifies the master version. Occurrence and range responses are separate.',
              key: Key('response-bundle-master'),
            )
          else if (_response?.originalStart != null)
            Text(
              'This response is only for original occurrence: ${invitationTimingLabel(_response!.originalStart!)}',
              key: const Key('response-original'),
            )
          else if (_invitation?.recurring == true)
            const Text(
              'Recurring series: this response applies to the whole series.',
            ),
          if ((_recurringView?.componentVersion ??
                  _bundleView?.componentVersion)
              case final version?)
            Text(
              'Effective invitation version: SEQUENCE ${version.sequence?.toString() ?? 'omitted'}; ${version.stamp.toIso8601String()}; ${version.originalStart == null
                  ? 'master'
                  : version.isThisAndFuture
                  ? 'future timing component'
                  : 'single component'}.',
              key: const Key('response-effective-version'),
            ),
          if (_recurringView != null)
            const Text(
              'One response per original, shared with the series selector. Calendar Apply is separate.',
              key: Key('response-shared-original'),
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
