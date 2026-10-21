import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'availability_values.dart';
import 'generated/protocol.dart';

const availabilityMaxSequence = 2147483647;
DateTime availabilityProtocolInstant(DateTime value) =>
    DateTime.fromMillisecondsSinceEpoch(
      (value.toUtc().millisecondsSinceEpoch ~/ 1000) * 1000,
      isUtc: true,
    );

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

CalendarAvailabilityProtocolState validateAvailabilityProtocolState(
  CalendarAvailabilityProtocolState state,
  CalendarAvailabilityContent content,
) {
  void instant(DateTime value) {
    if (!value.isUtc || value.microsecondsSinceEpoch % 1000000 != 0) {
      throw ArgumentError('Whole-second UTC protocol time required');
    }
  }

  RangeError.checkValueInInterval(state.sequence, 0, availabilityMaxSequence);
  for (final v in [state.created, state.stamp, state.lastModified]) {
    instant(v);
  }
  if (state.stamp != state.lastModified ||
      state.created.isAfter(state.lastModified) ||
      state.openings.length != content.openings.length) {
    throw ArgumentError('Invalid protocol state');
  }
  final ids = content.openings.map((o) => o.uid).toSet();
  final seen = <Object>{};
  for (final opening in state.openings) {
    if (!ids.contains(opening.openingUid) || !seen.add(opening.openingUid)) {
      throw ArgumentError('Invalid opening protocol identity');
    }
    for (final v in [opening.stamp, opening.lastModified, ?opening.created]) {
      instant(v);
    }
    if (opening.stamp != opening.lastModified ||
        opening.lastModified.isAfter(state.lastModified) ||
        (opening.created?.isAfter(opening.lastModified) ?? false)) {
      throw ArgumentError('Invalid opening protocol time');
    }
  }
  return state.copyWith(openings: List.unmodifiable(state.openings));
}

CalendarAvailabilityProtocolState advanceAvailabilityProtocol(
  CalendarAvailabilityProtocolState current,
  CalendarAvailabilityContent before,
  List<CalendarAvailabilityOpeningEdits>? beforeEdits,
  CalendarAvailabilityContent after,
  List<CalendarAvailabilityOpeningEdits>? afterEdits,
  DateTime now,
) {
  Object? edits(List<CalendarAvailabilityOpeningEdits>? value) =>
      value?.map((v) => v.toJson()).toList();
  if (jsonEncode(before.toJson()) == jsonEncode(after.toJson()) &&
      jsonEncode(edits(beforeEdits)) == jsonEncode(edits(afterEdits))) {
    return current;
  }
  if (current.sequence == availabilityMaxSequence) {
    throw const AvailabilityLimitException('protocolSequence');
  }
  final stamp = availabilityProtocolInstant(now);
  if (stamp.isBefore(current.lastModified)) {
    throw ArgumentError('Protocol time cannot go backwards');
  }
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
    openingStates.add(
      previous == null
          ? CalendarAvailabilityOpeningProtocolState(
              openingUid: opening.uid!,
              created: stamp,
              stamp: stamp,
              lastModified: stamp,
            )
          : changed
          ? previous.copyWith(stamp: stamp, lastModified: stamp)
          : previous,
    );
  }
  return validateAvailabilityProtocolState(
    current.copyWith(
      sequence: current.sequence + 1,
      stamp: stamp,
      lastModified: stamp,
      openings: List.unmodifiable(openingStates),
    ),
    after,
  );
}
