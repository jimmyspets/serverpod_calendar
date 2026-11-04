import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'event_wire_storage.dart';

/// Validates a complete initial REQUEST series. This proves no recipient,
/// provenance, existing-meeting state or permission to persist the result.
EventStorageProposal invitationRequestBundleProposal(
  IcalendarSchedulingMessage input, {
  int maxBytes = 262144,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  RangeError.checkValueInInterval(maxBytes, 1, 262144);
  if (sharedWorkBudget != null &&
      sharedWorkBudget.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid invitation work limit');
  }
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final syntax = IcalendarSyntaxLimits(maxBytes: maxBytes);
  final bytes = serializeIcalendarSyntax(input.source, limits: syntax);
  for (var i = 0; i < bytes.length; i += 64) {
    work.charge();
  }
  final message = validateIcalendarSchedulingMessage(
    input.source,
    syntaxLimits: syntax,
    sharedWorkBudget: work,
  );
  if (message.method != IcalendarSchedulingMethod.request ||
      message.events.length < 2 ||
      message.events.length > 65 ||
      message.events.where((e) => !e.isOverride).length != 1) {
    throw ArgumentError('Unsupported invitation bundle');
  }
  final master = message.events.singleWhere((e) => !e.isOverride);
  String claims(IcalendarEventParticipants p) {
    if (p.organizer == null ||
        p.organizer!.sentBy != null ||
        p.attendees.isEmpty ||
        p.attendees.length > 64 ||
        p.attendees.any(
          (a) =>
              a.sentBy != null ||
              a.delegatedTo.isNotEmpty ||
              a.delegatedFrom.isNotEmpty ||
              a.participationStatus?.toUpperCase() == 'DELEGATED',
        )) {
      throw ArgumentError('Unsupported participant profile');
    }
    final addresses = p.attendees.map((a) => a.address).toList()..sort();
    if (addresses.toSet().length != addresses.length) {
      throw ArgumentError('Duplicate participant');
    }
    return jsonEncode([p.organizer!.address, addresses]);
  }

  final roster = claims(master.participants);
  for (final part in message.events) {
    work.charge();
    if (claims(part.participants) != roster) {
      throw ArgumentError('Inconsistent participant claims');
    }
  }
  final root = message.source.components.single;
  final calendar = validateIcalendarEventCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(
        root.name,
        root.entries.where(
          (v) => v is! IcalendarSyntaxProperty || v.canonicalName != 'METHOD',
        ),
      ),
    ]),
    syntaxLimits: syntax,
    sharedWorkBudget: work,
  );
  if (calendar.series.length != 1) throw ArgumentError('Multiple series');
  final proposal = eventStorageProposal(
    calendar.series.single,
    sharedWorkBudget: work,
  );
  final content = proposal.content;
  if (content.recurrence == null && (content.periods?.isEmpty ?? true)) {
    throw ArgumentError('Recurring master required');
  }
  return proposal;
}
