import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

/// Example private-user background access. No JWT/session is fabricated.
final class DemoAlarmBackgroundPolicy implements CalendarAlarmBackgroundPolicy {
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarAlarmBackgroundContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    if (context.recipient.namespace != 'demo' ||
        context.scopeKey != 'demo:user:${context.recipient.key}') {
      return CalendarAuthorizationVerdict.deny;
    }
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(context.recipient.key),
      transaction: transaction,
    );
    return user != null && !user.blocked
        ? CalendarAuthorizationVerdict.allow
        : CalendarAuthorizationVerdict.deny;
  }
}
