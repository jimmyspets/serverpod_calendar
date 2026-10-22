@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/src/availability_wire_storage.dart';
import 'package:serverpod_calendar_server/src/availability_import_baseline.dart';

AvailabilityStorageProposal fixture({
  String extra = '',
  bool reversed = false,
}) {
  String opening(String id, int hour) => [
    'BEGIN:AVAILABLE',
    'UID:$id',
    'DTSTAMP:20261022T000000Z',
    'DTSTART:20261022T${hour}0000Z',
    'DURATION:PT1H',
    'END:AVAILABLE',
  ].join('\r\n');
  final parts = [opening('A', 10), opening('B', 12)];
  final lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Synthetic//EN',
    'BEGIN:VAVAILABILITY',
    'UID:source/界',
    'DTSTAMP:20261022T000000Z',
    extra,
    ...(reversed ? parts.reversed : parts),
    'END:VAVAILABILITY',
    'END:VCALENDAR',
  ].where((s) => s.isNotEmpty).join('\r\n');
  final bytes = utf8.encode('$lines\r\n');
  return availabilityStorageProposal(
    parseIcalendarAvailabilityCalendar(bytes).definitions.single,
  );
}

String canonical(AvailabilityStorageProposal p) => canonicalAvailabilitySource(
  p.protocolUid,
  p.content,
  p.edits,
  p.protocolState,
);
void main() {
  test('native UUID allocation and opening input order do not affect source equality', () {
    final first = fixture(), second = fixture(reversed: true);
    expect(
      first.content.openings.first.uid,
      isNot(second.content.openings.last.uid),
    );
    expect(canonical(first), canonical(second));
  });
  test('group order duplicates annotations and source sequence omission remain distinguishable', () {
    final first = fixture(
      extra: 'CATEGORIES;LANGUAGE=en:A,A\r\nCATEGORIES;LANGUAGE=sv:B',
    );
    final second = fixture(
      extra: 'CATEGORIES;LANGUAGE=sv:B\r\nCATEGORIES;LANGUAGE=en:A,A',
    );
    expect(canonical(first), isNot(canonical(second)));
    expect(
      canonical(fixture()),
      isNot(canonical(fixture(extra: 'SEQUENCE:0'))),
    );
  });
  test('baseline is exact versioned state and rejects corruption or another source UID', () {
    final p = fixture();
    final base = availabilityImportBaseline(
      p.protocolUid,
      p.content,
      p.edits,
      p.protocolState,
    );
    validateAvailabilityImportBaseline(base, p.protocolUid);
    expect(
      () => validateAvailabilityImportBaseline(
        base.copyWith(profile: 'unknown'),
        p.protocolUid,
      ),
      throwsStateError,
    );
    expect(
      () => validateAvailabilityImportBaseline(base, 'Other'),
      throwsStateError,
    );
    expect(
      () => validateAvailabilityImportBaseline(
        base.copyWith(sourceSequence: 17),
        p.protocolUid,
      ),
      throwsStateError,
    );
    expect(
      () => validateAvailabilityImportBaseline(
        base.copyWith(canonicalValue: '{"uid":"source/界"}'),
        p.protocolUid,
      ),
      throwsStateError,
    );
  });
  test(
    'ordinary text equal to a native UUID is preserved rather than rewritten',
    () {
      final p = fixture();
      final label = p.content.openings.first.uid.toString();
      final text = canonicalAvailabilitySource(
        p.protocolUid,
        p.content.copyWith(summary: label),
        p.edits,
        p.protocolState,
      );
      expect(text, contains(label));
      expect(jsonDecode(text)['content']['summary'], label);
      expect(
        jsonDecode(text)['content']['openings'].first.containsKey('uid'),
        isFalse,
      );
    },
  );
  test('baseline validation bounds bytes before decoding untrusted persisted state', () {
    final p = fixture();
    final base = availabilityImportBaseline(
      p.protocolUid,
      p.content,
      p.edits,
      p.protocolState,
    );
    expect(
      () => validateAvailabilityImportBaseline(
        base.copyWith(canonicalValue: 'x' * (availabilityBaselineMaxBytes + 1)),
        p.protocolUid,
      ),
      throwsStateError,
    );
  });
}
