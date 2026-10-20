import 'calendar_date.dart';
import 'date_event_span.dart';

/// Original DATE identity and effective span within one series context.
/// This is not a globally scoped key, persistence record or authorization proof.
final class DateEventOccurrence {
  const DateEventOccurrence({required this.originalStart, required this.span});

  final CalendarDate originalStart;
  final DateEventSpan span;

  @override
  bool operator ==(Object other) =>
      other is DateEventOccurrence &&
      originalStart == other.originalStart &&
      span == other.span;

  @override
  int get hashCode => Object.hash(originalStart, span);
}
