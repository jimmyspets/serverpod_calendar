import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'generated/protocol.dart';

CalendarFeedSettings validateFeedSettings(CalendarFeedSettings input) {
  if (input.displayName.length > 4096 ||
      input.displayName.codeUnits.any(
        (c) =>
            c == 0 ||
            c == 10 ||
            c == 13 ||
            c == 0x85 ||
            c == 0x2028 ||
            c == 0x2029,
      )) {
    throw ArgumentError('Invalid feed name');
  }
  // Detach caller-owned mutable metadata and collections before async work.
  final value = CalendarFeedSettings.fromJson(
    jsonDecode(jsonEncode(input.toJson())) as Map<String, dynamic>,
  );
  final name = value.displayName.trim();
  validateCalendarPlainText(name, maxCodePoints: 256);
  if (name.isEmpty ||
      name.codeUnits.any(
        (c) => c == 10 || c == 13 || c == 0x85 || c == 0x2028 || c == 0x2029,
      )) {
    throw ArgumentError('Invalid feed name');
  }
  if (value.calendarIds.isEmpty ||
      value.calendarIds.length > 16 ||
      value.calendarIds.toSet().length != value.calendarIds.length) {
    throw ArgumentError('Invalid feed selection');
  }
  final text = value.protocolMetadata;
  if (text != null) {
    IcalendarCalendarTextMetadata(
      names: text.names.map(
        (v) => IcalendarTextVariant(v.value, language: v.language),
      ),
      descriptions: text.descriptions.map(
        (v) => IcalendarTextVariant(v.value, language: v.language),
      ),
      color: text.color,
    );
  }
  final extra = value.supplementalMetadata;
  if (extra != null) {
    IcalendarSupplementalMetadata(
      url: extra.url,
      categories: extra.categories.map(
        (v) => IcalendarCategory(v.value, language: v.language),
      ),
      images: extra.images.map(
        (v) => IcalendarImageLink(
          v.uri,
          display: v.display,
          mediaType: v.mediaType,
        ),
      ),
      refreshHint: extra.refreshHint == null
          ? null
          : IcalendarRefreshHint(
              weeks: extra.refreshHint!.weeks,
              days: extra.refreshHint!.days,
              hours: extra.refreshHint!.hours,
              minutes: extra.refreshHint!.minutes,
              seconds: extra.refreshHint!.seconds,
            ),
    );
  }
  final ids = [...value.calendarIds]
    ..sort((a, b) => a.toString().compareTo(b.toString()));
  final emptyText =
      text == null ||
      text.names.isEmpty && text.descriptions.isEmpty && text.color == null;
  final emptyExtra =
      extra == null ||
      extra.url == null &&
          extra.categories.isEmpty &&
          extra.images.isEmpty &&
          extra.refreshHint == null;
  return value.copyWith(
    displayName: name,
    calendarIds: ids,
    protocolMetadata: emptyText ? null : text,
    supplementalMetadata: emptyExtra ? null : extra,
  );
}

String? validateFeedCredentialLabel(String? input) {
  if (input == null) return null;
  if (input.length > 4096 ||
      input.codeUnits.any(
        (c) =>
            c == 0 ||
            c == 10 ||
            c == 13 ||
            c == 0x85 ||
            c == 0x2028 ||
            c == 0x2029,
      )) {
    throw ArgumentError('Invalid credential label');
  }
  final value = input.trim();
  validateCalendarPlainText(value, maxCodePoints: 256);
  if (value.codeUnits.any(
    (c) => c == 10 || c == 13 || c == 0x85 || c == 0x2028 || c == 0x2029,
  )) {
    throw ArgumentError('Invalid credential label');
  }
  return value.isEmpty ? null : value;
}

/// Management labels and private authority references never affect feed bytes.
String feedPublicationSettingsKey(CalendarFeedSettings settings) => jsonEncode([
  settings.calendarIds.map((id) => id.toString()).toList(),
  settings.protocolMetadata?.toJson(),
  settings.supplementalMetadata?.toJson(),
]);
