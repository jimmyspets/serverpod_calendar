BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_attendee_refresh" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "entryId" uuid NOT NULL,
    "commandId" uuid NOT NULL,
    "actorId" text NOT NULL,
    "sourceId" uuid NOT NULL,
    "sourceRevision" bigint NOT NULL,
    "sourceDigest" text NOT NULL,
    "sourceSequence" bigint,
    "sourceStamp" timestamp without time zone NOT NULL,
    "attendeeAddress" text NOT NULL,
    "organizerAddress" text NOT NULL,
    "authorityRef" text NOT NULL,
    "routeRef" text NOT NULL,
    "payload" text NOT NULL,
    "payloadDigest" text NOT NULL,
    "stamp" timestamp without time zone NOT NULL,
    "state" text NOT NULL DEFAULT 'queued'::text,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "leaseToken" uuid,
    "leaseUntil" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_attendee_refresh_command_unique" ON "serverpod_calendar_attendee_refresh" USING btree ("scopeKey", "recipientKey", "commandId");
CREATE INDEX "calendar_attendee_refresh_owner_idx" ON "serverpod_calendar_attendee_refresh" USING btree ("scopeKey", "recipientKey", "entryId");
CREATE INDEX "calendar_attendee_refresh_due_idx" ON "serverpod_calendar_attendee_refresh" USING btree ("terminalAt", "nextAttemptAt", "leaseUntil");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_attendee_refresh_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "deliveryId" uuid NOT NULL,
    "attemptNumber" bigint NOT NULL,
    "leaseToken" uuid NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "finishedAt" timestamp without time zone,
    "outcome" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_attendee_refresh_attempt_unique" ON "serverpod_calendar_attendee_refresh_attempt" USING btree ("deliveryId", "attemptNumber");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_attendee_refresh"
    ADD CONSTRAINT "serverpod_calendar_attendee_refresh_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_attendee_refresh"
    ADD CONSTRAINT "serverpod_calendar_attendee_refresh_fk_1"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_invitation_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_attendee_refresh_attempt"
    ADD CONSTRAINT "serverpod_calendar_attendee_refresh_attempt_fk_0"
    FOREIGN KEY("deliveryId")
    REFERENCES "serverpod_calendar_attendee_refresh"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261128151834089-attendee-event-refresh', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261128151834089-attendee-event-refresh', "timestamp" = now();

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
