import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'dart:convert';

import 'event_values.dart';
import 'generated/protocol.dart';

CalendarItemTextMetadataPatch eventTextMetadata(
  CalendarEventSourceMetadata? v,
) => CalendarItemTextMetadataPatch(
  selectedFields: CalendarItemTextMetadataField.values,
  url: v?.url,
  classification: v?.classification,
  categoryGroups: List.unmodifiable(
    (v?.categoryGroups ?? <CalendarEventSourceCategoryGroup>[]).map(
      (g) => CalendarItemCategoryGroup(
        values: List.unmodifiable(g.values),
        language: g.language,
      ),
    ),
  ),
  comments: List.unmodifiable(
    (v?.comments ?? <CalendarEventSourceText>[]).map(
      (c) => CalendarItemComment(value: c.value, parameters: c.parameters),
    ),
  ),
);
CalendarItemTextMetadataPatch taskTextMetadata(CalendarTaskSourceMetadata? v) =>
    CalendarItemTextMetadataPatch(
      selectedFields: CalendarItemTextMetadataField.values,
      url: v?.url,
      classification: v?.classification,
      categoryGroups: List.unmodifiable(
        (v?.categoryGroups ?? <CalendarTaskSourceCategoryGroup>[]).map(
          (g) => CalendarItemCategoryGroup(
            values: List.unmodifiable(g.values),
            language: g.language,
          ),
        ),
      ),
      comments: List.unmodifiable(
        (v?.comments ?? <CalendarTaskSourceText>[]).map(
          (c) => CalendarItemComment(value: c.value, parameters: c.parameters),
        ),
      ),
    );

CalendarItemTextMetadataPatch validateItemTextPatch(
  CalendarItemTextMetadataPatch p,
) {
  final selected = p.selectedFields.toSet();
  if (p.selectedFields.isEmpty ||
      p.selectedFields.length > 4 ||
      selected.length != p.selectedFields.length ||
      !selected.contains(CalendarItemTextMetadataField.url) && p.url != null ||
      !selected.contains(CalendarItemTextMetadataField.classification) &&
          p.classification != null ||
      selected.contains(CalendarItemTextMetadataField.categories) !=
          (p.categoryGroups != null) ||
      selected.contains(CalendarItemTextMetadataField.comments) !=
          (p.comments != null)) {
    throw ArgumentError('Invalid text metadata patch shape');
  }
  if ((p.categoryGroups?.length ?? 0) > 64 || (p.comments?.length ?? 0) > 32) {
    throw ArgumentError('Too many text metadata groups');
  }
  for (final c in p.comments ?? <CalendarItemComment>[]) {
    final uri = c.parameters?.alternativeUri;
    if (uri != null) {
      try {
        validateIcalendarMetadataUri(uri);
      } on IcalendarComponentException {
        throw ArgumentError('Invalid comment alternative URI');
      }
    }
  }
  final validated = validateEventSourceMetadata(
    CalendarEventSourceMetadata(
      url: p.url,
      classification: p.classification,
      categoryGroups: [
        for (final g in p.categoryGroups ?? <CalendarItemCategoryGroup>[])
          CalendarEventSourceCategoryGroup(
            values: g.values,
            language: g.language,
          ),
      ],
      comments: [
        for (final c in p.comments ?? <CalendarItemComment>[])
          CalendarEventSourceText(value: c.value, parameters: c.parameters),
      ],
      contacts: [],
    ),
  );
  final value = eventTextMetadata(validated);
  return value.copyWith(
    selectedFields: List.unmodifiable(p.selectedFields),
    categoryGroups: selected.contains(CalendarItemTextMetadataField.categories)
        ? value.categoryGroups
        : null,
    comments: selected.contains(CalendarItemTextMetadataField.comments)
        ? value.comments
        : null,
  );
}

CalendarEventSourceMetadata? applyEventTextPatch(
  CalendarEventSourceMetadata? v,
  CalendarItemTextMetadataPatch p,
) {
  final old =
          v ??
          CalendarEventSourceMetadata(
            categoryGroups: [],
            comments: [],
            contacts: [],
          ),
      s = p.selectedFields.toSet();
  return validateEventSourceMetadata(
    old.copyWith(
      url: s.contains(CalendarItemTextMetadataField.url) ? p.url : old.url,
      classification: s.contains(CalendarItemTextMetadataField.classification)
          ? p.classification
          : old.classification,
      categoryGroups: s.contains(CalendarItemTextMetadataField.categories)
          ? [
              for (final g in p.categoryGroups!)
                CalendarEventSourceCategoryGroup(
                  values: g.values,
                  language: g.language,
                ),
            ]
          : old.categoryGroups,
      comments: s.contains(CalendarItemTextMetadataField.comments)
          ? [
              for (final c in p.comments!)
                CalendarEventSourceText(
                  value: c.value,
                  parameters: c.parameters,
                ),
            ]
          : old.comments,
    ),
  );
}

CalendarTaskSourceMetadata applyTaskTextPatch(
  CalendarTaskSourceMetadata old,
  CalendarItemTextMetadataPatch p,
) {
  final s = p.selectedFields.toSet();
  return old.copyWith(
    url: s.contains(CalendarItemTextMetadataField.url) ? p.url : old.url,
    classification: s.contains(CalendarItemTextMetadataField.classification)
        ? p.classification
        : old.classification,
    categoryGroups: s.contains(CalendarItemTextMetadataField.categories)
        ? List.unmodifiable([
            for (final g in p.categoryGroups!)
              CalendarTaskSourceCategoryGroup(
                values: g.values,
                language: g.language,
              ),
          ])
        : old.categoryGroups,
    comments: s.contains(CalendarItemTextMetadataField.comments)
        ? List.unmodifiable([
            for (final c in p.comments!)
              CalendarTaskSourceText(value: c.value, parameters: c.parameters),
          ])
        : old.comments,
  );
}

/// Only the trusted native metadata service constructs this storage shape.
CalendarTaskSourceMetadata validateNativeTaskTextMetadata(
  CalendarTaskSourceMetadata m,
) {
  if (m.organizer != null ||
      m.contacts.isNotEmpty ||
      m.attendees.isNotEmpty ||
      m.relationships.isNotEmpty ||
      m.attachments.isNotEmpty ||
      m.alarms.isNotEmpty) {
    throw ArgumentError('Non-native source metadata');
  }
  return applyTaskTextPatch(m, validateItemTextPatch(taskTextMetadata(m)));
}

Object? _field(
  CalendarItemTextMetadataPatch p,
  CalendarItemTextMetadataField f,
) => switch (f) {
  CalendarItemTextMetadataField.url => p.url,
  CalendarItemTextMetadataField.classification => p.classification,
  CalendarItemTextMetadataField.categories =>
    p.categoryGroups!.map((g) => g.toJson()).toList(),
  CalendarItemTextMetadataField.comments =>
    p.comments!.map((c) => c.toJson()).toList(),
};
CalendarItemTextMetadataPatch? itemTextChanges(
  Map<String, CalendarItemTextMetadataPatch> before,
  Map<String, CalendarItemTextMetadataPatch> after,
) {
  String values(
    Map<String, CalendarItemTextMetadataPatch> input,
    CalendarItemTextMetadataField f,
  ) => jsonEncode({
    for (final k in input.keys.toList()..sort())
      if (k == 'master' ||
          (_field(input[k]!, f) is List
              ? (_field(input[k]!, f) as List).isNotEmpty
              : _field(input[k]!, f) != null))
        k: _field(input[k]!, f),
  });
  final selected = [
    for (final f in CalendarItemTextMetadataField.values)
      if (values(before, f) != values(after, f)) f,
  ];
  if (selected.isEmpty) return null;
  final master = after['master']!;
  return validateItemTextPatch(
    CalendarItemTextMetadataPatch(
      selectedFields: selected,
      url: selected.contains(CalendarItemTextMetadataField.url)
          ? master.url
          : null,
      classification:
          selected.contains(CalendarItemTextMetadataField.classification)
          ? master.classification
          : null,
      categoryGroups:
          selected.contains(CalendarItemTextMetadataField.categories)
          ? master.categoryGroups
          : null,
      comments: selected.contains(CalendarItemTextMetadataField.comments)
          ? master.comments
          : null,
    ),
  );
}

Map<String, CalendarItemTextMetadataPatch> eventTextState(
  CalendarEventProtocolState state,
  CalendarEventTimingOverrides? edits,
) => {
  'master': eventTextMetadata(state.sourceMetadata),
  for (final s in edits?.singles ?? <CalendarEventSingleOverride>[])
    jsonEncode([false, s.originalStart.toJson()]): eventTextMetadata(
      s.sourceMetadata,
    ),
  for (final s in edits?.future ?? <CalendarEventFutureOverride>[])
    jsonEncode([true, s.originalStart.toJson()]): eventTextMetadata(
      s.sourceMetadata,
    ),
};
Map<String, CalendarItemTextMetadataPatch> taskTextState(
  CalendarTaskSourceState state,
) => {
  'master': taskTextMetadata(state.master.metadata),
  for (final s in state.occurrences)
    jsonEncode([s.thisAndFuture == true, s.originalStart!.toJson()]):
        taskTextMetadata(s.metadata),
};
