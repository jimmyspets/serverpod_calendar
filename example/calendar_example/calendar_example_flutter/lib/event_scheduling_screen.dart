import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
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
      _recipients = TextEditingController();
  late cal.CalendarEventView _event;
  cal.CalendarSchedulingView? _status;
  cal.CalendarSchedulingSaveRequest? _pending;
  cal.CalendarSchedulingCancelRequest? _pendingCancel;
  bool _busy = true;
  String? _error, _message;
  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _reload();
  }

  @override
  void dispose() {
    for (final controller in [_summary, _description, _location, _recipients]) {
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
      ? 'Scheduling failed: ${error.code.name}. Reload to review current state.'
      : error is FormatException
      ? error.message
      : 'Scheduling is unavailable. Retry the same action or reload.';

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
        _busy || _pending != null || _pendingCancel != null || !eligible;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting invitations'),
        actions: [
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
                'Last published action: ${_status!.method}',
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
              'Saved exceptions are included when representable. Follow-series content without explicit timing and individual cancellations cannot be published yet. Removing a previously published exception requires a future reset workflow. A rejected publication keeps your saved edits.',
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
            onPressed: _busy || !eligible || _pendingCancel != null
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
          if (_status?.publicationId != null)
            OutlinedButton(
              key: const Key('scheduling-cancel'),
              onPressed: _busy || !eligible || _pending != null
                  ? null
                  : _cancel,
              child: Text(
                _pendingCancel == null
                    ? 'Cancel and notify'
                    : 'Retry Cancel and notify',
              ),
            ),
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
