import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'generated/protocol.dart';
import 'task_source_values.dart';

/// The guarantee supplied by a host adapter, not inferred from its storage.
enum CalendarAuthorizationGuarantee { freshCheck, coordinated }

enum CalendarAuthorizationPhase { read, preliminaryWrite, finalWrite }

enum CalendarPermission {
  publishScheduling,
  cancelScheduling,
  cancelOccurrenceScheduling,
  restoreOccurrenceScheduling,
  reopenScheduling,
  readScheduling,
  readSchedulingResponses,
  readSchedulingReplySource,
  readPersonalAlarmActivity,
  acknowledgePersonalAlarm,
  dismissPersonalAlarm,
  snoozePersonalAlarm,
  resetPersonalAlarm,
  armPersonalAlarm,
  readPersonalAlarms,
  createPersonalAlarm,
  adoptPersonalAlarm,
  updatePersonalAlarm,
  deletePersonalAlarm,
  replaceEventsFromImport,
  replaceTasksFromImport,
  exportTasks,
  readTaskSource,
  readEventSource,
  importTasks,
  previewTaskOccurrences,
  readTaskHistory,
  listTasks,
  readTask,
  createTask,
  updateTask,
  changeTaskProgress,
  changeTaskAssignments,
  deleteTask,
  exportEvents,
  importEvents,
  exportFreeBusy,
  replaceAvailabilityFromImport,
  exportAvailability,
  importAvailability,
  previewAvailabilityOccurrences,
  changeAvailabilityOccurrence,
  updateAvailabilityMetadata,
  listAvailability,
  readAvailability,
  createAvailability,
  updateAvailability,
  deleteAvailability,
  projectAvailability,
  readSubjectAvailability,
  projectCalendarAvailability,
  readFreeBusy,
  projectEventBusy,
  previewEventOccurrences,
  listEvents,
  listEventOccurrences,
  readEvent,
  createEvent,
  updateEvent,
  updateEventDescriptiveMetadata,
  updateEventTextMetadata,
  updateTaskTextMetadata,
  changeEventStatus,
  deleteEvent,
  list,
  read,
  create,
  updateMetadata,
  updateProtocolMetadata,
  updateSupplementalMetadata,
  updateAvailabilitySettings,
  delete,
  readAssociations,
  changeAssociations,
}

enum CalendarAuthorizationVerdict { allow, deny, unavailable }

/// Trusted host result. Never accepted as a client-supplied request.
final class CalendarHostContext {
  const CalendarHostContext({
    required this.principalId,
    required this.scopeKey,
    required this.policyRevision,
  });
  final String principalId, scopeKey;

  /// Authoritative continuation epoch. Change when effective query rights change.
  final String policyRevision;
}

final class CalendarSubjectReference {
  const CalendarSubjectReference(this.namespace, this.kind, this.externalId);
  final String namespace, kind, externalId;
}

final class CalendarSubjectIntent {
  const CalendarSubjectIntent(
    this.action,
    this.subject,
    this.contributesAvailability,
  );
  final CalendarSubjectAction action;
  final CalendarSubjectReference subject;
  final bool contributesAvailability;
}

/// Immutable policy metadata; a host cannot mutate the ORM object through it.
final class CalendarPolicySubject {
  const CalendarPolicySubject(this.subject, this.contributesAvailability);
  final CalendarSubjectReference subject;
  final bool contributesAvailability;
}

final class CalendarPolicySnapshot {
  CalendarPolicySnapshot({
    required this.calendarId,
    required this.revision,
    required this.displayName,
    required this.description,
    required this.color,
    required this.protocolIdentity,
    required this.protocolMetadata,
    required this.supplementalMetadata,
    required this.availabilityZoneId,
    required this.noRuleFallback,
    required Iterable<CalendarPolicySubject> subjects,
  }) : subjects = List.unmodifiable(subjects);
  final UuidValue calendarId;
  final int revision;
  final String displayName, availabilityZoneId;
  final String? description, color;
  final CalendarProtocolIdentity protocolIdentity;
  final IcalendarCalendarTextMetadata protocolMetadata;
  final IcalendarSupplementalMetadata supplementalMetadata;
  final CalendarNoRuleFallback noRuleFallback;
  final List<CalendarPolicySubject> subjects;
}

/// Full replacement distinguishes clearing nulls from a name-only edit.
final class CalendarPresentationIntent {
  const CalendarPresentationIntent(
    this.displayName,
    this.description,
    this.color,
  );
  final String displayName;
  final String? description, color;
}

final class CalendarProposedChange {
  const CalendarProposedChange({
    this.displayName,
    this.availabilityZoneId,
    this.noRuleFallback,
    this.subject,
    this.presentation,
    this.protocolMetadata,
    this.supplementalMetadata,
  });
  final String? displayName, availabilityZoneId;
  final CalendarNoRuleFallback? noRuleFallback;
  final CalendarSubjectIntent? subject;
  final CalendarPresentationIntent? presentation;
  final IcalendarCalendarTextMetadata? protocolMetadata;
  final IcalendarSupplementalMetadata? supplementalMetadata;
}

final class CalendarAuthorizationRequest {
  CalendarAuthorizationRequest({
    required this.key,
    required this.operation,
    this.alarmRecipient,
    this.alarmId,
    this.currentAlarm,
    this.proposedAlarmDefinition,
    this.proposedAlarmArmed,
    this.currentAlarmFiring,
    this.currentAlarmAction,
    this.proposedAlarmAction,
    this.alarmActionKind,
    this.alarmActivityKind,
    this.alarmSourceIndex,
    this.current,
    this.proposed,
    this.calendarId,
    this.categoryFilter,
    this.eventId,
    this.currentTask,
    this.taskId,
    this.proposedTaskContent,
    this.proposedTaskProgress,
    this.proposedTaskAssignees,
    this.proposedTaskVersion,
    this.proposedTaskOccurrenceVersion,
    this.proposedTaskSourceState,
    this.taskProgressChange,
    this.taskOccurrenceQuery,
    this.taskOccurrenceProgressChange,
    this.taskOccurrenceTimingChange,
    this.taskOccurrenceContentChange,
    this.taskHistoryQuery,
    this.currentTaskOccurrence,
    this.proposedTaskOccurrence,
    Iterable<CalendarTaskOccurrence> recordedTaskOccurrences = const [],
    this.scheduling,
    this.schedulingReplySource,
    this.schedulingReplyDocument,
    this.replyPublishedMessage,
    this.replyPublishedMaster,
    this.replyOriginalStart,
    this.replyPublishedTarget,
    this.replyEffectiveOccurrence,
    this.currentEvent,
    this.proposedEvent,
    this.proposedEventProtocolState,
    this.itemTextMetadataPatch,
    this.occurrenceQuery,
    this.occurrenceListQuery,
    this.freeBusyQuery,
    this.availabilitySearchQuery,
    this.availabilityTarget,
    this.availabilityId,
    this.currentAvailability,
    this.proposedAvailability,
    this.availabilityOccurrenceChange,
    this.availabilityOccurrenceQuery,
    this.proposedAvailabilityEdits,
    this.proposedAvailabilityProtocolState,
    this.availabilityCategoryFilter,
    this.availabilityImport,
    this.eventImport,
    this.taskImport,
    this.taskExport,
    this.taskReplacement,
    this.eventExport,
    this.eventReplacement,
    this.availabilityExport,
    this.availabilityReplacement,
    this.occurrenceChange,
    this.eventOccurrenceContentChange,
    this.proposedTimingOverrides,
    Iterable<CalendarTaskFieldGroup> taskGroups = const [],
    Iterable<CalendarEventFieldGroup> eventGroups = const [],
    Iterable<CalendarFieldGroup> requestedGroups = const [],
  }) : recordedTaskOccurrences = List.unmodifiable(recordedTaskOccurrences),
       taskGroups = Set.unmodifiable(taskGroups),
       requestedGroups = Set.unmodifiable(requestedGroups),
       eventGroups = Set.unmodifiable(eventGroups);
  final String key;
  final CalendarPermission operation;
  final CalendarAlarmRecipient? alarmRecipient;
  final UuidValue? alarmId;
  final CalendarAlarmView? currentAlarm;
  final CalendarAlarmDefinition? proposedAlarmDefinition;
  final bool? proposedAlarmArmed;
  final CalendarAlarmFiringView? currentAlarmFiring;
  final CalendarAlarmActionView? currentAlarmAction, proposedAlarmAction;
  final CalendarAlarmActionKind? alarmActionKind;
  final CalendarAlarmActivityKind? alarmActivityKind;

  /// Validated master-source index for explicit timing adoption, never identity.
  final int? alarmSourceIndex;
  final UuidValue? eventId;
  final UuidValue? taskId;
  final CalendarTaskPolicySnapshot? currentTask;
  final CalendarTaskContent? proposedTaskContent;
  final CalendarTaskProgress? proposedTaskProgress;
  final List<CalendarTaskAssignee>? proposedTaskAssignees;
  final CalendarTaskProtocolVersion? proposedTaskVersion,
      proposedTaskOccurrenceVersion;
  final CalendarTaskSourceState? proposedTaskSourceState;
  final CalendarTaskProgressRequest? taskProgressChange;
  final CalendarTaskOccurrenceQuery? taskOccurrenceQuery;
  final CalendarTaskOccurrenceProgressRequest? taskOccurrenceProgressChange;
  final CalendarTaskOccurrenceTimingRequest? taskOccurrenceTimingChange;
  final CalendarTaskOccurrenceContentRequest? taskOccurrenceContentChange;
  final CalendarTaskHistoryQuery? taskHistoryQuery;
  final CalendarTaskOccurrence? currentTaskOccurrence, proposedTaskOccurrence;
  final List<CalendarTaskOccurrence> recordedTaskOccurrences;
  final Set<CalendarTaskFieldGroup> taskGroups;
  final CalendarSchedulingIntent? scheduling;
  final CalendarSchedulingReplySourceView? schedulingReplySource;
  final String? schedulingReplyDocument;
  final IcalendarSchedulingMessage? replyPublishedMessage;
  final IcalendarSchedulingEvent? replyPublishedMaster;
  final CalendarEventTiming? replyOriginalStart;
  final IcalendarSchedulingEvent? replyPublishedTarget;
  final CalendarEventContent? replyEffectiveOccurrence;
  final CalendarEventPolicySnapshot? currentEvent;
  final CalendarEventContent? proposedEvent;
  final CalendarEventProtocolState? proposedEventProtocolState;
  final CalendarItemTextMetadataPatch? itemTextMetadataPatch;
  final CalendarEventOccurrenceQuery? occurrenceQuery;
  final CalendarEventOccurrenceListQuery? occurrenceListQuery;
  final CalendarFreeBusyQuery? freeBusyQuery;
  final CalendarAvailabilitySearchQuery? availabilitySearchQuery;
  final CalendarAvailabilityTarget? availabilityTarget;
  final UuidValue? availabilityId;
  final CalendarAvailabilityPolicySnapshot? currentAvailability;
  final CalendarAvailabilityContent? proposedAvailability;
  final CalendarAvailabilityOccurrenceChange? availabilityOccurrenceChange;
  final CalendarAvailabilityOccurrenceQuery? availabilityOccurrenceQuery;
  final List<CalendarAvailabilityOpeningEdits>? proposedAvailabilityEdits;
  final CalendarAvailabilityProtocolState? proposedAvailabilityProtocolState;
  final String? availabilityCategoryFilter;

  /// Full immutable batch, absent on the cheap pre-parse authority check.
  final CalendarAvailabilityImportIntent? availabilityImport;
  final CalendarEventImportIntent? eventImport;
  final CalendarTaskImportIntent? taskImport;
  final CalendarTaskExportIntent? taskExport;
  final CalendarTaskReplacementIntent? taskReplacement;
  final CalendarEventExportIntent? eventExport;
  final CalendarEventReplacementIntent? eventReplacement;
  final CalendarAvailabilityExportIntent? availabilityExport;
  final CalendarAvailabilityReplacementIntent? availabilityReplacement;
  final CalendarEventOccurrenceChange? occurrenceChange;
  final CalendarEventOccurrenceContentRequest? eventOccurrenceContentChange;
  final CalendarEventTimingOverrides? proposedTimingOverrides;
  final Set<CalendarEventFieldGroup> eventGroups;
  final CalendarCategoryQuery? categoryFilter;

  /// Actual server-resolved collection/object identity, absent for scope/create.
  final UuidValue? calendarId;
  final CalendarPolicySnapshot? current;
  final CalendarProposedChange? proposed;
  final Set<CalendarFieldGroup> requestedGroups;
}

/// Server-allocated identities and source state, never authority from the file.
final class CalendarAvailabilityImportMember {
  const CalendarAvailabilityImportMember({
    required this.availabilityId,
    required this.protocolUid,
    required this.content,
    required this.protocolState,
    required this.timingOverrides,
  });
  final UuidValue availabilityId;
  final String protocolUid;
  final CalendarAvailabilityContent content;
  final CalendarAvailabilityProtocolState protocolState;
  final List<CalendarAvailabilityOpeningEdits>? timingOverrides;
}

final class CalendarAvailabilityImportIntent {
  CalendarAvailabilityImportIntent(
    Iterable<CalendarAvailabilityImportMember> members,
  ) : members = List.unmodifiable(members);
  final List<CalendarAvailabilityImportMember> members;
}

/// Complete validated source proposal; source identifiers grant no authority.
final class CalendarTaskImportMember {
  CalendarTaskImportMember({
    required this.taskId,
    required this.protocolUid,
    required CalendarTaskSourceState sourceState,
  }) : sourceState = validateTaskSourceState(protocolUid, sourceState);
  final UuidValue taskId;
  final String protocolUid;
  final CalendarTaskSourceState sourceState;
  bool get requiresProgress =>
      [sourceState.master, ...sourceState.occurrences].any(
        (c) =>
            c.progress.status != null ||
            c.progress.percentComplete != null ||
            c.progress.completedAt != null,
      );
}

final class CalendarTaskImportIntent {
  CalendarTaskImportIntent(Iterable<CalendarTaskImportMember> members)
    : members = List.unmodifiable(members);
  final List<CalendarTaskImportMember> members;
}

/// Actual current/proposed objects, excluding historical baseline contents.
final class CalendarTaskReplacementMember {
  const CalendarTaskReplacementMember({
    required this.current,
    required this.proposed,
    required this.baselineProfile,
    required this.baselineSequence,
    this.changed,
    this.localChanges,
  });
  final CalendarTaskPolicySnapshot current;
  final CalendarTaskImportMember proposed;
  final String? baselineProfile;
  final int? baselineSequence;
  final bool? changed, localChanges;
}

final class CalendarTaskReplacementIntent {
  CalendarTaskReplacementIntent(Iterable<CalendarTaskReplacementMember> members)
    : members = List.unmodifiable(members);
  final List<CalendarTaskReplacementMember> members;
}

final class CalendarEventImportMember {
  const CalendarEventImportMember({
    required this.eventId,
    required this.protocolUid,
    required this.content,
    required this.protocolState,
    required this.timingOverrides,
  });
  final UuidValue eventId;
  final String protocolUid;
  final CalendarEventContent content;
  final CalendarEventProtocolState protocolState;
  final CalendarEventTimingOverrides? timingOverrides;
  bool get requiresLifecycle =>
      content.status == CalendarEventStatus.cancelled ||
      (timingOverrides?.singles.any((v) => v.cancelled) ?? false);
}

final class CalendarEventImportIntent {
  CalendarEventImportIntent(Iterable<CalendarEventImportMember> members)
    : members = List.unmodifiable(members);
  final List<CalendarEventImportMember> members;
}

/// Actual current/proposed objects, never historical baseline contents.
final class CalendarEventReplacementMember {
  const CalendarEventReplacementMember({
    required this.current,
    required this.proposed,
    required this.baselineProfile,
    required this.baselineSequence,
    this.changed,
    this.localChanges,
  });
  final CalendarEventPolicySnapshot current;
  final CalendarEventImportMember proposed;
  final String? baselineProfile;
  final int? baselineSequence;
  final bool? changed, localChanges;
}

final class CalendarEventReplacementIntent {
  CalendarEventReplacementIntent(
    Iterable<CalendarEventReplacementMember> members,
  ) : members = List.unmodifiable(members);
  final List<CalendarEventReplacementMember> members;
}

/// Complete current selection, detached from ORM state and private baselines.
final class CalendarTaskExportMember {
  CalendarTaskExportMember({
    required this.current,
    required CalendarTaskSourceState sourceState,
  }) : sourceState = validateTaskSourceState(current.protocolUid, sourceState);
  final CalendarTaskPolicySnapshot current;
  final CalendarTaskSourceState sourceState;
}

final class CalendarTaskExportIntent {
  CalendarTaskExportIntent(Iterable<CalendarTaskExportMember> members)
    : members = List.unmodifiable(members);
  final List<CalendarTaskExportMember> members;
}

final class CalendarEventExportIntent {
  CalendarEventExportIntent(Iterable<CalendarEventPolicySnapshot> members)
    : members = List.unmodifiable(members);
  final List<CalendarEventPolicySnapshot> members;
}

/// Complete current selection, never a visibility-filtered management list.
final class CalendarAvailabilityExportIntent {
  CalendarAvailabilityExportIntent(
    Iterable<CalendarAvailabilityPolicySnapshot> members,
  ) : members = List.unmodifiable(members);
  final List<CalendarAvailabilityPolicySnapshot> members;
}

/// Current/proposed data only: historical baseline payload is never disclosed.
final class CalendarAvailabilityReplacementMember {
  const CalendarAvailabilityReplacementMember({
    required this.current,
    required this.proposed,
    required this.baselineProfile,
    required this.baselineSequence,
    this.changed,
    this.localChanges,
  });
  final CalendarAvailabilityPolicySnapshot current;
  final CalendarAvailabilityImportMember proposed;
  final String? baselineProfile;
  final int? baselineSequence;
  final bool? changed, localChanges;
}

final class CalendarAvailabilityReplacementIntent {
  CalendarAvailabilityReplacementIntent(
    Iterable<CalendarAvailabilityReplacementMember> members,
  ) : members = List.unmodifiable(members);
  final List<CalendarAvailabilityReplacementMember> members;
}

final class CalendarAuthorizationDecision {
  CalendarAuthorizationDecision({
    required this.key,
    required this.verdict,
    Iterable<CalendarFieldGroup> disclosedGroups = const [],
    this.discloseMutationReceipt = false,
    Iterable<CalendarTaskFieldGroup> taskDisclosedGroups = const [],
    Iterable<CalendarEventFieldGroup> eventDisclosedGroups = const [],
  }) : taskDisclosedGroups = Set.unmodifiable(taskDisclosedGroups),
       disclosedGroups = Set.unmodifiable(disclosedGroups),
       eventDisclosedGroups = Set.unmodifiable(eventDisclosedGroups);
  final String key;
  final CalendarAuthorizationVerdict verdict;
  final Set<CalendarFieldGroup> disclosedGroups;
  final bool discloseMutationReceipt;
  final Set<CalendarTaskFieldGroup> taskDisclosedGroups;
  final Set<CalendarEventFieldGroup> eventDisclosedGroups;
}

/// Server-owned coarse candidate constraint. Object decisions still apply.
final class CalendarCategoryQuery {
  const CalendarCategoryQuery(this.value, this.language);
  final String value;
  final String? language;
}

final class CalendarCandidatePlan {
  CalendarCandidatePlan({Iterable<UuidValue>? calendarIds})
    : calendarIds = calendarIds == null ? null : Set.unmodifiable(calendarIds);
  final Set<UuidValue>? calendarIds;
}

/// Trusted current recipient, never accepted from generated-client requests.
final class CalendarAlarmRecipient {
  const CalendarAlarmRecipient(this.namespace, this.key);
  final String namespace, key;
}

/// Hosts supply rules and a truthful guarantee. All methods must be side-effect
/// free except transactional locking; no notification/mail/business writes.
abstract interface class CalendarHostPolicy {
  CalendarAuthorizationGuarantee get guarantee;
  Future<CalendarHostContext> resolveContext(Session session);

  /// Resolve only the authenticated current recipient. Coordinate revocation at
  /// finalWrite under the same declared guarantee as ordinary policy checks.
  Future<CalendarAlarmRecipient> resolveAlarmRecipient(
    Session session,
    CalendarHostContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
  Future<CalendarCandidatePlan> planQuery(
    Session session,
    CalendarHostContext context,
    Set<CalendarFieldGroup> requestedGroups, {
    CalendarCategoryQuery? categoryFilter,
  });

  Future<CalendarTaskCandidatePlan> planTaskQuery(
    Session session,
    CalendarHostContext context,
    CalendarPolicySnapshot calendar,
    Set<CalendarTaskFieldGroup> requestedGroups, {
    CalendarCategoryQuery? categoryFilter,
  });

  /// Complete trusted query eligibility, not a partial optimization hint.
  /// Use this transaction for coordinated candidate/membership policy reads.
  Future<CalendarEventCandidatePlan> planEventOccurrenceQuery(
    Session session,
    CalendarHostContext context,
    CalendarPolicySnapshot calendar,
    CalendarEventOccurrenceListQuery query,
    Set<CalendarEventFieldGroup> requestedGroups,
    Transaction transaction,
  );

  Future<CalendarEventCandidatePlan> planEventQuery(
    Session session,
    CalendarHostContext context,
    CalendarPolicySnapshot calendar,
    Set<CalendarEventFieldGroup> requestedGroups, {
    CalendarCategoryQuery? categoryFilter,
  });

  /// Authoritative complete contributor set within the trusted scope. Never a
  /// detail-filtered candidate plan. Unresolved/external coverage is incomplete.
  /// Use this transaction to coordinate host mapping state when possible; an
  /// external resolver must expose a revision that changes with its mapping.
  Future<CalendarSubjectResolution> resolveAvailabilitySubject(
    Session session,
    CalendarHostContext context,
    CalendarAvailabilityTarget target,
    Transaction transaction,
  );

  /// Independent approval of the final organizer proposal (including removal).
  /// Called for preliminary/final writes; never grants ordinary metadata rights.
  /// Apply the same declared coordination guarantee as authorizeBatch.
  Future<CalendarAuthorizationVerdict> approveAvailabilityOrganizer(
    Session session,
    CalendarHostContext context,
    CalendarAuthorizationRequest request,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );

  /// For coordinated guarantees, finalWrite must coordinate every relevant
  /// policy revocation through this transaction until its actual commit.
  /// A version label alone is not coordination. Every retry is a new call.
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session session,
    CalendarHostContext context,
    List<CalendarAuthorizationRequest> requests,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

/// Future optional modules register their real dependencies here and must use
/// the same active-parent transaction/lock boundary for child writes.
abstract interface class CalendarDependencyProvider {
  Future<bool> hasActiveDependencies(
    Session session,
    UuidValue calendarId,
    Transaction transaction,
  );
}

final class CalendarModuleOptions {
  const CalendarModuleOptions({
    required this.requiredWriteGuarantee,
    this.maxPageSize = 100,
    this.maxOccurrenceQueryDays = 366,
    this.maxOccurrenceCandidateWork = 100000,
    this.maxOccurrenceResults = 10000,
    this.maxScannedCalendars = 1000,
    this.maxScannedEvents = 1000,
    this.maxScannedTasks = 1000,
    this.policyBatchSize = 64,
    this.maxAssociations = 64,
    this.maxCursorsPerScope = 64,
    this.cursorLifetime = const Duration(minutes: 10),
    this.policyTimeout = const Duration(seconds: 5),
  });
  final CalendarAuthorizationGuarantee requiredWriteGuarantee;
  final int maxOccurrenceQueryDays,
      maxOccurrenceCandidateWork,
      maxOccurrenceResults;
  final int maxPageSize,
      maxScannedCalendars,
      maxScannedEvents,
      maxScannedTasks,
      policyBatchSize,
      maxAssociations,
      maxCursorsPerScope;
  final Duration cursorLifetime, policyTimeout;
}

final class CalendarEventCandidatePlan {
  CalendarEventCandidatePlan({Iterable<UuidValue>? eventIds})
    : eventIds = eventIds == null ? null : Set.unmodifiable(eventIds);
  final Set<UuidValue>? eventIds;
}

final class CalendarEventPolicySnapshot {
  const CalendarEventPolicySnapshot(
    this.eventId,
    this.calendarId,
    this.revision,
    this.content,
    this.protocolUid,
    this.updatedAt, {
    this.origin = CalendarEventOrigin.unknown,
    this.timingOverrides,
    this.protocolState,
  });
  final CalendarEventTimingOverrides? timingOverrides;
  final CalendarEventProtocolState? protocolState;
  final CalendarEventOrigin origin;
  final UuidValue eventId, calendarId;
  final int revision;
  final CalendarEventContent content;
  final String protocolUid;
  final DateTime updatedAt;
}

/// Validated, frozen native rule state plus its actual parent identity.
final class CalendarAvailabilityPolicySnapshot {
  const CalendarAvailabilityPolicySnapshot(
    this.availabilityId,
    this.calendarId,
    this.revision,
    this.content,
    this.protocolUid,
    this.updatedAt, {
    this.timingOverrides,
    required this.protocolState,
  });
  final List<CalendarAvailabilityOpeningEdits>? timingOverrides;
  final CalendarAvailabilityProtocolState protocolState;
  final UuidValue availabilityId, calendarId;
  final String protocolUid;
  final int revision;
  final CalendarAvailabilityContent content;
  final DateTime updatedAt;
}

/// Trusted host result; not client input. Empty sets never establish free time.
final class CalendarSubjectResolution {
  CalendarSubjectResolution({
    required this.complete,
    required this.revision,
    required Iterable<UuidValue> calendarIds,
  }) : calendarIds = List.unmodifiable(calendarIds);
  final bool complete;
  final String revision;
  final List<UuidValue> calendarIds;
}

/// Private metadata only: no core behavior or authorization may depend on it.
enum CalendarAvailabilityExtensionContext { definition, opening }

final class CalendarAvailabilityExtensionRegistration {
  CalendarAvailabilityExtensionRegistration({
    required this.name,
    required Iterable<CalendarAvailabilityExtensionContext> contexts,
    required this.validate,
  }) : contexts = Set.unmodifiable(contexts);
  final String name;
  final Set<CalendarAvailabilityExtensionContext> contexts;

  /// Side-effect-free bounded validation of decoded TEXT, not content lines.
  final bool Function(String value) validate;
}

final class CalendarTaskCandidatePlan {
  CalendarTaskCandidatePlan({Iterable<UuidValue>? taskIds})
    : taskIds = taskIds == null ? null : Set.unmodifiable(taskIds);
  final Set<UuidValue>? taskIds;
}

final class CalendarTaskPolicySnapshot {
  CalendarTaskPolicySnapshot({
    required this.taskId,
    required this.calendarId,
    required this.revision,
    required this.content,
    required this.progress,
    required Iterable<CalendarTaskAssignee> assignees,
    required this.protocolUid,
    required this.protocolVersion,
    required this.updatedAt,
    required this.hasRecordedProgress,
    CalendarTaskSourceState? sourceState,
  }) : sourceState = sourceState == null
           ? null
           : validateTaskSourceState(protocolUid, sourceState),
       assignees = List.unmodifiable(assignees);
  final UuidValue taskId, calendarId;
  final int revision;
  final bool? hasRecordedProgress;
  final CalendarTaskSourceState? sourceState;
  final CalendarTaskContent content;
  final CalendarTaskProgress progress;
  final List<CalendarTaskAssignee> assignees;
  final String protocolUid;
  final CalendarTaskProtocolVersion protocolVersion;
  final DateTime updatedAt;
}

/// Exact outgoing snapshot and recipients, never an authorization grant.
final class CalendarSchedulingIntent {
  CalendarSchedulingIntent({
    required this.organizerAddress,
    required Iterable<String> recipients,
    required this.payload,
    this.publicationId,
    required this.generation,
    this.method = 'REQUEST',
    CalendarSchedulingPublicationKind? publicationKind,
    this.originalStart,
  }) : recipients = List.unmodifiable(recipients),
       publicationKind =
           publicationKind ??
           (method == 'CANCEL'
               ? CalendarSchedulingPublicationKind.seriesCancel
               : CalendarSchedulingPublicationKind.request);
  final CalendarSchedulingPublicationKind publicationKind;
  final CalendarEventTiming? originalStart;
  final String method;
  final String organizerAddress, payload;
  final List<String> recipients;
  final UuidValue? publicationId;
  final int generation;
}
