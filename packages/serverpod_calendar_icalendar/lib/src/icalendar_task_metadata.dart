part of 'icalendar_event_calendar.dart';

final class IcalendarTaskCategoryGroup {
  IcalendarTaskCategoryGroup._(
    this.source,
    Iterable<String> values,
    this.language,
  ) : values = List.unmodifiable(values);
  final IcalendarSyntaxProperty source;
  final List<String> values;
  final String? language;
}

/// Source metadata grants no host authority and triggers no URI retrieval.
final class IcalendarTaskMetadata {
  IcalendarTaskMetadata._({
    this.url,
    this.classification,
    required Iterable<IcalendarTaskCategoryGroup> categoryGroups,
    required Iterable<IcalendarTaskText> comments,
    required Iterable<IcalendarTaskText> contacts,
  }) : categoryGroups = List.unmodifiable(categoryGroups),
       comments = List.unmodifiable(comments),
       contacts = List.unmodifiable(contacts);
  final String? url, classification;
  final List<IcalendarTaskCategoryGroup> categoryGroups;
  final List<IcalendarTaskText> comments, contacts;
}

const _taskRepeatedMetadata = {'CATEGORIES', 'COMMENT', 'CONTACT'};
const _taskMetadataProperties = {'URL', 'CLASS', ..._taskRepeatedMetadata};

IcalendarTaskMetadata _taskMetadata(
  IcalendarSyntaxComponent source,
  ComponentBudget budget,
) {
  void charge(String? value) {
    if (value != null) budget.taskMetadata(value.runes.length);
  }

  final groups = <IcalendarTaskCategoryGroup>[];
  final comments = <IcalendarTaskText>[], contacts = <IcalendarTaskText>[];
  String? url, classification;
  var categoryCount = 0;
  for (final p in source.entries.whereType<IcalendarSyntaxProperty>()) {
    switch (p.canonicalName) {
      case 'CATEGORIES':
        final parameters = componentParameters(p, {'LANGUAGE'}),
            language = parameters['LANGUAGE'];
        if (language != null) validateCalendarLanguageTag(language);
        charge(language);
        final values = <String>[];
        for (final raw in _componentTextList(p.value)) {
          if (++categoryCount > 64) {
            componentFail(IcalendarComponentError.limitExceeded);
          }
          final value = decodeIcalendarText(raw);
          IcalendarCategory(value, language: language);
          charge(value);
          values.add(value);
        }
        groups.add(IcalendarTaskCategoryGroup._(p, values, language));
      case 'COMMENT':
      case 'CONTACT':
        final target = p.canonicalName == 'COMMENT' ? comments : contacts;
        if (target.length >= 32) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        final value = _componentTextValue(p, 4096)!;
        charge(value.value);
        charge(value.language);
        charge(value.alternativeUri);
        target.add(IcalendarTaskText._(value));
      case 'URL':
        componentParameters(p, {});
        componentUri(p.value);
        validateCalendarHttpUri(p.value);
        url = p.value;
        charge(url);
      case 'CLASS':
        componentParameters(p, {});
        classification = componentToken(p.value);
        if (!{'PUBLIC', 'PRIVATE', 'CONFIDENTIAL'}.contains(classification)) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        charge(p.value);
    }
  }
  return IcalendarTaskMetadata._(
    url: url,
    classification: classification,
    categoryGroups: groups,
    comments: comments,
    contacts: contacts,
  );
}

void _matchingTaskMetadata(
  IcalendarTaskMetadata master,
  IcalendarTaskMetadata override,
) {
  bool sameText(IcalendarTaskText a, IcalendarTaskText b) =>
      a.value == b.value &&
      a.language == b.language &&
      a.alternativeUri == b.alternativeUri;
  bool sameList<T>(List<T> a, List<T> b, bool Function(T, T) same) =>
      a.isEmpty ||
      (a.length == b.length &&
          List.generate(a.length, (i) => same(a[i], b[i])).every((v) => v));
  if ((override.url != null && override.url != master.url) ||
      (override.classification != null &&
          override.classification != (master.classification ?? 'PUBLIC')) ||
      !sameList(
        override.categoryGroups,
        master.categoryGroups,
        (a, b) =>
            a.language == b.language &&
            a.values.length == b.values.length &&
            List.generate(
              a.values.length,
              (i) => a.values[i] == b.values[i],
            ).every((v) => v),
      ) ||
      !sameList(override.comments, master.comments, sameText) ||
      !sameList(override.contacts, master.contacts, sameText)) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
}

IcalendarTaskMetadata _inheritedTaskMetadata(
  IcalendarTaskMetadata master,
  IcalendarTaskMetadata override,
) => IcalendarTaskMetadata._(
  url: override.url ?? master.url,
  classification: override.classification ?? master.classification,
  categoryGroups: override.categoryGroups.isEmpty
      ? master.categoryGroups
      : override.categoryGroups,
  comments: override.comments.isEmpty ? master.comments : override.comments,
  contacts: override.contacts.isEmpty ? master.contacts : override.contacts,
);
