import 'invitation_adoption_screen.dart';
import 'invitation_occurrence_application_screen.dart';
import 'invitation_bundle_occurrence_response_screen.dart';
import 'invitation_response_screen.dart';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:flutter/material.dart';

import 'invitation_timing_label.dart';
export 'invitation_timing_label.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key, required this.client});
  final Client client;
  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  List<cal.CalendarInvitationView> _entries = [];
  bool _busy = true;
  bool? _simulationRecurring;
  bool? _simulationBundle;
  String? _error;
  cal.UuidValue? _simulationId, _simulationCommand, _cancellationCommand;
  cal.CalendarInvitationView? _cancellationEntry;
  cal.CalendarInvitationView? _occurrenceEntry;
  cal.UuidValue? _occurrenceCommand;
  bool? _occurrenceCancellation;
  bool? _occurrenceRange;
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
              : 'Invitation request failed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load() => _run(() async {
    final entries = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .list();
    if (mounted) setState(() => _entries = entries);
  });
  Future<void> _dismiss(cal.CalendarInvitationView entry) => _run(() async {
    await widget.client.modules.serverpod_calendar.calendarInvitation.dismiss(
      entry.id,
      entry.revision,
    );
    final entries = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .list();
    if (mounted) setState(() => _entries = entries);
  });
  Future<void> _simulate({bool recurring = false, bool bundle = false}) =>
      _run(() async {
        _simulationRecurring ??= recurring;
        _simulationBundle ??= bundle;
        _simulationId ??= const cal.Uuid().v4obj();
        _simulationCommand ??= const cal.Uuid().v4obj();
        final simulate = _simulationBundle!
            ? widget.client.invitationDemo.simulateBundle
            : _simulationRecurring!
            ? widget.client.invitationDemo.simulateRecurring
            : widget.client.invitationDemo.simulate;
        await simulate(
          _simulationId!,
          _simulationCommand!,
          null,
          _simulationRecurring!
              ? 'Synthetic recurring invitation'
              : 'Synthetic invitation for review',
        );
        final entries = await widget
            .client
            .modules
            .serverpod_calendar
            .calendarInvitation
            .list();
        if (mounted) {
          setState(() {
            _entries = entries;
            _simulationId = null;
            _simulationCommand = null;
            _simulationRecurring = null;
            _simulationBundle = null;
          });
        }
      });
  Future<void> _cancel(cal.CalendarInvitationView entry) => _run(() async {
    _cancellationEntry ??= entry;
    _cancellationCommand ??= const cal.Uuid().v4obj();
    final selected = _cancellationEntry!;
    await widget.client.invitationDemo.simulateCancellation(
      cal.UuidValue.fromString(selected.uid.split(':').last),
      _cancellationCommand!,
      selected.kind == cal.CalendarInvitationSourceKind.requestBundle &&
              (selected.sequence ?? 0) < 13
          ? 13
          : (selected.sequence ?? 0) + 1,
    );
    _cancellationEntry = null;
    _cancellationCommand = null;
    final entries = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .list();
    if (mounted) setState(() => _entries = entries);
  });
  Future<void> _simulateOccurrence(
    cal.CalendarInvitationView entry,
    bool cancel, {
    bool range = false,
  }) => _run(() async {
    _occurrenceEntry ??= entry;
    _occurrenceCommand ??= const cal.Uuid().v4obj();
    _occurrenceCancellation ??= cancel;
    _occurrenceRange ??= range;
    final selected = _occurrenceEntry!;
    final simulate = _occurrenceRange!
        ? widget.client.invitationDemo.simulateRange
        : widget.client.invitationDemo.simulateOccurrence;
    await simulate(
      cal.UuidValue.fromString(selected.uid.split(':').last),
      _occurrenceCommand!,
      (selected.sequence ?? 0) + 1,
      _occurrenceCancellation!,
    );
    final entries = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .list();
    if (mounted) {
      setState(() {
        _entries = entries;
        _occurrenceEntry = null;
        _occurrenceCommand = null;
        _occurrenceCancellation = null;
        _occurrenceRange = null;
      });
    }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Invitation review'),
      actions: [
        IconButton(
          key: const Key('invitations-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Unprocessed invitations. Receiving or dismissing one does not add an event, book time, accept/decline participation or send a reply. Use Add to calendar for an explicit local copy.',
        ),
        TextButton(
          key: const Key('invitation-simulate'),
          onPressed: _busy || _simulationId != null ? null : () => _simulate(),
          child: const Text(
            'Create synthetic invitation (development/test only)',
          ),
        ),
        TextButton(
          key: const Key('invitation-simulate-recurring'),
          onPressed: _busy || _simulationId != null
              ? null
              : () => _simulate(recurring: true),
          child: const Text('Create synthetic recurring invitation'),
        ),
        TextButton(
          key: const Key('invitation-simulate-bundle'),
          onPressed: _busy || _simulationId != null
              ? null
              : () => _simulate(recurring: true, bundle: true),
          child: const Text('Create synthetic invitation with exceptions'),
        ),
        if (_simulationId != null)
          TextButton(
            key: const Key('invitation-simulate-retry'),
            onPressed: _busy
                ? null
                : () => _simulate(
                    recurring: _simulationRecurring!,
                    bundle: _simulationBundle!,
                  ),
            child: const Text('Retry the same synthetic invitation'),
          ),
        if (_cancellationEntry != null)
          TextButton(
            key: const Key('invitation-cancel-retry'),
            onPressed: _busy ? null : () => _cancel(_cancellationEntry!),
            child: const Text('Retry the same synthetic cancellation'),
          ),
        if (_occurrenceEntry != null)
          TextButton(
            key: const Key('invitation-occurrence-retry'),
            onPressed: _busy
                ? null
                : () => _simulateOccurrence(
                    _occurrenceEntry!,
                    _occurrenceCancellation!,
                    range: _occurrenceRange!,
                  ),
            child: const Text('Retry the same synthetic occurrence notice'),
          ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('invitation-error')),
        if (!_busy && _entries.isEmpty && _error == null)
          const Text('No visible pending invitations.'),
        for (final entry in _entries)
          Card(
            key: ValueKey('invitation-${entry.id}'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.kind ==
                            cal.CalendarInvitationSourceKind.rangeCancellation
                        ? 'Range cancellation source'
                        : entry.kind ==
                              cal
                                  .CalendarInvitationSourceKind
                                  .meetingCancellation
                        ? 'Meeting cancellation notice'
                        : entry.kind ==
                              cal
                                  .CalendarInvitationSourceKind
                                  .instanceCancellation
                        ? 'Occurrence cancellation notice'
                        : entry.summary ?? 'Source unavailable',
                  ),
                  if (entry.isThisAndFuture) ...[
                    Text(
                      entry.kind ==
                              cal.CalendarInvitationSourceKind.rangeCancellation
                          ? 'This and future cancellation notice'
                          : 'This and future update notice',
                    ),
                    Text(
                      'First affected original: ${invitationTimingLabel(entry.originalStart!)}',
                    ),
                    Text(
                      entry.kind ==
                              cal.CalendarInvitationSourceKind.rangeCancellation
                          ? 'Range cancellation requires explicit calendar application. Range participation responses are not supported.'
                          : 'Calendar application is an explicit action. Range participation responses are not supported.',
                    ),
                  ] else if (entry.originalStart != null) ...[
                    Text(
                      entry.kind ==
                              cal
                                  .CalendarInvitationSourceKind
                                  .instanceCancellation
                          ? 'Unapplied occurrence cancellation'
                          : 'Unapplied occurrence update',
                    ),
                    Text(
                      'Original: ${invitationTimingLabel(entry.originalStart!)}',
                    ),
                    const Text(
                      'Occurrence notice. Calendar application and participation responses are separate explicit actions.',
                    ),
                  ] else if (entry.kind ==
                      cal.CalendarInvitationSourceKind.requestBundle)
                    const Text(
                      'Complete recurring invitation with exceptions. Add preserves the whole series; Apply update requires a complete source bundle. Master responses are separate; occurrence responses remain outside this profile.',
                    )
                  else if (entry.recurring)
                    const Text('Recurring series'),
                  if ({
                    cal.CalendarInvitationSourceKind.meetingCancellation,
                    cal.CalendarInvitationSourceKind.bundleCancellation,
                  }.contains(entry.kind))
                    const Text('Review only. The calendar event is unchanged.'),
                  if (entry.sourceId == null)
                    const Text('Source body unavailable.')
                  else if (entry.timing == null)
                    const Text('No start time supplied.'),
                  Text('Organizer address: ${entry.organizer}'),
                  Text('UID: ${entry.uid}'),
                  Text(
                    'Source SEQUENCE: ${entry.sequence?.toString() ?? 'omitted (effective 0)'}; DTSTAMP: ${entry.stamp.toIso8601String()}',
                  ),
                  if (entry.timing != null)
                    Text(
                      invitationTimingLabel(entry.timing!),
                    ),
                  Wrap(
                    children: [
                      if (entry.isThisAndFuture)
                        TextButton(
                          key: ValueKey(
                            'invitation-range-apply-view-${entry.id}',
                          ),
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        InvitationOccurrenceApplicationScreen(
                                          client: widget.client,
                                          id: entry.id,
                                          range: true,
                                        ),
                                  ),
                                ),
                          child: Text(
                            entry.kind ==
                                    cal
                                        .CalendarInvitationSourceKind
                                        .rangeCancellation
                                ? 'Preview / apply range cancellation'
                                : 'Preview / apply range update',
                          ),
                        ),
                      if (entry.originalStart != null && !entry.isThisAndFuture)
                        TextButton(
                          key: ValueKey(
                            'invitation-occurrence-apply-view-${entry.id}',
                          ),
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        InvitationOccurrenceApplicationScreen(
                                          client: widget.client,
                                          id: entry.id,
                                        ),
                                  ),
                                ),
                          child: const Text(
                            'Preview / apply occurrence notice',
                          ),
                        ),
                      if ({
                        cal.CalendarInvitationSourceKind.requestBundle,
                        cal.CalendarInvitationSourceKind.bundleCancellation,
                      }.contains(entry.kind))
                        TextButton(
                          key: ValueKey(
                            'invitation-bundle-response-${entry.id}',
                          ),
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) => InvitationResponseScreen(
                                      client: widget.client,
                                      id: entry.id,
                                      bundleMaster: true,
                                    ),
                                  ),
                                ),
                          child: const Text(
                            'Series master response / activity',
                          ),
                        ),
                      if ({
                        cal.CalendarInvitationSourceKind.requestBundle,
                        cal.CalendarInvitationSourceKind.bundleCancellation,
                      }.contains(entry.kind))
                        TextButton(
                          key: ValueKey(
                            'invitation-bundle-occurrence-response-${entry.id}',
                          ),
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        InvitationBundleOccurrenceResponseScreen(
                                          client: widget.client,
                                          id: entry.id,
                                        ),
                                  ),
                                ),
                          child: const Text(
                            'Original occurrence response / activity',
                          ),
                        ),
                      if (!entry.isThisAndFuture &&
                          !{
                            cal.CalendarInvitationSourceKind.requestBundle,
                            cal.CalendarInvitationSourceKind.bundleCancellation,
                          }.contains(entry.kind))
                        TextButton(
                          key: ValueKey('invitation-response-${entry.id}'),
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) => InvitationResponseScreen(
                                      client: widget.client,
                                      id: entry.id,
                                    ),
                                  ),
                                ),
                          child: const Text('Participation response'),
                        ),
                      if (entry.originalStart == null &&
                          {
                            cal.CalendarInvitationSourceKind.request,
                            cal.CalendarInvitationSourceKind.requestBundle,
                          }.contains(entry.kind) &&
                          _cancellationEntry == null)
                        TextButton(
                          key: ValueKey('invitation-cancel-${entry.id}'),
                          onPressed: _busy ? null : () => _cancel(entry),
                          child: const Text(
                            'Simulate cancellation (development/test only)',
                          ),
                        ),
                      if (entry.originalStart == null)
                        TextButton(
                          key: ValueKey('invitation-add-${entry.id}'),
                          onPressed: _busy
                              ? null
                              : () async {
                                  await Navigator.of(context).push<void>(
                                    MaterialPageRoute(
                                      builder: (_) => InvitationAdoptionScreen(
                                        client: widget.client,
                                        entry: entry,
                                      ),
                                    ),
                                  );
                                  if (mounted) {
                                    await _load();
                                  }
                                },
                          child: Text(
                            {
                                  cal.CalendarInvitationSourceKind.request,
                                  cal
                                      .CalendarInvitationSourceKind
                                      .requestBundle,
                                }.contains(entry.kind)
                                ? 'Add to calendar / view link'
                                : 'View existing link',
                          ),
                        ),
                      if (!entry.isThisAndFuture &&
                          entry.recurring &&
                          entry.kind ==
                              cal.CalendarInvitationSourceKind.request &&
                          _occurrenceEntry == null)
                        TextButton(
                          key: ValueKey('invitation-instance-${entry.id}'),
                          onPressed: _busy
                              ? null
                              : () => _simulateOccurrence(
                                  entry,
                                  entry.originalStart != null,
                                ),
                          child: Text(
                            entry.originalStart == null
                                ? 'Simulate occurrence update'
                                : 'Simulate occurrence cancellation',
                          ),
                        ),
                      if (entry.recurring &&
                          entry.kind ==
                              cal.CalendarInvitationSourceKind.request &&
                          (entry.originalStart == null ||
                              entry.isThisAndFuture) &&
                          _occurrenceEntry == null)
                        TextButton(
                          key: ValueKey('invitation-range-${entry.id}'),
                          onPressed: _busy
                              ? null
                              : () => _simulateOccurrence(
                                  entry,
                                  entry.isThisAndFuture,
                                  range: true,
                                ),
                          child: Text(
                            entry.isThisAndFuture
                                ? 'Simulate range cancellation'
                                : 'Simulate this and future update',
                          ),
                        ),
                      TextButton(
                        key: ValueKey('invitation-source-${entry.id}'),
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => InvitationSourceScreen(
                                    client: widget.client,
                                    entry: entry,
                                  ),
                                ),
                              ),
                        child: const Text('Review source history'),
                      ),
                      TextButton(
                        key: ValueKey('invitation-dismiss-${entry.id}'),
                        onPressed: _busy ? null : () => _dismiss(entry),
                        child: const Text('Dismiss this version'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class InvitationSourceScreen extends StatefulWidget {
  const InvitationSourceScreen({
    super.key,
    required this.client,
    required this.entry,
  });
  final Client client;
  final cal.CalendarInvitationView entry;
  @override
  State<InvitationSourceScreen> createState() => _InvitationSourceScreenState();
}

class _InvitationSourceScreenState extends State<InvitationSourceScreen> {
  List<cal.CalendarInvitationSourceView> _sources = [];
  String? _text, _error;
  bool _busy = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load([cal.UuidValue? id]) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (id == null) {
        final sources = await widget
            .client
            .modules
            .serverpod_calendar
            .calendarInvitation
            .sources(widget.entry.id);
        if (mounted) setState(() => _sources = sources);
      } else {
        final source = await widget
            .client
            .modules
            .serverpod_calendar
            .calendarInvitation
            .source(widget.entry.id, id);
        if (mounted) setState(() => _text = source.text);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is cal.CalendarException
              ? e.message
              : 'Source review failed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Private invitation source')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Inert source data. Addresses and participation claims grant no authority. Historical selection is distinct from the current version; no links are fetched.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, key: const Key('invitation-source-error')),
        for (final source in _sources)
          ListTile(
            key: ValueKey('invitation-history-${source.id}'),
            title: Text(
              '${source.kind.name}; ${source.outcome.name}; current: ${source.isCurrent}; SEQUENCE: ${source.sequence?.toString() ?? 'omitted'}',
            ),
            subtitle: Text(source.stamp.toIso8601String()),
            onTap: _busy ? null : () => _load(source.id),
          ),
        if (_text != null)
          SelectableText(_text!, key: const Key('invitation-document')),
      ],
    ),
  );
}
