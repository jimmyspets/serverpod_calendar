import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'availability_values.dart';
import 'generated/protocol.dart';
import 'event_values.dart';

const availabilityMaxSequence = 2147483647;
DateTime availabilityProtocolInstant(DateTime value) =>
    DateTime.fromMillisecondsSinceEpoch(
      (value.toUtc().millisecondsSinceEpoch ~/ 1000) * 1000,
      isUtc: true,
    );

DateTime _stamp(DateTime now, DateTime previous, DateTime? modified) {
  var result = availabilityProtocolInstant(now);
  for (final v in [previous, ?modified]) {
    if (v.isAfter(result)) result = v;
  }
  return result;
}

CalendarAvailabilityProtocolState availabilityProtocolBaseline(
  CalendarAvailabilityContent content,
  DateTime created,
  DateTime modified, {
  bool legacy = false,
}) {
  final stamp = availabilityProtocolInstant(modified);
  return CalendarAvailabilityProtocolState(
    sequence: 0,
    created: availabilityProtocolInstant(created),
    stamp: stamp,
    lastModified: stamp,
    openings: List.unmodifiable([
      for (final o in content.openings)
        CalendarAvailabilityOpeningProtocolState(
          openingUid: o.uid!,
          created: legacy ? null : stamp,
          stamp: stamp,
          lastModified: stamp,
        ),
    ]),
  );
}

CalendarAvailabilitySourceMetadata availabilitySourceMetadata(
  CalendarAvailabilityOpening value,
) {
  CalendarAvailabilityText? text(String? v, CalendarTextParameters? p) =>
      v == null
      ? null
      : CalendarAvailabilityText(
          value: v,
          language: p?.language,
          alternativeUri: p?.alternativeUri,
        );
  return CalendarAvailabilitySourceMetadata(
    summary: text(value.summary, value.textParameters?.summary),
    description: text(value.description, value.textParameters?.description),
    location: text(value.location, value.textParameters?.location),
    categories: (value.categoryGroups?.isNotEmpty ?? false)
        ? value.categoryGroups
        : ((value.categories?.isNotEmpty ?? false)
              ? [
                  CalendarAvailabilityCategoryGroup(
                    values: value.categories!,
                    language: value.textParameters?.categoryLanguage,
                  ),
                ]
              : null),
    comments: value.comments == null || value.comments!.isEmpty
        ? null
        : [
            for (var i = 0; i < value.comments!.length; i++)
              text(value.comments![i], value.textParameters?.comments?[i])!,
          ],
    contacts: value.contacts,
    extensions: value.extensions,
  );
}

CalendarAvailabilitySourceMetadata _freezeMetadata(
  CalendarAvailabilitySourceMetadata v,
) => v.copyWith(
  categories: v.categories == null
      ? null
      : List.unmodifiable([
          for (final group in v.categories!)
            group.copyWith(values: List.unmodifiable(group.values)),
        ]),
  comments: v.comments == null ? null : List.unmodifiable(v.comments!),
  contacts: v.contacts == null ? null : List.unmodifiable(v.contacts!),
  extensions: v.extensions == null ? null : List.unmodifiable(v.extensions!),
);

CalendarAvailabilitySourceMetadata? _inherit(
  CalendarAvailabilitySourceMetadata? mask,
  CalendarAvailabilitySourceMetadata value,
) => mask == null
    ? null
    : _freezeMetadata(
        CalendarAvailabilitySourceMetadata(
          summary: mask.summary == null ? null : value.summary,
          description: mask.description == null ? null : value.description,
          location: mask.location == null ? null : value.location,
          categories: mask.categories == null ? null : value.categories,
          comments: mask.comments == null ? null : value.comments,
          contacts: mask.contacts == null ? null : value.contacts,
          extensions: mask.extensions == null
              ? null
              : [
                  for (final m in mask.extensions!)
                    for (final v
                        in value.extensions ??
                            <CalendarAvailabilityExtension>[])
                      if (m.name.toUpperCase() == v.name.toUpperCase())
                        m.copyWith(value: v.value),
                ],
        ),
      );

String _key(CalendarEventTiming start, bool future) =>
    '${jsonEncode(start.toJson())}:$future';
Map<String, (CalendarEventTiming, bool, Object)> _components(
  List<CalendarAvailabilityOpeningEdits>? edits,
  Object? id,
) {
  final change = openingEdits(edits, id);
  return {
    for (final v in change?.singles ?? <CalendarEventSingleOverride>[])
      if (v.replacement != null)
        _key(v.originalStart, false): (v.originalStart, false, v.toJson()),
    for (final v in change?.future ?? <CalendarEventFutureOverride>[])
      _key(v.originalStart, true): (v.originalStart, true, v.toJson()),
  };
}

CalendarAvailabilityProtocolState validateAvailabilityProtocolState(
  CalendarAvailabilityProtocolState state,
  CalendarAvailabilityContent content, {
  List<CalendarAvailabilityOpeningEdits>? edits,
}) {
  void instant(DateTime value) {
    if (!value.isUtc || value.microsecondsSinceEpoch % 1000000 != 0) {
      throw ArgumentError('Whole-second UTC protocol time required');
    }
    TimedValue.utc(value);
  }

  if (state.sequence != null) {
    RangeError.checkValueInInterval(
      state.sequence!,
      0,
      availabilityMaxSequence,
    );
  }
  for (final v in [state.stamp, ?state.created, ?state.lastModified]) {
    instant(v);
  }
  if (state.openings.length != content.openings.length) {
    throw ArgumentError('Invalid protocol state');
  }
  final ids = content.openings.map((o) => o.uid).toSet();
  final seen = <Object>{};
  var metadataWork = 0;
  int work(Object? v) => v is String
      ? v.runes.length
      : v is List
      ? v.fold<int>(0, (n, item) => n + work(item))
      : v is Map
      ? v.entries
            .where((e) => e.key != '__className__')
            .fold<int>(0, (n, e) => n + work(e.value))
      : 0;
  final frozen = <CalendarAvailabilityOpeningProtocolState>[];
  for (final opening in state.openings) {
    if (!ids.contains(opening.openingUid) || !seen.add(opening.openingUid)) {
      throw ArgumentError('Invalid opening protocol identity');
    }
    for (final v in [opening.stamp, ?opening.lastModified, ?opening.created]) {
      instant(v);
    }
    final master = content.openings.singleWhere(
      (o) => o.uid == opening.openingUid,
    );
    final full = availabilitySourceMetadata(master);
    final components = _components(edits, opening.openingUid);
    final keys = <String>{};
    final overrides = <CalendarAvailabilityOverrideProtocolState>[];
    if ((opening.overrides?.length ?? 0) > eventMaxOverrides) {
      throw const AvailabilityLimitException('componentProtocolStates');
    }
    for (final v
        in opening.overrides ?? <CalendarAvailabilityOverrideProtocolState>[]) {
      final key = _key(v.originalStart, v.isThisAndFuture);
      if (!keys.add(key) || !components.containsKey(key)) {
        throw ArgumentError('Orphan component protocol state');
      }
      for (final t in [v.stamp, ?v.created, ?v.lastModified]) {
        instant(t);
      }
      final extensionNames = <String>{};
      for (final extension
          in v.metadata?.extensions ?? <CalendarAvailabilityExtension>[]) {
        if (!extensionNames.add(extension.name.toUpperCase())) {
          throw ArgumentError('Duplicate source private property');
        }
      }
      final masked = _inherit(v.metadata, full);
      if (jsonEncode(masked?.toJson()) != jsonEncode(v.metadata?.toJson())) {
        throw ArgumentError('Timing component metadata must inherit master');
      }
      metadataWork += work(masked?.toJson());
      overrides.add(v.copyWith(metadata: masked));
    }
    frozen.add(
      opening.copyWith(
        overrides: overrides.isEmpty ? null : List.unmodifiable(overrides),
      ),
    );
  }
  if (metadataWork > 65536) {
    throw const AvailabilityLimitException('componentMetadata');
  }
  return state.copyWith(openings: List.unmodifiable(frozen));
}

CalendarAvailabilityProtocolState advanceAvailabilityProtocol(
  CalendarAvailabilityProtocolState current,
  CalendarAvailabilityContent before,
  List<CalendarAvailabilityOpeningEdits>? beforeEdits,
  CalendarAvailabilityContent after,
  List<CalendarAvailabilityOpeningEdits>? afterEdits,
  DateTime now,
) {
  Object? edits(List<CalendarAvailabilityOpeningEdits>? v) =>
      v?.map((e) => e.toJson()).toList();
  if (jsonEncode(before.toJson()) == jsonEncode(after.toJson()) &&
      jsonEncode(edits(beforeEdits)) == jsonEncode(edits(afterEdits))) {
    return current;
  }
  if (current.sequence == availabilityMaxSequence) {
    throw const AvailabilityLimitException('protocolSequence');
  }
  final stamp = _stamp(now, current.stamp, current.lastModified);
  final openingStates = <CalendarAvailabilityOpeningProtocolState>[];
  for (final opening in after.openings) {
    final old = before.openings.where((v) => v.uid == opening.uid).firstOrNull;
    final previous = current.openings
        .where((v) => v.openingUid == opening.uid)
        .firstOrNull;
    final changed =
        old == null ||
        jsonEncode(old.toJson()) != jsonEncode(opening.toJson()) ||
        jsonEncode(openingEdits(beforeEdits, opening.uid)?.toJson()) !=
            jsonEncode(openingEdits(afterEdits, opening.uid)?.toJson());
    final ownStamp = previous == null
        ? availabilityProtocolInstant(now)
        : _stamp(now, previous.stamp, previous.lastModified);
    final oldComponents = _components(beforeEdits, opening.uid);
    final components = _components(afterEdits, opening.uid);
    final full = availabilitySourceMetadata(opening);
    final sources = <CalendarAvailabilityOverrideProtocolState>[];
    for (final entry in components.entries) {
      final source = previous?.overrides
          ?.where((v) => _key(v.originalStart, v.isThisAndFuture) == entry.key)
          .firstOrNull;
      final metadata = _inherit(source?.metadata, full);
      final modified =
          source == null ||
          jsonEncode(oldComponents[entry.key]?.$3) !=
              jsonEncode(entry.value.$3) ||
          jsonEncode(source.metadata?.toJson()) !=
              jsonEncode(metadata?.toJson());
      final legacy = source == null && oldComponents.containsKey(entry.key);
      final version = source == null
          ? (legacy
                ? _stamp(
                    now,
                    previous?.stamp ?? current.stamp,
                    previous?.lastModified,
                  )
                : availabilityProtocolInstant(now))
          : _stamp(now, source.stamp, source.lastModified);
      final legacyChanged =
          legacy &&
          jsonEncode(oldComponents[entry.key]?.$3) !=
              jsonEncode(entry.value.$3);
      final legacyStamp = previous?.stamp ?? current.stamp;
      sources.add(
        source == null
            ? CalendarAvailabilityOverrideProtocolState(
                originalStart: entry.value.$1,
                isThisAndFuture: entry.value.$2,
                created: legacy ? null : availabilityProtocolInstant(now),
                stamp: legacy && !legacyChanged ? legacyStamp : version,
                lastModified: legacy && !legacyChanged
                    ? previous?.lastModified
                    : version,
              )
            : modified
            ? source.copyWith(
                stamp: version,
                lastModified: version,
                metadata: metadata,
              )
            : source,
      );
    }
    openingStates.add(
      previous == null
          ? CalendarAvailabilityOpeningProtocolState(
              openingUid: opening.uid!,
              created: ownStamp,
              stamp: ownStamp,
              lastModified: ownStamp,
              overrides: sources.isEmpty ? null : List.unmodifiable(sources),
            )
          : previous.copyWith(
              stamp: changed ? ownStamp : previous.stamp,
              lastModified: changed ? ownStamp : previous.lastModified,
              overrides: sources.isEmpty ? null : List.unmodifiable(sources),
            ),
    );
  }
  return validateAvailabilityProtocolState(
    current.copyWith(
      sequence: (current.sequence ?? 0) + 1,
      stamp: stamp,
      lastModified: stamp,
      openings: List.unmodifiable(openingStates),
    ),
    after,
    edits: afterEdits,
  );
}
