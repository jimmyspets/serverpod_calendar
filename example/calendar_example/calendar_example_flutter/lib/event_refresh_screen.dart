import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:material_ui/material_ui.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class EventRefreshScreen extends StatefulWidget {
  const EventRefreshScreen({
    super.key,
    required this.client,
    required this.eventId,
  });

  final Client client;
  final cal.UuidValue eventId;

  @override
  State<EventRefreshScreen> createState() => _EventRefreshScreenState();
}

class _EventRefreshScreenState extends State<EventRefreshScreen> {
  final _commands = <cal.UuidValue, cal.CalendarRefreshResendCommand>{};
  List<cal.CalendarRefreshView> _entries = [];
  cal.CalendarRefreshPage? _page;
  String? _error;
  bool _busy = false;

  cal.EndpointCalendarEvent get _api =>
      widget.client.modules.serverpod_calendar.calendarEvent;

  @override
  void initState() {
    super.initState();
    _run(() => _load());
  }

  Future<void> _load([String? cursor]) async {
    final page = await _api.listEventRefresh(widget.eventId, 16, cursor);
    if (!mounted) return;
    setState(() {
      _page = page;
      _entries = [if (cursor != null) ..._entries, ...page.entries];
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on cal.CalendarException catch (error) {
      if (!mounted) return;
      setState(() {
        if (error.code == cal.CalendarFailureCode.accessDenied ||
            error.code == cal.CalendarFailureCode.invalidCursor) {
          _page = null;
          _entries = [];
        }
        _error = error.code == cal.CalendarFailureCode.staleRevision
            ? 'The published invitation changed. Reload before resending.'
            : 'The refresh action could not be completed.';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The refresh action could not be completed.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend(cal.CalendarRefreshView entry) => _run(() async {
    final command = _commands[entry.requestId] ??=
        cal.CalendarRefreshResendCommand(
          eventId: widget.eventId,
          requestId: entry.requestId,
          publicationId: _page!.publicationId!,
          generation: _page!.generation!,
          commandId: cal.Uuid().v4obj(),
        );
    try {
      await _api.resendEventRefresh(command);
      _commands.remove(entry.requestId);
    } on cal.CalendarException catch (error) {
      if (error.code == cal.CalendarFailureCode.staleRevision) {
        _commands.remove(entry.requestId);
      }
      rethrow;
    }
    await _load();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Invitation refresh requests'),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => _run(() => _load()),
          child: const Text('Reload'),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('refresh-error')),
        if (_page != null && _entries.isEmpty)
          const Text('No refresh requests.'),
        for (final entry in _entries)
          ListTile(
            title: Text(entry.attendeeAddress),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final comment in entry.comments) Text(comment),
                if (entry.dismissedAt != null) const Text('Dismissed'),
                if (entry.resendState != null)
                  Text('Resend: ${entry.resendState!.name}'),
                if (entry.dismissedAt == null && entry.resendState == null)
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        key: ValueKey('refresh-resend-${entry.requestId}'),
                        onPressed: _busy || _page?.publicationId == null
                            ? null
                            : () => _resend(entry),
                        child: const Text('Resend published invitation'),
                      ),
                      TextButton(
                        key: ValueKey('refresh-dismiss-${entry.requestId}'),
                        onPressed:
                            _busy || _commands.containsKey(entry.requestId)
                            ? null
                            : () => _run(() async {
                                await _api.dismissEventRefresh(
                                  widget.eventId,
                                  entry.requestId,
                                );
                                await _load();
                              }),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        if (_page?.nextCursor case final cursor?)
          TextButton(
            onPressed: _busy ? null : () => _run(() => _load(cursor)),
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}
