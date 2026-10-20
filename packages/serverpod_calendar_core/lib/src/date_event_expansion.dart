import 'calendar_date.dart';
import 'date_event_span.dart';

// Shared internal arithmetic for uniform DATE templates. Not a public API.
CalendarDate dateEventLookback(DateEventSpan span, CalendarDate from) {
  final first = CalendarDate(year: 1, month: 1, day: 1);
  final available = first.daysUntil(from);
  final wanted = span.dayCount - 1;
  return from.addDays(-(wanted < available ? wanted : available));
}

DateEventSpan dateEventSpanAt(DateEventSpan span, CalendarDate start) {
  if (span.end != null) {
    return DateEventSpan(start: start, end: start.addDays(span.dayCount));
  }
  return DateEventSpan(start: start, duration: span.duration);
}
