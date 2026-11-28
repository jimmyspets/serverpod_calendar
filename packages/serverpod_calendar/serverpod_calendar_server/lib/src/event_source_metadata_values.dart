part of 'event_values.dart';

const eventMaxMetadataCodePoints = 65536;

final class EventMetadataBudget {
  int used = 0;
  void charge(String? value) {
    used += value?.runes.length ?? 0;
    if (used > eventMaxMetadataCodePoints) {
      throw const RecurrenceLimitException('eventMetadataCodePoints');
    }
  }
}

CalendarEventSourceMetadata? eventComponentMetadata(Object value) =>
    value is CalendarEventSingleOverride
    ? value.sourceMetadata
    : (value as CalendarEventFutureOverride).sourceMetadata;
CalendarEventSourceMetadata? validateEventSourceMetadata(
  CalendarEventSourceMetadata? value, {
  EventMetadataBudget? budget,
}) {
  if (value == null) return null;
  budget ??= EventMetadataBudget();
  if (value.url != null) {
    validateCalendarHttpUri(value.url!);
    budget.charge(value.url);
  }
  if (value.classification != null) {
    if (!{'PUBLIC', 'PRIVATE', 'CONFIDENTIAL'}.contains(value.classification)) {
      throw ArgumentError('Unprofiled event classification');
    }
    budget.charge(value.classification);
  }
  if (value.categoryGroups.length > 64 ||
      value.comments.length > 32 ||
      value.contacts.length > 32) {
    throw const RecurrenceLimitException('eventMetadataItems');
  }
  var count = 0;
  final groups = <CalendarEventSourceCategoryGroup>[];
  for (final g in value.categoryGroups) {
    if (g.values.isEmpty) throw ArgumentError('Empty category group');
    if (g.language != null) validateCalendarLanguageTag(g.language!);
    budget.charge(g.language);
    for (final v in g.values) {
      if (++count > 64) throw const RecurrenceLimitException('eventCategories');
      IcalendarCategory(v, language: g.language);
      budget.charge(v);
    }
    groups.add(g.copyWith(values: List.unmodifiable(g.values)));
  }
  List<CalendarEventSourceText> texts(List<CalendarEventSourceText> values) =>
      List.unmodifiable(
        values.map((v) {
          validateCalendarPlainText(v.value, maxCodePoints: 4096);
          final p = _eventTextParameter(v.parameters, v.value);
          budget!.charge(v.value);
          budget.charge(p?.language);
          budget.charge(p?.alternativeUri);
          return v.copyWith(parameters: p);
        }),
      );
  CalendarEventSourceParticipant participant(
    CalendarEventSourceParticipant v,
    bool organizer,
  ) {
    final decoded = decodeIcalendarEventParticipant(
      IcalendarSyntaxProperty(
        organizer ? 'ORGANIZER' : 'ATTENDEE',
        v.address,
        parameters: [
          for (final p in v.parameters.entries)
            IcalendarSyntaxParameter(p.key, p.value),
        ],
      ),
    );
    budget!.charge(decoded.address);
    for (final values in decoded.parameters.values) {
      for (final v in values) {
        budget.charge(v);
      }
    }
    return v.copyWith(parameters: decoded.parameters);
  }

  if ((value.attendees?.length ?? 0) > 64) {
    throw const RecurrenceLimitException('eventAttendees');
  }
  if ((value.relationships?.length ?? 0) > 64 ||
      (value.attachments?.length ?? 0) > 64) {
    throw const RecurrenceLimitException('eventSourceReferences');
  }
  final references = decodeIcalendarEventReferences([
    for (final r in value.relationships ?? <CalendarEventSourceRelationship>[])
      IcalendarSyntaxProperty(
        'RELATED-TO',
        encodeIcalendarText(r.targetUid),
        parameters: [
          if (r.relationType != null)
            IcalendarSyntaxParameter('RELTYPE', [r.relationType!]),
        ],
      ),
    for (final a in value.attachments ?? <CalendarEventSourceAttachment>[])
      IcalendarSyntaxProperty(
        'ATTACH',
        a.uri,
        parameters: [
          if (a.explicitUri) IcalendarSyntaxParameter('VALUE', ['URI']),
          if (a.mediaType != null)
            IcalendarSyntaxParameter('FMTTYPE', [a.mediaType!]),
        ],
      ),
  ]);
  for (final r in references.relationships) {
    budget.charge(r.targetUid);
    budget.charge(r.relationType);
  }
  for (final a in references.attachments) {
    budget.charge(a.uri);
    budget.charge(a.mediaType);
  }
  final result = value.copyWith(
    relationships: references.relationships.isEmpty
        ? null
        : List.unmodifiable(
            references.relationships.map(
              (r) => CalendarEventSourceRelationship(
                targetUid: r.targetUid,
                relationType: r.relationType,
              ),
            ),
          ),
    attachments: references.attachments.isEmpty
        ? null
        : List.unmodifiable(
            references.attachments.map(
              (a) => CalendarEventSourceAttachment(
                uri: a.uri,
                mediaType: a.mediaType,
                explicitUri: a.source.parameters.any(
                  (p) => p.canonicalName == 'VALUE',
                ),
              ),
            ),
          ),
    organizer: value.organizer == null
        ? null
        : participant(value.organizer!, true),
    attendees: value.attendees == null || value.attendees!.isEmpty
        ? null
        : List.unmodifiable(value.attendees!.map((v) => participant(v, false))),
    categoryGroups: List.unmodifiable(groups),
    comments: texts(value.comments),
    contacts: texts(value.contacts),
  );
  return result.url == null &&
          result.classification == null &&
          result.categoryGroups.isEmpty &&
          result.comments.isEmpty &&
          result.contacts.isEmpty &&
          result.organizer == null &&
          result.attendees == null &&
          result.relationships == null &&
          result.attachments == null
      ? null
      : result;
}

void validateEventMetadataInheritance(
  CalendarEventSourceMetadata? master,
  CalendarEventSourceMetadata? own,
) {
  if (own == null) return;
  bool same<T>(List<T> a, List<T>? b) =>
      a.isEmpty ||
      (b != null &&
          a.length == b.length &&
          List.generate(a.length, (i) => a[i] == b[i]).every((v) => v));
  bool participantMatches(
    CalendarEventSourceParticipant a,
    CalendarEventSourceParticipant? b,
  ) {
    if (b == null ||
        a.address != b.address ||
        a.parameters.length != b.parameters.length) {
      return false;
    }
    for (final e in a.parameters.entries) {
      final other = b.parameters[e.key];
      if (other == null || other.length != e.value.length) return false;
      for (var i = 0; i < other.length; i++) {
        String token(String v) =>
            {'CUTYPE', 'ROLE', 'PARTSTAT', 'RSVP'}.contains(e.key)
            ? v.toUpperCase()
            : v;
        if (token(e.value[i]) != token(other[i])) return false;
      }
    }
    return true;
  }

  bool sameReferences<T>(
    List<T>? own,
    List<T>? master,
    bool Function(T, T) matches,
  ) =>
      own == null ||
      own.isEmpty ||
      (master != null &&
          own.length == master.length &&
          List.generate(
            own.length,
            (i) => matches(own[i], master[i]),
          ).every((v) => v));
  final attendees = own.attendees ?? <CalendarEventSourceParticipant>[];
  final masterAttendees =
      master?.attendees ?? <CalendarEventSourceParticipant>[];
  if (!sameReferences<CalendarEventSourceRelationship>(
        own.relationships,
        master?.relationships,
        (a, b) =>
            a.targetUid == b.targetUid &&
            (a.relationType ?? 'PARENT') == (b.relationType ?? 'PARENT'),
      ) ||
      !sameReferences<CalendarEventSourceAttachment>(
        own.attachments,
        master?.attachments,
        (a, b) =>
            a.uri == b.uri &&
            a.mediaType?.toLowerCase() == b.mediaType?.toLowerCase(),
      ) ||
      own.organizer != null &&
          !participantMatches(own.organizer!, master?.organizer) ||
      attendees.isNotEmpty &&
          (attendees.length != masterAttendees.length ||
              List.generate(
                attendees.length,
                (i) => !participantMatches(attendees[i], masterAttendees[i]),
              ).any((v) => v)) ||
      own.url != null && own.url != master?.url ||
      own.classification != null &&
          own.classification != (master?.classification ?? 'PUBLIC') ||
      !same(own.categoryGroups, master?.categoryGroups) ||
      !same(own.comments, master?.comments) ||
      !same(own.contacts, master?.contacts)) {
    throw ArgumentError(
      'Differing occurrence source metadata is not supported',
    );
  }
}
