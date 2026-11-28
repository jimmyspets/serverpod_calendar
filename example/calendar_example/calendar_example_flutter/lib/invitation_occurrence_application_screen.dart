import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'invitation_timing_label.dart';

class InvitationOccurrenceApplicationScreen extends StatefulWidget {
  const InvitationOccurrenceApplicationScreen({
    super.key,
    required this.client,
    required this.id,
    this.range = false,
  });
  final Client client;
  final cal.UuidValue id;
  final bool range;
  @override
  State<InvitationOccurrenceApplicationScreen> createState() => _State();
}

class _State extends State<InvitationOccurrenceApplicationScreen> {
  cal.CalendarInvitationOccurrenceApplicationView? _view;
  cal.CalendarInvitationOccurrenceApplyRequest? _request;
  bool? _cancel;
  String? _error;
  cal.CalendarInvitationOccurrenceApplyReceipt? _result;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _run(Future<void> Function() work) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await work();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is cal.CalendarException ? e.message : 'Occurrence action failed. Retain the same command for retry or reload a stale selection.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _load() => _run(() async {
    final api = widget.client.modules.serverpod_calendar.calendarInvitation;
    final v = await (widget.range
        ? api.rangeApplication
        : api.occurrenceApplication)(widget.id);
    if (mounted) {
      setState(() {
        _view = v;
        _request = null;
        _cancel = null;
        _result = null;
      });
    }
  });
  Future<void> _apply() => _run(() async {
    final v = _view!;
    _cancel ??= {
      cal.CalendarInvitationSourceKind.instanceCancellation,
      cal.CalendarInvitationSourceKind.rangeCancellation,
    }.contains(v.incomingKind);
    _request ??= cal.CalendarInvitationOccurrenceApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      linkId: v.linkId,
      expectedInvitationRevision: v.invitationRevision,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    final api = widget.client.modules.serverpod_calendar.calendarInvitation;
    final r = widget.range
        ? _cancel!
              ? await api.applyRangeCancellation(_request!)
              : await api.applyRangeUpdate(_request!)
        : _cancel!
        ? await api.applyOccurrenceCancellation(_request!)
        : await api.applyOccurrenceUpdate(_request!);
    if (mounted) {
      setState(() {
        _result = r;
        _request = null;
        _cancel = null;
      });
    }
    final next = await (widget.range
        ? api.rangeApplication
        : api.occurrenceApplication)(widget.id);
    if (mounted) {
      setState(() => _view = next);
    }
  });
  @override
  Widget build(BuildContext context) {
    final v = _view;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.range ? 'Apply range notice' : 'Apply occurrence notice',
        ),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Explicit local calendar action. Receiving this notice sends no reply. Any local change anywhere in the linked series blocks application.',
          ),
          if (widget.range)
            const Text(
              'This and future: timing propagates from the original anchor. Text changes stay at that anchor. Other explicit exceptions remain unchanged. A range cancellation suppresses every original from its anchor, preserving exception data. Participation stays separate.',
            ),
          if (_error != null)
            Text(_error!, key: const Key('invitation-occurrence-error')),
          if (_result != null)
            Text(
              '${widget.range ? 'Range notice' : 'Occurrence'} applied. Event revision ${_result!.eventRevision}.',
              key: const Key('invitation-occurrence-result'),
            ),
          if (v != null) ...[
            if (v.hasAcceptedRangeCancellation)
              const Text(
                'A source range cancellation is accepted. Occurrence and cancellation source applications remain blocked. Eligible master updates preserve the cutoff; exact retained retries remain available.',
              ),
            Text('Original: ${invitationTimingLabel(v.originalStart)}'),
            Text(
              'Accepted ${v.acceptedKind.name}; SEQUENCE ${v.acceptedVersion.sequence ?? 'omitted (effective zero)'}',
            ),
            if (v.currentOccurrence != null)
              Text(
                'Current: ${invitationTimingLabel(v.currentOccurrence!.timing)}',
              ),
            if (v.proposedOccurrence != null)
              Text(
                'Proposed: ${invitationTimingLabel(v.proposedOccurrence!.timing)}',
              ),
            if (v.incomingKind ==
                cal.CalendarInvitationSourceKind.instanceCancellation)
              const Text(
                'Apply cancellation retains the accepted timing, text and inheritance. Only this original is cancelled.',
              ),
            if (v.hasLocalChanges)
              const Text(
                'Local series or occurrence changes exist. Application is blocked.',
                key: Key('invitation-occurrence-conflict'),
              ),
            if (v.incomingSourceText != null)
              SelectableText(
                v.incomingSourceText!,
                key: const Key('invitation-occurrence-incoming-source'),
              ),
            if (v.acceptedSourceText != null) ...[
              const Text('Latest accepted source (inert text):'),
              SelectableText(v.acceptedSourceText!),
            ],
            ElevatedButton(
              key: const Key('invitation-occurrence-apply'),
              onPressed:
                  _busy || _result != null || (!v.canApply && _request == null)
                  ? null
                  : _apply,
              child: Text(
                _request != null
                    ? widget.range
                          ? 'Retry the same range action'
                          : 'Retry the same occurrence action'
                    : widget.range
                    ? v.incomingKind ==
                              cal.CalendarInvitationSourceKind.rangeCancellation
                          ? 'Apply range cancellation'
                          : 'Apply range update'
                    : v.incomingKind ==
                          cal.CalendarInvitationSourceKind.instanceCancellation
                    ? 'Apply occurrence cancellation'
                    : 'Apply occurrence update',
              ),
            ),
            if (v.incomingKind ==
                cal.CalendarInvitationSourceKind.rangeCancellation)
              const Text(
                'Apply explicitly cancels all originals from the anchor, including moved exceptions. Timing, content and source versions are retained. Eligible master updates preserve the cutoff. Other source applications and source restoration remain guarded.',
              ),
            const Text(
              'New whole-series sources preserve accepted occurrence edits and individual cancellations. Updates that remove an accepted original are rejected.',
            ),
          ],
          TextButton(
            key: const Key('invitation-occurrence-reload'),
            onPressed: _busy ? null : _load,
            child: const Text('Reload current source and revisions'),
          ),
        ],
      ),
    );
  }
}
