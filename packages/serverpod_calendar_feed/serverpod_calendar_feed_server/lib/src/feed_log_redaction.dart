import 'dart:async';

final Object _feedLogRedactionKey = Object();

/// Whole-host console redaction is required because the HTTP adapter can log
/// a raw URI after a handler returns (for example on a disconnected socket).
/// Wrap startup, not just route construction. External proxies/traces need
/// their own equivalent policy. This does not install an authorization cache.
T runWithCalendarFeedLogRedaction<T>(
  T Function() body, {
  List<String> mountPaths = const ['/calendar-feed'],
}) {
  if (mountPaths.isEmpty ||
      mountPaths.length > 16 ||
      mountPaths.any(
        (p) => !RegExp(r'^/[A-Za-z0-9_-]+(?:/[A-Za-z0-9_-]+)*$').hasMatch(p),
      )) {
    throw ArgumentError('Invalid feed redaction mounts');
  }
  final mounts = List<String>.unmodifiable(mountPaths);
  return runZoned(
    body,
    zoneValues: {_feedLogRedactionKey: mounts},
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(zone, redactCalendarFeedLogLine(line, mountPaths: mounts));
      },
    ),
  );
}

bool calendarFeedLogRedactionEnabled(String mountPath) =>
    (Zone.current[_feedLogRedactionKey] as List<String>?)?.contains(
      mountPath,
    ) ??
    false;

/// Drop the complete message if it includes a mounted feed path, including
/// JSON slash escapes and bounded percent-encoded aliases. Never echo a suffix.
String redactCalendarFeedLogLine(
  String line, {
  List<String> mountPaths = const ['/calendar-feed'],
}) {
  var candidate = line.replaceAll(r'\/', '/');
  final encoded = RegExp(r'%([0-9a-fA-F]{2})');
  for (var i = 0; i < 4; i++) {
    candidate = candidate.replaceAll(r'\/', '/');
    if (mountPaths.any(
      (p) => candidate.toLowerCase().contains(p.toLowerCase()),
    )) {
      return '[calendar feed request redacted]';
    }
    final decoded = candidate.replaceAllMapped(
      encoded,
      (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)),
    );
    if (decoded == candidate) break;
    candidate = decoded;
  }
  // Very deeply encoded suspicious messages are suppressed too; the route
  // never accepts such paths, but an upstream parser can still log them.
  if (encoded.hasMatch(candidate)) {
    return '[encoded request diagnostic redacted]';
  }
  return line;
}
