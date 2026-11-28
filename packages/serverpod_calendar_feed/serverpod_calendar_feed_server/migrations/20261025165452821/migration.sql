BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_feed_credential" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "feedId" uuid NOT NULL,
    "digestVersion" bigint NOT NULL,
    "digest" text NOT NULL,
    "label" text,
    "revision" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "revokedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "calendar_feed_credential_digest_unique" ON "serverpod_calendar_feed_credential" USING btree ("digestVersion", "digest");
CREATE INDEX "calendar_feed_credential_parent_idx" ON "serverpod_calendar_feed_credential" USING btree ("feedId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_feed_data" (
    "id" bigserial PRIMARY KEY,
    "feedId" uuid NOT NULL,
    "displayName" text NOT NULL,
    "protocolUid" uuid NOT NULL DEFAULT gen_random_uuid(),
    "protocolMetadata" json,
    "supplementalMetadata" json,
    "protocolModifiedAt" timestamp without time zone NOT NULL,
    "authorityReference" text NOT NULL,
    "profileVersion" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_feed_data_identity_unique" ON "serverpod_calendar_feed_data" USING btree ("feedId");
CREATE UNIQUE INDEX "calendar_feed_protocol_uid_unique" ON "serverpod_calendar_feed_data" USING btree ("protocolUid");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_feed_identity" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "revision" bigint NOT NULL,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "calendar_feed_identity_scope_idx" ON "serverpod_calendar_feed_identity" USING btree ("scopeKey", "id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_feed_selection" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "feedId" uuid NOT NULL,
    "calendarId" uuid NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_feed_selection_unique" ON "serverpod_calendar_feed_selection" USING btree ("feedId", "calendarId");
CREATE INDEX "calendar_feed_selection_calendar_idx" ON "serverpod_calendar_feed_selection" USING btree ("calendarId");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_event_data" (
    "id" bigserial PRIMARY KEY,
    "eventId" uuid NOT NULL,
    "calendarId" uuid NOT NULL,
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_scope" (
    "id" bigserial PRIMARY KEY,
    "scopeKey" text NOT NULL,
    "revision" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_scope_key_unique" ON "serverpod_calendar_scope" USING btree ("scopeKey");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_notifications_scope" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_scope_key_unique" ON "serverpod_notifications_scope" USING btree ("scopeKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_feed_credential"
    ADD CONSTRAINT "serverpod_calendar_feed_credential_fk_0"
    FOREIGN KEY("feedId")
    REFERENCES "serverpod_calendar_feed_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_feed_data"
    ADD CONSTRAINT "serverpod_calendar_feed_data_fk_0"
    FOREIGN KEY("feedId")
    REFERENCES "serverpod_calendar_feed_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_feed_selection"
    ADD CONSTRAINT "serverpod_calendar_feed_selection_fk_0"
    FOREIGN KEY("feedId")
    REFERENCES "serverpod_calendar_feed_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_alarm"
    ADD CONSTRAINT "serverpod_calendar_alarm_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_alarm_action"
    ADD CONSTRAINT "serverpod_calendar_alarm_action_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_alarm_firing"
    ADD CONSTRAINT "serverpod_calendar_alarm_firing_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_alarm_plan"
    ADD CONSTRAINT "serverpod_calendar_alarm_plan_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_availability"
    ADD CONSTRAINT "serverpod_calendar_availability_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_data"
    ADD CONSTRAINT "serverpod_calendar_data_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_event"
    ADD CONSTRAINT "serverpod_calendar_event_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_event_data"
    ADD CONSTRAINT "serverpod_calendar_event_data_fk_0"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_subject"
    ADD CONSTRAINT "serverpod_calendar_subject_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_task"
    ADD CONSTRAINT "serverpod_calendar_task_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_task_data"
    ADD CONSTRAINT "serverpod_calendar_task_data_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_task_history"
    ADD CONSTRAINT "serverpod_calendar_task_history_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_task_occurrence"
    ADD CONSTRAINT "serverpod_calendar_task_occurrence_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar_feed
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar_feed', '20261025165452821', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025165452821', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261025082949995-alarm-actions', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025082949995-alarm-actions', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_notifications
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_notifications', '20261025122205313-live-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025122205313-live-notifications', "timestamp" = now();


COMMIT;
