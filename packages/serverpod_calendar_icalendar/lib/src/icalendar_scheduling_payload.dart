part of 'icalendar_event_calendar.dart';

/// Untrusted reported result. Numeric codes do not trigger actions or retries.
final class IcalendarSchedulingRequestStatus {
  IcalendarSchedulingRequestStatus._(
    this.code,
    Iterable<int> levels,
    this.description,
    this.extraData,
    this.language,
  ) : levels = List.unmodifiable(levels);
  final String code, description;
  final List<int> levels;
  final String? extraData, language;
}

/// Exact source decimals; no coordinate transformation or geocoding.
final class IcalendarSchedulingGeographicPosition {
  IcalendarSchedulingGeographicPosition._(
    this.latitudeText,
    this.longitudeText,
  );
  final String latitudeText, longitudeText;

  /// Approximate binary doubles; exact spellings above are retained for output.
  double get latitude => double.parse(latitudeText);
  double get longitude => double.parse(longitudeText);
}

/// Descriptive source labels, never host resource identities or bookings.
final class IcalendarSchedulingResourceGroup {
  IcalendarSchedulingResourceGroup._(
    Iterable<String> values,
    this.language,
    this.alternativeUri,
  ) : values = List.unmodifiable(values);
  final List<String> values;
  final String? language, alternativeUri;
}

List<IcalendarSchedulingRequestStatus> _schedulingRequestStatuses(
  List<IcalendarSyntaxProperty> properties,
  ComponentBudget budget,
) {
  if (properties.length > 32) {
    componentFail(IcalendarComponentError.limitExceeded);
  }
  final result = <IcalendarSchedulingRequestStatus>[];
  for (final property in properties) {
    final parameters = componentParameters(property, {'LANGUAGE'});
    final language = parameters['LANGUAGE'];
    if (language != null) validateCalendarLanguageTag(language);
    final fields = <String>[];
    var start = 0;
    for (var i = 0; i <= property.value.length; i++) {
      if (i < property.value.length && property.value[i] == r'\') {
        if (++i >= property.value.length) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        continue;
      }
      if (i == property.value.length || property.value[i] == ';') {
        if (fields.length >= 3) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        fields.add(property.value.substring(start, i));
        start = i + 1;
      }
    }
    if (fields.length < 2) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final code = fields.first;
    if (code.length > 32) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
    if (!RegExp(r'^[0-9]+(?:\.[0-9]+){1,2}$').hasMatch(code)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final levels = <int>[];
    for (final level in code.split('.')) {
      final number = BigInt.parse(level);
      if (number > BigInt.from(2147483647)) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      levels.add(number.toInt());
    }
    String text(String raw) {
      final value = decodeIcalendarText(raw);
      validateCalendarPlainText(value, maxCodePoints: 4096);
      return value;
    }

    final description = text(fields[1]);
    final extra = fields.length == 3 ? text(fields[2]) : null;
    budget.eventMetadata(
      code.length +
          description.runes.length +
          (extra?.runes.length ?? 0) +
          (language?.runes.length ?? 0),
    );
    result.add(
      IcalendarSchedulingRequestStatus._(
        code,
        levels,
        description,
        extra,
        language,
      ),
    );
  }
  return result;
}

IcalendarSchedulingGeographicPosition? _schedulingGeographicPosition(
  IcalendarSyntaxProperty? property,
  ComponentBudget budget,
) {
  if (property == null) return null;
  componentParameters(property, {});
  budget.eventMetadata(property.value.runes.length);
  final values = property.value.split(';');
  if (values.length != 2) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  for (var i = 0; i < 2; i++) {
    final text = values[i];
    if (text.length > 64) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
    if (!RegExp(r'^[+-]?[0-9]+(?:\.[0-9]+)?$').hasMatch(text)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final magnitude = text.replaceFirst(RegExp(r'^[+-]'), '');
    final decimal = magnitude.split('.');
    final fraction = decimal.length == 2 ? decimal[1] : '';
    // Compare exact decimal integers, so 90.000000000000000001 cannot round
    // down to the boundary and pass a floating-point comparison.
    if (BigInt.parse(decimal[0] + fraction) >
        BigInt.from(i == 0 ? 90 : 180) * BigInt.from(10).pow(fraction.length)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
  }
  return IcalendarSchedulingGeographicPosition._(values[0], values[1]);
}

List<IcalendarSchedulingResourceGroup> _schedulingResources(
  List<IcalendarSyntaxProperty> properties,
  ComponentBudget budget,
) {
  if (properties.length > 32) {
    componentFail(IcalendarComponentError.limitExceeded);
  }
  final result = <IcalendarSchedulingResourceGroup>[];
  var count = 0;
  for (final property in properties) {
    final parameters = componentParameters(property, {'LANGUAGE', 'ALTREP'});
    final language = parameters['LANGUAGE'], alternative = parameters['ALTREP'];
    if (language != null) validateCalendarLanguageTag(language);
    if (alternative != null) componentUri(alternative);
    final values = <String>[];
    for (final raw in _componentTextList(property.value)) {
      if (++count > 64) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      final value = decodeIcalendarText(raw);
      validateCalendarPlainText(value, maxCodePoints: 4096);
      budget.eventMetadata(value.runes.length);
      values.add(value);
    }
    budget.eventMetadata(
      (language?.runes.length ?? 0) + (alternative?.runes.length ?? 0),
    );
    result.add(
      IcalendarSchedulingResourceGroup._(values, language, alternative),
    );
  }
  return result;
}

/// Bounded descriptive event metadata shared by wire and native adapters.
/// Claims remain inert; this decoder grants no host/resource authority.
({
  int? priority,
  IcalendarSchedulingGeographicPosition? geographicPosition,
  List<IcalendarSchedulingResourceGroup> resources,
})
decodeIcalendarEventDescriptiveMetadata(
  Iterable<IcalendarSyntaxProperty> properties, {
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => componentGuard(
  () => _eventDescriptiveMetadata(properties, ComponentBudget(limits)),
);

({
  int? priority,
  IcalendarSchedulingGeographicPosition? geographicPosition,
  List<IcalendarSchedulingResourceGroup> resources,
})
_eventDescriptiveMetadata(
  Iterable<IcalendarSyntaxProperty> properties,
  ComponentBudget budget,
) {
  final singles = <String, IcalendarSyntaxProperty>{};
  final resources = <IcalendarSyntaxProperty>[];
  for (final p in properties) {
    if (p.canonicalName == 'RESOURCES') {
      if (resources.length >= 32) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      resources.add(p);
    } else if ({'GEO', 'PRIORITY'}.contains(p.canonicalName)) {
      if (singles.containsKey(p.canonicalName)) {
        componentFail(IcalendarComponentError.duplicate);
      }
      singles[p.canonicalName] = p;
    } else {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
  }
  return (
    priority: _componentInteger(singles['PRIORITY'], maximum: 9),
    geographicPosition: _schedulingGeographicPosition(singles['GEO'], budget),
    resources: List.unmodifiable(_schedulingResources(resources, budget)),
  );
}
