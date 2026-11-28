import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

class AttendeeRepliesScreen extends StatefulWidget {
  const AttendeeRepliesScreen({
    super.key,
    required this.client,
    required this.eventId,
  });
  final Client client;
  final UuidValue eventId;
  @override
  State<AttendeeRepliesScreen> createState() => _AttendeeRepliesScreenState();
}

class _AttendeeRepliesScreenState extends State<AttendeeRepliesScreen> {
  cal.CalendarSchedulingResponsesView? _responses;
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
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _busy = true;
      _error = null;
      _source = null;
      _responses = null;
      _sources = null;
    });
    try {
      final api = widget.client.modules.serverpod_calendar.calendarEvent;
      final responses = await api.schedulingResponses(widget.eventId);
      // Source access is independently protected. A denied source list must not
      // erase an already authorized response summary.
      if (!mounted) return;
      setState(() {
        _responses = responses;
        _sources = null;
        _attendee ??= responses.responses.firstOrNull?.attendeeAddress;
        if (_pending == null) _sequence.text = '${responses.publishedSequence}';
      });
      final sources = await api.schedulingReplySources(widget.eventId);
      if (mounted) {
        setState(() {
          _sources = sources;
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
        const Text(
          'Non-recurring invitation responses. Prior and stale replies never apply automatically.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('replies-error')),
        if (_message != null) Text(_message!, key: const Key('replies-result')),
        if (_responses != null) ...[
          Text(
            'Published sequence ${_responses!.publishedSequence}'
            '${_responses!.publishedCancelled ? ' (cancelled)' : ''}',
          ),
          for (final response in _responses!.responses)
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
              for (final r in _responses!.responses)
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
            onPressed: _busy || _attendee == null ? null : _simulate,
            child: Text(
              _pending == null ? 'Simulate reply' : 'Retry same reply',
            ),
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
