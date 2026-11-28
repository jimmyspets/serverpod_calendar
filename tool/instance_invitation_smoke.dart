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
      v.originalStart?.start.day == 5 &&
          v.timing?.start.hour == 11 &&
          (await api.getInvitation(master.entryId)).revision == 1,
      'Instance source changed original or master',
    );
    await rejects(() => api.link(instance!.entryId));
    await rejects(() => api.application(instance!.entryId));
    final response = await api.recurringOccurrenceResponse(
      instance.entryId,
      v.originalStart!,
    );
    require(
      response.canSend && response.originalStart.start.day == 5,
      'Instance response lost its original or source eligibility',
    );
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
          notice.originalStart?.start.day == 5 &&
          notice.kind == cal.CalendarInvitationSourceKind.instanceCancellation,
      'Cancellation lost original or manufactured start',
    );
    require(
      !(await api.response(instance.entryId)).canSend,
      'Instance cancellation admitted a new response',
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

Future<void> rangeInvitationSmoke(List<Client> clients) async {
  final a = clients.first, b = clients.last;
  final api = b.modules.serverpod_calendar.calendarInvitation;
  final id = const cal.Uuid().v4obj(), key = const cal.Uuid().v4obj();
  final master = await a.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Range review basis',
  );
  final entries = <cal.UuidValue>[master.entryId];
  void require(bool value, String message) {
    if (!value) throw StateError(message);
  }

  Future<void> rejects(Future<Object?> Function() call) async {
    try {
      await call();
    } on cal.CalendarException catch (e) {
      require(
        e.code == cal.CalendarFailureCode.validation,
        'Wrong range guard failure',
      );
      return;
    }
    throw StateError('Range crossed a master/single action boundary');
  }

  try {
    final raced = await Future.wait(
      clients.map((c) => c.invitationDemo.simulateRange(id, key, 1, false)),
    );
    require(
      raced.first.id == raced.last.id,
      'Range ingress race duplicated receipt',
    );
    final r = raced.first;
    entries.add(r.entryId);
    final v = await api.getInvitation(r.entryId);
    require(
      v.isThisAndFuture &&
          v.originalStart?.start.day == 3 &&
          v.timing?.start.hour == 11,
      'Range projection lost source identity',
    );
    final single = await a.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      1,
      false,
    );
    entries.add(single.entryId);
    require(
      single.entryId != r.entryId &&
          !(await api.getInvitation(single.entryId)).isThisAndFuture,
      'Single and range review targets collided',
    );
    final source = await api.source(r.entryId, r.sourceId);
    require(
      source.text.contains(
        'RECURRENCE-ID;RANGE=THISANDFUTURE:20300103T090000Z',
      ),
      'MIME lost RANGE',
    );
    for (final call in <Future<Object?> Function()>[
      () => api.link(r.entryId),
      () => api.application(r.entryId),
      () => api.occurrenceApplication(r.entryId),
      () => api.response(r.entryId),
      () => api.responseActivity(r.entryId),
    ]) {
      await rejects(call);
    }
    await a.invitationDemo.simulateRange(id, const cal.Uuid().v4obj(), 2, true);
    final notice = await api.getInvitation(r.entryId);
    require(
      notice.kind == cal.CalendarInvitationSourceKind.rangeCancellation &&
          notice.isThisAndFuture &&
          notice.timing == null,
      'Range cancellation manufactured timing or lost kind',
    );
    require(
      (await api.getInvitation(single.entryId)).revision == 1 &&
          !(await api.recurringOccurrenceResponse(
            single.entryId,
            (await api.getInvitation(single.entryId)).originalStart!,
          )).canSend,
      'Range cancellation did not block source-only occurrence eligibility',
    );
    await api.dismiss(notice.id, notice.revision);
    require(
      (await a.invitationDemo.simulateRange(id, key, 1, false)).id == r.id &&
          (await api.getInvitation(r.entryId)).dismissedAt != null,
      'Historical range retry reactivated notice',
    );
    require(
      (await api.getInvitation(master.entryId)).revision == 1,
      'Range altered master',
    );
    stdout.writeln(
      'PASS: generated-client two-host range MIME, distinct single target, source/guards, cancellation/dismissal and historical retries.',
    );
  } finally {
    for (final entry in entries) {
      final current = await api.getInvitation(entry);
      if (current.dismissedAt == null) {
        await api.dismiss(entry, current.revision);
      }
    }
  }
}
