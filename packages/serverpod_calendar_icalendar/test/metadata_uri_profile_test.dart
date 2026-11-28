import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

void main() {
  test('metadata URI profile accepts inert schemes without retrieval', () {
    for (final uri in [
      'cid:note@example.invalid',
      'urn:note:synthetic',
      'https://example.invalid/a%20b',
    ]) {
      expect(() => validateIcalendarMetadataUri(uri), returnsNormally);
    }
  });
  test('metadata URI errors reject credentials malformed escapes and ports without echo', () {
    for (final uri in [
      'https://user:PRIVATE@example.invalid/',
      'https://example.invalid/%oops',
      'https://example.invalid:invalid/',
      'relative',
      'https://example.invalid/line\n',
    ]) {
      expect(
        () => validateIcalendarMetadataUri(uri),
        throwsA(
          isA<IcalendarComponentException>()
              .having(
                (e) => e.kind,
                'kind',
                IcalendarComponentError.invalidValue,
              )
              .having(
                (e) => e.toString().contains('PRIVATE'),
                'private',
                false,
              ),
        ),
      );
    }
  });
  test('metadata URI length remains bounded', () {
    expect(
      () => validateIcalendarMetadataUri('urn:${'x' * 4097}'),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
}
