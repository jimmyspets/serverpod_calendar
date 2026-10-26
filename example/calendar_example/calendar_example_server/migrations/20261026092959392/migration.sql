BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_event_data" ADD COLUMN "origin" text NOT NULL DEFAULT 'unknown'::text;
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
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261026092959392', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261026092959392', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261026091909495', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261026091909495', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_calendar_feed
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar_feed', '20261025165452821', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025165452821', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_notifications
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_notifications', '20261025122205313-live-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025122205313-live-notifications', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
