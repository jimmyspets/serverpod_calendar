part of 'icalendar_event_calendar.dart';

/// One complete in-file master and supported timing/cancellation components.
/// Omitted text inherits [master]; explicit override text remains local, including
/// at timing-range anchors. [overrides] retains source omission/versions.
/// Core projections provide timing only, not status/transparency or authority.
final class IcalendarEventSeries {
  IcalendarEventSeries._(
    this.master,
    List<IcalendarEvent> overrides,
    this.dateSeries,
    this.timedSeries,
  ) : overrides = List.unmodifiable(overrides);

  /// Resolve source omissions without changing raw component presence.
  IcalendarEventParticipants participantsFor(IcalendarEvent component) {
    if (identical(component, master)) return master.participants;
    if (!overrides.contains(component)) {
      throw ArgumentError('Foreign component');
    }
    return _inheritedEventParticipants(
      master.participants,
      component.participants,
    );
  }

  /// Effective bounded metadata; the component retains its original omissions.
  IcalendarEventMetadata metadataFor(IcalendarEvent component) {
    if (identical(component, master)) return master.metadata;
    if (!overrides.contains(component)) {
      throw ArgumentError('Foreign event component');
    }
    return _inheritedEventMetadata(master.metadata, component.metadata);
  }

  final IcalendarEvent master;
  final List<IcalendarEvent> overrides;
  final DateEventRangeSet? dateSeries;
  final TimedEventSeries? timedSeries;
}

IcalendarEventSeries _eventSeries(
  IcalendarEvent master,
  List<IcalendarEvent> overrides,
  ComponentBudget budget, {
  int? maxOverrides,
}) {
  final limits = budget.limits;
  final overrideLimit = maxOverrides ?? limits.maxOverridesPerEvent;
  if (overrides.isNotEmpty && master.recurrence == null) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  for (final o in overrides) {
    _matchingEventMetadata(master.metadata, o.metadata);
    _matchingEventParticipants(master.participants, o.participants);
    if ((o.transparency != null && o.isTransparent != master.isTransparent) ||
        (o.status != null &&
            o.status != master.status &&
            o.status != IcalendarEventStatus.cancelled)) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    if (o.isThisAndFuture && o.status == IcalendarEventStatus.cancelled) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    if (master.dateSpan != null) {
      if (o.recurrenceDate == null || o.dateSpan == null) {
        componentFail(IcalendarComponentError.invalidValue);
      }
    } else if (o.recurrenceTime == null ||
        o.timedSpan == null ||
        !master.timedSpan!.start.sameProfile(o.recurrenceTime!) ||
        !master.timedSpan!.start.sameProfile(o.timedSpan!.start)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
  }
  if (master.dateSpan != null) {
    final recurrence =
        master.recurrence?.dateSet ??
        DateRecurrenceSet(start: master.dateSpan!.start, maxExplicitDates: 0);
    final singles = DateEventExceptionSet(
      series: DateEventSeries(recurrence: recurrence, span: master.dateSpan!),
      exceptions: [
        for (final o in overrides.where((o) => !o.isThisAndFuture))
          o.status == IcalendarEventStatus.cancelled
              ? DateEventException.cancel(originalStart: o.recurrenceDate!)
              : DateEventException.replace(
                  originalStart: o.recurrenceDate!,
                  replacement: o.dateSpan!,
                ),
      ],
      maxExceptions: overrideLimit,
      maxValidationCandidateDays: limits.maxCandidates,
      maxValidationRuleOccurrences: limits.maxValidationOccurrences,
      maxValidationResults: limits.maxValidationOccurrences,
      sharedWorkBudget: budget.sharedWork,
    );
    final ranges = DateEventRangeSet(
      base: singles,
      changes: [
        for (final o in overrides.where((o) => o.isThisAndFuture))
          DateEventRangeChange(
            originalStart: o.recurrenceDate!,
            replacement: o.dateSpan!,
          ),
      ],
      maxRangeChanges: overrideLimit,
      maxValidationCandidateDays: limits.maxCandidates,
      maxValidationRuleOccurrences: limits.maxValidationOccurrences,
      maxValidationResults: limits.maxValidationOccurrences,
      sharedWorkBudget: budget.sharedWork,
    );
    return IcalendarEventSeries._(master, overrides, ranges, null);
  }
  final recurrence =
      master.recurrence?.timedSet ??
      TimedRecurrenceSet(start: master.timedSpan!.start, maxExplicitDates: 0);
  final timed = TimedEventSeries(
    recurrence: recurrence,
    span: master.timedSpan!,
    exceptions: [
      for (final o in overrides.where((o) => !o.isThisAndFuture))
        o.status == IcalendarEventStatus.cancelled
            ? TimedEventException.cancel(o.recurrenceTime!)
            : TimedEventException.replace(o.recurrenceTime!, o.timedSpan!),
    ],
    changes: [
      for (final o in overrides.where((o) => o.isThisAndFuture))
        TimedEventRangeChange(
          originalStart: o.recurrenceTime!,
          replacement: o.timedSpan!,
        ),
    ],
    maxChanges: overrideLimit,
    maxValidationCandidateWork: limits.maxCandidates,
    maxValidationOccurrences: limits.maxValidationOccurrences,
    sharedWorkBudget: budget.sharedWork,
  );
  return IcalendarEventSeries._(master, overrides, null, timed);
}
