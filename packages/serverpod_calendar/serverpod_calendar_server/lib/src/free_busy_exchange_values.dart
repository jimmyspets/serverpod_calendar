import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

/// Constructs only the selected bounded message profile. Callers must separately
/// establish mailbox, recipient and complete source-projection authority.
IcalendarFreeBusyMessage buildCalendarFreeBusyExchange({
  required IcalendarFreeBusyMethod method,
  required String uid,
  required DateTime stamp,
  required UtcWindow window,
  required String organizer,
  Iterable<String> attendees = const [],
  List<AvailabilityInterval>? partition,
  bool refused = false,
}) {
  if (uid.isEmpty || uid.length > 8192 || uid.runes.length > 4096) {
    throw ArgumentError('Invalid exchange UID');
  }
  if (window.duration > const Duration(days: 31)) {
    throw ArgumentError('Exchange window exceeds the native profile');
  }
  final recipients = List<String>.of(attendees);
  if (recipients.length > 64 ||
      recipients.toSet().length != recipients.length ||
      method == IcalendarFreeBusyMethod.publish && recipients.isNotEmpty ||
      method == IcalendarFreeBusyMethod.request && recipients.isEmpty ||
      method == IcalendarFreeBusyMethod.reply && recipients.length != 1 ||
      refused && method != IcalendarFreeBusyMethod.reply ||
      method == IcalendarFreeBusyMethod.request && partition != null ||
      refused && partition != null ||
      method != IcalendarFreeBusyMethod.request &&
          !refused &&
          partition == null) {
    throw ArgumentError('Invalid exchange shape');
  }
  // Reuse the privacy serializer's complete-partition checks before adding any
  // scheduling roles. An empty or incomplete input cannot become all-free.
  final List<IcalendarSyntaxEntry> report;
  if (partition != null) {
    final snapshot = parseIcalendarSyntax(
      serializeIcalendarFreeBusy(
        // The privacy serializer's native UID editing limit is narrower than
        // the accepted source TEXT profile. Validate geometry with a private
        // placeholder, then validate the exact real UID in the message profile.
        uid: 'partition-validation',
        stamp: stamp,
        window: window,
        partition: partition,
      ),
    );
    report = snapshot.components.single.entries
        .whereType<IcalendarSyntaxComponent>()
        .single
        .entries
        .map(
          (entry) =>
              entry is IcalendarSyntaxProperty && entry.canonicalName == 'UID'
              ? IcalendarSyntaxProperty('UID', encodeIcalendarText(uid))
              : entry,
        )
        .toList();
  } else {
    String utc(DateTime d, {bool end = false}) => serializeIcalendarDateTime(
      end ? TimedValue.utcEnd(d) : TimedValue.utc(d),
      exclusiveEnd: end,
    );
    report = [
      IcalendarSyntaxProperty('UID', encodeIcalendarText(uid)),
      IcalendarSyntaxProperty('DTSTAMP', utc(stamp)),
      IcalendarSyntaxProperty('DTSTART', utc(window.start)),
      IcalendarSyntaxProperty('DTEND', utc(window.end, end: true)),
    ];
  }
  final document = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent('VCALENDAR', [
      IcalendarSyntaxProperty('VERSION', '2.0'),
      IcalendarSyntaxProperty(
        'PRODID',
        '-//serverpod_calendar//Busy exchange//EN',
      ),
      IcalendarSyntaxProperty('METHOD', method.name.toUpperCase()),
      IcalendarSyntaxComponent('VFREEBUSY', [
        ...report,
        IcalendarSyntaxProperty('ORGANIZER', organizer),
        for (final address in recipients)
          IcalendarSyntaxProperty('ATTENDEE', address),
        if (refused)
          IcalendarSyntaxProperty('REQUEST-STATUS', '3.8;No authority'),
      ]),
    ]),
  ]);
  const limits = IcalendarSyntaxLimits(maxBytes: 262144);
  return parseIcalendarFreeBusyMessage(
    serializeIcalendarSyntax(document, limits: limits),
    syntaxLimits: limits,
  );
}

Uint8List calendarFreeBusyExchangeBytes(IcalendarFreeBusyMessage message) =>
    serializeIcalendarFreeBusyMessage(message);
