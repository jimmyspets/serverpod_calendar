import 'package:flutter/material.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class CalendarFreeBusyScreen extends StatefulWidget {
  const CalendarFreeBusyScreen({
    super.key,
    required this.client,
    required this.calendarId,
  });
  final Client client;
  final cal.UuidValue calendarId;
  @override
  State<CalendarFreeBusyScreen> createState() => _CalendarFreeBusyScreenState();
}

class _CalendarFreeBusyScreenState extends State<CalendarFreeBusyScreen> {
  final _from = TextEditingController(), _until = TextEditingController();
  bool _busy = false;
  String? _error;
  cal.CalendarFreeBusyView? _result;
  String _format(DateTime value) =>
      value.toIso8601String().replaceFirst('.000Z', 'Z');
  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    _from.text = _format(start);
    _until.text = _format(start.add(const Duration(days: 1)));
  }

  @override
  void dispose() {
    _from.dispose();
    _until.dispose();
    super.dispose();
  }

  DateTime _utc(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$').hasMatch(value)) {
      throw const FormatException('Use YYYY-MM-DDTHH:MM:SSZ.');
    }
    final parsed = DateTime.parse(value);
    if (_format(parsed) != value) {
      throw const FormatException('Invalid UTC fields.');
    }
    return parsed;
  }

  Future<void> _load() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await widget.client.modules.serverpod_calendar.calendar
          .freeBusy(
            cal.CalendarFreeBusyQuery(
              calendarId: widget.calendarId,
              fromUtc: _utc(_from.text),
              untilUtc: _utc(_until.text),
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
              : 'Free/busy query failed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calendar free/busy')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'UTC bounds, end exclusive. Maximum 31 days. Tentative bookings block time. This first version applies stored fallback and bookings; working-hours rules and subject/common-slot search follow separately.',
        ),
        const Text(
          'Results contain no event details and do not reserve a slot.',
        ),
        TextField(
          key: const Key('busy-from'),
          controller: _from,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'From (UTC)'),
        ),
        TextField(
          key: const Key('busy-until'),
          controller: _until,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Until (exclusive UTC)'),
        ),
        FilledButton(
          key: const Key('busy-load'),
          onPressed: _busy ? null : _load,
          child: const Text('Calculate free/busy'),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('busy-error')),
        if (_result?.coverage == cal.CalendarFreeBusyCoverage.unknown)
          const Text(
            'Unknown coverage. No free time can be established.',
            key: Key('busy-unknown'),
          ),
        if (_result?.coverage == cal.CalendarFreeBusyCoverage.complete) ...[
          const Text(
            'Complete coverage for this calendar and query.',
            key: Key('busy-complete'),
          ),
          for (final period in _result!.periods)
            ListTile(
              title: Text(period.kind.name),
              subtitle: Text(
                '${_format(period.startUtc)} to ${_format(period.endUtc)}',
              ),
            ),
        ],
      ],
    ),
  );
}
