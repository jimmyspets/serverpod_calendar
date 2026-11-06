import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_protocol_values.dart';
import 'event_values.dart';
import 'generated/protocol.dart';
import 'invitation_bundle_values.dart';

/// Pure semantic proof, never recipient authority or permission to send.
final class CalendarInvitationBundleResponseTarget {
  const CalendarInvitationBundleResponseTarget(
    this.originalStart,
    this.componentVersion,
    this.cancelled,
  );
  final CalendarEventTiming originalStart;
  final CalendarInvitationBundleComponentVersion componentVersion;
  final bool cancelled;
}

String invitationBundleResponseTargetKey(CalendarEventTiming original) {
  if (original.end != null || original.duration != null) {
    throw ArgumentError('Original must be a point');
  }
  validateEventTiming(original);
  return 'bundle-occurrence-v1:${eventComponentKey(original, false)}';
}

CalendarInvitationBundleResponseTarget resolveInvitationBundleResponseTarget(
  IcalendarSchedulingMessage source,
  CalendarEventTiming original, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid work limit');
  }
  invitationBundleResponseTargetKey(original);
  final proposal = invitationRequestBundleProposal(
    source,
    sharedWorkBudget: work,
  );
  if (!eventSchedulingMember(
    proposal.content,
    original,
    sharedWorkBudget: work,
  )) {
    throw ArgumentError('Original is not a member');
  }
  int order(CalendarEventTiming a, CalendarEventTiming b) {
    final x = a.start, y = b.start;
    return DateTime.utc(
      x.year,
      x.month,
      x.day,
      x.hour,
      x.minute,
      x.second,
    ).compareTo(
      DateTime.utc(y.year, y.month, y.day, y.hour, y.minute, y.second),
    );
  }

  CalendarEventOverrideProtocolState? single, range;
  final key = eventComponentKey(original, false);
  for (final component in proposal.protocolState.overrides) {
    work.charge();
    if (!component.isThisAndFuture &&
        eventComponentKey(component.originalStart, false) == key) {
      single = component;
    } else if (component.isThisAndFuture &&
        order(component.originalStart, original) <= 0 &&
        (range == null ||
            order(component.originalStart, range.originalStart) > 0)) {
      range = component;
    }
  }
  final part = single ?? range;
  final version = part?.version ?? proposal.protocolState.version;
  final cancelled =
      proposal.content.status == CalendarEventStatus.cancelled ||
      (proposal.edits?.singles.any(
            (v) =>
                eventComponentKey(v.originalStart, false) == key && v.cancelled,
          ) ??
          false);
  return CalendarInvitationBundleResponseTarget(
    original,
    CalendarInvitationBundleComponentVersion(
      originalStart: part?.originalStart,
      isThisAndFuture: part?.isThisAndFuture ?? false,
      sequence: version.sequence,
      stamp: version.stamp,
    ),
    cancelled,
  );
}
