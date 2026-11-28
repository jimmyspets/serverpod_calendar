import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'invitation_timing_label.dart';

class InvitationBundleUpdateScreen extends StatefulWidget {
  const InvitationBundleUpdateScreen({
    super.key,
    required this.client,
    required this.id,
  });
  final Client client;
  final cal.UuidValue id;
  @override
  State<InvitationBundleUpdateScreen> createState() =>
      _InvitationBundleUpdateScreenState();
}

class _InvitationBundleUpdateScreenState
    extends State<InvitationBundleUpdateScreen> {
  cal.CalendarInvitationBundleApplicationView? _view;
  cal.CalendarInvitationApplyRequest? _request;
  cal.CalendarInvitationApplyReceipt? _result;
  String? _error;
  final _scroll = ScrollController();
  bool _busy = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
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
              : 'Bundle update unavailable.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
        });
      }
    }
  }

  Future<void> _load() => _run(() async {
    final view = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .bundleApplication(widget.id);
    if (mounted) {
      setState(() {
        _view = view;
        _request = null;
        _result = null;
      });
    }
  });
  Future<void> _apply() => _run(() async {
    final view = _view!;
    _request ??= cal.CalendarInvitationApplyRequest(
      invitationId: view.invitationId,
      sourceId: view.incomingSourceId!,
      expectedInvitationRevision: view.invitationRevision!,
      linkId: view.linkId,
      expectedEventRevision: view.eventRevision,
      expectedCalendarRevision: view.calendarRevision,
      expectedApplicationRevision: view.applicationRevision,
    );
    final result = await widget
        .client
        .modules
        .serverpod_calendar
        .calendarInvitation
        .applyBundleUpdate(_request!);
    if (mounted) setState(() => _result = result);
  });
  String _versions(
    List<cal.CalendarInvitationBundleComponentVersion> values,
  ) => values
      .map(
        (v) =>
            '${v.originalStart == null
                ? 'Series'
                : v.isThisAndFuture
                ? 'This and future'
                : 'One occurrence'}: '
            '${v.originalStart == null ? '' : invitationTimingLabel(v.originalStart!)} '
            'SEQUENCE ${v.sequence?.toString() ?? 'omitted (effective 0)'}; ${v.stamp.toIso8601String()}',
      )
      .join('\n');
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Review complete invitation update'),
      actions: [
        IconButton(
          key: const Key('bundle-update-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      key: const Key('bundle-update-scroll'),
      controller: _scroll,
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Apply replaces the complete supported series only when it has no local changes. Receiving an invitation sends no reply. Partial merges and participation responses are separate.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, key: const Key('bundle-update-error')),
        if (_result != null)
          Text(
            'Applied complete update. Event revision ${_result!.eventRevision}.',
            key: const Key('bundle-update-result'),
          ),
        if (_view case final view?) ...[
          Text('Current: ${view.currentContent.summary ?? 'Untitled event'}'),
          Text(
            'Accepted component versions\n${_versions(view.acceptedComponents)}',
          ),
          if (view.acceptedSourceUnavailable)
            const Text(
              'Earlier source body expired. Accepted versions remain available.',
            ),
          if (view.hasLocalChanges)
            const Text(
              'Local changes must be resolved before applying this update.',
              key: Key('bundle-update-conflict'),
            ),
          if (view.incomingContent != null)
            Text(
              'Incoming: ${view.incomingContent!.summary ?? 'Untitled event'}',
            ),
          if (view.incomingComponents != null)
            Text(
              'Incoming component versions\n${_versions(view.incomingComponents!)}',
            ),
          if (view.incomingSourceText != null)
            SelectableText(
              view.incomingSourceText!,
              key: const Key('bundle-update-source'),
            )
          else
            const Text('No selected update is available.'),
          ElevatedButton(
            key: const Key('bundle-update-apply'),
            onPressed:
                _busy || _result != null || (_request == null && !view.canApply)
                ? null
                : _apply,
            child: Text(
              _request == null
                  ? 'Apply complete update'
                  : 'Retry the same complete update',
            ),
          ),
          if (_request != null && _result == null)
            const Text(
              'Retry retains the same request. Refresh explicitly reloads the latest source and revisions.',
            ),
        ],
      ],
    ),
  );
}
