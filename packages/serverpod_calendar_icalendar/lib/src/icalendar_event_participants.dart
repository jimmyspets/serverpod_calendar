part of 'icalendar_event_calendar.dart';

/// Unverified source address/parameter claims, never a host identity or grant.
sealed class IcalendarEventParticipant {
  IcalendarEventParticipant._(this.source, Map<String, List<String>> parameters)
    : parameters = Map.unmodifiable(
        parameters.map((k, v) => MapEntry(k, List<String>.unmodifiable(v))),
      );
  final IcalendarSyntaxProperty source;
  String get address => source.value;
  final Map<String, List<String>> parameters;
  String? _one(String name) => parameters[name]?.single;
  String? get commonName => _one('CN');
  String? get language => _one('LANGUAGE');
  String? get directoryUri => _one('DIR');
  String? get sentBy => _one('SENT-BY');
}

final class IcalendarEventOrganizer extends IcalendarEventParticipant {
  IcalendarEventOrganizer._(super.source, super.parameters) : super._();
}

final class IcalendarEventAttendee extends IcalendarEventParticipant {
  IcalendarEventAttendee._(super.source, super.parameters) : super._();
  String? get calendarUserType => _one('CUTYPE');
  String? get role => _one('ROLE');
  String? get participationStatus => _one('PARTSTAT');
  bool? get rsvp =>
      _one('RSVP') == null ? null : _one('RSVP')!.toUpperCase() == 'TRUE';
  List<String> get members => parameters['MEMBER'] ?? const [];
  List<String> get delegatedTo => parameters['DELEGATED-TO'] ?? const [];
  List<String> get delegatedFrom => parameters['DELEGATED-FROM'] ?? const [];
  String get effectiveCalendarUserType => calendarUserType == null
      ? 'INDIVIDUAL'
      : (_eventUserTypes.contains(calendarUserType!.toUpperCase())
            ? calendarUserType!.toUpperCase()
            : 'UNKNOWN');
  String get effectiveRole => _eventRoles.contains(role?.toUpperCase())
      ? role!.toUpperCase()
      : 'REQ-PARTICIPANT';
  String get effectiveParticipationStatus =>
      _eventParticipationStates.contains(participationStatus?.toUpperCase())
      ? participationStatus!.toUpperCase()
      : 'NEEDS-ACTION';
  bool get effectiveRsvp => rsvp ?? false;
}

final class IcalendarEventParticipants {
  IcalendarEventParticipants._(
    this.organizer,
    Iterable<IcalendarEventAttendee> attendees,
  ) : attendees = List.unmodifiable(attendees);
  final IcalendarEventOrganizer? organizer;
  final List<IcalendarEventAttendee> attendees;
}

const _eventUserTypes = {'INDIVIDUAL', 'GROUP', 'ROOM', 'RESOURCE', 'UNKNOWN'};
const _eventRoles = {
  'CHAIR',
  'REQ-PARTICIPANT',
  'OPT-PARTICIPANT',
  'NON-PARTICIPANT',
};
const _eventParticipationStates = {
  'NEEDS-ACTION',
  'ACCEPTED',
  'DECLINED',
  'TENTATIVE',
  'DELEGATED',
};
const _eventParticipantLists = {'MEMBER', 'DELEGATED-TO', 'DELEGATED-FROM'};
const _eventParticipantTokens = {'CUTYPE', 'ROLE', 'PARTSTAT', 'RSVP'};
const _eventOrganizerParameters = {'CN', 'LANGUAGE', 'DIR', 'SENT-BY'};

IcalendarEventParticipants _eventParticipants(
  IcalendarSyntaxComponent source,
  ComponentBudget budget, {
  required bool isOverride,
}) {
  IcalendarEventOrganizer? organizer;
  final attendees = <IcalendarEventAttendee>[];
  void address(String value) {
    componentUri(value);
    if (value.length > 1024) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
  }

  for (final p in source.entries.whereType<IcalendarSyntaxProperty>()) {
    final isOrganizer = p.canonicalName == 'ORGANIZER';
    if (!isOrganizer && p.canonicalName != 'ATTENDEE') continue;
    if (!isOrganizer && attendees.length >= 64) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
    address(p.value);
    budget.eventMetadata(p.value.runes.length);
    final allowed = {
      ..._eventOrganizerParameters,
      if (!isOrganizer) ..._eventParticipantTokens,
      if (!isOrganizer) ..._eventParticipantLists,
    };
    final parameters = <String, List<String>>{};
    for (final param in p.parameters) {
      final name = param.canonicalName;
      if (!allowed.contains(name)) {
        componentFail(IcalendarComponentError.unsupportedParameter);
      }
      if (parameters.containsKey(name)) {
        componentFail(IcalendarComponentError.duplicate);
      }
      if (param.values.isEmpty ||
          (!_eventParticipantLists.contains(name) &&
              param.values.length != 1)) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      if (param.values.length > 16) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      for (final v in param.values) {
        if (_eventParticipantLists.contains(name) || name == 'SENT-BY') {
          address(v);
        }
        if (name == 'DIR') componentUri(v);
        if (name == 'CN') validateCalendarPlainText(v, maxCodePoints: 4096);
        if (name == 'LANGUAGE') validateCalendarLanguageTag(v);
        if (_eventParticipantTokens.contains(name)) {
          if (v.isEmpty ||
              v.length > 64 ||
              RegExp(r'[^A-Za-z0-9-]').hasMatch(v)) {
            componentFail(IcalendarComponentError.invalidValue);
          }
          if (name == 'PARTSTAT' &&
              {'COMPLETED', 'IN-PROCESS'}.contains(v.toUpperCase())) {
            componentFail(IcalendarComponentError.invalidValue);
          }
          if (name == 'RSVP' && !{'TRUE', 'FALSE'}.contains(v.toUpperCase())) {
            componentFail(IcalendarComponentError.invalidValue);
          }
        }
        budget.eventMetadata(v.runes.length);
      }
      parameters[name] = param.values;
    }
    if (parameters.containsKey('LANGUAGE') && !parameters.containsKey('CN')) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    if (isOrganizer) {
      organizer = IcalendarEventOrganizer._(p, parameters);
    } else {
      attendees.add(IcalendarEventAttendee._(p, parameters));
    }
  }
  if (!isOverride && attendees.isNotEmpty && organizer == null) {
    componentFail(IcalendarComponentError.missing);
  }
  return IcalendarEventParticipants._(organizer, attendees);
}

void _matchingEventParticipants(
  IcalendarEventParticipants master,
  IcalendarEventParticipants override,
) {
  bool same(IcalendarEventParticipant a, IcalendarEventParticipant b) {
    if (a.address != b.address || a.parameters.length != b.parameters.length) {
      return false;
    }
    for (final entry in a.parameters.entries) {
      final other = b.parameters[entry.key];
      if (other == null || other.length != entry.value.length) return false;
      for (var i = 0; i < other.length; i++) {
        if ((_eventParticipantTokens.contains(entry.key)
                ? entry.value[i].toUpperCase()
                : entry.value[i]) !=
            (_eventParticipantTokens.contains(entry.key)
                ? other[i].toUpperCase()
                : other[i])) {
          return false;
        }
      }
    }
    return true;
  }

  if ((override.organizer != null &&
          (master.organizer == null ||
              !same(override.organizer!, master.organizer!))) ||
      (override.attendees.isNotEmpty &&
          (override.attendees.length != master.attendees.length ||
              List.generate(
                override.attendees.length,
                (i) => !same(override.attendees[i], master.attendees[i]),
              ).any((v) => v)))) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
}

IcalendarEventParticipants _inheritedEventParticipants(
  IcalendarEventParticipants master,
  IcalendarEventParticipants override,
) => IcalendarEventParticipants._(
  override.organizer ?? master.organizer,
  override.attendees.isEmpty ? master.attendees : override.attendees,
);

/// Decode one unverified source claim using the bounded event parameter profile.
/// This validates data only; it never resolves an address or grants authority.
IcalendarEventParticipant decodeIcalendarEventParticipant(
  IcalendarSyntaxProperty source,
) => componentGuard(() {
  if (!{'ORGANIZER', 'ATTENDEE'}.contains(source.canonicalName)) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
  final value = _eventParticipants(
    IcalendarSyntaxComponent('VEVENT', [source]),
    ComponentBudget(const IcalendarComponentLimits()),
    isOverride: true,
  );
  return value.organizer ?? value.attendees.single;
});
