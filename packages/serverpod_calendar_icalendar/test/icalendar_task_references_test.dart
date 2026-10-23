import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_task_calendar_test.dart' show load, task, rejects;
import 'icalendar_task_series_test.dart' show series, master, original;
import 'support/icalendar_fixtures.dart' show file;

void main() {
  test('decoded UID relationship types default presence order and duplicates round trip', () {
    final c = load([
      r'RELATED-TO:parent\, é',
      'RELATED-TO;RELTYPE=child:child',
      'RELATED-TO;RELTYPE=SIBLING:peer',
      'RELATED-TO:parent',
    ]);
    final r = c.tasks.single.references.relationships;
    expect(r.first.targetUid, 'parent, é');
    expect(r.first.relationType, isNull);
    expect(r.first.effectiveRelationType, 'PARENT');
    expect(r[1].relationType, 'CHILD');
    expect(r[2].relationType, 'SIBLING');
    expect(r.last.targetUid, 'parent');
    final bytes = serializeIcalendarTaskCalendar(c);
    expect(
      serializeIcalendarTaskCalendar(parseIcalendarTaskCalendar(bytes)),
      bytes,
    );
    expect(utf8.decode(bytes), contains('RELTYPE=child'));
  });
  test(
    'forward dangling self and cyclic source references remain unresolved data',
    () {
      final c = parseIcalendarTaskCalendar(
        utf8.encode(
          file(
            events: [
              task(
                uid: 'a',
                properties: [
                  'RELATED-TO:b',
                  'RELATED-TO:a',
                  'RELATED-TO:missing',
                ],
              ),
              task(uid: 'b', properties: ['RELATED-TO:a']),
            ],
          ),
        ),
      );
      expect(c.tasks.first.references.relationships.map((r) => r.targetUid), [
        'b',
        'a',
        'missing',
      ]);
      expect(c.tasks.last.references.relationships.single.targetUid, 'a');
    },
  );
  test(
    'inert attachment URI media type and explicit URI annotation survive',
    () {
      final c = load([
        'ATTACH;VALUE=URI;FMTTYPE=Application/PDF:https://example.invalid/file',
        'ATTACH:cid:file@example.invalid',
        'ATTACH:urn:storage:opaque',
      ]);
      final a = c.tasks.single.references.attachments;
      expect(a.first.mediaType, 'Application/PDF');
      expect(a[1].uri, 'cid:file@example.invalid');
      expect(a.last.mediaType, isNull);
      final bytes = serializeIcalendarTaskCalendar(c);
      expect(
        serializeIcalendarTaskCalendar(parseIcalendarTaskCalendar(bytes)),
        bytes,
      );
      expect(utf8.decode(bytes), contains('VALUE=URI;FMTTYPE=Application/PDF'));
    },
  );
  test(
    'occurrence omissions inherit reference lists while raw state stays empty',
    () {
      final c = series([
        [...master, 'RELATED-TO:parent', 'ATTACH:https://example.invalid/file'],
        [original],
      ]);
      final o = c.series.single.overrides.single;
      expect(o.component.references.relationships, isEmpty);
      expect(o.component.references.attachments, isEmpty);
      expect(o.references.relationships.single.targetUid, 'parent');
      expect(
        o.references.attachments.single.uri,
        'https://example.invalid/file',
      );
      expect(
        parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c))
            .series
            .single
            .overrides
            .single
            .component
            .references
            .attachments,
        isEmpty,
      );
    },
  );
  test('matching explicit defaults and media case retain source presence', () {
    final c = series([
      [
        ...master,
        'RELATED-TO:parent',
        'ATTACH;FMTTYPE=application/pdf:urn:storage:file',
      ],
      [
        original,
        'RELATED-TO;RELTYPE=PARENT:parent',
        'ATTACH;VALUE=URI;FMTTYPE=APPLICATION/PDF:urn:storage:file',
      ],
    ]);
    final raw = c.series.single.overrides.single.component.references;
    expect(raw.relationships.single.relationType, 'PARENT');
    expect(raw.attachments.single.mediaType, 'APPLICATION/PDF');
  });
  test('explicit content list order targets and media changes reject', () {
    for (final p in [
      'RELATED-TO:Parent',
      'RELATED-TO;RELTYPE=CHILD:parent',
      'RELATED-TO:other',
      'ATTACH:urn:storage:other',
      'ATTACH;FMTTYPE=application/pdf:urn:storage:file',
    ]) {
      expect(
        () => series([
          [...master, 'RELATED-TO:parent', 'ATTACH:urn:storage:file'],
          [original, p],
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
    expect(
      () => series([
        [...master, 'RELATED-TO:a', 'RELATED-TO:b'],
        [original, 'RELATED-TO:b', 'RELATED-TO:a'],
      ]),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
  });
  test('extended relationships and unknown or duplicate parameters reject', () {
    for (final p in [
      'RELATED-TO;RELTYPE=DEPENDS-ON:other',
      'RELATED-TO;VALUE=URI:https://example.invalid',
      'RELATED-TO;GAP=PT1H:other',
      'RELATED-TO;RELTYPE=PARENT;RELTYPE=CHILD:other',
      'ATTACH;X-PRIVATE=value:urn:file:1',
    ]) {
      expect(() => load([p]), throwsA(isA<IcalendarComponentException>()));
    }
  });
  test(
    'binary encoding and inline data payloads cannot bypass URI-only profile',
    () {
      for (final p in [
        'ATTACH;VALUE=BINARY:AAAA',
        'ATTACH;ENCODING=BASE64;VALUE=BINARY:AAAA',
        'ATTACH:data:application/pdf;base64,AAAA',
        'ATTACH:DATA:text/plain,hello',
      ]) {
        expect(() => load([p]), throwsA(isA<IcalendarComponentException>()));
      }
    },
  );
  test('malformed URI media and empty target reject without repair', () {
    for (final p in [
      'RELATED-TO:',
      r'RELATED-TO:bad\q',
      'ATTACH:relative/file',
      'ATTACH:https://user:password@example.invalid/file',
      'ATTACH:https://example.invalid/%zz',
      'ATTACH;FMTTYPE="text/plain;charset=utf-8":urn:file:1',
      'ATTACH;FMTTYPE=*/*:urn:file:1',
      'ATTACH;FMTTYPE=application/:urn:file:1',
      'ATTACH;FMTTYPE="text/plain^n":urn:file:1',
    ]) {
      expect(
        () => load([p]),
        throwsA(isA<IcalendarComponentException>()),
        reason: p.split(':').first,
      );
    }
  });
  test('reference lists and retained source values are immutable', () {
    final r = load(['RELATED-TO:a', 'ATTACH:urn:file:1'])
        .tasks
        .single
        .references;
    expect(() => r.relationships.clear(), throwsUnsupportedError);
    expect(() => r.attachments.clear(), throwsUnsupportedError);
    expect(
      () => r.attachments.single.source.parameters.clear(),
      throwsUnsupportedError,
    );
  });
  test('per-component limits shared text budgets and long values reject atomically', () {
    for (final p in [
      List.filled(65, 'RELATED-TO:a'),
      List.filled(65, 'ATTACH:urn:file:1'),
      ['RELATED-TO:${'a' * 4097}'],
      ['ATTACH:https://example.invalid/${'a' * 4097}'],
      ['ATTACH;FMTTYPE=application/${'a' * 127}:urn:file:1'],
    ]) {
      expect(() => load(p), throwsA(isA<IcalendarComponentException>()));
    }
    const limits = IcalendarComponentLimits(maxTaskMetadataCodePoints: 60);
    expect(load(['RELATED-TO:${'a' * 20}'], limits: limits).tasks.length, 1);
    expect(
      () => parseIcalendarTaskCalendar(
        utf8.encode(
          file(
            events: [
              task(properties: ['RELATED-TO:${'a' * 20}']),
              task(
                uid: 'other@example.invalid',
                properties: ['ATTACH:urn:file:${'b' * 20}'],
              ),
            ],
          ),
        ),
        limits: limits,
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
}
