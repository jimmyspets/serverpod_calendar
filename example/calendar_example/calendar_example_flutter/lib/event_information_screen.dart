import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Explicit information delivery; recipients are routing addresses, not attendees.
class EventInformationScreen extends StatefulWidget {
  const EventInformationScreen({
    super.key,
    required this.client,
    required this.event,
  });
  final Client client;
  final cal.CalendarEventView event;
  @override
  State<EventInformationScreen> createState() => _EventInformationScreenState();
}

class _EventInformationScreenState extends State<EventInformationScreen> {
  final _recipients = TextEditingController();
  late cal.CalendarEventView _event;
  cal.CalendarSchedulingView? _status;
  cal.CalendarSchedulingSaveRequest? _save;
  cal.CalendarSchedulingCancelRequest? _cancel;
  cal.CalendarSchedulingReopenRequest? _reopen;
  bool _busy = true;
  String? _error, _message;
  bool get _pending => _save != null || _cancel != null || _reopen != null;
  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _load();
  }

  @override
  void dispose() {
    _recipients.dispose();
    super.dispose();
  }

  Future<void> _load() async {
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
      final status = await api.informationPublicationStatus(_event.id);
      if (!event.disclosedGroups.toSet().containsAll(
        cal.CalendarEventFieldGroup.values,
      )) {
        throw const FormatException('Complete event access is required.');
      }
      if (!mounted) return;
      setState(() {
        _event = event;
        _status = status;
        _save = null;
        _cancel = null;
        _reopen = null;
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
      ? 'Publication failed: ${error.code.name}. Retry the same command or refresh before a new action.'
      : error is FormatException
      ? error.message
      : 'Publication is unavailable. Retry the same command or refresh.';

  Future<void> _run(String action) async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final api = widget.client.modules.serverpod_calendar.calendarEvent;
      final cal.CalendarSchedulingReceipt receipt;
      if (action == 'save') {
        final input = _save ??= cal.CalendarSchedulingSaveRequest(
          eventId: _event.id,
          expectedRevision: _event.revision,
          commandId: cal.Uuid().v4obj(),
          recipients: _recipients.text
              .split('\n')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          content: cal.CalendarEventContent(
            summary: _event.summary,
            description: _event.description,
            location: _event.location,
            timing: _event.timing!,
            status: _event.status!,
            transparency: _event.transparency!,
            recurrence: _event.recurrence,
            periods: _event.periods,
            textParameters: _event.textParameters,
          ),
        );
        receipt = await api.saveAndPublishInformation(input);
      } else if (action == 'cancel') {
        receipt = await api.cancelPublishedInformation(
          _cancel ??= cal.CalendarSchedulingCancelRequest(
            eventId: _event.id,
            expectedRevision: _event.revision,
            commandId: cal.Uuid().v4obj(),
          ),
        );
      } else {
        receipt = await api.reopenPublishedInformation(
          _reopen ??= cal.CalendarSchedulingReopenRequest(
            eventId: _event.id,
            expectedRevision: _event.revision,
            commandId: cal.Uuid().v4obj(),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _save = null;
        _cancel = null;
        _reopen = null;
        _message = receipt.unchanged
            ? 'Already recorded; no new delivery queued.'
            : action == 'save'
            ? 'Saved values queued for synthetic information delivery.'
            : 'Published lifecycle queued; newer saved drafts preserved.';
      });
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _safe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bound = _status?.publicationId != null;
    final cancelled = _status?.method == 'CANCEL';
    return Scaffold(
      appBar: AppBar(title: const Text('Information publication')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Synthetic information delivery only. Fixed recipients receive information, not an attendance request. No real email is sent.',
          ),
          const Text(
            'Ordinary edits remain local. Save and publish sends the saved event values. Cancel/reopen uses the last published values and preserves newer drafts.',
          ),
          const Text(
            'Native-created events and supported single/future timing exceptions can be published. Published resets keep following the series. New content-only exceptions without explicit timing, individual cancellations, future cutoffs, source attendees and source alarms are rejected.',
          ),
          if (_error != null)
            Text(_error!, key: const Key('information-error')),
          if (_message != null)
            Text(_message!, key: const Key('information-message')),
          if (_status != null)
            Text(
              'Purpose: ${_status!.purpose?.name ?? "unbound"}; method: ${_status!.method ?? "none"}; local changes: ${_status!.hasLocalChanges}',
              key: const Key('information-status'),
            ),
          Text(_event.summary ?? 'Untitled event'),
          TextField(
            key: const Key('information-recipients'),
            controller: _recipients,
            enabled: !_busy && !bound && !_pending,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'One mailto:recipient@example.invalid per line (fixed after first publication)',
            ),
          ),
          FilledButton(
            key: const Key('information-publish'),
            onPressed:
                _busy ||
                    _status == null ||
                    cancelled ||
                    _pending && _save == null
                ? null
                : () => _run('save'),
            child: Text(
              _save == null
                  ? 'Save and publish information'
                  : 'Retry information publication',
            ),
          ),
          OutlinedButton(
            key: const Key('information-cancel'),
            onPressed:
                _busy || !bound || cancelled || _pending && _cancel == null
                ? null
                : () => _run('cancel'),
            child: Text(
              _cancel == null
                  ? 'Cancel published information'
                  : 'Retry cancellation',
            ),
          ),
          OutlinedButton(
            key: const Key('information-reopen'),
            onPressed:
                _busy || !bound || !cancelled || _pending && _reopen == null
                ? null
                : () => _run('reopen'),
            child: Text(
              _reopen == null
                  ? 'Reopen published information'
                  : 'Retry reopening',
            ),
          ),
          TextButton(
            key: const Key('information-refresh'),
            onPressed: _busy ? null : _load,
            child: const Text('Refresh current state / start a new command'),
          ),
          for (final d
              in _status?.deliveries ?? <cal.CalendarSchedulingDeliveryView>[])
            Text(
              '${d.recipientAddress}: ${d.state.name}; attempts ${d.attemptCount}',
            ),
          if (_busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
