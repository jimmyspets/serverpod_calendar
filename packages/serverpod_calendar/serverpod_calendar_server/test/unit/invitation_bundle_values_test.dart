@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';

import 'event_wire_output_test.dart' show snapshot;

import 'published_range_cancellation_values_test.dart' show raw;

void main() {
  IcalendarSchedulingMessage message(String source) =>
      parseIcalendarSchedulingMessage(utf8.encode(source));

  for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
    test(
      '$profile retains the whole series and independent source versions',
      () {
        final source = message(
          raw(
            date: profile == 'date',
            zone: profile == 'date' || profile == 'utc' ? null : profile,
            own: [(2, 4, false, null), (5, 6, true, 12)],
          ),
        );
        final before = serializeIcalendarSchedulingMessage(source);
        final result = invitationRequestBundleProposal(source);
        expect(result.edits!.singles.length, 1);
        expect(result.edits!.future.length, 1);
        expect(result.protocolState.version.sequence, 2);
        expect(result.edits!.singles.single.originalStart.start.day, 2);
        expect(result.edits!.future.single.originalStart.start.day, 5);
        expect(serializeIcalendarSchedulingMessage(source), before);
      },
    );
  }

  test('a master alone is not a bundle', () {
    expect(
      () => invitationRequestBundleProposal(message(raw())),
      throwsArgumentError,
    );
  });
  for (final (prefix, start, original, moved) in [
    ('203003', 27, 28, 30),
    ('203010', 24, 25, 26),
  ]) {
    test('named-zone DST $prefix keeps original identity through export', () {
      final value = invitationRequestBundleProposal(
        message(
          raw(
            zone: 'Europe/Stockholm',
            prefix: prefix,
            startDay: start,
            time: '023000',
            rule: 'FREQ=DAILY;COUNT=3',
            own: [(original, moved, false, 7)],
          ),
        ),
      );
      final exported = parseIcalendarEventCalendar(
        eventExportBytes([snapshot(value)]),
      );
      expect(exported.series.single.overrides.single.sequence, 7);
      expect(value.edits!.singles.single.originalStart.start.day, original);
      expect(value.edits!.singles.single.replacement!.start.day, moved);
    });
  }
  test('source annotations, references and PERIOD forms survive native export', () {
    final value = invitationRequestBundleProposal(
      message(
        raw(
          sequence: null,
          own: [(2, 4, false, 7)],
          extra: [
            'CATEGORIES;LANGUAGE=sv:Alpha,Beta',
            'RELATED-TO:unresolved-source',
            'ATTACH;FMTTYPE=application/pdf:https://example.invalid/inert.pdf',
            'RDATE;VALUE=PERIOD:20300110T090000Z/PT2H',
            'EXDATE:20300103T090000Z',
          ],
        ).replaceFirst(
          'DESCRIPTION:Private retained text',
          'DESCRIPTION;LANGUAGE=sv;ALTREP="https://example.invalid/text":Source text',
        ),
      ),
    );
    final exported = parseIcalendarEventCalendar(
      eventExportBytes([snapshot(value)]),
    );
    final master = exported.series.single.master;
    expect(master.sequence, isNull);
    expect(value.content.periods!.length, 1);
    expect(
      utf8.decode(eventExportBytes([snapshot(value)])),
      contains('ALTREP="https://example.invalid/text"'),
    );
    expect(
      master.references.relationships.single.targetUid,
      'unresolved-source',
    );
    expect(exported.series.single.overrides.single.sequence, 7);
  });
  test('missing component participant claims reject rather than inherit', () {
    expect(
      () => invitationRequestBundleProposal(
        message(
          raw(
            own: [(2, 4, false, 3)],
            ownClaims: false,
          ),
        ),
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
  test('source alarms reject without stripping an unsupported component', () {
    expect(
      () => invitationRequestBundleProposal(
        message(
          raw(
            own: [(2, 4, false, 7)],
            extra: [
              'BEGIN:VALARM',
              'ACTION:DISPLAY',
              'TRIGGER:-PT15M',
              'DESCRIPTION:Untrusted reminder',
              'END:VALARM',
            ],
          ),
        ),
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
  test(
    'shared work exhaustion and byte limits reject the complete projection',
    () {
      final source = message(raw(own: [(2, 4, false, 3)]));
      expect(
        () => invitationRequestBundleProposal(source, maxBytes: 128),
        throwsA(anything),
      );
      expect(
        () => invitationRequestBundleProposal(
          source,
          sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
        ),
        throwsA(anything),
      );
      expect(
        () => invitationRequestBundleProposal(
          source,
          sharedWorkBudget: RecurrenceWorkBudget(maxWork: 200001),
        ),
        throwsArgumentError,
      );
    },
  );
}
