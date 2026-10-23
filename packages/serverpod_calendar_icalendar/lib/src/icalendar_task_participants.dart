part of 'icalendar_event_calendar.dart';

/// Unverified source address/parameter claims, never a host identity or grant.
sealed class IcalendarTaskParticipant {
  IcalendarTaskParticipant._(this.source, Map<String, List<String>> parameters)
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

final class IcalendarTaskOrganizer extends IcalendarTaskParticipant {
  IcalendarTaskOrganizer._(super.source, super.parameters) : super._();
}

final class IcalendarTaskAttendee extends IcalendarTaskParticipant {
  IcalendarTaskAttendee._(super.source, super.parameters) : super._();
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
      : (_taskUserTypes.contains(calendarUserType!.toUpperCase())
            ? calendarUserType!.toUpperCase()
            : 'UNKNOWN');
  String get effectiveRole => _taskRoles.contains(role?.toUpperCase())
      ? role!.toUpperCase()
      : 'REQ-PARTICIPANT';
  String get effectiveParticipationStatus =>
      _taskParticipationStates.contains(participationStatus?.toUpperCase())
      ? participationStatus!.toUpperCase()
      : 'NEEDS-ACTION';
  bool get effectiveRsvp => rsvp ?? false;
}

final class IcalendarTaskParticipants {
  IcalendarTaskParticipants._(
    this.organizer,
    Iterable<IcalendarTaskAttendee> attendees,
  ) : attendees = List.unmodifiable(attendees);
  final IcalendarTaskOrganizer? organizer;
  final List<IcalendarTaskAttendee> attendees;
}

const _taskUserTypes = {'INDIVIDUAL', 'GROUP', 'ROOM', 'RESOURCE', 'UNKNOWN'};
const _taskRoles = {
  'CHAIR',
  'REQ-PARTICIPANT',
  'OPT-PARTICIPANT',
  'NON-PARTICIPANT',
};
const _taskParticipationStates = {
  'NEEDS-ACTION',
  'ACCEPTED',
  'DECLINED',
  'TENTATIVE',
  'DELEGATED',
  'COMPLETED',
  'IN-PROCESS',
};
const _taskParticipantLists = {'MEMBER', 'DELEGATED-TO', 'DELEGATED-FROM'};
const _taskParticipantTokens = {'CUTYPE', 'ROLE', 'PARTSTAT', 'RSVP'};
const _taskOrganizerParameters = {'CN', 'LANGUAGE', 'DIR', 'SENT-BY'};

IcalendarTaskParticipants _taskParticipants(
  IcalendarSyntaxComponent source,
  ComponentBudget budget, {
  required bool isOverride,
}) {
  IcalendarTaskOrganizer? organizer;
  final attendees = <IcalendarTaskAttendee>[];
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
    budget.taskMetadata(p.value.runes.length);
    final allowed = {
      ..._taskOrganizerParameters,
      if (!isOrganizer) ..._taskParticipantTokens,
      if (!isOrganizer) ..._taskParticipantLists,
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
          (!_taskParticipantLists.contains(name) && param.values.length != 1)) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      if (param.values.length > 16) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      for (final v in param.values) {
        if (_taskParticipantLists.contains(name) || name == 'SENT-BY') {
          address(v);
        }
        if (name == 'DIR') componentUri(v);
        if (name == 'CN') validateCalendarPlainText(v, maxCodePoints: 4096);
        if (name == 'LANGUAGE') validateCalendarLanguageTag(v);
        if (_taskParticipantTokens.contains(name)) {
          if (v.isEmpty ||
              v.length > 64 ||
              RegExp(r'[^A-Za-z0-9-]').hasMatch(v)) {
            componentFail(IcalendarComponentError.invalidValue);
          }
          if (name == 'RSVP' && !{'TRUE', 'FALSE'}.contains(v.toUpperCase())) {
            componentFail(IcalendarComponentError.invalidValue);
          }
        }
        budget.taskMetadata(v.runes.length);
      }
      parameters[name] = param.values;
    }
    if (parameters.containsKey('LANGUAGE') && !parameters.containsKey('CN')) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    if (isOrganizer) {
      organizer = IcalendarTaskOrganizer._(p, parameters);
    } else {
      attendees.add(IcalendarTaskAttendee._(p, parameters));
    }
  }
  if (!isOverride && attendees.isNotEmpty && organizer == null) {
    componentFail(IcalendarComponentError.missing);
  }
  return IcalendarTaskParticipants._(organizer, attendees);
}

void _matchingTaskParticipants(
  IcalendarTaskParticipants master,
  IcalendarTaskParticipants override,
) {
  bool same(IcalendarTaskParticipant a, IcalendarTaskParticipant b) {
    if (a.address != b.address || a.parameters.length != b.parameters.length) {
      return false;
    }
    for (final entry in a.parameters.entries) {
      final other = b.parameters[entry.key];
      if (other == null || other.length != entry.value.length) return false;
      for (var i = 0; i < other.length; i++) {
        if ((_taskParticipantTokens.contains(entry.key)
                ? entry.value[i].toUpperCase()
                : entry.value[i]) !=
            (_taskParticipantTokens.contains(entry.key)
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

IcalendarTaskParticipants _inheritedTaskParticipants(
  IcalendarTaskParticipants master,
  IcalendarTaskParticipants override,
) => IcalendarTaskParticipants._(
  override.organizer ?? master.organizer,
  override.attendees.isEmpty ? master.attendees : override.attendees,
);
