import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Edits decoded metadata only; no import, export, automatic copying or fetching.
class ProtocolMetadataEditor extends StatefulWidget {
  const ProtocolMetadataEditor({
    super.key,
    required this.initial,
    required this.busy,
    required this.nativeName,
    required this.nativeDescription,
    required this.onSave,
    this.canCopyNative = true,
  });
  final cal.CalendarProtocolMetadata initial;
  final bool busy, canCopyNative;
  final String Function() nativeName, nativeDescription;
  final VoidCallback onSave;
  @override
  ProtocolMetadataEditorState createState() => ProtocolMetadataEditorState();
}

class ProtocolMetadataEditorState extends State<ProtocolMetadataEditor> {
  final _names = <_TextDraft>[], _descriptions = <_TextDraft>[];
  final _color = TextEditingController();
  @override
  void initState() {
    super.initState();
    _replace(widget.initial);
  }

  void _replace(cal.CalendarProtocolMetadata value) {
    for (final draft in [..._names, ..._descriptions]) {
      draft.dispose();
    }
    _names
      ..clear()
      ..addAll(value.names.map(_TextDraft.from));
    _descriptions
      ..clear()
      ..addAll(value.descriptions.map(_TextDraft.from));
    _color.text = value.color ?? '';
  }

  void reset(cal.CalendarProtocolMetadata value) =>
      setState(() => _replace(value));
  cal.CalendarProtocolMetadata get value => cal.CalendarProtocolMetadata(
    names: [for (final row in _names) row.value],
    descriptions: [for (final row in _descriptions) row.value],
    color: _color.text.isEmpty ? null : _color.text,
  );
  @override
  void dispose() {
    for (final draft in [..._names, ..._descriptions]) {
      draft.dispose();
    }
    _color.dispose();
    super.dispose();
  }

  void _copy(List<_TextDraft> rows, String text) {
    final defaultRows = rows.where((row) => row.language.text.isEmpty);
    if (defaultRows.isNotEmpty) {
      setState(() {
        defaultRows.first.text.text = text;
      });
    } else if (rows.length < 16) {
      setState(() {
        rows.insert(0, _TextDraft.from(cal.CalendarTextVariant(value: text)));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remove a variant before adding another.'),
        ),
      );
    }
  }

  Widget _variants(String kind, List<_TextDraft> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < rows.length; i++)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  key: Key('protocol-$kind-language-$i'),
                  controller: rows[i].language,
                  enabled: !widget.busy,
                  decoration: const InputDecoration(
                    labelText: 'Language tag',
                    helperText:
                        'For example sv or en-GB; blank means unspecified',
                  ),
                ),
                TextField(
                  key: Key('protocol-$kind-value-$i'),
                  controller: rows[i].text,
                  enabled: !widget.busy,
                  minLines: kind == 'description' ? 3 : 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: kind == 'name'
                        ? 'iCalendar NAME'
                        : 'iCalendar DESCRIPTION',
                  ),
                ),
                TextButton(
                  key: Key('protocol-$kind-remove-$i'),
                  onPressed: widget.busy
                      ? null
                      : () {
                          setState(() {
                            rows.removeAt(i).dispose();
                          });
                        },
                  child: const Text('Remove variant'),
                ),
              ],
            ),
          ),
        ),
      TextButton(
        key: Key('protocol-$kind-add'),
        onPressed: widget.busy || rows.length >= 16
            ? null
            : () {
                setState(() {
                  rows.add(_TextDraft.from(cal.CalendarTextVariant(value: '')));
                });
              },
        child: Text('Add $kind variant'),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 24),
      Text(
        'iCalendar text metadata',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const Text(
        'Stored separately from native presentation. No import/export or feed publication is performed here.',
      ),
      _variants('name', _names),
      if (widget.canCopyNative)
        TextButton(
          key: const Key('protocol-copy-name'),
          onPressed: widget.busy
              ? null
              : () => _copy(_names, widget.nativeName()),
          child: const Text('Copy native name to unspecified NAME variant'),
        ),
      _variants('description', _descriptions),
      if (widget.canCopyNative)
        TextButton(
          key: const Key('protocol-copy-description'),
          onPressed: widget.busy
              ? null
              : () => _copy(_descriptions, widget.nativeDescription()),
          child: const Text(
            'Copy native description to unspecified DESCRIPTION variant',
          ),
        ),
      const Text(
        'Copy changes this draft only. Saving replaces this calendar’s text variants and protocol color; other metadata stays separate.',
      ),
      TextField(
        key: const Key('protocol-color'),
        controller: _color,
        enabled: !widget.busy,
        decoration: const InputDecoration(
          labelText: 'iCalendar COLOR',
          helperText: 'CSS3 color name, for example turquoise; blank clears it',
        ),
      ),
      const Text(
        'Native RGB is not automatically converted to an RFC color name.',
      ),
      FilledButton(
        key: const Key('protocol-save'),
        onPressed: widget.busy ? null : widget.onSave,
        child: const Text('Save iCalendar text metadata'),
      ),
    ],
  );
}

final class _TextDraft {
  _TextDraft.from(cal.CalendarTextVariant value)
    : text = TextEditingController(text: value.value),
      language = TextEditingController(text: value.language ?? '');
  final TextEditingController text, language;
  cal.CalendarTextVariant get value => cal.CalendarTextVariant(
    value: text.text,
    language: language.text.isEmpty ? null : language.text,
  );
  void dispose() {
    text.dispose();
    language.dispose();
  }
}
