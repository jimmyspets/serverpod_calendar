BEGIN;

--
-- Class CalendarAlarmRecord as table serverpod_calendar_alarm
--
CREATE TABLE "serverpod_calendar_alarm" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "calendarId" uuid NOT NULL,
    "parentKind" text NOT NULL,
    "parentId" uuid NOT NULL,
    "recipientNamespace" text NOT NULL,
    "recipientKey" text NOT NULL,
    "revision" bigint NOT NULL,
    "armed" boolean NOT NULL DEFAULT false,
    "generation" bigint NOT NULL DEFAULT 1,
    "definition" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "calendar_alarm_private_parent_idx" ON "serverpod_calendar_alarm" USING btree ("scopeKey", "parentKind", "parentId", "recipientNamespace", "recipientKey");

--
-- Class CalendarAlarmActionRecord as table serverpod_calendar_alarm_action
--
CREATE TABLE "serverpod_calendar_alarm_action" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "alarmId" uuid NOT NULL,
    "originalKey" text NOT NULL,
    "revision" bigint NOT NULL,
    "resetAt" timestamp without time zone,
    "acknowledgedAt" timestamp without time zone,
    "dismissedAt" timestamp without time zone,
    "pendingSnoozeAt" timestamp without time zone,
    "snoozeRevision" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_alarm_action_identity_unique" ON "serverpod_calendar_alarm_action" USING btree ("alarmId", "originalKey");

--
-- Class CalendarAlarmFiringRecord as table serverpod_calendar_alarm_firing
--
CREATE TABLE "serverpod_calendar_alarm_firing" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "alarmId" uuid NOT NULL,
    "generation" bigint NOT NULL,
    "originalKey" text NOT NULL,
    "kind" text NOT NULL,
    "repeatOrdinal" bigint NOT NULL,
    "snoozeRevision" bigint NOT NULL DEFAULT 0,
    "dueAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "state" text NOT NULL DEFAULT 'pending'::text,
    "reason" text,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "acceptedAt" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "leaseOwner" uuid,
    "leaseUntil" timestamp without time zone,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_alarm_firing_identity_unique" ON "serverpod_calendar_alarm_firing" USING btree ("alarmId", "generation", "originalKey", "kind", "repeatOrdinal", "snoozeRevision");
CREATE INDEX "calendar_alarm_firing_due_idx" ON "serverpod_calendar_alarm_firing" USING btree ("state", "nextAttemptAt", "leaseUntil");
CREATE INDEX "calendar_alarm_firing_terminal_idx" ON "serverpod_calendar_alarm_firing" USING btree ("terminalAt");

--
-- Class CalendarAlarmPlanRecord as table serverpod_calendar_alarm_plan
--
CREATE TABLE "serverpod_calendar_alarm_plan" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "alarmId" uuid NOT NULL,
    "scopeKey" text NOT NULL,
    "generation" bigint NOT NULL,
    "timingDigest" text,
    "windowStart" timestamp without time zone,
    "windowEnd" timestamp without time zone,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "reason" text,
    "dirty" boolean NOT NULL DEFAULT true,
    "nextScanAt" timestamp without time zone NOT NULL,
    "lastCompletedAt" timestamp without time zone,
    "leaseOwner" uuid,
    "leaseUntil" timestamp without time zone,
    "leaseFence" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "calendar_alarm_plan_alarm_unique" ON "serverpod_calendar_alarm_plan" USING btree ("alarmId");
CREATE INDEX "calendar_alarm_plan_due_idx" ON "serverpod_calendar_alarm_plan" USING btree ("nextScanAt", "leaseUntil");
CREATE INDEX "calendar_alarm_plan_scope_idx" ON "serverpod_calendar_alarm_plan" USING btree ("scopeKey");

--
-- Class CalendarAvailabilityRecord as table serverpod_calendar_availability
--
CREATE TABLE "serverpod_calendar_availability" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "calendarId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "calendar_availability_parent_idx" ON "serverpod_calendar_availability" USING btree ("calendarId", "id");

--
-- Class CalendarAvailabilityDataRecord as table serverpod_calendar_availability_data
--
CREATE TABLE "serverpod_calendar_availability_data" (
    "id" bigserial PRIMARY KEY,
    "availabilityId" uuid NOT NULL,
    "protocolUid" text NOT NULL,
    "calendarId" uuid NOT NULL,
    "uidDigest" text NOT NULL,
    "protocolState" json,
    "importBaseline" json,
    "timingOverrides" json,
    "content" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_availability_data_identity_unique" ON "serverpod_calendar_availability_data" USING btree ("availabilityId");
CREATE INDEX "calendar_availability_data_uid_candidates" ON "serverpod_calendar_availability_data" USING btree ("calendarId", "uidDigest");

--
-- Class CalendarCursorRecord as table serverpod_calendar_cursor
--
CREATE TABLE "serverpod_calendar_cursor" (
    "id" bigserial PRIMARY KEY,
    "token" text NOT NULL,
    "scopeKey" text NOT NULL,
    "principalId" text NOT NULL,
    "policyRevision" text NOT NULL,
    "dataRevision" bigint NOT NULL,
    "afterId" uuid NOT NULL,
    "pageSize" bigint NOT NULL,
    "fieldGroups" json NOT NULL,
    "taskCalendarId" uuid,
    "taskFieldGroups" json,
    "eventCalendarId" uuid,
    "eventFieldGroups" json,
    "eventOccurrenceState" json,
    "categoryFilter" json,
    "alarmActivityId" uuid,
    "alarmActivityKind" text,
    "expiresAt" timestamp without time zone NOT NULL,
    "taskHistoryTaskId" uuid,
    "taskHistoryOriginalKey" text,
    "taskHistoryAfterRevision" bigint
);

-- Indexes
CREATE UNIQUE INDEX "calendar_cursor_token_unique" ON "serverpod_calendar_cursor" USING btree ("token");
CREATE INDEX "calendar_cursor_expiry_idx" ON "serverpod_calendar_cursor" USING btree ("expiresAt");

--
-- Class CalendarDataRecord as table serverpod_calendar_data
--
CREATE TABLE "serverpod_calendar_data" (
    "id" bigserial PRIMARY KEY,
    "calendarId" uuid NOT NULL,
    "protocolUid" uuid NOT NULL DEFAULT gen_random_uuid(),
    "displayName" text NOT NULL,
    "description" text,
    "color" text,
    "availabilityZoneId" text NOT NULL,
    "noRuleFallback" text NOT NULL,
    "protocolMetadata" json,
    "supplementalMetadata" json,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_data_protocol_uid_unique" ON "serverpod_calendar_data" USING btree ("protocolUid");
CREATE UNIQUE INDEX "calendar_data_identity_unique" ON "serverpod_calendar_data" USING btree ("calendarId");

--
-- Class CalendarEventRecord as table serverpod_calendar_event
--
CREATE TABLE "serverpod_calendar_event" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "calendarId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "calendar_event_parent_idx" ON "serverpod_calendar_event" USING btree ("calendarId", "id");

--
-- Class CalendarEventDataRecord as table serverpod_calendar_event_data
--
CREATE TABLE "serverpod_calendar_event_data" (
    "id" bigserial PRIMARY KEY,
    "eventId" uuid NOT NULL,
    "calendarId" uuid NOT NULL,
    "origin" text NOT NULL DEFAULT 'unknown'::text,
    "protocolUid" text NOT NULL,
    "uidDigest" text NOT NULL,
    "protocolState" json,
    "importBaseline" json,
    "timingOverrides" json,
    "content" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_event_data_identity_unique" ON "serverpod_calendar_event_data" USING btree ("eventId");
CREATE INDEX "calendar_event_data_uid_candidates" ON "serverpod_calendar_event_data" USING btree ("calendarId", "uidDigest");

--
-- Class CalendarIdentityRecord as table serverpod_calendar_identity
--
CREATE TABLE "serverpod_calendar_identity" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "revision" bigint NOT NULL,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "calendar_identity_scope_idx" ON "serverpod_calendar_identity" USING btree ("scopeKey", "id");

--
-- Class CalendarInvitationRecord as table serverpod_calendar_invitation
--
CREATE TABLE "serverpod_calendar_invitation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "kind" text NOT NULL DEFAULT 'request'::text,
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "correlationDigest" text NOT NULL,
    "uid" text NOT NULL,
    "organizer" text NOT NULL,
    "revision" bigint NOT NULL,
    "currentSourceId" uuid,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "digest" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "dismissedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_correlation_unique" ON "serverpod_calendar_invitation" USING btree ("scopeKey", "recipientKey", "correlationDigest");
CREATE INDEX "calendar_invitation_recipient_idx" ON "serverpod_calendar_invitation" USING btree ("scopeKey", "recipientKey");

--
-- Class CalendarInvitationApplicationRecord as table serverpod_calendar_invitation_application
--
CREATE TABLE "serverpod_calendar_invitation_application" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "kind" text NOT NULL DEFAULT 'request'::text,
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "linkId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "invitationId" uuid NOT NULL,
    "sourceId" uuid NOT NULL,
    "digest" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "baselineDigest" text NOT NULL,
    "creationDigest" text NOT NULL,
    "eventRevision" bigint NOT NULL,
    "invitationRevision" bigint NOT NULL,
    "appliedAt" timestamp without time zone NOT NULL,
    "requestDigest" text NOT NULL,
    "resultId" uuid NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_application_link_unique" ON "serverpod_calendar_invitation_application" USING btree ("linkId");

--
-- Class CalendarInvitationLinkRecord as table serverpod_calendar_invitation_link
--
CREATE TABLE "serverpod_calendar_invitation_link" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "uid" text NOT NULL,
    "organizer" text NOT NULL,
    "correlationDigest" text NOT NULL,
    "invitationId" uuid NOT NULL,
    "sourceId" uuid NOT NULL,
    "sourceDigest" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "calendarId" uuid NOT NULL,
    "eventId" uuid NOT NULL,
    "requestDigest" text NOT NULL,
    "eventRevision" bigint NOT NULL,
    "invitationRevision" bigint NOT NULL,
    "adoptedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_link_correlation_unique" ON "serverpod_calendar_invitation_link" USING btree ("scopeKey", "recipientKey", "correlationDigest");
CREATE UNIQUE INDEX "calendar_invitation_link_original_unique" ON "serverpod_calendar_invitation_link" USING btree ("scopeKey", "recipientKey", "invitationId");
CREATE UNIQUE INDEX "calendar_invitation_link_event_unique" ON "serverpod_calendar_invitation_link" USING btree ("eventId");

--
-- Class CalendarInvitationReceiptRecord as table serverpod_calendar_invitation_receipt
--
CREATE TABLE "serverpod_calendar_invitation_receipt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "ingressDigest" text NOT NULL,
    "sourceId" uuid NOT NULL,
    "originDigest" text NOT NULL,
    "outcome" text NOT NULL,
    "entryRevision" bigint NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_receipt_key_unique" ON "serverpod_calendar_invitation_receipt" USING btree ("scopeKey", "recipientKey", "ingressDigest");
CREATE INDEX "calendar_invitation_receipt_source_idx" ON "serverpod_calendar_invitation_receipt" USING btree ("sourceId");
CREATE INDEX "calendar_invitation_receipt_expiry_idx" ON "serverpod_calendar_invitation_receipt" USING btree ("scopeKey", "recipientKey", "expiresAt");

--
-- Class CalendarInvitationResponseRecord as table serverpod_calendar_invitation_response
--
CREATE TABLE "serverpod_calendar_invitation_response" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "stateId" uuid NOT NULL,
    "entryId" uuid NOT NULL,
    "commandId" uuid NOT NULL,
    "criteriaDigest" text NOT NULL,
    "request" json NOT NULL,
    "receipt" json NOT NULL,
    "sourceId" uuid NOT NULL,
    "sourceRevision" bigint NOT NULL,
    "sourceDigest" text NOT NULL,
    "sourceSequence" bigint,
    "sourceStamp" timestamp without time zone NOT NULL,
    "recipientAddress" text NOT NULL,
    "organizerAddress" text NOT NULL,
    "authorityRef" text NOT NULL,
    "routeRef" text NOT NULL,
    "generation" bigint NOT NULL,
    "choice" text NOT NULL,
    "stamp" timestamp without time zone NOT NULL,
    "payload" text NOT NULL,
    "payloadDigest" text NOT NULL,
    "byteCount" bigint NOT NULL,
    "state" text NOT NULL DEFAULT 'queued'::text,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "leaseOwner" uuid,
    "leaseToken" uuid,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "leaseUntil" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_response_command_unique" ON "serverpod_calendar_invitation_response" USING btree ("scopeKey", "recipientKey", "commandId");
CREATE INDEX "calendar_invitation_response_due_idx" ON "serverpod_calendar_invitation_response" USING btree ("terminalAt", "nextAttemptAt", "leaseUntil");
CREATE INDEX "calendar_invitation_response_recipient_idx" ON "serverpod_calendar_invitation_response" USING btree ("scopeKey", "recipientKey", "stateId");

--
-- Class CalendarInvitationResponseAttemptRecord as table serverpod_calendar_invitation_response_attempt
--
CREATE TABLE "serverpod_calendar_invitation_response_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "responseId" uuid NOT NULL,
    "attemptNumber" bigint NOT NULL,
    "leaseToken" uuid NOT NULL,
    "leaseFence" bigint NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "finishedAt" timestamp without time zone,
    "outcome" text NOT NULL,
    "adapterReceipt" text,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_response_attempt_number_unique" ON "serverpod_calendar_invitation_response_attempt" USING btree ("responseId", "attemptNumber");

--
-- Class CalendarInvitationResponseStateRecord as table serverpod_calendar_invitation_response_state
--
CREATE TABLE "serverpod_calendar_invitation_response_state" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "entryId" uuid NOT NULL,
    "recipientAddress" text NOT NULL,
    "revision" bigint NOT NULL,
    "latestResponseId" uuid NOT NULL,
    "lastStamp" timestamp without time zone NOT NULL,
    "choice" text NOT NULL,
    "sourceId" uuid NOT NULL,
    "sourceRevision" bigint NOT NULL,
    "sourceDigest" text NOT NULL,
    "sourceSequence" bigint,
    "sourceStamp" timestamp without time zone NOT NULL,
    "outcome" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_response_state_unique" ON "serverpod_calendar_invitation_response_state" USING btree ("scopeKey", "recipientKey", "entryId");
CREATE INDEX "calendar_invitation_response_state_scope_idx" ON "serverpod_calendar_invitation_response_state" USING btree ("scopeKey", "recipientKey");

--
-- Class CalendarInvitationSourceRecord as table serverpod_calendar_invitation_source
--
CREATE TABLE "serverpod_calendar_invitation_source" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "entryId" uuid NOT NULL,
    "normalizedSource" text NOT NULL,
    "byteCount" bigint NOT NULL,
    "digest" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "outcome" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "inactiveAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_source_digest_unique" ON "serverpod_calendar_invitation_source" USING btree ("entryId", "digest");
CREATE INDEX "calendar_invitation_source_entry_time_idx" ON "serverpod_calendar_invitation_source" USING btree ("entryId", "inactiveAt");

--
-- Class CalendarSchedulingAttemptRecord as table serverpod_calendar_scheduling_attempt
--
CREATE TABLE "serverpod_calendar_scheduling_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "deliveryId" uuid NOT NULL,
    "attemptNumber" bigint NOT NULL,
    "leaseToken" uuid NOT NULL,
    "leaseFence" bigint NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "finishedAt" timestamp without time zone,
    "outcome" text NOT NULL,
    "adapterReceipt" text,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_scheduling_attempt_number_unique" ON "serverpod_calendar_scheduling_attempt" USING btree ("deliveryId", "attemptNumber");

--
-- Class CalendarSchedulingAttendeeResponseRecord as table serverpod_calendar_scheduling_attendee_response
--
CREATE TABLE "serverpod_calendar_scheduling_attendee_response" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "attendeeAddress" text NOT NULL,
    "targetKey" text NOT NULL DEFAULT 'master'::text,
    "revision" bigint NOT NULL,
    "sourceId" uuid NOT NULL,
    "sequence" bigint NOT NULL,
    "stamp" timestamp without time zone NOT NULL,
    "sourceParticipation" text,
    "effectiveParticipation" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_attendee_response_address_unique" ON "serverpod_calendar_scheduling_attendee_response" USING btree ("meetingId", "attendeeAddress", "targetKey");
CREATE INDEX "calendar_attendee_response_source_idx" ON "serverpod_calendar_scheduling_attendee_response" USING btree ("sourceId");
CREATE INDEX "calendar_attendee_response_scope_idx" ON "serverpod_calendar_scheduling_attendee_response" USING btree ("scopeKey");

--
-- Class CalendarSchedulingDeliveryRecord as table serverpod_calendar_scheduling_delivery
--
CREATE TABLE "serverpod_calendar_scheduling_delivery" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "publicationId" uuid NOT NULL,
    "recipientAddress" text NOT NULL,
    "routeRef" text NOT NULL,
    "deliveryKey" uuid NOT NULL DEFAULT gen_random_uuid(),
    "state" text NOT NULL DEFAULT 'pending'::text,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "leaseOwner" uuid,
    "leaseToken" uuid,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "leaseUntil" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_scheduling_delivery_recipient_unique" ON "serverpod_calendar_scheduling_delivery" USING btree ("publicationId", "recipientAddress");
CREATE UNIQUE INDEX "calendar_scheduling_delivery_key_unique" ON "serverpod_calendar_scheduling_delivery" USING btree ("deliveryKey");
CREATE INDEX "calendar_scheduling_delivery_due_idx" ON "serverpod_calendar_scheduling_delivery" USING btree ("state", "nextAttemptAt", "leaseUntil");
CREATE INDEX "calendar_scheduling_delivery_scope_idx" ON "serverpod_calendar_scheduling_delivery" USING btree ("scopeKey", "terminalAt");

--
-- Class CalendarSchedulingMeetingRecord as table serverpod_calendar_scheduling_meeting
--
CREATE TABLE "serverpod_calendar_scheduling_meeting" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "calendarId" uuid NOT NULL,
    "eventId" uuid NOT NULL,
    "organizerAddress" text NOT NULL,
    "authorityRef" text NOT NULL,
    "revision" bigint NOT NULL,
    "generation" bigint NOT NULL,
    "latestPublicationId" uuid,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_scheduling_meeting_event_unique" ON "serverpod_calendar_scheduling_meeting" USING btree ("eventId");
CREATE INDEX "calendar_scheduling_meeting_scope_idx" ON "serverpod_calendar_scheduling_meeting" USING btree ("scopeKey");

--
-- Class CalendarSchedulingPublicationRecord as table serverpod_calendar_scheduling_publication
--
CREATE TABLE "serverpod_calendar_scheduling_publication" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "generation" bigint NOT NULL,
    "method" text NOT NULL,
    "protocolUid" text NOT NULL,
    "sequence" bigint NOT NULL,
    "stamp" timestamp without time zone NOT NULL,
    "snapshot" text NOT NULL,
    "projection" text NOT NULL,
    "payload" text NOT NULL,
    "payloadDigest" text NOT NULL,
    "recipients" json NOT NULL,
    "commandId" uuid NOT NULL,
    "actorId" text NOT NULL,
    "requestDigest" text NOT NULL,
    "expectedRevision" bigint NOT NULL,
    "eventRevision" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "completedAt" timestamp without time zone,
    "outcome" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_scheduling_publication_generation_unique" ON "serverpod_calendar_scheduling_publication" USING btree ("meetingId", "generation");
CREATE UNIQUE INDEX "calendar_scheduling_publication_command_unique" ON "serverpod_calendar_scheduling_publication" USING btree ("scopeKey", "commandId");
CREATE INDEX "calendar_scheduling_publication_cleanup_idx" ON "serverpod_calendar_scheduling_publication" USING btree ("completedAt");

--
-- Class CalendarSchedulingReplyReceiptRecord as table serverpod_calendar_scheduling_reply_receipt
--
CREATE TABLE "serverpod_calendar_scheduling_reply_receipt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "sourceId" uuid NOT NULL,
    "ingressDigest" text NOT NULL,
    "outcome" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_reply_receipt_key_unique" ON "serverpod_calendar_scheduling_reply_receipt" USING btree ("scopeKey", "meetingId", "ingressDigest");
CREATE INDEX "calendar_reply_receipt_source_idx" ON "serverpod_calendar_scheduling_reply_receipt" USING btree ("sourceId");
CREATE INDEX "calendar_reply_receipt_scope_time_idx" ON "serverpod_calendar_scheduling_reply_receipt" USING btree ("scopeKey", "receivedAt");

--
-- Class CalendarSchedulingReplySourceRecord as table serverpod_calendar_scheduling_reply_source
--
CREATE TABLE "serverpod_calendar_scheduling_reply_source" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "attendeeAddress" text NOT NULL,
    "targetKey" text NOT NULL DEFAULT 'master'::text,
    "originalStart" json,
    "targetBasisKey" text NOT NULL DEFAULT 'master'::text,
    "digest" text NOT NULL,
    "normalizedSource" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "sourceParticipation" text,
    "effectiveParticipation" text NOT NULL,
    "outcome" text NOT NULL,
    "publishedSequence" bigint NOT NULL,
    "publishedCancelled" boolean NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "inactiveAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "calendar_reply_source_message_unique" ON "serverpod_calendar_scheduling_reply_source" USING btree ("meetingId", "attendeeAddress", "digest");
CREATE INDEX "calendar_reply_source_scope_inactive_idx" ON "serverpod_calendar_scheduling_reply_source" USING btree ("scopeKey", "inactiveAt");

--
-- Class CalendarScopeRecord as table serverpod_calendar_scope
--
CREATE TABLE "serverpod_calendar_scope" (
    "id" bigserial PRIMARY KEY,
    "scopeKey" text NOT NULL,
    "revision" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_scope_key_unique" ON "serverpod_calendar_scope" USING btree ("scopeKey");

--
-- Class CalendarSubjectRecord as table serverpod_calendar_subject
--
CREATE TABLE "serverpod_calendar_subject" (
    "id" bigserial PRIMARY KEY,
    "calendarId" uuid NOT NULL,
    "namespace" text NOT NULL,
    "kind" text NOT NULL,
    "externalId" text NOT NULL,
    "contributesAvailability" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_subject_tuple_unique" ON "serverpod_calendar_subject" USING btree ("calendarId", "namespace", "kind", "externalId");

--
-- Class CalendarTaskRecord as table serverpod_calendar_task
--
CREATE TABLE "serverpod_calendar_task" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "calendarId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "calendar_task_parent_idx" ON "serverpod_calendar_task" USING btree ("calendarId", "id");

--
-- Class CalendarTaskDataRecord as table serverpod_calendar_task_data
--
CREATE TABLE "serverpod_calendar_task_data" (
    "id" bigserial PRIMARY KEY,
    "taskId" uuid NOT NULL,
    "calendarId" uuid NOT NULL,
    "protocolUid" text NOT NULL,
    "uidDigest" text NOT NULL,
    "protocolVersion" json NOT NULL,
    "content" json NOT NULL,
    "progress" json NOT NULL,
    "assignees" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "hasRecordedProgress" boolean,
    "sourceState" json,
    "importBaseline" json
);

-- Indexes
CREATE UNIQUE INDEX "calendar_task_data_identity_unique" ON "serverpod_calendar_task_data" USING btree ("taskId");
CREATE INDEX "calendar_task_data_uid_candidates" ON "serverpod_calendar_task_data" USING btree ("calendarId", "uidDigest");

--
-- Class CalendarTaskHistoryRecord as table serverpod_calendar_task_history
--
CREATE TABLE "serverpod_calendar_task_history" (
    "id" bigserial PRIMARY KEY,
    "taskId" uuid NOT NULL,
    "originalKey" text NOT NULL,
    "originalStart" json NOT NULL,
    "revision" bigint NOT NULL,
    "action" text NOT NULL,
    "before" json NOT NULL,
    "after" json NOT NULL,
    "recordedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_task_history_revision_unique" ON "serverpod_calendar_task_history" USING btree ("taskId", "revision");
CREATE INDEX "calendar_task_history_original_idx" ON "serverpod_calendar_task_history" USING btree ("taskId", "originalKey", "revision");

--
-- Class CalendarTaskOccurrenceRecord as table serverpod_calendar_task_occurrence
--
CREATE TABLE "serverpod_calendar_task_occurrence" (
    "id" bigserial PRIMARY KEY,
    "taskId" uuid NOT NULL,
    "originalKey" text NOT NULL,
    "originalStart" json NOT NULL,
    "replacementTiming" json,
    "futureTiming" json,
    "contentOverrides" json,
    "progress" json NOT NULL,
    "protocolVersion" json
);

-- Indexes
CREATE UNIQUE INDEX "calendar_task_occurrence_identity_unique" ON "serverpod_calendar_task_occurrence" USING btree ("taskId", "originalKey");

--
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectDownloadEntry as table serverpod_cloud_storage_direct_download
--
CREATE TABLE "serverpod_cloud_storage_direct_download" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "downloadFileName" text,
    "contentType" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_download_auth_key" ON "serverpod_cloud_storage_direct_download" USING btree ("authKey");
CREATE INDEX "serverpod_cloud_storage_direct_download_expiration" ON "serverpod_cloud_storage_direct_download" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "maxFileSize" bigint NOT NULL DEFAULT 10485760,
    "contentLength" bigint,
    "preventOverwrite" boolean NOT NULL DEFAULT false,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text,
    "scheduling" json
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class FutureCallClaimEntry as table serverpod_future_call_claim
--
CREATE TABLE "serverpod_future_call_claim" (
    "id" bigserial PRIMARY KEY,
    "futureCallId" bigint,
    "lastHeartbeatTime" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "future_call_unique_idx" ON "serverpod_future_call_claim" USING btree ("futureCallId");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId", "order");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_message_log_sessionLogId_idx" ON "serverpod_message_log" USING btree ("sessionLogId", "order");

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId", "order");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "userId" text,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Class NotificationCursorRecord as table serverpod_notifications_cursor
--
CREATE TABLE "serverpod_notifications_cursor" (
    "id" bigserial PRIMARY KEY,
    "token" text NOT NULL,
    "scopeKey" text NOT NULL,
    "principalId" text NOT NULL,
    "policyRevision" text NOT NULL,
    "recipientNamespace" text NOT NULL,
    "recipientKey" text NOT NULL,
    "afterId" uuid NOT NULL,
    "pageSize" bigint NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_cursor_token_unique" ON "serverpod_notifications_cursor" USING btree ("token");
CREATE INDEX "notification_cursor_expiry_idx" ON "serverpod_notifications_cursor" USING btree ("expiresAt");

--
-- Class NotificationDeliveryRecord as table serverpod_notifications_delivery
--
CREATE TABLE "serverpod_notifications_delivery" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientNamespace" text NOT NULL,
    "recipientKey" text NOT NULL,
    "sourceNamespace" text NOT NULL,
    "sourceVersion" bigint NOT NULL,
    "sourceRequestId" text NOT NULL,
    "requestDigest" text NOT NULL,
    "sourceReference" text NOT NULL,
    "dueAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "state" text NOT NULL DEFAULT 'queued'::text,
    "reason" text,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "leaseOwner" uuid,
    "leaseUntil" timestamp without time zone,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "publishedAt" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_request_unique" ON "serverpod_notifications_delivery" USING btree ("scopeKey", "sourceNamespace", "sourceRequestId");
CREATE INDEX "notification_due_idx" ON "serverpod_notifications_delivery" USING btree ("state", "nextAttemptAt", "leaseUntil");
CREATE INDEX "notification_recipient_idx" ON "serverpod_notifications_delivery" USING btree ("scopeKey", "recipientNamespace", "recipientKey", "expiresAt", "id");
CREATE INDEX "notification_terminal_idx" ON "serverpod_notifications_delivery" USING btree ("terminalAt", "expiresAt");

--
-- Class NotificationScopeRecord as table serverpod_notifications_scope
--
CREATE TABLE "serverpod_notifications_scope" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_scope_key_unique" ON "serverpod_notifications_scope" USING btree ("scopeKey");

--
-- Foreign relations for "serverpod_calendar_alarm" table
--
ALTER TABLE ONLY "serverpod_calendar_alarm"
    ADD CONSTRAINT "serverpod_calendar_alarm_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_alarm_action" table
--
ALTER TABLE ONLY "serverpod_calendar_alarm_action"
    ADD CONSTRAINT "serverpod_calendar_alarm_action_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_alarm_firing" table
--
ALTER TABLE ONLY "serverpod_calendar_alarm_firing"
    ADD CONSTRAINT "serverpod_calendar_alarm_firing_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_alarm_plan" table
--
ALTER TABLE ONLY "serverpod_calendar_alarm_plan"
    ADD CONSTRAINT "serverpod_calendar_alarm_plan_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_availability" table
--
ALTER TABLE ONLY "serverpod_calendar_availability"
    ADD CONSTRAINT "serverpod_calendar_availability_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_availability_data" table
--
ALTER TABLE ONLY "serverpod_calendar_availability_data"
    ADD CONSTRAINT "serverpod_calendar_availability_data_fk_0"
    FOREIGN KEY("availabilityId")
    REFERENCES "serverpod_calendar_availability"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_availability_data"
    ADD CONSTRAINT "serverpod_calendar_availability_data_fk_1"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_data" table
--
ALTER TABLE ONLY "serverpod_calendar_data"
    ADD CONSTRAINT "serverpod_calendar_data_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_event" table
--
ALTER TABLE ONLY "serverpod_calendar_event"
    ADD CONSTRAINT "serverpod_calendar_event_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_event_data" table
--
ALTER TABLE ONLY "serverpod_calendar_event_data"
    ADD CONSTRAINT "serverpod_calendar_event_data_fk_0"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_invitation_application" table
--
ALTER TABLE ONLY "serverpod_calendar_invitation_application"
    ADD CONSTRAINT "serverpod_calendar_invitation_application_fk_0"
    FOREIGN KEY("linkId")
    REFERENCES "serverpod_calendar_invitation_link"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_invitation_link" table
--
ALTER TABLE ONLY "serverpod_calendar_invitation_link"
    ADD CONSTRAINT "serverpod_calendar_invitation_link_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_invitation_link"
    ADD CONSTRAINT "serverpod_calendar_invitation_link_fk_1"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_invitation_receipt" table
--
ALTER TABLE ONLY "serverpod_calendar_invitation_receipt"
    ADD CONSTRAINT "serverpod_calendar_invitation_receipt_fk_0"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_invitation_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_invitation_response" table
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_0"
    FOREIGN KEY("stateId")
    REFERENCES "serverpod_calendar_invitation_response_state"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_1"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_2"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_invitation_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_invitation_response_attempt" table
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response_attempt"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_attempt_fk_0"
    FOREIGN KEY("responseId")
    REFERENCES "serverpod_calendar_invitation_response"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_invitation_response_state" table
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response_state"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_state_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_invitation_source" table
--
ALTER TABLE ONLY "serverpod_calendar_invitation_source"
    ADD CONSTRAINT "serverpod_calendar_invitation_source_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_scheduling_attempt" table
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_attempt"
    ADD CONSTRAINT "serverpod_calendar_scheduling_attempt_fk_0"
    FOREIGN KEY("deliveryId")
    REFERENCES "serverpod_calendar_scheduling_delivery"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_scheduling_attendee_response" table
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_attendee_response"
    ADD CONSTRAINT "serverpod_calendar_scheduling_attendee_response_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_scheduling_attendee_response"
    ADD CONSTRAINT "serverpod_calendar_scheduling_attendee_response_fk_1"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_scheduling_reply_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_scheduling_delivery" table
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_delivery"
    ADD CONSTRAINT "serverpod_calendar_scheduling_delivery_fk_0"
    FOREIGN KEY("publicationId")
    REFERENCES "serverpod_calendar_scheduling_publication"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_scheduling_meeting" table
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_meeting"
    ADD CONSTRAINT "serverpod_calendar_scheduling_meeting_fk_0"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_scheduling_publication" table
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_publication"
    ADD CONSTRAINT "serverpod_calendar_scheduling_publication_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_scheduling_reply_receipt" table
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_reply_receipt"
    ADD CONSTRAINT "serverpod_calendar_scheduling_reply_receipt_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_scheduling_reply_receipt"
    ADD CONSTRAINT "serverpod_calendar_scheduling_reply_receipt_fk_1"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_scheduling_reply_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_scheduling_reply_source" table
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_reply_source"
    ADD CONSTRAINT "serverpod_calendar_scheduling_reply_source_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_subject" table
--
ALTER TABLE ONLY "serverpod_calendar_subject"
    ADD CONSTRAINT "serverpod_calendar_subject_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_task" table
--
ALTER TABLE ONLY "serverpod_calendar_task"
    ADD CONSTRAINT "serverpod_calendar_task_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_task_data" table
--
ALTER TABLE ONLY "serverpod_calendar_task_data"
    ADD CONSTRAINT "serverpod_calendar_task_data_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_task_history" table
--
ALTER TABLE ONLY "serverpod_calendar_task_history"
    ADD CONSTRAINT "serverpod_calendar_task_history_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_calendar_task_occurrence" table
--
ALTER TABLE ONLY "serverpod_calendar_task_occurrence"
    ADD CONSTRAINT "serverpod_calendar_task_occurrence_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_future_call_claim" table
--
ALTER TABLE ONLY "serverpod_future_call_claim"
    ADD CONSTRAINT "serverpod_future_call_claim_fk_0"
    FOREIGN KEY("futureCallId")
    REFERENCES "serverpod_future_call"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261030180331863', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261030180331863', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_notifications
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_notifications', '20261025122205313-live-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025122205313-live-notifications', "timestamp" = now();


COMMIT;
