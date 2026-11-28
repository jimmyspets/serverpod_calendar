import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'event_protocol_values.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';

enum RecurringInvitationResponseRole { master, single, range }

enum RecurringInvitationResponseBlock {
  masterCancelled,
  singleCancelled,
  rangeCancelled,
}

/// Semantic selection only: no proof of currentness, completeness or authority.
final class RecurringInvitationResponseTarget {
  const RecurringInvitationResponseTarget._(
    this.originalStart,
    this.sourceMessage,
    this.role,
    this.sourceOriginalStart,
    this.block,
  );
  final CalendarEventTiming originalStart;
  final IcalendarSchedulingMessage sourceMessage;
  final RecurringInvitationResponseRole role;
  final CalendarEventTiming? sourceOriginalStart;
  final RecurringInvitationResponseBlock? block;
  bool get blocked => block != null;
  int? get sequence => sourceMessage.events.single.sequence;
  DateTime get stamp => sourceMessage.events.single.stamp;
}

/// Selects among caller-supplied current notices and explicitly active cutoffs.
/// Never discovers history or infers restoration from a later REQUEST.
RecurringInvitationResponseTarget resolveRecurringInvitationResponseTarget({
  required IcalendarSchedulingMessage master,
  required CalendarEventTiming originalStart,
  required String recipientAddress,
  Iterable<IcalendarSchedulingMessage> notices = const [],
  Iterable<IcalendarSchedulingMessage> activeRangeCancellations = const [],
  int maxNotices = 64,
  int maxBytes = 262144,
  int maxComponents = 1000,
  int maxZones = 32,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  RangeError.checkValueInInterval(maxNotices, 0, 64);
  RangeError.checkValueInInterval(maxBytes, 1, 262144);
  RangeError.checkValueInInterval(
    maxComponents,
    1,
    const IcalendarSyntaxLimits().maxComponents,
  );
  RangeError.checkValueInInterval(
    maxZones,
    0,
    const IcalendarComponentLimits().maxZones,
  );
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid work limit');
  }
  if (originalStart.end != null || originalStart.duration != null) {
    throw ArgumentError('Original must be a point');
  }
  validateEventTiming(originalStart);
  var bytes = 0, components = 0, zones = 0, count = 0;
  final syntax = IcalendarSyntaxLimits(maxBytes: maxBytes);
  void countComponent(IcalendarSyntaxComponent c) {
    work.charge();
    if (++components > maxComponents) {
      throw const RecurrenceLimitException('responseSelectionComponents');
    }
    if (c.canonicalName == 'VTIMEZONE' && ++zones > maxZones) {
      throw const RecurrenceLimitException('responseSelectionZones');
    }
    for (final child in c.entries.whereType<IcalendarSyntaxComponent>()) {
      countComponent(child);
    }
  }

  IcalendarSchedulingMessage checked(IcalendarSchedulingMessage input) {
    final encoded = serializeIcalendarSyntax(input.source, limits: syntax);
    bytes += encoded.length;
    for (var i = 0; i < encoded.length; i += 64) {
      work.charge();
    }
    if (bytes > maxBytes) {
      throw const RecurrenceLimitException('responseSelectionBytes');
    }
    for (final c in input.source.components) {
      countComponent(c);
    }
    final value = validateIcalendarSchedulingMessage(
      input.source,
      syntaxLimits: syntax,
      sharedWorkBudget: work,
    );
    if (value.events.length != 1) {
      throw ArgumentError('One component per packet required');
    }
    final claims = value.events.single.participants;
    if (claims.organizer == null ||
        claims.organizer!.sentBy != null ||
        claims.attendees.isEmpty ||
        claims.attendees.length > 64 ||
        !claims.attendees.any((a) => a.address == recipientAddress) ||
        claims.attendees.map((a) => a.address).toSet().length !=
            claims.attendees.length ||
        claims.attendees.any(
          (a) =>
              a.sentBy != null ||
              a.delegatedFrom.isNotEmpty ||
              a.delegatedTo.isNotEmpty ||
              a.participationStatus?.toUpperCase() == 'DELEGATED',
        )) {
      throw ArgumentError('Unsupported participant claims');
    }
    return value;
  }

  final basis = checked(master), head = basis.events.single;
  if (basis.method != IcalendarSchedulingMethod.request ||
      head.isOverride ||
      head.recurrence == null) {
    throw ArgumentError('Ordinary recurring REQUEST required');
  }
  final root = basis.source.components.single;
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
  final content = eventStorageProposal(
    calendar.series.single,
    sharedWorkBudget: work,
  ).content;
  void member(CalendarEventTiming point) {
    if (!eventSchedulingMember(content, point, sharedWorkBudget: work)) {
      throw ArgumentError('Original is not a member');
    }
  }

  member(originalStart);
  CalendarEventTiming anchor(IcalendarSchedulingEvent e) {
    final date = e.originalDate, time = e.originalTime;
    return CalendarEventTiming(
      kind: date != null
          ? CalendarEventTimeKind.date
          : time!.zoneId == null
          ? CalendarEventTimeKind.utc
          : CalendarEventTimeKind.zoned,
      start: date != null ? eventDate(date) : eventCivil(time!.civil),
      zoneId: time?.zoneId,
    );
  }

  int order(CalendarEventTiming a, CalendarEventTiming b) {
    DateTime civil(CalendarEventTiming t) {
      final c = t.start;
      return DateTime.utc(c.year, c.month, c.day, c.hour, c.minute, c.second);
    }

    return civil(a).compareTo(civil(b));
  }

  final keys = <String>{}, cutoffKeys = <String>{};
  final values = <(IcalendarSchedulingMessage, CalendarEventTiming, bool)>[];
  void add(IcalendarSchedulingMessage input, bool cutoff) {
    work.charge();
    if (++count > maxNotices) {
      throw const RecurrenceLimitException('responseSelectionNotices');
    }
    final value = checked(input), e = value.events.single;
    if (value.uid != basis.uid ||
        e.participants.organizer!.address !=
            head.participants.organizer!.address ||
        !e.isOverride ||
        e.recurrence != null ||
        !{
          IcalendarSchedulingMethod.request,
          IcalendarSchedulingMethod.cancel,
        }.contains(value.method) ||
        cutoff !=
            (e.isThisAndFuture &&
                value.method == IcalendarSchedulingMethod.cancel) ||
        value.method == IcalendarSchedulingMethod.cancel &&
            e.status != IcalendarEventStatus.cancelled) {
      throw ArgumentError('Unsupported correlated notice');
    }
    final point = anchor(e);
    member(point);
    final key = '${e.isThisAndFuture}:${eventComponentKey(point, false)}';
    if (!(cutoff ? cutoffKeys : keys).add(key)) {
      throw ArgumentError('Duplicate notice target');
    }
    values.add((value, point, cutoff));
  }

  for (final notice in notices) {
    add(notice, false);
  }
  for (final cutoff in activeRangeCancellations) {
    add(cutoff, true);
  }
  // Validate every supplied packet before returning any selected/blocked result.
  RecurringInvitationResponseTarget result(
    IcalendarSchedulingMessage source,
    CalendarEventTiming? point,
    RecurringInvitationResponseBlock? block,
  ) => RecurringInvitationResponseTarget._(
    originalStart,
    source,
    point == null
        ? RecurringInvitationResponseRole.master
        : source.events.single.isThisAndFuture
        ? RecurringInvitationResponseRole.range
        : RecurringInvitationResponseRole.single,
    point,
    block,
  );
  if (head.status == IcalendarEventStatus.cancelled) {
    return result(
      basis,
      null,
      RecurringInvitationResponseBlock.masterCancelled,
    );
  }
  (IcalendarSchedulingMessage, CalendarEventTiming, bool)? single,
      range,
      cutoff;
  final originalKey = eventComponentKey(originalStart, false);
  for (final value in values) {
    work.charge();
    final e = value.$1.events.single;
    if (value.$3 && order(value.$2, originalStart) <= 0) {
      if (cutoff == null || order(value.$2, cutoff.$2) < 0) {
        cutoff = value;
      }
    } else if (!e.isThisAndFuture &&
        eventComponentKey(value.$2, false) == originalKey) {
      single = value;
    } else if (!value.$3 &&
        e.isThisAndFuture &&
        order(value.$2, originalStart) <= 0 &&
        (range == null || order(value.$2, range.$2) > 0)) {
      range = value;
    }
  }
  if (cutoff != null) {
    return result(
      cutoff.$1,
      cutoff.$2,
      RecurringInvitationResponseBlock.rangeCancelled,
    );
  }
  final selected = single ?? range;
  return selected == null
      ? result(basis, null, null)
      : result(
          selected.$1,
          selected.$2,
          selected.$1.method == IcalendarSchedulingMethod.cancel ||
                  selected.$1.events.single.status ==
                      IcalendarEventStatus.cancelled
              ? RecurringInvitationResponseBlock.singleCancelled
              : null,
        );
}
