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
    _categories.text =
        (o == null ? c.categories : o.categories)?.join('\n') ?? '';
    _comments.addAll(
      (o == null ? c.comments : o.comments)?.map(
            (s) => TextEditingController(text: s),
          ) ??
          [],
    );
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
      final next = widget.openingUid == null
          ? c.copyWith(
              summary: summary,
              description: description,
              location: location,
              categories: categories,
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
                      summary: summary,
                      description: description,
                      location: location,
                      categories: categories,
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
              'Categories, one per line (exact spelling)',
              _categories,
              lines: 3,
            ),
            for (var i = 0; i < _comments.length; i++)
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
                        : () => setState(() => _comments.removeAt(i).dispose()),
                    icon: const Icon(Icons.remove),
                  ),
                ],
              ),
            TextButton(
              key: const Key('availability-comment-add'),
              onPressed: locked
                  ? null
                  : () =>
                        setState(() => _comments.add(TextEditingController())),
              child: const Text('Add comment'),
            ),
            if (widget.openingUid == null) ...[
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
