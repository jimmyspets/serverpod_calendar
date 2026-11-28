import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:flutter/material.dart';

import 'invitation_timing_label.dart';

class InvitationUpdateScreen extends StatefulWidget {
  const InvitationUpdateScreen({
    super.key,
    required this.client,
    required this.invitationId,
  });
  final Client client;
  final cal.UuidValue invitationId;
  @override
  State<InvitationUpdateScreen> createState() => _InvitationUpdateScreenState();
}

class _InvitationUpdateScreenState extends State<InvitationUpdateScreen> {
  cal.CalendarInvitationApplicationView? _view;
  cal.CalendarInvitationApplyRequest? _request;
  cal.CalendarInvitationApplyReceipt? _result;
  String? _error;
  bool _busy = true;
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
              : 'Invitation update failed.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _load() => _run(() async {
    final view = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .application(widget.invitationId);
    if (mounted) {
      setState(() {
        _view = view;
        _request = null;
        _result = null;
      });
    }
  });
  Future<void> _apply() => _run(() async {
    final view = _view!;
    _request ??= cal.CalendarInvitationApplyRequest(
      invitationId: widget.invitationId,
      sourceId: view.incomingSourceId!,
      expectedInvitationRevision: view.invitationRevision!,
      linkId: view.linkId,
      expectedEventRevision: view.eventRevision,
      expectedCalendarRevision: view.calendarRevision,
      expectedApplicationRevision: view.applicationRevision,
    );
    final receipt = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .applyUpdate(_request!);
    if (mounted) {
      setState(() {
        _result = receipt;
        _request = null;
      });
    }
    final next = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .application(widget.invitationId);
    if (mounted) {
      setState(() => _view = next);
    }
  });
  @override
  Widget build(BuildContext context) {
    final view = _view;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review invitation update'),
        actions: [
          IconButton(
            key: const Key('invitation-update-refresh'),
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Apply replaces the linked local event from the selected incoming source. It sends no participation reply. Local changes are preserved by rejecting conflicts.',
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(_error!, key: const Key('invitation-update-error')),
          if (_result != null)
            Text(
              'Update applied. Event revision ${_result!.eventRevision}.',
              key: const Key('invitation-update-result'),
            ),
          if (view != null) ...[
            Text(
              'Current local event: ${view.currentContent.summary ?? 'Untitled event'}',
            ),
            Text(invitationTimingLabel(view.currentContent.timing)),
            if (view.currentContent.description != null)
              Text(view.currentContent.description!),
            if (view.currentContent.location != null)
              Text(view.currentContent.location!),
            Text(
              'Accepted source SEQUENCE: ${view.acceptedSequence?.toString() ?? 'omitted (effective 0)'}; DTSTAMP: ${view.acceptedStamp.toIso8601String()}',
            ),
            if (view.hasLocalChanges)
              const Text(
                'Local changes exist. This incoming update cannot replace them.',
                key: Key('invitation-update-conflict'),
              ),
            if (view.incomingContent != null) ...[
              Text(
                'Incoming event: ${view.incomingContent!.summary ?? 'Untitled event'}',
              ),
              Text(invitationTimingLabel(view.incomingContent!.timing)),
              const Text(
                'Complete incoming source (inert text; links are not fetched):',
              ),
              SelectableText(
                view.incomingSourceText!,
                key: const Key('invitation-update-source'),
              ),
            ],
            if (!view.canApply && !view.hasLocalChanges)
              const Text('There is no pending newer source to apply.'),
            ElevatedButton(
              key: const Key('invitation-update-apply'),
              onPressed:
                  _busy ||
                      _result != null ||
                      (!view.canApply && _request == null)
                  ? null
                  : _apply,
              child: Text(
                _request == null ? 'Apply update' : 'Retry the same update',
              ),
            ),
            if (_request != null)
              const Text(
                'Retry keeps the same request. Refresh explicitly loads the current accepted source and event.',
              ),
          ],
        ],
      ),
    );
  }
}
