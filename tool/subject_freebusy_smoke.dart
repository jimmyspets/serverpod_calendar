import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

final class _Storage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

Future<void> subjectFreeBusySmoke(
  List<Client> clients,
  String bobPassword,
) async {
  if (clients.length != 2) throw StateError('Two hosts required');
  final a = clients.first.modules.serverpod_calendar,
      b = clients.last.modules.serverpod_calendar;
  final anonymous = Client(clients.first.host);
  final bob = Client(clients.last.host)
    ..authSessionManager = ClientAuthSessionManager(storage: _Storage());
  final owner = await clients.first.smoke.whoAmI();
  final target = cal.CalendarAvailabilityTarget(
    namespace: 'demo',
    kind: 'user',
    externalId: owner,
  );
  final query = cal.CalendarSubjectFreeBusyExportRequest(
    targets: [target],
    fromUtc: DateTime.utc(2031, 1, 14),
    untilUtc: DateTime.utc(2031, 1, 15),
    mode: cal.CalendarAvailabilitySearchMode.perTarget,
  );
  String text(ByteData value) => utf8.decode(
    value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes),
  );
  List<String> periods(String value) => value
      .replaceAll('\r\n ', '')
      .split('\r\n')
      .where((line) => line.startsWith('FREEBUSY;'))
      .toList();
  void require(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  cal.UuidValue? parent, event, rule;
  var attached = false;
  try {
    var denied = false;
    try {
      await anonymous.modules.serverpod_calendar.calendarAvailabilitySearch
          .exportSubjectFreeBusy(query);
    } on ServerpodClientUnauthorized {
      denied = true;
    }
    require(denied, 'Anonymous subject export was allowed');
    final auth = await bob.emailIdp.login(
      email: 'bob@example.invalid',
      password: bobPassword,
    );
    await bob.auth.updateSignedInUser(auth);
    denied = false;
    try {
      await bob.modules.serverpod_calendar.calendarAvailabilitySearch
          .exportSubjectFreeBusy(query);
    } on cal.CalendarException catch (e) {
      if (e.code != cal.CalendarFailureCode.accessDenied) rethrow;
      denied = true;
    }
    require(denied, 'Foreign private subject was exported');
    parent = (await a.calendar.create(
      cal.CalendarCreateRequest(
        displayName: 'Synthetic subject export',
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    await a.calendar.changeSubject(
      cal.CalendarSubjectChangeRequest(
        calendarId: parent,
        expectedRevision: 1,
        action: cal.CalendarSubjectAction.attach,
        namespace: target.namespace,
        kind: target.kind,
        externalId: owner,
        contributesAvailability: true,
      ),
    );
    attached = true;
    event = (await a.calendarEvent.create(
      cal.CalendarEventCreateRequest(
        calendarId: parent,
        content: cal.CalendarEventContent(
          summary: 'Private export title',
          status: cal.CalendarEventStatus.tentative,
          timing: cal.CalendarEventTiming(
            kind: cal.CalendarEventTimeKind.utc,
            start: cal.CalendarEventCivil(
              year: 2031,
              month: 1,
              day: 14,
              hour: 9,
            ),
            duration: cal.CalendarEventDuration(hours: 1),
          ),
        ),
      ),
    ))!.eventId;
    final local = text(
      await a.calendarAvailabilitySearch.exportSubjectFreeBusy(query),
    );
    final remote = text(
      await b.calendarAvailabilitySearch.exportSubjectFreeBusy(
        query.copyWith(mode: cal.CalendarAvailabilitySearchMode.commonFree),
      ),
    );
    require(
      jsonEncode(periods(local)) == jsonEncode(periods(remote)) &&
          remote.contains('BUSY-TENTATIVE:20310114T090000Z/20310114T100000Z'),
      'Cross-host complete subject snapshots disagree',
    );
    for (final secret in [
      parent.toString(),
      event.toString(),
      owner,
      'Private export title',
      'METHOD:',
      'ORGANIZER:',
      'ATTENDEE:',
    ]) {
      require(
        !remote.contains(secret),
        'Subject snapshot disclosed native identity/detail',
      );
    }
    await b.calendarEvent.changeStatus(
      cal.CalendarEventStatusRequest(
        eventId: event,
        expectedRevision: 1,
        status: cal.CalendarEventStatus.cancelled,
      ),
    );
    require(
      !text(await a.calendarAvailabilitySearch.exportSubjectFreeBusy(query))
          .contains('20310114T090000Z/20310114T100000Z'),
      'Committed remote cancellation was ignored',
    );
    rule = (await b.calendarAvailability.create(
      cal.CalendarAvailabilityCreateRequest(
        calendarId: parent,
        content: cal.CalendarAvailabilityContent(openings: []),
      ),
    ))!.availabilityId;
    require(
      text(await a.calendarAvailabilitySearch.exportSubjectFreeBusy(query))
          .contains('BUSY-UNAVAILABLE:20310114T000000Z/20310115T000000Z'),
      'Committed remote working-hours closure was ignored',
    );
    await b.calendarAvailability.deleteRule(rule, 1);
    rule = null;
    require(
      (await a.calendar.getCalendar(parent, [])).revision == 2,
      'Export changed calendar metadata revision',
    );
    await b.calendar.changeSubject(
      cal.CalendarSubjectChangeRequest(
        calendarId: parent,
        expectedRevision: 2,
        action: cal.CalendarSubjectAction.detach,
        namespace: target.namespace,
        kind: target.kind,
        externalId: owner,
        contributesAvailability: true,
      ),
    );
    attached = false;
    denied = false;
    try {
      await a.calendarAvailabilitySearch.exportSubjectFreeBusy(query);
    } on cal.CalendarException catch (e) {
      if (e.code != cal.CalendarFailureCode.unavailable) rethrow;
      denied = true;
    }
    require(denied, 'Missing contributors became an empty free snapshot');
    stdout.writeln(
      'PASS: subject/common VFREEBUSY JWT exports, independent ownership, cross-host event/rule/association changes and anonymous complete snapshots.',
    );
  } finally {
    if (rule != null) await a.calendarAvailability.deleteRule(rule, 1);
    if (event != null) {
      final current = await a.calendarEvent.getEvent(event, []);
      await a.calendarEvent.deleteEvent(event, current.revision);
    }
    if (parent != null) {
      if (attached) {
        final current = await a.calendar.getCalendar(parent, []);
        await a.calendar.changeSubject(
          cal.CalendarSubjectChangeRequest(
            calendarId: parent,
            expectedRevision: current.revision,
            action: cal.CalendarSubjectAction.detach,
            namespace: target.namespace,
            kind: target.kind,
            externalId: owner,
            contributesAvailability: true,
          ),
        );
      }
      final current = await a.calendar.getCalendar(parent, []);
      await a.calendar.delete(parent, current.revision);
    }
    anonymous.close();
    bob.close();
  }
}
