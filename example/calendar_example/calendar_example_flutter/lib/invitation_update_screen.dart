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
  cal.CalendarInvitationSourceKind? _requestKind;
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
        _requestKind = null;
        _result = null;
      });
    }
  });
  Future<void> _apply({bool cancellation = false}) => _run(() async {
    _requestKind ??= cancellation
        ? cal.CalendarInvitationSourceKind.meetingCancellation
        : cal.CalendarInvitationSourceKind.request;
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
    final api = widget.client.modules.serverpod_calendar.calendarInvitation;
    final receipt =
        _requestKind == cal.CalendarInvitationSourceKind.meetingCancellation
        ? await api.applyCancellation(_request!)
        : await api.applyUpdate(_request!);
    if (mounted) {
      setState(() {
        _result = receipt;
        _request = null;
        _requestKind = null;
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
            'Apply update replaces content from a REQUEST. Apply cancellation retains content and records cancelled status/source version. Both require a clean baseline and send no participation reply.',
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(_error!, key: const Key('invitation-update-error')),
          if (_result != null)
            Text(
              '${_result!.kind == cal.CalendarInvitationSourceKind.meetingCancellation ? 'Cancellation' : 'Update'} applied. Event revision ${_result!.eventRevision}.',
              key: const Key('invitation-update-result'),
            ),
          if (view != null) ...[
            if (view.currentContent.recurrence != null ||
                view.incomingContent?.recurrence != null)
              const Text(
                'Recurring series: application, cancellation and reopening below affect the whole series.',
              ),
            Text(
              'Current local event: ${view.currentContent.summary ?? 'Untitled event'}',
            ),
            Text(invitationTimingLabel(view.currentContent.timing)),
            Text('Current status: ${view.currentContent.status.name}'),
            Text(
              'Last accepted source: ${view.acceptedKind == cal.CalendarInvitationSourceKind.meetingCancellation ? 'Cancellation' : 'REQUEST'}',
            ),
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
            if (view.incomingKind ==
                cal.CalendarInvitationSourceKind.meetingCancellation)
              const Text(
                'Cancellation notice. Explicit application changes status/version while retaining other event content. Other source properties remain review-only.',
                key: Key('invitation-update-cancellation'),
              ),
            if (view.incomingKind ==
                    cal.CalendarInvitationSourceKind.meetingCancellation &&
                view.incomingSourceText != null)
              SelectableText(
                view.incomingSourceText!,
                key: const Key('invitation-cancellation-source'),
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
            if (!view.canApply &&
                !view.canApplyCancellation &&
                !view.hasLocalChanges)
              const Text('There is no pending newer source to apply.'),
            ElevatedButton(
              key: const Key('invitation-update-apply'),
              onPressed:
                  _busy ||
                      _result != null ||
                      (_requestKind != null &&
                          _requestKind !=
                              cal.CalendarInvitationSourceKind.request) ||
                      (!view.canApply &&
                          _requestKind !=
                              cal.CalendarInvitationSourceKind.request)
                  ? null
                  : () => _apply(),
              child: Text(
                _requestKind == cal.CalendarInvitationSourceKind.request
                    ? 'Retry the same update'
                    : view.currentContent.status ==
                              cal.CalendarEventStatus.cancelled &&
                          view.incomingKind ==
                              cal.CalendarInvitationSourceKind.request
                    ? 'Apply update / reopen'
                    : 'Apply update',
              ),
            ),
            if (view.incomingKind ==
                    cal.CalendarInvitationSourceKind.meetingCancellation ||
                _requestKind ==
                    cal.CalendarInvitationSourceKind.meetingCancellation)
              ElevatedButton(
                key: const Key('invitation-cancellation-apply'),
                onPressed:
                    _busy ||
                        _result != null ||
                        (_requestKind != null &&
                            _requestKind !=
                                cal
                                    .CalendarInvitationSourceKind
                                    .meetingCancellation) ||
                        (!view.canApplyCancellation &&
                            _requestKind !=
                                cal
                                    .CalendarInvitationSourceKind
                                    .meetingCancellation)
                    ? null
                    : () => _apply(cancellation: true),
                child: Text(
                  _requestKind ==
                          cal.CalendarInvitationSourceKind.meetingCancellation
                      ? 'Retry the same cancellation'
                      : 'Apply cancellation',
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
