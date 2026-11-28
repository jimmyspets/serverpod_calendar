import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_event_override_test.dart' show timed, single, rejects;
import 'support/icalendar_fixtures.dart' as f;

IcalendarEventCalendar load(
  List<String> values, {
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => f.load(
  f.file(events: [f.event(extra: values)]),
  limits: limits,
);

const organizer =
    'ORGANIZER;CN="Synthetic ^\'Organizer^\'";LANGUAGE=en;DIR="ldap://example.invalid/people";SENT-BY="mailto:agent@example.invalid":mailto:organizer@example.invalid';
const attendee =
    'ATTENDEE;CN=Worker;LANGUAGE=en;DIR="https://example.invalid/person";SENT-BY="mailto:agent@example.invalid";CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE;MEMBER="mailto:group@example.invalid","urn:group:second";DELEGATED-TO="mailto:delegate@example.invalid";DELEGATED-FROM="mailto:previous@example.invalid":mailto:worker@example.invalid';
IcalendarEventAttendee readAttendee(String parameters) => load([
  'ORGANIZER:mailto:org@example.invalid',
  'ATTENDEE$parameters:mailto:worker@example.invalid',
]).events.single.participants.attendees.single;

void main() {
  test('source organizer attendee parameters and address lists round trip without native mapping', () {
    final c = load([organizer, attendee]), p = c.events.single.participants;
    expect(p.organizer!.address, 'mailto:organizer@example.invalid');
    expect(p.organizer!.commonName, 'Synthetic "Organizer"');
    expect(p.organizer!.language, 'en');
    expect(p.organizer!.directoryUri, 'ldap://example.invalid/people');
    expect(p.organizer!.sentBy, 'mailto:agent@example.invalid');
    final a = p.attendees.single;
    expect(a.members, ['mailto:group@example.invalid', 'urn:group:second']);
    expect(a.delegatedTo, ['mailto:delegate@example.invalid']);
    expect(a.delegatedFrom, ['mailto:previous@example.invalid']);
    expect(a.effectiveParticipationStatus, 'ACCEPTED');
    expect(a.rsvp, isTrue);
    final bytes = serializeIcalendarEventCalendar(c),
        again = parseIcalendarEventCalendar(bytes);
    expect(serializeIcalendarEventCalendar(again), bytes);
    expect(
      again.events.single.participants.attendees.single.parameters,
      a.parameters,
    );
  });
  test('absent parameters retain presence while named effective defaults are available', () {
    final a = readAttendee('');
    expect(a.parameters, isEmpty);
    expect(a.calendarUserType, isNull);
    expect(a.role, isNull);
    expect(a.participationStatus, isNull);
    expect(a.rsvp, isNull);
    expect(a.effectiveCalendarUserType, 'INDIVIDUAL');
    expect(a.effectiveRole, 'REQ-PARTICIPANT');
    expect(a.effectiveParticipationStatus, 'NEEDS-ACTION');
    expect(a.effectiveRsvp, isFalse);
    expect(a.members, isEmpty);
    expect(load([]).events.single.participants.organizer, isNull);
  });
  test(
    'unrecognized token claims retain source values with RFC fallback only',
    () {
      final a = readAttendee(
        ';CUTYPE=X-CUSTOM;ROLE=X-CUSTOM;PARTSTAT=X-CUSTOM',
      );
      expect(a.calendarUserType, 'X-CUSTOM');
      expect(a.role, 'X-CUSTOM');
      expect(a.participationStatus, 'X-CUSTOM');
      expect(a.effectiveCalendarUserType, 'UNKNOWN');
      expect(a.effectiveRole, 'REQ-PARTICIPANT');
      expect(a.effectiveParticipationStatus, 'NEEDS-ACTION');
      for (final v in ['INDIVIDUAL', 'GROUP', 'ROOM', 'RESOURCE', 'UNKNOWN']) {
        expect(readAttendee(';CUTYPE=$v').effectiveCalendarUserType, v);
      }
      for (final v in [
        'CHAIR',
        'REQ-PARTICIPANT',
        'OPT-PARTICIPANT',
        'NON-PARTICIPANT',
      ]) {
        expect(readAttendee(';ROLE=$v').effectiveRole, v);
      }
    },
  );
  test('event states exclude task-only completion while preserving unknown token fallbacks', () {
    for (final v in [
      'NEEDS-ACTION',
      'ACCEPTED',
      'DECLINED',
      'TENTATIVE',
      'DELEGATED',
    ]) {
      expect(readAttendee(';PARTSTAT=$v').effectiveParticipationStatus, v);
    }
    for (final v in ['COMPLETED', 'IN-PROCESS']) {
      expect(
        () => readAttendee(';PARTSTAT=$v'),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
  });
  test('repeated source attendees address spelling order and duplicate claims are preserved', () {
    final c = load([
      organizer,
      'ATTENDEE:mailto:Worker@example.invalid',
      'ATTENDEE:mailto:worker@example.invalid',
      'ATTENDEE:mailto:Worker@example.invalid',
    ]);
    expect(c.events.single.participants.attendees.map((a) => a.address), [
      'mailto:Worker@example.invalid',
      'mailto:worker@example.invalid',
      'mailto:Worker@example.invalid',
    ]);
    expect(
      parseIcalendarEventCalendar(serializeIcalendarEventCalendar(c))
          .events
          .single
          .participants
          .attendees
          .length,
      3,
    );
  });
  test('occurrence omissions inherit while explicit matching source claims retain presence', () {
    final c = timed(
      [
        single(':20261023T120000Z', 'DTSTART:20261023T140000Z'),
        single(
          ';RANGE=THISANDFUTURE:20261024T120000Z',
          'DTSTART:20261024T150000Z',
          extra: [organizer, attendee.replaceAll('RSVP=TRUE', 'RSVP=true')],
        ),
      ],
      extra: [organizer, attendee],
    );
    final s = c.series.single, o = s.overrides.first;
    expect(o.participants.organizer, isNull);
    expect(o.participants.attendees, isEmpty);
    expect(
      s.participantsFor(o).attendees.single.effectiveParticipationStatus,
      'ACCEPTED',
    );
    expect(s.overrides.last.participants.attendees.single.rsvp, isTrue);
    expect(
      () => s.participantsFor(timed([]).events.single),
      throwsArgumentError,
    );
  });
  test('explicit participant differences missing organizer and singleton duplicates reject', () {
    expect(
      () => load(['ATTENDEE:mailto:a@example.invalid']),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      () => load([organizer, organizer]),
      rejects(IcalendarComponentError.duplicate),
    );
    for (final p in [
      attendee.replaceAll('PARTSTAT=ACCEPTED', 'PARTSTAT=DECLINED'),
      attendee.replaceAll('mailto:worker@', 'mailto:Worker@'),
      'ATTENDEE:mailto:worker@example.invalid',
      organizer.replaceAll('CN="Synthetic', 'CN="Other Synthetic'),
    ]) {
      expect(
        () => timed(
          [
            single(':20261023T120000Z', 'DTSTART:20261023T140000Z', extra: [p]),
          ],
          extra: [organizer, attendee],
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
  });
  test(
    'context unknown duplicate and multivalued singleton parameters reject',
    () {
      for (final p in [
        'ORGANIZER;ROLE=CHAIR:mailto:o@example.invalid',
        'ATTENDEE;X-PRIVATE=yes:mailto:a@example.invalid',
        'ATTENDEE;RSVP=TRUE;RSVP=FALSE:mailto:a@example.invalid',
        'ATTENDEE;CN=One,Two:mailto:a@example.invalid',
        'ATTENDEE;SENT-BY="mailto:a@example.invalid","mailto:b@example.invalid":mailto:c@example.invalid',
      ]) {
        expect(
          () => load([organizer, p]),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
    },
  );
  test('malformed or unanchored claims reject instead of being normalized', () {
    for (final parameters in [
      ';RSVP=YES',
      ';LANGUAGE=en',
      ';CN=Name;LANGUAGE=not_a_tag',
      ';ROLE=BAD_VALUE',
      ';ROLE="CHAIR^n"',
      ';CUTYPE=',
      ';DIR="relative/path"',
      ';SENT-BY="https://user:password@example.invalid"',
      ';MEMBER="mailto:good@example.invalid","bad"',
      ';DELEGATED-TO="mailto:a@example.invalid/%zz"',
    ]) {
      expect(
        () => readAttendee(parameters),
        throwsA(isA<IcalendarComponentException>()),
        reason: parameters,
      );
    }
    for (final address in [
      'relative',
      'mailto:',
      'mailto:bad address',
      'https://user:password@example.invalid',
      'https://example.invalid/%zz',
    ]) {
      expect(
        () => load(['ORGANIZER:$address']),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
  });
  test('immutable source participant lists cannot be changed by callers', () {
    final p = load([organizer, attendee]).events.single.participants;
    expect(() => p.attendees.clear(), throwsUnsupportedError);
    expect(() => p.attendees.single.parameters.clear(), throwsUnsupportedError);
    expect(() => p.attendees.single.members.clear(), throwsUnsupportedError);
    expect(
      () => p.attendees.single.delegatedTo.clear(),
      throwsUnsupportedError,
    );
  });
  test(
    'participant list address and file-wide text limits reject atomically',
    () {
      expect(
        () => load([
          organizer,
          ...List.filled(65, 'ATTENDEE:mailto:a@example.invalid'),
        ]),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => readAttendee(
          ';MEMBER=${List.filled(17, '"mailto:a@example.invalid"').join(',')}',
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(['ORGANIZER:urn:${'a' * 1024}']),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => readAttendee(';CN=${'a' * 4097}'),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          [organizer, attendee],
          limits: const IcalendarComponentLimits(
            maxEventMetadataCodePoints: 100,
          ),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
}
