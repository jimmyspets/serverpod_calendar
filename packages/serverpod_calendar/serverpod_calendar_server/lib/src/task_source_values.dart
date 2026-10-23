import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'event_protocol_values.dart';
import 'event_wire_output.dart';
import 'generated/protocol.dart';
import 'task_values.dart';
import 'task_recurrence_values.dart';

const taskBaselineMaxBytes = 2097152;
String get taskBaselineProfile =>
    'task-source-v2/${NamedZoneResolver.dataVersion}';

/// A pure, validated proposal. It grants no authority and persists nothing.
final class TaskStorageProposal {
  TaskStorageProposal._(this.protocolUid, this.state, this.importBaseline);
  final String protocolUid;
  final CalendarTaskSourceState state;
  final CalendarTaskImportBaseline importBaseline;
}

CalendarEventDuration _duration(CalendarDuration d) => CalendarEventDuration(
  weeks: d.weeks,
  days: d.days,
  hours: d.hours,
  minutes: d.minutes,
  seconds: d.seconds,
  microsecond: d.microsecond,
);
CalendarTaskSourceDuration _signed(CalendarDuration d) =>
    CalendarTaskSourceDuration(
      sign: d.sign,
      weeks: d.weeks,
      days: d.days,
      hours: d.hours,
      minutes: d.minutes,
      seconds: d.seconds,
    );
CalendarEventTiming _anchor(Object v) => v is CalendarDate
    ? CalendarEventTiming(kind: CalendarEventTimeKind.date, start: eventDate(v))
    : CalendarEventTiming(
        kind: (v as TimedValue).zoneId == null
            ? CalendarEventTimeKind.utc
            : CalendarEventTimeKind.zoned,
        zoneId: v.zoneId,
        start: eventCivil(v.civil),
      );
CalendarTaskTiming _timing(IcalendarTask t) {
  final d = t.dateTiming, z = t.timedTiming;
  if (d != null) {
    return CalendarTaskTiming(
      kind: CalendarTaskTimeKind.date,
      start: d.start == null ? null : eventDate(d.start!),
      due: d.due == null ? null : eventDate(d.due!),
      duration: d.duration == null ? null : _duration(d.duration!),
    );
  }
  if (z != null) {
    return CalendarTaskTiming(
      kind: (z.start ?? z.due)!.zoneId == null
          ? CalendarTaskTimeKind.utc
          : CalendarTaskTimeKind.zoned,
      zoneId: (z.start ?? z.due)!.zoneId,
      start: z.start == null ? null : eventCivil(z.start!.civil),
      due: z.due == null ? null : eventCivil(z.due!.civil),
      duration: z.duration == null ? null : _duration(z.duration!),
    );
  }
  return CalendarTaskTiming(kind: CalendarTaskTimeKind.undated);
}

CalendarTextParameters? _parameters(String? language, String? uri) =>
    language == null && uri == null
    ? null
    : CalendarTextParameters(language: language, alternativeUri: uri);
CalendarTaskSourceText _text(IcalendarTaskText v) => CalendarTaskSourceText(
  value: v.value,
  parameters: _parameters(v.language, v.alternativeUri),
);
CalendarTaskSourceParticipant _participant(IcalendarTaskParticipant v) =>
    CalendarTaskSourceParticipant(
      address: v.address,
      parameters: Map.unmodifiable(
        v.parameters.map((k, v) => MapEntry(k, List<String>.unmodifiable(v))),
      ),
    );
CalendarTaskSourceMetadata emptyTaskSourceMetadata() =>
    CalendarTaskSourceMetadata(
      categoryGroups: const [],
      comments: const [],
      contacts: const [],
      attendees: const [],
      relationships: const [],
      attachments: const [],
      alarms: const [],
    );
CalendarTaskSourceMetadata _metadata(IcalendarTask t) =>
    CalendarTaskSourceMetadata(
      url: t.metadata.url,
      classification: t.metadata.classification,
      categoryGroups: List.unmodifiable(
        t.metadata.categoryGroups.map(
          (g) => CalendarTaskSourceCategoryGroup(
            values: List.unmodifiable(g.values),
            language: g.language,
          ),
        ),
      ),
      comments: List.unmodifiable(t.metadata.comments.map(_text)),
      contacts: List.unmodifiable(t.metadata.contacts.map(_text)),
      organizer: t.participants.organizer == null
          ? null
          : _participant(t.participants.organizer!),
      attendees: List.unmodifiable(t.participants.attendees.map(_participant)),
      relationships: List.unmodifiable(
        t.references.relationships.map(
          (r) => CalendarTaskSourceRelationship(
            targetUid: r.targetUid,
            relationType: r.relationType,
          ),
        ),
      ),
      attachments: List.unmodifiable(
        t.references.attachments.map(
          (a) => CalendarTaskSourceAttachment(
            uri: a.uri,
            mediaType: a.mediaType,
            explicitUri: a.source.parameters.any(
              (p) => p.canonicalName == 'VALUE',
            ),
          ),
        ),
      ),
      alarms: List.unmodifiable(
        t.alarms.map(
          (a) => CalendarTaskSourceAlarm(
            description: CalendarTaskSourceText(
              value: a.description.value,
              parameters: _parameters(
                a.description.language,
                a.description.alternativeUri,
              ),
            ),
            relativeDuration: a.trigger.relativeDuration == null
                ? null
                : _signed(a.trigger.relativeDuration!),
            absoluteUtc: a.trigger.absoluteUtc,
            related: a.trigger.related,
            uid: a.uid,
            acknowledged: a.acknowledged,
            repeat: a.repeat,
            repeatInterval: a.repeatInterval == null
                ? null
                : _signed(a.repeatInterval!),
            snoozeTargetUid: a.snoozeTargetUid,
          ),
        ),
      ),
    );
CalendarEventRule _rule(DateRecurrenceRule d, TimedRecurrenceRule? t) =>
    CalendarEventRule(
      frequency: t == null
          ? CalendarEventFrequency.values[d.frequency.index + 2]
          : CalendarEventFrequency.values[t.frequency.index],
      interval: t?.interval ?? d.interval,
      count: t?.count ?? d.count,
      untilDate: d.until == null ? null : eventDate(d.until!),
      untilUtc: t?.until,
      weekStart: d.weekStart.isoNumber,
      byDay: [
        for (final v in d.byDay)
          CalendarEventByDay(weekday: v.weekday.isoNumber, ordinal: v.ordinal),
      ],
      byMonthDay: d.byMonthDay,
      byYearDay: d.byYearDay,
      byWeekNo: d.byWeekNo,
      byMonth: d.byMonth,
      byHour: t?.byHour ?? [],
      byMinute: t?.byMinute ?? [],
      bySetPosition: t?.bySetPosition ?? d.bySetPosition,
    );
CalendarEventRecurrence? _recurrence(IcalendarTaskRecurrence? v) {
  if (v == null) return null;
  final d = v.dateSet;
  final t = v.timedSet;
  final tr = t?.rule, dr = d?.rule ?? tr?.dateSelection;
  return CalendarEventRecurrence(
    rule: dr == null ? null : _rule(dr, tr),
    inclusions: List.unmodifiable(
      d != null ? d.inclusions.map(_anchor) : t!.inclusions.map(_anchor),
    ),
    exclusions: List.unmodifiable(
      d != null ? d.exclusions.map(_anchor) : t!.exclusions.map(_anchor),
    ),
  );
}

CalendarTaskSourceComponent _component(IcalendarTask t) =>
    CalendarTaskSourceComponent(
      originalStart: t.originalStart == null ? null : _anchor(t.originalStart!),
      version: validateTaskVersion(
        CalendarTaskProtocolVersion(
          sequence: t.sequence,
          stamp: t.stamp,
          created: t.created,
          lastModified: t.lastModified,
        ),
      ),
      content: validateTaskContent(
        CalendarTaskContent(
          summary: t.summary?.value,
          description: t.description?.value,
          location: t.location?.value,
          priority: t.priority,
          timing: _timing(t),
          recurrence: _recurrence(t.recurrence),
        ),
      ),
      progress: validateTaskProgress(
        CalendarTaskProgress(
          status: t.status == null
              ? null
              : CalendarTaskStatus.values.byName(t.status!.name),
          percentComplete: t.percentComplete,
          completedAt: t.completed,
        ),
      ),
      textParameters: CalendarEventTextParameters(
        summary: _parameters(t.summary?.language, t.summary?.alternativeUri),
        description: _parameters(
          t.description?.language,
          t.description?.alternativeUri,
        ),
        location: _parameters(t.location?.language, t.location?.alternativeUri),
      ),
      metadata: _metadata(t),
    );
CalendarTaskSourceState _state(IcalendarTaskSeries v) =>
    CalendarTaskSourceState(
      master: _component(v.master),
      occurrences: List.unmodifiable(
        v.overrides.map((o) => _component(o.component)),
      ),
    );
TaskStorageProposal taskStorageProposal(IcalendarTaskSeries source) {
  validateEventUid(source.master.uid);
  final state = _state(source);
  return TaskStorageProposal._(
    source.master.uid,
    state,
    taskImportBaseline(source.master.uid, state),
  );
}

Object? _canonical(Object? v) {
  if (v is Map) {
    final keys = v.keys.cast<String>().toList()..sort();
    return {for (final k in keys) k: _canonical(v[k])};
  }
  if (v is List) return v.map(_canonical).toList();
  return v;
}

String taskSourceJson(CalendarTaskSourceState state) =>
    jsonEncode(_canonical(state.toJson()));
CalendarTaskImportBaseline taskImportBaseline(
  String uid,
  CalendarTaskSourceState state,
) {
  validateEventUid(uid);
  final value = jsonEncode(_canonical({'uid': uid, 'state': state.toJson()}));
  if (utf8.encode(value).length > taskBaselineMaxBytes) {
    throw const RecurrenceLimitException('taskBaselineBytes');
  }
  return CalendarTaskImportBaseline(
    profile: taskBaselineProfile,
    canonicalValue: value,
    sourceSequence: state.master.version.sequence,
  );
}

void validateTaskImportBaseline(
  CalendarTaskImportBaseline baseline,
  String uid,
) {
  if (baseline.profile != taskBaselineProfile ||
      utf8.encode(baseline.canonicalValue).length > taskBaselineMaxBytes) {
    throw StateError('Unknown or oversized task baseline');
  }
  final v = jsonDecode(baseline.canonicalValue);
  if (v is! Map<String, dynamic> ||
      v['uid'] != uid ||
      v['state'] is! Map<String, dynamic>) {
    throw StateError('Invalid task baseline');
  }
  final state = validateTaskSourceState(
    uid,
    CalendarTaskSourceState.fromJson(v['state'] as Map<String, dynamic>),
  );
  final expected = taskImportBaseline(uid, state);
  if (expected.canonicalValue != baseline.canonicalValue ||
      expected.sourceSequence != baseline.sourceSequence) {
    throw StateError('Noncanonical task baseline');
  }
}

/// Rebuilds a fresh typed source model through the same strict profile. Returned
/// nested lists/maps are detached and frozen; no source URI is accessed.
CalendarTaskSourceState validateTaskSourceState(
  String uid,
  CalendarTaskSourceState value,
) {
  validateEventUid(uid);
  // Bound serialized input before zone generation or recurrence validation.
  taskImportBaseline(uid, value);
  final writer = _TaskWriter();
  final components = [
    writer.component(uid, value.master),
    for (final o in value.occurrences) writer.component(uid, o),
  ];
  final zones = writer.values.zones.toList()..sort();
  final parsed = validateIcalendarTaskCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        IcalendarSyntaxProperty('VERSION', '2.0'),
        IcalendarSyntaxProperty(
          'PRODID',
          '-//Serverpod Calendar//Task source state//EN',
        ),
        for (final zone in zones) createIcalendarTimeZone(zone),
        ...components,
      ]),
    ]),
  );
  if (parsed.series.length != 1) {
    throw ArgumentError('Expected one task series');
  }
  final result = _state(parsed.series.single);
  if (taskSourceJson(result) != taskSourceJson(value)) {
    throw ArgumentError('Task source state is not faithfully representable');
  }
  return result;
}

final class _TaskWriter {
  final values = EventComponentWriter();
  IcalendarSyntaxParameter parameter(String n, String v) =>
      IcalendarSyntaxParameter(n, [v]);
  IcalendarSyntaxProperty property(
    String n,
    String v, [
    List<IcalendarSyntaxParameter> p = const [],
  ]) => IcalendarSyntaxProperty(n, v, parameters: p);
  IcalendarSyntaxProperty text(String n, CalendarTaskSourceText t) =>
      values.text(n, t.value, t.parameters);
  String duration(CalendarTaskSourceDuration d) => serializeIcalendarDuration(
    CalendarDuration(
      sign: d.sign,
      weeks: d.weeks,
      days: d.days,
      hours: d.hours,
      minutes: d.minutes,
      seconds: d.seconds,
    ),
  );
  IcalendarSyntaxProperty participant(
    String name,
    CalendarTaskSourceParticipant p,
  ) => property(name, p.address, [
    for (final e in p.parameters.entries)
      IcalendarSyntaxParameter(e.key, e.value),
  ]);
  List<IcalendarSyntaxEntry> metadata(CalendarTaskSourceMetadata m) => [
    if (m.url != null) property('URL', m.url!),
    if (m.classification != null) property('CLASS', m.classification!),
    for (final g in m.categoryGroups)
      property('CATEGORIES', g.values.map(encodeIcalendarText).join(','), [
        if (g.language != null) parameter('LANGUAGE', g.language!),
      ]),
    for (final t in m.comments) text('COMMENT', t),
    for (final t in m.contacts) text('CONTACT', t),
    if (m.organizer != null) participant('ORGANIZER', m.organizer!),
    for (final p in m.attendees) participant('ATTENDEE', p),
    for (final r in m.relationships)
      property('RELATED-TO', encodeIcalendarText(r.targetUid), [
        if (r.relationType != null) parameter('RELTYPE', r.relationType!),
      ]),
    for (final a in m.attachments)
      property('ATTACH', a.uri, [
        if (a.explicitUri) parameter('VALUE', 'URI'),
        if (a.mediaType != null) parameter('FMTTYPE', a.mediaType!),
      ]),
    for (final a in m.alarms)
      IcalendarSyntaxComponent('VALARM', [
        property('ACTION', 'DISPLAY'),
        text('DESCRIPTION', a.description),
        property(
          'TRIGGER',
          a.absoluteUtc == null
              ? duration(
                  a.relativeDuration ??
                      (throw ArgumentError('Missing alarm trigger')),
                )
              : values.utc(a.absoluteUtc!),
          [
            if (a.absoluteUtc != null) parameter('VALUE', 'DATE-TIME'),
            if (a.related != null) parameter('RELATED', a.related!),
          ],
        ),
        if (a.absoluteUtc != null && a.relativeDuration != null)
          throw ArgumentError('Conflicting alarm trigger'),
        if (a.uid != null) property('UID', encodeIcalendarText(a.uid!)),
        if (a.acknowledged != null)
          property('ACKNOWLEDGED', values.utc(a.acknowledged!)),
        if (a.repeat != null) property('REPEAT', '${a.repeat}'),
        if (a.repeatInterval != null)
          property('DURATION', duration(a.repeatInterval!)),
        if (a.snoozeTargetUid != null)
          property('RELATED-TO', encodeIcalendarText(a.snoozeTargetUid!), [
            parameter('RELTYPE', 'SNOOZE'),
          ]),
      ]),
  ];
  IcalendarSyntaxComponent component(
    String uid,
    CalendarTaskSourceComponent c,
  ) {
    validateTaskContent(c.content);
    validateTaskProgress(c.progress);
    validateTaskVersion(c.version);
    final t = c.content.timing, annotations = c.textParameters;
    final CalendarEventTiming? anchor = t.kind == CalendarTaskTimeKind.undated
        ? null
        : CalendarEventTiming(
            kind: CalendarEventTimeKind.values.byName(t.kind.name),
            zoneId: t.zoneId,
            start: t.start ?? t.due!,
          );
    return IcalendarSyntaxComponent('VTODO', [
      property('UID', encodeIcalendarText(uid)),
      ...values.stamps(
        c.version.stamp,
        c.version.created,
        c.version.lastModified,
      ),
      if (c.version.sequence != null)
        property('SEQUENCE', '${c.version.sequence}'),
      if (c.originalStart != null)
        values.time('RECURRENCE-ID', c.originalStart!),
      if (t.start != null)
        values.time('DTSTART', anchor!.copyWith(start: t.start)),
      if (t.due != null) values.time('DUE', anchor!.copyWith(start: t.due)),
      if (t.duration != null)
        property('DURATION', values.duration(t.duration!)),
      if (c.content.summary != null)
        values.text('SUMMARY', c.content.summary!, annotations?.summary),
      if (c.content.description != null)
        values.text(
          'DESCRIPTION',
          c.content.description!,
          annotations?.description,
        ),
      if (c.content.location != null)
        values.text('LOCATION', c.content.location!, annotations?.location),
      if (c.content.priority != null)
        property('PRIORITY', '${c.content.priority}'),
      if (c.progress.status != null)
        property('STATUS', switch (c.progress.status!) {
          CalendarTaskStatus.needsAction => 'NEEDS-ACTION',
          CalendarTaskStatus.inProcess => 'IN-PROCESS',
          CalendarTaskStatus.completed => 'COMPLETED',
          CalendarTaskStatus.cancelled => 'CANCELLED',
        }),
      if (c.progress.percentComplete != null)
        property('PERCENT-COMPLETE', '${c.progress.percentComplete}'),
      if (c.progress.completedAt != null)
        property('COMPLETED', values.utc(c.progress.completedAt!)),
      if (c.content.recurrence?.rule != null)
        property('RRULE', values.rule(c.content.recurrence!.rule!)),
      for (final d
          in c.content.recurrence?.inclusions ?? <CalendarEventTiming>[])
        values.time('RDATE', d),
      for (final d
          in c.content.recurrence?.exclusions ?? <CalendarEventTiming>[])
        values.time('EXDATE', d),
      ...metadata(c.metadata),
    ]);
  }
}

/// Retains explicit component content and annotations when a master is edited.
/// Explicit timing replacements stay independent; invalid anchors/metadata reject.
CalendarTaskSourceState changeTaskSourceMaster(
  String uid,
  CalendarTaskSourceState before,
  CalendarTaskContent content,
  CalendarTaskProgress progress,
  CalendarTaskProtocolVersion version,
  DateTime now,
) {
  final result = before.copyWith(
    master: before.master.copyWith(
      content: content,
      progress: progress,
      version: version,
    ),
    occurrences: [
      for (final o in before.occurrences)
        (() {
          final c = o.content;
          final next = c.copyWith(
            summary: c.summary == null ? null : content.summary,
            description: c.description == null ? null : content.description,
            location: c.location == null ? null : content.location,
            priority: c.priority == null ? null : content.priority ?? 0,
          );
          final parameters = o.textParameters!.copyWith(
            summary: next.summary == null ? null : o.textParameters!.summary,
            description: next.description == null
                ? null
                : o.textParameters!.description,
            location: next.location == null ? null : o.textParameters!.location,
          );
          final changed = next != c || parameters != o.textParameters;
          return o.copyWith(
            content: next,
            textParameters: parameters,
            version: changed ? advanceTaskVersion(o.version, now) : o.version,
          );
        })(),
    ],
  );
  return validateTaskSourceState(uid, result);
}

CalendarTaskProtocolVersion taskOccurrenceInitialVersion(
  DateTime now, {
  bool legacy = false,
}) => CalendarTaskProtocolVersion(
  sequence: 0,
  stamp: eventProtocolInstant(now),
  created: legacy ? null : eventProtocolInstant(now),
  lastModified: eventProtocolInstant(now),
);
CalendarTaskSourceState changeTaskSourceOccurrence(
  String uid,
  CalendarTaskSourceState before,
  CalendarEventTiming original,
  CalendarTaskProgress progress,
  CalendarTaskProtocolVersion version,
) {
  final key = taskOriginalKey(original);
  var found = false;
  final components = [
    for (final o in before.occurrences)
      if (taskOriginalKey(o.originalStart!) == key)
        (() {
          found = true;
          return o.copyWith(progress: progress, version: version);
        })()
      else
        o,
  ];
  if (!found) {
    components.add(
      CalendarTaskSourceComponent(
        originalStart: original,
        version: version,
        progress: progress,
        content: CalendarTaskContent(
          timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
        ),
        textParameters: CalendarEventTextParameters(),
        metadata: emptyTaskSourceMetadata(),
      ),
    );
  }
  return validateTaskSourceState(uid, before.copyWith(occurrences: components));
}

/// Serialize complete current series, never historical import snapshots.
List<int> taskExportBytes(
  List<({String uid, CalendarTaskSourceState state})> members,
) {
  if (members.isEmpty ||
      members.map((m) => m.uid).toSet().length != members.length) {
    throw ArgumentError('Empty or duplicate task selection');
  }
  final writer = _TaskWriter();
  final components = [
    for (final m in members) ...[
      writer.component(m.uid, m.state.master),
      for (final o in m.state.occurrences) writer.component(m.uid, o),
    ],
  ];
  final zones = writer.values.zones.toList()..sort();
  final parsed = validateIcalendarTaskCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        IcalendarSyntaxProperty('VERSION', '2.0'),
        IcalendarSyntaxProperty('PRODID', '-//Serverpod Calendar//Tasks//EN'),
        for (final zone in zones) createIcalendarTimeZone(zone),
        ...components,
      ]),
    ]),
  );
  if (parsed.series.length != members.length) {
    throw ArgumentError('Task count mismatch');
  }
  final expected = {for (final m in members) m.uid: m.state};
  for (final series in parsed.series) {
    if (taskSourceJson(_state(series)) !=
        taskSourceJson(expected[series.master.uid]!)) {
      throw ArgumentError('Current task state is not faithfully representable');
    }
  }
  return serializeIcalendarTaskCalendar(parsed);
}

CalendarTaskTiming? taskSourceReplacement(CalendarTaskSourceComponent c) =>
    c.content.timing.start == null ? null : c.content.timing;

CalendarTaskSourceState changeTaskSourceTiming(
  String uid,
  CalendarTaskSourceState before,
  CalendarEventTiming original,
  CalendarTaskTiming? replacement,
  CalendarTaskProgress progress,
  CalendarTaskProtocolVersion version,
) {
  final key = taskOriginalKey(original);
  final existing = before.occurrences
      .where((o) => taskOriginalKey(o.originalStart!) == key)
      .firstOrNull;
  final timing =
      replacement ?? CalendarTaskTiming(kind: CalendarTaskTimeKind.undated);
  final next = existing == null
      ? CalendarTaskSourceComponent(
          originalStart: original,
          version: version,
          content: CalendarTaskContent(timing: timing),
          progress: progress,
          textParameters: CalendarEventTextParameters(),
          metadata: emptyTaskSourceMetadata(),
        )
      : existing.copyWith(
          version: version,
          content: existing.content.copyWith(timing: timing),
        );
  return validateTaskSourceState(
    uid,
    before.copyWith(
      occurrences: [
        for (final o in before.occurrences)
          if (taskOriginalKey(o.originalStart!) != key) o,
        next,
      ],
    ),
  );
}
