import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'generated/protocol.dart';

/// The guarantee supplied by a host adapter, not inferred from its storage.
enum CalendarAuthorizationGuarantee { freshCheck, coordinated }

enum CalendarAuthorizationPhase { read, preliminaryWrite, finalWrite }

enum CalendarPermission {
  listAvailability,
  readAvailability,
  createAvailability,
  updateAvailability,
  deleteAvailability,
  projectAvailability,
  readFreeBusy,
  projectEventBusy,
  previewEventOccurrences,
  listEvents,
  readEvent,
  createEvent,
  updateEvent,
  changeEventStatus,
  deleteEvent,
  list,
  read,
  create,
  updateMetadata,
  updateProtocolMetadata,
  updateSupplementalMetadata,
  updateAvailabilitySettings,
  delete,
  readAssociations,
  changeAssociations,
}

enum CalendarAuthorizationVerdict { allow, deny, unavailable }

/// Trusted host result. Never accepted as a client-supplied request.
final class CalendarHostContext {
  const CalendarHostContext({
    required this.principalId,
    required this.scopeKey,
    required this.policyRevision,
  });
  final String principalId, scopeKey;

  /// Authoritative continuation epoch. Change when effective query rights change.
  final String policyRevision;
}

final class CalendarSubjectReference {
  const CalendarSubjectReference(this.namespace, this.kind, this.externalId);
  final String namespace, kind, externalId;
}

final class CalendarSubjectIntent {
  const CalendarSubjectIntent(
    this.action,
    this.subject,
    this.contributesAvailability,
  );
  final CalendarSubjectAction action;
  final CalendarSubjectReference subject;
  final bool contributesAvailability;
}

/// Immutable policy metadata; a host cannot mutate the ORM object through it.
final class CalendarPolicySubject {
  const CalendarPolicySubject(this.subject, this.contributesAvailability);
  final CalendarSubjectReference subject;
  final bool contributesAvailability;
}

final class CalendarPolicySnapshot {
  CalendarPolicySnapshot({
    required this.calendarId,
    required this.revision,
    required this.displayName,
    required this.description,
    required this.color,
    required this.protocolIdentity,
    required this.protocolMetadata,
    required this.supplementalMetadata,
    required this.availabilityZoneId,
    required this.noRuleFallback,
    required Iterable<CalendarPolicySubject> subjects,
  }) : subjects = List.unmodifiable(subjects);
  final UuidValue calendarId;
  final int revision;
  final String displayName, availabilityZoneId;
  final String? description, color;
  final CalendarProtocolIdentity protocolIdentity;
  final IcalendarCalendarTextMetadata protocolMetadata;
  final IcalendarSupplementalMetadata supplementalMetadata;
  final CalendarNoRuleFallback noRuleFallback;
  final List<CalendarPolicySubject> subjects;
}

/// Full replacement distinguishes clearing nulls from a name-only edit.
final class CalendarPresentationIntent {
  const CalendarPresentationIntent(
    this.displayName,
    this.description,
    this.color,
  );
  final String displayName;
  final String? description, color;
}

final class CalendarProposedChange {
  const CalendarProposedChange({
    this.displayName,
    this.availabilityZoneId,
    this.noRuleFallback,
    this.subject,
    this.presentation,
    this.protocolMetadata,
    this.supplementalMetadata,
  });
  final String? displayName, availabilityZoneId;
  final CalendarNoRuleFallback? noRuleFallback;
  final CalendarSubjectIntent? subject;
  final CalendarPresentationIntent? presentation;
  final IcalendarCalendarTextMetadata? protocolMetadata;
  final IcalendarSupplementalMetadata? supplementalMetadata;
}

final class CalendarAuthorizationRequest {
  CalendarAuthorizationRequest({
    required this.key,
    required this.operation,
    this.current,
    this.proposed,
    this.calendarId,
    this.categoryFilter,
    this.eventId,
    this.currentEvent,
    this.proposedEvent,
    this.occurrenceQuery,
    this.freeBusyQuery,
    this.availabilityId,
    this.currentAvailability,
    this.proposedAvailability,
    this.occurrenceChange,
    this.proposedTimingOverrides,
    Iterable<CalendarEventFieldGroup> eventGroups = const [],
    Iterable<CalendarFieldGroup> requestedGroups = const [],
  }) : requestedGroups = Set.unmodifiable(requestedGroups),
       eventGroups = Set.unmodifiable(eventGroups);
  final String key;
  final CalendarPermission operation;
  final UuidValue? eventId;
  final CalendarEventPolicySnapshot? currentEvent;
  final CalendarEventContent? proposedEvent;
  final CalendarEventOccurrenceQuery? occurrenceQuery;
  final CalendarFreeBusyQuery? freeBusyQuery;
  final UuidValue? availabilityId;
  final CalendarAvailabilityPolicySnapshot? currentAvailability;
  final CalendarAvailabilityContent? proposedAvailability;
  final CalendarEventOccurrenceChange? occurrenceChange;
  final CalendarEventTimingOverrides? proposedTimingOverrides;
  final Set<CalendarEventFieldGroup> eventGroups;
  final CalendarCategoryQuery? categoryFilter;

  /// Actual server-resolved collection/object identity, absent for scope/create.
  final UuidValue? calendarId;
  final CalendarPolicySnapshot? current;
  final CalendarProposedChange? proposed;
  final Set<CalendarFieldGroup> requestedGroups;
}

final class CalendarAuthorizationDecision {
  CalendarAuthorizationDecision({
    required this.key,
    required this.verdict,
    Iterable<CalendarFieldGroup> disclosedGroups = const [],
    this.discloseMutationReceipt = false,
    Iterable<CalendarEventFieldGroup> eventDisclosedGroups = const [],
  }) : disclosedGroups = Set.unmodifiable(disclosedGroups),
       eventDisclosedGroups = Set.unmodifiable(eventDisclosedGroups);
  final String key;
  final CalendarAuthorizationVerdict verdict;
  final Set<CalendarFieldGroup> disclosedGroups;
  final bool discloseMutationReceipt;
  final Set<CalendarEventFieldGroup> eventDisclosedGroups;
}

/// Server-owned coarse candidate constraint. Object decisions still apply.
final class CalendarCategoryQuery {
  const CalendarCategoryQuery(this.value, this.language);
  final String value;
  final String? language;
}

final class CalendarCandidatePlan {
  CalendarCandidatePlan({Iterable<UuidValue>? calendarIds})
    : calendarIds = calendarIds == null ? null : Set.unmodifiable(calendarIds);
  final Set<UuidValue>? calendarIds;
}

/// Hosts supply rules and a truthful guarantee. All methods must be side-effect
/// free except transactional locking; no notification/mail/business writes.
abstract interface class CalendarHostPolicy {
  CalendarAuthorizationGuarantee get guarantee;
  Future<CalendarHostContext> resolveContext(Session session);
  Future<CalendarCandidatePlan> planQuery(
    Session session,
    CalendarHostContext context,
    Set<CalendarFieldGroup> requestedGroups, {
    CalendarCategoryQuery? categoryFilter,
  });

  Future<CalendarEventCandidatePlan> planEventQuery(
    Session session,
    CalendarHostContext context,
    CalendarPolicySnapshot calendar,
    Set<CalendarEventFieldGroup> requestedGroups,
  );

  /// For coordinated guarantees, finalWrite must coordinate every relevant
  /// policy revocation through this transaction until its actual commit.
  /// A version label alone is not coordination. Every retry is a new call.
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session session,
    CalendarHostContext context,
    List<CalendarAuthorizationRequest> requests,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

/// Future optional modules register their real dependencies here and must use
/// the same active-parent transaction/lock boundary for child writes.
abstract interface class CalendarDependencyProvider {
  Future<bool> hasActiveDependencies(
    Session session,
    UuidValue calendarId,
    Transaction transaction,
  );
}

final class CalendarModuleOptions {
  const CalendarModuleOptions({
    required this.requiredWriteGuarantee,
    this.maxPageSize = 100,
    this.maxScannedCalendars = 1000,
    this.maxScannedEvents = 1000,
    this.policyBatchSize = 64,
    this.maxAssociations = 64,
    this.maxCursorsPerScope = 64,
    this.cursorLifetime = const Duration(minutes: 10),
    this.policyTimeout = const Duration(seconds: 5),
  });
  final CalendarAuthorizationGuarantee requiredWriteGuarantee;
  final int maxPageSize,
      maxScannedCalendars,
      maxScannedEvents,
      policyBatchSize,
      maxAssociations,
      maxCursorsPerScope;
  final Duration cursorLifetime, policyTimeout;
}

final class CalendarEventCandidatePlan {
  CalendarEventCandidatePlan({Iterable<UuidValue>? eventIds})
    : eventIds = eventIds == null ? null : Set.unmodifiable(eventIds);
  final Set<UuidValue>? eventIds;
}

final class CalendarEventPolicySnapshot {
  const CalendarEventPolicySnapshot(
    this.eventId,
    this.calendarId,
    this.revision,
    this.content,
    this.protocolUid,
    this.updatedAt, {
    this.timingOverrides,
  });
  final CalendarEventTimingOverrides? timingOverrides;
  final UuidValue eventId, calendarId;
  final int revision;
  final CalendarEventContent content;
  final String protocolUid;
  final DateTime updatedAt;
}

/// Validated, frozen native rule state plus its actual parent identity.
final class CalendarAvailabilityPolicySnapshot {
  const CalendarAvailabilityPolicySnapshot(
    this.availabilityId,
    this.calendarId,
    this.revision,
    this.content,
    this.protocolUid,
    this.updatedAt,
  );
  final UuidValue availabilityId, calendarId, protocolUid;
  final int revision;
  final CalendarAvailabilityContent content;
  final DateTime updatedAt;
}
