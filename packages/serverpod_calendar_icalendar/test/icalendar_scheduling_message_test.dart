import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart' show fixedZone, explicitZone;

import 'support/scheduling_fixtures.dart';

void main() {
  test(
    'mandatory envelope and REPLY zone cardinality are independent checks',
    () {
      final source = message('REPLY', minimal('REPLY'));
      for (final line in [
        'VERSION:2.0',
        'PRODID:-//Synthetic scheduling//EN',
        'METHOD:REPLY',
      ]) {
        expect(
          () => load(source.replaceFirst('$line\r\n', '')),
          rejects(IcalendarComponentError.missing),
        );
      }
      final zones = [fixedZone(), fixedZone(id: 'Etc/UTC')];
      expect(
        () => load(message('REPLY', minimal('REPLY'), zones: zones)),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(
          message('REQUEST', minimal('REQUEST'), zones: zones),
          limits: const IcalendarComponentLimits(maxZones: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(
          message(
            'REQUEST',
            minimal('REQUEST'),
            zones: [fixedZone(), fixedZone()],
          ),
        ),
        rejects(IcalendarComponentError.duplicate),
      );
    },
  );
  for (final method in ['PUBLISH', 'REQUEST', 'REPLY', 'CANCEL']) {
    test('$method minimal message round trips without manufactured fields', () {
      final source = message(method, minimal(method));
      final value = load(source);
      expect(value.method.name, method.toLowerCase());
      expect(value.uid, 'synthetic-scheduling@example.invalid');
      expect(value.sequence, method == 'CANCEL' ? 2 : null);
      expect(
        value.status,
        method == 'CANCEL' ? IcalendarEventStatus.cancelled : null,
      );
      expect(value.transparency, isNull);
      expect(
        value.summary?.value,
        method == 'PUBLISH' || method == 'REQUEST' ? '' : null,
      );
      expect(value.startTime == null, method == 'REPLY' || method == 'CANCEL');
      expect(value.created, isNull);
      expect(value.lastModified, isNull);
      expect(
        utf8
            .decode(serializeIcalendarSchedulingMessage(value))
            .replaceAll('\r\n ', ''),
        source,
      );
      expect(
        () => value.participants.attendees.clear(),
        throwsUnsupportedError,
      );
      expect(() => value.timeZones.clear(), throwsUnsupportedError);
    });
    for (final required in [
      'UID',
      'DTSTAMP',
      'ORGANIZER',
      if (method == 'CANCEL') 'SEQUENCE',
      if (method == 'REQUEST') 'ATTENDEE',
      if (method == 'PUBLISH' || method == 'REQUEST') ...['DTSTART', 'SUMMARY'],
    ]) {
      test('$method rejects absent $required', () {
        expect(
          () => load(
            message(
              method,
              minimal(method)
                  .where(
                    (p) =>
                        !p.startsWith('$required:') &&
                        !p.startsWith('$required;'),
                  )
                  .toList(),
            ),
          ),
          rejects(),
        );
      });
    }
  }
  test(
    'method-specific attendees, contact cardinality and status restrictions',
    () {
      expect(
        () => load(message('PUBLISH', [...minimal('PUBLISH'), attendee])),
        rejects(),
      );
      expect(
        () => load(
          message('PUBLISH', [
            ...minimal('PUBLISH'),
            'CONTACT:One',
            'CONTACT:Two',
          ]),
        ),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        load(
          message('REQUEST', [
            ...minimal('REQUEST'),
            'CONTACT:One',
            'CONTACT:Two',
          ]),
        ).metadata.contacts,
        hasLength(2),
      );
      expect(
        () => load(message('REPLY', [...minimal('REPLY'), attendee])),
        rejects(),
      );
      expect(
        () => load(
          message(
            'REPLY',
            minimal('REPLY').where((p) => p != attendee).toList(),
          ),
        ),
        rejects(),
      );
      expect(
        () => load(
          message('REQUEST', [...minimal('REQUEST'), 'STATUS:CANCELLED']),
        ),
        rejects(),
      );
      expect(
        () => load(
          message(
            'CANCEL',
            minimal('CANCEL')
                .map(
                  (p) => p.replaceFirst('STATUS:CANCELLED', 'STATUS:CONFIRMED'),
                )
                .toList(),
          ),
        ),
        rejects(),
      );
      expect(
        load(message('PUBLISH', [...minimal('PUBLISH'), 'STATUS:CANCELLED']))
            .status,
        IcalendarEventStatus.cancelled,
      );
    },
  );
  test('attendee removal preserves absent cancellation status', () {
    final fields = [
      ...minimal('CANCEL').where((p) => !p.startsWith('STATUS:')),
      attendee,
    ];
    final value = load(message('CANCEL', fields));
    expect(value.status, isNull);
    expect(
      value.participants.attendees.single.address,
      'mailto:guest@example.invalid',
    );
    expect(
      () =>
          load(message('CANCEL', fields.where((p) => p != attendee).toList())),
      rejects(),
    );
  });
  test(
    'minimal reply keeps independently supplied end without inventing start',
    () {
      final value = load(
        message('REPLY', [...minimal('REPLY'), 'DTEND:20261022T130000Z']),
      );
      expect(value.startTime, isNull);
      expect(value.timedSpan, isNull);
      expect(value.endTime!.instant, DateTime.utc(2026, 10, 22, 13));
    },
  );
  test('DATE/UTC/named-zone start spans preserve end and duration forms', () {
    final date = load(
      message(
        'REQUEST',
        minimal('REQUEST')
            .map((p) => p == start ? 'DTSTART;VALUE=DATE:20261022' : p)
            .toList()
          ..add('DURATION:P2D'),
      ),
    );
    expect(date.dateSpan!.dayCount, 2);
    expect(date.duration!.days, 2);
    final timed = load(
      message('REQUEST', [...minimal('REQUEST'), 'DTEND:20261022T130000Z']),
    );
    expect(timed.timedSpan!.end!.instant, DateTime.utc(2026, 10, 22, 13));
    final zoned = load(
      message(
        'REQUEST',
        minimal('REQUEST')
            .map(
              (p) => p == start
                  ? 'DTSTART;TZID=America/New_York:20261101T013000'
                  : p,
            )
            .toList()
          ..add('DURATION:PT1H'),
        zones: [explicitZone('America/New_York')],
      ),
    );
    expect(zoned.startTime!.instant, DateTime.utc(2026, 11, 1, 5, 30));
    expect(
      load(utf8.decode(serializeIcalendarSchedulingMessage(zoned)))
          .startTime!
          .instant,
      zoned.startTime!.instant,
    );
  });
  test('partial optional text, annotations, source claims and inert references survive', () {
    final fields = [
      ...minimal('REPLY').where((p) => p != organizer && p != attendee),
      'ORGANIZER;SENT-BY="mailto:delegate@example.invalid":mailto:organizer@example.invalid',
      'ATTENDEE;PARTSTAT=TENTATIVE;CN=Guest;LANGUAGE=en:mailto:guest@example.invalid',
      'SUMMARY;LANGUAGE=sv;ALTREP="https://example.invalid/text":',
      'COMMENT:First',
      'COMMENT:Second',
      'CATEGORIES;LANGUAGE=en:Room,Meeting',
      'CONTACT:One',
      'CONTACT:Two',
      'CLASS:PRIVATE',
      'URL:https://example.invalid/event',
      'ATTACH;FMTTYPE=application/pdf:https://example.invalid/file',
      'RELATED-TO:unresolved',
      'SEQUENCE:0',
      'CREATED:20261021T120000Z',
      'LAST-MODIFIED:20261022T090000Z',
    ];
    final source = message('REPLY', fields), value = load(source);
    expect(value.summary!.value, '');
    expect(value.summary!.language, 'sv');
    expect(value.summary!.alternativeUri, 'https://example.invalid/text');
    expect(value.description, isNull);
    expect(
      value.participants.organizer!.sentBy,
      'mailto:delegate@example.invalid',
    );
    expect(value.metadata.comments, hasLength(2));
    expect(
      value.references.attachments.single.uri,
      'https://example.invalid/file',
    );
    expect(value.sequence, 0);
    expect(
      utf8
          .decode(serializeIcalendarSchedulingMessage(value))
          .replaceAll('\r\n ', ''),
      source,
    );
  });
  for (final property in [
    'RRULE:FREQ=DAILY',
    'RDATE:20261023T120000Z',
    'EXDATE:20261023T120000Z',
    'RECURRENCE-ID:20261022T120000Z',
    'X-PRIVATE:value',
  ]) {
    test('unprofiled $property rejects rather than disappearing', () {
      expect(
        () => load(message('REPLY', [...minimal('REPLY'), property])),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    });
  }
  test('unsupported methods, mixed/multiple components and alarms reject', () {
    for (final method in [
      'ADD',
      'REFRESH',
      'COUNTER',
      'DECLINECOUNTER',
      'X-METHOD',
    ]) {
      expect(() => load(message(method, minimal('REQUEST'))), rejects());
    }
    for (final component in [
      'BEGIN:VTODO\r\nEND:VTODO',
      'BEGIN:VEVENT\r\nEND:VEVENT',
    ]) {
      expect(
        () => load(
          message('REQUEST', minimal('REQUEST'), components: [component]),
        ),
        rejects(),
      );
    }
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'TRIGGER:-PT5M',
          'DESCRIPTION:Reminder',
          'END:VALARM',
        ]),
      ),
      rejects(),
    );
    expect(
      () => load(
        message(
          'REPLY',
          minimal('REPLY')
              .map(
                (p) => p == attendee
                    ? 'ATTENDEE;PARTSTAT=DELEGATED;DELEGATED-TO="mailto:other@example.invalid":mailto:guest@example.invalid'
                    : p,
              )
              .toList(),
        ),
      ),
      rejects(IcalendarComponentError.unsupportedParameter),
    );
  });
  test(
    'envelope, duplicate and property parameter restrictions are enforced',
    () {
      for (final envelope in [
        ['METHOD:REQUEST'],
        ['VERSION:2.0'],
        ['CALSCALE:JULIAN'],
        ['METHOD;X-PARAM=x:REQUEST'],
        ['NAME:Not scheduling presentation'],
      ]) {
        expect(
          () =>
              load(message('REQUEST', minimal('REQUEST'), envelope: envelope)),
          rejects(),
        );
      }
      expect(
        () => load(message('REQUEST', [...minimal('REQUEST'), stamp])),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        () => load(
          message('REQUEST', [...minimal('REQUEST'), 'SUMMARY:Another']),
        ),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        () => load(
          message(
            'REQUEST',
            minimal('REQUEST')
                .map(
                  (p) => p == organizer
                      ? 'ORGANIZER;X-AUTHORITY=true:mailto:organizer@example.invalid'
                      : p,
                )
                .toList(),
          ),
        ),
        rejects(IcalendarComponentError.unsupportedParameter),
      );
    },
  );
  test('invalid temporal, duration, version and zone inputs reject', () {
    for (final timing in [
      'DTSTART:20261022T120000.000Z',
      'DTSTART:20261022T120060Z',
      'DTSTART:20261022T120000',
      'DTSTART:19691231T120000Z',
      'DTSTART:21000101T000000Z',
      'DTSTART;TZID=UTC:20261022T120000',
    ]) {
      expect(
        () => load(
          message(
            'REQUEST',
            minimal('REQUEST').map((p) => p == start ? timing : p).toList(),
          ),
        ),
        rejects(),
      );
    }
    for (final extra in [
      ['DURATION:PT0S'],
      ['DURATION:-PT1H'],
      ['DURATION:PT1H', 'DTEND:20261022T130000Z'],
      ['DTEND;VALUE=DATE:20261023'],
      ['SEQUENCE:-1'],
      ['SEQUENCE:2147483648'],
    ]) {
      expect(
        () => load(message('REQUEST', [...minimal('REQUEST'), ...extra])),
        rejects(),
      );
    }
    expect(
      () => load(message('REPLY', [...minimal('REPLY'), 'DURATION:PT1H'])),
      rejects(),
    );
    expect(
      () => load(
        message(
          'REQUEST',
          minimal('REQUEST')
              .map((p) => p == start ? 'DTSTART;TZID=UTC:20261022T120000' : p)
              .toList(),
          zones: [fixedZone(offset: '+0100')],
        ),
      ),
      rejects(IcalendarComponentError.zoneMismatch),
    );
  });
  test('exclusive endpoint, empty versus absent values and syntax limits remain explicit', () {
    final value = load(
      message(
        'REQUEST',
        minimal('REQUEST')
            .map((p) => p == start ? 'DTSTART:20991231T230000Z' : p)
            .toList()
          ..add('DTEND:21000101T000000Z'),
      ),
    );
    expect(value.endTime!.instant, DateTime.utc(2100));
    expect(
      () => parseIcalendarSchedulingMessage(
        utf8.encode(message('REQUEST', minimal('REQUEST'))),
        syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 40),
      ),
      throwsA(isA<IcalendarSyntaxException>()),
    );
    expect(
      () => serializeIcalendarSchedulingMessage(
        value,
        syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 40),
      ),
      throwsA(isA<IcalendarSyntaxException>()),
    );
    expect(
      () => load(
        message('REQUEST', [...minimal('REQUEST'), 'DESCRIPTION:Many points']),
        limits: const IcalendarComponentLimits(maxEventMetadataCodePoints: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test('ordinary event import still rejects scheduling METHOD', () {
    final source = utf8.encode(message('REQUEST', minimal('REQUEST')));
    expect(
      () => parseIcalendarEventCalendar(source),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
    final value = validateIcalendarSchedulingMessage(
      parseIcalendarSyntax(source),
    );
    expect(
      () => value.source.components.single.entries.clear(),
      throwsUnsupportedError,
    );
    expect(
      () => validateIcalendarSchedulingMessage(
        IcalendarSyntaxDocument([
          IcalendarSyntaxComponent('VCALENDAR', [
            IcalendarSyntaxProperty('METHOD', 'REQUEST'),
          ]),
        ]),
      ),
      rejects(),
    );
  });
}
