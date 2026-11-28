import 'dart:convert';
import 'dart:io';

import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Assertions on owned generated fixtures, never an incoming email parser.
final class SyntheticSchedulingMimeChecks {
  SyntheticSchedulingMimeChecks._(this.directory, this.seen);
  final Directory directory;
  final Set<String> seen;
  final Map<String, List<Map<String, dynamic>>> publications = {};

  static Future<SyntheticSchedulingMimeChecks> start() async {
    final directory = Directory('.local/scheduling-mail');
    final paths = await directory.exists()
        ? await directory
              .list(followLinks: false)
              .map((file) => file.path)
              .toSet()
        : <String>{};
    return SyntheticSchedulingMimeChecks._(directory, paths);
  }

  Future<void> accepted(cal.CalendarSchedulingView state) async {
    if (!await directory.exists()) {
      throw StateError('Synthetic MIME recording directory is missing');
    }
    await for (final file in directory.list(followLinks: false)) {
      if (file is! File ||
          !file.path.endsWith('.json') ||
          seen.contains(file.path)) {
        continue;
      }
      Map<String, dynamic> value;
      try {
        value = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      } on FormatException {
        // An unrelated worker may still be writing. An accepted delivery below
        // must already have its complete flushed fixture.
        continue;
      }
      seen.add(file.path);
      publications
          .putIfAbsent(value['publicationId'] as String, () => [])
          .add(value);
    }
    final records = publications[state.publicationId.toString()] ?? [];
    if (records.isEmpty ||
        state.deliveries.any(
          (delivery) => !records.any(
            (record) => record['recipient'] == delivery.recipientAddress,
          ),
        )) {
      throw StateError('Accepted scheduling delivery has no MIME fixture');
    }
    final byKey = <String, String>{};
    for (final record in records) {
      final mime = record['mime'];
      if (mime is! String ||
          mime.length > 1048576 ||
          mime.codeUnits.any((c) => c > 127) ||
          !mime.contains(
            '<calendar-${record['deliveryKey']}@example.invalid>',
          ) ||
          !RegExp(
            r'^Content-Transfer-Encoding: base64\r?$',
            caseSensitive: false,
            multiLine: true,
          ).hasMatch(mime)) {
        throw StateError('Synthetic scheduling MIME envelope is invalid');
      }
      final separator = mime.indexOf('\r\n\r\n');
      if (separator < 0 ||
          utf8.decode(
                base64.decode(
                  mime.substring(separator + 4).replaceAll('\r\n', ''),
                ),
              ) !=
              record['payload']) {
        throw StateError('Synthetic MIME changed authorized payload bytes');
      }
      final key = record['deliveryKey'] as String;
      if (byKey.containsKey(key) && byKey[key] != mime) {
        throw StateError('Synthetic scheduling retry changed MIME bytes');
      }
      byKey[key] = mime;
    }
  }
}
