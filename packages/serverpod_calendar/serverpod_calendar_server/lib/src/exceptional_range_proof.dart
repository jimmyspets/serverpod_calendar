import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_protocol_values.dart';
import 'event_values.dart';
import 'event_wire_output.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';
import 'published_range_restoration_validation.dart';

bool _emptyInheritedClear(
  IcalendarSyntaxEntry entry,
  IcalendarSchedulingEvent master,
) =>
    entry is IcalendarSyntaxProperty &&
    entry.value.isEmpty &&
    entry.parameters.isEmpty &&
    ((entry.canonicalName == 'DESCRIPTION' && master.description == null) ||
        (entry.canonicalName == 'LOCATION' && master.location == null));

/// Pure, bounded evidence for an exceptional range projection. A caller must
/// independently authenticate the publication basis and cancellation ledger.
final class ExceptionalRangeProof {
  ExceptionalRangeProof._(this._encoded);

  final String _encoded;
  String get encoded => _encoded;
  String get basis =>
      (jsonDecode(_encoded) as Map<String, dynamic>)['basis'] as String;
  String get candidate =>
      (jsonDecode(_encoded) as Map<String, dynamic>)['candidate'] as String;

  /// Validates a complete REQUEST against this candidate after checking every
  /// component's independently allocated version against a trusted ledger.
  /// Ledger authority and delivery fencing are the caller's responsibility.
  void requireCommittedRequest(
    String payload,
    Map<String, (int, DateTime)> versions, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    const limit = 524288;
    final work =
        sharedWorkBudget ??
        RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    if (work.maxWork > eventMaxCandidateWork ||
        payload.length > limit ||
        utf8.encode(payload).length > limit ||
        versions.length > 65) {
      throw ArgumentError('Invalid committed exceptional request');
    }
    final data = jsonDecode(_encoded) as Map<String, dynamic>;
    final expected = parseIcalendarSchedulingMessage(
      utf8.encode(data['candidate'] as String),
      sharedWorkBudget: work,
    );
    final actual = parseIcalendarSchedulingMessage(
      utf8.encode(payload),
      sharedWorkBudget: work,
    );
    if (expected.method != IcalendarSchedulingMethod.request ||
        actual.method != IcalendarSchedulingMethod.request) {
      throw ArgumentError('Invalid committed exceptional request');
    }
    String key(IcalendarSchedulingEvent event) {
      if (!event.isOverride) return 'master';
      final date = event.originalDate;
      final timed = event.originalTime;
      final point = CalendarEventTiming(
        kind: date != null
            ? CalendarEventTimeKind.date
            : timed!.zoneId == null
            ? CalendarEventTimeKind.utc
            : CalendarEventTimeKind.zoned,
        start: date != null ? eventDate(date) : eventCivil(timed!.civil),
        zoneId: timed?.zoneId,
      );
      return eventComponentKey(point, event.isThisAndFuture);
    }

    final originals = {for (final event in expected.events) key(event): event};
    final sourceMessage = parseIcalendarSchedulingMessage(
      utf8.encode(data['basis'] as String),
      sharedWorkBudget: work,
    );
    final sourceKeys = sourceMessage.events.map(key).toSet();
    final master = actual.events.singleWhere((event) => !event.isOverride);
    if (originals.length != expected.events.length ||
        versions.length != actual.events.length ||
        originals.length != actual.events.length) {
      throw ArgumentError('Invalid committed exceptional request');
    }
    final replacements = <IcalendarSyntaxComponent, IcalendarSyntaxComponent>{};
    for (final event in actual.events) {
      final name = key(event);
      final original = originals.remove(name);
      final version = versions[name];
      if (original == null ||
          version == null ||
          event.sequence != version.$1 ||
          event.stamp != version.$2) {
        throw ArgumentError('Invalid committed exceptional request');
      }
      final synthetic = !sourceKeys.contains(name);
      if (synthetic &&
          (event.status != null &&
                  event.status !=
                      (master.status ?? IcalendarEventStatus.confirmed) ||
              event.transparency != null &&
                  event.transparency !=
                      (master.transparency ??
                          IcalendarEventTransparency.opaque))) {
        throw ArgumentError('Invalid committed exceptional request');
      }
      final normalizedProperties = {
        'DTSTAMP',
        'SEQUENCE',
        if (synthetic) 'STATUS',
        if (synthetic) 'TRANSP',
      };
      replacements[event.source] = IcalendarSyntaxComponent(event.source.name, [
        for (final entry in event.source.entries)
          if (entry is! IcalendarSyntaxProperty ||
              (!normalizedProperties.contains(entry.canonicalName) &&
                  !(synthetic && _emptyInheritedClear(entry, master))))
            entry,
        for (final entry
            in original.source.entries.whereType<IcalendarSyntaxProperty>())
          if (normalizedProperties.contains(entry.canonicalName)) entry,
      ]);
    }
    if (originals.isNotEmpty) {
      throw ArgumentError('Invalid committed exceptional request');
    }
    final root = actual.source.components.single;
    final normalized = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(root.name, [
        for (final entry in root.entries)
          if (entry is IcalendarSyntaxComponent &&
              replacements.containsKey(entry))
            replacements[entry]!
          else
            entry,
      ]),
    ]);
    validatePublishedRangeRestorationPair(
      basis: expected.source,
      candidate: normalized,
      sharedWorkBudget: work,
    );
  }

  /// Binds the proof's original unmasked source to the current unmasked
  /// publication. Actual component versions must be verified independently.
  void requireUnmaskedLineage(
    String payload, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    final work =
        sharedWorkBudget ??
        RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    if (work.maxWork > eventMaxCandidateWork ||
        payload.length > 524288 ||
        utf8.encode(payload).length > 524288) {
      throw ArgumentError('Invalid exceptional source lineage');
    }
    final data = jsonDecode(_encoded) as Map<String, dynamic>;
    final basis = parseIcalendarSchedulingMessage(
      utf8.encode(data['basis'] as String),
      sharedWorkBudget: work,
    );
    final actual = parseIcalendarSchedulingMessage(
      utf8.encode(payload),
      sharedWorkBudget: work,
    );
    String key(IcalendarSchedulingEvent event) {
      if (!event.isOverride) return 'master';
      final date = event.originalDate, timed = event.originalTime;
      return eventComponentKey(
        CalendarEventTiming(
          kind: date != null
              ? CalendarEventTimeKind.date
              : timed!.zoneId == null
              ? CalendarEventTimeKind.utc
              : CalendarEventTimeKind.zoned,
          start: date != null ? eventDate(date) : eventCivil(timed!.civil),
          zoneId: timed?.zoneId,
        ),
        event.isThisAndFuture,
      );
    }

    final originals = {for (final event in basis.events) key(event): event};
    final master = actual.events.singleWhere((event) => !event.isOverride);
    if (originals.length != basis.events.length) {
      throw ArgumentError('Invalid exceptional source lineage');
    }
    final replacements = <IcalendarSyntaxComponent, IcalendarSyntaxComponent>{};
    for (final event in actual.events) {
      final original = originals.remove(key(event));
      if (original == null) {
        replacements[event.source] = IcalendarSyntaxComponent(
          event.source.name,
          [
            for (final entry in event.source.entries)
              if (!_emptyInheritedClear(entry, master)) entry,
          ],
        );
        continue;
      }
      replacements[event.source] = IcalendarSyntaxComponent(event.source.name, [
        for (final entry in event.source.entries)
          if (entry is! IcalendarSyntaxProperty ||
              !{'DTSTAMP', 'SEQUENCE'}.contains(entry.canonicalName))
            entry,
        for (final entry
            in original.source.entries.whereType<IcalendarSyntaxProperty>())
          if ({'DTSTAMP', 'SEQUENCE'}.contains(entry.canonicalName)) entry,
      ]);
    }
    if (originals.isNotEmpty) {
      throw ArgumentError('Invalid exceptional source lineage');
    }
    final root = actual.source.components.single;
    final normalized = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(root.name, [
        for (final entry in root.entries)
          if (entry is IcalendarSyntaxComponent &&
              replacements.containsKey(entry))
            replacements[entry]!
          else
            entry,
      ]),
    ]);
    validatePublishedRangeRestorationPair(
      basis: basis.source,
      candidate: normalized,
      sharedWorkBudget: work,
    );
  }

  /// Binds reconstructed evidence to independently authenticated checkpoint
  /// data. This comparison does not itself authorize the source or ledger.
  void requireBindings({
    required String basis,
    required CalendarEventTiming anchor,
    required List<CalendarEventTiming> masks,
  }) {
    final data = jsonDecode(_encoded) as Map<String, dynamic>;
    final storedAnchor = CalendarEventTiming.fromJson(
      data['anchor'] as Map<String, dynamic>,
    );
    final expected = masks.map((v) => eventComponentKey(v, false)).toList()
      ..sort();
    final stored = [
      for (final value in data['masks'] as List)
        eventComponentKey(
          CalendarEventTiming.fromJson(value as Map<String, dynamic>),
          false,
        ),
    ]..sort();
    if (basis != data['basis'] ||
        eventComponentKey(anchor, false) !=
            eventComponentKey(storedAnchor, false) ||
        expected.toSet().length != expected.length ||
        jsonEncode(expected) != jsonEncode(stored)) {
      throw const FormatException('Invalid exceptional range proof binding');
    }
  }

  /// Reconstructs the candidate and proves every supplied mask is an original
  /// in the unmasked source. This does not prove any mask is module-owned.
  static ExceptionalRangeProof create({
    required String basis,
    required CalendarEventTiming anchor,
    required List<CalendarEventTiming> masks,
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    const limit = 524288;
    final work =
        sharedWorkBudget ??
        RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    if (work.maxWork > eventMaxCandidateWork ||
        basis.length > limit ||
        utf8.encode(basis).length > limit ||
        masks.length > 64) {
      throw ArgumentError('Invalid exceptional range proof');
    }
    final source = parseIcalendarSyntax(
      utf8.encode(basis),
      limits: const IcalendarSyntaxLimits(maxBytes: limit),
    );
    final root = source.components.single;
    final calendar = validateIcalendarEventCalendar(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent(root.name, [
          for (final entry in root.entries)
            if (entry is! IcalendarSyntaxProperty ||
                entry.canonicalName != 'METHOD')
              entry,
        ]),
      ]),
      sharedWorkBudget: work,
    );
    if (calendar.series.length != 1) {
      throw ArgumentError('Invalid exceptional range proof');
    }
    final content = eventWireProjection(
      calendar.series.single,
      sharedWorkBudget: work,
    ).content;
    final ordered = <String, CalendarEventTiming>{};
    for (final mask in masks) {
      final key = eventComponentKey(mask, false);
      if (ordered.containsKey(key) ||
          !eventSchedulingMember(content, mask, sharedWorkBudget: work)) {
        throw ArgumentError('Invalid exceptional range proof');
      }
      ordered[key] = CalendarEventTiming.fromJson(mask.toJson());
    }
    var projectionBasis = source;
    if (ordered.isNotEmpty) {
      final message = validateIcalendarSchedulingMessage(
        source,
        sharedWorkBudget: work,
      );
      final master = message.events.singleWhere((event) => !event.isOverride);
      CalendarEventTiming point(IcalendarSchedulingEvent value) {
        final date = value.originalDate;
        final timed = value.originalTime;
        return CalendarEventTiming(
          kind: date != null
              ? CalendarEventTimeKind.date
              : timed!.zoneId == null
              ? CalendarEventTimeKind.utc
              : CalendarEventTimeKind.zoned,
          start: date != null ? eventDate(date) : eventCivil(timed!.civil),
          zoneId: timed?.zoneId,
        );
      }

      final own = message.events
          .where(
            (event) =>
                event.isOverride &&
                ordered.containsKey(eventComponentKey(point(event), false)),
          )
          .toList();
      if (own.any((event) => event.isThisAndFuture)) {
        throw ArgumentError('Invalid exceptional range proof');
      }
      final writer = EventComponentWriter();
      projectionBasis = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent(root.name, [
          for (final entry in root.entries)
            if (identical(entry, master.source))
              IcalendarSyntaxComponent(master.source.name, [
                ...master.source.entries,
                for (final key in ordered.keys.toList()..sort())
                  writer.time('EXDATE', ordered[key]!),
              ])
            else if (!own.any((event) => identical(entry, event.source)))
              entry,
        ]),
      ]);
    }
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: projectionBasis,
      originalStart: anchor,
      sharedWorkBudget: work,
    );
    final candidateBytes = serializeIcalendarSyntax(
      candidate,
      limits: const IcalendarSyntaxLimits(maxBytes: limit),
    );
    final sourceBytes = utf8.encode(basis);
    final values = ordered.keys.toList()..sort();
    final encoded = jsonEncode({
      'version': 1,
      'anchor': anchor.toJson(),
      'basis': basis,
      'basisDigest': sha256.convert(sourceBytes).toString(),
      'candidate': utf8.decode(candidateBytes),
      'candidateDigest': sha256.convert(candidateBytes).toString(),
      'masks': [for (final key in values) ordered[key]!.toJson()],
    });
    if (utf8.encode(encoded).length > limit) {
      throw const RecurrenceLimitException('exceptionalProofBytes');
    }
    return ExceptionalRangeProof._(encoded);
  }

  /// Strictly rebuilds evidence; untrusted stored bytes never establish proof.
  static ExceptionalRangeProof read(
    String encoded, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    if (encoded.length > 524288 || utf8.encode(encoded).length > 524288) {
      throw const RecurrenceLimitException('exceptionalProofBytes');
    }
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    if (data.length != 7 || data['version'] != 1 || data['masks'] is! List) {
      throw const FormatException('Invalid exceptional range proof');
    }
    final rebuilt = create(
      basis: data['basis'] as String,
      anchor: CalendarEventTiming.fromJson(
        data['anchor'] as Map<String, dynamic>,
      ),
      masks: [
        for (final value in data['masks'] as List)
          CalendarEventTiming.fromJson(value as Map<String, dynamic>),
      ],
      sharedWorkBudget: sharedWorkBudget,
    );
    if (rebuilt.encoded != encoded) {
      throw const FormatException('Invalid exceptional range proof');
    }
    return rebuilt;
  }
}

/// Flat version-8 carrier. The caller must still validate the reconstructed
/// version-7 state and bind the proof to its authenticated basis and ledger.
final class ExceptionalRangeEnvelope {
  ExceptionalRangeEnvelope._(this.v7, this.proof, this.frozen);

  final Map<String, dynamic> v7;
  final ExceptionalRangeProof proof;
  final Map<String, dynamic>? frozen;

  static String write(
    Map<String, dynamic> v7,
    ExceptionalRangeProof proof, {
    Map<String, dynamic>? frozen,
  }) {
    if (v7['version'] != 7 ||
        v7.containsKey('exceptionalProof') ||
        v7.containsKey('exceptionalFrozen')) {
      throw const FormatException('Invalid exceptional range envelope');
    }
    if (frozen != null) _checkFrozen(frozen);
    final encoded = jsonEncode({
      ...v7,
      'version': 8,
      'exceptionalProof': proof.encoded,
      // Omission is part of the active-checkpoint representation.
      // ignore: use_null_aware_elements
      if (frozen != null) 'exceptionalFrozen': frozen,
    });
    if (utf8.encode(encoded).length > 524288) {
      throw const RecurrenceLimitException('exceptionalEnvelopeBytes');
    }
    return encoded;
  }

  static ExceptionalRangeEnvelope read(
    String encoded, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    if (encoded.length > 524288 || utf8.encode(encoded).length > 524288) {
      throw const RecurrenceLimitException('exceptionalEnvelopeBytes');
    }
    final value = jsonDecode(encoded) as Map<String, dynamic>;
    if (value['version'] != 8 || value['exceptionalProof'] is! String) {
      throw const FormatException('Invalid exceptional range envelope');
    }
    final proof = ExceptionalRangeProof.read(
      value.remove('exceptionalProof') as String,
      sharedWorkBudget: sharedWorkBudget,
    );
    final frozen = value.remove('exceptionalFrozen');
    if (frozen != null && frozen is! Map<String, dynamic>) {
      throw const FormatException('Invalid exceptional range envelope');
    }
    if (frozen != null) _checkFrozen(frozen as Map<String, dynamic>);
    value['version'] = 7;
    return ExceptionalRangeEnvelope._(
      Map.unmodifiable(value),
      proof,
      frozen == null ? null : Map.unmodifiable(frozen as Map<String, dynamic>),
    );
  }

  static void _checkFrozen(Map<String, dynamic> value) {
    if (value.length != 6 ||
        value['snapshot'] is! String ||
        value['projection'] is! String ||
        value['payload'] is! String ||
        value['method'] is! String ||
        value['sequence'] is! int ||
        value['stamp'] is! String) {
      throw const FormatException('Invalid exceptional range envelope');
    }
    final encoded = value['snapshot'] as String;
    if (encoded.length > 524288 || utf8.encode(encoded).length > 524288) {
      throw const RecurrenceLimitException('exceptionalEnvelopeBytes');
    }
    final snapshot = jsonDecode(encoded);
    if (snapshot is! Map || !{3, 6}.contains(snapshot['version'])) {
      throw const FormatException('Invalid exceptional range envelope');
    }
  }
}
