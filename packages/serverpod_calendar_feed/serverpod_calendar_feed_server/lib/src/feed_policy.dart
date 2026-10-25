import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

enum CalendarFeedOperation {
  list,
  read,
  create,
  update,
  delete,
  listCredentials,
  createCredential,
  revokeCredential,
}

/// Host-owned identity and authority reference, never client supplied.
final class CalendarFeedHostContext {
  const CalendarFeedHostContext({
    required this.actor,
    required this.scopeKey,
    required this.policyRevision,
    required this.authorityReference,
  });
  final String actor, scopeKey, policyRevision, authorityReference;
}

/// Immutable actual/proposed context; contains no token/digest.
final class CalendarFeedPolicyState {
  CalendarFeedPolicyState({
    required this.id,
    required this.revision,
    required this.authorityReference,
    required this.settingsJson,
    required Iterable<UuidValue> calendarIds,
    this.credentialId,
    this.credentialRevision,
    this.credentialRevokedAt,
    this.credentialLabel,
    this.credentialCreatedAt,
    this.deleted = false,
  }) : calendarIds = List.unmodifiable(calendarIds);
  final UuidValue id;
  final int revision;
  final String authorityReference, settingsJson;
  final List<UuidValue> calendarIds;
  final UuidValue? credentialId;
  final int? credentialRevision;
  final DateTime? credentialRevokedAt;
  final String? credentialLabel;
  final DateTime? credentialCreatedAt;
  final bool deleted;
}

abstract interface class CalendarFeedHostPolicy {
  CalendarAuthorizationGuarantee get guarantee;
  Future<CalendarFeedHostContext> resolveContext(Session session);
  Future<bool> authorize(
    Session session,
    CalendarFeedHostContext context,
    CalendarFeedOperation operation,
    Transaction transaction, {
    CalendarFeedPolicyState? current,
    CalendarFeedPolicyState? proposed,
    required bool finalCheck,
  });
}
