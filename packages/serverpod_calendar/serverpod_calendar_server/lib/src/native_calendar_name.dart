import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'dart:convert';

/// Native label validation, deliberately independent of protocol text rules.
String normalizeCalendarDisplayName(String input) {
  if (input.length > 4096) throw ArgumentError('Name input exceeds raw limit');
  final units = input.codeUnits;
  for (var i = 0; i < units.length; i++) {
    final c = units[i];
    if (c == 0 ||
        c == 10 ||
        c == 13 ||
        c == 0x85 ||
        c == 0x2028 ||
        c == 0x2029) {
      throw ArgumentError('Name must be single-line valid text');
    }
    if (c >= 0xd800 && c <= 0xdbff) {
      if (++i >= units.length || units[i] < 0xdc00 || units[i] > 0xdfff) {
        throw ArgumentError('Malformed Unicode');
      }
    } else if (c >= 0xdc00 && c <= 0xdfff) {
      throw ArgumentError('Malformed Unicode');
    }
  }
  final value = input.trim();
  if (value.isEmpty || value.runes.length > 256) {
    throw ArgumentError('Name must contain 1–256 Unicode code points');
  }
  return value;
}

/// Exact opaque host reference with a byte limit safe for composite indexes.
void validateCalendarOpaqueText(String input, {required int maxUtf8Bytes}) {
  if (input.isEmpty ||
      input.length > maxUtf8Bytes ||
      input.contains('\u0000')) {
    throw ArgumentError('Invalid opaque reference');
  }
  // The encoder rejects unpaired surrogates instead of replacing identity text.
  try {
    if (utf8.encode(input).length > maxUtf8Bytes ||
        utf8.decode(utf8.encode(input)) != input) {
      throw ArgumentError('Invalid opaque reference');
    }
  } on FormatException {
    throw ArgumentError('Malformed Unicode');
  }
}

String? normalizeCalendarDescription(String? input) {
  if (input == null || input.isEmpty) return null;
  validateCalendarPlainText(input, maxCodePoints: 16384);
  return input;
}

String? normalizeCalendarNativeColor(String? input) {
  if (input == null || input.isEmpty) return null;
  if (input.length != 7 || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(input)) {
    throw ArgumentError('Native color requires #RRGGBB');
  }
  return input.toUpperCase();
}
