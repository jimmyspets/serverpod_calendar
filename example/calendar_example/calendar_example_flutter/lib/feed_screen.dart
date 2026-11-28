import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_calendar_feed_client/serverpod_calendar_feed_client.dart'
    as feed;

import 'protocol_metadata_editor.dart';
import 'supplemental_metadata_editor.dart';

String _message(Object e) => e is feed.CalendarFeedException
    ? e.message
    : e is FormatException
    ? e.message
    : 'Could not complete the operation. Refresh and try again.';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.client});
  final Client client;
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<feed.CalendarFeedView> _feeds = [];
  bool _busy = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final values = await widget
          .client
          .modules
          .serverpod_calendar_feed
          .calendarFeed
          .list();
      if (mounted) setState(() => _feeds = values);
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit([feed.CalendarFeedView? value]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FeedEditor(client: widget.client, id: value?.id),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _urls(feed.CalendarFeedView value) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            FeedCredentialsScreen(client: widget.client, id: value.id),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Subscription feeds'),
      actions: [
        IconButton(
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Read-only event subscriptions. Choose calendars and explicit feed presentation. '
          'Tasks, working-hours rules and alarms are excluded. Anyone holding a subscription URL can forward it.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('feed-error')),
        FilledButton(
          key: const Key('feed-create'),
          onPressed: _busy ? null : () => _edit(),
          child: const Text('Create feed'),
        ),
        for (final value in _feeds)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value.displayName),
                  Text('${value.calendarIds.length} selected calendars'),
                  Wrap(
                    spacing: 12,
                    children: [
                      TextButton(
                        key: Key('feed-edit-${value.id}'),
                        onPressed: _busy ? null : () => _edit(value),
                        child: const Text('Edit feed'),
                      ),
                      TextButton(
                        key: Key('feed-urls-${value.id}'),
                        onPressed: _busy ? null : () => _urls(value),
                        child: const Text('Subscription URLs'),
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

class FeedEditor extends StatefulWidget {
  const FeedEditor({super.key, required this.client, this.id});
  final Client client;
  final feed.UuidValue? id;
  @override
  State<FeedEditor> createState() => _FeedEditorState();
}

class _FeedEditorState extends State<FeedEditor> {
  final _name = TextEditingController();
  final _selected = <feed.UuidValue>{};
  final _calendars = <cal.CalendarView>[];
  var _protocol = GlobalKey<ProtocolMetadataEditorState>();
  var _extra = GlobalKey<SupplementalMetadataEditorState>();
  cal.CalendarProtocolMetadata _text = cal.CalendarProtocolMetadata(
    names: [],
    descriptions: [],
  );
  cal.CalendarSupplementalMetadata _supplemental =
      cal.CalendarSupplementalMetadata(categories: [], images: []);
  feed.CalendarFeedView? _view;
  String? _cursor, _error;
  bool _busy = true;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
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
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load() => _run(() async {
    setState(() => _loaded = false);
    final view = widget.id == null
        ? null
        : await widget.client.modules.serverpod_calendar_feed.calendarFeed.read(
            widget.id!,
          );
    final page = await widget.client.modules.serverpod_calendar.calendar.list(
      pageSize: 25,
      fieldGroups: [cal.CalendarFieldGroup.metadata],
    );
    if (!mounted) return;
    setState(() {
      _view = view;
      _name.text = view?.displayName ?? '';
      _selected
        ..clear()
        ..addAll(view?.calendarIds ?? []);
      _calendars
        ..clear()
        ..addAll(page.calendars);
      _cursor = page.nextCursor;
      _text =
          view?.protocolMetadata ??
          cal.CalendarProtocolMetadata(names: [], descriptions: []);
      _supplemental =
          view?.supplementalMetadata ??
          cal.CalendarSupplementalMetadata(categories: [], images: []);
      _protocol = GlobalKey<ProtocolMetadataEditorState>();
      _extra = GlobalKey<SupplementalMetadataEditorState>();
      _loaded = true;
    });
  });
  Future<void> _more() => _run(() async {
    final page = await widget.client.modules.serverpod_calendar.calendar.list(
      pageSize: 25,
      fieldGroups: [cal.CalendarFieldGroup.metadata],
      cursor: _cursor,
    );
    if (mounted) {
      setState(() {
        _calendars.addAll(page.calendars);
        _cursor = page.nextCursor;
      });
    }
  });
  Future<void> _save() => _run(() async {
    if (!_loaded) return;
    final value = feed.CalendarFeedSettings(
      displayName: _name.text,
      calendarIds: _selected.toList(),
      protocolMetadata: _protocol.currentState?.value ?? _text,
      supplementalMetadata: _extra.currentState?.value ?? _supplemental,
    );
    final api = widget.client.modules.serverpod_calendar_feed.calendarFeed;
    if (_view == null) {
      await api.create(value);
    } else {
      await api.update(_view!.id, _view!.revision, value);
    }
    if (mounted) Navigator.of(context).pop();
  });
  Future<void> _delete() => _run(() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete feed?'),
        content: const Text(
          'All its subscription URLs will stop working. Selected calendars and events remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('feed-confirm-delete'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete feed'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.client.modules.serverpod_calendar_feed.calendarFeed.delete(
      _view!.id,
      _view!.revision,
    );
    if (mounted) Navigator.of(context).pop();
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.id == null
            ? 'Create subscription feed'
            : 'Edit subscription feed',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('feed-error')),
        TextField(
          key: const Key('feed-name'),
          controller: _name,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Feed management label'),
        ),
        const Text(
          'Select one to sixteen calendars. The server rechecks publication permission for every source. '
          'A missing, unsupported or unauthorized source prevents the whole feed from being published.',
        ),
        for (final calendar in _calendars)
          CheckboxListTile(
            key: Key('feed-calendar-${calendar.id}'),
            title: Text(calendar.displayName ?? calendar.id.toString()),
            value: _selected.contains(calendar.id),
            onChanged:
                _busy ||
                    !_selected.contains(calendar.id) && _selected.length >= 16
                ? null
                : (value) => setState(() {
                    if (value == true) {
                      _selected.add(calendar.id);
                    } else {
                      _selected.remove(calendar.id);
                    }
                  }),
          ),
        for (final id
            in _selected
                .where((id) => !_calendars.any((c) => c.id == id))
                .toList())
          CheckboxListTile(
            key: Key('feed-calendar-$id'),
            title: Text('Selected calendar $id'),
            value: true,
            onChanged: _busy
                ? null
                : (_) => setState(() => _selected.remove(id)),
          ),
        if (_cursor != null)
          TextButton(
            onPressed: _busy ? null : _more,
            child: const Text('More calendars'),
          ),
        ExpansionTile(
          title: const Text('Publication text and color'),
          maintainState: true,
          children: [
            const Text(
              'These are feed values, separate from management labels and calendar metadata. Copying is explicit.',
            ),
            ProtocolMetadataEditor(
              key: _protocol,
              initial: _text,
              busy: _busy || !_loaded,
              nativeName: () => _name.text,
              nativeDescription: () => '',
              onSave: _save,
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Publication links and hints'),
          maintainState: true,
          children: [
            SupplementalMetadataEditor(
              key: _extra,
              initial: _supplemental,
              busy: _busy || !_loaded,
              onSave: _save,
            ),
          ],
        ),
        FilledButton(
          key: const Key('feed-save'),
          onPressed: _busy || !_loaded ? null : _save,
          child: const Text('Save feed'),
        ),
        if (_view != null) ...[
          Text(
            'Revision ${_view!.revision}. Publication identity ${_view!.protocolUid}.',
          ),
          TextButton(
            onPressed: _busy ? null : _load,
            child: const Text('Reload saved settings'),
          ),
          TextButton(
            key: const Key('feed-delete'),
            onPressed: _busy ? null : _delete,
            child: const Text('Delete feed'),
          ),
        ],
      ],
    ),
  );
}

class FeedCredentialsScreen extends StatefulWidget {
  const FeedCredentialsScreen({
    super.key,
    required this.client,
    required this.id,
  });
  final Client client;
  final feed.UuidValue id;
  @override
  State<FeedCredentialsScreen> createState() => _FeedCredentialsScreenState();
}

class _FeedCredentialsScreenState extends State<FeedCredentialsScreen> {
  feed.CalendarFeedView? _view;
  List<feed.CalendarFeedCredentialView> _credentials = [];
  bool _busy = true;
  String? _error;
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
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    final api = widget.client.modules.serverpod_calendar_feed.calendarFeed;
    final view = await api.read(widget.id),
        credentials = await api.credentials(widget.id);
    if (mounted) {
      setState(() {
        _view = view;
        _credentials = credentials;
      });
    }
  }

  Future<void> _load() => _run(_refresh);
  Future<void> _issue() => _run(() async {
    var label = '';
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create subscription URL'),
        content: TextField(
          key: const Key('feed-url-label'),
          onChanged: (value) => label = value,
          decoration: const InputDecoration(
            labelText: 'Optional subscriber label',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('feed-url-confirm'),
            onPressed: () => Navigator.pop(context, label),
            child: const Text('Create URL'),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    final created = await widget
        .client
        .modules
        .serverpod_calendar_feed
        .calendarFeed
        .createCredential(widget.id, _view!.revision, chosen);
    if (!mounted) return;
    // Show the one-time result before making any follow-up request that can fail.
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save this subscription URL now'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This URL is shown only once. Anyone holding it can read the selected events. '
                'Revocation stops future origin access and cannot erase downloaded copies. Calendar apps decide when to refresh.',
              ),
              SelectableText(created.url, key: const Key('feed-created-url')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: created.url)),
            child: const Text('Copy URL'),
          ),
          FilledButton(
            key: const Key('feed-url-close'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    await _refresh();
  });
  Future<void> _revoke(
    feed.CalendarFeedCredentialView credential,
  ) => _run(() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke this URL?'),
        content: const Text(
          'This URL will stop working. Other subscription URLs remain active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('feed-confirm-revoke'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.client.modules.serverpod_calendar_feed.calendarFeed
        .revokeCredential(
          widget.id,
          _view!.revision,
          credential.id,
          credential.revision,
        );
    await _refresh();
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Subscription URLs'),
      actions: [
        IconButton(
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('feed-error')),
        if (_view != null) Text(_view!.displayName),
        const Text(
          'Existing secrets cannot be retrieved. Create a new URL to replace a lost one. '
          'These subscriptions never publish alarms; personal reminders use the native notification flow.',
        ),
        FilledButton(
          key: const Key('feed-url-create'),
          onPressed:
              _busy ||
                  _view == null ||
                  _credentials.where((c) => c.revokedAt == null).length >= 16
              ? null
              : _issue,
          child: const Text('Create subscription URL'),
        ),
        for (final value in _credentials)
          ListTile(
            title: Text(value.label ?? value.id.toString()),
            subtitle: Text(value.revokedAt == null ? 'Active' : 'Revoked'),
            trailing: value.revokedAt != null
                ? null
                : TextButton(
                    key: Key('feed-revoke-${value.id}'),
                    onPressed: _busy ? null : () => _revoke(value),
                    child: const Text('Revoke URL'),
                  ),
          ),
      ],
    ),
  );
}
