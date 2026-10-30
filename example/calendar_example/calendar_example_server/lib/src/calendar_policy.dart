import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

/// Example policy only: production hosts replace this adapter with their rules.
final class DemoCalendarPolicy implements CalendarHostPolicy {
  @override
  Future<CalendarAlarmRecipient> resolveAlarmRecipient(
    Session session,
    CalendarHostContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async => CalendarAlarmRecipient('demo', context.principalId);

  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;

  @override
  Future<CalendarHostContext> resolveContext(Session session) async {
    final principal = session.authenticated!.userIdentifier;
    return CalendarHostContext(
      principalId: principal,
      scopeKey: 'demo:user:$principal',
      policyRevision: 'private-scope-v13',
    );
  }

  @override
  Future<CalendarSubjectResolution> resolveAvailabilitySubject(
    Session session,
    CalendarHostContext context,
    CalendarAvailabilityTarget target,
    Transaction transaction,
  ) async {
    final active = await CalendarIdentityRecord.db.find(
      session,
      where: (t) =>
          t.scopeKey.equals(context.scopeKey) & t.deletedAt.equals(null),
      orderBy: (t) => t.id,
      limit: 257,
      transaction: transaction,
    );
    if (active.length > 256) {
      return CalendarSubjectResolution(
        complete: false,
        revision: context.policyRevision,
        calendarIds: [],
      );
    }
    final links = active.isEmpty
        ? <CalendarSubjectRecord>[]
        : await CalendarSubjectRecord.db.find(
            session,
            where: (t) =>
                t.calendarId.inSet(active.map((a) => a.id!).toSet()) &
                t.namespace.equals(target.namespace) &
                t.kind.equals(target.kind) &
                t.externalId.equals(target.externalId) &
                t.contributesAvailability.equals(true),
            orderBy: (t) => t.calendarId,
            limit: 9,
            transaction: transaction,
          );
    final scope = await CalendarScopeRecord.db.findFirstRow(
      session,
      where: (t) => t.scopeKey.equals(context.scopeKey),
      transaction: transaction,
    );
    return CalendarSubjectResolution(
      complete: links.length <= 8,
      revision: '${context.policyRevision}:${scope?.revision ?? 0}',
      calendarIds: links.map((l) => l.calendarId),
    );
  }

  @override
  Future<CalendarTaskCandidatePlan> planTaskQuery(
    Session s,
    CalendarHostContext c,
    CalendarPolicySnapshot calendar,
    Set<CalendarTaskFieldGroup> groups, {
    CalendarCategoryQuery? categoryFilter,
  }) async => CalendarTaskCandidatePlan();
  @override
  Future<CalendarEventCandidatePlan> planEventOccurrenceQuery(
    Session s,
    CalendarHostContext c,
    CalendarPolicySnapshot calendar,
    CalendarEventOccurrenceListQuery query,
    Set<CalendarEventFieldGroup> groups,
    Transaction transaction,
  ) async => CalendarEventCandidatePlan();

  @override
  Future<CalendarEventCandidatePlan> planEventQuery(
    Session s,
    CalendarHostContext c,
    CalendarPolicySnapshot calendar,
    Set<CalendarEventFieldGroup> groups, {
    CalendarCategoryQuery? categoryFilter,
  }) async => CalendarEventCandidatePlan();
  @override
  Future<CalendarCandidatePlan> planQuery(
    Session session,
    CalendarHostContext context,
    Set<CalendarFieldGroup> requestedGroups, {
    CalendarCategoryQuery? categoryFilter,
  }) async => CalendarCandidatePlan();

  @override
  Future<CalendarAuthorizationVerdict> approveAvailabilityOrganizer(
    Session session,
    CalendarHostContext context,
    CalendarAuthorizationRequest request,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    // Synthetic publication label only. No mail is sent and no directory exists.
    final organizer = request.proposedAvailability!.organizer;
    return organizer == null ||
            organizer.address ==
                'urn:calendar-example:user:${context.principalId}'
        ? CalendarAuthorizationVerdict.allow
        : CalendarAuthorizationVerdict.deny;
  }

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
        taskDisclosedGroups: request.taskGroups,
        eventDisclosedGroups: request.eventGroups,
        discloseMutationReceipt: true,
      ),
  ];

  bool _allowed(
    CalendarHostContext context,
    CalendarAuthorizationRequest request,
  ) {
    final assignees = request.proposedTaskAssignees;
    if (assignees != null &&
        assignees.any(
          (a) =>
              a.namespace != 'demo' ||
              a.kind != 'user' ||
              a.externalId != context.principalId,
        )) {
      return false;
    }
    final target = request.availabilityTarget;
    if (target != null &&
        (target.namespace != 'demo' ||
            target.kind != 'user' ||
            target.externalId != context.principalId)) {
      return false;
    }
    final subject = request.proposed?.subject?.subject;
    return subject == null ||
        (subject.namespace == 'demo' &&
            subject.kind == 'user' &&
            subject.externalId == context.principalId);
  }
}
