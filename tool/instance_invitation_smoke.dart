import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> instanceInvitationSmoke(List<Client> clients) async {
  final a = clients.first, b = clients.last;
  final api = b.modules.serverpod_calendar.calendarInvitation;
  final id = const cal.Uuid().v4obj(), key = const cal.Uuid().v4obj();
  final master = await a.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Instance review basis',
  );
  cal.CalendarInvitationReceipt? instance;
  void require(bool value, String message) {
    if (!value) throw StateError(message);
  }

  Future<void> rejects(Future<Object?> Function() call) async {
    try {
      await call();
    } on cal.CalendarException catch (e) {
      require(
        e.code == cal.CalendarFailureCode.validation,
        'Wrong instance action failure',
      );
      return;
    }
    throw StateError('Master-only action accepted instance entry');
  }

  try {
    final raced = await Future.wait(
      clients.map(
        (c) => c.invitationDemo.simulateOccurrence(id, key, 1, false),
      ),
    );
    instance = raced.first;
    require(
      raced.first.id == raced.last.id,
      'Generated ingress retry duplicated receipt',
    );
    final v = await api.getInvitation(instance.entryId);
    require(
      v.originalStart?.start.day == 3 &&
          v.timing?.start.hour == 11 &&
          (await api.getInvitation(master.entryId)).revision == 1,
      'Instance source changed original or master',
    );
    await rejects(() => api.link(instance!.entryId));
    await rejects(() => api.application(instance!.entryId));
    await rejects(() => api.response(instance!.entryId));
    final cancelled = await a.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      2,
      true,
    );
    final notice = await api.getInvitation(instance.entryId);
    require(
      cancelled.entryId == instance.entryId &&
          notice.timing == null &&
          notice.originalStart?.start.day == 3 &&
          notice.kind == cal.CalendarInvitationSourceKind.instanceCancellation,
      'Cancellation lost original or manufactured start',
    );
    final attempts = await Future.wait(
      clients.map((c) async {
        try {
          await c.modules.serverpod_calendar.calendarInvitation.dismiss(
            notice.id,
            notice.revision,
          );
          return true;
        } on cal.CalendarException catch (e) {
          require(
            e.code == cal.CalendarFailureCode.staleRevision,
            'Wrong dismissal race failure',
          );
          return false;
        }
      }),
    );
    require(
      attempts.where((v) => v).length == 1,
      'Instance dismiss revision race had wrong winner count',
    );
    require(
      (await a.invitationDemo.simulateOccurrence(id, key, 1, false)).id ==
              instance.id &&
          (await api.getInvitation(instance.entryId)).dismissedAt != null,
      'Historical instance retry reactivated notice',
    );
    stdout.writeln(
      'PASS: generated-client two-host instance notices, immutable original/moved timing, private source kinds, master-only guards, cancellation/dismissal races and historical retries.',
    );
  } finally {
    for (final entry in [
      master.entryId,
      if (instance != null) instance.entryId,
    ]) {
      final current = await api.getInvitation(entry);
      if (current.dismissedAt == null) {
        await api.dismiss(entry, current.revision);
      }
    }
  }
}
