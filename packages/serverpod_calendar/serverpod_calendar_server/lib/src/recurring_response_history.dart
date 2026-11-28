import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'event_protocol_values.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';
import 'invitation_occurrence_values.dart';
import 'recurring_invitation_response_values.dart';

CalendarEventTiming recurringResponsePoint(IcalendarSchedulingEvent e) {
  final d = e.originalDate ?? e.startDate;
  final t = e.originalTime ?? e.startTime;
  if (d == null && t == null) {
    throw ArgumentError('Missing identity');
  }
  return CalendarEventTiming(
    kind: d != null
        ? CalendarEventTimeKind.date
        : t!.zoneId == null
        ? CalendarEventTimeKind.utc
        : CalendarEventTimeKind.zoned,
    start: d != null ? eventDate(d) : eventCivil(t!.civil),
    zoneId: t?.zoneId,
  );
}

int recurringResponseOrder(CalendarEventTiming a, CalendarEventTiming b) {
  DateTime value(CalendarEventTiming t) {
    final c = t.start;
    return DateTime.utc(c.year, c.month, c.day, c.hour, c.minute, c.second);
  }

  return value(a).compareTo(value(b));
}

String recurringResponsePacketKey(IcalendarSchedulingMessage p) {
  final e = p.events.single;
  return e.isOverride
      ? '${e.isThisAndFuture}:${eventComponentKey(recurringResponsePoint(e), false)}'
      : 'master';
}

/// Replays semantic cancellation/restoration proof, not just its outer digest.
void validateRecurringResponseHistory(
  Map<String, dynamic> data,
  Map<String, IcalendarSchedulingMessage> packets,
  String recipient,
  RecurrenceWorkBudget work,
) {
  if (data['version'] != 1) {
    throw ArgumentError('Unknown history version');
  }
  IcalendarSchedulingMessage packet(String id) =>
      packets[id] ?? (throw ArgumentError('Missing proof source'));
  final claimed = recurringResponseCycles(data),
      derived = <Map<String, dynamic>>[];
  final events = (data['events'] as List).cast<Map<String, dynamic>>();
  final current = (data['current'] as List).cast<Map<String, dynamic>>();
  if (events.length + current.length - 1 > 64 ||
      current.isEmpty ||
      current.length > 65) {
    throw const RecurrenceLimitException('replyProofHistorySlots');
  }
  final required = <String>{
    data['membership'] as String,
    data['root'] as String,
    ...(data['retained'] as List).cast<String>(),
    ...current.map((v) => v['source'] as String),
  };
  for (final event in events) {
    work.charge();
    final id = event['source'] as String,
        member = event['floorMaster'] as String;
    final retained = (event['floorNotices'] as List).cast<String>();
    required.addAll([id, member, ...retained]);
    final source = packet(id), e = source.events.single;
    final anchor = recurringResponsePoint(e), index = event['cycle'] as int;
    final floor = recurringResponseHistoryFloor(
      packet(member),
      retained,
      derived,
      packets,
      anchor,
    );
    if (e.sequence == null || e.sequence! <= floor || !e.isThisAndFuture) {
      throw ArgumentError('Invalid source version floor');
    }
    if (event['kind'] == 'cancel') {
      if (index != derived.length ||
          index >= claimed.length ||
          source.method != IcalendarSchedulingMethod.cancel ||
          e.status != IcalendarEventStatus.cancelled) {
        throw ArgumentError('Invalid cancellation transition');
      }
      final cycle = claimed[index];
      final claimedPoint = CalendarEventTiming.fromJson(cycle['anchor']);
      if (claimedPoint.end != null || claimedPoint.duration != null) {
        throw ArgumentError('Invalid cutoff point');
      }
      validateEventTiming(claimedPoint);
      if (jsonEncode(claimedPoint.toJson()) != jsonEncode(anchor.toJson())) {
        throw ArgumentError('Different cutoff profile');
      }
      if (cycle['cancel'] != id ||
          eventComponentKey(
                CalendarEventTiming.fromJson(cycle['anchor']),
                false,
              ) !=
              eventComponentKey(anchor, false)) {
        throw ArgumentError('Different cancellation identity');
      }
      final active = derived
          .where(
            (c) =>
                recurringResponseActive(c) &&
                eventComponentKey(
                      CalendarEventTiming.fromJson(c['anchor']),
                      false,
                    ) ==
                    eventComponentKey(anchor, false),
          )
          .firstOrNull;
      if (cycle['basisMaster'] != (active?['basisMaster'] ?? member) ||
          jsonEncode(cycle['basisNotices']) !=
              jsonEncode(active?['basisNotices'] ?? retained)) {
        throw ArgumentError('Different frozen basis');
      }
      final basis = recurringResponseMasterProposal(
        packet(cycle['basisMaster'] as String),
        work,
      );
      if (!eventSchedulingMember(
        basis.content,
        anchor,
        sharedWorkBudget: work,
      )) {
        throw ArgumentError('Orphaned cancellation anchor');
      }
      if (active != null) {
        active['superseded'] = id;
      }
      derived.add({...cycle, 'restored': null, 'superseded': null});
    } else if (event['kind'] == 'restore') {
      if (index < 0 ||
          index >= derived.length ||
          source.method != IcalendarSchedulingMethod.request ||
          !recurringResponseActive(derived[index])) {
        throw ArgumentError('Invalid restoration transition');
      }
      validateRecurringResponseRestoration(
        derived[index],
        source,
        packets,
        recipient,
        work,
      );
      derived[index]['restored'] = id;
    } else {
      throw ArgumentError('Unknown proof transition');
    }
  }
  if (jsonEncode(derived) != jsonEncode(claimed)) {
    throw ArgumentError('Unproven history state');
  }
  for (final c in claimed) {
    required.addAll([
      c['cancel'] as String,
      c['basisMaster'] as String,
      ...(c['basisNotices'] as List).cast<String>(),
      if (c['restored'] != null) c['restored'] as String,
      if (c['superseded'] != null) c['superseded'] as String,
    ]);
  }
  final ids = (data['sources'] as List).cast<String>().toSet();
  if (ids.length > 65 ||
      ids.length != required.length ||
      !ids.containsAll(required) ||
      !packets.keys.toSet().containsAll(ids)) {
    throw ArgumentError('Different proof closure');
  }
  final master = packet(data['membership'] as String),
      root = packet(data['root'] as String);
  if (root.events.single.isOverride ||
      data['wholeCancelled'] !=
          (root.method != IcalendarSchedulingMethod.request)) {
    throw ArgumentError('Different whole-series state');
  }
  if (data['complete'] == true) {
    for (final ref in current) {
      final source = packet(ref['source'] as String);
      if (source.events.single.isThisAndFuture &&
          source.method == IcalendarSchedulingMethod.cancel &&
          !claimed.any((c) => c['cancel'] == ref['source'])) {
        throw ArgumentError('Unproven current cancellation');
      }
    }
    selectRecurringResponseHistory(
      data,
      packets,
      recurringResponsePoint(master.events.single),
      recipient,
      work,
    );
  }
}

EventStorageProposal recurringResponseMasterProposal(
  IcalendarSchedulingMessage p,
  RecurrenceWorkBudget work,
) {
  final root = p.source.components.single;
  final calendar = validateIcalendarEventCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(
        root.name,
        root.entries.where(
          (e) => e is! IcalendarSyntaxProperty || e.canonicalName != 'METHOD',
        ),
      ),
    ]),
    sharedWorkBudget: work,
  );
  return eventStorageProposal(calendar.series.single, sharedWorkBudget: work);
}

List<Map<String, dynamic>> recurringResponseCycles(Map<String, dynamic> data) =>
    (data['cycles'] as List)
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
bool recurringResponseActive(Map<String, dynamic> cycle) =>
    cycle['restored'] == null && cycle['superseded'] == null;

/// A versioned source-only ledger. No source packet establishes trust/currentness.
Map<String, dynamic> buildRecurringResponseHistory({
  Map<String, dynamic>? previous,
  required String masterEntryId,
  required String rootSourceId,
  required String membershipSourceId,
  required List<Map<String, dynamic>> current,
  required String incomingSourceId,
  required Map<String, IcalendarSchedulingMessage> packets,
  required String recipientAddress,
  required RecurrenceWorkBudget work,
  int maxHistorySlots = 64,
}) {
  if (maxHistorySlots < 1 ||
      maxHistorySlots > 64 ||
      packets.length > 65 ||
      work.maxWork > eventMaxCandidateWork) {
    throw const RecurrenceLimitException('replyHistorySize');
  }
  IcalendarSchedulingMessage packet(String id) =>
      packets[id] ?? (throw ArgumentError('Missing evidence'));
  final master = packet(membershipSourceId), root = packet(rootSourceId);
  var byteCount = 0, components = 0, zones = 0;
  void count(IcalendarSyntaxComponent c) {
    work.charge();
    if (++components > 1000 || c.canonicalName == 'VTIMEZONE' && ++zones > 32) {
      throw const RecurrenceLimitException('replyHistoryComponents');
    }
    for (final child in c.entries.whereType<IcalendarSyntaxComponent>()) {
      count(child);
    }
  }

  for (final source in packets.values) {
    final bytes = serializeIcalendarSyntax(source.source);
    byteCount += bytes.length;
    for (var i = 0; i < bytes.length; i += 64) {
      work.charge();
    }
    if (byteCount > 262144) {
      throw const RecurrenceLimitException('replyHistoryBytes');
    }
    for (final c in source.source.components) {
      count(c);
    }
    final checked = validateIcalendarSchedulingMessage(
      source.source,
      sharedWorkBudget: work,
    );
    if (checked.events.length != 1 ||
        checked.uid != master.uid ||
        checked.events.single.participants.organizer?.address !=
            master.events.single.participants.organizer?.address ||
        !checked.events.single.participants.attendees.any(
          (a) => a.address == recipientAddress,
        )) {
      throw ArgumentError('Invalid source closure');
    }
  }
  if (master.method != IcalendarSchedulingMethod.request ||
      master.events.single.isOverride ||
      master.events.single.recurrence == null ||
      root.events.single.isOverride) {
    throw ArgumentError('Invalid recurring membership');
  }
  final cycles = previous == null
      ? <Map<String, dynamic>>[]
      : recurringResponseCycles(previous);
  final events = (previous?['events'] as List? ?? const [])
      .map((v) => Map<String, dynamic>.from(v as Map))
      .toList();
  final retained = <String, String>{};
  for (final id
      in (previous?['retained'] as List? ?? const []).cast<String>()) {
    retained[recurringResponsePacketKey(packet(id))] = id;
  }
  final incoming = packet(incomingSourceId), e = incoming.events.single;
  final incomingKey = recurringResponsePacketKey(incoming);
  var complete = true;
  int floor(CalendarEventTiming anchor) => recurringResponseHistoryFloor(
    master,
    retained.values.toList(),
    cycles,
    packets,
    anchor,
  );
  if (e.isThisAndFuture &&
      incoming.method == IcalendarSchedulingMethod.cancel) {
    final anchor = recurringResponsePoint(e);
    if (e.sequence == null || e.sequence! <= floor(anchor)) {
      complete = false;
    } else {
      final prior = cycles
          .where(
            (c) =>
                recurringResponseActive(c) &&
                eventComponentKey(
                      CalendarEventTiming.fromJson(c['anchor']),
                      false,
                    ) ==
                    eventComponentKey(anchor, false),
          )
          .firstOrNull;
      if (cycles.length >= maxHistorySlots) {
        throw const RecurrenceLimitException('replyHistorySlots');
      }
      final cycle = <String, dynamic>{
        'anchor': anchor.toJson(),
        'cancel': incomingSourceId,
        'basisMaster':
            prior?['basisMaster'] ??
            previous?['membership'] ??
            membershipSourceId,
        'basisNotices': prior?['basisNotices'] ?? retained.values.toList(),
        'restored': null,
        'superseded': null,
      };
      if (prior != null) {
        prior['superseded'] = incomingSourceId;
      }
      events.add({
        'kind': 'cancel',
        'cycle': cycles.length,
        'source': incomingSourceId,
        'floorMaster': membershipSourceId,
        'floorNotices': retained.values.toList(),
      });
      cycles.add(cycle);
    }
  } else if (incoming.method == IcalendarSchedulingMethod.request &&
      e.isOverride) {
    final active = e.isThisAndFuture
        ? cycles
              .where(
                (c) =>
                    recurringResponseActive(c) &&
                    eventComponentKey(
                          CalendarEventTiming.fromJson(c['anchor']),
                          false,
                        ) ==
                        eventComponentKey(recurringResponsePoint(e), false),
              )
              .firstOrNull
        : null;
    var mayRetain = active == null;
    if (active != null &&
        e.sequence != null &&
        e.sequence! > floor(recurringResponsePoint(e))) {
      try {
        validateRecurringResponseRestoration(
          active,
          incoming,
          packets,
          recipientAddress,
          work,
        );
        events.add({
          'kind': 'restore',
          'cycle': cycles.indexOf(active),
          'source': incomingSourceId,
          'floorMaster': membershipSourceId,
          'floorNotices': retained.values.toList(),
        });
        active['restored'] = incomingSourceId;
        mayRetain = true;
      } on RecurrenceLimitException {
        rethrow;
      } on ArgumentError {
        if (work.remaining <= 0) {
          throw const RecurrenceLimitException('replyHistoryWork');
        }
        /* Not a restore-only notice. Keep mask. */
      }
    }
    if (mayRetain) {
      retained[incomingKey] = incomingSourceId;
    }
  }
  final currentIds = current.map((v) => v['source'] as String).toList();
  for (final id in currentIds) {
    final p = packet(id);
    if (p.events.single.isThisAndFuture &&
        p.method == IcalendarSchedulingMethod.cancel &&
        !cycles.any((c) => c['cancel'] == id)) {
      complete = false;
    }
  }
  final activeIds = cycles
      .where(recurringResponseActive)
      .map((c) => c['cancel'] as String)
      .toList();
  final notices = currentIds
      .where(
        (id) =>
            packet(id).events.single.isOverride &&
            !(packet(id).events.single.isThisAndFuture &&
                packet(id).method == IcalendarSchedulingMethod.cancel),
      )
      .map(packet)
      .toList();
  try {
    resolveRecurringInvitationResponseTarget(
      master: master,
      originalStart: recurringResponsePoint(master.events.single),
      recipientAddress: recipientAddress,
      notices: notices,
      activeRangeCancellations: activeIds.map(packet).toList(),
      sharedWorkBudget: work,
    );
  } on RecurrenceLimitException {
    rethrow;
  } on ArgumentError {
    if (work.remaining <= 0) {
      throw const RecurrenceLimitException('replyHistoryWork');
    }
    complete = false;
  }
  final required = <String>{
    membershipSourceId,
    rootSourceId,
    ...currentIds,
    ...retained.values,
  };
  for (final c in cycles) {
    required.addAll([
      c['cancel'] as String,
      c['basisMaster'] as String,
      ...(c['basisNotices'] as List).cast<String>(),
      if (c['restored'] != null) c['restored'] as String,
      if (c['superseded'] != null) c['superseded'] as String,
    ]);
  }
  for (final event in events) {
    required.add(event['source'] as String);
    required.add(event['floorMaster'] as String);
    required.addAll((event['floorNotices'] as List).cast<String>());
  }
  if (required.length > 65 ||
      events.length + current.length - 1 > maxHistorySlots) {
    throw const RecurrenceLimitException('replyHistoryClosure');
  }
  final ids = required.toList()..sort();
  return {
    'version': 1,
    'recipientAddress': recipientAddress,
    'master': masterEntryId,
    'membership': membershipSourceId,
    'root': rootSourceId,
    'current': current,
    'retained': retained.values.toList()..sort(),
    'cycles': cycles,
    'events': events,
    'sources': ids,
    'complete': complete,
    'wholeCancelled': root.method != IcalendarSchedulingMethod.request,
  };
}

RecurringInvitationResponseTarget selectRecurringResponseHistory(
  Map<String, dynamic> data,
  Map<String, IcalendarSchedulingMessage> packets,
  CalendarEventTiming original,
  String recipient,
  RecurrenceWorkBudget work,
) {
  if (data['version'] != 1 || data['complete'] != true) {
    throw ArgumentError('Incomplete history');
  }
  IcalendarSchedulingMessage packet(String id) =>
      packets[id] ?? (throw ArgumentError('Missing source'));
  final current = (data['current'] as List).cast<Map<String, dynamic>>();
  return resolveRecurringInvitationResponseTarget(
    master: packet(data['membership'] as String),
    originalStart: original,
    recipientAddress: recipient,
    notices: current
        .map((v) => packet(v['source'] as String))
        .where(
          (p) =>
              p.events.single.isOverride &&
              !(p.events.single.isThisAndFuture &&
                  p.method == IcalendarSchedulingMethod.cancel),
        )
        .toList(),
    activeRangeCancellations: recurringResponseCycles(data)
        .where(recurringResponseActive)
        .map((c) => packet(c['cancel'] as String))
        .toList(),
    sharedWorkBudget: work,
  );
}

int recurringResponseHistoryFloor(
  IcalendarSchedulingMessage master,
  List<String> retainedIds,
  List<Map<String, dynamic>> cycles,
  Map<String, IcalendarSchedulingMessage> packets,
  CalendarEventTiming anchor,
) {
  IcalendarSchedulingMessage packet(String id) =>
      packets[id] ?? (throw ArgumentError('Missing floor source'));
  var result = master.events.single.sequence ?? 0;
  IcalendarSchedulingMessage? underlying;
  for (final id in retainedIds) {
    final source = packet(id), item = source.events.single;
    final point = recurringResponsePoint(item),
        order = recurringResponseOrder(point, anchor);
    if (order >= 0) {
      final v = item.sequence ?? 0;
      if (v > result) {
        result = v;
      }
    }
    if (item.isThisAndFuture &&
        order <= 0 &&
        (underlying == null ||
            recurringResponseOrder(
                  point,
                  recurringResponsePoint(underlying.events.single),
                ) >
                0)) {
      underlying = source;
    }
  }
  final u = underlying?.events.single.sequence ?? 0;
  if (u > result) {
    result = u;
  }
  for (final c in cycles) {
    for (final id in [
      c['restored'],
      if (recurringResponseActive(c)) c['cancel'],
    ]) {
      if (id != null) {
        final v = packet(id as String).events.single.sequence ?? 0;
        if (v > result) {
          result = v;
        }
      }
    }
  }
  return result;
}

void validateRecurringResponseRestoration(
  Map<String, dynamic> active,
  IcalendarSchedulingMessage incoming,
  Map<String, IcalendarSchedulingMessage> packets,
  String recipientAddress,
  RecurrenceWorkBudget work,
) {
  IcalendarSchedulingMessage packet(String id) =>
      packets[id] ?? (throw ArgumentError('Missing frozen source'));
  final frozenMaster = packet(active['basisMaster'] as String);
  final anchor = CalendarEventTiming.fromJson(active['anchor']);
  final frozenNotices = (active['basisNotices'] as List)
      .cast<String>()
      .map(packet)
      .toList();
  final target = resolveRecurringInvitationResponseTarget(
    master: frozenMaster,
    originalStart: anchor,
    recipientAddress: recipientAddress,
    notices: frozenNotices,
    sharedWorkBudget: work,
  );
  final proposal = recurringResponseMasterProposal(frozenMaster, work);
  CalendarEventTimingOverrides? edits;
  var state = proposal.protocolState;
  if (target.role != RecurringInvitationResponseRole.master) {
    final projected = target.role == RecurringInvitationResponseRole.range
        ? projectInvitationRangeRequest(
            protocolUid: proposal.protocolUid,
            content: proposal.content,
            protocolState: state,
            message: target.sourceMessage,
            recipientAddress: recipientAddress,
            sharedWorkBudget: work,
          )
        : projectInvitationOccurrence(
            protocolUid: proposal.protocolUid,
            content: proposal.content,
            protocolState: state,
            message: target.sourceMessage,
            recipientAddress: recipientAddress,
            sharedWorkBudget: work,
          );
    edits = projected.timingOverrides;
    state = projected.protocolState;
  }
  projectInvitationRangeRestoration(
    protocolUid: proposal.protocolUid,
    content: proposal.content,
    timingOverrides:
        (edits ??
                CalendarEventTimingOverrides(
                  singles: const [],
                  future: const [],
                ))
            .copyWith(
              cancelledFrom: anchor,
            ),
    protocolState: state,
    cancellationVersion: CalendarEventProtocolVersion(
      sequence: packet(active['cancel'] as String).events.single.sequence,
      stamp: packet(active['cancel'] as String).events.single.stamp,
    ),
    message: incoming,
    recipientAddress: recipientAddress,
    sharedWorkBudget: work,
  );
}
