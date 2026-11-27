import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/availability_fixtures.dart';

Matcher rejects(IcalendarComponentError kind) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);
IcalendarAvailabilityExtensionRegistry registry({
  bool Function(String)? validate,
  Iterable<IcalendarAvailabilityExtensionContext> contexts =
      IcalendarAvailabilityExtensionContext.values,
}) => IcalendarAvailabilityExtensionRegistry([
  IcalendarAvailabilityExtensionRegistration(
    name: 'X-LABEL',
    contexts: contexts,
    validateText: validate ?? ((_) => true),
  ),
]);
IcalendarAvailabilityCalendar metadata(
  List<String> values, {
  IcalendarAvailabilityExtensionRegistry? extensions,
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => read(
  [definition(extra: values)],
  extensions: extensions,
  limits: limits,
);
String hours(List<String> values, {bool override = false}) => opening(
  uid: 'hours',
  timing: override ? 'DTSTART:20261023T100000Z' : 'DTSTART:20261022T090000Z',
  extra: [
    'DURATION:PT1H',
    if (override)
      'RECURRENCE-ID:20261023T090000Z'
    else
      'RRULE:FREQ=DAILY;COUNT=2',
    ...values,
  ],
);

void main() {
  test('definition organizer links class and repeated text survive source round trip', () {
    final c = metadata([
      'ORGANIZER;CN="Synthetic ^\'Publisher^\'";LANGUAGE=en;DIR="ldap://example.invalid/people":mailto:publisher@example.invalid',
      'URL:https://example.invalid/calendar',
      'CLASS:PRIVATE',
      'CATEGORIES;LANGUAGE=en:Work,Meetings',
      'CATEGORIES;LANGUAGE=sv:Arbete',
      'COMMENT;LANGUAGE=en;ALTREP="cid:comment@example.invalid":Note',
      'CONTACT;LANGUAGE=sv;ALTREP="https://example.invalid/contact":Help desk',
    ]);
    final m = c.definitions.single.metadata;
    expect(m.organizer!.address, 'mailto:publisher@example.invalid');
    expect(m.organizer!.commonName, 'Synthetic "Publisher"');
    expect(m.organizer!.language, 'en');
    expect(m.organizer!.directoryUri, 'ldap://example.invalid/people');
    expect(m.url, 'https://example.invalid/calendar');
    expect(m.classification, 'PRIVATE');
    expect(m.categoryGroups.map((g) => g.language), ['en', 'sv']);
    expect(m.comments.single.alternativeUri, 'cid:comment@example.invalid');
    expect(m.contacts.single.value, 'Help desk');
    final bytes = serializeIcalendarAvailabilityCalendar(c);
    final copy = parseIcalendarAvailabilityCalendar(bytes);
    expect(serializeIcalendarAvailabilityCalendar(copy), bytes);
    expect(
      copy.definitions.single.metadata.organizer!.commonName,
      m.organizer!.commonName,
    );
  });
  test(
    'category lists split escaped commas and preserve duplicates and groups',
    () {
      final m = metadata([
        r'CATEGORIES;LANGUAGE=en:A\,B,C\\,D\;E',
        r'CATEGORIES:A\,B,A\,B',
      ]).definitions.single.metadata;
      expect(m.categoryGroups.first.values, ['A,B', r'C\', 'D;E']);
      expect(m.categoryGroups.last.values, ['A,B', 'A,B']);
      expect(m.categoryGroups.last.language, isNull);
      expect(() => m.categoryGroups.clear(), throwsUnsupportedError);
      expect(
        () => m.categoryGroups.first.values.clear(),
        throwsUnsupportedError,
      );
      expect(m.categoryGroups.first.source.value, r'A\,B,C\\,D\;E');
    },
  );
  test('comments and CONTACT retain separate annotation positions and decoded text', () {
    final m = metadata([
      r'COMMENT:First\nline',
      'COMMENT;LANGUAGE=sv:Andra',
      r'CONTACT:Desk\, ext 1',
      'CONTACT;ALTREP="cid:card@example.invalid":Other',
    ]).definitions.single.metadata;
    expect(m.comments.map((v) => v.value), ['First\nline', 'Andra']);
    expect(m.comments.map((v) => v.language), [null, 'sv']);
    expect(m.contacts.first.value, 'Desk, ext 1');
    expect(m.contacts.last.alternativeUri, 'cid:card@example.invalid');
    expect(() => m.comments.clear(), throwsUnsupportedError);
    expect(() => m.contacts.clear(), throwsUnsupportedError);
  });
  test('organizer CAL-ADDRESS is URI data without TEXT decoding or identity approval', () {
    for (final address in [
      'urn:synthetic:publisher',
      'mailto:a%2Cb@example.invalid',
      'https://example.invalid/user',
    ]) {
      expect(
        metadata(['ORGANIZER:$address'])
            .definitions
            .single
            .metadata
            .organizer!
            .address,
        address,
      );
    }
    for (final property in [
      r'ORGANIZER:mailto:a\,b@example.invalid',
      'ORGANIZER:relative',
      'ORGANIZER:https://user:pass@example.invalid/p',
      'ORGANIZER:mailto:a%ZZ@example.invalid',
      'ORGANIZER;LANGUAGE=en:mailto:a@example.invalid',
    ]) {
      expect(
        () => metadata([property]),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
  });
  test('organizer parameter contexts and cardinality are strict', () {
    for (final property in [
      'ORGANIZER;SENT-BY="mailto:delegate@example.invalid":mailto:a@example.invalid',
      'ORGANIZER;ALTREP="cid:x":mailto:a@example.invalid',
      'ORGANIZER;VALUE=CAL-ADDRESS:mailto:a@example.invalid',
      'ORGANIZER;CN=One;CN=Two:mailto:a@example.invalid',
      'ORGANIZER;CN=One;LANGUAGE=not_a_tag:mailto:a@example.invalid',
      'ORGANIZER;DIR="relative":mailto:a@example.invalid',
    ]) {
      expect(
        () => metadata([property]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    for (final property in [
      'ORGANIZER:mailto:a@example.invalid',
      'URL:https://example.invalid',
      'CLASS:PUBLIC',
    ]) {
      expect(
        () => metadata([property, property]),
        rejects(IcalendarComponentError.duplicate),
      );
    }
  });
  test('URL and classification preserve source with bounded native-compatible values', () {
    expect(
      metadata(['URL:https://example.invalid/%41', 'CLASS:confidential'])
          .definitions
          .single
          .metadata
          .classification,
      'CONFIDENTIAL',
    );
    expect(metadata([]).definitions.single.metadata.classification, isNull);
    for (final property in [
      'URL:ftp://example.invalid/data',
      'URL:https://user:pass@example.invalid',
      'URL:https://example.invalid/%ZZ',
      'CLASS:X-CUSTOM',
      'CLASS:PUBLıC',
      'CLASS;LANGUAGE=en:PUBLIC',
    ]) {
      expect(
        () => metadata([property]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
  });
  test('definition-only properties never become opening metadata', () {
    for (final property in [
      'ORGANIZER:mailto:a@example.invalid',
      'URL:https://example.invalid',
      'CLASS:PRIVATE',
    ]) {
      expect(
        () => read([
          definition(
            openings: [
              opening(extra: ['DURATION:PT1H', property]),
            ],
          ),
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
  });
  test('trusted registry and contexts snapshot input collections', () {
    final contexts = {IcalendarAvailabilityExtensionContext.definition};
    final registration = IcalendarAvailabilityExtensionRegistration(
      name: 'X-LABEL',
      contexts: contexts,
      validateText: (_) => true,
    );
    final input = [registration];
    final r = IcalendarAvailabilityExtensionRegistry(input);
    contexts.clear();
    input.clear();
    expect(
      metadata([
        'X-LABEL:One',
      ], extensions: r).definitions.single.metadata.extensions.single.value,
      'One',
    );
    expect(() => registration.contexts.clear(), throwsUnsupportedError);
    expect(
      () => read([
        definition(
          openings: [
            opening(extra: ['DURATION:PT1H', 'X-LABEL:One']),
          ],
        ),
      ], extensions: r),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
  });
  test(
    'registry rejects invalid duplicate names and excessive registrations',
    () {
      IcalendarAvailabilityExtensionRegistration item(String name) =>
          IcalendarAvailabilityExtensionRegistration(
            name: name,
            contexts: IcalendarAvailabilityExtensionContext.values,
            validateText: (_) => true,
          );
      for (final name in [
        'UID',
        'X-',
        'X--A',
        'X-A-',
        'X-Å',
        'X-${'a' * 63}',
      ]) {
        expect(() => item(name), throwsArgumentError);
      }
      expect(
        () => IcalendarAvailabilityExtensionRegistration(
          name: 'X-A',
          contexts: [],
          validateText: (_) => true,
        ),
        throwsArgumentError,
      );
      expect(
        () =>
            IcalendarAvailabilityExtensionRegistry([item('X-A'), item('x-a')]),
        throwsArgumentError,
      );
      expect(
        () => IcalendarAvailabilityExtensionRegistry(
          List.generate(33, (i) => item('X-A$i')),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'registered decoded TEXT validates once and raw extension source survives',
    () {
      final seen = <String>[];
      final r = registry(
        validate: (value) {
          seen.add(value);
          return value == 'A,B\nC';
        },
      );
      final c = metadata([r'x-label:A\,B\nC'], extensions: r);
      expect(seen, ['A,B\nC']);
      final v = c.definitions.single.metadata.extensions.single;
      expect(v.name, 'x-label');
      expect(v.source.value, r'A\,B\nC');
      expect(v.value, 'A,B\nC');
      expect(
        () => c.definitions.single.metadata.extensions.clear(),
        throwsUnsupportedError,
      );
      final bytes = serializeIcalendarAvailabilityCalendar(c);
      expect(
        () => parseIcalendarAvailabilityCalendar(bytes),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
      expect(
        parseIcalendarAvailabilityCalendar(
          bytes,
          extensions: r,
        ).definitions.single.metadata.extensions.single.value,
        v.value,
      );
    },
  );
  test('false validation and unavailable validators have distinct sanitized errors', () {
    expect(
      () => metadata([
        'X-LABEL:private',
      ], extensions: registry(validate: (_) => false)),
      rejects(IcalendarComponentError.invalidValue),
    );
    try {
      metadata(
        ['X-LABEL:private'],
        extensions: registry(
          validate: (_) => throw StateError('private value'),
        ),
      );
      fail('Expected rejection');
    } on IcalendarComponentException catch (e) {
      expect(e.kind, IcalendarComponentError.extensionValidationUnavailable);
      expect(
        e.toString(),
        'IcalendarComponentException(extensionValidationUnavailable)',
      );
    }
  });
  test('unknown IANA/private names duplicate private properties and parameters reject', () {
    for (final values in [
      ['X-OTHER:value'],
      ['COLOR:blue'],
      ['X-LABEL:A', 'x-label:A'],
      ['X-LABEL;LANGUAGE=en:A'],
      ['X-LABEL;VALUE=TEXT:A'],
    ]) {
      expect(
        () => metadata(values, extensions: registry()),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    expect(
      () => metadata(['X-LABEL:A']),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
  });
  test(
    'opening metadata preserves actual source and omitted override inheritance',
    () {
      final values = [
        'CATEGORIES;LANGUAGE=en:Work',
        'COMMENT:One',
        'CONTACT:Desk',
        'X-LABEL:Public',
      ];
      final c = read([
        definition(openings: [hours(values), hours([], override: true)]),
      ], extensions: registry());
      final series = c.definitions.single.openings.single;
      expect(series.master.source.canonicalName, 'AVAILABLE');
      expect(
        series.master.source.entries.whereType<IcalendarSyntaxProperty>().any(
          (p) => p.canonicalName == 'CATEGORIES',
        ),
        isTrue,
      );
      expect(series.master.metadata.categoryGroups.single.values, ['Work']);
      expect(series.overrides.single.metadata.categoryGroups, isEmpty);
      expect(expand(c).single.openings.length, 1);
      final bytes = serializeIcalendarAvailabilityCalendar(c);
      expect(utf8.decode(bytes), contains('CONTACT:Desk'));
      expect(
        parseIcalendarAvailabilityCalendar(
          bytes,
          extensions: registry(),
        ).definitions.single.openings.single.overrides.length,
        1,
      );
    },
  );
  test('identical supplied grouped metadata is valid on timing overrides', () {
    final values = [
      'CATEGORIES;LANGUAGE=en:A,B',
      'CATEGORIES;LANGUAGE=sv:C',
      'COMMENT;LANGUAGE=en:One',
      'CONTACT;ALTREP="cid:x":Desk',
      'X-LABEL:One',
    ];
    final c = read([
      definition(openings: [hours(values), hours(values, override: true)]),
    ], extensions: registry());
    expect(
      c
          .definitions
          .single
          .openings
          .single
          .overrides
          .single
          .metadata
          .contacts
          .single
          .alternativeUri,
      'cid:x',
    );
  });
  test(
    'group and annotation differences cannot be hidden by timing overrides',
    () {
      final master = [
        'CATEGORIES;LANGUAGE=en:A,B',
        'COMMENT;LANGUAGE=en:One',
        'CONTACT:Desk',
        'X-LABEL:One',
      ];
      for (final changed in [
        ['CATEGORIES;LANGUAGE=en:B,A'],
        ['CATEGORIES;LANGUAGE=sv:A,B'],
        ['COMMENT;LANGUAGE=sv:One'],
        ['CONTACT;ALTREP="cid:new":Desk'],
        ['X-LABEL:Two'],
      ]) {
        expect(
          () => read([
            definition(
              openings: [hours(master), hours(changed, override: true)],
            ),
          ], extensions: registry()),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
    },
  );
  test(
    'category/comment/contact grammar and annotation contexts remain explicit',
    () {
      for (final property in [
        'CATEGORIES:',
        'CATEGORIES:A,',
        'CATEGORIES;ALTREP="cid:x":A',
        'CATEGORIES;LANGUAGE=en;LANGUAGE=sv:A',
        r'CATEGORIES:A\x',
        'COMMENT;VALUE=TEXT:A',
        'CONTACT;CN=Desk:A',
        'CONTACT;ALTREP="relative":Desk',
      ]) {
        expect(
          () => metadata([property]),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
    },
  );
  test(
    'raw repeated values and codepoint bounds reject before normalization',
    () {
      expect(
        metadata(['CATEGORIES:${List.filled(64, 'A').join(',')}'])
            .definitions
            .single
            .metadata
            .categoryGroups
            .single
            .values
            .length,
        64,
      );
      expect(
        () => metadata(['CATEGORIES:${List.filled(65, 'A').join(',')}']),
        rejects(IcalendarComponentError.limitExceeded),
      );
      for (final name in ['COMMENT', 'CONTACT']) {
        expect(metadata(List.filled(32, '$name:')).definitions.length, 1);
        expect(
          () => metadata(List.filled(33, '$name:')),
          rejects(IcalendarComponentError.limitExceeded),
        );
      }
      expect(
        metadata(
          ['CATEGORIES:${'🌟' * 256}'],
          limits: const IcalendarComponentLimits(
            maxAvailabilityMetadataCodePoints: 256,
          ),
        ).definitions.length,
        1,
      );
      expect(
        () => metadata(['CATEGORIES:${'🌟' * 257}']),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('aggregate codepoint work includes annotations duplicates and every component', () {
    final values = ['SUMMARY;LANGUAGE=en:a', 'CATEGORIES:c', 'COMMENT:b'];
    expect(
      metadata(
        values,
        limits: const IcalendarComponentLimits(
          maxAvailabilityMetadataCodePoints: 5,
        ),
      ).definitions.length,
      1,
    );
    expect(
      () => metadata(
        values,
        limits: const IcalendarComponentLimits(
          maxAvailabilityMetadataCodePoints: 4,
        ),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => read(
        [
          definition(extra: ['SUMMARY:ab']),
          definition(uid: 'other', extra: ['SUMMARY:ab']),
        ],
        limits: const IcalendarComponentLimits(
          maxAvailabilityMetadataCodePoints: 3,
        ),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => metadata(
        ['CATEGORIES:A', 'CATEGORIES:A'],
        limits: const IcalendarComponentLimits(
          maxAvailabilityMetadataCodePoints: 1,
        ),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    var calls = 0;
    expect(
      () => metadata(
        ['X-LABEL:A'],
        extensions: registry(
          validate: (_) {
            calls++;
            return true;
          },
        ),
        limits: const IcalendarComponentLimits(
          maxAvailabilityMetadataCodePoints: 1,
        ),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(calls, 0);
  });
  test(
    'metadata leaves source timing and core composition inputs unchanged',
    () {
      final plain = read([
        definition(
          openings: [
            opening(extra: ['DURATION:PT1H']),
          ],
        ),
      ]);
      final rich = read([
        definition(
          extra: [
            'CLASS:PUBLIC',
            'URL:https://example.invalid',
            'ORGANIZER:urn:synthetic:publisher',
          ],
          openings: [
            opening(
              extra: ['DURATION:PT1H', 'CATEGORIES:Public', 'CONTACT:Desk'],
            ),
          ],
        ),
      ]);
      final a = expand(plain).single, b = expand(rich).single;
      expect(b.priority, a.priority);
      expect(b.closedKind, a.closedKind);
      expect(b.openings, a.openings);
      expect(
        compose(rich).map((v) => v.kind),
        compose(plain).map((v) => v.kind),
      );
    },
  );
  test(
    'late invalid extension exposes no partial calendar or private payload',
    () {
      IcalendarAvailabilityCalendar? result;
      try {
        result = read([
          definition(extra: ['COMMENT:Valid']),
          definition(uid: 'private', extra: ['X-LABEL:private']),
        ], extensions: registry(validate: (value) => value != 'private'));
        fail('Expected rejection');
      } on IcalendarComponentException catch (e) {
        expect(e.toString(), 'IcalendarComponentException(invalidValue)');
      }
      expect(result, isNull);
    },
  );
}
