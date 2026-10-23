import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

String taskProgressLabel(cal.CalendarTaskProgress progress) {
  final status = progress.status?.name ?? 'status unspecified';
  final percentage = progress.percentComplete == null
      ? 'percentage unspecified'
      : '${progress.percentComplete}%';
  final completion = progress.completedAt == null
      ? ''
      : '; completion ${progress.completedAt!.toIso8601String()}';
  return '$status; $percentage$completion';
}
