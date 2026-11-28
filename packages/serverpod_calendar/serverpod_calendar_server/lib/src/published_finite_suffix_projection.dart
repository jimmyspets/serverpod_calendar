import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_protocol_values.dart';
import 'event_values.dart';
import 'event_wire_output.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';

/// A pure, untrusted projection. It proves neither publication nor authority.
final class PublishedFiniteSuffixProjection {
  PublishedFiniteSuffixProjection._(
    this.candidate,
    this._content,
    List<CalendarEventTiming> originals,
    Iterable<IcalendarSyntaxComponent> suppressed,
  ) : _originals = List.unmodifiable(originals.map((v) => v.toJson())),
      suppressedComponents = List.unmodifiable(suppressed);

  final IcalendarSyntaxDocument candidate;
  final CalendarEventContent _content;
  final List<Map<String, dynamic>> _originals;

  /// Immutable source components omitted from the candidate.
  final List<IcalendarSyntaxComponent> suppressedComponents;

  /// Detached original identities that were added as publication-only masks.
  List<CalendarEventTiming> get exclusions => List.unmodifiable(
    _originals.map((v) => CalendarEventTiming.fromJson(v)),
  );
}

/// Projects a finite suffix into master EXDATEs, without mutating its source.
PublishedFiniteSuffixProjection projectPublishedFiniteSuffix({
  required IcalendarSyntaxDocument basis,
  required CalendarEventTiming originalStart,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid work limit');
  }
  final input = serializeIcalendarSyntax(
    basis,
    limits: const IcalendarSyntaxLimits(maxBytes: 524288),
  );
  for (var i = 0; i < input.length; i += 64) {
    work.charge();
  }
  final message = validateIcalendarSchedulingMessage(
    basis,
    sharedWorkBudget: work,
  );
  if (message.method != IcalendarSchedulingMethod.request ||
      message.events.where((e) => !e.isOverride).length != 1) {
    throw ArgumentError('Expected one REQUEST master');
  }
  final root = basis.components.single;
  final calendar = validateIcalendarEventCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(root.name, [
        for (final entry in root.entries)
          if (entry is! IcalendarSyntaxProperty ||
              entry.canonicalName != 'METHOD')
            entry,
      ]),
    ]),
    sharedWorkBudget: work,
  );
  if (calendar.series.length != 1) throw ArgumentError('Expected one series');
  final content = eventWireProjection(
    calendar.series.single,
    sharedWorkBudget: work,
  ).content;
  final rule = content.recurrence?.rule;
  if (rule == null ||
      rule.count == null && rule.untilDate == null && rule.untilUtc == null ||
      originalStart.end != null ||
      originalStart.duration != null ||
      !eventSchedulingMember(content, originalStart, sharedWorkBudget: work)) {
    throw ArgumentError('Expected a finite series and an included original');
  }
  final originals = <CalendarEventTiming>[];
  var current = originalStart;
  while (true) {
    if (originals.length >= 256) {
      throw const RecurrenceLimitException('suffixExclusions');
    }
    originals.add(current);
    final last = current.kind == CalendarEventTimeKind.date
        ? eventSchedulingDateIsProvablyLast(
            content,
            current,
            sharedWorkBudget: work,
          )
        : eventSchedulingTimedIsProvablyLast(
            content,
            current,
            sharedWorkBudget: work,
          );
    if (last) break;
    final CalendarEventTiming? next;
    if (current.kind == CalendarEventTimeKind.date) {
      next = eventSchedulingNextDateInWindow(
        content,
        current,
        CalendarDate(year: 2099, month: 12, day: 31),
        sharedWorkBudget: work,
      );
    } else {
      next = eventSchedulingNextTimedInWindow(
        content,
        current,
        CalendarEventTiming(
          kind: current.kind,
          zoneId: current.zoneId,
          start: CalendarEventCivil(
            year: 2099,
            month: 12,
            day: 31,
            hour: 23,
            minute: 59,
            second: 59,
          ),
        ),
        sharedWorkBudget: work,
      );
    }
    if (next == null) throw ArgumentError('Cannot prove suffix exhaustion');
    current = next;
  }
  DateTime order(CalendarEventTiming v) => DateTime.utc(
    v.start.year,
    v.start.month,
    v.start.day,
    v.start.hour,
    v.start.minute,
    v.start.second,
  );
  final master = message.events.singleWhere((e) => !e.isOverride);
  final omitted = message.events
      .where(
        (e) =>
            e.isOverride &&
            !order(_finiteSuffixPoint(e.originalStart!))
                .isBefore(order(originalStart)),
      )
      .map((e) => e.source)
      .toSet();
  final writer = EventComponentWriter();
  final candidate = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent(root.name, [
      for (final entry in root.entries)
        if (!omitted.contains(entry))
          if (identical(entry, master.source))
            IcalendarSyntaxComponent(master.source.name, [
              ...master.source.entries,
              for (final original in originals) writer.time('EXDATE', original),
            ])
          else
            entry,
    ]),
  ]);
  final output = serializeIcalendarSyntax(
    candidate,
    limits: const IcalendarSyntaxLimits(maxBytes: 524288),
  );
  for (var i = 0; i < output.length; i += 64) {
    work.charge();
  }
  parseIcalendarSchedulingMessage(output, sharedWorkBudget: work);
  final projectedRoot = candidate.components.single;
  validateIcalendarEventCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(projectedRoot.name, [
        for (final entry in projectedRoot.entries)
          if (entry is! IcalendarSyntaxProperty ||
              entry.canonicalName != 'METHOD')
            entry,
      ]),
    ]),
    sharedWorkBudget: work,
  );
  return PublishedFiniteSuffixProjection._(
    candidate,
    content,
    originals,
    omitted,
  );
}

CalendarEventTiming _finiteSuffixPoint(Object value) => value is CalendarDate
    ? CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: eventDate(value),
      )
    : CalendarEventTiming(
        kind: (value as TimedValue).zoneId == null
            ? CalendarEventTimeKind.utc
            : CalendarEventTimeKind.zoned,
        zoneId: value.zoneId,
        start: eventCivil(value.civil),
      );

/// Compose the exact finite reopening message from a validated unmasked basis.
/// The caller must establish publication history and authenticate individual
/// masks before invoking this projection.
(IcalendarSchedulingMessage, PublishedFiniteSuffixProjection)
composePublishedCutoffReopening({
  required IcalendarSyntaxDocument basis,
  required CalendarEventTiming cutoff,
  required List<CalendarEventTiming> individualMasks,
  required int sequenceFloor,
  required DateTime stamp,
  required int maxBytes,
  required RecurrenceWorkBudget work,
}) {
  if (individualMasks.length > 64 ||
      sequenceFloor < 0 ||
      !stamp.isUtc ||
      eventProtocolInstant(stamp) != stamp) {
    throw ArgumentError('Invalid reopening proof');
  }
  final suffix = projectPublishedFiniteSuffix(
    basis: basis,
    originalStart: cutoff,
    sharedWorkBudget: work,
  );
  final writer = EventComponentWriter();
  final suffixKeys = suffix.exclusions
      .map((p) => eventComponentKey(p, false))
      .toSet();
  final masks = <String, CalendarEventTiming>{};
  for (final mask in individualMasks) {
    final key = eventComponentKey(mask, false);
    if (mask.end != null ||
        mask.duration != null ||
        masks.containsKey(key) ||
        !eventSchedulingMember(suffix._content, mask, sharedWorkBudget: work)) {
      throw ArgumentError('Invalid individual cancellation');
    }
    masks[key] = mask;
  }
  final root = suffix.candidate.components.single;
  final events = validateIcalendarSchedulingMessage(
    suffix.candidate,
    sharedWorkBudget: work,
  ).events;
  final retained = [events.singleWhere((event) => !event.isOverride)];
  for (final event in events.where((event) => event.isOverride)) {
    final key = eventComponentKey(
      _finiteSuffixPoint(event.originalStart!),
      false,
    );
    if (!masks.containsKey(key)) {
      retained.add(event);
    } else if (event.isThisAndFuture) {
      throw ArgumentError('Individual cancellation conflicts with a range');
    }
  }
  if (sequenceFloor + retained.length > eventMaxSequence) {
    throw const RecurrenceLimitException('schedulingSequence');
  }
  var sequence = sequenceFloor;
  final outgoing = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent(root.name, [
      ...root.entries.where(
        (entry) =>
            entry is! IcalendarSyntaxComponent ||
            entry.canonicalName != 'VEVENT',
      ),
      for (final event in retained)
        IcalendarSyntaxComponent(event.source.name, [
          ...event.source.entries.where(
            (entry) =>
                entry is! IcalendarSyntaxProperty ||
                !{'SEQUENCE', 'DTSTAMP'}.contains(entry.canonicalName),
          ),
          if (!event.isOverride)
            for (final mask in masks.entries)
              if (!suffixKeys.contains(mask.key))
                writer.time('EXDATE', mask.value),
          IcalendarSyntaxProperty('SEQUENCE', '${++sequence}'),
          IcalendarSyntaxProperty('DTSTAMP', writer.utc(stamp)),
        ]),
    ]),
  ]);
  final limits = IcalendarSyntaxLimits(maxBytes: maxBytes);
  final bytes = serializeIcalendarSyntax(outgoing, limits: limits);
  for (var i = 0; i < bytes.length; i += 64) {
    work.charge();
  }
  return (
    parseIcalendarSchedulingMessage(
      bytes,
      syntaxLimits: limits,
      sharedWorkBudget: work,
    ),
    suffix,
  );
}
