part of 'icalendar_event_calendar.dart';

final class IcalendarEventCategoryGroup {
  IcalendarEventCategoryGroup._(
    this.source,
    Iterable<String> values,
    this.language,
  ) : values = List.unmodifiable(values);
  final IcalendarSyntaxProperty source;
  final List<String> values;
  final String? language;
}

/// Source metadata grants no host authority and triggers no URI retrieval.
final class IcalendarEventMetadata {
  IcalendarEventMetadata._({
    this.url,
    this.priority,
    this.geographicPosition,
    required Iterable<IcalendarSchedulingResourceGroup> resources,
    this.classification,
    required Iterable<IcalendarEventCategoryGroup> categoryGroups,
    required Iterable<IcalendarEventText> comments,
    required Iterable<IcalendarEventText> contacts,
  }) : resources = List.unmodifiable(resources),
       categoryGroups = List.unmodifiable(categoryGroups),
       comments = List.unmodifiable(comments),
       contacts = List.unmodifiable(contacts);
  final String? url, classification;
  final int? priority;
  final IcalendarSchedulingGeographicPosition? geographicPosition;
  final List<IcalendarSchedulingResourceGroup> resources;
  final List<IcalendarEventCategoryGroup> categoryGroups;
  final List<IcalendarEventText> comments, contacts;
}

const _eventRepeatedMetadata = {
  'CATEGORIES',
  'COMMENT',
  'CONTACT',
  'RESOURCES',
};
const _eventMetadataProperties = {
  'URL',
  'CLASS',
  'GEO',
  'PRIORITY',
  ..._eventRepeatedMetadata,
};

IcalendarEventMetadata _eventMetadata(
  IcalendarSyntaxComponent source,
  ComponentBudget budget,
) {
  void charge(String? value) {
    if (value != null) budget.eventMetadata(value.runes.length);
  }

  final descriptive = _eventDescriptiveMetadata(
    source.entries.whereType<IcalendarSyntaxProperty>().where(
      (p) => {'GEO', 'PRIORITY', 'RESOURCES'}.contains(p.canonicalName),
    ),
    budget,
  );
  final groups = <IcalendarEventCategoryGroup>[];
  final comments = <IcalendarEventText>[], contacts = <IcalendarEventText>[];
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
        groups.add(IcalendarEventCategoryGroup._(p, values, language));
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
        target.add(value);
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
  return IcalendarEventMetadata._(
    url: url,
    priority: descriptive.priority,
    geographicPosition: descriptive.geographicPosition,
    resources: descriptive.resources,
    classification: classification,
    categoryGroups: groups,
    comments: comments,
    contacts: contacts,
  );
}

void _matchingEventMetadata(
  IcalendarEventMetadata master,
  IcalendarEventMetadata override,
) {
  bool sameText(IcalendarEventText a, IcalendarEventText b) =>
      a.value == b.value &&
      a.language == b.language &&
      a.alternativeUri == b.alternativeUri;
  bool sameList<T>(List<T> a, List<T> b, bool Function(T, T) same) =>
      a.isEmpty ||
      (a.length == b.length &&
          List.generate(a.length, (i) => same(a[i], b[i])).every((v) => v));
  if ((override.priority != null && override.priority != master.priority) ||
      (override.geographicPosition != null &&
          (override.geographicPosition!.latitudeText !=
                  master.geographicPosition?.latitudeText ||
              override.geographicPosition!.longitudeText !=
                  master.geographicPosition?.longitudeText)) ||
      !sameList(
        override.resources,
        master.resources,
        (a, b) =>
            a.language == b.language &&
            a.alternativeUri == b.alternativeUri &&
            a.values.length == b.values.length &&
            List.generate(
              a.values.length,
              (i) => a.values[i] == b.values[i],
            ).every((v) => v),
      ) ||
      (override.url != null && override.url != master.url) ||
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

IcalendarEventMetadata _inheritedEventMetadata(
  IcalendarEventMetadata master,
  IcalendarEventMetadata own,
) => IcalendarEventMetadata._(
  url: own.url ?? master.url,
  priority: own.priority ?? master.priority,
  geographicPosition: own.geographicPosition ?? master.geographicPosition,
  resources: own.resources.isEmpty ? master.resources : own.resources,
  classification: own.classification ?? master.classification,
  categoryGroups: own.categoryGroups.isEmpty
      ? master.categoryGroups
      : own.categoryGroups,
  comments: own.comments.isEmpty ? master.comments : own.comments,
  contacts: own.contacts.isEmpty ? master.contacts : own.contacts,
);
