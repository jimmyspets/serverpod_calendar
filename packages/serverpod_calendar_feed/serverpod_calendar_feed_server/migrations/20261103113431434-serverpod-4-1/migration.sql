BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "eventOccurrenceState" json;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_event_data" ADD COLUMN "origin" text NOT NULL DEFAULT 'unknown'::text;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "kind" text NOT NULL DEFAULT 'request'::text,
    "recurring" boolean NOT NULL DEFAULT false,
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "correlationDigest" text NOT NULL,
    "targetKey" text NOT NULL DEFAULT 'master'::text,
    "originalStart" json,
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
CREATE UNIQUE INDEX "calendar_invitation_correlation_unique" ON "serverpod_calendar_invitation" USING btree ("scopeKey", "recipientKey", "correlationDigest", "targetKey");
CREATE INDEX "calendar_invitation_recipient_idx" ON "serverpod_calendar_invitation" USING btree ("scopeKey", "recipientKey");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation_occurrence_application" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "linkId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "stateJson" text NOT NULL,
    "eventRevision" bigint NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_occurrence_application_link_unique" ON "serverpod_calendar_invitation_occurrence_application" USING btree ("linkId");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_application"
    ADD CONSTRAINT "serverpod_calendar_invitation_application_fk_0"
    FOREIGN KEY("linkId")
    REFERENCES "serverpod_calendar_invitation_link"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_occurrence_application"
    ADD CONSTRAINT "serverpod_calendar_invitation_occurrence_application_fk_0"
    FOREIGN KEY("linkId")
    REFERENCES "serverpod_calendar_invitation_link"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_receipt"
    ADD CONSTRAINT "serverpod_calendar_invitation_receipt_fk_0"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_invitation_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response_attempt"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_attempt_fk_0"
    FOREIGN KEY("responseId")
    REFERENCES "serverpod_calendar_invitation_response"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response_state"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_state_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_source"
    ADD CONSTRAINT "serverpod_calendar_invitation_source_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_attempt"
    ADD CONSTRAINT "serverpod_calendar_scheduling_attempt_fk_0"
    FOREIGN KEY("deliveryId")
    REFERENCES "serverpod_calendar_scheduling_delivery"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_delivery"
    ADD CONSTRAINT "serverpod_calendar_scheduling_delivery_fk_0"
    FOREIGN KEY("publicationId")
    REFERENCES "serverpod_calendar_scheduling_publication"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_meeting"
    ADD CONSTRAINT "serverpod_calendar_scheduling_meeting_fk_0"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_publication"
    ADD CONSTRAINT "serverpod_calendar_scheduling_publication_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_reply_source"
    ADD CONSTRAINT "serverpod_calendar_scheduling_reply_source_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar_feed
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar_feed', '20261103113431434-serverpod-4-1', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103113431434-serverpod-4-1', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261031120611007-instance-invitation-application', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261031120611007-instance-invitation-application', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_notifications
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_notifications', '20261025122205313-live-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025122205313-live-notifications', "timestamp" = now();


COMMIT;
