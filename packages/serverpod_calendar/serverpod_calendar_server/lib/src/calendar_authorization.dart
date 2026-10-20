import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';

/// The guarantee supplied by a host adapter, not inferred from its storage.
enum CalendarAuthorizationGuarantee { freshCheck, coordinated }

enum CalendarAuthorizationPhase { read, preliminaryWrite, finalWrite }

enum CalendarPermission {
  list,
  read,
  create,
  updateMetadata,
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
    required this.availabilityZoneId,
    required this.noRuleFallback,
    required Iterable<CalendarPolicySubject> subjects,
  }) : subjects = List.unmodifiable(subjects);
  final UuidValue calendarId;
  final int revision;
  final String displayName, availabilityZoneId;
  final CalendarNoRuleFallback noRuleFallback;
  final List<CalendarPolicySubject> subjects;
}

final class CalendarProposedChange {
  const CalendarProposedChange({
    this.displayName,
    this.availabilityZoneId,
    this.noRuleFallback,
    this.subject,
  });
  final String? displayName, availabilityZoneId;
  final CalendarNoRuleFallback? noRuleFallback;
  final CalendarSubjectIntent? subject;
}

final class CalendarAuthorizationRequest {
  CalendarAuthorizationRequest({
    required this.key,
    required this.operation,
    this.current,
    this.proposed,
    this.calendarId,
    Iterable<CalendarFieldGroup> requestedGroups = const [],
  }) : requestedGroups = Set.unmodifiable(requestedGroups);
  final String key;
  final CalendarPermission operation;

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
  }) : disclosedGroups = Set.unmodifiable(disclosedGroups);
  final String key;
  final CalendarAuthorizationVerdict verdict;
  final Set<CalendarFieldGroup> disclosedGroups;
  final bool discloseMutationReceipt;
}

/// Server-owned coarse candidate constraint. Object decisions still apply.
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
    Set<CalendarFieldGroup> requestedGroups,
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
    this.policyBatchSize = 64,
    this.maxAssociations = 64,
    this.maxCursorsPerScope = 64,
    this.cursorLifetime = const Duration(minutes: 10),
    this.policyTimeout = const Duration(seconds: 5),
  });
  final CalendarAuthorizationGuarantee requiredWriteGuarantee;
  final int maxPageSize,
      maxScannedCalendars,
      policyBatchSize,
      maxAssociations,
      maxCursorsPerScope;
  final Duration cursorLifetime, policyTimeout;
}
