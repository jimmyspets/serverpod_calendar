part of 'calendar_module.dart';

CalendarEventTiming? _replyOriginal(IcalendarSchedulingEvent event) =>
    !event.isOverride
    ? null
    : CalendarEventTiming(
        kind: event.originalDate != null
            ? CalendarEventTimeKind.date
            : event.originalTime!.zoneId == null
            ? CalendarEventTimeKind.utc
            : CalendarEventTimeKind.zoned,
        start: event.originalDate != null
            ? eventDate(event.originalDate!)
            : eventCivil(event.originalTime!.civil),
        zoneId: event.originalTime?.zoneId,
      );

String _replyTargetKey(CalendarEventTiming? point) {
  if (point == null) return 'master';
  if (point.end != null || point.duration != null) {
    throw _failure(CalendarFailureCode.validation);
  }
  validateEventTiming(point);
  return _schedulingDigest(
    jsonEncode([
      'calendar-reply-original-v1',
      point.kind.name,
      point.zoneId,
      point.start.year,
      point.start.month,
      point.start.day,
      point.start.hour,
      point.start.minute,
      point.start.second,
    ]),
  );
}

String _replyPointOrder(CalendarEventTiming point) {
  final c = point.start;
  return DateTime.utc(
    c.year,
    c.month,
    c.day,
    c.hour,
    c.minute,
    c.second,
  ).toIso8601String();
}

bool _replySamePoint(CalendarEventTiming? a, CalendarEventTiming? b) =>
    a == null || b == null
    ? a == null && b == null
    : jsonEncode(a.toJson()) == jsonEncode(b.toJson());

final class _ReplyTarget {
  const _ReplyTarget(
    this.originalStart,
    this.basis,
    this.matching,
    this.effective,
    this.sequence,
    this.cancelled,
    this.basisKey,
  );
  final CalendarEventTiming? originalStart;
  final IcalendarSchedulingEvent? basis, matching;
  final CalendarEventContent? effective;
  final int? sequence;
  final bool? cancelled;
  final String? basisKey;
  String get key => _replyTargetKey(originalStart);
  bool current(
    CalendarSchedulingAttendeeResponseRecord? response,
    CalendarSchedulingReplySourceRecord? source,
  ) =>
      response != null &&
      source != null &&
      cancelled == false &&
      response.targetKey == key &&
      source.targetKey == key &&
      _replySamePoint(source.originalStart, originalStart) &&
      source.targetBasisKey == basisKey &&
      response.sequence == sequence;
}

_ReplyTarget _replyTarget(
  _ReplyMaster publication,
  CalendarEventTiming? point, {
  bool allowMissing = false,
}) {
  final key = _replyTargetKey(point);
  final cached = publication.targets[key];
  if (cached != null) {
    if (!_replySamePoint(cached.originalStart, point)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (!allowMissing && cached.sequence == null) {
      throw _failure(CalendarFailureCode.validation);
    }
    return cached;
  }
  if (point == null) {
    return publication.targets[key] = _ReplyTarget(
      null,
      publication.master,
      publication.master,
      null,
      publication.sequence,
      publication.method == 'CANCEL',
      'master',
    );
  }
  if (!publication.checkpoint.instanceVersionProfile) {
    throw _failure(CalendarFailureCode.dependencyConflict);
  }
  final master = publication.published.content.timing;
  if (master.kind != point.kind ||
      master.zoneId != point.zoneId ||
      !publication.recurring) {
    if (!allowMissing) throw _failure(CalendarFailureCode.validation);
    return publication.targets[key] = _ReplyTarget(
      point,
      null,
      null,
      null,
      null,
      null,
      null,
    );
  }
  final cancellation = publication.checkpoint.cancelled
      .where((s) => _replySamePoint(s.point, point))
      .firstOrNull;
  if (publication.method == 'CANCEL' || cancellation != null) {
    if (cancellation == null &&
        !eventSchedulingMember(
          publication.wire.content,
          point,
          sharedWorkBudget: publication.work,
        )) {
      if (!allowMissing) throw _failure(CalendarFailureCode.validation);
      return publication.targets[key] = _ReplyTarget(
        point,
        null,
        null,
        null,
        null,
        null,
        null,
      );
    }
    return publication.targets[key] = _ReplyTarget(
      point,
      publication.master,
      null,
      null,
      cancellation?.version.sequence ?? publication.sequence,
      true,
      _schedulingDigest(jsonEncode(['cancel', key])),
    );
  }
  IcalendarSchedulingEvent basis = publication.master;
  final singles = publication.message.events.where(
    (e) => e.isOverride && !e.isThisAndFuture,
  );
  final single = singles
      .where((e) => _replySamePoint(_replyOriginal(e), point))
      .firstOrNull;
  if (single != null) {
    basis = single;
  } else {
    final ranges =
        publication.message.events.where((e) => e.isThisAndFuture).toList()
          ..sort(
            (a, b) =>
                _replyPointOrder(_replyOriginal(a)!)
                    .compareTo(_replyPointOrder(_replyOriginal(b)!)),
          );
    for (final range in ranges) {
      if (_replyPointOrder(_replyOriginal(range)!)
              .compareTo(_replyPointOrder(point)) >
          0) {
        break;
      }
      basis = range;
    }
  }
  final effective = eventSchedulingOccurrence(
    publication.wire.content,
    publication.wire.edits,
    point,
    sharedWorkBudget: publication.work,
  );
  if (effective == null) {
    if (!allowMissing) throw _failure(CalendarFailureCode.validation);
    return publication.targets[key] = _ReplyTarget(
      point,
      null,
      null,
      null,
      null,
      null,
      null,
    );
  }
  final version = CalendarEventProtocolVersion(
    sequence: basis.sequence,
    stamp: basis.stamp,
    created: basis.created,
    lastModified: basis.lastModified,
  );
  final snapshot = CalendarEventPolicySnapshot(
    publication.published.eventId,
    publication.published.calendarId,
    publication.published.revision,
    effective,
    publication.protocolUid,
    publication.published.updatedAt,
    origin: CalendarEventOrigin.native,
    protocolState: publication.wire.protocolState.copyWith(
      version: version,
      overrides: [],
    ),
  );
  final projected = parseIcalendarSchedulingMessage(
    utf8.encode(_schedulingPayload(snapshot, _schedulingCheckpointBytes)),
  ).events.single;
  final basisKey = basis.isOverride
      ? _schedulingDigest(
          jsonEncode([
            basis.isThisAndFuture ? 'future' : 'single',
            _replyTargetKey(_replyOriginal(basis)),
          ]),
        )
      : 'master';
  return publication.targets[key] = _ReplyTarget(
    point,
    basis,
    projected,
    effective,
    basis.sequence!,
    false,
    basisKey,
  );
}
