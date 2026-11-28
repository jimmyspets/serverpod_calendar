import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:flutter/material.dart';

/// Publication review is separate from invitation participation.
class IncomingPublicationsScreen extends StatefulWidget {
  const IncomingPublicationsScreen({super.key, required this.client});
  final Client client;
  @override
  State<IncomingPublicationsScreen> createState() =>
      _IncomingPublicationsState();
}

class _IncomingPublicationsState extends State<IncomingPublicationsScreen> {
  final _entries = <cal.CalendarIncomingPublicationView>[];
  String? _cursor, _error;
  bool _busy = false, _dismissed = false;
  final _fixture = cal.Uuid().v4obj();
  int _sequence = 0;
  bool _cancel = false;
  cal.UuidValue? _simulationCommand;
  cal.EndpointCalendarIncomingPublication get _api =>
      widget.client.modules.serverpod_calendar.calendarIncomingPublication;
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
              : 'Publication action failed. Retry or refresh.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _page() async {
    final page = await _api.list(
      cal.CalendarIncomingPublicationQuery(
        includeDismissed: _dismissed,
        cursor: _cursor,
      ),
    );
    if (mounted) {
      setState(() {
        _entries.addAll(page.entries);
        _cursor = page.continuation;
      });
    }
  }

  Future<void> _load() => _run(() async {
    _entries.clear();
    _cursor = null;
    await _page();
  });
  Future<void> _simulate() => _run(() async {
    _simulationCommand ??= cal.Uuid().v4obj();
    await widget.client.publicationDemo.simulate(
      _fixture,
      _simulationCommand!,
      _sequence,
      _cancel,
      true,
      'Synthetic published event',
    );
    _simulationCommand = null;
    _sequence++;
    _entries.clear();
    _cursor = null;
    await _page();
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Published events'),
      actions: [
        IconButton(
          key: const Key('publications-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Receiving a publication changes no calendar and sends no reply. Review it, then explicitly add or apply it.',
        ),
        if (_error != null) Text(_error!, key: const Key('publications-error')),
        if (_busy) const LinearProgressIndicator(),
        SwitchListTile(
          title: const Text('Include dismissed'),
          value: _dismissed,
          onChanged: _busy
              ? null
              : (v) {
                  setState(() => _dismissed = v);
                  _load();
                },
        ),
        for (final entry in _entries)
          ListTile(
            key: ValueKey('publication-${entry.id}'),
            title: Text(entry.summary ?? 'Published event'),
            subtitle: Text(
              '${entry.kind.name} · ${entry.organizer} · sequence ${entry.sequence ?? "omitted"}',
            ),
            onTap: _busy
                ? null
                : () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => _PublicationReview(
                          client: widget.client,
                          id: entry.id,
                        ),
                      ),
                    );
                    if (mounted) await _load();
                  },
          ),
        if (_cursor != null)
          TextButton(
            key: const Key('publications-more'),
            onPressed: _busy ? null : () => _run(_page),
            child: const Text('Load more'),
          ),
        const Divider(),
        const Text(
          'Synthetic example fixture. This simulates a trusted host mailbox; it does not send mail.',
        ),
        SwitchListTile(
          title: const Text('Simulate cancellation'),
          value: _cancel,
          onChanged: _busy || _simulationCommand != null
              ? null
              : (v) => setState(() => _cancel = v),
        ),
        OutlinedButton(
          key: const Key('publication-simulate'),
          onPressed: _busy ? null : _simulate,
          child: Text(
            _simulationCommand == null
                ? 'Receive synthetic publication'
                : 'Retry same simulation',
          ),
        ),
      ],
    ),
  );
}

class _PublicationReview extends StatefulWidget {
  const _PublicationReview({required this.client, required this.id});
  final Client client;
  final cal.UuidValue id;
  @override
  State<_PublicationReview> createState() => _PublicationReviewState();
}

class _PublicationReviewState extends State<_PublicationReview> {
  cal.CalendarIncomingPublicationView? _entry;
  cal.CalendarIncomingPublicationLinkView? _link;
  cal.CalendarIncomingPublicationSourceView? _source;
  final _calendars = <cal.CalendarView>[];
  cal.UuidValue? _selected;
  String? _calendarCursor, _error;
  bool _busy = false, _checked = false;
  cal.CalendarIncomingPublicationAddRequest? _addRequest;
  cal.CalendarIncomingPublicationApplyRequest? _applyRequest;
  cal.EndpointCalendarIncomingPublication get _api =>
      widget.client.modules.serverpod_calendar.calendarIncomingPublication;
  bool get _pending => _addRequest != null || _applyRequest != null;
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
              : 'Publication action failed. Retry the same command or refresh.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _calendarsPage() async {
    final page = await widget.client.modules.serverpod_calendar.calendar.list(
      pageSize: 25,
      fieldGroups: [cal.CalendarFieldGroup.metadata],
      cursor: _calendarCursor,
    );
    if (mounted) {
      setState(() {
        _calendars.addAll(page.calendars);
        _calendarCursor = page.nextCursor;
      });
    }
  }

  Future<void> _reload() async {
    final entry = await _api.getEntry(widget.id);
    final link = await _api.getLink(widget.id);
    if (mounted) {
      setState(() {
        _entry = entry;
        _link = link;
        _checked = true;
      });
    }
  }

  Future<void> _load() => _run(() async {
    _checked = false;
    _source = null;
    _selected = null;
    _calendars.clear();
    _calendarCursor = null;
    // Refresh explicitly abandons an uncertain command; an ordinary Retry keeps it.
    _addRequest = null;
    _applyRequest = null;
    await _reload();
    if (_link == null &&
        _entry!.kind == cal.CalendarIncomingPublicationKind.publication) {
      await _calendarsPage();
    }
  });
  Future<void> _add() => _run(() async {
    if (_addRequest == null) {
      final parent = await widget.client.modules.serverpod_calendar.calendar
          .getCalendar(_selected!, [cal.CalendarFieldGroup.metadata]);
      _addRequest = cal.CalendarIncomingPublicationAddRequest(
        entryId: widget.id,
        sourceId: _entry!.sourceId,
        expectedRevision: _entry!.revision,
        calendarId: parent.id,
        expectedCalendarRevision: parent.revision,
        commandId: cal.Uuid().v4obj(),
      );
    }
    await _api.addToCalendar(_addRequest!);
    _addRequest = null;
    await _reload();
  });
  Future<void> _apply() => _run(() async {
    _applyRequest ??= cal.CalendarIncomingPublicationApplyRequest(
      entryId: widget.id,
      sourceId: _entry!.sourceId,
      expectedRevision: _entry!.revision,
      expectedEventRevision: _link!.eventRevision,
      commandId: cal.Uuid().v4obj(),
    );
    await _api.applySource(_applyRequest!);
    _applyRequest = null;
    await _reload();
  });
  @override
  Widget build(BuildContext context) {
    final entry = _entry, link = _link;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review publication'),
        actions: [
          IconButton(
            key: const Key('publication-review-refresh'),
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(_error!, key: const Key('publication-review-error')),
          if (entry != null) ...[
            Text(
              entry.summary ?? 'Published event',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Source: ${entry.organizer}'),
            Text('UID: ${entry.uid}'),
            Text(
              '${entry.kind.name} · sequence ${entry.sequence ?? "omitted"} · ${entry.stamp.toIso8601String()}',
            ),
            const Text(
              'Adding or applying a publication sends no participation reply.',
            ),
            OutlinedButton(
              key: const Key('publication-source'),
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      final source = await _api.getSource(
                        widget.id,
                        entry.sourceId,
                      );
                      if (mounted) setState(() => _source = source);
                    }),
              child: const Text('Read authorized source'),
            ),
            if (_source != null)
              SelectableText(
                _source!.normalizedSource,
                key: const Key('publication-source-text'),
              ),
            if (_checked &&
                link == null &&
                entry.kind ==
                    cal.CalendarIncomingPublicationKind.publication) ...[
              DropdownButtonFormField<cal.UuidValue>(
                key: const Key('publication-calendar'),
                initialValue: _selected,
                decoration: const InputDecoration(
                  labelText: 'Destination calendar',
                ),
                items: [
                  for (final calendar in _calendars)
                    DropdownMenuItem(
                      value: calendar.id,
                      child: Text(calendar.displayName ?? 'Calendar'),
                    ),
                ],
                onChanged: _busy || _pending
                    ? null
                    : (v) => setState(() => _selected = v),
              ),
              if (_calendarCursor != null)
                TextButton(
                  key: const Key('publication-more-calendars'),
                  onPressed: _busy || _pending
                      ? null
                      : () => _run(_calendarsPage),
                  child: const Text('More calendars'),
                ),
              FilledButton(
                key: const Key('publication-add'),
                onPressed: _busy || _selected == null ? null : _add,
                child: Text(
                  _addRequest == null
                      ? 'Add to calendar'
                      : 'Retry same addition',
                ),
              ),
            ],
            if (link != null) ...[
              Text(
                link.deleted
                    ? 'Linked event was deleted. This publication cannot recreate it.'
                    : 'Linked event: ${link.eventId}',
              ),
              if (!link.deleted)
                Text(
                  'Accepted ${link.acceptedKind?.name ?? "publication"} · sequence ${link.acceptedSequence ?? "omitted"}',
                ),
              if (link.hasLocalChanges)
                const Text('Local changes conflict with source replacement.'),
              if (!link.deleted)
                FilledButton(
                  key: const Key('publication-apply'),
                  onPressed:
                      _busy ||
                          (link.hasLocalChanges && !_pending) ||
                          _addRequest != null
                      ? null
                      : _apply,
                  child: Text(
                    _applyRequest != null
                        ? 'Retry same application'
                        : entry.kind ==
                              cal.CalendarIncomingPublicationKind.cancellation
                        ? 'Apply cancellation'
                        : link.acceptedKind ==
                              cal.CalendarIncomingPublicationKind.cancellation
                        ? 'Apply publication and reopen'
                        : 'Apply update',
                  ),
                ),
            ],
            OutlinedButton(
              key: const Key('publication-dismiss'),
              onPressed: _busy || _pending || entry.dismissedAt != null
                  ? null
                  : () => _run(() async {
                      await _api.dismiss(widget.id, entry.revision);
                      await _reload();
                    }),
              child: const Text('Dismiss review'),
            ),
          ],
        ],
      ),
    );
  }
}
