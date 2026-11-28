import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_mail/mime.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

enum HostImipMimeError {
  profile,
  protection,
  limitExceeded,
  calendar,
  unavailable,
}

/// Does not expose source headers, addresses, content or decoder diagnostics.
final class HostImipMimeException implements Exception {
  const HostImipMimeException(this.kind);
  final HostImipMimeError kind;
  @override
  String toString() => 'HostImipMimeException(${kind.name})';
}

Never _fail(HostImipMimeError kind) => throw HostImipMimeException(kind);

const _octets = 'application/octet-stream';
const _alphabet =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
final _token = RegExp(r"^[A-Za-z0-9!#$%&'*+.^_`|~-]+$");
final _boundary = RegExp(r'^[A-Za-z0-9._=+\-]{1,70}$');
const _critical = {
  'content-type',
  'content-transfer-encoding',
  'mime-version',
  'from',
  'date',
  'message-id',
};

final class _Budget {
  int headerBytes = 0, fields = 0;
}

final class _Part {
  _Part(this.data, this.body, this.type, this.parameters, this.encoding);
  final BinaryMimeData data;
  final Uint8List body;
  final String type, encoding;
  final List<ImipParameter> parameters;
  String? parameter(String key) {
    for (final value in parameters) {
      if (value.name.toLowerCase() == key) return value.value;
    }
    return null;
  }
}

/// Bounds raw header framing before the library can copy/unfold it.
int _headerEnd(Uint8List bytes, _Budget budget, List<String> names) {
  final remaining = 16384 - budget.headerBytes;
  var end = -1;
  for (var i = 0; i + 3 < bytes.length && i + 4 <= remaining; i++) {
    if (bytes[i] == 13 &&
        bytes[i + 1] == 10 &&
        bytes[i + 2] == 13 &&
        bytes[i + 3] == 10) {
      end = i;
      break;
    }
  }
  if (end < 0) {
    _fail(
      bytes.length >= remaining
          ? HostImipMimeError.limitExceeded
          : HostImipMimeError.profile,
    );
  }
  var lineStart = 0;
  var hasField = false;
  for (var i = 0; i <= end; i++) {
    final c = bytes[i];
    if (c == 13) {
      if (bytes[i + 1] != 10) _fail(HostImipMimeError.profile);
      final length = i - lineStart;
      if (length > 998) _fail(HostImipMimeError.limitExceeded);
      if (length == 0) _fail(HostImipMimeError.profile);
      if (bytes[lineStart] == 32 || bytes[lineStart] == 9) {
        if (!hasField) _fail(HostImipMimeError.profile);
      } else {
        var colon = lineStart;
        while (colon < i && bytes[colon] != 58) {
          colon++;
        }
        if (colon == lineStart || colon == i) _fail(HostImipMimeError.profile);
        if (colon - lineStart > 64 || ++budget.fields > 64) {
          _fail(HostImipMimeError.limitExceeded);
        }
        for (var p = lineStart; p < colon; p++) {
          if (bytes[p] < 33 || bytes[p] > 126) _fail(HostImipMimeError.profile);
        }
        names.add(
          ascii
              .decode(Uint8List.sublistView(bytes, lineStart, colon))
              .toLowerCase(),
        );
        hasField = true;
      }
      lineStart = i + 2;
      i++;
    } else if (c == 10 || c > 126 || c < 32 && c != 9) {
      _fail(HostImipMimeError.profile);
    }
  }
  budget.headerBytes += end + 4;
  return end + 4;
}

_Part _frame(Uint8List bytes, _Budget budget, {required bool root}) {
  final names = <String>[];
  final start = _headerEnd(bytes, budget, names);
  final seenNames = <String>{};
  for (final name in names) {
    if (_critical.contains(name) && !seenNames.add(name)) {
      _fail(HostImipMimeError.profile);
    }
  }
  // Parsing instruction only: source headers remain unchanged. Never descend
  // into an uninspected multipart/protected body or use this as its actual type.
  final data = BinaryMimeData(bytes, containsHeader: true)
    ..parse(ContentTypeHeader(_octets));
  final headers = data.headersList ?? const <Header>[];
  if (headers.length != names.length ||
      headers.indexed.any(
        (entry) => entry.$2.lowerCaseName != names[entry.$1],
      )) {
    _fail(HostImipMimeError.profile);
  }
  final critical = <String, String?>{};
  for (final header in headers) {
    final name = header.lowerCaseName;
    if (_critical.contains(name)) {
      if (critical.containsKey(name)) _fail(HostImipMimeError.profile);
      critical[name] = header.value;
    }
  }
  final version = critical['mime-version'];
  if ((root || critical.containsKey('mime-version')) &&
      version?.trim() != '1.0') {
    _fail(HostImipMimeError.profile);
  }
  final raw = critical['content-type'];
  if (raw == null) _fail(HostImipMimeError.profile);
  final semicolons = ';'.allMatches(raw).length;
  if (semicolons > 16) _fail(HostImipMimeError.limitExceeded);
  final pieces = raw.split(';');
  final originalType = pieces.first.trim();
  final type = originalType.toLowerCase();
  if (const {
    'multipart/signed',
    'multipart/encrypted',
    'application/pkcs7-mime',
    'application/x-pkcs7-mime',
    'application/pkcs7-signature',
    'application/pgp-encrypted',
  }.contains(type)) {
    _fail(HostImipMimeError.protection);
  }
  if (root && type != 'text/calendar' && type != 'multipart/alternative') {
    _fail(HostImipMimeError.profile);
  }
  final allowed = switch (type) {
    'text/calendar' => const {'method', 'charset', 'component'},
    'text/plain' || 'text/html' => const {'charset'},
    'multipart/alternative' when root => const {'boundary'},
    _ => throw const HostImipMimeException(HostImipMimeError.profile),
  };
  final parameters = <ImipParameter>[];
  final seen = <String>{};
  for (final segment in pieces.skip(1)) {
    final equal = segment.indexOf('=');
    if (equal < 1) _fail(HostImipMimeError.profile);
    final name = segment.substring(0, equal).trim();
    final key = name.toLowerCase();
    var value = segment.substring(equal + 1).trim();
    if (name.length > 64 || value.length > 1026) {
      _fail(HostImipMimeError.limitExceeded);
    }
    if (!_token.hasMatch(name) || !allowed.contains(key) || !seen.add(key)) {
      _fail(HostImipMimeError.profile);
    }
    final quoted =
        value.startsWith('"') && value.endsWith('"') && value.length >= 2;
    if (quoted) value = value.substring(1, value.length - 1);
    if (value.length > 1024) _fail(HostImipMimeError.limitExceeded);
    if (key == 'boundary') {
      if (!_boundary.hasMatch(value) || !quoted && !_token.hasMatch(value)) {
        _fail(HostImipMimeError.profile);
      }
    } else if (!_token.hasMatch(value)) {
      _fail(HostImipMimeError.profile);
    }
    parameters.add(ImipParameter(name, value));
  }
  // Compare only after the strict raw grammar has proved there are no aliases
  // or duplicates for the library's normalized map to conceal.
  final parsed = ContentTypeHeader(raw);
  if (parsed.parameters.length != parameters.length ||
      parameters.any(
        (p) => parsed.parameters[p.name.toLowerCase()] != p.value,
      )) {
    _fail(HostImipMimeError.profile);
  }
  final encoding = critical.containsKey('content-transfer-encoding')
      ? critical['content-transfer-encoding']?.trim().toLowerCase()
      : '7bit';
  if (!const {'7bit', 'base64', 'quoted-printable'}.contains(encoding) ||
      type == 'multipart/alternative' && encoding != '7bit') {
    _fail(HostImipMimeError.profile);
  }
  return _Part(
    data,
    Uint8List.sublistView(bytes, start),
    originalType,
    List.unmodifiable(parameters),
    encoding!,
  );
}

void _rawLines(Uint8List bytes) {
  var length = 0, lines = 0;
  for (var i = 0; i < bytes.length; i++) {
    final c = bytes[i];
    if (c == 13) {
      if (i + 1 == bytes.length || bytes[++i] != 10) {
        _fail(HostImipMimeError.profile);
      }
      if (++lines > 16384) _fail(HostImipMimeError.limitExceeded);
      length = 0;
    } else {
      if (c == 10 || c > 126 || c < 32 && c != 9) {
        _fail(HostImipMimeError.profile);
      }
      if (++length > 998) _fail(HostImipMimeError.limitExceeded);
    }
  }
  if (length > 0 && ++lines > 16384) _fail(HostImipMimeError.limitExceeded);
}

List<String> _flat(_Part parent) {
  final boundary = parent.parameter('boundary');
  if (boundary == null) _fail(HostImipMimeError.profile);
  final body = ascii.decode(parent.body);
  final delimiter = '--$boundary';
  var cursor = 0, opens = 0;
  int? first, closedAt;
  while (cursor < body.length) {
    final crlf = body.indexOf('\r\n', cursor);
    final end = crlf < 0 ? body.length : crlf;
    if (body.startsWith(delimiter, cursor)) {
      var tail = end;
      while (tail > cursor &&
          (body.codeUnitAt(tail - 1) == 32 || body.codeUnitAt(tail - 1) == 9)) {
        tail--;
      }
      final suffix = body.substring(cursor + delimiter.length, tail);
      if (suffix.isEmpty || suffix == '--') {
        if (closedAt != null) _fail(HostImipMimeError.profile);
        first ??= cursor;
        if (suffix == '--') {
          if (opens == 0) _fail(HostImipMimeError.profile);
          closedAt = crlf < 0 ? end : end + 2;
        } else if (++opens > 3) {
          _fail(HostImipMimeError.limitExceeded);
        }
      }
    }
    if (crlf < 0) break;
    cursor = end + 2;
  }
  if (first == null || closedAt == null) _fail(HostImipMimeError.profile);
  if (first > 4096 || body.length - closedAt > 4096) {
    _fail(HostImipMimeError.limitExceeded);
  }
  final chunks = TextMimeData.splitMultipart(body, boundary);
  if (chunks.length != opens) _fail(HostImipMimeError.profile);
  return chunks.map((chunk) {
    if (!chunk.endsWith('\r\n')) _fail(HostImipMimeError.profile);
    // Only the MIME separator retained by this library, never calendar data.
    return chunk.substring(0, chunk.length - 2);
  }).toList();
}

int _sextet(int c) => c >= 65 && c <= 90
    ? c - 65
    : c >= 97 && c <= 122
    ? c - 71
    : c >= 48 && c <= 57
    ? c + 4
    : c == 43
    ? 62
    : c == 47
    ? 63
    : -1;

int _hex(int c) => c >= 48 && c <= 57
    ? c - 48
    : c >= 65 && c <= 70
    ? c - 55
    : c >= 97 && c <= 102
    ? c - 87
    : -1;

Uint8List _decoded(_Part part, int maximum) {
  var expected = 0;
  BinaryMimeData decoder = part.data;
  if (part.encoding == '7bit') {
    expected = part.body.length;
  } else {
    final lines = ascii.decode(part.body).split('\r\n');
    final cleaned = StringBuffer();
    for (var line in lines) {
      var end = line.length;
      while (end > 0 &&
          (line.codeUnitAt(end - 1) == 32 || line.codeUnitAt(end - 1) == 9)) {
        end--;
      }
      line = line.substring(0, end);
      if (line.length > 76) _fail(HostImipMimeError.profile);
      if (part.encoding == 'base64') {
        for (final c in line.codeUnits) {
          if (c == 32 || c == 9) continue;
          if (c != 61 && _sextet(c) < 0) _fail(HostImipMimeError.profile);
          cleaned.writeCharCode(c);
        }
      } else {
        cleaned.write(line);
        cleaned.write('\r\n');
      }
    }
    if (part.encoding == 'base64') {
      final value = cleaned.toString();
      if (value.length % 4 != 0) _fail(HostImipMimeError.profile);
      final firstPad = value.indexOf('=');
      final padding = firstPad < 0 ? 0 : value.length - firstPad;
      if (padding > 2 ||
          firstPad >= 0 &&
              value.substring(firstPad).codeUnits.any((c) => c != 61)) {
        _fail(HostImipMimeError.profile);
      }
      if (padding > 0) {
        final last = _alphabet.indexOf(value[firstPad - 1]);
        if (last < 0 || (last & (padding == 2 ? 15 : 3)) != 0) {
          _fail(HostImipMimeError.profile);
        }
      }
      expected = value.length ~/ 4 * 3 - padding;
    } else {
      // split/join preserves only existing line breaks, including absent EOF CRLF.
      var value = cleaned.toString();
      value = value.substring(0, value.length - 2);
      for (var i = 0; i < value.length; i++) {
        final c = value.codeUnitAt(i);
        if (c == 61) {
          if (i + 2 >= value.length) _fail(HostImipMimeError.profile);
          if (value.codeUnitAt(i + 1) == 13 && value.codeUnitAt(i + 2) == 10) {
            i += 2;
            continue;
          }
          if (_hex(value.codeUnitAt(i + 1)) < 0 ||
              _hex(value.codeUnitAt(i + 2)) < 0) {
            _fail(HostImipMimeError.profile);
          }
          i += 2;
        } else if (c < 32 && c != 9 && c != 13 && c != 10 || c > 126) {
          _fail(HostImipMimeError.profile);
        }
        if (++expected > maximum) _fail(HostImipMimeError.limitExceeded);
      }
      decoder = BinaryMimeData(
        Uint8List.fromList(ascii.encode(value)),
        containsHeader: false,
      )..parse(ContentTypeHeader(_octets));
    }
  }
  if (expected > maximum) _fail(HostImipMimeError.limitExceeded);
  final decoded = decoder.decodeBinary(part.encoding);
  if (decoded.length != expected) _fail(HostImipMimeError.profile);
  return decoded;
}

/// Complete untrusted raw MIME data only. No lookup, authority, native dispatch,
/// sender verification, archive, rendering, response or network effect.
ImipCalendarPart parseHostImipMime(
  List<int> raw, {
  required ImipProtection outerProtection,
}) {
  if (outerProtection != ImipProtection.none) {
    _fail(HostImipMimeError.protection);
  }
  if (raw.length > 1048576) _fail(HostImipMimeError.limitExceeded);
  try {
    if (raw.any((b) => b < 0 || b > 255)) _fail(HostImipMimeError.profile);
    final bytes = Uint8List.fromList(raw);
    final budget = _Budget();
    final parent = _frame(bytes, budget, root: true);
    _rawLines(bytes);
    final leaves = parent.type.toLowerCase() == 'multipart/alternative'
        ? _flat(parent)
              .map(
                (chunk) => _frame(
                  Uint8List.fromList(ascii.encode(chunk)),
                  budget,
                  root: false,
                ),
              )
              .toList()
        : [parent];
    final kinds = <String>{};
    ImipDecodedPart? calendar;
    for (final leaf in leaves) {
      final type = leaf.type.toLowerCase();
      if (type == 'multipart/alternative' || !kinds.add(type)) {
        _fail(HostImipMimeError.profile);
      }
      final body = _decoded(leaf, type == 'text/calendar' ? 524288 : 65536);
      if (type == 'text/calendar') {
        calendar = ImipDecodedPart(
          mediaType: leaf.type,
          parameters: leaf.parameters,
          body: body,
          protection: ImipProtection.none,
          limits: const ImipPartLimits(maxDecodedBytes: 524288),
        );
      } else {
        final charset = leaf.parameter('charset')?.toUpperCase();
        if ((charset != null && charset != 'UTF-8' && charset != 'US-ASCII') ||
            charset != 'UTF-8' && body.any((b) => b > 127)) {
          _fail(HostImipMimeError.profile);
        }
        utf8.decode(body, allowMalformed: false);
      }
    }
    if (calendar == null) _fail(HostImipMimeError.profile);
    return parseImipCalendarPart(
      calendar,
      limits: const ImipPartLimits(maxDecodedBytes: 524288),
    );
  } on HostImipMimeException {
    rethrow;
  } on ImipPartException catch (e) {
    _fail(
      e.kind == ImipPartError.limitExceeded
          ? HostImipMimeError.limitExceeded
          : HostImipMimeError.calendar,
    );
  } on FormatException {
    _fail(HostImipMimeError.profile);
  } catch (_) {
    _fail(HostImipMimeError.unavailable);
  }
}
