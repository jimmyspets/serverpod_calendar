import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'occurrence_timing_editor.dart' show occurrenceError;

class AvailabilityMetadataEditor extends StatefulWidget {
  const AvailabilityMetadataEditor({
    super.key,
    required this.client,
    required this.rule,
    this.openingUid,
  });
  final Client client;
  final cal.CalendarAvailabilityView rule;
  final UuidValue? openingUid;
  @override
  State<AvailabilityMetadataEditor> createState() =>
      _AvailabilityMetadataEditorState();
}

class _AvailabilityMetadataEditorState
    extends State<AvailabilityMetadataEditor> {
  final _summary = TextEditingController(),
      _description = TextEditingController(),
      _location = TextEditingController();
  final _categories = TextEditingController(), _url = TextEditingController();
  final _comments = <TextEditingController>[];
  final _summaryParameters = _TextParameters(),
      _descriptionParameters = _TextParameters(),
      _locationParameters = _TextParameters();
  final _commentParameters = <_TextParameters>[];
  final _categoryLanguage = TextEditingController();
  List<cal.CalendarAvailabilityCategoryGroup>? _groups;
  List<cal.CalendarAvailabilityText>? _contacts;
  final _organizerAddress = TextEditingController(),
      _organizerName = TextEditingController(),
      _organizerLanguage = TextEditingController(),
      _organizerDirectory = TextEditingController();
  final _extensions = <_ExtensionFields>[];
  cal.CalendarAvailabilityClass? _classification;
  bool _busy = false, _stale = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final c = widget.rule.content;
    final o = widget.openingUid == null
        ? null
        : c.openings.singleWhere((o) => o.uid == widget.openingUid);
    _summary.text = o == null ? c.summary ?? '' : o.summary ?? '';
    _description.text = o == null ? c.description ?? '' : o.description ?? '';
    _location.text = o == null ? c.location ?? '' : o.location ?? '';
    _groups = o == null ? c.categoryGroups : o.categoryGroups;
    _contacts = o == null ? c.contacts : o.contacts;
    _categories.text =
        (_groups?.firstOrNull?.values ??
                (o == null ? c.categories : o.categories))
            ?.join('\n') ??
        '';
    _comments.addAll(
      (o == null ? c.comments : o.comments)?.map(
            (s) => TextEditingController(text: s),
          ) ??
          [],
    );
    final parameters = o == null ? c.textParameters : o.textParameters;
    _summaryParameters.load(parameters?.summary);
    _descriptionParameters.load(parameters?.description);
    _locationParameters.load(parameters?.location);
    _categoryLanguage.text =
        _groups?.firstOrNull?.language ?? parameters?.categoryLanguage ?? '';
    for (var i = 0; i < _comments.length; i++) {
      _commentParameters.add(_TextParameters()..load(parameters?.comments?[i]));
    }
    for (final v
        in (o == null ? c.extensions : o.extensions) ??
            <cal.CalendarAvailabilityExtension>[]) {
      _extensions.add(_ExtensionFields(v.name, v.value));
    }
    _organizerAddress.text = c.organizer?.address ?? '';
    _organizerName.text = c.organizer?.commonName ?? '';
    _organizerLanguage.text = c.organizer?.language ?? '';
    _organizerDirectory.text = c.organizer?.directoryUri ?? '';
    _url.text = c.url ?? '';
    _classification = c.classification;
  }

  @override
  void dispose() {
    for (final c in [
      _summary,
      _description,
      _location,
      _categories,
      _url,
      ..._comments,
      _categoryLanguage,
      _organizerAddress,
      _organizerName,
      _organizerLanguage,
      _organizerDirectory,
      for (final p in [
        _summaryParameters,
        _descriptionParameters,
        _locationParameters,
        ..._commentParameters,
      ]) ...[p.language, p.uri],
      for (final e in _extensions) ...[e.name, e.value],
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final c = widget.rule.content;
      final summary = _summary.text.isEmpty ? null : _summary.text;
      final description = _description.text.isEmpty ? null : _description.text;
      final location = _location.text.isEmpty ? null : _location.text;
      final categories = _categories.text.isEmpty
          ? <String>[]
          : _categories.text.split('\n');
      final comments = _comments.map((c) => c.text).toList();
      final parameters = cal.CalendarAvailabilityTextParameters(
        summary: _summaryParameters.value,
        description: _descriptionParameters.value,
        location: _locationParameters.value,
        categoryLanguage: _groups != null || _categoryLanguage.text.isEmpty
            ? null
            : _categoryLanguage.text,
        comments: _commentParameters.map((p) => p.value).toList(),
      );
      final extensions = [
        for (final e in _extensions)
          cal.CalendarAvailabilityExtension(
            name: e.name.text,
            value: e.value.text,
          ),
      ];
      final next = widget.openingUid == null
          ? c.copyWith(
              textParameters: parameters,
              extensions: extensions,
              organizer: _organizerAddress.text.isEmpty
                  ? null
                  : cal.CalendarAvailabilityOrganizer(
                      address: _organizerAddress.text,
                      commonName: _organizerName.text.isEmpty
                          ? null
                          : _organizerName.text,
                      language: _organizerLanguage.text.isEmpty
                          ? null
                          : _organizerLanguage.text,
                      directoryUri: _organizerDirectory.text.isEmpty
                          ? null
                          : _organizerDirectory.text,
                    ),
              summary: summary,
              description: description,
              location: location,
              categories: _groups == null ? categories : null,
              categoryGroups: _groups == null
                  ? null
                  : [
                      if (categories.isNotEmpty)
                        cal.CalendarAvailabilityCategoryGroup(
                          values: categories,
                          language: _categoryLanguage.text.isEmpty
                              ? null
                              : _categoryLanguage.text,
                        ),
                      ..._groups!.skip(1),
                    ],
              comments: comments,
              url: _url.text.isEmpty ? null : _url.text,
              classification: _classification,
            )
          : c.copyWith(
              openings: [
                for (final o in c.openings)
                  if (o.uid != widget.openingUid)
                    o
                  else
                    o.copyWith(
                      textParameters: parameters,
                      extensions: extensions,
                      summary: summary,
                      description: description,
                      location: location,
                      categories: _groups == null ? categories : null,
                      categoryGroups: _groups == null
                          ? null
                          : [
                              if (categories.isNotEmpty)
                                cal.CalendarAvailabilityCategoryGroup(
                                  values: categories,
                                  language: _categoryLanguage.text.isEmpty
                                      ? null
                                      : _categoryLanguage.text,
                                ),
                              ..._groups!.skip(1),
                            ],
                      comments: comments,
                    ),
              ],
            );
      await widget.client.modules.serverpod_calendar.calendarAvailability
          .updateMetadata(
            cal.CalendarAvailabilityUpdateRequest(
              availabilityId: widget.rule.id,
              expectedRevision: widget.rule.revision,
              content: next,
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = occurrenceError(e);
          _stale =
              e is cal.CalendarException &&
              e.code == cal.CalendarFailureCode.staleRevision;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _busy || _stale;
    Widget field(
      String key,
      String label,
      TextEditingController c, {
      int lines = 1,
    }) => TextField(
      key: Key(key),
      controller: c,
      enabled: !locked,
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.openingUid == null
              ? 'Definition metadata'
              : 'Opening metadata',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Labels and links do not grant access, book resources or change opening hours. Links are stored without fetching.',
            ),
            if (_error != null)
              Text(_error!, key: const Key('availability-metadata-error')),
            if (_stale)
              const Text(
                'Saved values changed. Close and reopen; your draft was not applied.',
              ),
            field('availability-meta-summary', 'Summary', _summary),
            field(
              'availability-meta-description',
              'Description',
              _description,
              lines: 4,
            ),
            field('availability-meta-location', 'Location', _location),
            field(
              'availability-meta-categories',
              _groups == null
                  ? 'Categories, one per line (exact spelling)'
                  : 'First category group, one per line (exact spelling)',
              _categories,
              lines: 3,
            ),
            if ((_groups?.length ?? 0) > 1)
              Text(
                'Additional category groups are preserved: ${_groups!.skip(1).map((g) => '${g.values.join(', ')} (${g.language ?? 'no language'})').join('; ')}',
              ),
            if (_contacts?.isNotEmpty ?? false)
              Text(
                'Imported contacts (preserved): ${_contacts!.map((v) => v.value).join('; ')}',
              ),
            ExpansionTile(
              key: const Key('availability-text-parameters'),
              title: const Text('Text language and alternative links'),
              children: [
                for (final p in [
                  ('summary', _summaryParameters),
                  ('description', _descriptionParameters),
                  ('location', _locationParameters),
                ]) ...[
                  field(
                    'availability-${p.$1}-language',
                    '${p.$1} language tag',
                    p.$2.language,
                  ),
                  field(
                    'availability-${p.$1}-altrep',
                    '${p.$1} alternative URI (stored only)',
                    p.$2.uri,
                  ),
                ],
                field(
                  'availability-category-language',
                  'Category language tag',
                  _categoryLanguage,
                ),
              ],
            ),
            for (var i = 0; i < _comments.length; i++)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: field(
                          'availability-comment-$i',
                          'Comment',
                          _comments[i],
                          lines: 3,
                        ),
                      ),
                      IconButton(
                        onPressed: locked
                            ? null
                            : () => setState(() {
                                _comments.removeAt(i).dispose();
                                _commentParameters.removeAt(i).dispose();
                              }),
                        icon: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text('Comment language and alternative link'),
                    children: [
                      field(
                        'availability-comment-$i-language',
                        'Comment language tag',
                        _commentParameters[i].language,
                      ),
                      field(
                        'availability-comment-$i-altrep',
                        'Comment alternative URI (stored only)',
                        _commentParameters[i].uri,
                      ),
                    ],
                  ),
                ],
              ),
            TextButton(
              key: const Key('availability-comment-add'),
              onPressed: locked
                  ? null
                  : () => setState(() {
                      _comments.add(TextEditingController());
                      _commentParameters.add(_TextParameters());
                    }),
              child: const Text('Add comment'),
            ),
            ExpansionTile(
              title: const Text('Private host extensions'),
              children: [
                const Text(
                  'This demo accepts X-CALENDAR-EXAMPLE-LABEL, a single-line label up to 256 characters.',
                ),
                for (var i = 0; i < _extensions.length; i++)
                  Column(
                    children: [
                      field(
                        'availability-extension-$i-name',
                        'Registered extension name',
                        _extensions[i].name,
                      ),
                      field(
                        'availability-extension-$i-value',
                        'Value',
                        _extensions[i].value,
                      ),
                      TextButton(
                        onPressed: locked
                            ? null
                            : () => setState(
                                () => _extensions.removeAt(i).dispose(),
                              ),
                        child: const Text('Remove extension'),
                      ),
                    ],
                  ),
                TextButton(
                  key: const Key('availability-extension-add'),
                  onPressed: locked
                      ? null
                      : () => setState(
                          () => _extensions.add(
                            _ExtensionFields('X-CALENDAR-EXAMPLE-LABEL', ''),
                          ),
                        ),
                  child: const Text('Add extension'),
                ),
              ],
            ),
            if (widget.openingUid == null) ...[
              ExpansionTile(
                title: const Text('Organizer publication label'),
                children: [
                  const Text(
                    'The host must approve this address. It grants no access and sends no invitations. Empty address clears the organizer.',
                  ),
                  field(
                    'availability-organizer-address',
                    'Calendar address URI',
                    _organizerAddress,
                  ),
                  TextButton(
                    key: const Key('availability-organizer-self'),
                    onPressed: locked
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            try {
                              final principal = await widget.client.smoke
                                  .whoAmI();
                              if (mounted) {
                                setState(
                                  () => _organizerAddress.text =
                                      'urn:calendar-example:user:$principal',
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _error = occurrenceError(e));
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    child: const Text('Use my demo calendar address'),
                  ),
                  field(
                    'availability-organizer-name',
                    'Organizer display name',
                    _organizerName,
                  ),
                  field(
                    'availability-organizer-language',
                    'Display-name language tag',
                    _organizerLanguage,
                  ),
                  field(
                    'availability-organizer-directory',
                    'Directory URI (stored only)',
                    _organizerDirectory,
                  ),
                ],
              ),
              field(
                'availability-meta-url',
                'HTTP/HTTPS information URL',
                _url,
              ),
              DropdownButtonFormField<String>(
                initialValue: _classification?.name ?? 'unspecified',
                decoration: const InputDecoration(
                  labelText: 'Confidentiality label',
                ),
                items: [
                  for (final label in [
                    'unspecified',
                    'public',
                    'private',
                    'confidential',
                  ])
                    DropdownMenuItem(value: label, child: Text(label)),
                ],
                onChanged: locked
                    ? null
                    : (v) => setState(
                        () => _classification = v == 'unspecified'
                            ? null
                            : cal.CalendarAvailabilityClass.values.byName(v!),
                      ),
              ),
            ],
            ElevatedButton(
              key: const Key('availability-metadata-save'),
              onPressed: locked ? null : _save,
              child: const Text('Save metadata'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextParameters {
  final language = TextEditingController(), uri = TextEditingController();
  void load(cal.CalendarTextParameters? p) {
    language.text = p?.language ?? '';
    uri.text = p?.alternativeUri ?? '';
  }

  cal.CalendarTextParameters? get value =>
      language.text.isEmpty && uri.text.isEmpty
      ? null
      : cal.CalendarTextParameters(
          language: language.text.isEmpty ? null : language.text,
          alternativeUri: uri.text.isEmpty ? null : uri.text,
        );
  void dispose() {
    language.dispose();
    uri.dispose();
  }
}

class _ExtensionFields {
  _ExtensionFields(String name, String value)
    : name = TextEditingController(text: name),
      value = TextEditingController(text: value);
  final TextEditingController name, value;
  void dispose() {
    name.dispose();
    value.dispose();
  }
}
