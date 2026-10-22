import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'calendar_text_metadata.dart';
import 'icalendar_syntax.dart';
import 'icalendar_temporal_values.dart';

enum IcalendarComponentError {
  unsupportedComponent,
  unsupportedProperty,
  unsupportedParameter,
  duplicate,
  missing,
  invalidValue,
  limitExceeded,
  zoneMismatch,
  zoneCoverage,
}

/// Diagnostics omit private source names/values and nested exception payloads.
final class IcalendarComponentException implements Exception {
  const IcalendarComponentException(this.kind);
  final IcalendarComponentError kind;
  @override
  String toString() => 'IcalendarComponentException(${kind.name})';
}

Never componentFail(IcalendarComponentError kind) =>
    throw IcalendarComponentException(kind);

/// Protocol tokens use ASCII case folding; Unicode text remains separate.
String componentToken(String value) {
  if (value.codeUnits.any((v) => v <= 32 || v >= 127)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return value.toUpperCase();
}

T componentGuard<T>(T Function() action) {
  try {
    return action();
  } on IcalendarValueException catch (e) {
    componentFail(
      e.kind == IcalendarValueError.zoneCoverage
          ? IcalendarComponentError.zoneCoverage
          : IcalendarComponentError.invalidValue,
    );
  } on IcalendarSyntaxException {
    componentFail(IcalendarComponentError.invalidValue);
  } on ZoneCoverageException {
    componentFail(IcalendarComponentError.zoneCoverage);
  } on RecurrenceLimitException {
    componentFail(IcalendarComponentError.limitExceeded);
  } on ArgumentError {
    componentFail(IcalendarComponentError.invalidValue);
  } on FormatException {
    componentFail(IcalendarComponentError.invalidValue);
  }
}

/// Resource ceilings for the first component profile, not RFC maxima.
final class IcalendarComponentLimits {
  const IcalendarComponentLimits({
    this.maxEvents = 128,
    this.maxZones = 32,
    this.maxObservances = 128,
    this.maxOnsets = 8192,
    this.maxCandidates = 200000,
    this.maxExplicitDates = 256,
    this.maxRuleValues = 512,
    this.maxCalendarExplicitDates = 4096,
    this.maxCalendarRuleValues = 4096,
  });
  final int maxEvents, maxZones, maxObservances, maxOnsets, maxCandidates;
  final int maxExplicitDates,
      maxRuleValues,
      maxCalendarExplicitDates,
      maxCalendarRuleValues;
  void validate() {
    for (final n in [
      maxEvents,
      maxZones,
      maxObservances,
      maxOnsets,
      maxCandidates,
      maxExplicitDates,
      maxRuleValues,
      maxCalendarExplicitDates,
      maxCalendarRuleValues,
    ]) {
      if (n < 1 || n > 1000000) throw ArgumentError('Invalid component limit');
    }
  }
}

final class ComponentBudget {
  ComponentBudget(this.limits)
    : sharedWork = RecurrenceWorkBudget(maxWork: limits.maxCandidates);
  final IcalendarComponentLimits limits;
  final RecurrenceWorkBudget sharedWork;
  int observances = 0, onsets = 0, explicitDates = 0, ruleValues = 0;
  void observance() {
    if (++observances > limits.maxObservances) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
  }

  void onset() {
    if (++onsets > limits.maxOnsets) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
  }

  void candidate() {
    sharedWork.charge();
  }

  void explicitDate() {
    if (++explicitDates > limits.maxCalendarExplicitDates) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
  }

  void ruleValue() {
    if (++ruleValues > limits.maxCalendarRuleValues) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
  }
}

Map<String, String> componentParameters(
  IcalendarSyntaxProperty p,
  Set<String> allowed,
) {
  final result = <String, String>{};
  for (final parameter in p.parameters) {
    final name = parameter.canonicalName;
    if (!allowed.contains(name)) {
      componentFail(IcalendarComponentError.unsupportedParameter);
    }
    if (result.containsKey(name)) {
      componentFail(IcalendarComponentError.duplicate);
    }
    if (parameter.values.length != 1) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    result[name] = parameter.values.single;
  }
  return result;
}

Map<String, List<IcalendarSyntaxProperty>> componentProperties(
  IcalendarSyntaxComponent c,
  Set<String> allowed, {
  Set<String> repeated = const {},
}) {
  final result = <String, List<IcalendarSyntaxProperty>>{};
  for (final p in c.entries.whereType<IcalendarSyntaxProperty>()) {
    final name = p.canonicalName;
    if (!allowed.contains(name)) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    final values = result.putIfAbsent(name, () => []);
    if (values.isNotEmpty && !repeated.contains(name)) {
      componentFail(IcalendarComponentError.duplicate);
    }
    values.add(p);
  }
  return result;
}

IcalendarSyntaxProperty requiredProperty(
  Map<String, List<IcalendarSyntaxProperty>> properties,
  String name,
) {
  final p = properties[name];
  if (p == null) componentFail(IcalendarComponentError.missing);
  return p.single;
}

DateTime componentUtc(IcalendarSyntaxProperty p) {
  componentParameters(p, {});
  if (!p.value.endsWith('Z')) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return parseIcalendarDateTime(p.value).instant;
}

String componentText(
  IcalendarSyntaxProperty p, {
  int maxPoints = 4096,
  Set<String> parameters = const {},
}) {
  componentParameters(p, parameters);
  final text = decodeIcalendarText(p.value);
  validateCalendarPlainText(text, maxCodePoints: maxPoints);
  return text;
}

/// Absolute ASCII URI metadata; never retrieved. Not an identity/authority check.
void componentUri(String value) {
  if (value.isEmpty ||
      value.length > 4096 ||
      !RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*:').hasMatch(value) ||
      value.codeUnits.any((v) => v <= 32 || v >= 127) ||
      RegExp(r"[^A-Za-z0-9:/?#\[\]@!$&()*+,;=._~%'-]").hasMatch(value) ||
      RegExp(r'%(?![0-9A-Fa-f]{2})').hasMatch(value)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final uri = Uri.parse(value);
  if (uri.userInfo.isNotEmpty || value.length <= uri.scheme.length + 1) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final parts = RegExp(
    r'^([A-Za-z][A-Za-z0-9+.-]*):(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#([^#]*))?$',
  ).firstMatch(value);
  if (parts == null ||
      parts.end != value.length ||
      [3, 4, 5].any((i) => RegExp(r'[\[\]]').hasMatch(parts.group(i) ?? '')) ||
      ({'http', 'https'}.contains(uri.scheme) && uri.host.isEmpty)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
}
