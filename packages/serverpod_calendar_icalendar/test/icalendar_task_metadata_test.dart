import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_task_calendar_test.dart' show load, task, rejects;
import 'icalendar_task_series_test.dart' show series, master, original;
import 'support/icalendar_fixtures.dart' show file;

const properties = [
  'URL:https://example.invalid/task?q=work',
  'CLASS:private',
  r'CATEGORIES;LANGUAGE=sv:Arbete\, möten,Planering',
  'CATEGORIES;LANGUAGE=en:Work,Work',
  r'COMMENT;LANGUAGE=sv;ALTREP="cid:note@example.invalid":Första\nAndra',
  'COMMENT:Another',
  r'CONTACT;LANGUAGE=en;ALTREP="https://example.invalid/contact":Synthetic\, Desk',
  'CONTACT:Other desk',
];

void main() {
  test(
    'grouped metadata retains Unicode escaping source groups and annotations',
    () {
      final c = load(properties), m = c.tasks.single.metadata;
      expect(m.url, 'https://example.invalid/task?q=work');
      expect(m.classification, 'PRIVATE');
      expect(m.categoryGroups.map((g) => g.values), [
        ['Arbete, möten', 'Planering'],
        ['Work', 'Work'],
      ]);
      expect(m.categoryGroups.map((g) => g.language), ['sv', 'en']);
      expect(m.comments.first.value, 'Första\nAndra');
      expect(m.comments.first.alternativeUri, 'cid:note@example.invalid');
      expect(m.contacts.first.value, 'Synthetic, Desk');
      expect(m.contacts.first.language, 'en');
      final bytes = serializeIcalendarTaskCalendar(c),
          again = parseIcalendarTaskCalendar(bytes);
      expect(serializeIcalendarTaskCalendar(again), bytes);
      expect(again.tasks.single.metadata.categoryGroups.last.values, [
        'Work',
        'Work',
      ]);
      expect(utf8.decode(bytes), contains('CLASS:private'));
    },
  );
  test('absence remains distinct from PUBLIC and lists are immutable', () {
    final m = load([]).tasks.single.metadata;
    expect(m.url, isNull);
    expect(m.classification, isNull);
    expect(m.categoryGroups, isEmpty);
    expect(m.contacts, isEmpty);
    expect(m.comments, isEmpty);
    final full = load(properties).tasks.single.metadata;
    expect(() => full.categoryGroups.clear(), throwsUnsupportedError);
    expect(
      () => full.categoryGroups.first.values.clear(),
      throwsUnsupportedError,
    );
    expect(() => full.comments.clear(), throwsUnsupportedError);
    expect(() => full.contacts.clear(), throwsUnsupportedError);
  });
  test(
    'omitted occurrence metadata inherits without inserting source properties',
    () {
      final c = series([
        [...master, ...properties],
        [original, 'PERCENT-COMPLETE:12'],
      ]);
      final o = c.series.single.overrides.single;
      expect(o.component.metadata.url, isNull);
      expect(o.component.metadata.categoryGroups, isEmpty);
      expect(o.metadata.url, c.tasks.single.metadata.url);
      expect(o.metadata.comments.first.value, 'Första\nAndra');
      final raw = parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c))
          .series
          .single
          .overrides
          .single
          .component;
      expect(raw.metadata.contacts, isEmpty);
      expect(raw.percentComplete, 12);
    },
  );
  test(
    'explicit matching metadata retains presence and independent progress',
    () {
      final c = series([
        [...master, ...properties],
        [original, ...properties, 'STATUS:CANCELLED'],
      ]);
      final o = c.series.single.overrides.single;
      expect(o.component.metadata.comments.length, 2);
      expect(o.component.metadata.classification, 'PRIVATE');
      expect(o.component.status, IcalendarTaskStatus.cancelled);
      expect(o.component.percentComplete, isNull);
      expect(o.component.completed, isNull);
      expect(
        series([
          master,
          [original, 'CLASS:PUBLIC'],
        ]).series.single.overrides.single.component.metadata.classification,
        'PUBLIC',
      );
    },
  );
  test('different occurrence metadata or group shapes reject', () {
    for (final p in <List<String>>[
      ['URL:https://example.invalid/other'],
      ['CLASS:PUBLIC'],
      ['CATEGORIES;LANGUAGE=sv:Other'],
      [
        r'CATEGORIES;LANGUAGE=sv:Arbete\, möten',
        'CATEGORIES;LANGUAGE=sv:Planering',
        'CATEGORIES;LANGUAGE=en:Work,Work',
      ],
      ['COMMENT:Another'],
      ['CONTACT:Other desk'],
      [
        r'COMMENT;LANGUAGE=en;ALTREP="cid:note@example.invalid":Första\nAndra',
        'COMMENT:Another',
      ],
    ]) {
      expect(
        () => series([
          [...master, ...properties],
          [original, ...p],
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
        reason: p.first,
      );
    }
  });
  test('bounded HTTP links reject userinfo relative and other schemes', () {
    for (final uri in [
      'relative/path',
      'ftp://example.invalid/task',
      'https://user:password@example.invalid/task',
      'https:///missing',
      'https://example.invalid/%zz',
    ]) {
      expect(
        () => load(['URL:$uri']),
        rejects(IcalendarComponentError.invalidValue),
        reason: uri,
      );
    }
    expect(
      load(['URL:http://example.invalid/task']).tasks.single.metadata.url,
      'http://example.invalid/task',
    );
  });
  test(
    'classification scope rejects extension tokens and unknown parameters',
    () {
      for (final value in ['X-SECRET', 'CUSTOM', 'PUBLIC PRIVATE']) {
        expect(
          () => load(['CLASS:$value']),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      for (final p in [
        'CLASS;LANGUAGE=en:PRIVATE',
        'URL;VALUE=URI:https://example.invalid',
        'CATEGORIES;ALTREP="https://example.invalid":Work',
        'CONTACT;X-OTHER=value:Desk',
        'COMMENT;LANGUAGE=en;LANGUAGE=sv:Note',
      ]) {
        expect(() => load([p]), throwsA(isA<IcalendarComponentException>()));
      }
    },
  );
  test(
    'malformed annotation category escaping and duplicate singleton rejects',
    () {
      for (final p in [
        'CATEGORIES;LANGUAGE=not_a_tag:Work',
        r'CATEGORIES:Bad\q',
        'CATEGORIES:',
        r'COMMENT:Bad\q',
        'CONTACT;ALTREP="relative":Desk',
      ]) {
        expect(() => load([p]), rejects(IcalendarComponentError.invalidValue));
      }
      for (final p in ['CLASS:PRIVATE', 'URL:https://example.invalid']) {
        expect(() => load([p, p]), rejects(IcalendarComponentError.duplicate));
      }
    },
  );
  test(
    'per-component metadata cardinality limits and shared text budgets reject',
    () {
      for (final p in [
        List.filled(65, 'CATEGORIES:Work'),
        List.filled(33, 'COMMENT:Note'),
        List.filled(33, 'CONTACT:Desk'),
        ['COMMENT:${'a' * 4097}'],
        ['CONTACT:${'a' * 4097}'],
      ]) {
        expect(() => load(p), throwsA(isA<IcalendarComponentException>()));
      }
      const limits = IcalendarComponentLimits(maxTaskMetadataCodePoints: 60);
      expect(load(['COMMENT:${'a' * 20}'], limits: limits).tasks.length, 1);
      expect(
        () => parseIcalendarTaskCalendar(
          utf8.encode(
            file(
              events: [
                task(properties: ['COMMENT:${'a' * 20}']),
                task(
                  uid: 'other@example.invalid',
                  properties: ['CONTACT:${'b' * 20}'],
                ),
              ],
            ),
          ),
          limits: limits,
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
  test('unsupported alarms and private extensions still reject', () {
    for (final p in ['X-TASK:value']) {
      expect(
        () => load([...properties, p]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
    expect(
      () => load([
        ...properties,
        'BEGIN:VALARM',
        'ACTION:DISPLAY',
        'TRIGGER:-PT5M',
        'END:VALARM',
      ]),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
  });
}
