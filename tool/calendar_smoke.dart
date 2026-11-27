import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

Future<void> rejects(
  Future<dynamic> Function() call,
  cal.CalendarFailureCode code,
) async {
  try {
    await call();
  } on cal.CalendarException catch (e) {
    if (e.code == code) return;
    rethrow;
  }
  throw StateError('Expected calendar rejection: $code');
}

Future<void> calendarSmoke(List<Client> clients, String bobPassword) async {
  final a = clients.first.modules.serverpod_calendar.calendar;
  final b = clients.last.modules.serverpod_calendar.calendar;
  final principal = await clients.first.smoke.whoAmI();
  const groups = cal.CalendarFieldGroup.values;
  final ids = <UuidValue>[];
  Future<cal.CalendarMutationReceipt> create() async {
    final receipt = (await a.create(
      cal.CalendarCreateRequest(
        displayName: '  Demo  ',
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!;
    ids.add(receipt.calendarId);
    return receipt;
  }

  try {
    final first = await create();
    final second = await create();
    check(
      first.calendarId != second.calendarId,
      'Duplicate names must have separate identities',
    );
    check(
      (await b.getCalendar(first.calendarId, groups)).displayName == 'Demo',
      'Cross-host create visibility',
    );
    await a.updatePresentation(
      cal.CalendarPresentationUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 1,
        displayName: 'Native metadata',
        description: '  Native\nnotes  ',
        color: '#a0b1c2',
      ),
    );
    await b.updateProtocolMetadata(
      cal.CalendarProtocolMetadataUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 2,
        metadata: cal.CalendarProtocolMetadata(
          names: [
            cal.CalendarTextVariant(value: 'Swedish name', language: 'SV'),
            cal.CalendarTextVariant(value: 'English name', language: 'en'),
          ],
          descriptions: [cal.CalendarTextVariant(value: 'Protocol notes')],
          color: 'Turquoise',
        ),
      ),
    );
    final protocolView = await a.getCalendar(second.calendarId, [
      cal.CalendarFieldGroup.protocolMetadata,
    ]);
    check(
      protocolView.displayName == null &&
          protocolView.description == null &&
          protocolView.color == null,
      'Protocol disclosure leaked native presentation',
    );
    check(
      protocolView.protocolMetadata!.names.first.language == 'SV' &&
          protocolView.protocolMetadata!.color == 'Turquoise',
      'Cross-host protocol metadata round trip',
    );
    final nativeView = await a.getCalendar(second.calendarId, [
      cal.CalendarFieldGroup.metadata,
    ]);
    check(
      nativeView.protocolMetadata == null &&
          nativeView.description == '  Native\nnotes  ' &&
          nativeView.color == '#A0B1C2',
      'Native disclosure leaked protocol metadata',
    );
    await a.updateMetadata(
      cal.CalendarMetadataUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 3,
        displayName: 'Only native name changed',
      ),
    );
    final retained = await b.getCalendar(second.calendarId, groups);
    check(
      retained.description == '  Native\nnotes  ' &&
          retained.protocolMetadata!.names.length == 2,
      'Name-only edit discarded metadata',
    );
    await rejects(
      () => a.updateProtocolMetadata(
        cal.CalendarProtocolMetadataUpdateRequest(
          calendarId: second.calendarId,
          expectedRevision: 4,
          metadata: cal.CalendarProtocolMetadata(
            names: [],
            descriptions: [],
            color: '#aabbcc',
          ),
        ),
      ),
      cal.CalendarFailureCode.validation,
    );
    await b.updatePresentation(
      cal.CalendarPresentationUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 4,
        displayName: 'Native cleared',
      ),
    );
    final cleared = await a.getCalendar(second.calendarId, groups);
    check(
      cleared.description == null &&
          cleared.color == null &&
          cleared.protocolMetadata!.names.length == 2,
      'Clearing native fields changed protocol metadata',
    );
    final page = await a.list(pageSize: 1, fieldGroups: groups);
    check(
      page.nextCursor != null && page.calendars.length == 1,
      'Missing protected continuation',
    );
    final next = await b.list(
      pageSize: 1,
      fieldGroups: groups,
      cursor: page.nextCursor,
    );
    check(
      next.calendars.single.id != page.calendars.single.id,
      'Cross-host cursor replay',
    );
    await a.updateMetadata(
      cal.CalendarMetadataUpdateRequest(
        calendarId: first.calendarId,
        expectedRevision: 1,
        displayName: 'Renamed',
      ),
    );
    await rejects(
      () => b.updateMetadata(
        cal.CalendarMetadataUpdateRequest(
          calendarId: first.calendarId,
          expectedRevision: 1,
          displayName: 'Stale',
        ),
      ),
      cal.CalendarFailureCode.staleRevision,
    );
    await rejects(
      () => b.list(pageSize: 1, fieldGroups: groups, cursor: page.nextCursor),
      cal.CalendarFailureCode.invalidCursor,
    );
    final metadata = await b.getCalendar(first.calendarId, [
      cal.CalendarFieldGroup.metadata,
    ]);
    check(
      metadata.availabilityZoneId == null && metadata.displayName == 'Renamed',
      'Disclosure projection',
    );
    await b.updateSettings(
      cal.CalendarSettingsUpdateRequest(
        calendarId: first.calendarId,
        expectedRevision: 2,
        availabilityZoneId: 'UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.unavailable,
      ),
    );
    cal.CalendarSubjectChangeRequest subject(
      cal.CalendarSubjectAction action,
      int revision, {
      String? externalId,
    }) => cal.CalendarSubjectChangeRequest(
      calendarId: first.calendarId,
      expectedRevision: revision,
      action: action,
      namespace: 'demo',
      kind: 'user',
      externalId: externalId ?? principal,
      contributesAvailability: true,
    );
    await rejects(
      () => a.changeSubject(
        subject(cal.CalendarSubjectAction.attach, 3, externalId: 'forged'),
      ),
      cal.CalendarFailureCode.accessDenied,
    );
    // Competing independent hosts must not leave a link attached to a marker.
    final outcomes = await Future.wait([
      a
          .delete(first.calendarId, 3)
          .then<Object?>((r) => r, onError: (Object e) => e),
      b
          .changeSubject(subject(cal.CalendarSubjectAction.attach, 3))
          .then<Object?>((r) => r, onError: (Object e) => e),
    ]);
    check(
      outcomes.whereType<cal.CalendarMutationReceipt>().length == 1,
      'Delete/attach race had multiple winners',
    );
    final winner = outcomes.whereType<cal.CalendarMutationReceipt>().single;
    if (!winner.deleted) {
      await rejects(
        () => a.delete(first.calendarId, 4),
        cal.CalendarFailureCode.dependencyConflict,
      );
      check(
        (await a.subjects(first.calendarId)).single.externalId == principal,
        'Cross-host association visibility',
      );
      await a.changeSubject(
        subject(cal.CalendarSubjectAction.setContribution, 4)
          ..contributesAvailability = false,
      );
      await b.changeSubject(subject(cal.CalendarSubjectAction.detach, 5));
      await a.delete(first.calendarId, 6);
    }
    await rejects(
      () => b.getCalendar(first.calendarId, groups),
      cal.CalendarFailureCode.accessDenied,
    );
    ids.remove(first.calendarId);
    final bob = Client(clients.last.host)
      ..authSessionManager = ClientAuthSessionManager(storage: _Storage());
    try {
      await bob.auth.updateSignedInUser(
        await bob.emailIdp.login(
          email: 'bob@example.invalid',
          password: bobPassword,
        ),
      );
      await rejects(
        () => bob.modules.serverpod_calendar.calendar.getCalendar(
          second.calendarId,
          groups,
        ),
        cal.CalendarFailureCode.accessDenied,
      );
      check(
        (await bob.modules.serverpod_calendar.calendar.list(
          pageSize: 100,
          fieldGroups: groups,
        )).calendars.every((v) => !ids.contains(v.id)),
        'Private scope leakage',
      );
      await bob.auth.signOutDevice();
    } finally {
      bob.close();
    }
    print(
      'PASS: native/protocol metadata isolation, multilingual round trips and generated calendar CRUD, scope isolation, cursors, stale writes and cross-host delete/attach race.',
    );
  } finally {
    for (final id in ids) {
      final v = await b.getCalendar(id, groups);
      await b.delete(id, v.revision);
    }
  }
}

final class _Storage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}
