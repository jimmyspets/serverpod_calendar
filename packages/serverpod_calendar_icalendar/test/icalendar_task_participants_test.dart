import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_task_calendar_test.dart' show load, rejects;
import 'icalendar_task_series_test.dart' show series, master, original;

const organizer =
    'ORGANIZER;CN="Synthetic ^\'Organizer^\'";LANGUAGE=en;DIR="ldap://example.invalid/people";SENT-BY="mailto:agent@example.invalid":mailto:organizer@example.invalid';
const attendee =
    'ATTENDEE;CN=Worker;LANGUAGE=en;DIR="https://example.invalid/person";SENT-BY="mailto:agent@example.invalid";CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=IN-PROCESS;RSVP=TRUE;MEMBER="mailto:group@example.invalid","urn:group:second";DELEGATED-TO="mailto:delegate@example.invalid";DELEGATED-FROM="mailto:previous@example.invalid":mailto:worker@example.invalid';
IcalendarTaskAttendee readAttendee(String parameters) => load([
  'ORGANIZER:mailto:org@example.invalid',
  'ATTENDEE$parameters:mailto:worker@example.invalid',
]).tasks.single.participants.attendees.single;

void main() {
  test('source organizer attendee parameters and address lists round trip without native mapping', () {
    final c = load([organizer, attendee]), p = c.tasks.single.participants;
    expect(p.organizer!.address, 'mailto:organizer@example.invalid');
    expect(p.organizer!.commonName, 'Synthetic "Organizer"');
    expect(p.organizer!.language, 'en');
    expect(p.organizer!.directoryUri, 'ldap://example.invalid/people');
    expect(p.organizer!.sentBy, 'mailto:agent@example.invalid');
    final a = p.attendees.single;
    expect(a.members, ['mailto:group@example.invalid', 'urn:group:second']);
    expect(a.delegatedTo, ['mailto:delegate@example.invalid']);
    expect(a.delegatedFrom, ['mailto:previous@example.invalid']);
    expect(a.effectiveParticipationStatus, 'IN-PROCESS');
    expect(a.rsvp, isTrue);
    final bytes = serializeIcalendarTaskCalendar(c),
        again = parseIcalendarTaskCalendar(bytes);
    expect(serializeIcalendarTaskCalendar(again), bytes);
    expect(
      again.tasks.single.participants.attendees.single.parameters,
      a.parameters,
    );
    expect(c.tasks.single.status, isNull);
    expect(c.tasks.single.completed, isNull);
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
    expect(load([]).tasks.single.participants.organizer, isNull);
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
  test(
    'all seven task participation states are independent from task progress',
    () {
      for (final v in [
        'NEEDS-ACTION',
        'ACCEPTED',
        'DECLINED',
        'TENTATIVE',
        'DELEGATED',
        'COMPLETED',
        'IN-PROCESS',
      ]) {
        final c = load([
          'ORGANIZER:mailto:org@example.invalid',
          'ATTENDEE;PARTSTAT=$v:mailto:a@example.invalid',
        ]);
        expect(
          c
              .tasks
              .single
              .participants
              .attendees
              .single
              .effectiveParticipationStatus,
          v,
        );
        expect(c.tasks.single.status, isNull);
        expect(c.tasks.single.percentComplete, isNull);
        expect(c.tasks.single.completed, isNull);
      }
    },
  );
  test('repeated source attendees address spelling order and duplicate claims are preserved', () {
    final c = load([
      organizer,
      'ATTENDEE:mailto:Worker@example.invalid',
      'ATTENDEE:mailto:worker@example.invalid',
      'ATTENDEE:mailto:Worker@example.invalid',
    ]);
    expect(c.tasks.single.participants.attendees.map((a) => a.address), [
      'mailto:Worker@example.invalid',
      'mailto:worker@example.invalid',
      'mailto:Worker@example.invalid',
    ]);
    expect(
      parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c))
          .tasks
          .single
          .participants
          .attendees
          .length,
      3,
    );
  });
  test('occurrence omissions inherit source participants and explicit matching repetitions survive', () {
    final c = series([
      [...master, organizer, attendee],
      [original, 'STATUS:COMPLETED'],
    ]);
    final o = c.series.single.overrides.single;
    expect(o.component.participants.organizer, isNull);
    expect(o.component.participants.attendees, isEmpty);
    expect(
      o.participants.organizer!.address,
      c.tasks.single.participants.organizer!.address,
    );
    expect(
      o.participants.attendees.single.effectiveParticipationStatus,
      'IN-PROCESS',
    );
    expect(o.component.status, IcalendarTaskStatus.completed);
    expect(
      series([
        [...master, organizer, attendee],
        [original, attendee.replaceAll('RSVP=TRUE', 'RSVP=true')],
      ]).series.single.overrides.single.component.participants.attendees.length,
      1,
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
      attendee.replaceAll('PARTSTAT=IN-PROCESS', 'PARTSTAT=COMPLETED'),
      attendee.replaceAll('mailto:worker@', 'mailto:Worker@'),
      'ATTENDEE:mailto:worker@example.invalid',
      organizer.replaceAll('CN="Synthetic', 'CN="Other Synthetic'),
    ]) {
      expect(
        () => series([
          [...master, organizer, attendee],
          [original, p],
        ]),
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
    final p = load([organizer, attendee]).tasks.single.participants;
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
            maxTaskMetadataCodePoints: 100,
          ),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
}
