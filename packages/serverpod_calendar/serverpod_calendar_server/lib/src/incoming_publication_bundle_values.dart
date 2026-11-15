import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_protocol_values.dart';
import 'event_values.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';

/// Validates a complete initial PUBLISH series. This proves no recipient,
/// provenance, existing-meeting state or permission to persist the result.
EventStorageProposal informationPublicationBundleProposal(
  IcalendarSchedulingMessage input, {
  int maxBytes = 524288,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  RangeError.checkValueInInterval(maxBytes, 1, 524288);
  if (sharedWorkBudget != null &&
      sharedWorkBudget.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid publication work limit');
  }
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final syntax = IcalendarSyntaxLimits(maxBytes: maxBytes);
  final bytes = serializeIcalendarSyntax(input.source, limits: syntax);
  for (var i = 0; i < bytes.length; i += 64) {
    work.charge();
  }
  final message = validateIcalendarSchedulingMessage(
    input.source,
    syntaxLimits: syntax,
    sharedWorkBudget: work,
  );
  if (message.method != IcalendarSchedulingMethod.publish ||
      message.events.length < 2 ||
      message.events.length > 65 ||
      message.events.where((e) => !e.isOverride).length != 1) {
    throw ArgumentError('Unsupported publication bundle');
  }
  final master = message.events.singleWhere((e) => !e.isOverride);
  String claims(IcalendarEventParticipants p) {
    if (p.organizer == null ||
        p.organizer!.sentBy != null ||
        p.attendees.isNotEmpty ||
        p.attendees.any(
          (a) =>
              a.sentBy != null ||
              a.delegatedTo.isNotEmpty ||
              a.delegatedFrom.isNotEmpty ||
              a.participationStatus?.toUpperCase() == 'DELEGATED',
        )) {
      throw ArgumentError('Unsupported participant profile');
    }
    return p.organizer!.address;
  }

  final roster = claims(master.participants);
  for (final part in message.events) {
    work.charge();
    if (part.status == IcalendarEventStatus.cancelled ||
        claims(part.participants) != roster) {
      throw ArgumentError('Inconsistent participant claims');
    }
  }
  final root = message.source.components.single;
  final calendar = validateIcalendarEventCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(
        root.name,
        root.entries.where(
          (v) => v is! IcalendarSyntaxProperty || v.canonicalName != 'METHOD',
        ),
      ),
    ]),
    syntaxLimits: syntax,
    sharedWorkBudget: work,
  );
  if (calendar.series.length != 1) throw ArgumentError('Multiple series');
  final proposal = eventStorageProposal(
    calendar.series.single,
    sharedWorkBudget: work,
  );
  final content = proposal.content;
  if (content.recurrence == null && (content.periods?.isEmpty ?? true)) {
    throw ArgumentError('Recurring master required');
  }
  return proposal;
}

final class _BundlePart {
  const _BundlePart(this.version, this.payload);
  final CalendarIncomingPublicationComponentVersion version;
  final String payload;
}

/// A validated value graph, never proof of accepted history or authority.
final class CalendarIncomingPublicationBundleState {
  CalendarIncomingPublicationBundleState._(
    this.uid,
    this.content,
    this.roster,
    Map<String, _BundlePart> parts,
  ) : _parts = Map.unmodifiable(parts);
  final String uid, roster;
  final CalendarEventContent content;
  final Map<String, _BundlePart> _parts;
  List<CalendarIncomingPublicationComponentVersion> get versions =>
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
      attendees.isNotEmpty ||
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
  return organizer['address'] as String;
}

/// Validates the full private baseline before reading its independent versions.
CalendarIncomingPublicationBundleState informationPublicationBundleBaseline(
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
      CalendarIncomingPublicationComponentVersion(
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
  return CalendarIncomingPublicationBundleState._(
    protocolUid,
    content,
    roster,
    {
      for (final key in keys) key: parts[key]!,
    },
  );
}

int _bundleOrder(
  CalendarIncomingPublicationComponentVersion a,
  CalendarIncomingPublicationComponentVersion b,
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
bool validateInformationPublicationBundleAdvance(
  CalendarIncomingPublicationBundleState accepted,
  CalendarIncomingPublicationBundleState incoming, {
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
EventStorageProposal informationPublicationBundleUpdateProposal({
  required CalendarEventImportBaseline accepted,
  required String protocolUid,
  required IcalendarSchedulingMessage incoming,
  int maxBytes = 524288,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final old = informationPublicationBundleBaseline(
    accepted,
    protocolUid: protocolUid,
    sharedWorkBudget: work,
  );
  final next = informationPublicationBundleProposal(
    incoming,
    maxBytes: maxBytes,
    sharedWorkBudget: work,
  );
  validateInformationPublicationBundleAdvance(
    old,
    informationPublicationBundleBaseline(
      next.importBaseline,
      protocolUid: protocolUid,
      sharedWorkBudget: work,
    ),
    sharedWorkBudget: work,
  );
  return next;
}

/// Whole-CANCEL claims/version floors only. The caller must separately prove
/// trusted history and compare any supplied fields with the actual sender basis.
CalendarIncomingPublicationComponentVersion
validateInformationPublicationBundleCancellation({
  required CalendarIncomingPublicationBundleState accepted,
  required IcalendarSchedulingMessage incoming,
  CalendarIncomingPublicationBundleState? pending,
  CalendarIncomingPublicationComponentVersion? previousCancellation,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid work limit');
  }
  final message = validateIcalendarSchedulingMessage(
    incoming.source,
    sharedWorkBudget: work,
  );
  if (message.method != IcalendarSchedulingMethod.cancel ||
      message.events.length != 1 ||
      message.uid != accepted.uid) {
    throw ArgumentError('Unsupported bundle cancellation');
  }
  final event = message.events.single;
  final addresses = event.participants.attendees.map((a) => a.address).toList();
  final organizer = accepted.roster;
  if (event.isOverride ||
      event.status != IcalendarEventStatus.cancelled ||
      event.sequence == null ||
      event.participants.organizer?.address != organizer ||
      addresses.isNotEmpty) {
    throw ArgumentError('Invalid cancellation claims');
  }
  // Reuse the bounded participant checks, including delegation/SENT-BY rejection.
  _bundleRoster({
    'organizer': {
      'address': event.participants.organizer!.address,
      'parameters': event.participants.organizer!.parameters,
    },
    'attendees': [
      for (final a in event.participants.attendees)
        {'address': a.address, 'parameters': a.parameters},
    ],
  });
  for (final version in [
    ...accepted.versions,
    ...?pending?.versions,
    ?previousCancellation,
  ]) {
    work.charge();
    if (event.sequence! <= (version.sequence ?? 0)) {
      throw ArgumentError('Cancellation version conflict');
    }
  }
  return CalendarIncomingPublicationComponentVersion(
    sequence: event.sequence,
    stamp: event.stamp,
  );
}

/// A complete PUBLISH must explicitly cross a distinct whole-CANCEL floor.
bool validateInformationPublicationBundleReopening({
  required CalendarIncomingPublicationBundleState accepted,
  required CalendarIncomingPublicationBundleState incoming,
  required CalendarIncomingPublicationComponentVersion cancellation,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final master = incoming.versions.singleWhere((v) => v.originalStart == null);
  if (cancellation.originalStart != null ||
      cancellation.isThisAndFuture ||
      (master.sequence ?? 0) <= (cancellation.sequence ?? 0)) {
    throw ArgumentError('Reopening version conflict');
  }
  return validateInformationPublicationBundleAdvance(
    accepted,
    incoming,
    sharedWorkBudget: sharedWorkBudget,
  );
}
