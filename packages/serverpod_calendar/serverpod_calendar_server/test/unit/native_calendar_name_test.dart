import 'package:test/test.dart';
import 'package:serverpod_calendar_server/src/native_calendar_name.dart';

void main() {
  const emoji = '\u{1f600}';
  test('names trim outside and preserve Unicode spelling', () {
    expect(
      normalizeCalendarDisplayName('  A  e\u0301 $emoji  '),
      'A  e\u0301 $emoji',
    );
    expect(normalizeCalendarDisplayName(emoji * 256), emoji * 256);
    expect(
      () => normalizeCalendarDisplayName(emoji * 257),
      throwsArgumentError,
    );
  });
  test('invalid text is rejected before trimming', () {
    for (final name in [
      '',
      '  ',
      '\nA',
      'A\r',
      'A\u0085',
      'A\u2028',
      'A\u2029',
      'A\u0000',
      String.fromCharCode(0xd800),
      String.fromCharCode(0xdc00),
      'a' * 4097,
    ]) {
      expect(
        () => normalizeCalendarDisplayName(name),
        throwsArgumentError,
        reason: name.codeUnits.toString(),
      );
    }
  });
  test('opaque references preserve identity and enforce UTF8 byte limits', () {
    validateCalendarOpaqueText(' \u00e9 ', maxUtf8Bytes: 4);
    validateCalendarOpaqueText(emoji, maxUtf8Bytes: 4);
    for (final value in [
      '',
      '${emoji}a',
      'a\u0000',
      String.fromCharCode(0xd800),
    ]) {
      expect(
        () => validateCalendarOpaqueText(value, maxUtf8Bytes: 4),
        throwsArgumentError,
      );
    }
  });
}
