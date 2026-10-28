import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class ItemTextMetadataEditor extends StatefulWidget {
  const ItemTextMetadataEditor({
    super.key,
    required this.client,
    this.event,
    this.task,
  }) : assert((event == null) != (task == null));
  final Client client;
  final cal.CalendarEventView? event;
  final cal.CalendarTaskView? task;
  @override
  State<ItemTextMetadataEditor> createState() => _ItemTextMetadataEditorState();
}

class _CategoryFields {
  _CategoryFields(cal.CalendarItemCategoryGroup value, VoidCallback changed) {
    for (final v in value.values) {
      values.add(TextEditingController(text: v)..addListener(changed));
    }
    language.text = value.language ?? '';
    language.addListener(changed);
  }
  final values = <TextEditingController>[];
  final language = TextEditingController();
  void dispose() {
    for (final v in values) {
      v.dispose();
    }
    language.dispose();
  }

  cal.CalendarItemCategoryGroup value() => cal.CalendarItemCategoryGroup(
    values: values.map((v) => v.text).toList(),
    language: language.text.isEmpty ? null : language.text,
  );
}

class _CommentFields {
  _CommentFields(cal.CalendarItemComment value, VoidCallback changed) {
    text.text = value.value;
    language.text = value.parameters?.language ?? '';
    alternative.text = value.parameters?.alternativeUri ?? '';
    for (final v in [text, language, alternative]) {
      v.addListener(changed);
    }
  }
  final text = TextEditingController(),
      language = TextEditingController(),
      alternative = TextEditingController();
  void dispose() {
    text.dispose();
    language.dispose();
    alternative.dispose();
  }

  cal.CalendarItemComment value() => cal.CalendarItemComment(
    value: text.text,
    parameters: language.text.isEmpty && alternative.text.isEmpty
        ? null
        : cal.CalendarTextParameters(
            language: language.text.isEmpty ? null : language.text,
            alternativeUri: alternative.text.isEmpty ? null : alternative.text,
          ),
  );
}

class _ItemTextMetadataEditorState extends State<ItemTextMetadataEditor> {
  final _url = TextEditingController(),
      _categories = <_CategoryFields>[],
      _comments = <_CommentFields>[];
  final _selected = <cal.CalendarItemTextMetadataField>{};
  String? _classification, _error;
  bool _busy = false, _stale = false;
  Set<String> get _granted =>
      (widget.event?.disclosedGroups.map((g) => g.name) ??
              widget.task!.disclosedGroups.map((g) => g.name))
          .toSet();
  bool has(cal.CalendarItemTextMetadataField f) => _granted.contains(f.name);
  void change(cal.CalendarItemTextMetadataField f) {
    if (mounted) {
      setState(() => _selected.add(f));
    }
  }

  @override
  void initState() {
    super.initState();
    _url.text = widget.event?.url ?? widget.task?.url ?? '';
    _classification =
        widget.event?.classification ?? widget.task?.classification;
    _categories.addAll(
      (widget.event?.categoryGroups ?? widget.task?.categoryGroups ?? []).map(
        (g) => _CategoryFields(
          g,
          () => change(cal.CalendarItemTextMetadataField.categories),
        ),
      ),
    );
    _comments.addAll(
      (widget.event?.comments ?? widget.task?.comments ?? []).map(
        (c) => _CommentFields(
          c,
          () => change(cal.CalendarItemTextMetadataField.comments),
        ),
      ),
    );
    _url.addListener(() => change(cal.CalendarItemTextMetadataField.url));
  }

  @override
  void dispose() {
    _url.dispose();
    for (final g in _categories) {
      g.dispose();
    }
    for (final c in _comments) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final selected = _selected.toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      final patch = cal.CalendarItemTextMetadataPatch(
        selectedFields: selected,
        url:
            _selected.contains(cal.CalendarItemTextMetadataField.url) &&
                _url.text.isNotEmpty
            ? _url.text
            : null,
        classification:
            _selected.contains(cal.CalendarItemTextMetadataField.classification)
            ? _classification
            : null,
        categoryGroups:
            _selected.contains(cal.CalendarItemTextMetadataField.categories)
            ? _categories.map((g) => g.value()).toList()
            : null,
        comments: _selected.contains(cal.CalendarItemTextMetadataField.comments)
            ? _comments.map((c) => c.value()).toList()
            : null,
      );
      final api = widget.client.modules.serverpod_calendar;
      if (widget.event != null) {
        await api.calendarEvent.updateTextMetadata(
          cal.CalendarEventTextMetadataRequest(
            eventId: widget.event!.id,
            expectedRevision: widget.event!.revision,
            patch: patch,
          ),
        );
      } else {
        await api.calendarTask.updateTextMetadata(
          cal.CalendarTaskTextMetadataRequest(
            taskId: widget.task!.id,
            expectedRevision: widget.task!.revision,
            patch: patch,
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on cal.CalendarException catch (e) {
      if (mounted) {
        setState(() {
          _stale = e.code == cal.CalendarFailureCode.staleRevision;
          _error = _stale
              ? 'This item changed. Return and reload before editing.'
              : 'The change was rejected (${e.code.name}).';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Unable to save. Return and reload before retrying.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _busy || _stale;
    Widget field(
      String key,
      String label,
      TextEditingController c, {
      bool multiline = false,
    }) => TextField(
      key: Key(key),
      controller: c,
      enabled: !locked,
      minLines: multiline ? 2 : 1,
      maxLines: multiline ? 6 : 1,
      decoration: InputDecoration(labelText: label),
    );
    void categoriesChanged() =>
        change(cal.CalendarItemTextMetadataField.categories);
    void commentsChanged() =>
        change(cal.CalendarItemTextMetadataField.comments);
    final categoryCount = _categories.fold(0, (n, g) => n + g.values.length);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event != null ? 'Event text and links' : 'Task text and links',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Only edited fields are saved. Other fields remain unchanged. Labels never grant access or book resources. Links are stored without loading them; source contacts and participants are not edited here.',
          ),
          if (_error != null) Text(_error!, key: const Key('item-text-error')),
          if (has(cal.CalendarItemTextMetadataField.url))
            field(
              'item-text-url',
              'Information URL (HTTP/HTTPS; blank clears)',
              _url,
            ),
          if (has(cal.CalendarItemTextMetadataField.classification))
            DropdownButtonFormField<String>(
              key: const Key('item-text-class'),
              initialValue: _classification ?? '',
              decoration: const InputDecoration(
                labelText: 'Classification (host policy controls access)',
              ),
              items: [
                for (final v in ['', 'PUBLIC', 'PRIVATE', 'CONFIDENTIAL'])
                  DropdownMenuItem(
                    value: v,
                    child: Text(
                      v.isEmpty ? 'Absent (RFC effective PUBLIC)' : v,
                    ),
                  ),
              ],
              onChanged: locked
                  ? null
                  : (v) => setState(() {
                      _classification = v == '' ? null : v;
                      _selected.add(
                        cal.CalendarItemTextMetadataField.classification,
                      );
                    }),
            ),
          if (has(cal.CalendarItemTextMetadataField.categories)) ...[
            const Text(
              'Category groups preserve order, duplicates and language. Each field is one nonblank single-line label.',
            ),
            for (var i = 0; i < _categories.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      for (
                        var j = 0;
                        j < _categories[i].values.length;
                        j++
                      ) ...[
                        field(
                          'item-category-value-$i-$j',
                          'Category label',
                          _categories[i].values[j],
                        ),
                        TextButton(
                          onPressed: locked || _categories[i].values.length == 1
                              ? null
                              : () => setState(() {
                                  _categories[i].values.removeAt(j).dispose();
                                  _selected.add(
                                    cal
                                        .CalendarItemTextMetadataField
                                        .categories,
                                  );
                                }),
                          child: const Text('Remove label'),
                        ),
                      ],
                      TextButton(
                        key: Key('item-category-value-add-$i'),
                        onPressed: locked || categoryCount >= 64
                            ? null
                            : () => setState(() {
                                _categories[i].values.add(
                                  TextEditingController()
                                    ..addListener(categoriesChanged),
                                );
                                _selected.add(
                                  cal.CalendarItemTextMetadataField.categories,
                                );
                              }),
                        child: const Text('Add category label'),
                      ),
                      field(
                        'item-category-language-$i',
                        'Language (optional)',
                        _categories[i].language,
                      ),
                      TextButton(
                        onPressed: locked
                            ? null
                            : () => setState(() {
                                _categories.removeAt(i).dispose();
                                _selected.add(
                                  cal.CalendarItemTextMetadataField.categories,
                                );
                              }),
                        child: const Text('Remove category group'),
                      ),
                    ],
                  ),
                ),
              ),
            TextButton(
              key: const Key('item-category-add'),
              onPressed: locked || categoryCount >= 64
                  ? null
                  : () => setState(() {
                      _categories.add(
                        _CategoryFields(
                          cal.CalendarItemCategoryGroup(values: ['']),
                          categoriesChanged,
                        ),
                      );
                      _selected.add(
                        cal.CalendarItemTextMetadataField.categories,
                      );
                    }),
              child: const Text('Add category group'),
            ),
          ],
          if (has(cal.CalendarItemTextMetadataField.comments)) ...[
            const Text(
              'Each comment preserves multiline text, language and alternative representation. Empty text remains a comment; remove it to clear it.',
            ),
            for (var i = 0; i < _comments.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      field(
                        'item-comment-value-$i',
                        'Comment',
                        _comments[i].text,
                        multiline: true,
                      ),
                      field(
                        'item-comment-language-$i',
                        'Language (optional)',
                        _comments[i].language,
                      ),
                      field(
                        'item-comment-alternative-$i',
                        'Alternative representation URI (optional)',
                        _comments[i].alternative,
                      ),
                      TextButton(
                        onPressed: locked
                            ? null
                            : () => setState(() {
                                _comments.removeAt(i).dispose();
                                _selected.add(
                                  cal.CalendarItemTextMetadataField.comments,
                                );
                              }),
                        child: const Text('Remove comment'),
                      ),
                    ],
                  ),
                ),
              ),
            TextButton(
              key: const Key('item-comment-add'),
              onPressed: locked || _comments.length >= 32
                  ? null
                  : () => setState(() {
                      _comments.add(
                        _CommentFields(
                          cal.CalendarItemComment(value: ''),
                          commentsChanged,
                        ),
                      );
                      _selected.add(cal.CalendarItemTextMetadataField.comments);
                    }),
              child: const Text('Add comment'),
            ),
          ],
          if (_granted.intersection({
            'url',
            'classification',
            'categories',
            'comments',
          }).isEmpty)
            const Text('Metadata fields are withheld.'),
          FilledButton(
            key: const Key('item-text-save'),
            onPressed: locked || _selected.isEmpty ? null : save,
            child: const Text('Save changed metadata'),
          ),
        ],
      ),
    );
  }
}
