import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class EventDescriptiveEditor extends StatefulWidget {
  const EventDescriptiveEditor({
    super.key,
    required this.client,
    required this.event,
  });
  final Client client;
  final cal.CalendarEventView event;
  @override
  State<EventDescriptiveEditor> createState() => _EventDescriptiveEditorState();
}

class _ResourceFields {
  _ResourceFields([cal.CalendarEventResourceGroup? value]) {
    labels.addAll(
      (value?.values ?? ['']).map((v) => TextEditingController(text: v)),
    );
    language.text = value?.language ?? '';
    alternative.text = value?.alternativeUri ?? '';
  }
  final labels = <TextEditingController>[];
  final language = TextEditingController(),
      alternative = TextEditingController();
  void dispose() {
    for (final label in labels) {
      label.dispose();
    }
    language.dispose();
    alternative.dispose();
  }

  cal.CalendarEventResourceGroup value() => cal.CalendarEventResourceGroup(
    values: labels.map((v) => v.text).toList(),
    language: language.text.isEmpty ? null : language.text,
    alternativeUri: alternative.text.isEmpty ? null : alternative.text,
  );
}

class _EventDescriptiveEditorState extends State<EventDescriptiveEditor> {
  final _priority = TextEditingController(),
      _latitude = TextEditingController(),
      _longitude = TextEditingController();
  final _groups = <_ResourceFields>[];
  bool _busy = false, _stale = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final v = widget.event;
    _priority.text = v.priority?.toString() ?? '';
    _latitude.text = v.geographicPosition?.latitudeText ?? '';
    _longitude.text = v.geographicPosition?.longitudeText ?? '';
    _groups.addAll((v.resourceGroups ?? []).map(_ResourceFields.new));
  }

  @override
  void dispose() {
    _priority.dispose();
    _latitude.dispose();
    _longitude.dispose();
    for (final g in _groups) {
      g.dispose();
    }
    super.dispose();
  }

  int get _labelCount => _groups.fold(0, (n, g) => n + g.labels.length);
  bool get _disclosed => [
    cal.CalendarEventFieldGroup.location,
    cal.CalendarEventFieldGroup.priority,
    cal.CalendarEventFieldGroup.resources,
  ].every(widget.event.disclosedGroups.contains);
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final priority = _priority.text.isEmpty
          ? null
          : int.tryParse(_priority.text);
      if (_priority.text.isNotEmpty && priority == null) {
        throw const FormatException('Priority must be an integer from 0 to 9.');
      }
      final hasLatitude = _latitude.text.isNotEmpty,
          hasLongitude = _longitude.text.isNotEmpty;
      if (hasLatitude != hasLongitude) {
        throw const FormatException('Enter both coordinates or clear both.');
      }
      await widget.client.modules.serverpod_calendar.calendarEvent
          .updateDescriptiveMetadata(
            cal.CalendarEventDescriptiveRequest(
              eventId: widget.event.id,
              expectedRevision: widget.event.revision,
              metadata: cal.CalendarEventDescriptiveMetadata(
                priority: priority,
                geographicPosition: hasLatitude
                    ? cal.CalendarEventGeographicPosition(
                        latitudeText: _latitude.text,
                        longitudeText: _longitude.text,
                      )
                    : null,
                resourceGroups: _groups.map((g) => g.value()).toList(),
              ),
            ),
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on cal.CalendarException catch (e) {
      if (mounted) {
        setState(() {
          _stale = e.code == cal.CalendarFailureCode.staleRevision;
          _error = _stale
              ? 'This event changed. Return and reload before editing.'
              : 'The change was rejected (${e.code.name}).';
        });
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
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
    final locked = _busy || _stale || !_disclosed;
    Widget field(
      String key,
      String label,
      TextEditingController controller, {
      int lines = 1,
    }) => TextField(
      key: Key(key),
      controller: controller,
      enabled: !locked,
      minLines: lines,
      maxLines: lines == 1 ? 1 : 6,
      decoration: InputDecoration(labelText: label),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event priority, coordinates and resources'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'These fields describe the series. Resource labels do not reserve rooms or equipment. Coordinate fractions are preserved exactly; calendar times still use whole seconds.',
          ),
          if (!_disclosed)
            const Text('Some fields are withheld. Editing is unavailable.'),
          if (_error != null)
            Text(_error!, key: const Key('event-descriptive-error')),
          field(
            'event-priority',
            'Priority (0–9; blank means absent)',
            _priority,
          ),
          field('event-latitude', 'Latitude (exact decimal text)', _latitude),
          field(
            'event-longitude',
            'Longitude (exact decimal text)',
            _longitude,
          ),
          const Text(
            'Each resource group preserves labels in order, including duplicates. Each field is one label and may contain newlines; a blank field is an empty label. Remove a group to clear it. Links are stored without loading them.',
          ),
          for (var i = 0; i < _groups.length; i++)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    for (var j = 0; j < _groups[i].labels.length; j++) ...[
                      field(
                        'event-resource-value-$i-$j',
                        'Resource label',
                        _groups[i].labels[j],
                        lines: 2,
                      ),
                      TextButton(
                        onPressed: locked || _groups[i].labels.length == 1
                            ? null
                            : () => setState(
                                () => _groups[i].labels.removeAt(j).dispose(),
                              ),
                        child: const Text('Remove label'),
                      ),
                    ],
                    TextButton(
                      key: Key('event-resource-label-add-$i'),
                      onPressed: locked || _labelCount >= 64
                          ? null
                          : () => setState(
                              () => _groups[i].labels.add(
                                TextEditingController(),
                              ),
                            ),
                      child: const Text('Add label'),
                    ),
                    field(
                      'event-resource-language-$i',
                      'Language (optional)',
                      _groups[i].language,
                    ),
                    field(
                      'event-resource-alternative-$i',
                      'Alternative representation URI (optional)',
                      _groups[i].alternative,
                    ),
                    TextButton(
                      onPressed: locked
                          ? null
                          : () => setState(() => _groups.removeAt(i).dispose()),
                      child: const Text('Remove group'),
                    ),
                  ],
                ),
              ),
            ),
          TextButton(
            key: const Key('event-resource-add'),
            onPressed: locked || _groups.length >= 32 || _labelCount >= 64
                ? null
                : () => setState(() => _groups.add(_ResourceFields())),
            child: const Text('Add resource group'),
          ),
          FilledButton(
            key: const Key('event-descriptive-save'),
            onPressed: locked ? null : _save,
            child: const Text('Save descriptive fields'),
          ),
        ],
      ),
    );
  }
}
