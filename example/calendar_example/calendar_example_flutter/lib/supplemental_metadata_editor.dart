import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class SupplementalMetadataEditor extends StatefulWidget {
  const SupplementalMetadataEditor({
    super.key,
    required this.initial,
    required this.busy,
    required this.onSave,
  });
  final cal.CalendarSupplementalMetadata initial;
  final bool busy;
  final VoidCallback onSave;
  @override
  SupplementalMetadataEditorState createState() =>
      SupplementalMetadataEditorState();
}

class SupplementalMetadataEditorState
    extends State<SupplementalMetadataEditor> {
  final _url = TextEditingController();
  final _categories = <_CategoryDraft>[];
  final _images = <_ImageDraft>[];
  final _units = [for (var i = 0; i < 5; i++) TextEditingController()];
  bool _hint = false;
  @override
  void initState() {
    super.initState();
    _replace(widget.initial);
  }

  void _replace(cal.CalendarSupplementalMetadata v) {
    for (final d in _categories) {
      d.dispose();
    }
    for (final d in _images) {
      d.dispose();
    }
    _categories
      ..clear()
      ..addAll(v.categories.map(_CategoryDraft.new));
    _images
      ..clear()
      ..addAll(v.images.map(_ImageDraft.new));
    _url.text = v.url ?? '';
    _hint = v.refreshHint != null;
    final h = v.refreshHint;
    final values = [
      h?.weeks ?? 0,
      h?.days ?? 0,
      h?.hours ?? 0,
      h?.minutes ?? 0,
      h?.seconds ?? 0,
    ];
    for (var i = 0; i < 5; i++) {
      _units[i].text = '${values[i]}';
    }
  }

  void reset(cal.CalendarSupplementalMetadata v) => setState(() => _replace(v));
  cal.CalendarSupplementalMetadata get value {
    final n = <int>[];
    if (_hint) {
      for (final input in _units) {
        if (input.text.isEmpty ||
            input.text.codeUnits.any((c) => c < 48 || c > 57)) {
          throw const FormatException(
            'Refresh units must be nonnegative whole numbers.',
          );
        }
        final number = int.tryParse(input.text);
        if (number == null) {
          throw const FormatException('Refresh unit is too large.');
        }
        n.add(number);
      }
    }
    return cal.CalendarSupplementalMetadata(
      url: _url.text.isEmpty ? null : _url.text,
      categories: [for (final c in _categories) c.value],
      images: [for (final i in _images) i.value],
      refreshHint: _hint
          ? cal.CalendarRefreshHint(
              weeks: n[0],
              days: n[1],
              hours: n[2],
              minutes: n[3],
              seconds: n[4],
            )
          : null,
    );
  }

  @override
  void dispose() {
    _url.dispose();
    for (final c in _categories) {
      c.dispose();
    }
    for (final i in _images) {
      i.dispose();
    }
    for (final c in _units) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 24),
      Text(
        'Links, categories and refresh hint',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      TextField(
        key: const Key('metadata-url'),
        controller: _url,
        enabled: !widget.busy,
        decoration: const InputDecoration(
          labelText: 'Alternative calendar URL',
          helperText: 'Absolute HTTP/HTTPS link; empty clears it',
        ),
      ),
      for (var i = 0; i < _categories.length; i++)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  key: Key('metadata-category-value-$i'),
                  controller: _categories[i].text,
                  enabled: !widget.busy,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    helperText: 'Exact text; case and spacing are preserved',
                  ),
                ),
                TextField(
                  key: Key('metadata-category-language-$i'),
                  controller: _categories[i].language,
                  enabled: !widget.busy,
                  decoration: const InputDecoration(
                    labelText: 'Category language',
                    helperText: 'Optional tag, for example sv',
                  ),
                ),
                TextButton(
                  key: Key('metadata-category-remove-$i'),
                  onPressed: widget.busy
                      ? null
                      : () {
                          setState(() {
                            _categories.removeAt(i).dispose();
                          });
                        },
                  child: const Text('Remove category'),
                ),
              ],
            ),
          ),
        ),
      TextButton(
        key: const Key('metadata-category-add'),
        onPressed: widget.busy || _categories.length >= 64
            ? null
            : () {
                setState(() {
                  _categories.add(
                    _CategoryDraft(cal.CalendarCategory(value: '')),
                  );
                });
              },
        child: const Text('Add category'),
      ),
      const Text(
        'Image links are stored without loading the images. Links do not grant file access.',
      ),
      for (var i = 0; i < _images.length; i++)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  key: Key('metadata-image-uri-$i'),
                  controller: _images[i].uri,
                  enabled: !widget.busy,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                TextField(
                  key: Key('metadata-image-display-$i'),
                  controller: _images[i].display,
                  enabled: !widget.busy,
                  decoration: const InputDecoration(
                    labelText: 'DISPLAY hints',
                    helperText: 'Comma-separated hints; empty omits DISPLAY (default BADGE)',
                  ),
                ),
                TextField(
                  key: Key('metadata-image-type-$i'),
                  controller: _images[i].mediaType,
                  enabled: !widget.busy,
                  decoration: const InputDecoration(
                    labelText: 'Declared image media type',
                    helperText: 'Optional, for example image/png; content is not inspected',
                  ),
                ),
                TextButton(
                  key: Key('metadata-image-remove-$i'),
                  onPressed: widget.busy
                      ? null
                      : () {
                          setState(() {
                            _images.removeAt(i).dispose();
                          });
                        },
                  child: const Text('Remove image link'),
                ),
              ],
            ),
          ),
        ),
      TextButton(
        key: const Key('metadata-image-add'),
        onPressed: widget.busy || _images.length >= 16
            ? null
            : () {
                setState(() {
                  _images.add(_ImageDraft(cal.CalendarImageLink(uri: '')));
                });
              },
        child: const Text('Add image link'),
      ),
      SwitchListTile(
        key: const Key('metadata-refresh-enabled'),
        title: const Text('Set a suggested refresh interval'),
        value: _hint,
        onChanged: widget.busy
            ? null
            : (v) {
                setState(() {
                  _hint = v;
                });
              },
      ),
      if (_hint) ...[
        const Text(
          'Positive whole units, at most 365 days. Weeks cannot be mixed with other units. This does not start polling.',
        ),
        for (var i = 0; i < 5; i++)
          TextField(
            key: Key(
              'metadata-refresh-${const ['weeks', 'days', 'hours', 'minutes', 'seconds'][i]}',
            ),
            controller: _units[i],
            enabled: !widget.busy,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: const [
                'Weeks',
                'Days',
                'Hours',
                'Minutes',
                'Seconds',
              ][i],
            ),
          ),
      ],
      FilledButton(
        key: const Key('metadata-save'),
        onPressed: widget.busy ? null : widget.onSave,
        child: const Text('Save links, categories and hint'),
      ),
    ],
  );
}

class _CategoryDraft {
  _CategoryDraft(cal.CalendarCategory v)
    : text = TextEditingController(text: v.value),
      language = TextEditingController(text: v.language ?? '');
  final TextEditingController text, language;
  cal.CalendarCategory get value => cal.CalendarCategory(
    value: text.text,
    language: language.text.isEmpty ? null : language.text,
  );
  void dispose() {
    text.dispose();
    language.dispose();
  }
}

class _ImageDraft {
  _ImageDraft(cal.CalendarImageLink v)
    : uri = TextEditingController(text: v.uri),
      display = TextEditingController(text: v.display?.join(',') ?? ''),
      mediaType = TextEditingController(text: v.mediaType ?? '');
  final TextEditingController uri, display, mediaType;
  cal.CalendarImageLink get value => cal.CalendarImageLink(
    uri: uri.text,
    display: display.text.isEmpty
        ? null
        : display.text.split(',').map((s) => s.trim()).toList(),
    mediaType: mediaType.text.isEmpty ? null : mediaType.text,
  );
  void dispose() {
    uri.dispose();
    display.dispose();
    mediaType.dispose();
  }
}
