import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'calendar_text_metadata.dart';

final class IcalendarCategory {
  IcalendarCategory(this.value, {this.language}) {
    validateCalendarPlainText(value, maxCodePoints: 256);
    if (value.trim().isEmpty ||
        value.codeUnits.any(
          (c) => c == 10 || c == 13 || c == 0x85 || c == 0x2028 || c == 0x2029,
        )) {
      throw ArgumentError('Category must be nonblank and single line');
    }
    if (language != null) validateCalendarLanguageTag(language!);
  }
  final String value;
  final String? language;

  /// An omitted query language matches this exact text in any language.
  bool matches(IcalendarCategory query) =>
      value == query.value &&
      (query.language == null ||
          language?.toLowerCase() == query.language!.toLowerCase());
}

final class IcalendarRefreshHint {
  IcalendarRefreshHint({
    int weeks = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
  }) : duration = CalendarDuration(
         weeks: weeks,
         days: days,
         hours: hours,
         minutes: minutes,
         seconds: seconds,
       ) {
    final d = duration;
    final boundSeconds =
        BigInt.from(d.weeks) * BigInt.from(604800) +
        BigInt.from(d.days) * BigInt.from(86400) +
        BigInt.from(d.hours) * BigInt.from(3600) +
        BigInt.from(d.minutes) * BigInt.from(60) +
        BigInt.from(d.seconds);
    if (boundSeconds <= BigInt.zero || boundSeconds > BigInt.from(31536000)) {
      throw ArgumentError('Refresh hint must be positive and at most 365 days');
    }
  }

  /// Units stay intact; the day/week conversion above is only a size bound.
  final CalendarDuration duration;
}

final class IcalendarImageLink {
  factory IcalendarImageLink(
    String uri, {
    Iterable<String>? display,
    String? mediaType,
  }) {
    validateCalendarHttpUri(uri);
    final tokens = display == null ? null : <String>[];
    if (display != null) {
      final seen = <String>{};
      for (final token in display) {
        if (tokens!.length == 8 ||
            token.isEmpty ||
            token.length > 32 ||
            token.codeUnits.any(
              (c) =>
                  !((c >= 65 && c <= 90) ||
                      (c >= 97 && c <= 122) ||
                      (c >= 48 && c <= 57) ||
                      c == 45),
            ) ||
            !seen.add(token.toUpperCase())) {
          throw ArgumentError('Invalid or duplicate image display token');
        }
        tokens.add(token);
      }
      if (tokens!.isEmpty) {
        throw ArgumentError('Explicit DISPLAY cannot be empty');
      }
    }
    if (mediaType != null) {
      final match = RegExp(
        r"^image/[A-Za-z0-9!#$%&'*+.^_`|~-]+$",
        caseSensitive: false,
      ).firstMatch(mediaType);
      if (mediaType.length > 127 ||
          match == null ||
          match.end != mediaType.length) {
        throw ArgumentError('Expected an image media type without parameters');
      }
    }
    return IcalendarImageLink._(
      uri,
      tokens == null ? null : List.unmodifiable(tokens),
      mediaType,
    );
  }
  IcalendarImageLink._(this.uri, this.display, this.mediaType);
  final String uri;
  final List<String>? display;
  final String? mediaType;
  List<String> get effectiveDisplay => display ?? const ['BADGE'];

  /// Unknown hints suppress rendering of the entire image; no fallback to BADGE.
  bool get hasOnlyKnownDisplayHints => effectiveDisplay.every(
    (v) => const {
      'BADGE',
      'GRAPHIC',
      'FULLSIZE',
      'THUMBNAIL',
    }.contains(v.toUpperCase()),
  );
}

final class IcalendarSupplementalMetadata {
  factory IcalendarSupplementalMetadata({
    String? url,
    Iterable<IcalendarCategory> categories = const [],
    Iterable<IcalendarImageLink> images = const [],
    IcalendarRefreshHint? refreshHint,
  }) {
    if (url != null) validateCalendarHttpUri(url);
    final c = <IcalendarCategory>[];
    final keys = <(String, String?)>{};
    for (final value in categories) {
      if (c.length == 64 ||
          !keys.add((value.value, value.language?.toLowerCase()))) {
        throw ArgumentError('Too many or duplicate categories');
      }
      c.add(value);
    }
    final links = <IcalendarImageLink>[];
    for (final link in images) {
      if (links.length == 16) throw ArgumentError('Too many images');
      links.add(link);
    }
    var bytes = url?.length ?? 0;
    for (final v in c) {
      bytes += utf8.encode(v.value).length + (v.language?.length ?? 0);
    }
    for (final v in links) {
      bytes += v.uri.length + (v.mediaType?.length ?? 0);
      for (final token in v.display ?? const <String>[]) {
        bytes += token.length;
      }
    }
    if (refreshHint != null) {
      final d = refreshHint.duration;
      for (final value in [d.weeks, d.days, d.hours, d.minutes, d.seconds]) {
        bytes += value.toString().length;
      }
    }
    if (bytes > 65536) {
      throw ArgumentError('Supplemental metadata exceeds byte limit');
    }
    return IcalendarSupplementalMetadata._(
      url,
      List.unmodifiable(c),
      List.unmodifiable(links),
      refreshHint,
    );
  }
  IcalendarSupplementalMetadata._(
    this.url,
    this.categories,
    this.images,
    this.refreshHint,
  );
  final String? url;
  final List<IcalendarCategory> categories;
  final List<IcalendarImageLink> images;
  final IcalendarRefreshHint? refreshHint;
  bool get isEmpty =>
      url == null &&
      categories.isEmpty &&
      images.isEmpty &&
      refreshHint == null;
}

/// Bounded native URI profile. Does not resolve, normalize or fetch the link.
void validateCalendarHttpUri(String value) {
  if (value.isEmpty ||
      value.length > 4096 ||
      value.codeUnits.any((c) => c < 33 || c > 126)) {
    throw ArgumentError('Invalid HTTP URI');
  }
  final match = RegExp(
    r'^(https?)://([^/?#]+)([^?#]*)(?:\?([^#]*))?(?:#(.*))?$',
    caseSensitive: false,
  ).firstMatch(value);
  if (match == null || match.end != value.length || match[2]!.contains('@')) {
    throw ArgumentError(
      'Expected absolute HTTP/HTTPS URI without user information',
    );
  }
  bool part(String text, String extra) {
    const chars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~!\$&'()*+,;=";
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '%') {
        if (i + 2 >= text.length ||
            !RegExp(r'^[0-9A-Fa-f]{2}$')
                .hasMatch(text.substring(i + 1, i + 3))) {
          return false;
        }
        i += 2;
      } else if (!chars.contains(text[i]) && !extra.contains(text[i])) {
        return false;
      }
    }
    return true;
  }

  if (!part(match[2]!, '[]:') ||
      !part(match[3]!, '/:@') ||
      !part(match[4] ?? '', '/?:@') ||
      !part(match[5] ?? '', '/?:@')) {
    throw ArgumentError('Invalid URI component');
  }
  try {
    final uri = Uri.parse(value);
    if (!uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.hasPort && (uri.port < 1 || uri.port > 65535))) {
      throw ArgumentError('Invalid HTTP authority');
    }
  } on FormatException {
    throw ArgumentError('Invalid HTTP URI');
  }
}
