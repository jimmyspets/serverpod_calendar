@TestOn('vm')
library;

import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart';
import 'package:test/test.dart';

void main() {
  test('weak/list/wildcard If-None-Match and unmatched tags', () {
    expect(
      calendarFeedConditionalStatus('"current"', ifNoneMatch: ['W/"current"']),
      304,
    );
    expect(
      calendarFeedConditionalStatus(
        '"current"',
        ifNoneMatch: ['"other"', 'W/"current"'],
      ),
      304,
    );
    expect(
      calendarFeedConditionalStatus('"current"', ifNoneMatch: [' *\t']),
      304,
    );
    expect(
      calendarFeedConditionalStatus('"current"', ifNoneMatch: ['"other"']),
      200,
    );
  });
  test('If-Match requires strong equality and precedes If-None-Match', () {
    expect(
      calendarFeedConditionalStatus('"current"', ifMatch: ['"current"']),
      200,
    );
    expect(
      calendarFeedConditionalStatus('"current"', ifMatch: ['W/"current"']),
      412,
    );
    expect(calendarFeedConditionalStatus('"current"', ifMatch: ['*']), 200);
    expect(
      calendarFeedConditionalStatus(
        '"current"',
        ifMatch: ['"wrong"'],
        ifNoneMatch: ['"current"'],
      ),
      412,
    );
    expect(
      calendarFeedConditionalStatus(
        '"current"',
        ifMatch: ['"current"'],
        ifNoneMatch: ['W/"current"'],
      ),
      304,
    );
  });
  test('commas and backslashes inside opaque tags are data', () {
    expect(
      calendarFeedConditionalStatus('"a,b"', ifNoneMatch: ['"other", "a,b"']),
      304,
    );
    expect(
      calendarFeedConditionalStatus(r'"a\b"', ifNoneMatch: [r'"a\b"']),
      304,
    );
    expect(calendarFeedConditionalStatus('""', ifNoneMatch: ['""']), 304);
    expect(calendarFeedConditionalStatus('"é"', ifNoneMatch: ['W/"é"']), 304);
  });
  test('reasonable empty list elements are ignored', () {
    expect(
      calendarFeedConditionalStatus(
        '"current"',
        ifNoneMatch: [', ,"current",,'],
      ),
      304,
    );
    expect(
      calendarFeedConditionalStatus('"current"', ifNoneMatch: [', ,']),
      200,
    );
    expect(calendarFeedConditionalStatus('"current"', ifMatch: ['']), 412);
  });
  test('malformed conditional fields reject without echoing content', () {
    for (final value in [
      '*, "current"',
      '*,*',
      'w/"current"',
      '"unterminated',
      '"a b"',
      '"a\nb"',
      '"a" junk',
      '"a" "b"',
      '"😀"',
    ]) {
      expect(
        () => calendarFeedConditionalStatus('"current"', ifNoneMatch: [value]),
        throwsFormatException,
      );
    }
  });
  test('header length, member and empty-element work are bounded', () {
    expect(
      () => calendarFeedConditionalStatus('"x"', ifMatch: ['"${'x' * 8192}"']),
      throwsFormatException,
    );
    expect(
      () =>
          calendarFeedConditionalStatus('"x"', ifMatch: List.filled(65, '"x"')),
      throwsFormatException,
    );
    expect(
      () => calendarFeedConditionalStatus('"x"', ifMatch: [',' * 33]),
      throwsFormatException,
    );
    expect(
      calendarFeedConditionalStatus('"x"', ifMatch: List.filled(64, '"x"')),
      200,
    );
  });
}
