import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'generated/protocol.dart';

const eventMaxSequence = 2147483647;
const eventBaselineMaxBytes = 2097152;
String get eventBaselineProfile =>
    'event-source-v2/${NamedZoneResolver.dataVersion}';
void validateEventUid(String uid) {
  if (uid.isEmpty) throw ArgumentError('Protocol UID required');
  validateCalendarPlainText(uid, maxCodePoints: 4096);
}

String eventUidDigest(String uid) {
  validateEventUid(uid);
  return sha256.convert(utf8.encode(uid)).toString();
}

bool eventUidConflicts(String uid, Iterable<String> candidates) =>
    candidates.any((v) => v == uid);
DateTime eventProtocolInstant(DateTime value) =>
    DateTime.fromMillisecondsSinceEpoch(
      (value.toUtc().millisecondsSinceEpoch ~/ 1000) * 1000,
      isUtc: true,
    );
String _json(Object? value) => jsonEncode(value);
String eventComponentKey(CalendarEventTiming anchor, bool future) =>
    '${_json(anchor.toJson())}:$future';
Map<String, (CalendarEventTiming, bool, Object)> _components(
  CalendarEventTimingOverrides? edits,
) => {
  for (final v in edits?.singles ?? <CalendarEventSingleOverride>[])
    eventComponentKey(v.originalStart, false): (v.originalStart, false, v),
  for (final v in edits?.future ?? <CalendarEventFutureOverride>[])
    eventComponentKey(v.originalStart, true): (v.originalStart, true, v),
};
bool _cancelled(Object v) => v is CalendarEventSingleOverride && v.cancelled;
CalendarEventProtocolVersion _initial(DateTime now, {bool legacy = false}) =>
    CalendarEventProtocolVersion(
      sequence: 0,
      stamp: eventProtocolInstant(now),
      created: legacy ? null : eventProtocolInstant(now),
      lastModified: eventProtocolInstant(now),
    );
CalendarEventProtocolState eventProtocolBaseline(
  CalendarEventContent content,
  CalendarEventTimingOverrides? edits,
  DateTime created,
  DateTime modified, {
  bool legacy = false,
}) => validateEventProtocolState(
  CalendarEventProtocolState(
    version: _initial(modified)
        .copyWith(created: eventProtocolInstant(created)),
    overrides: [
      for (final v in _components(edits).values)
        CalendarEventOverrideProtocolState(
          originalStart: v.$1,
          isThisAndFuture: v.$2,
          statusPresent: _cancelled(v.$3),
          summaryPresent: eventComponentContent(v.$3)?.summary != null,
          descriptionPresent: eventComponentContent(v.$3)?.description != null,
          locationPresent: eventComponentContent(v.$3)?.location != null,
          version: _initial(modified, legacy: legacy),
        ),
    ],
  ),
  content,
  edits,
);

CalendarEventProtocolVersion validateEventProtocolVersion(
  CalendarEventProtocolVersion value,
) {
  if (value.sequence != null) {
    RangeError.checkValueInInterval(value.sequence!, 0, eventMaxSequence);
  }
  for (final t in [value.stamp, ?value.created, ?value.lastModified]) {
    TimedValue.utc(t);
  }
  return value;
}

CalendarEventProtocolState validateEventProtocolState(
  CalendarEventProtocolState value,
  CalendarEventContent content,
  CalendarEventTimingOverrides? edits,
) {
  validateEventProtocolVersion(value.version);
  if (!value.statusPresent && content.status != CalendarEventStatus.confirmed ||
      !value.transparencyPresent &&
          content.transparency != CalendarEventTransparency.opaque) {
    throw ArgumentError('Source omission contradicts native defaults');
  }
  final metadataBudget = EventMetadataBudget();
  final sourceMetadata = validateEventSourceMetadata(
    value.sourceMetadata,
    budget: metadataBudget,
  );
  if ((sourceMetadata?.attendees?.isNotEmpty ?? false) &&
      sourceMetadata?.organizer == null) {
    throw ArgumentError('Event attendees require a source organizer');
  }
  validateEventAlarmAnchors(content, edits, sourceMetadata);
  final components = _components(edits), seen = <String>{};
  if (components.length != value.overrides.length) {
    throw ArgumentError('Missing component checkpoint');
  }
  final frozen = <CalendarEventOverrideProtocolState>[];
  for (final state in value.overrides) {
    final key = eventComponentKey(state.originalStart, state.isThisAndFuture);
    final component = components[key];
    if (!seen.add(key) || component == null) {
      throw ArgumentError('Orphan component checkpoint');
    }
    validateEventProtocolVersion(state.version);
    final own = eventComponentContent(component.$3);
    final metadata = validateEventSourceMetadata(
      eventComponentMetadata(component.$3),
      budget: metadataBudget,
    );
    validateEventMetadataInheritance(sourceMetadata, metadata);
    if (state.summaryPresent != (own?.summary != null) ||
        state.descriptionPresent != (own?.description != null) ||
        state.locationPresent != (own?.location != null) ||
        _cancelled(component.$3) && !state.statusPresent) {
      throw ArgumentError('Invalid component property presence');
    }
    frozen.add(state);
  }
  frozen.sort(
    (a, b) => eventComponentKey(
      a.originalStart,
      a.isThisAndFuture,
    ).compareTo(eventComponentKey(b.originalStart, b.isThisAndFuture)),
  );
  return value.copyWith(
    overrides: List.unmodifiable(frozen),
    sourceMetadata: sourceMetadata,
  );
}

CalendarEventProtocolVersion _advance(
  CalendarEventProtocolVersion v,
  DateTime now,
) {
  if (v.sequence == eventMaxSequence) {
    throw const RecurrenceLimitException('protocolSequence');
  }
  var stamp = eventProtocolInstant(now);
  for (final old in [v.stamp, ?v.lastModified]) {
    if (old.isAfter(stamp)) stamp = old;
  }
  return v.copyWith(
    sequence: (v.sequence ?? 0) + 1,
    stamp: stamp,
    lastModified: stamp,
  );
}

Object _payload(
  CalendarEventContent c,
  Object change,
  CalendarEventOverrideProtocolState mask,
) => {
  'change': (change is CalendarEventSingleOverride
      ? change.toJson()
      : (change as CalendarEventFutureOverride).toJson()),
  if (mask.summaryPresent)
    'summary': [
      eventComponentContent(change)?.summary,
      eventComponentContent(change)?.textParameters?.summary?.toJson(),
    ],
  if (mask.descriptionPresent)
    'description': [
      eventComponentContent(change)?.description,
      eventComponentContent(change)?.textParameters?.description?.toJson(),
    ],
  if (mask.locationPresent)
    'location': [
      eventComponentContent(change)?.location,
      eventComponentContent(change)?.textParameters?.location?.toJson(),
    ],
  if (mask.statusPresent)
    'status': _cancelled(change) ? 'cancelled' : c.status.name,
  if (mask.transparencyPresent) 'transparency': c.transparency.name,
};
CalendarEventProtocolState advanceEventProtocol(
  CalendarEventProtocolState current,
  CalendarEventContent before,
  CalendarEventTimingOverrides? beforeEdits,
  CalendarEventContent after,
  CalendarEventTimingOverrides? afterEdits,
  DateTime now, {
  bool replaceSourceMetadata = false,
  CalendarEventSourceMetadata? sourceMetadata,
}) {
  final nextMetadata = replaceSourceMetadata
      ? validateEventSourceMetadata(sourceMetadata)
      : current.sourceMetadata;
  final masterChanged =
      _json(before.toJson()) != _json(after.toJson()) ||
      _json(current.sourceMetadata?.toJson()) != _json(nextMetadata?.toJson());
  final oldComponents = _components(beforeEdits),
      components = _components(afterEdits);
  final states = <CalendarEventOverrideProtocolState>[];
  for (final entry in components.entries) {
    final v = entry.value;
    var old = current.overrides
        .where(
          (s) =>
              eventComponentKey(s.originalStart, s.isThisAndFuture) ==
              entry.key,
        )
        .firstOrNull;
    var oldValue = oldComponents[entry.key];
    // Timing scope transfers retain the same original's component history.
    if (old == null || oldValue == null) {
      final retained = current.overrides
          .where((s) => s.originalStart == v.$1)
          .firstOrNull;
      if (retained != null) {
        old = retained;
        oldValue =
            oldComponents[eventComponentKey(
              retained.originalStart,
              retained.isThisAndFuture,
            )];
      }
    }
    if (old == null || oldValue == null) {
      states.add(
        CalendarEventOverrideProtocolState(
          originalStart: v.$1,
          isThisAndFuture: v.$2,
          statusPresent: _cancelled(v.$3),
          summaryPresent: eventComponentContent(v.$3)?.summary != null,
          descriptionPresent: eventComponentContent(v.$3)?.description != null,
          locationPresent: eventComponentContent(v.$3)?.location != null,
          version: _initial(now),
        ),
      );
      continue;
    }
    final state = old.copyWith(
      originalStart: v.$1,
      isThisAndFuture: v.$2,
      summaryPresent: eventComponentContent(v.$3)?.summary != null,
      descriptionPresent: eventComponentContent(v.$3)?.description != null,
      locationPresent: eventComponentContent(v.$3)?.location != null,
      statusPresent:
          _cancelled(v.$3) ||
          (_cancelled(oldValue.$3) ? false : old.statusPresent),
    );
    final changed =
        _json(_payload(before, oldValue.$3, old)) !=
        _json(_payload(after, v.$3, state));
    states.add(
      state.copyWith(
        version: changed ? _advance(old.version, now) : old.version,
      ),
    );
  }
  return validateEventProtocolState(
    current.copyWith(
      sourceMetadata: nextMetadata,
      version: masterChanged ? _advance(current.version, now) : current.version,
      statusPresent: current.statusPresent || before.status != after.status,
      transparencyPresent:
          current.transparencyPresent ||
          before.transparency != after.transparency,
      overrides: states,
    ),
    after,
    afterEdits,
  );
}

Object? _ordered(Object? value) {
  if (value is Map) {
    final result = <String, Object?>{};
    for (final key
        in value.keys.cast<String>().where((k) => k != '__className__').toList()
          ..sort()) {
      final v = _ordered(value[key]);
      if (v != null) result[key] = v;
    }
    return result.isEmpty ? null : result;
  }
  if (value is List) return value.map(_ordered).toList();
  return value;
}

CalendarEventImportBaseline eventImportBaseline(
  String uid,
  CalendarEventContent content,
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState state,
) {
  validateEventUid(uid);
  content = validateEventContent(content);
  edits = validateEventOverrides(content, edits);
  state = validateEventProtocolState(state, content, edits);
  final canonical = jsonEncode(
    _ordered({
      'uid': uid,
      'content': content.toJson(),
      'edits': edits?.toJson(),
      'protocol': state.toJson(),
    }),
  );
  if (utf8.encode(canonical).length > eventBaselineMaxBytes) {
    throw const RecurrenceLimitException('baselineBytes');
  }
  return CalendarEventImportBaseline(
    profile: eventBaselineProfile,
    canonicalValue: canonical,
    sourceSequence: state.version.sequence,
  );
}

void validateEventImportBaseline(
  CalendarEventImportBaseline value,
  String uid,
) {
  if (value.profile != eventBaselineProfile ||
      utf8.encode(value.canonicalValue).length > eventBaselineMaxBytes) {
    throw StateError('Incompatible event baseline');
  }
  final decoded = jsonDecode(value.canonicalValue) as Map<String, dynamic>;
  if (decoded['uid'] != uid ||
      decoded['content'] is! Map ||
      decoded['protocol'] is! Map ||
      decoded['protocol']['version']['sequence'] != value.sourceSequence ||
      jsonEncode(_ordered(decoded)) != value.canonicalValue) {
    throw StateError('Invalid event baseline');
  }
  // Canonical v2 snapshots omit empty maps. Reconstruct only the known
  // required participant parameter maps before generated DTO decoding.
  // Do not change snapshot bytes or invent any address/parameter claims.
  void restoreParameters(Object? metadata) {
    if (metadata is! Map) return;
    void participant(Object? value) {
      if (value is Map && !value.containsKey('parameters')) {
        value['parameters'] = <String, dynamic>{};
      }
    }

    participant(metadata['organizer']);
    final attendees = metadata['attendees'];
    if (attendees is List) {
      for (final value in attendees) {
        participant(value);
      }
    }
  }

  restoreParameters(decoded['protocol']['sourceMetadata']);
  final edits = decoded['edits'];
  if (edits is Map) {
    for (final name in ['singles', 'future']) {
      final components = edits[name];
      if (components is List) {
        for (final component in components) {
          if (component is Map) restoreParameters(component['sourceMetadata']);
        }
      }
    }
  }
  final expected = eventImportBaseline(
    uid,
    CalendarEventContent.fromJson(decoded['content'] as Map<String, dynamic>),
    decoded['edits'] == null
        ? null
        : CalendarEventTimingOverrides.fromJson(
            decoded['edits'] as Map<String, dynamic>,
          ),
    CalendarEventProtocolState.fromJson(
      decoded['protocol'] as Map<String, dynamic>,
    ),
  );
  if (expected.canonicalValue != value.canonicalValue ||
      expected.sourceSequence != value.sourceSequence) {
    throw StateError('Noncanonical event baseline');
  }
}
