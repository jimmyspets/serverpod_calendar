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
          status: _event.status!,
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

  @override
  Widget build(BuildContext context) {
    final eligible =
        _status?.origin == cal.CalendarEventOrigin.native &&
        _event.recurrence == null;
    final locked = _busy || _pending != null || !eligible;
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
            'The first workflow supports non-recurring native events with fixed recipients. Cancellation and recipient changes are not sent here.',
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
            if (!eligible)
              const Text(
                'Imported, older unknown-origin or recurring events cannot use this workflow.',
              ),
            if (_status!.organizerAddress != null)
              Text('Organizer: ${_status!.organizerAddress}'),
          ],
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
            onPressed: _busy || !eligible ? null : _publish,
            child: Text(
              _pending == null ? 'Save and notify' : 'Retry Save and notify',
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
