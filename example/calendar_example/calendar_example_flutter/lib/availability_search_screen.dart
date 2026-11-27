import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class _TargetFields {
  _TargetFields({String id = ''}) : reference = TextEditingController(text: id);
  final namespace = TextEditingController(text: 'demo');
  final kind = TextEditingController(text: 'user');
  final TextEditingController reference;
  void dispose() {
    namespace.dispose();
    kind.dispose();
    reference.dispose();
  }
}

class AvailabilitySearchScreen extends StatefulWidget {
  const AvailabilitySearchScreen({super.key, required this.client});
  final Client client;
  @override
  State<AvailabilitySearchScreen> createState() =>
      _AvailabilitySearchScreenState();
}

class _AvailabilitySearchScreenState extends State<AvailabilitySearchScreen> {
  final _from = TextEditingController(), _until = TextEditingController();
  final _minimum = TextEditingController(text: '1');
  final _targets = <_TargetFields>[];
  bool _busy = true;
  String? _error;
  cal.CalendarAvailabilitySearchView? _result;
  cal.CalendarAvailabilitySearchMode _mode =
      cal.CalendarAvailabilitySearchMode.commonFree;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    _from.text = start.toIso8601String().replaceFirst('.000Z', 'Z');
    _until.text = start
        .add(const Duration(days: 1))
        .toIso8601String()
        .replaceFirst('.000Z', 'Z');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final principal = await widget.client.smoke.whoAmI();
      if (mounted) setState(() => _targets.add(_TargetFields(id: principal)));
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to initialize the demo target.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _from.dispose();
    _until.dispose();
    _minimum.dispose();
    for (final t in _targets) {
      t.dispose();
    }
    super.dispose();
  }

  void _invalidate() {
    if (_result != null) setState(() => _result = null);
  }

  DateTime _utc(String input) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$').hasMatch(input)) {
      throw const FormatException('Use YYYY-MM-DDTHH:MM:SSZ for UTC bounds.');
    }
    final value = DateTime.parse(input);
    if (value.toIso8601String().replaceFirst('.000Z', 'Z') != input) {
      throw const FormatException('Invalid UTC date/time.');
    }
    return value;
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      if (!RegExp(r'^\d+$').hasMatch(_minimum.text)) {
        throw const FormatException(
          'Minimum duration must be positive whole seconds.',
        );
      }
      final result = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarAvailabilitySearch
          .search(
            cal.CalendarAvailabilitySearchQuery(
              targets: [
                for (final t in _targets)
                  cal.CalendarAvailabilityTarget(
                    namespace: t.namespace.text,
                    kind: t.kind.text,
                    externalId: t.reference.text,
                  ),
              ],
              fromUtc: _utc(_from.text),
              untilUtc: _utc(_until.text),
              mode: _mode,
              minimumSeconds: int.parse(_minimum.text),
            ),
          );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is cal.CalendarException
              ? e.message
              : e is FormatException
              ? e.message
              : 'Availability search failed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _slots(List<cal.CalendarAvailabilitySlot> slots) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (slots.isEmpty)
        const Text('No interval meets the requested minimum duration.'),
      for (final s in slots)
        SelectableText(
          '${s.startUtc.toIso8601String()} — ${s.endUtc.toIso8601String()}',
        ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    Widget field(String key, String label, TextEditingController c) =>
        TextField(
          key: Key(key),
          controller: c,
          enabled: !_busy,
          onChanged: (_) => _invalidate(),
          decoration: InputDecoration(labelText: label),
        );
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Person/resource availability')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'The host resolves all contributing calendars. This private demo supports only your signed-in user. Unknown coverage never establishes free time. Results are snapshots, not reservations.',
            ),
            if (_error != null) Text(_error!, key: const Key('search-error')),
            if (_busy) const LinearProgressIndicator(),
            field('search-from', 'UTC from (inclusive)', _from),
            field(
              'search-until',
              'UTC until (exclusive), at most 31 days',
              _until,
            ),
            field(
              'search-minimum',
              'Minimum free duration in elapsed seconds',
              _minimum,
            ),
            DropdownButtonFormField<cal.CalendarAvailabilitySearchMode>(
              key: const Key('search-mode'),
              initialValue: _mode,
              items: [
                for (final mode in cal.CalendarAvailabilitySearchMode.values)
                  DropdownMenuItem(
                    value: mode,
                    child: Text(
                      mode == cal.CalendarAvailabilitySearchMode.commonFree
                          ? 'Common free'
                          : 'Per person/resource',
                    ),
                  ),
              ],
              onChanged: _busy
                  ? null
                  : (mode) => setState(() {
                      _mode = mode!;
                      _result = null;
                    }),
            ),
            for (var i = 0; i < _targets.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      field(
                        'search-namespace-$i',
                        'Namespace',
                        _targets[i].namespace,
                      ),
                      field('search-kind-$i', 'Kind', _targets[i].kind),
                      field(
                        'search-reference-$i',
                        'Person/resource reference',
                        _targets[i].reference,
                      ),
                      TextButton(
                        key: Key('search-remove-$i'),
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _targets.removeAt(i).dispose();
                                _result = null;
                              }),
                        child: const Text('Remove target'),
                      ),
                    ],
                  ),
                ),
              ),
            TextButton(
              key: const Key('search-add'),
              onPressed: _busy || _targets.length >= 8
                  ? null
                  : () => setState(() {
                      _targets.add(_TargetFields());
                      _result = null;
                    }),
              child: const Text('Add target'),
            ),
            ElevatedButton(
              key: const Key('search-load'),
              onPressed: _busy ? null : _search,
              child: const Text('Find availability'),
            ),
            if (result != null) ...[
              Text(
                'Calculated ${result.calculatedAtUtc.toIso8601String()}; ${result.fromUtc.toIso8601String()} — ${result.untilUtc.toIso8601String()}',
              ),
              if (result.mode ==
                  cal.CalendarAvailabilitySearchMode.commonFree) ...[
                if (result.commonCoverage ==
                    cal.CalendarFreeBusyCoverage.unknown)
                  const Text(
                    'Unknown coverage: no common free time has been established.',
                    key: Key('search-common-unknown'),
                  )
                else ...[
                  const Text(
                    'Complete common-free coverage',
                    key: Key('search-common-complete'),
                  ),
                  _slots(result.commonSlots),
                ],
              ] else
                const Text(
                  'Per person/resource results',
                  key: Key('search-per-target'),
                ),
              for (var i = 0; i < result.results.length; i++) ...[
                Text(
                  '${result.results[i].target.namespace}/${result.results[i].target.kind}/${result.results[i].target.externalId}',
                ),
                if (result.results[i].coverage ==
                    cal.CalendarFreeBusyCoverage.unknown)
                  Text(
                    'Unknown: cannot establish free time.',
                    key: Key('search-target-unknown-$i'),
                  )
                else ...[
                  Text(
                    'Complete coverage',
                    key: Key('search-target-complete-$i'),
                  ),
                  _slots(result.results[i].freeSlots),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
