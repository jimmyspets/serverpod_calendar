part of 'icalendar_event_calendar.dart';

final class IcalendarTaskSeries {
  IcalendarTaskSeries._(
    this.master,
    Iterable<IcalendarTaskOccurrenceComponent> overrides,
  ) : overrides = List.unmodifiable(overrides);
  final IcalendarTask master;
  final List<IcalendarTaskOccurrenceComponent> overrides;
}

/// Raw optional source progress/checkpoints stay on [component]. Timing and
/// content projections inherit omitted values without changing source presence.
final class IcalendarTaskOccurrenceComponent {
  IcalendarTaskOccurrenceComponent._(
    this.master,
    this.component,
    this.dateTiming,
    this.timedProjection,
  );
  final IcalendarTask master, component;
  final DateTaskTiming? dateTiming;
  final TimedTaskProjection? timedProjection;
  Object get originalStart => component.originalStart!;
  IcalendarTaskText? get summary => component.summary ?? master.summary;
  IcalendarTaskText? get description =>
      component.description ?? master.description;
  IcalendarTaskText? get location => component.location ?? master.location;
  int? get priority => component.priority ?? master.priority;
  IcalendarTaskParticipants get participants =>
      _inheritedTaskParticipants(master.participants, component.participants);
  IcalendarTaskMetadata get metadata =>
      _inheritedTaskMetadata(master.metadata, component.metadata);
}

IcalendarTaskSeries _taskSeries(
  IcalendarTask master,
  List<IcalendarTask> overrides,
  ComponentBudget budget,
) {
  if (overrides.isEmpty) return IcalendarTaskSeries._(master, []);
  if (master.recurrence == null) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final originals = overrides.map((o) => o.originalStart!).toList();
  if (originals.toSet().length != originals.length) {
    componentFail(IcalendarComponentError.duplicate);
  }
  final limits = budget.limits;
  bool sameText(IcalendarTaskText? a, IcalendarTaskText? b) =>
      a == null ||
      (b != null &&
          a.value == b.value &&
          a.language == b.language &&
          a.alternativeUri == b.alternativeUri);
  bool supplied(IcalendarTask t, String name) => t.source.entries
      .whereType<IcalendarSyntaxProperty>()
      .any((p) => p.canonicalName == name);
  for (final o in overrides) {
    _matchingTaskMetadata(master.metadata, o.metadata);
    _matchingTaskParticipants(master.participants, o.participants);
    if (!sameText(o.summary, master.summary) ||
        !sameText(o.description, master.description) ||
        !sameText(o.location, master.location) ||
        (o.priority != null && o.priority != (master.priority ?? 0))) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
  }
  final linked = <IcalendarTaskOccurrenceComponent>[];
  if (master.dateTiming != null) {
    if (overrides.any(
      (o) => o.recurrenceDate == null || o.timedTiming != null,
    )) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final dates = overrides.map((o) => o.recurrenceDate!).toList()..sort();
    final found = master.recurrence!.dateSet!
        .expand(
          from: dates.first,
          through: dates.last,
          maxCandidateDays: limits.maxCandidates,
          maxRuleOccurrences: limits.maxValidationOccurrences,
          maxResults: limits.maxValidationOccurrences,
          sharedWorkBudget: budget.sharedWork,
        )
        .toSet();
    if (!found.containsAll(dates)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    for (final o in overrides) {
      final projected = master.dateTiming!.at(o.recurrenceDate!);
      if ((supplied(o, 'DTSTART') && o.dateTiming?.start != projected.start) ||
          ((supplied(o, 'DUE') || supplied(o, 'DURATION')) &&
              o.dateTiming?.effectiveDue != projected.effectiveDue)) {
        componentFail(IcalendarComponentError.unsupportedProperty);
      }
      linked.add(
        IcalendarTaskOccurrenceComponent._(master, o, projected, null),
      );
    }
  } else {
    final start = master.timedTiming!.start!;
    if (overrides.any(
      (o) =>
          o.recurrenceTime == null ||
          o.dateTiming != null ||
          !start.sameProfile(o.recurrenceTime!),
    )) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final times = overrides.map((o) => o.recurrenceTime!).toList()
      ..sort((a, b) => a.instant.compareTo(b.instant));
    final found = master.recurrence!.timedSet!
        .expand(
          window: UtcWindow(
            start: times.first.instant,
            end: times.last.instant.add(const Duration(seconds: 1)),
          ),
          maxCandidateWork: limits.maxCandidates,
          maxRuleOccurrences: limits.maxValidationOccurrences,
          maxResults: limits.maxValidationOccurrences,
          sharedWorkBudget: budget.sharedWork,
        )
        .toSet();
    if (!found.containsAll(times)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    for (final o in overrides) {
      final projected = master.timedTiming!.at(o.recurrenceTime!);
      final explicit = o.timedTiming;
      if ((explicit?.start != null && !start.sameProfile(explicit!.start!)) ||
          (explicit?.due != null && !start.sameProfile(explicit!.due!))) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      if ((supplied(o, 'DTSTART') && explicit?.start != projected.start) ||
          ((supplied(o, 'DUE') || supplied(o, 'DURATION')) &&
              explicit?.effectiveDue != projected.dueInstant)) {
        componentFail(IcalendarComponentError.unsupportedProperty);
      }
      linked.add(
        IcalendarTaskOccurrenceComponent._(master, o, null, projected),
      );
    }
  }
  return IcalendarTaskSeries._(master, linked);
}
