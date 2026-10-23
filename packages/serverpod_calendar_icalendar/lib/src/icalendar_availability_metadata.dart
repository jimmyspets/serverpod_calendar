part of 'icalendar_event_calendar.dart';

enum IcalendarAvailabilityExtensionContext { definition, opening }

/// Trusted pure validation, never host authorization or extension execution.
final class IcalendarAvailabilityExtensionRegistration {
  IcalendarAvailabilityExtensionRegistration({
    required this.name,
    required Iterable<IcalendarAvailabilityExtensionContext> contexts,
    required this.validateText,
  }) : contexts = Set.unmodifiable(contexts) {
    _privateAvailabilityName(name);
    if (this.contexts.isEmpty) {
      throw ArgumentError('Extension contexts required');
    }
  }
  final String name;
  final Set<IcalendarAvailabilityExtensionContext> contexts;
  final bool Function(String value) validateText;
}

/// A snapshot supplied by trusted application code, never by ICS input.
final class IcalendarAvailabilityExtensionRegistry {
  IcalendarAvailabilityExtensionRegistry([
    Iterable<IcalendarAvailabilityExtensionRegistration> registrations =
        const [],
  ]) {
    final values = <String, IcalendarAvailabilityExtensionRegistration>{};
    for (final r in registrations) {
      if (values.length >= 32 || values.containsKey(r.name.toUpperCase())) {
        throw ArgumentError('Too many or duplicate extension registrations');
      }
      values[r.name.toUpperCase()] = r;
    }
    _values = Map.unmodifiable(values);
  }
  late final Map<String, IcalendarAvailabilityExtensionRegistration> _values;
  Set<String> _names(IcalendarAvailabilityExtensionContext context) => {
    for (final r in _values.values.where((r) => r.contexts.contains(context)))
      r.name.toUpperCase(),
  };
}

final class IcalendarAvailabilityCategoryGroup {
  IcalendarAvailabilityCategoryGroup._(
    this.source,
    List<String> values,
    this.language,
  ) : values = List.unmodifiable(values);
  final IcalendarSyntaxProperty source;
  final List<String> values;
  final String? language;
}

final class IcalendarAvailabilityOrganizer {
  IcalendarAvailabilityOrganizer._(
    this.address,
    this.commonName,
    this.language,
    this.directoryUri,
  );
  final String address;
  final String? commonName, language, directoryUri;
}

final class IcalendarAvailabilityExtensionValue {
  IcalendarAvailabilityExtensionValue._(this.source, this.value);
  final IcalendarSyntaxProperty source;
  String get name => source.name;
  final String value;
}

/// Preserved decoded source groups. None of these values are host-approved.
final class IcalendarAvailabilityMetadata {
  IcalendarAvailabilityMetadata._({
    this.organizer,
    this.url,
    this.classification,
    required List<IcalendarAvailabilityCategoryGroup> categories,
    required List<IcalendarEventText> comments,
    required List<IcalendarEventText> contacts,
    required List<IcalendarAvailabilityExtensionValue> extensions,
  }) : categoryGroups = List.unmodifiable(categories),
       comments = List.unmodifiable(comments),
       contacts = List.unmodifiable(contacts),
       extensions = List.unmodifiable(extensions);
  final IcalendarAvailabilityOrganizer? organizer;
  final String? url, classification;
  final List<IcalendarAvailabilityCategoryGroup> categoryGroups;
  final List<IcalendarEventText> comments, contacts;
  final List<IcalendarAvailabilityExtensionValue> extensions;
}

void _privateAvailabilityName(String name) {
  final m = RegExp(
    r'X-[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*',
    caseSensitive: false,
  ).firstMatch(name);
  if (name.length > 64 || m == null || m.start != 0 || m.end != name.length) {
    throw ArgumentError('Private extension name required');
  }
}

const _availabilityRepeatedMetadata = {'CATEGORIES', 'COMMENT', 'CONTACT'};
const _availabilityDefinitionMetadata = {
  'ORGANIZER',
  'URL',
  'CLASS',
  ..._availabilityRepeatedMetadata,
};

IcalendarAvailabilityMetadata _publicationMetadata(
  IcalendarSyntaxComponent source,
  IcalendarAvailabilityExtensionContext context,
  ComponentBudget budget,
  IcalendarAvailabilityExtensionRegistry registry,
  Iterable<IcalendarEventText?> basic,
) {
  void charge(String? value) {
    if (value != null) budget.metadata(value.runes.length);
  }

  void text(IcalendarEventText? v) {
    if (v == null) return;
    charge(v.value);
    charge(v.language);
    charge(v.alternativeUri);
  }

  for (final v in basic) {
    text(v);
  }
  final categories = <IcalendarAvailabilityCategoryGroup>[];
  final comments = <IcalendarEventText>[], contacts = <IcalendarEventText>[];
  final extensions = <IcalendarAvailabilityExtensionValue>[];
  IcalendarAvailabilityOrganizer? organizer;
  String? url, classification;
  var categoryCount = 0;
  final privateNames = <String>{};
  for (final p in source.entries.whereType<IcalendarSyntaxProperty>()) {
    switch (p.canonicalName) {
      case 'CATEGORIES':
        final parameters = componentParameters(p, {'LANGUAGE'});
        final language = parameters['LANGUAGE'];
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
        categories.add(
          IcalendarAvailabilityCategoryGroup._(p, values, language),
        );
      case 'COMMENT':
      case 'CONTACT':
        final target = p.canonicalName == 'COMMENT' ? comments : contacts;
        if (target.length >= 32) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        final value = _componentTextValue(p, 4096)!;
        text(value);
        target.add(value);
      case 'ORGANIZER':
        if (context != IcalendarAvailabilityExtensionContext.definition) {
          componentFail(IcalendarComponentError.unsupportedProperty);
        }
        final parameters = componentParameters(p, {'CN', 'LANGUAGE', 'DIR'});
        componentUri(p.value);
        if (p.value.length > 1024) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        final name = parameters['CN'],
            language = parameters['LANGUAGE'],
            directory = parameters['DIR'];
        if (name != null) validateCalendarPlainText(name, maxCodePoints: 4096);
        if (language != null) {
          if (name == null) componentFail(IcalendarComponentError.invalidValue);
          validateCalendarLanguageTag(language);
        }
        if (directory != null) componentUri(directory);
        organizer = IcalendarAvailabilityOrganizer._(
          p.value,
          name,
          language,
          directory,
        );
        charge(p.value);
        charge(name);
        charge(language);
        charge(directory);
      case 'URL':
        if (context != IcalendarAvailabilityExtensionContext.definition) {
          componentFail(IcalendarComponentError.unsupportedProperty);
        }
        componentParameters(p, {});
        componentUri(p.value);
        validateCalendarHttpUri(p.value);
        url = p.value;
        charge(url);
      case 'CLASS':
        if (context != IcalendarAvailabilityExtensionContext.definition) {
          componentFail(IcalendarComponentError.unsupportedProperty);
        }
        componentParameters(p, {});
        classification = componentToken(p.value);
        if (!{'PUBLIC', 'PRIVATE', 'CONFIDENTIAL'}.contains(classification)) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        charge(p.value);
      default:
        if (!p.canonicalName.startsWith('X-')) continue;
        _privateAvailabilityName(p.name);
        if (!privateNames.add(p.canonicalName)) {
          componentFail(IcalendarComponentError.duplicate);
        }
        if (privateNames.length > 32) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        final registration = registry._values[p.canonicalName];
        if (registration == null || !registration.contexts.contains(context)) {
          componentFail(IcalendarComponentError.unsupportedProperty);
        }
        final value = componentText(p, maxPoints: 4096);
        charge(p.name);
        charge(value);
        bool accepted;
        try {
          accepted = registration.validateText(value);
        } catch (_) {
          componentFail(IcalendarComponentError.extensionValidationUnavailable);
        }
        if (!accepted) componentFail(IcalendarComponentError.invalidValue);
        extensions.add(IcalendarAvailabilityExtensionValue._(p, value));
    }
  }
  return IcalendarAvailabilityMetadata._(
    organizer: organizer,
    url: url,
    classification: classification,
    categories: categories,
    comments: comments,
    contacts: contacts,
    extensions: extensions,
  );
}

Iterable<String> _componentTextList(String raw) sync* {
  var start = 0;
  for (var i = 0; i < raw.length; i++) {
    if (raw.codeUnitAt(i) == 92) {
      i++;
    } else if (raw.codeUnitAt(i) == 44) {
      yield raw.substring(start, i);
      start = i + 1;
    }
  }
  yield raw.substring(start);
}

void _matchingPublicationMetadata(
  IcalendarAvailabilityMetadata master,
  IcalendarAvailabilityMetadata override,
) {
  bool sameText(IcalendarEventText a, IcalendarEventText b) =>
      a.value == b.value &&
      a.language == b.language &&
      a.alternativeUri == b.alternativeUri;
  bool sameList<T>(List<T> a, List<T> b, bool Function(T, T) same) =>
      a.isEmpty ||
      (a.length == b.length &&
          List.generate(a.length, (i) => same(a[i], b[i])).every((v) => v));
  if (!sameList(
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
  for (final v in override.extensions) {
    if (!master.extensions.any(
      (m) => m.name.toUpperCase() == v.name.toUpperCase() && m.value == v.value,
    )) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
  }
}
