import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:material_ui/material_ui.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class AttendeeRefreshScreen extends StatefulWidget {
  const AttendeeRefreshScreen({
    super.key,
    required this.client,
    required this.id,
  });

  final Client client;
  final cal.UuidValue id;

  @override
  State<AttendeeRefreshScreen> createState() => _AttendeeRefreshScreenState();
}

class _AttendeeRefreshScreenState extends State<AttendeeRefreshScreen> {
  cal.CalendarInvitationView? _invitation;
  cal.CalendarAttendeeRefreshView? _delivery;
  cal.CalendarAttendeeRefreshCommand? _pending;
  bool _busy = true;
  String? _error;

  cal.EndpointCalendarInvitation get _api =>
      widget.client.modules.serverpod_calendar.calendarInvitation;

  @override
  void initState() {
    super.initState();
    _run(_read);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on cal.CalendarException catch (error) {
      if (mounted) {
        setState(() {
          if (error.code == cal.CalendarFailureCode.staleRevision) {
            _pending = null;
            _invitation = null;
            _delivery = null;
          }
          _error = error.message;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not confirm the request.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _read() async {
    setState(() {
      _invitation = null;
      _delivery = null;
    });
    final invitation = await _api.getInvitation(widget.id);
    final delivery = await _api.attendeeRefresh(widget.id);
    if (!mounted) return;
    setState(() {
      _invitation = invitation;
      _delivery = delivery;
    });
  }

  Future<void> _send() => _run(() async {
    _pending ??= cal.CalendarAttendeeRefreshCommand(
      invitationId: widget.id,
      expectedInvitationRevision: _invitation!.revision,
      commandId: const cal.Uuid().v4obj(),
    );
    final delivery = await _api.requestAttendeeRefresh(_pending!);
    if (!mounted) return;
    setState(() {
      _delivery = delivery;
      _pending = null;
    });
  });

  @override
  Widget build(BuildContext context) {
    final state = _delivery?.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Request current invitation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_invitation case final invitation?)
            Text('Organizer ${invitation.organizer}'),
          if (_busy) const LinearProgressIndicator(),
          if (_error case final error?) Text(error),
          if (state != null)
            Text(
              state == cal.CalendarInvitationResponseDeliveryState.accepted
                  ? 'Accepted by the synthetic transport'
                  : 'Delivery ${state.name}',
            ),
          TextButton(
            onPressed: _busy ? null : () => _run(_read),
            child: const Text('Reload delivery status'),
          ),
          FilledButton(
            key: const ValueKey('send-attendee-refresh'),
            onPressed:
                !_busy && (_pending != null || _delivery?.canRequest == true)
                ? _send
                : null,
            child: Text(_pending == null ? 'Send request' : 'Retry request'),
          ),
        ],
      ),
    );
  }
}
