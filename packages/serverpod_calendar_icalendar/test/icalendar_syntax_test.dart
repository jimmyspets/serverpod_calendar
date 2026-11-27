import 'dart:convert';
import 'dart:math';

import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

List<int> wire(String text) => utf8.encode(text);
IcalendarSyntaxDocument parse(
  String text, {
  IcalendarSyntaxLimits limits = const IcalendarSyntaxLimits(),
}) => parseIcalendarSyntax(wire(text), limits: limits);
String calendar(String lines) =>
    'BEGIN:VCALENDAR\r\n$lines'
    'END:VCALENDAR\r\n';
IcalendarSyntaxProperty property(IcalendarSyntaxDocument d, [int index = 0]) =>
    d.components.single.entries[index] as IcalendarSyntaxProperty;
Matcher error(IcalendarSyntaxError kind, [String? limit]) => throwsA(
  isA<IcalendarSyntaxException>()
      .having((e) => e.kind, 'kind', kind)
      .having((e) => e.limit, 'limit', limit),
);
Object tree(IcalendarSyntaxDocument d) {
  Object entry(IcalendarSyntaxEntry e) => switch (e) {
    IcalendarSyntaxComponent() => [e.name, e.entries.map(entry).toList()],
    IcalendarSyntaxProperty() => [
      e.name,
      e.value,
      e.parameters.map((p) => [p.name, p.values]).toList(),
    ],
  };
  return d.components.map(entry).toList();
}

void main() {
  test('generated Unicode TEXT and parameter trees preserve meaning deterministically', () {
    final random = Random(6868);
    const alphabet = [
      'a',
      'Å',
      '漢',
      '😀',
      ',',
      ';',
      ':',
      '^',
      "'",
      '"',
      '\\',
      '\t',
      '\n',
    ];
    for (var n = 0; n < 200; n++) {
      String value() => List.generate(
        random.nextInt(120),
        (_) => alphabet[random.nextInt(alphabet.length)],
      ).join();
      final text = value(), parameter = value();
      expect(decodeIcalendarText(encodeIcalendarText(text)), text);
      expect(
        decodeIcalendarParameter(encodeIcalendarParameter(parameter)),
        parameter,
      );
      final d = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty(
            'SUMMARY',
            encodeIcalendarText(text),
            parameters: [
              IcalendarSyntaxParameter('X-P', [parameter, '', parameter]),
            ],
          ),
          IcalendarSyntaxComponent('X-CHILD', [
            IcalendarSyntaxProperty('X-RAW', 'a:raw;value,without-type'),
          ]),
        ]),
      ]);
      final encoded = serializeIcalendarSyntax(d);
      final parsed = parseIcalendarSyntax(encoded);
      expect(tree(parsed), tree(d));
      expect(serializeIcalendarSyntax(parsed), encoded);
    }
  });
  test(
    'arbitrary byte-position folds preserve complete UTF-8 logical lines',
    () {
      final text = '😀é漢字' * 40;
      final raw = wire('SUMMARY:$text');
      for (var stride = 1; stride <= 13; stride++) {
        final bytes = <int>[...wire('BEGIN:VCALENDAR\r\n')];
        for (var i = 0; i < raw.length; i++) {
          if (i > 0 && i % stride == 0) bytes.addAll([13, 10, 9]);
          bytes.add(raw[i]);
        }
        bytes.addAll(wire('\r\nEND:VCALENDAR\r\n'));
        expect(property(parseIcalendarSyntax(bytes)).value, text);
      }
    },
  );
  test('blank physical lines are not repaired by a following continuation', () {
    expect(
      () => parse(calendar('\r\n SUMMARY:value\r\n')),
      error(IcalendarSyntaxError.contentLine),
    );
  });
  test(
    'ordered immutable syntax retains repeated unknown names and raw values',
    () {
      final d = parse(
        calendar(
          'VERSION:2.0\r\nX-PRIVATE:a\\,b\r\nSUMMARY:One\r\nSUMMARY:Two\r\nBEGIN:VEVENT\r\nX-RAW;X-P=a;X-P=b:raw:semi;comma,\\q\r\nEND:VEVENT\r\n',
        ),
      );
      expect(property(d, 1).value, r'a\,b');
      expect(property(d, 3).value, 'Two');
      final child =
          d.components.single.entries.last as IcalendarSyntaxComponent;
      final p = child.entries.single as IcalendarSyntaxProperty;
      expect(p.parameters.map((v) => v.values.single), ['a', 'b']);
      expect(p.value, r'raw:semi;comma,\q');
      expect(() => d.components.clear(), throwsUnsupportedError);
      expect(() => child.entries.clear(), throwsUnsupportedError);
      expect(() => p.parameters.clear(), throwsUnsupportedError);
      expect(() => p.parameters.first.values.clear(), throwsUnsupportedError);
      expect(tree(parseIcalendarSyntax(serializeIcalendarSyntax(d))), tree(d));
    },
  );
  test(
    'component boundary matching is case insensitive but spelling retained',
    () {
      final d = parse('begin:vcalendar\r\nx-label:MiXeD\r\nend:VCALENDAR\r\n');
      expect(d.components.single.name, 'vcalendar');
      expect(property(d).name, 'x-label');
      expect(property(d).canonicalName, 'X-LABEL');
      expect(property(d).value, 'MiXeD');
    },
  );
  test('multiple balanced roots are syntax not domain approval', () {
    expect(
      parse('${calendar('')}BEGIN:X-UNKNOWN\r\nEND:X-UNKNOWN\r\n').components,
      hasLength(2),
    );
  });
  test('unfold removes exactly one space or tab and preserves subsequent whitespace', () {
    final d = parse(calendar('DESCRIPTION:One\r\n  Two\r\n\tThree\r\n'));
    expect(property(d).value, 'One TwoThree');
  });
  test('UTF-8 split inside a folded multibyte character is restored before decoding', () {
    final bytes = [
      ...wire('BEGIN:VCALENDAR\r\nSUMMARY:'),
      0xf0,
      0x9f,
      13,
      10,
      32,
      0x98,
      0x80,
      ...wire('\r\nEND:VCALENDAR\r\n'),
    ];
    expect(property(parseIcalendarSyntax(bytes)).value, '😀');
  });
  test('75 octets is an output recommendation not the hard input bound', () {
    expect(
      property(parse(calendar('SUMMARY:${'x' * 1000}\r\n'))).value.length,
      1000,
    );
  });
  test('quoted parameter delimiters and multiple values stay associated', () {
    final p = property(
      parse(
        calendar(
          'ATTENDEE;CN="A,B;C:D";MEMBER="mailto:a@example.invalid","mailto:b@example.invalid";X-EMPTY=,:mailto:c@example.invalid\r\n',
        ),
      ),
    );
    expect(p.parameters.first.values, ['A,B;C:D']);
    expect(p.parameters[1].values, [
      'mailto:a@example.invalid',
      'mailto:b@example.invalid',
    ]);
    expect(p.parameters[2].values, ['', '']);
  });
  test('parameter caret decoding is separate from literal backslashes and unknown pairs', () {
    final p = property(parse(calendar("X-P;CN=One^nTwo^^^'\\n^N^q^:v\r\n")));
    expect(p.parameters.single.values.single, "One\nTwo^\"\\n^N^q^");
    final d = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [p]),
    ]);
    expect(tree(parseIcalendarSyntax(serializeIcalendarSyntax(d))), tree(d));
  });
  test(
    'parameter output encodes LF quote and caret and quotes only when required',
    () {
      final d = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty(
            'X-P',
            'v',
            parameters: [
              IcalendarSyntaxParameter('CN', ['Åsa "A"\n^;comma,colon:']),
            ],
          ),
        ]),
      ]);
      final output = utf8.decode(serializeIcalendarSyntax(d));
      expect(output, contains('CN="Åsa ^\'A^\'^n^^;comma,colon:"'));
      expect(tree(parseIcalendarSyntax(serializeIcalendarSyntax(d))), tree(d));
    },
  );
  test('TEXT codecs preserve Unicode punctuation tabs and LF without guessing raw types', () {
    const text = 'Åsa; A,B\\C\nline: "quoted"\t😀';
    final escaped = encodeIcalendarText(text);
    expect(
      escaped,
      r'Åsa\; A\,B\\C\nline: "quoted"'
      '\t😀',
    );
    expect(decodeIcalendarText(escaped), text);
    expect(decodeIcalendarText(r'A\NB'), 'A\nB');
    expect(decodeIcalendarParameter(r'A\nB'), r'A\nB');
  });
  test(
    'TEXT lists retain escaped delimiters duplicates empty entries and order',
    () {
      final values = ['A,B', 'C;D', '', 'A,B', 'Back\\slash'];
      final result = decodeIcalendarTextList(encodeIcalendarTextList(values));
      expect(result, values);
      expect(() => result.clear(), throwsUnsupportedError);
      expect(decodeIcalendarTextList(''), ['']);
      expect(
        () => encodeIcalendarTextList([]),
        error(IcalendarSyntaxError.contentLine),
      );
    },
  );
  for (final value in [
    r'bad\q',
    r'bad\:',
    r'bad\',
    'unescaped,comma',
    'unescaped;semi',
  ]) {
    test(
      'invalid single TEXT escape or delimiter rejects: $value',
      () => expect(
        () => decodeIcalendarText(value),
        error(IcalendarSyntaxError.contentLine),
      ),
    );
  }
  test(
    'trailing TEXT list escape rejects rather than dropping the last value',
    () {
      expect(
        () => decodeIcalendarTextList(r'First,Last\'),
        error(IcalendarSyntaxError.contentLine),
      );
    },
  );
  test('decoded CR is rejected rather than silently normalized', () {
    expect(
      () => encodeIcalendarText('A\r\nB'),
      error(IcalendarSyntaxError.contentLine),
    );
    expect(
      () => encodeIcalendarParameter('A\rB'),
      error(IcalendarSyntaxError.contentLine),
    );
  });
  for (final text in [
    'BEGIN:VCALENDAR\nEND:VCALENDAR\n',
    'BEGIN:VCALENDAR\rEND:VCALENDAR\r',
    'BEGIN:VCALENDAR\r\nEND:VCALENDAR',
    'BEGIN:VCALENDAR\r\nSUMMARY:bad\nEND:VCALENDAR\r\n',
  ]) {
    test(
      'strict input requires CRLF and a final terminator: ${text.length}',
      () => expect(() => parse(text), error(IcalendarSyntaxError.lineEnding)),
    );
  }
  test('leading BOM malformed UTF-8 and non-octet input reject', () {
    expect(
      () => parseIcalendarSyntax([239, 187, 191, ...wire(calendar(''))]),
      error(IcalendarSyntaxError.byteOrderMark),
    );
    for (final bytes in [
      [0xff],
      [0xc0, 0xaf],
      [0xed, 0xa0, 0x80],
      [0xf4, 0x90, 0x80, 0x80],
    ]) {
      expect(
        () => parseIcalendarSyntax([
          ...wire('BEGIN:VCALENDAR\r\nSUMMARY:'),
          ...bytes,
          ...wire('\r\nEND:VCALENDAR\r\n'),
        ]),
        error(IcalendarSyntaxError.encoding),
      );
    }
    expect(
      () => parseIcalendarSyntax([256]),
      error(IcalendarSyntaxError.encoding),
    );
  });
  for (final lines in [
    '\r\n',
    'SUMMARY\r\n',
    'Bad.Name:value\r\n',
    'X;P="unfinished:value\r\n',
    'X;P="a"garbage:value\r\n',
    'X;P=a"b:value\r\n',
    'X;=a:value\r\n',
    'X;P:value\r\n',
    'X;P=a;:value\r\n',
    'X:\u0000\r\n',
  ]) {
    test(
      'malformed content line rejected: ${lines.hashCode}',
      () => expect(
        () => parse(calendar(lines)),
        error(IcalendarSyntaxError.contentLine),
      ),
    );
  }
  for (final text in [
    '',
    'SUMMARY:outside\r\n',
    ' BEGIN:VCALENDAR\r\n',
    'END:VCALENDAR\r\n',
    'BEGIN:VCALENDAR\r\nEND:VEVENT\r\n',
    'BEGIN:VCALENDAR\r\n',
    'BEGIN;X=P:VCALENDAR\r\nEND:VCALENDAR\r\n',
  ]) {
    test(
      'malformed structure or orphan fold rejected: ${text.hashCode}',
      () => expect(() => parse(text), throwsA(isA<IcalendarSyntaxException>())),
    );
  }
  test('late failure is atomic and diagnostics do not echo private values', () {
    const secret = 'Private-title-and-address@example.invalid';
    try {
      parse('${calendar('SUMMARY:$secret\r\n')}X:$secret\r\n');
      fail('Expected failure');
    } on IcalendarSyntaxException catch (e) {
      expect(e.toString(), isNot(contains(secret)));
      expect(e.line, 4);
    }
  });
  test('serializer folds at rune boundaries with continuation space included in 75 octets', () {
    for (var prefix = 0; prefix < 8; prefix++) {
      final d = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('DESCRIPTION', 'x' * prefix + '😀é漢字' * 80),
        ]),
      ]);
      final bytes = serializeIcalendarSyntax(d);
      final physical = utf8.decode(bytes).split('\r\n');
      for (final line in physical.where((v) => v.isNotEmpty)) {
        expect(utf8.encode(line).length, lessThanOrEqualTo(75));
      }
      expect(physical.where((v) => v.startsWith(' ')), isNotEmpty);
      expect(tree(parseIcalendarSyntax(bytes)), tree(d));
      expect(serializeIcalendarSyntax(d), bytes);
    }
  });
  test('constructor inputs are copied and serializer prevents line injection and surrogate replacement', () {
    final values = ['One'];
    final params = [IcalendarSyntaxParameter('X-P', values)];
    final entries = <IcalendarSyntaxEntry>[
      IcalendarSyntaxProperty('X', 'value', parameters: params),
    ];
    final components = [IcalendarSyntaxComponent('VCALENDAR', entries)];
    final d = IcalendarSyntaxDocument(components);
    values.clear();
    params.clear();
    entries.clear();
    components.clear();
    expect(property(d).parameters.single.values, ['One']);
    for (final p in [
      IcalendarSyntaxProperty('X', 'value\r\nINJECTED:yes'),
      IcalendarSyntaxProperty('BEGIN', 'VEVENT'),
      IcalendarSyntaxProperty('Bad.Name', 'v'),
      IcalendarSyntaxProperty('X', String.fromCharCode(0xd800)),
    ]) {
      expect(
        () => serializeIcalendarSyntax(
          IcalendarSyntaxDocument([
            IcalendarSyntaxComponent('VCALENDAR', [p]),
          ]),
        ),
        throwsA(isA<IcalendarSyntaxException>()),
      );
    }
  });
  test('raw input byte budget precedes decoding and unfolded/physical lengths are independent', () {
    expect(
      () => parse(
        calendar('SUMMARY:hello\r\n'),
        limits: const IcalendarSyntaxLimits(maxBytes: 10),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'inputBytes'),
    );
    expect(
      () => parse(
        calendar(''),
        limits: const IcalendarSyntaxLimits(maxPhysicalLineBytes: 5),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'physicalLineBytes'),
    );
    expect(
      () => parse(
        calendar('SUMMARY:${'x' * 15}\r\n ${'y' * 15}\r\n'),
        limits: const IcalendarSyntaxLimits(maxUnfoldedLineBytes: 25),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'unfoldedLineBytes'),
    );
  });
  test('component depth count line parameter value and name budgets reject before retention', () {
    expect(
      () => parse(
        'BEGIN:X\r\nBEGIN:Y\r\nEND:Y\r\nEND:X\r\n',
        limits: const IcalendarSyntaxLimits(maxDepth: 1),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'depth'),
    );
    expect(
      () => parse(
        calendar('') + calendar(''),
        limits: const IcalendarSyntaxLimits(maxComponents: 1),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'components'),
    );
    expect(
      () => parse(
        calendar('X:1\r\n'),
        limits: const IcalendarSyntaxLimits(maxLines: 2),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'lines'),
    );
    expect(
      () => parse(
        calendar('X;P=1;Q=2:v\r\n'),
        limits: const IcalendarSyntaxLimits(maxParameters: 1),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'parameters'),
    );
    expect(
      () => parse(
        calendar('X;P=a,b:v\r\n'),
        limits: const IcalendarSyntaxLimits(maxParameterValues: 1),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'parameterValues'),
    );
    expect(
      () => parse(
        calendar(''),
        limits: const IcalendarSyntaxLimits(maxNameBytes: 3),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'nameBytes'),
    );
  });
  test('serializer enforces output and structural budgets too', () {
    final d = parse(calendar('X;P=a,b:v\r\n'));
    expect(
      () => serializeIcalendarSyntax(
        d,
        limits: const IcalendarSyntaxLimits(maxBytes: 10),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'outputBytes'),
    );
    expect(
      () => serializeIcalendarSyntax(
        d,
        limits: const IcalendarSyntaxLimits(maxParameterValues: 1),
      ),
      error(IcalendarSyntaxError.limitExceeded, 'parameterValues'),
    );
    expect(
      () => serializeIcalendarSyntax(IcalendarSyntaxDocument([])),
      error(IcalendarSyntaxError.structure),
    );
    expect(
      () => decodeIcalendarTextList('a,b', maxValues: 1),
      error(IcalendarSyntaxError.limitExceeded, 'textValues'),
    );
  });
  test('invalid configured limits reject explicitly', () {
    expect(
      () =>
          parse(calendar(''), limits: const IcalendarSyntaxLimits(maxBytes: 0)),
      throwsArgumentError,
    );
    expect(
      () => serializeIcalendarSyntax(
        parse(calendar('')),
        limits: const IcalendarSyntaxLimits(maxDepth: 65),
      ),
      throwsArgumentError,
    );
  });
}
