import 'package:serverpod/serverpod.dart';

import 'alarm_work_store.dart';
import 'calendar_authorization.dart';
import 'generated/protocol.dart';

export 'alarm_work_store.dart' show CalendarAlarmWorkOptions;

enum CalendarAlarmBackgroundOperation { plan, dispatch }

/// Dedicated background policy input; no request login is impersonated.
final class CalendarAlarmBackgroundContext {
  CalendarAlarmBackgroundContext({
    required this.scopeKey,
    this.operation = CalendarAlarmBackgroundOperation.plan,
    required this.recipient,
    required this.alarm,
    required this.calendar,
    this.event,
    this.task,
    Iterable<CalendarTaskOccurrence> taskOccurrences = const [],
  }) : taskOccurrences = List.unmodifiable(taskOccurrences);
  final CalendarAlarmBackgroundOperation operation;
  final String scopeKey;
  final CalendarAlarmRecipient recipient;
  final CalendarAlarmView alarm;
  final CalendarPolicySnapshot calendar;
  final CalendarEventPolicySnapshot? event;
  final CalendarTaskPolicySnapshot? task;
  final List<CalendarTaskOccurrence> taskOccurrences;
  CalendarAlarmBackgroundContext forOperation(
    CalendarAlarmBackgroundOperation value,
  ) => CalendarAlarmBackgroundContext(
    operation: value,
    scopeKey: scopeKey,
    recipient: recipient,
    alarm: alarm,
    calendar: calendar,
    event: event,
    task: task,
    taskOccurrences: taskOccurrences,
  );
}

abstract interface class CalendarAlarmBackgroundPolicy {
  CalendarAuthorizationGuarantee get guarantee;
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarAlarmBackgroundContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

/// Minimal durable source reference. Never contains event text or credentials.
/// Reusable delivery queues must call CalendarModule.validateAlarmDelivery
/// again before every downstream dispatch/retry; acceptance is not display.
final class CalendarAlarmDeliveryIntent {
  const CalendarAlarmDeliveryIntent({
    required this.firingId,
    required this.alarmId,
    required this.generation,
    required this.recipient,
    required this.parent,
    required this.originalKey,
    required this.dueAt,
    required this.expiresAt,
  });
  final UuidValue firingId, alarmId;
  final int generation;
  final CalendarAlarmRecipient recipient;
  final CalendarAlarmParent parent;
  final String originalKey;
  final DateTime dueAt, expiresAt;
}

abstract interface class CalendarAlarmDeliveryPort {
  /// Return true only after durable, idempotent acceptance keyed by firingId.
  /// Failures/false cause retry of the same ID, never an inferred acknowledgement.
  Future<bool> accept(Session session, CalendarAlarmDeliveryIntent intent);
}

final class CalendarAlarmRuntime {
  CalendarAlarmRuntime({
    required this.policy,
    required this.delivery,
    CalendarAlarmWorkOptions? options,
    this.grace = const Duration(minutes: 15),
  }) : options = options ?? CalendarAlarmWorkOptions() {
    if (grace <= Duration.zero ||
        grace > const Duration(days: 1) ||
        grace.inMicroseconds % 1000000 != 0) {
      throw ArgumentError('Grace must be positive whole seconds up to one day');
    }
  }
  final CalendarAlarmBackgroundPolicy policy;
  final CalendarAlarmDeliveryPort delivery;
  final CalendarAlarmWorkOptions options;
  final Duration grace;
}
