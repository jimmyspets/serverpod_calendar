import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/scheduling_fixtures.dart';

void main() {
  test(
    'reply statuses retain code spelling, escaped text, groups and empty data',
    () {
      final source = message('REPLY', [
        ...minimal('REPLY'),
        r'REQUEST-STATUS;LANGUAGE=en:02.008.000;Fallback\, used\; details;RRULE:FREQ=WEEKLY\;INTERVAL=2',
        r'REQUEST-STATUS:3.1;Bad input\nTry again;',
        'REQUEST-STATUS:5.42.9;Uninterpreted future code',
        'REQUEST-STATUS:2.0;',
      ]);
      final value = load(source),
          statuses = value.events.single.requestStatuses;
      expect(statuses, hasLength(4));
      expect(statuses.first.code, '02.008.000');
      expect(statuses.first.levels, [2, 8, 0]);
      expect(statuses.first.description, 'Fallback, used; details');
      expect(statuses.first.extraData, 'RRULE:FREQ=WEEKLY;INTERVAL=2');
      expect(statuses.first.language, 'en');
      expect(statuses[1].description, 'Bad input\nTry again');
      expect(statuses[1].extraData, '');
      expect(statuses[2].extraData, isNull);
      expect(statuses[2].levels, [5, 42, 9]);
      expect(statuses.last.description, '');
      expect(
        utf8
            .decode(serializeIcalendarSchedulingMessage(value))
            .replaceAll('\r\n ', ''),
        source,
      );
      expect(() => statuses.clear(), throwsUnsupportedError);
      expect(() => statuses.first.levels.clear(), throwsUnsupportedError);
    },
  );
  for (final method in ['PUBLISH', 'REQUEST', 'CANCEL']) {
    test('$method rejects REQUEST-STATUS instead of interpreting it', () {
      expect(
        () => load(
          message(method, [...minimal(method), 'REQUEST-STATUS:2.0;Success']),
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    });
  }
  for (final raw in [
    '2',
    '2.0.0.0',
    '-2.0',
    '+2.0',
    '2.',
    '2..0',
    '2.0 ',
    '٢.0',
    '2147483648.0',
    '2.0;Description;Extra;Unescaped',
    r'2.0;Bad\x',
    '2.0;Bad,comma',
    '2.0;Trailing\\',
  ]) {
    test('invalid request-status $raw rejects', () {
      expect(
        () => load(
          message('REPLY', [
            ...minimal('REPLY'),
            raw.contains(';')
                ? 'REQUEST-STATUS:$raw'
                : 'REQUEST-STATUS:$raw;Text',
          ]),
        ),
        rejects(),
      );
    });
  }
  test('status numeric/code/text/repetition bounds are explicit', () {
    final largest = load(
      message('REPLY', [
        ...minimal('REPLY'),
        'REQUEST-STATUS:2147483647.2147483647.2147483647;Max',
      ]),
    );
    expect(largest.events.single.requestStatuses.single.levels, [
      2147483647,
      2147483647,
      2147483647,
    ]);
    expect(
      () => load(
        message('REPLY', [
          ...minimal('REPLY'),
          'REQUEST-STATUS:${'0' * 33}.0;Long',
        ]),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        message('REPLY', [
          ...minimal('REPLY'),
          'REQUEST-STATUS:2.0;${'x' * 4097}',
        ]),
      ),
      rejects(),
    );
    expect(
      load(
        message('REPLY', [
          ...minimal('REPLY'),
          ...List.filled(32, 'REQUEST-STATUS:2.0;Success'),
        ]),
      ).events.single.requestStatuses,
      hasLength(32),
    );
    expect(
      () => load(
        message('REPLY', [
          ...minimal('REPLY'),
          ...List.filled(33, 'REQUEST-STATUS:2.0;Success'),
        ]),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  for (final method in ['PUBLISH', 'REQUEST', 'REPLY', 'CANCEL']) {
    test(
      '$method retains optional priority, exact GEO and descriptive resource groups',
      () {
        final absent = load(message(method, minimal(method)));
        expect(absent.events.single.priority, isNull);
        expect(absent.events.single.geographicPosition, isNull);
        expect(absent.events.single.resources, isEmpty);
        expect(absent.events.single.requestStatuses, isEmpty);
        final source = message(method, [
          ...minimal(method),
          'PRIORITY:+0009',
          'GEO:+37.386013000000000001;-122.082932',
          r'RESOURCES;LANGUAGE=en;ALTREP="https://example.invalid/resources":Room\, west,Projector',
          'RESOURCES;LANGUAGE=sv:Sal,Projektor',
          'RESOURCES:',
        ]);
        final value = load(source),
            position = value.events.single.geographicPosition!;
        expect(value.events.single.priority, 9);
        expect(position.latitudeText, '+37.386013000000000001');
        expect(position.longitudeText, '-122.082932');
        expect(position.latitude, closeTo(37.386013, 0.0000001));
        expect(position.longitude, closeTo(-122.082932, 0.0000001));
        expect(value.events.single.resources, hasLength(3));
        expect(value.events.single.resources.first.values, [
          'Room, west',
          'Projector',
        ]);
        expect(
          value.events.single.resources.first.alternativeUri,
          'https://example.invalid/resources',
        );
        expect(value.events.single.resources[1].language, 'sv');
        expect(value.events.single.resources.last.values, ['']);
        expect(
          utf8
              .decode(serializeIcalendarSchedulingMessage(value))
              .replaceAll('\r\n ', ''),
          source,
        );
        expect(
          () => value.events.single.resources.clear(),
          throwsUnsupportedError,
        );
        expect(
          () => value.events.single.resources.first.values.clear(),
          throwsUnsupportedError,
        );
      },
    );
  }
  test('GEO exact decimal comparisons reject values binary doubles round to boundaries', () {
    for (final raw in [
      '90;180',
      '-90.000;-180.000',
      '+00.000;-000.000',
      '89.999999999999999999;179.999999999999999999',
    ]) {
      expect(
        load(message('REQUEST', [...minimal('REQUEST'), 'GEO:$raw']))
            .events
            .single
            .geographicPosition,
        isNotNull,
      );
    }
    for (final raw in [
      '90.000000000000000001;0',
      '0;180.000000000000000001',
      '-90.000000000000000001;0',
      '0;-180.000000000000000001',
      '91;0',
      '0;181',
      'NaN;0',
      'Infinity;0',
      '9e1;0',
      '.5;0',
      '90.;0',
      '1;2;3',
      '1,2',
      '1; 2',
    ]) {
      expect(
        () => load(message('REQUEST', [...minimal('REQUEST'), 'GEO:$raw'])),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
    expect(
      () => load(
        message('REQUEST', [...minimal('REQUEST'), 'GEO:0.${'0' * 63};0']),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test(
    'priority has no manufactured default and rejects values outside 0-9',
    () {
      for (var n = 0; n <= 9; n++) {
        expect(
          load(message('REQUEST', [...minimal('REQUEST'), 'PRIORITY:$n']))
              .events
              .single
              .priority,
          n,
        );
      }
      for (final raw in ['-1', '10', '1.0', 'HIGH', '999999999999999999999']) {
        expect(
          () => load(
            message('REQUEST', [...minimal('REQUEST'), 'PRIORITY:$raw']),
          ),
          rejects(),
        );
      }
    },
  );
  test('resources preserve groups but cap groups, values and label size', () {
    expect(
      load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          ...List.filled(32, 'RESOURCES:Room'),
        ]),
      ).events.single.resources,
      hasLength(32),
    );
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          ...List.filled(33, 'RESOURCES:Room'),
        ]),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'RESOURCES:${List.filled(64, 'Room').join(',')}',
        ]),
      ).events.single.resources.single.values,
      hasLength(64),
    );
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'RESOURCES:${List.filled(64, 'Room').join(',')}',
          'RESOURCES:Extra',
        ]),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        message('REQUEST', [...minimal('REQUEST'), 'RESOURCES:${'x' * 4097}']),
      ),
      rejects(),
    );
  });
  test(
    'parameter, cardinality and aggregate limits fail before returning payload',
    () {
      for (final property in [
        'REQUEST-STATUS;ALTREP="https://example.invalid":2.0;Success',
        'REQUEST-STATUS;LANGUAGE=en;LANGUAGE=sv:2.0;Success',
        'REQUEST-STATUS;LANGUAGE=bad_tag:2.0;Success',
        'GEO;X-UNKNOWN=value:1;2',
        'PRIORITY;X-UNKNOWN=value:1',
        'RESOURCES;ALTREP=relative:Room',
        'RESOURCES;LANGUAGE=bad_tag:Room',
        r'RESOURCES:Bad\x',
        'RESOURCES;X-UNKNOWN=value:Room',
      ]) {
        expect(
          () => load(message('REPLY', [...minimal('REPLY'), property])),
          rejects(),
        );
      }
      for (final property in ['GEO:1;2', 'PRIORITY:1']) {
        expect(
          () =>
              load(message('REPLY', [...minimal('REPLY'), property, property])),
          rejects(IcalendarComponentError.duplicate),
        );
      }
      expect(
        load(
          message('REPLY', minimal('REPLY')),
          limits: const IcalendarComponentLimits(
            maxEventMetadataCodePoints: 128,
          ),
        ),
        isNotNull,
      );
      for (final property in [
        'REQUEST-STATUS:2.0;${'x' * 200}',
        'RESOURCES:${'x' * 200}',
      ]) {
        expect(
          () => load(
            message('REPLY', [...minimal('REPLY'), property]),
            limits: const IcalendarComponentLimits(
              maxEventMetadataCodePoints: 128,
            ),
          ),
          rejects(IcalendarComponentError.limitExceeded),
        );
      }
    },
  );
  test('standalone event descriptive profile is explicit; result codes stay scheduling-only', () {
    for (final property in ['PRIORITY:1', 'GEO:1;2', 'RESOURCES:Room']) {
      final source = message('REQUEST', [
        ...minimal('REQUEST'),
        property,
      ]).replaceFirst('METHOD:REQUEST\r\n', '');
      expect(
        parseIcalendarEventCalendar(utf8.encode(source)).events,
        hasLength(1),
      );
    }
    final source = message('REPLY', [
      ...minimal('REPLY'),
      'REQUEST-STATUS:2.0;Success',
    ]).replaceFirst('METHOD:REPLY\r\n', '');
    expect(
      () => parseIcalendarEventCalendar(utf8.encode(source)),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
  });
}
