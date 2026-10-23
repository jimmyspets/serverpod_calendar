import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarTaskEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<CalendarTaskReceipt?> create(
    Session session,
    CalendarTaskCreateRequest request,
  ) => CalendarModule.service(session).createTask(request);
  Future<CalendarTaskView> getTask(
    Session session,
    UuidValue taskId,
    List<CalendarTaskFieldGroup> groups,
  ) => CalendarModule.service(session).getTask(taskId, groups);
  Future<CalendarTaskPage> list(
    Session session,
    UuidValue calendarId, {
    required int pageSize,
    required List<CalendarTaskFieldGroup> fieldGroups,
    String? cursor,
  }) => CalendarModule.service(session).listTasks(
    calendarId,
    pageSize: pageSize,
    fieldGroups: fieldGroups,
    cursor: cursor,
  );
  Future<CalendarTaskReceipt?> update(
    Session session,
    CalendarTaskUpdateRequest request,
  ) => CalendarModule.service(session).updateTask(request);
  Future<CalendarTaskReceipt?> changeProgress(
    Session session,
    CalendarTaskProgressRequest request,
  ) => CalendarModule.service(session).changeTaskProgress(request);
  Future<CalendarTaskReceipt?> changeAssignments(
    Session session,
    CalendarTaskAssignmentsRequest request,
  ) => CalendarModule.service(session).changeTaskAssignments(request);
  Future<CalendarTaskReceipt?> deleteTask(
    Session session,
    UuidValue taskId,
    int expectedRevision,
  ) => CalendarModule.service(session).deleteTask(taskId, expectedRevision);
}
