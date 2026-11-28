import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'generated/protocol.dart';

const availabilityMaxDefinitions = 64;
const availabilityMaxOpenings = 128;

/// A bound is a start-only UTC or named-zone civil value. The special 2100
/// midnight is permitted only for the exclusive upper bound.
DateTime? availabilityBound(CalendarEventTiming? value, {bool end = false}) {
  if (value == null) return null;
  if (value.kind != CalendarEventTimeKind.utc &&
      value.kind != CalendarEventTimeKind.zoned) {
    throw ArgumentError('Availability requires UTC or named-zone DATE-TIME');
  }
  if (value.end != null || value.duration != null) {
    throw ArgumentError('Validity bounds must be individual values');
  }
  if (!end || value.start.year != 2100) {
    return validateEventTiming(value).$2!.start.instant;
  }
  final span = validateEventTiming(
    CalendarEventTiming(
      kind: value.kind,
      zoneId: value.zoneId,
      start: CalendarEventCivil(year: 1970, month: 1, day: 1),
      end: value.start,
    ),
  ).$2!;
  return span.resolved.endExclusive;
}

/// Effective envelope end without flattening nominal duration units in storage.
DateTime? availabilityEnvelopeEnd(CalendarAvailabilityContent input) {
  final duration = input.validDuration;
  if (duration == null) return availabilityBound(input.validUntil, end: true);
  if (input.validUntil != null || input.validFrom == null) {
    throw ArgumentError(
      'Envelope duration requires a start and excludes an end',
    );
  }
  final start = input.validFrom!;
  availabilityBound(start);
  final span = validateEventTiming(
    CalendarEventTiming(
      kind: start.kind,
      zoneId: start.zoneId,
      start: start.start,
      duration: duration,
    ),
  ).$2!;
  if (span.isPoint) throw ArgumentError('Envelope duration must be positive');
  return span.resolved.endExclusive;
}

CalendarAvailabilityContent validateAvailabilityContent(
  CalendarAvailabilityContent input,
) {
  if (input.summary != null) {
    validateCalendarPlainText(input.summary!, maxCodePoints: 4096);
  }
  RangeError.checkValueInInterval(input.priority, 0, 9, 'priority');
  if (input.closedKind == CalendarFreeBusyKind.free) {
    throw ArgumentError('Closed-time type cannot be free');
  }
  if (input.openings.length > availabilityMaxOpenings) {
    throw const AvailabilityLimitException('maxOpeningsPerDefinition');
  }
  final start = availabilityBound(input.validFrom);
  final end = availabilityEnvelopeEnd(input);
  if (start != null && end != null && !start.isBefore(end)) {
    throw ArgumentError('Validity end must follow start');
  }
  var metadataWork = 0;
  List<String> categories(List<String>? values) {
    if ((values?.length ?? 0) > 64) {
      throw ArgumentError('At most 64 categories');
    }
    final result = <String>[];
    for (final value in values ?? <String>[]) {
      if (value.runes.length > 256) throw ArgumentError('Category too long');
      IcalendarCategory(value);
      metadataWork += value.runes.length;
      if (!result.contains(value)) result.add(value);
    }
    return List.unmodifiable(result);
  }

  List<String> comments(List<String>? values) {
    if ((values?.length ?? 0) > 32) throw ArgumentError('At most 32 comments');
    for (final value in values ?? <String>[]) {
      validateCalendarPlainText(value, maxCodePoints: 4096);
      metadataWork += value.runes.length;
    }
    return List.unmodifiable(values ?? <String>[]);
  }

  void text(String? summary, String? description, String? location) {
    for (final pair in [
      (summary, 4096),
      (description, 16384),
      (location, 4096),
    ]) {
      if (pair.$1 != null) {
        validateCalendarPlainText(pair.$1!, maxCodePoints: pair.$2);
        metadataWork += pair.$1!.runes.length;
      }
    }
  }

  CalendarTextParameters? parameter(CalendarTextParameters? p, String? text) {
    if (p == null) return null;
    if (text == null) throw ArgumentError('Text parameters need ordinary text');
    if (p.language != null) {
      validateCalendarLanguageTag(p.language!);
      metadataWork += p.language!.length;
    }
    if (p.alternativeUri != null) {
      validateAvailabilityMetadataUri(p.alternativeUri!);
      metadataWork += p.alternativeUri!.length;
    }
    return p.language == null && p.alternativeUri == null ? null : p;
  }

  CalendarAvailabilityTextParameters? parameters(
    CalendarAvailabilityTextParameters? p,
    String? summary,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
  ) {
    if (p == null) return null;
    final a = parameter(p.summary, summary),
        b = parameter(p.description, description),
        c = parameter(p.location, location);
    if (p.categoryLanguage != null) {
      if (categories == null || categories.isEmpty) {
        throw ArgumentError('Category language needs categories');
      }
      validateCalendarLanguageTag(p.categoryLanguage!);
      metadataWork += p.categoryLanguage!.length;
    }
    if (p.comments != null && p.comments!.length != (comments?.length ?? 0)) {
      throw ArgumentError('Comment parameter positions must match comments');
    }
    if ((p.comments?.length ?? 0) > 32) {
      throw ArgumentError('Too many comment parameters');
    }
    final notes = p.comments == null
        ? null
        : List<CalendarTextParameters?>.unmodifiable([
            for (var i = 0; i < p.comments!.length; i++)
              parameter(p.comments![i], comments![i]),
          ]);
    if (a == null &&
        b == null &&
        c == null &&
        p.categoryLanguage == null &&
        (notes == null || notes.every((v) => v == null))) {
      return null;
    }
    return CalendarAvailabilityTextParameters(
      summary: a,
      description: b,
      location: c,
      categoryLanguage: p.categoryLanguage,
      comments: notes,
    );
  }

  List<CalendarAvailabilityExtension>? extensions(
    List<CalendarAvailabilityExtension>? values,
  ) {
    if ((values?.length ?? 0) > 32) {
      throw ArgumentError('Too many private extensions');
    }
    final names = <String>{};
    for (final v in values ?? <CalendarAvailabilityExtension>[]) {
      validateAvailabilityExtensionName(v.name);
      if (!names.add(v.name.toUpperCase())) {
        throw ArgumentError('Duplicate private extension');
      }
      validateCalendarPlainText(v.value, maxCodePoints: 4096);
      metadataWork += v.name.length + v.value.runes.length;
    }
    return values == null || values.isEmpty ? null : List.unmodifiable(values);
  }

  text(input.summary, input.description, input.location);
  if (input.url != null) {
    validateCalendarHttpUri(input.url!);
    metadataWork += input.url!.runes.length;
  }
  final envelopeParameters = parameters(
    input.textParameters,
    input.summary,
    input.description,
    input.location,
    input.categories,
    input.comments,
  );
  final envelopeExtensions = extensions(input.extensions);
  final organizer = input.organizer;
  if (organizer != null) {
    validateAvailabilityMetadataUri(organizer.address, maxLength: 1024);
    metadataWork += organizer.address.length;
    if (organizer.commonName != null) {
      validateCalendarPlainText(organizer.commonName!, maxCodePoints: 4096);
      metadataWork += organizer.commonName!.runes.length;
    }
    if (organizer.language != null) {
      if (organizer.commonName == null) {
        throw ArgumentError('Organizer language needs a common name');
      }
      validateCalendarLanguageTag(organizer.language!);
      metadataWork += organizer.language!.length;
    }
    if (organizer.directoryUri != null) {
      validateAvailabilityMetadataUri(organizer.directoryUri!);
      metadataWork += organizer.directoryUri!.length;
    }
  }
  final envelopeCategories = categories(input.categories);
  final envelopeComments = comments(input.comments);
  List<CalendarAvailabilityCategoryGroup>? groups(
    List<CalendarAvailabilityCategoryGroup>? input,
    List<String>? legacy,
    CalendarAvailabilityTextParameters? parameters,
  ) {
    if (input == null || input.isEmpty) return null;
    if ((legacy?.isNotEmpty ?? false) || parameters?.categoryLanguage != null) {
      throw ArgumentError('Choose grouped or native single-group categories');
    }
    var count = 0;
    final result = <CalendarAvailabilityCategoryGroup>[];
    for (final group in input) {
      if (group.values.isEmpty) throw ArgumentError('Empty category group');
      if (group.language != null) {
        validateCalendarLanguageTag(group.language!);
        metadataWork += group.language!.runes.length;
      }
      for (final value in group.values) {
        if (++count > 64) throw ArgumentError('At most 64 category values');
        IcalendarCategory(value, language: group.language);
        metadataWork += value.runes.length;
      }
      result.add(group.copyWith(values: List.unmodifiable(group.values)));
    }
    return List.unmodifiable(result);
  }

  List<CalendarAvailabilityText>? contacts(
    List<CalendarAvailabilityText>? values,
  ) {
    if ((values?.length ?? 0) > 32) throw ArgumentError('At most 32 contacts');
    for (final value in values ?? <CalendarAvailabilityText>[]) {
      validateCalendarPlainText(value.value, maxCodePoints: 4096);
      metadataWork += value.value.runes.length;
      if (value.language != null) {
        validateCalendarLanguageTag(value.language!);
        metadataWork += value.language!.runes.length;
      }
      if (value.alternativeUri != null) {
        validateAvailabilityMetadataUri(value.alternativeUri!);
        metadataWork += value.alternativeUri!.length;
      }
    }
    return values == null || values.isEmpty ? null : List.unmodifiable(values);
  }

  final envelopeGroups = groups(
    input.categoryGroups,
    input.categories,
    input.textParameters,
  );
  final envelopeContacts = contacts(input.contacts);
  final protocolUids = <String>{};
  final uids = <Object>{};
  final openings = <CalendarAvailabilityOpening>[];
  for (final opening in input.openings) {
    if (opening.uid != null && !uids.add(opening.uid!)) {
      throw ArgumentError('Duplicate opening identity');
    }
    if (opening.protocolUid != null) {
      validateAvailabilityUid(opening.protocolUid!);
      if (!protocolUids.add(opening.protocolUid!)) {
        throw ArgumentError('Duplicate opening protocol UID');
      }
    }
    final grouped = groups(
      opening.categoryGroups,
      opening.categories,
      opening.textParameters,
    );
    final contact = contacts(opening.contacts);
    text(opening.summary, opening.description, opening.location);
    final tags = categories(opening.categories);
    final notes = comments(opening.comments);
    final annotation = parameters(
      opening.textParameters,
      opening.summary,
      opening.description,
      opening.location,
      opening.categories,
      opening.comments,
    );
    final extra = extensions(opening.extensions);
    final t = opening.timing;
    if (t.kind != CalendarEventTimeKind.utc &&
        t.kind != CalendarEventTimeKind.zoned) {
      throw ArgumentError('Openings require UTC or named-zone DATE-TIME');
    }
    final span = validateEventTiming(t).$2!;
    if (span.isPoint) {
      throw ArgumentError('An opening must have positive duration');
    }
    openings.add(
      opening.copyWith(
        textParameters: annotation,
        extensions: extra,
        categories: tags,
        comments: notes,
        categoryGroups: grouped,
        contacts: contact,
        periods: validateAvailabilityPeriods(
          t,
          opening.recurrence,
          opening.periods,
        ),
        recurrence: validateEventRecurrence(t, opening.recurrence),
      ),
    );
  }
  if (metadataWork > 65536) {
    throw ArgumentError('Metadata exceeds 65536 code points');
  }
  return input.copyWith(
    openings: List.unmodifiable(openings),
    textParameters: envelopeParameters,
    extensions: envelopeExtensions,
    categories: envelopeCategories,
    comments: envelopeComments,
    categoryGroups: envelopeGroups,
    contacts: envelopeContacts,
  );
}

/// Bounded native adapter. Event transport types are shared timing structures;
/// status, transparency, attendees and event authorization never enter rules.
AvailabilityDefinition evaluateAvailability(
  CalendarAvailabilityContent input,
  UtcWindow window, {
  List<CalendarAvailabilityOpeningEdits>? edits,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final start = availabilityBound(input.validFrom);
  final end = availabilityEnvelopeEnd(input);
  final from = start != null && start.isAfter(window.start)
      ? start
      : window.start;
  final until = end != null && end.isBefore(window.end) ? end : window.end;
  final openings = <UtcWindow>[];
  if (from.isBefore(until)) {
    final clipped = UtcWindow(start: from, end: until);
    for (final opening in input.openings) {
      openings.addAll(
        eventOccupiedWindows(
          CalendarEventContent(
            timing: opening.timing,
            recurrence: opening.recurrence,
          ),
          openingEdits(edits, opening.uid),
          clipped,
          dateZone: 'UTC',
          periods: opening.periods,
          sharedWorkBudget: work,
        ),
      );
      if (openings.length > 5000) {
        throw const AvailabilityLimitException('maxProjectedOpenings');
      }
    }
  }
  return AvailabilityDefinition(
    start: start,
    end: end,
    priority: input.priority,
    closedKind: AvailabilityKind.values.byName(input.closedKind.name),
    openings: openings,
  );
}

CalendarEventContent openingEvent(CalendarAvailabilityOpening opening) =>
    CalendarEventContent(
      timing: opening.timing,
      recurrence: opening.recurrence,
    );

CalendarEventTimingOverrides? openingEdits(
  List<CalendarAvailabilityOpeningEdits>? edits,
  Object? uid,
) {
  for (final entry in edits ?? <CalendarAvailabilityOpeningEdits>[]) {
    if (entry.openingUid == uid) return entry.overrides;
  }
  return null;
}

List<CalendarAvailabilityOpeningEdits>? validateAvailabilityEdits(
  CalendarAvailabilityContent content,
  List<CalendarAvailabilityOpeningEdits>? edits,
) {
  if (edits == null || edits.isEmpty) return null;
  if (edits.length > availabilityMaxOpenings) {
    throw const AvailabilityLimitException('editedOpenings');
  }
  final seen = <Object>{};
  var total = 0;
  final result = <CalendarAvailabilityOpeningEdits>[];
  for (final entry in edits) {
    if (!seen.add(entry.openingUid)) {
      throw ArgumentError('Duplicate edited opening');
    }
    final matches = content.openings
        .where((o) => o.uid == entry.openingUid)
        .toList();
    if (matches.length != 1) throw ArgumentError('Unknown opening');
    total += entry.overrides.singles.length + entry.overrides.future.length;
    if (total > 128) {
      throw const AvailabilityLimitException('aggregateOpeningOverrides');
    }
    for (final replacement in [
      for (final item in entry.overrides.singles)
        if (item.replacement != null) item.replacement!,
      for (final item in entry.overrides.future) item.replacement,
    ]) {
      if (validateEventTiming(replacement).$2?.isPoint != false) {
        throw ArgumentError('Opening replacements must have positive duration');
      }
    }
    if (entry.overrides.singles.any((v) => v.contentOverrides != null) ||
        entry.overrides.future.any((v) => v.contentOverrides != null)) {
      throw ArgumentError('Availability content exceptions are not supported');
    }
    final validated = validateEventOverrides(
      openingEvent(matches.single),
      entry.overrides,
      periods: matches.single.periods,
    );
    if (validated != null) result.add(entry.copyWith(overrides: validated));
  }
  result.sort(
    (a, b) => a.openingUid.toString().compareTo(b.openingUid.toString()),
  );
  return result.isEmpty ? null : List.unmodifiable(result);
}

List<CalendarAvailabilityOpeningEdits>? changeAvailabilityEdits(
  CalendarAvailabilityContent content,
  List<CalendarAvailabilityOpeningEdits>? current,
  CalendarAvailabilityOccurrenceChange request,
) {
  final opening = content.openings.singleWhere(
    (o) => o.uid == request.openingUid,
    orElse: () => throw ArgumentError('Unknown opening'),
  );
  final changed = changeEventOverrides(
    openingEvent(opening),
    openingEdits(current, request.openingUid),
    CalendarEventOccurrenceChange(
      eventId: request.availabilityId,
      expectedRevision: request.expectedRevision,
      originalStart: request.originalStart,
      action: request.action,
      replacement: request.replacement,
    ),
    periods: opening.periods,
  );
  return validateAvailabilityEdits(content, [
    for (final entry in current ?? <CalendarAvailabilityOpeningEdits>[])
      if (entry.openingUid != request.openingUid) entry,
    if (changed != null)
      CalendarAvailabilityOpeningEdits(
        openingUid: request.openingUid,
        overrides: changed,
      ),
  ]);
}

/// Metadata signatures distinguish the additional gate for mixed updates.
Object availabilityMetadata(CalendarAvailabilityContent value) => [
  value.summary,
  value.description,
  value.location,
  value.categories,
  value.categoryGroups?.map((v) => v.toJson()).toList(),
  value.contacts?.map((v) => v.toJson()).toList(),
  value.comments,
  value.url,
  value.classification?.name,
  value.organizer?.toJson(),
  value.textParameters?.toJson(),
  value.extensions?.map((v) => v.toJson()).toList(),
  for (final o in value.openings)
    [
      o.uid?.toString(),
      o.summary,
      o.description,
      o.location,
      o.categories,
      o.categoryGroups?.map((v) => v.toJson()).toList(),
      o.contacts?.map((v) => v.toJson()).toList(),
      o.comments,
      o.textParameters?.toJson(),
      o.extensions?.map((v) => v.toJson()).toList(),
    ],
];
Object availabilityStructure(CalendarAvailabilityContent value) => [
  value.validFrom?.toJson(),
  value.validUntil?.toJson(),
  value.validDuration?.toJson(),
  value.priority,
  value.closedKind.name,
  for (final o in value.openings)
    [
      o.uid?.toString(),
      o.protocolUid,
      o.timing.toJson(),
      o.recurrence?.toJson(),
      o.periods?.map((v) => v.toJson()).toList(),
    ],
];

/// Decoded absolute URI metadata only; no retrieval or scheme-based authority.
void validateAvailabilityMetadataUri(String value, {int maxLength = 4096}) {
  if (value.isEmpty ||
      value.length > maxLength ||
      RegExp(r'[\x00-\x20\x7f-\uffff"<>\\^`{|}]').hasMatch(value) ||
      RegExp(r'%(?![0-9a-fA-F]{2})').hasMatch(value)) {
    throw ArgumentError('Invalid absolute metadata URI');
  }
  final uri = Uri.parse(value);
  if (!uri.hasScheme ||
      value.length <= uri.scheme.length + 1 ||
      uri.userInfo.isNotEmpty) {
    throw ArgumentError('Invalid absolute metadata URI');
  }
}

void validateAvailabilityExtensionName(String name) {
  if (name.length > 64 ||
      RegExp(r'[^A-Za-z0-9-]').hasMatch(name) ||
      !RegExp(
        r'^X-[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$',
        caseSensitive: false,
      ).hasMatch(name)) {
    throw ArgumentError('Private extension name required');
  }
}

void validateAvailabilityUid(String value) {
  if (value.isEmpty) throw ArgumentError('Protocol UID required');
  validateCalendarPlainText(value, maxCodePoints: 4096);
}
