import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'availability_values.dart';
import 'availability_protocol_values.dart';
import 'generated/protocol.dart';

String get availabilityBaselineProfile =>
    'availability-source-v1/${NamedZoneResolver.dataVersion}';
const availabilityBaselineMaxBytes = 2097152;

/// Exact, bounded comparison state. Native UUIDs are references only and never
/// part of source equality. No raw source file or digest is authoritative.
String canonicalAvailabilitySource(
  String uid,
  CalendarAvailabilityContent content,
  List<CalendarAvailabilityOpeningEdits>? edits,
  CalendarAvailabilityProtocolState protocol,
) {
  validateAvailabilityUid(uid);
  content = validateAvailabilityContent(content);
  edits = validateAvailabilityEdits(content, edits);
  protocol = validateAvailabilityProtocolState(protocol, content, edits: edits);
  final ids = <String, String>{};
  for (final opening in content.openings) {
    if (opening.uid == null || opening.protocolUid == null) {
      throw ArgumentError('Opening identity required');
    }
    ids[opening.uid.toString()] = opening.protocolUid!;
  }
  Map<String, dynamic> json(Object value) =>
      jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
  List<dynamic> sorted(List<dynamic> values, String Function(dynamic) key) =>
      values..sort((a, b) => key(a).compareTo(key(b)));
  void metadata(Map<String, dynamic> value, {bool source = false}) {
    final parameters = value['textParameters'] as Map<String, dynamic>?;
    final categories = value.remove('categories') as List<dynamic>?;
    if (source) {
      value['categoryGroups'] = categories;
    } else if (value['categoryGroups'] == null &&
        categories != null &&
        categories.isNotEmpty) {
      value['categoryGroups'] = [
        {
          'values': categories,
          if (parameters?['categoryLanguage'] != null)
            'language': parameters!['categoryLanguage'],
        },
      ];
    }
    parameters?.remove('categoryLanguage');
    final extensions = value['extensions'] as List<dynamic>?;
    if (extensions != null) {
      for (final extension in extensions) {
        extension['name'] = (extension['name'] as String).toUpperCase();
      }
      sorted(extensions, (e) => e['name'] as String);
    }
  }

  final data = json(content.toJson());
  metadata(data);
  final openings = data['openings'] as List<dynamic>;
  for (final opening in openings) {
    opening.remove('uid');
    metadata(opening as Map<String, dynamic>);
    if (opening['periods'] == null) opening['periods'] = [];
    sorted(opening['periods'] as List<dynamic>, (v) => jsonEncode(_ordered(v)));
    final recurrence = opening['recurrence'] as Map<String, dynamic>?;
    if (recurrence != null) {
      for (final key in ['inclusions', 'exclusions']) {
        final values = recurrence[key] as List<dynamic>?;
        if (values != null) sorted(values, (v) => jsonEncode(_ordered(v)));
      }
    }
  }
  sorted(openings, (o) => o['protocolUid'] as String);
  Map<String, dynamic> refs(Map<String, dynamic> value) {
    void visit(dynamic node) {
      if (node is Map<String, dynamic>) {
        if (node.containsKey('openingUid')) {
          final mapped = ids[node['openingUid']];
          if (mapped == null) throw ArgumentError('Unknown opening reference');
          node['openingUid'] = mapped;
        }
        for (final child in node.values) {
          visit(child);
        }
      } else if (node is List) {
        for (final child in node) {
          visit(child);
        }
      }
    }

    visit(value);
    return value;
  }

  String anchor(dynamic v) => jsonEncode(_ordered(v['originalStart']));
  final changes = <dynamic>[
    for (final edit in edits ?? <CalendarAvailabilityOpeningEdits>[])
      refs(json(edit.toJson())),
  ];
  for (final change in changes) {
    final overrides = change['overrides'] as Map<String, dynamic>;
    sorted(overrides['singles'] as List<dynamic>, anchor);
    sorted(overrides['future'] as List<dynamic>, anchor);
  }
  sorted(changes, (e) => e['openingUid'] as String);
  final state = refs(json(protocol.toJson()));
  final checkpoints = state['openings'] as List<dynamic>;
  sorted(checkpoints, (s) => s['openingUid'] as String);
  for (final checkpoint in checkpoints) {
    final overrides = checkpoint['overrides'] as List<dynamic>?;
    if (overrides != null) {
      sorted(overrides, (o) => '${o['isThisAndFuture']}:${anchor(o)}');
      for (final override in overrides) {
        final values = override['metadata'] as Map<String, dynamic>?;
        if (values != null) metadata(values, source: true);
      }
    }
  }
  final result = jsonEncode(
    _ordered({
      'uid': uid,
      'content': data,
      'edits': changes,
      'protocol': state,
    }),
  );
  if (utf8.encode(result).length > availabilityBaselineMaxBytes) {
    throw const AvailabilityLimitException('baselineBytes');
  }
  return result;
}

Object? _ordered(Object? value) {
  if (value is Map) {
    final keys =
        value.keys.cast<String>().where((k) => k != '__className__').toList()
          ..sort();
    final result = <String, Object?>{};
    for (final key in keys) {
      final v = _ordered(value[key]);
      if (v != null) result[key] = v;
    }
    return result.isEmpty ? null : result;
  }
  if (value is List) return value.map(_ordered).toList();
  return value;
}

CalendarAvailabilityImportBaseline availabilityImportBaseline(
  String uid,
  CalendarAvailabilityContent content,
  List<CalendarAvailabilityOpeningEdits>? edits,
  CalendarAvailabilityProtocolState protocol,
) => CalendarAvailabilityImportBaseline(
  profile: availabilityBaselineProfile,
  sourceSequence: protocol.sequence,
  canonicalValue: canonicalAvailabilitySource(uid, content, edits, protocol),
);

void validateAvailabilityImportBaseline(
  CalendarAvailabilityImportBaseline value,
  String uid,
) {
  if (value.profile != availabilityBaselineProfile ||
      utf8.encode(value.canonicalValue).length > availabilityBaselineMaxBytes) {
    throw StateError('Incompatible import baseline');
  }
  final decoded = jsonDecode(value.canonicalValue) as Map<String, dynamic>;
  if (decoded['uid'] != uid ||
      decoded['content'] is! Map ||
      decoded['edits'] is! List ||
      decoded['protocol'] is! Map ||
      decoded['protocol']['sequence'] != value.sourceSequence ||
      jsonEncode(_ordered(decoded)) != value.canonicalValue) {
    throw StateError('Invalid import baseline');
  }
}
