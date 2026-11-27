import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:flutter/material.dart';

import 'protocol_metadata_editor.dart';
import 'supplemental_metadata_editor.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.client});
  final Client client;
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _items = <cal.CalendarView>[];
  final _category = TextEditingController(),
      _language = TextEditingController();
  cal.CalendarCategoryFilter? _filter;
  String? _cursor, _error;
  bool _busy = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final page = await widget.client.modules.serverpod_calendar.calendar.list(
        pageSize: 25,
        fieldGroups: cal.CalendarFieldGroup.values,
        cursor: more ? _cursor : null,
        categoryFilter: _filter,
      );
      if (mounted) {
        setState(() {
          if (!more) {
            _items.clear();
          }
          _items.addAll(page.calendars);
          _cursor = page.nextCursor;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _message(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _category.dispose();
    _language.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_category.text.isEmpty && _language.text.isNotEmpty) {
      setState(() {
        _error = 'Enter category text to filter by language.';
      });
      return;
    }
    _filter = _category.text.isEmpty
        ? null
        : cal.CalendarCategoryFilter(
            value: _category.text,
            language: _language.text.isEmpty ? null : _language.text,
          );
    await _load();
  }

  Future<void> _open([cal.CalendarView? item]) async {
    if (item == null) {
      _filter = null;
      _category.clear();
      _language.clear();
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CalendarEditor(client: widget.client, calendar: item),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('My calendars'),
      actions: [
        IconButton(
          key: const Key('calendar-refresh'),
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh calendars',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('calendar-create'),
      onPressed: _busy ? null : () => _open(),
      icon: const Icon(Icons.add),
      label: const Text('New calendar'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        const Text(
          'Calendars in your private demo scope. Subject links do not grant access.',
        ),
        TextField(
          key: const Key('calendar-category-search'),
          controller: _category,
          enabled: !_busy,
          decoration: const InputDecoration(
            labelText: 'Category filter',
            helperText: 'Exact text; empty means all calendars',
          ),
        ),
        TextField(
          key: const Key('calendar-category-language'),
          controller: _language,
          enabled: !_busy,
          decoration: const InputDecoration(
            labelText: 'Category language filter',
            helperText: 'Optional; empty matches any language',
          ),
        ),
        TextButton(
          key: const Key('calendar-category-apply'),
          onPressed: _busy ? null : _search,
          child: const Text('Apply category filter'),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('calendar-error')),
        if (!_busy && _items.isEmpty && _error == null)
          Text(
            _filter == null ? 'No calendars yet.' : 'No matching calendars.',
          ),
        for (final item in _items)
          Card(
            child: ListTile(
              key: ValueKey('calendar-${item.id}'),
              leading: item.color == null
                  ? null
                  : CircleAvatar(
                      backgroundColor: Color(
                        int.parse('FF${item.color!.substring(1)}', radix: 16),
                      ),
                    ),
              title: Text(item.displayName ?? 'Calendar'),
              subtitle: Text(
                item.availabilityZoneId ?? 'Settings not disclosed',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy ? null : () => _open(item),
            ),
          ),
        if (_cursor != null)
          TextButton(
            key: const Key('calendar-more'),
            onPressed: _busy ? null : () => _load(more: true),
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}

class CalendarEditor extends StatefulWidget {
  const CalendarEditor({super.key, required this.client, this.calendar});
  final Client client;
  final cal.CalendarView? calendar;
  @override
  State<CalendarEditor> createState() => _CalendarEditorState();
}

class _CalendarEditorState extends State<CalendarEditor> {
  late final TextEditingController _name, _zone, _description, _color;
  final _protocol = GlobalKey<ProtocolMetadataEditorState>();
  final _supplemental = GlobalKey<SupplementalMetadataEditorState>();
  cal.CalendarView? _calendar;
  cal.CalendarNoRuleFallback _fallback = cal.CalendarNoRuleFallback.free;
  List<cal.CalendarSubjectView> _subjects = [];
  String? _error;
  bool _busy = false;
  bool _requiresReload = false;
  @override
  void initState() {
    super.initState();
    _calendar = widget.calendar;
    _name = TextEditingController(text: _calendar?.displayName ?? '');
    _description = TextEditingController(text: _calendar?.description ?? '');
    _color = TextEditingController(text: _calendar?.color ?? '');
    _zone = TextEditingController(
      text: _calendar?.availabilityZoneId ?? 'Europe/Stockholm',
    );
    _fallback = _calendar?.noRuleFallback ?? cal.CalendarNoRuleFallback.free;
    if (_calendar != null) _run(_readSubjects);
  }

  @override
  void dispose() {
    _name.dispose();
    _zone.dispose();
    _description.dispose();
    _color.dispose();
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
        setState(() {
          _error = _message(e);
          if (e is cal.CalendarException &&
              e.code == cal.CalendarFailureCode.staleRevision) {
            _requiresReload = true;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _readSubjects() async {
    final subjects = await widget.client.modules.serverpod_calendar.calendar
        .subjects(_calendar!.id);
    if (mounted) {
      setState(() {
        _subjects = subjects;
      });
    }
  }

  Future<void> _refresh({
    bool presentation = false,
    bool settings = false,
    bool protocol = false,
    bool supplemental = false,
    int? afterRevision,
  }) async {
    final view = await widget.client.modules.serverpod_calendar.calendar
        .getCalendar(_calendar!.id, cal.CalendarFieldGroup.values);
    if (mounted) {
      setState(() {
        _calendar = view;
        _requiresReload =
            afterRevision != null && view.revision != afterRevision;
        if (_requiresReload) {
          _error =
              'This calendar changed again. Reload saved values before saving.';
        }
        if (presentation && !_requiresReload) {
          _name.text = view.displayName ?? '';
          _description.text = view.description ?? '';
          _color.text = view.color ?? '';
        }
        if (settings && !_requiresReload) {
          _zone.text = view.availabilityZoneId ?? '';
          _fallback = view.noRuleFallback ?? _fallback;
        }
      });
      if (protocol && !_requiresReload && view.protocolMetadata != null) {
        _protocol.currentState?.reset(view.protocolMetadata!);
      }
      if (supplemental &&
          !_requiresReload &&
          view.supplementalMetadata != null) {
        _supplemental.currentState?.reset(view.supplementalMetadata!);
      }
    }
    await _readSubjects();
  }

  Future<void> _reload() => _refresh(
    presentation: true,
    settings: true,
    protocol: true,
    supplemental: true,
  );
  Future<void> _create() => _run(() async {
    await widget.client.modules.serverpod_calendar.calendar.create(
      cal.CalendarCreateRequest(
        displayName: _name.text,
        description: _description.text,
        color: _color.text,
        availabilityZoneId: _zone.text,
        noRuleFallback: _fallback,
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  });
  Future<void> _presentation() => _run(() async {
    final expected = _calendar!.revision;
    await widget.client.modules.serverpod_calendar.calendar.updatePresentation(
      cal.CalendarPresentationUpdateRequest(
        calendarId: _calendar!.id,
        expectedRevision: expected,
        displayName: _name.text,
        description: _description.text,
        color: _color.text,
      ),
    );
    await _refresh(presentation: true, afterRevision: expected + 1);
  });
  Future<void> _saveProtocol() => _run(() async {
    final expected = _calendar!.revision;
    final metadata = _protocol.currentState!.value;
    await widget.client.modules.serverpod_calendar.calendar
        .updateProtocolMetadata(
          cal.CalendarProtocolMetadataUpdateRequest(
            calendarId: _calendar!.id,
            expectedRevision: expected,
            metadata: metadata,
          ),
        );
    await _refresh(protocol: true, afterRevision: expected + 1);
  });
  Future<void> _saveSupplemental() => _run(() async {
    final expected = _calendar!.revision;
    final metadata = _supplemental.currentState!.value;
    await widget.client.modules.serverpod_calendar.calendar
        .updateSupplementalMetadata(
          cal.CalendarSupplementalMetadataUpdateRequest(
            calendarId: _calendar!.id,
            expectedRevision: expected,
            metadata: metadata,
          ),
        );
    await _refresh(supplemental: true, afterRevision: expected + 1);
  });
  Future<void> _settings() => _run(() async {
    final expected = _calendar!.revision;
    await widget.client.modules.serverpod_calendar.calendar.updateSettings(
      cal.CalendarSettingsUpdateRequest(
        calendarId: _calendar!.id,
        expectedRevision: expected,
        availabilityZoneId: _zone.text,
        noRuleFallback: _fallback,
      ),
    );
    await _refresh(settings: true, afterRevision: expected + 1);
  });
  Future<void> _subject(
    cal.CalendarSubjectAction action, {
    cal.CalendarSubjectView? subject,
  }) => _run(() async {
    final expected = _calendar!.revision;
    final principal = await widget.client.smoke.whoAmI();
    await widget.client.modules.serverpod_calendar.calendar.changeSubject(
      cal.CalendarSubjectChangeRequest(
        calendarId: _calendar!.id,
        expectedRevision: expected,
        action: action,
        namespace: subject?.namespace ?? 'demo',
        kind: subject?.kind ?? 'user',
        externalId: subject?.externalId ?? principal,
        contributesAvailability: subject == null
            ? true
            : !subject.contributesAvailability,
      ),
    );
    await _refresh(afterRevision: expected + 1);
  });
  Future<void> _delete() => _run(() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete calendar?'),
        content: const Text('Only an unreferenced calendar can be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('calendar-confirm-delete'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await widget.client.modules.serverpod_calendar.calendar.delete(
      _calendar!.id,
      _calendar!.revision,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  });
  @override
  Widget build(BuildContext context) {
    final locked = _busy || _requiresReload;
    final existing = _calendar != null;
    final presentation =
        !existing ||
        _calendar!.disclosedGroups.contains(cal.CalendarFieldGroup.metadata);
    final settings =
        !existing ||
        _calendar!.disclosedGroups.contains(
          cal.CalendarFieldGroup.availabilitySettings,
        );
    return Scaffold(
      appBar: AppBar(title: Text(existing ? 'Edit calendar' : 'New calendar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_busy) const LinearProgressIndicator(),
                if (_error != null)
                  Text(_error!, key: const Key('calendar-error')),
                if (existing)
                  TextButton(
                    key: const Key('calendar-reload'),
                    onPressed: _busy ? null : () => _run(_reload),
                    child: const Text('Reload saved values'),
                  ),
                if (presentation) ...[
                  TextField(
                    key: const Key('calendar-name'),
                    controller: _name,
                    enabled: !locked,
                    decoration: const InputDecoration(
                      labelText: 'Native name',
                      helperText:
                          '1-256 Unicode code points; duplicate names allowed',
                    ),
                  ),
                  TextField(
                    key: const Key('calendar-description'),
                    controller: _description,
                    enabled: !locked,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Native description',
                      helperText: 'Plain text, up to 16,384 Unicode code points; empty clears it',
                    ),
                  ),
                  TextField(
                    key: const Key('calendar-color'),
                    controller: _color,
                    enabled: !locked,
                    decoration: const InputDecoration(
                      labelText: 'Native color',
                      helperText: '#RRGGBB; empty clears it',
                    ),
                  ),
                  if (existing)
                    FilledButton(
                      key: const Key('calendar-save-name'),
                      onPressed: locked ? null : _presentation,
                      child: const Text('Save native presentation'),
                    ),
                ],
                if (settings) ...[
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('calendar-zone'),
                    controller: _zone,
                    enabled: !locked,
                    decoration: const InputDecoration(
                      labelText: 'Availability timezone',
                      helperText:
                          'Exact IANA name, for example Europe/Stockholm',
                    ),
                  ),
                  DropdownButtonFormField<cal.CalendarNoRuleFallback>(
                    key: ValueKey(_fallback),
                    initialValue: _fallback,
                    decoration: const InputDecoration(
                      labelText: 'When no availability rule applies',
                    ),
                    items: [
                      for (final value in cal.CalendarNoRuleFallback.values)
                        DropdownMenuItem(value: value, child: Text(value.name)),
                    ],
                    onChanged: locked
                        ? null
                        : (v) {
                            if (v != null) {
                              setState(() {
                                _fallback = v;
                              });
                            }
                          },
                  ),
                  if (existing)
                    FilledButton(
                      key: const Key('calendar-save-settings'),
                      onPressed: locked ? null : _settings,
                      child: const Text('Save availability settings'),
                    ),
                ],
                if (!existing)
                  FilledButton(
                    key: const Key('calendar-submit-create'),
                    onPressed: locked ? null : _create,
                    child: const Text('Create calendar'),
                  ),
                if (existing && _calendar!.protocolMetadata != null)
                  ProtocolMetadataEditor(
                    key: _protocol,
                    initial: _calendar!.protocolMetadata!,
                    busy: locked,
                    canCopyNative: presentation,
                    nativeName: () => _name.text,
                    nativeDescription: () => _description.text,
                    onSave: _saveProtocol,
                  ),
                if (existing && _calendar!.supplementalMetadata != null)
                  SupplementalMetadataEditor(
                    key: _supplemental,
                    initial: _calendar!.supplementalMetadata!,
                    busy: locked,
                    onSave: _saveSupplemental,
                  ),
                if (existing) ...[
                  const SizedBox(height: 24),
                  const Text('Subject associations'),
                  const Text(
                    'A link identifies whose availability this calendar contributes to; it does not grant permissions. Availability calculation follows in a later batch.',
                  ),
                  for (final subject in _subjects)
                    Card(
                      child: Column(
                        children: [
                          Text(
                            '${subject.namespace}:${subject.kind}:${subject.externalId}',
                          ),
                          SwitchListTile(
                            title: const Text('Contributes availability'),
                            value: subject.contributesAvailability,
                            onChanged: locked
                                ? null
                                : (_) => _subject(
                                    cal.CalendarSubjectAction.setContribution,
                                    subject: subject,
                                  ),
                          ),
                          TextButton(
                            key: const Key('calendar-detach'),
                            onPressed: locked
                                ? null
                                : () => _subject(
                                    cal.CalendarSubjectAction.detach,
                                    subject: subject,
                                  ),
                            child: const Text('Remove association'),
                          ),
                        ],
                      ),
                    ),
                  if (_subjects.isEmpty)
                    TextButton(
                      key: const Key('calendar-attach-self'),
                      onPressed: locked
                          ? null
                          : () => _subject(cal.CalendarSubjectAction.attach),
                      child: const Text('Associate my availability'),
                    ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    key: const Key('calendar-delete'),
                    onPressed: locked ? null : _delete,
                    child: const Text('Delete calendar'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _message(Object error) => error is FormatException
    ? error.message
    : error is cal.CalendarException
    ? (error.code == cal.CalendarFailureCode.staleRevision
          ? 'This calendar changed. Reload saved values before trying again.'
          : error.message)
    : 'Unable to complete the request. Try again after checking your connection.';
