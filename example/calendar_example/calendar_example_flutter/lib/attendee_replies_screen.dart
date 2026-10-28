import 'dart:convert';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class AttendeeRepliesScreen extends StatefulWidget {
  const AttendeeRepliesScreen({
    super.key,
    required this.client,
    required this.eventId,
    this.originalStart,
  });
  final Client client;
  final UuidValue eventId;
  final cal.CalendarEventTiming? originalStart;
  @override
  State<AttendeeRepliesScreen> createState() => _AttendeeRepliesScreenState();
}

class _AttendeeRepliesScreenState extends State<AttendeeRepliesScreen> {
  cal.CalendarSchedulingResponsesView? _responses;
  cal.CalendarSchedulingInstanceResponsesView? _instance;
  List<cal.CalendarSchedulingAttendeeResponseView> get _rows =>
      _instance?.responses ?? _responses?.responses ?? [];
  int? get _publishedSequence =>
      _instance?.publishedSequence ?? _responses?.publishedSequence;
  bool? get _cancelled =>
      _instance?.publishedCancelled ?? _responses?.publishedCancelled;
  final _originalText = TextEditingController(),
      _originalZone = TextEditingController();
  cal.CalendarEventTimeKind _originalKind = cal.CalendarEventTimeKind.date;
  List<cal.CalendarSchedulingReplySourceView>? _sources;
  String? _error, _source, _message;
  bool _busy = false;
  String? _attendee;
  cal.CalendarSchedulingParticipation _participation =
      cal.CalendarSchedulingParticipation.accepted;
  final _sequence = TextEditingController(), _comment = TextEditingController();
  // Keep exact body-defining values on uncertain retry; server time is not a
  // regenerated message identity and the sender's clock is not trusted freshness.
  (
    UuidValue,
    String,
    cal.CalendarSchedulingParticipation,
    int?,
    DateTime,
    String?,
  )?
  _pending;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _sequence.dispose();
    _comment.dispose();
    _originalText.dispose();
    _originalZone.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _busy = true;
      _error = null;
      _source = null;
      _responses = null;
      _instance = null;
      _sources = null;
    });
    try {
      final api = widget.client.modules.serverpod_calendar.calendarEvent;
      final responses = widget.originalStart == null
          ? await api.schedulingResponses(widget.eventId)
          : null;
      final instance = widget.originalStart == null
          ? null
          : await api.schedulingInstanceResponses(
              widget.eventId,
              widget.originalStart!,
            );
      // Source access is independently protected. A denied source list must not
      // erase an already authorized response summary.
      if (!mounted) return;
      setState(() {
        _responses = responses;
        _instance = instance;
        _sources = null;
        _attendee ??= _rows.firstOrNull?.attendeeAddress;
        if (_pending == null) {
          _sequence.text = _publishedSequence?.toString() ?? '';
        }
      });
      final sources = await api.schedulingReplySources(widget.eventId);
      if (mounted) {
        setState(() {
          _sources = sources
              .where(
                (source) =>
                    jsonEncode(source.originalStart?.toJson()) ==
                    jsonEncode(widget.originalStart?.toJson()),
              )
              .toList();
        });
      }
    } on cal.CalendarException catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Reply review: ${error.code.name}.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Reply review is unavailable.';
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

  Future<void> _simulate() async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      if (_pending == null) {
        final text = _sequence.text.trim();
        final sequence = text.isEmpty ? null : int.parse(text);
        final now = DateTime.now().toUtc();
        _pending = (
          const Uuid().v4obj(),
          _attendee!,
          _participation,
          sequence,
          DateTime.utc(
            now.year,
            now.month,
            now.day,
            now.hour,
            now.minute,
            now.second,
          ),
          _comment.text.isEmpty ? null : _comment.text,
        );
      }
      final input = _pending!;
      final result = await widget.client.schedulingDemo.simulateReply(
        widget.eventId,
        input.$1,
        input.$2,
        input.$3,
        input.$4,
        input.$5,
        input.$6,
        widget.originalStart,
      );
      _pending = null;
      if (!mounted) return;
      setState(() {
        _message = 'Synthetic reply: ${result.outcome.name}.';
      });
      await _reload();
    } on cal.CalendarException catch (error) {
      _pending = null;
      if (mounted) {
        setState(() {
          _error = 'Simulation rejected: ${error.code.name}.';
        });
      }
    } on FormatException {
      if (mounted) {
        setState(() {
          _error = 'Enter a whole sequence number, or leave it empty.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Result uncertain. Retry the same synthetic reply.';
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

  Future<void> _read(cal.CalendarSchedulingReplySourceView source) async {
    setState(() {
      _busy = true;
      _error = null;
      _source = null;
    });
    try {
      final document = await widget
          .client
          .modules
          .serverpod_calendar
          .calendarEvent
          .schedulingReplySource(widget.eventId, source.id);
      if (mounted) {
        setState(() {
          _source = document.normalizedSource;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Source is unavailable or access was denied.';
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

  Future<void> _openInstance() async {
    try {
      final match = RegExp(
        r'^([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T([0-9]{2}):([0-9]{2}):([0-9]{2}))?$',
      ).firstMatch(_originalText.text);
      if (match == null) throw const FormatException();
      int part(int n) => int.parse(match[n] ?? '0');
      final point = cal.CalendarEventTiming(
        kind: _originalKind,
        zoneId: _originalKind == cal.CalendarEventTimeKind.zoned
            ? _originalZone.text
            : null,
        start: cal.CalendarEventCivil(
          year: part(1),
          month: part(2),
          day: part(3),
          hour: part(4),
          minute: part(5),
          second: part(6),
        ),
      );
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AttendeeRepliesScreen(
            client: widget.client,
            eventId: widget.eventId,
            originalStart: point,
          ),
        ),
      );
    } on FormatException {
      setState(() {
        _error = 'Enter the original as YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Attendee replies'),
      actions: [
        TextButton(
          key: const Key('replies-reload'),
          onPressed: _busy ? null : _reload,
          child: const Text('Reload'),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          widget.originalStart == null
              ? 'Master invitation responses. Prior and stale replies never apply automatically.'
              : 'Single-occurrence response; other occurrences and the whole series stay independent.',
        ),
        if (widget.originalStart != null)
          Text('Original: ${_originalLabel(widget.originalStart!)}'),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('replies-error')),
        if (_message != null) Text(_message!, key: const Key('replies-result')),
        if (_responses != null || _instance != null) ...[
          if (_responses?.recurring ?? false)
            const Text(
              'Whole-series master response; single-occurrence responses are separate.',
            ),
          Text(
            'Published sequence ${_publishedSequence?.toString() ?? 'no current target'}'
            '${_cancelled == true ? ' (cancelled)' : ''}',
          ),
          for (final response in _rows)
            ListTile(
              title: Text(response.attendeeAddress),
              subtitle: Text(
                response.effectiveParticipation == null
                    ? 'No recorded response'
                    : '${response.effectiveParticipation!.name} — ${response.isCurrent ? 'current' : 'prior version'}',
              ),
              key: ValueKey('reply-response-${response.attendeeAddress}'),
            ),
          const Divider(),
          const Text(
            'Development/test simulation only. This does not verify a real mailbox or send email.',
          ),
          DropdownButtonFormField<String>(
            key: const Key('reply-attendee'),
            initialValue: _attendee,
            items: [
              for (final r in _rows)
                DropdownMenuItem(
                  value: r.attendeeAddress,
                  child: Text(r.attendeeAddress),
                ),
            ],
            onChanged: _busy || _pending != null
                ? null
                : (v) => setState(() {
                    _attendee = v;
                  }),
            decoration: const InputDecoration(labelText: 'Synthetic attendee'),
          ),
          DropdownButtonFormField<cal.CalendarSchedulingParticipation>(
            key: const Key('reply-participation'),
            initialValue: _participation,
            items: [
              for (final p in cal.CalendarSchedulingParticipation.values)
                DropdownMenuItem(value: p, child: Text(p.name)),
            ],
            onChanged: _busy || _pending != null
                ? null
                : (v) => setState(() {
                    _participation = v!;
                  }),
            decoration: const InputDecoration(labelText: 'Response'),
          ),
          TextField(
            key: const Key('reply-sequence'),
            controller: _sequence,
            enabled: !_busy && _pending == null,
            decoration: const InputDecoration(
              labelText: 'Source sequence (empty means omitted/zero)',
            ),
          ),
          TextField(
            key: const Key('reply-comment'),
            controller: _comment,
            enabled: !_busy && _pending == null,
            maxLength: 4096,
            decoration: const InputDecoration(
              labelText: 'Private source comment',
            ),
          ),
          FilledButton(
            key: const Key('reply-simulate'),
            onPressed:
                _busy ||
                    _attendee == null ||
                    (_publishedSequence == null && _pending == null)
                ? null
                : _simulate,
            child: Text(
              _pending == null ? 'Simulate reply' : 'Retry same reply',
            ),
          ),
        ],
        if (widget.originalStart == null &&
            (_responses?.recurring ?? false)) ...[
          const Divider(),
          const Text(
            'Review one original from the published invitation, not its moved start. Choose its exact DATE/UTC/named-zone profile. Older invitations need a new Save and notify before instance replies.',
          ),
          DropdownButtonFormField<cal.CalendarEventTimeKind>(
            key: const Key('reply-original-kind'),
            initialValue: _originalKind,
            items: [
              for (final kind in [
                cal.CalendarEventTimeKind.date,
                cal.CalendarEventTimeKind.utc,
                cal.CalendarEventTimeKind.zoned,
              ])
                DropdownMenuItem(value: kind, child: Text(kind.name)),
            ],
            onChanged: _busy || _pending != null
                ? null
                : (kind) => setState(() {
                    _originalKind = kind!;
                  }),
          ),
          TextField(
            key: const Key('reply-original'),
            controller: _originalText,
            enabled: !_busy && _pending == null,
            decoration: const InputDecoration(
              labelText: 'Original YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS',
            ),
          ),
          if (_originalKind == cal.CalendarEventTimeKind.zoned)
            TextField(
              key: const Key('reply-original-zone'),
              controller: _originalZone,
              enabled: !_busy && _pending == null,
              decoration: const InputDecoration(
                labelText: 'Exact published IANA zone',
              ),
            ),
          FilledButton(
            key: const Key('reply-open-instance'),
            onPressed: _busy || _pending != null ? null : _openInstance,
            child: const Text('Review single occurrence'),
          ),
        ],
        const Divider(),
        const Text('Retained private sources'),
        for (final source
            in _sources ?? <cal.CalendarSchedulingReplySourceView>[])
          ListTile(
            title: Text('${source.attendeeAddress}: ${source.outcome.name}'),
            subtitle: Text(
              'Source sequence ${source.sourceSequence?.toString() ?? 'omitted (0)'}; ${source.stamp.toIso8601String()}',
            ),
            trailing: TextButton(
              key: ValueKey('reply-read-${source.id}'),
              onPressed: _busy ? null : () => _read(source),
              child: const Text('Read source'),
            ),
          ),
        if (_source != null)
          SelectableText(_source!, key: const Key('reply-source')),
      ],
    ),
  );
}

String _originalLabel(cal.CalendarEventTiming point) {
  final c = point.start;
  String two(int n) => n.toString().padLeft(2, '0');
  final date = '${c.year}-${two(c.month)}-${two(c.day)}';
  return point.kind == cal.CalendarEventTimeKind.date
      ? date
      : '$date'
            'T${two(c.hour)}:${two(c.minute)}:${two(c.second)} ${point.zoneId ?? 'UTC'}';
}
