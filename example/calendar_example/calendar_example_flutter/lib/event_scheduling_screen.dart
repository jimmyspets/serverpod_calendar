import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';

import 'attendee_replies_screen.dart';

import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class EventSchedulingScreen extends StatefulWidget {
  const EventSchedulingScreen({
    super.key,
    required this.client,
    required this.event,
  });
  final Client client;
  final cal.CalendarEventView event;
  @override
  State<EventSchedulingScreen> createState() => _EventSchedulingScreenState();
}

class _EventSchedulingScreenState extends State<EventSchedulingScreen> {
  final _summary = TextEditingController(),
      _description = TextEditingController(),
      _location = TextEditingController(),
      _originalDate = TextEditingController(),
      _originalTime = TextEditingController(text: '00:00:00'),
      _originalZone = TextEditingController(),
      _recipients = TextEditingController();
  cal.CalendarEventTimeKind _originalKind = cal.CalendarEventTimeKind.date;
  late cal.CalendarEventView _event;
  cal.CalendarSchedulingView? _status;
  cal.CalendarSchedulingSaveRequest? _pending;
  cal.CalendarSchedulingCancelRequest? _pendingCancel;
  cal.CalendarSchedulingOccurrenceCancelRequest? _pendingOccurrenceCancel;
  cal.CalendarSchedulingOccurrenceRestoreRequest? _pendingOccurrenceRestore;
  cal.CalendarSchedulingReopenRequest? _pendingReopen;
  bool _busy = true;
  String? _error, _message;
  @override
  void initState() {
    super.initState();
    _event = widget.event;
    final timing = _event.timing;
    if (timing != null) {
      _originalKind = timing.kind;
      final c = timing.start;
      String two(int n) => n.toString().padLeft(2, '0');
      _originalDate.text = '${c.year}-${two(c.month)}-${two(c.day)}';
      _originalTime.text = '${two(c.hour)}:${two(c.minute)}:${two(c.second)}';
      _originalZone.text = timing.zoneId ?? '';
    }
    _reload();
  }

  @override
  void dispose() {
    for (final controller in [
      _summary,
      _description,
      _location,
      _recipients,
      _originalDate,
      _originalTime,
      _originalZone,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = widget.client.modules.serverpod_calendar.calendarEvent;
      final event = await api.getEvent(
        _event.id,
        cal.CalendarEventFieldGroup.values,
      );
      final status = await api.schedulingStatus(_event.id);
      if (!event.disclosedGroups.toSet().containsAll(
        cal.CalendarEventFieldGroup.values,
      )) {
        throw const FormatException('Full event access is required.');
      }
      if (!mounted) return;
      setState(() {
        _event = event;
        _status = status;
        _pending = null;
        _pendingCancel = null;
        _pendingOccurrenceCancel = null;
        _pendingOccurrenceRestore = null;
        _pendingReopen = null;
        _summary.text = event.summary ?? '';
        _description.text = event.description ?? '';
        _location.text = event.location ?? '';
        if (status.publicationId != null) {
          _recipients.text = status.deliveries
              .map((d) => d.recipientAddress)
              .join('\n');
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = _safe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _safe(Object error) => error is cal.CalendarException
      ? error.code == cal.CalendarFailureCode.dependencyConflict
            ? 'Review pending deliveries, remaining individual cancellations and master lifecycle, then reload before retrying.'
            : 'Scheduling failed: ${error.code.name}. Reload to review current state.'
      : error is FormatException
      ? error.message
      : 'Scheduling is unavailable. Retry the same action or reload.';

  cal.CalendarEventTiming _originalPoint() {
    final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$')
        .firstMatch(_originalDate.text);
    final time = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$')
        .firstMatch(_originalTime.text);
    if (date == null ||
        _originalKind != cal.CalendarEventTimeKind.date && time == null) {
      throw const FormatException(
        'Enter the original date as YYYY-MM-DD and time as HH:MM:SS.',
      );
    }
    return cal.CalendarEventTiming(
      kind: _originalKind,
      start: cal.CalendarEventCivil(
        year: int.parse(date[1]!),
        month: int.parse(date[2]!),
        day: int.parse(date[3]!),
        hour: _originalKind == cal.CalendarEventTimeKind.date
            ? 0
            : int.parse(time![1]!),
        minute: _originalKind == cal.CalendarEventTimeKind.date
            ? 0
            : int.parse(time![2]!),
        second: _originalKind == cal.CalendarEventTimeKind.date
            ? 0
            : int.parse(time![3]!),
      ),
      zoneId: _originalKind == cal.CalendarEventTimeKind.zoned
          ? _originalZone.text
          : null,
    );
  }

  Future<void> _restoreOccurrence() async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final input = _pendingOccurrenceRestore ??=
          cal.CalendarSchedulingOccurrenceRestoreRequest(
            eventId: _event.id,
            expectedRevision: _event.revision,
            commandId: cal.Uuid().v4obj(),
            originalStart: _originalPoint(),
          );
      final result = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .restoreOccurrenceAndNotify(input);
      if (!mounted) return;
      setState(() {
        _pendingOccurrenceRestore = null;
        _message = result.unchanged ? 'Published occurrence already restored.' : 'Published occurrence restored and queued; newer drafts preserved.';
      });
      await _reload();
    } catch (e) {
      if (mounted) setState(() => _error = _safe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelOccurrence() async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      _pendingOccurrenceCancel ??=
          cal.CalendarSchedulingOccurrenceCancelRequest(
            eventId: _event.id,
            expectedRevision: _event.revision,
            commandId: cal.Uuid().v4obj(),
            originalStart: _originalPoint(),
          );

      final result = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .cancelOccurrenceAndNotify(_pendingOccurrenceCancel!);
      if (!mounted) return;
      setState(() {
        _pendingOccurrenceCancel = null;
        _message = result.unchanged
            ? 'Occurrence cancellation already recorded.'
            : 'Occurrence cancellation queued; saved drafts preserved.';
      });
      await _reload();
    } catch (e) {
      if (mounted) setState(() => _error = _safe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reopenPublished() async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final input = _pendingReopen ??= cal.CalendarSchedulingReopenRequest(
        eventId: _event.id,
        expectedRevision: _event.revision,
        commandId: cal.Uuid().v4obj(),
      );
      final receipt = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .reopenPublishedAndNotify(input);
      if (!mounted) return;
      setState(() {
        _pendingReopen = null;
        _message = receipt.unchanged ? 'Published series already reopened.' : 'Reopened published values; individual cancellations and newer saved drafts were preserved.';
      });
      await _reload();
    } catch (e) {
      if (mounted) setState(() => _error = _safe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish() async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final input = _pending ??= cal.CalendarSchedulingSaveRequest(
        eventId: _event.id,
        expectedRevision: _event.revision,
        commandId: cal.Uuid().v4obj(),
        recipients: _recipients.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        content: cal.CalendarEventContent(
          summary: _summary.text.isEmpty ? null : _summary.text,
          description: _description.text.isEmpty ? null : _description.text,
          location: _location.text.isEmpty ? null : _location.text,
          timing: _event.timing!,
          status: _event.status == cal.CalendarEventStatus.cancelled
              ? cal.CalendarEventStatus.confirmed
              : _event.status!,
          transparency: _event.transparency!,
          recurrence: _event.recurrence,
          periods: _event.periods,
          textParameters: _event.textParameters,
        ),
      );
      final receipt = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .saveAndNotify(input);
      if (!mounted) return;
      setState(() {
        _pending = null;
        _pendingCancel = null;
        _message = receipt.unchanged
            ? 'Already published; no new messages queued.'
            : 'Saved and queued for synthetic delivery.';
      });
      await _reload();
    } catch (e) {
      if (mounted) setState(() => _error = _safe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final input = _pendingCancel ??= cal.CalendarSchedulingCancelRequest(
        eventId: _event.id,
        expectedRevision: _event.revision,
        commandId: cal.Uuid().v4obj(),
      );
      final receipt = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .cancelAndNotify(input);
      if (!mounted) return;
      setState(() {
        _pendingCancel = null;
        _message = receipt.unchanged
            ? 'Cancellation already published; no new messages queued.'
            : 'Cancelled and queued for synthetic delivery.';
      });
      await _reload();
    } catch (e) {
      if (mounted) setState(() => _error = _safe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligible = _status?.origin == cal.CalendarEventOrigin.native;
    final hasExceptions =
        (_event.timingOverrides?.singles.isNotEmpty ?? false) ||
        (_event.timingOverrides?.future.isNotEmpty ?? false);
    final locked =
        _busy ||
        _pendingReopen != null ||
        _pending != null ||
        _pendingCancel != null ||
        _pendingOccurrenceCancel != null ||
        _pendingOccurrenceRestore != null ||
        !eligible;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting invitations'),
        actions: [
          if (_status?.publicationId != null)
            TextButton(
              key: const Key('scheduling-replies'),
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AttendeeRepliesScreen(
                          client: widget.client,
                          eventId: _event.id,
                        ),
                      ),
                    ),
              child: const Text('Attendee replies'),
            ),
          TextButton(
            key: const Key('scheduling-reload'),
            onPressed: _busy ? null : _reload,
            child: const Text('Reload saved event'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'This example records synthetic invitations locally. It sends no email.',
          ),
          const Text(
            'Ordinary event edits remain local. Save and notify publishes the content below with the currently saved timing.',
          ),
          const Text(
            'Published originals stay in the publication history. After following the series again, Save and notify sends their current series values without creating native exceptions.',
          ),
          const Text(
            'This workflow supports native events and representable recurring exceptions with fixed recipients. Cancel and notify uses the last published version and keeps saved local fields. It does not save unsaved form edits; reloading discards those edits.',
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) Text(_error!, key: const Key('scheduling-error')),
          if (_message != null)
            Text(_message!, key: const Key('scheduling-message')),
          if (_status != null) ...[
            Text(
              _status!.publicationId == null
                  ? 'Not published'
                  : _status!.hasLocalChanges
                  ? 'Local changes have not been published'
                  : 'Current saved content is published',
              key: const Key('scheduling-status'),
            ),
            if (_status!.method != null)
              Text(
                'Last published action: ${_status!.publicationKind?.name ?? _status!.method}',
                key: const Key('scheduling-method'),
              ),
            if (!eligible)
              const Text(
                'Imported and older unknown-origin events cannot use this workflow.',
              ),
            if (_status!.organizerAddress != null)
              Text('Organizer: ${_status!.organizerAddress}'),
          ],
          if (hasExceptions)
            const Text(
              'Saved exceptions are included when representable. New content-only exceptions without timing cannot yet be published. Individual cancellation uses the separate action below. A rejected publication keeps your saved edits.',
              key: Key('scheduling-exception-limit'),
            ),
          TextField(
            key: const Key('scheduling-summary'),
            controller: _summary,
            enabled: !locked,
            decoration: const InputDecoration(labelText: 'Summary'),
          ),
          TextField(
            key: const Key('scheduling-description'),
            controller: _description,
            enabled: !locked,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextField(
            key: const Key('scheduling-location'),
            controller: _location,
            enabled: !locked,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          TextField(
            key: const Key('scheduling-recipients'),
            controller: _recipients,
            enabled: !locked && _status?.publicationId == null,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Recipient calendar addresses, one per line',
              hintText: 'mailto:bob@example.invalid',
            ),
          ),
          FilledButton(
            key: const Key('scheduling-publish'),
            onPressed:
                _busy ||
                    !eligible ||
                    _pendingReopen != null ||
                    _pendingCancel != null ||
                    _pendingOccurrenceCancel != null ||
                    _pendingOccurrenceRestore != null ||
                    (_status?.hasOccurrenceCancellations ?? false)
                ? null
                : _publish,
            child: Text(
              _pending != null
                  ? 'Retry Save and notify'
                  : _event.status == cal.CalendarEventStatus.cancelled
                  ? 'Reopen and notify'
                  : 'Save and notify',
            ),
          ),
          if (_status?.hasOccurrenceCancellations ?? false) ...[
            const Text(
              'Reopen the last published series while keeping individual cancellations. Newer saved drafts are not published by this action.',
            ),
            FilledButton(
              key: const Key('scheduling-reopen-published'),
              onPressed:
                  _busy ||
                      !eligible ||
                      _pending != null ||
                      _pendingCancel != null ||
                      _pendingOccurrenceCancel != null ||
                      _pendingOccurrenceRestore != null ||
                      _status?.publicationKind !=
                          cal.CalendarSchedulingPublicationKind.seriesCancel
                  ? null
                  : _reopenPublished,
              child: Text(
                _pendingReopen == null
                    ? 'Reopen published series and notify'
                    : 'Retry reopening published series',
              ),
            ),
          ],
          if (_status?.usesPublicationExclusions ?? false)
            const Text(
              'Individual cancellations are preserved in scheduling publications. Restoring one sends a complete published-series update; newer saved drafts stay local.',
            ),
          if (_status?.publicationId != null)
            OutlinedButton(
              key: const Key('scheduling-cancel'),
              onPressed:
                  _busy ||
                      !eligible ||
                      _pendingReopen != null ||
                      _pending != null ||
                      _pendingOccurrenceCancel != null ||
                      _pendingOccurrenceRestore != null
                  ? null
                  : _cancel,
              child: Text(
                _pendingCancel == null
                    ? 'Cancel and notify'
                    : 'Retry Cancel and notify',
              ),
            ),
          if (_status?.hasOccurrenceCancellations ?? false)
            const Text(
              'Individual cancellations are published. Restore each published occurrence before Save/Reopen and notify. Ordinary local restore sends nothing; cancelled-master reopening remains separate.',
            ),
          if (_status?.publicationId != null) ...[
            const Text(
              'Cancel one original from the last published recurring series. Enter its original profile and date/time, even if local drafts changed it. Earlier deliveries must be terminal; range anchors are unsupported. Restore sends the published occurrence values and preserves newer drafts. A cancelled master must be reopened separately.',
            ),
            DropdownButtonFormField<cal.CalendarEventTimeKind>(
              key: const Key('scheduling-original-kind'),
              initialValue: _originalKind,
              decoration: const InputDecoration(
                labelText: 'Original time profile',
              ),
              items: [
                for (final kind in [
                  cal.CalendarEventTimeKind.date,
                  cal.CalendarEventTimeKind.utc,
                  cal.CalendarEventTimeKind.zoned,
                ])
                  DropdownMenuItem(value: kind, child: Text(kind.name)),
              ],
              onChanged: locked
                  ? null
                  : (v) => setState(() => _originalKind = v!),
            ),
            TextField(
              key: const Key('scheduling-original-date'),
              controller: _originalDate,
              enabled: !locked,
              decoration: const InputDecoration(
                labelText: 'Original date (YYYY-MM-DD)',
              ),
            ),
            if (_originalKind != cal.CalendarEventTimeKind.date)
              TextField(
                key: const Key('scheduling-original-time'),
                controller: _originalTime,
                enabled: !locked,
                decoration: const InputDecoration(
                  labelText: 'Original time (HH:MM:SS)',
                ),
              ),
            if (_originalKind == cal.CalendarEventTimeKind.zoned)
              TextField(
                key: const Key('scheduling-original-zone'),
                controller: _originalZone,
                enabled: !locked,
                decoration: const InputDecoration(
                  labelText: 'Exact original IANA zone',
                ),
              ),
            OutlinedButton(
              key: const Key('scheduling-cancel-occurrence'),
              onPressed:
                  _busy ||
                      !eligible ||
                      _pendingReopen != null ||
                      _pending != null ||
                      _pendingCancel != null ||
                      _pendingOccurrenceRestore != null ||
                      _status?.publicationKind ==
                          cal.CalendarSchedulingPublicationKind.seriesCancel
                  ? null
                  : _cancelOccurrence,
              child: Text(
                _pendingOccurrenceCancel == null
                    ? 'Cancel occurrence and notify'
                    : 'Retry occurrence cancellation',
              ),
            ),
            OutlinedButton(
              key: const Key('scheduling-restore-occurrence'),
              onPressed:
                  _busy ||
                      !eligible ||
                      _pendingReopen != null ||
                      _pending != null ||
                      _pendingCancel != null ||
                      _pendingOccurrenceCancel != null ||
                      _event.status == cal.CalendarEventStatus.cancelled ||
                      _status?.publicationKind ==
                          cal.CalendarSchedulingPublicationKind.seriesCancel
                  ? null
                  : _restoreOccurrence,
              child: Text(
                _pendingOccurrenceRestore == null
                    ? 'Restore published occurrence and notify'
                    : 'Retry occurrence restoration',
              ),
            ),
          ],
          for (final delivery
              in _status?.deliveries ?? <cal.CalendarSchedulingDeliveryView>[])
            ListTile(
              title: Text(delivery.recipientAddress),
              subtitle: Text(
                '${delivery.state.name}; attempts ${delivery.attemptCount}',
              ),
              trailing: delivery.resultCode == null
                  ? null
                  : Text(delivery.resultCode!),
            ),
          const Text(
            'Acceptance by the recording adapter is not receipt or display. Reload refreshes delivery state and discards unsaved text edits.',
          ),
        ],
      ),
    );
  }
}
