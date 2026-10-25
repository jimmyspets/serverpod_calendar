import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as cal;
import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart'
    as feed;

/// Example only: one private scope and publication authority per active user.
final class DemoFeedPolicy implements feed.CalendarFeedHostPolicy {
  @override
  cal.CalendarAuthorizationGuarantee get guarantee =>
      cal.CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<feed.CalendarFeedHostContext> resolveContext(Session session) async {
    final key = session.authenticationKey;
    final handler = session.serverpod.authenticationHandler;
    final current = key == null || handler == null
        ? null
        : await handler(session, key);
    if (current == null ||
        current.userIdentifier != session.authenticated?.userIdentifier) {
      throw StateError('Current authentication required');
    }
    return feed.CalendarFeedHostContext(
      actor: current.userIdentifier,
      scopeKey: 'demo:user:${current.userIdentifier}',
      policyRevision: 'demo-feeds-v1',
      authorityReference: 'demo:user:${current.userIdentifier}',
    );
  }

  @override
  Future<bool> authorize(
    Session session,
    feed.CalendarFeedHostContext context,
    feed.CalendarFeedOperation operation,
    Transaction transaction, {
    feed.CalendarFeedPolicyState? current,
    feed.CalendarFeedPolicyState? proposed,
    required bool finalCheck,
  }) async {
    if (context.scopeKey != 'demo:user:${context.actor}' ||
        context.authorityReference != context.scopeKey ||
        current != null && current.authorityReference != context.scopeKey ||
        proposed != null &&
            !proposed.deleted &&
            proposed.authorityReference != context.scopeKey) {
      return false;
    }
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(context.actor),
      transaction: transaction,
    );
    return user != null && !user.blocked;
  }
}

final class DemoCalendarPublicationPolicy
    implements cal.CalendarPublicationPolicy {
  @override
  cal.CalendarAuthorizationGuarantee get guarantee =>
      cal.CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<bool> authorizePublication(
    Session session,
    cal.CalendarPublicationRequest request,
    Transaction transaction, {
    required bool finalCheck,
  }) async {
    const prefix = 'demo:user:';
    if (!request.scopeKey.startsWith(prefix) ||
        request.authorityReference != request.scopeKey) {
      return false;
    }
    final userId = request.scopeKey.substring(prefix.length);
    if (request.selecting) {
      final key = session.authenticationKey;
      final handler = session.serverpod.authenticationHandler;
      final actor = key == null || handler == null
          ? null
          : await handler(session, key);
      if (actor?.userIdentifier != userId ||
          session.authenticated?.userIdentifier != userId) {
        return false;
      }
    }
    if (request.sources.any(
      (s) => s.event != null && s.event!.calendarId != s.calendar.calendarId,
    )) {
      return false;
    }
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(userId),
      transaction: transaction,
    );
    return user != null && !user.blocked;
  }
}
