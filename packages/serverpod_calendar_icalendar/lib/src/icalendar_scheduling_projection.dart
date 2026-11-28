part of 'icalendar_event_calendar.dart';

/// Project required REQUEST fields from one validated standalone source series.
///
/// Missing SUMMARY inherits the master's property (including parameters), or is
/// empty when the master has no summary. Missing organizer/attendee properties
/// copy the master claims. Explicit component properties remain unchanged.
///
/// Source omissions, timing, identities and protocol versions are not modified.
/// The result is untrusted candidate data, not an authorized dispatch decision.
/// Callers must independently approve addresses/disclosure, allocate versions,
/// reconcile instance lifecycle/reset state and persist delivery atomically.
IcalendarSchedulingMessage projectIcalendarRequestFields(
  IcalendarEventCalendar value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  return _projectIcalendarSchedulingFields(
    value,
    IcalendarSchedulingMethod.request,
    syntaxLimits: syntaxLimits,
    limits: limits,
    sharedWorkBudget: sharedWorkBudget,
  );
}

/// Project required PUBLISH summary/organizer fields without copying attendees.
/// Source/native inheritance and versions remain unchanged. No authority or
/// delivery is established; unsupported participants/alarms reject explicitly.
IcalendarSchedulingMessage projectIcalendarPublishFields(
  IcalendarEventCalendar value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
  RecurrenceWorkBudget? sharedWorkBudget,
}) => _projectIcalendarSchedulingFields(
  value,
  IcalendarSchedulingMethod.publish,
  syntaxLimits: syntaxLimits,
  limits: limits,
  sharedWorkBudget: sharedWorkBudget,
);

IcalendarSchedulingMessage _projectIcalendarSchedulingFields(
  IcalendarEventCalendar value,
  IcalendarSchedulingMethod method, {
  required IcalendarSyntaxLimits syntaxLimits,
  required IcalendarComponentLimits limits,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final request = method == IcalendarSchedulingMethod.request;
  limits.validate();
  // The typed input is immutable and already semantically validated. Bound its
  // syntax again for these limits; final validation charges all projected data.
  final inputBytes = serializeIcalendarSyntax(
    value.source,
    limits: syntaxLimits,
  );
  if (value.series.length != 1) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final series = value.series.single;
  if (series.overrides.length > limits.maxOverridesPerEvent ||
      series.overrides.length + 1 > limits.maxEvents) {
    componentFail(IcalendarComponentError.limitExceeded);
  }
  List<IcalendarSyntaxProperty> properties(String name) => series
      .master
      .source
      .entries
      .whereType<IcalendarSyntaxProperty>()
      .where((p) => p.canonicalName == name)
      .toList();
  final organizers = properties('ORGANIZER'),
      attendees = properties('ATTENDEE');
  if (organizers.isEmpty || request && attendees.isEmpty) {
    componentFail(IcalendarComponentError.missing);
  }
  if (!request && attendees.isNotEmpty) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
  final summaries = properties('SUMMARY');
  final summary = summaries.isEmpty
      ? IcalendarSyntaxProperty('SUMMARY', '')
      : summaries.single;

  // Charge a lower bound before allocating each copied property list. Actual
  // quoting, parameters, folding, metadata and work are bounded by validation.
  // This prevents a small master roster from growing quadratically unchecked.
  int minimumBytes(Iterable<IcalendarSyntaxProperty> props) => props.fold(
    0,
    (total, p) => total + p.name.length + 3 + utf8.encode(p.value).length,
  );
  var byteFloor = inputBytes.length,
      lineFloor = inputBytes.where((b) => b == 10).length;
  final summaryBytes = minimumBytes([summary]),
      organizerBytes = minimumBytes(organizers),
      attendeeBytes = minimumBytes(attendees);
  void charge(int bytes, int lines) {
    byteFloor += bytes;
    lineFloor += lines;
    if (byteFloor > syntaxLimits.maxBytes) {
      throw const IcalendarSyntaxException(
        IcalendarSyntaxError.limitExceeded,
        limit: 'maxBytes',
      );
    }
    if (lineFloor > syntaxLimits.maxLines) {
      throw const IcalendarSyntaxException(
        IcalendarSyntaxError.limitExceeded,
        limit: 'maxLines',
      );
    }
  }

  charge(
    minimumBytes([
      IcalendarSyntaxProperty('METHOD', method.name.toUpperCase()),
    ]),
    1,
  );
  IcalendarSyntaxComponent project(IcalendarSyntaxComponent component) {
    final names = component.entries
        .whereType<IcalendarSyntaxProperty>()
        .map((p) => p.canonicalName)
        .toSet();
    if (!names.contains('SUMMARY')) charge(summaryBytes, 1);
    if (!names.contains('ORGANIZER')) charge(organizerBytes, organizers.length);
    if (request && !names.contains('ATTENDEE')) {
      charge(attendeeBytes, attendees.length);
    }
    return IcalendarSyntaxComponent(component.name, [
      ...component.entries,
      if (!names.contains('SUMMARY')) summary,
      if (!names.contains('ORGANIZER')) ...organizers,
      if (request && !names.contains('ATTENDEE')) ...attendees,
    ]);
  }

  final source = value.source.components.single;
  return validateIcalendarSchedulingMessage(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(source.name, [
        ...source.entries.whereType<IcalendarSyntaxProperty>(),
        IcalendarSyntaxProperty('METHOD', method.name.toUpperCase()),
        for (final child
            in source.entries.whereType<IcalendarSyntaxComponent>())
          if (child.canonicalName == 'VEVENT') project(child) else child,
      ]),
    ]),
    syntaxLimits: syntaxLimits,
    limits: limits,
    sharedWorkBudget: sharedWorkBudget,
  );
}
