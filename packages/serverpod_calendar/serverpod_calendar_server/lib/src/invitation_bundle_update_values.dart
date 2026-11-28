import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_protocol_values.dart';
import 'event_values.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';
import 'invitation_bundle_values.dart';

final class _BundlePart {
  const _BundlePart(this.version, this.payload);
  final CalendarInvitationBundleComponentVersion version;
  final String payload;
}

/// A validated value graph, never proof of accepted history or authority.
final class CalendarInvitationBundleState {
  CalendarInvitationBundleState._(
    this.uid,
    this.content,
    this.roster,
    Map<String, _BundlePart> parts,
  ) : _parts = Map.unmodifiable(parts);
  final String uid, roster;
  final CalendarEventContent content;
  final Map<String, _BundlePart> _parts;
  List<CalendarInvitationBundleComponentVersion> get versions =>
      List.unmodifiable(_parts.values.map((v) => v.version));
}

Object? _bundleSorted(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _bundleSorted(value[key])};
  }
  if (value is List) return value.map(_bundleSorted).toList();
  return value;
}

String _bundleRoster(Object? raw) {
  final metadata = raw as Map<String, dynamic>?;
  final organizer = metadata?['organizer'] as Map<String, dynamic>?;
  final attendees = (metadata?['attendees'] as List? ?? []).cast<Map>();
  if (organizer == null ||
      attendees.isEmpty ||
      attendees.length > 64 ||
      (metadata?['alarms'] as List? ?? []).isNotEmpty) {
    throw ArgumentError('Unsupported bundle claims');
  }
  for (final p in [organizer, ...attendees]) {
    final parameters = p['parameters'] as Map? ?? {};
    for (final key in parameters.keys.cast<String>()) {
      final name = key.toUpperCase();
      if ({'SENT-BY', 'DELEGATED-TO', 'DELEGATED-FROM'}.contains(name) ||
          name == 'PARTSTAT' &&
              (parameters[key] as List).any(
                (v) => (v as String).toUpperCase() == 'DELEGATED',
              )) {
        throw ArgumentError('Unsupported bundle claims');
      }
    }
  }
  final addresses = attendees.map((v) => v['address'] as String).toList()
    ..sort();
  if (addresses.toSet().length != addresses.length) {
    throw ArgumentError('Duplicate bundle claims');
  }
  return jsonEncode([organizer['address'], addresses]);
}

/// Validates the full private baseline before reading its independent versions.
CalendarInvitationBundleState invitationBundleBaseline(
  CalendarEventImportBaseline baseline, {
  required String protocolUid,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid work limit');
  }
  validateEventImportBaseline(baseline, protocolUid, sharedWorkBudget: work);
  final data = jsonDecode(baseline.canonicalValue) as Map<String, dynamic>;
  final content = CalendarEventContent.fromJson(data['content']);
  final protocol = data['protocol'] as Map<String, dynamic>;
  final edits = data['edits'] as Map<String, dynamic>?;
  if (edits == null ||
      edits['cancelledFrom'] != null ||
      content.status == CalendarEventStatus.cancelled ||
      content.summary == null ||
      (content.recurrence == null && (content.periods?.isEmpty ?? true))) {
    throw ArgumentError('Unsupported bundle baseline');
  }
  final roster = _bundleRoster(protocol['sourceMetadata']);
  final parts = <String, _BundlePart>{};
  _BundlePart part(
    Map<String, dynamic> state,
    Object payload, {
    CalendarEventTiming? original,
    bool future = false,
  }) {
    work.charge();
    final version = Map<String, dynamic>.from(state['version'] as Map);
    final stamp = DateTime.parse(version.remove('stamp') as String);
    final present = version.containsKey('sequence');
    final sequence = version.remove('sequence') as int?;
    return _BundlePart(
      CalendarInvitationBundleComponentVersion(
        originalStart: original,
        isThisAndFuture: future,
        sequence: sequence,
        stamp: stamp,
      ),
      jsonEncode(
        _bundleSorted({
          'payload': payload,
          'version': version,
          'sequencePresent': present,
        }),
      ),
    );
  }

  final ownStates = (protocol['overrides'] as List? ?? []).cast<Map>();
  parts['master'] = part(protocol, {
    'content': data['content'],
    'protocol': {...protocol}
      ..remove('overrides')
      ..remove('version'),
  });
  for (final name in ['singles', 'future']) {
    final future = name == 'future';
    for (final raw in (edits[name] as List? ?? []).cast<Map>()) {
      final original = CalendarEventTiming.fromJson(raw['originalStart']);
      final key = eventComponentKey(original, future);
      final state = ownStates.singleWhere(
        (v) =>
            (v['isThisAndFuture'] == true) == future &&
            eventComponentKey(
                  CalendarEventTiming.fromJson(v['originalStart']),
                  future,
                ) ==
                key,
      );
      if (raw['replacement'] == null ||
          raw['cancelled'] == true ||
          state['summaryPresent'] != true ||
          _bundleRoster(raw['sourceMetadata']) != roster) {
        throw ArgumentError('Unsupported bundle component');
      }
      parts[key] = part(
        Map<String, dynamic>.from(state),
        {
          'edit': raw,
          'protocol': {...state}..remove('version'),
          if (state['statusPresent'] == true) 'status': content.status.name,
          if (state['transparencyPresent'] == true)
            'transparency': content.transparency.name,
        },
        original: original,
        future: future,
      );
    }
  }
  if (parts.length < 2 || parts.length > 65) {
    throw ArgumentError('Invalid bundle size');
  }
  final keys = parts.keys.toList()..sort();
  return CalendarInvitationBundleState._(protocolUid, content, roster, {
    for (final key in keys) key: parts[key]!,
  });
}

int _bundleOrder(
  CalendarInvitationBundleComponentVersion a,
  CalendarInvitationBundleComponentVersion b,
) {
  final sequence = (a.sequence ?? 0).compareTo(b.sequence ?? 0);
  return sequence == 0 ? a.stamp.compareTo(b.stamp) : sequence;
}

int _bundlePointOrder(CalendarEventTiming a, CalendarEventTiming b) {
  final x = a.start, y = b.start;
  return DateTime.utc(
    x.year,
    x.month,
    x.day,
    x.hour,
    x.minute,
    x.second,
  ).compareTo(DateTime.utc(y.year, y.month, y.day, y.hour, y.minute, y.second));
}

/// Requires a complete non-regressing graph. Returns true only if it advanced.
/// Exhaustion throws; it never proves missing membership or a stale component.
bool validateInvitationBundleAdvance(
  CalendarInvitationBundleState accepted,
  CalendarInvitationBundleState incoming, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork ||
      accepted.uid != incoming.uid ||
      accepted.roster != incoming.roster ||
      accepted.content.timing.kind != incoming.content.timing.kind ||
      accepted.content.timing.zoneId != incoming.content.timing.zoneId ||
      !incoming._parts.keys.toSet().containsAll(accepted._parts.keys)) {
    throw ArgumentError('Incompatible bundle update');
  }
  var changed = false;
  for (final entry in incoming._parts.entries) {
    work.charge();
    final previous = accepted._parts[entry.key], next = entry.value;
    if (previous != null) {
      final order = _bundleOrder(next.version, previous.version);
      if (order < 0 || order == 0 && next.payload != previous.payload) {
        throw ArgumentError('Bundle component version conflict');
      }
      changed |= order > 0;
    } else {
      final point = next.version.originalStart!;
      var floor = accepted._parts['master']!.version;
      if (eventSchedulingMember(
        accepted.content,
        point,
        sharedWorkBudget: work,
      )) {
        final ranges =
            accepted._parts.values
                .where(
                  (v) =>
                      v.version.isThisAndFuture &&
                      _bundlePointOrder(v.version.originalStart!, point) <= 0,
                )
                .toList()
              ..sort(
                (a, b) => _bundlePointOrder(
                  a.version.originalStart!,
                  b.version.originalStart!,
                ),
              );
        if (ranges.isNotEmpty) floor = ranges.last.version;
      }
      if (_bundleOrder(next.version, floor) <= 0) {
        throw ArgumentError('New bundle component version conflict');
      }
      changed = true;
    }
  }
  return changed;
}

/// Pure conversion/comparison; callers separately prove authority and history.
EventStorageProposal invitationRequestBundleUpdateProposal({
  required CalendarEventImportBaseline accepted,
  required String protocolUid,
  required IcalendarSchedulingMessage incoming,
  int maxBytes = 262144,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final old = invitationBundleBaseline(
    accepted,
    protocolUid: protocolUid,
    sharedWorkBudget: work,
  );
  final next = invitationRequestBundleProposal(
    incoming,
    maxBytes: maxBytes,
    sharedWorkBudget: work,
  );
  validateInvitationBundleAdvance(
    old,
    invitationBundleBaseline(
      next.importBaseline,
      protocolUid: protocolUid,
      sharedWorkBudget: work,
    ),
    sharedWorkBudget: work,
  );
  return next;
}
