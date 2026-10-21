import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

/// Example policy only: production hosts replace this adapter with their rules.
final class DemoCalendarPolicy implements CalendarHostPolicy {
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;

  @override
  Future<CalendarHostContext> resolveContext(Session session) async {
    final principal = session.authenticated!.userIdentifier;
    return CalendarHostContext(
      principalId: principal,
      scopeKey: 'demo:user:$principal',
      policyRevision: 'private-scope-v4',
    );
  }

  @override
  Future<CalendarCandidatePlan> planQuery(
    Session session,
    CalendarHostContext context,
    Set<CalendarFieldGroup> requestedGroups, {
    CalendarCategoryQuery? categoryFilter,
  }) async => CalendarCandidatePlan();

  @override
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session session,
    CalendarHostContext context,
    List<CalendarAuthorizationRequest> requests,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async => [
    for (final request in requests)
      CalendarAuthorizationDecision(
        key: request.key,
        verdict: _allowed(context, request)
            ? CalendarAuthorizationVerdict.allow
            : CalendarAuthorizationVerdict.deny,
        disclosedGroups: request.requestedGroups,
        discloseMutationReceipt: true,
      ),
  ];

  bool _allowed(
    CalendarHostContext context,
    CalendarAuthorizationRequest request,
  ) {
    final subject = request.proposed?.subject?.subject;
    return subject == null ||
        (subject.namespace == 'demo' &&
            subject.kind == 'user' &&
            subject.externalId == context.principalId);
  }
}
