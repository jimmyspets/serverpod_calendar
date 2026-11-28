BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "incomingPublicationState" json;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_incoming_publication" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "correlationDigest" text NOT NULL,
    "uid" text NOT NULL,
    "organizer" text NOT NULL,
    "recurring" boolean NOT NULL,
    "revision" bigint NOT NULL,
    "currentSourceId" uuid NOT NULL,
    "kind" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "digest" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "dismissedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "cal_incoming_publication_correlation_unique" ON "serverpod_calendar_incoming_publication" USING btree ("scopeKey", "recipientKey", "correlationDigest");
CREATE INDEX "cal_incoming_publication_recipient_idx" ON "serverpod_calendar_incoming_publication" USING btree ("scopeKey", "recipientKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_incoming_publication_link" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "entryId" uuid NOT NULL,
    "correlationDigest" text NOT NULL,
    "calendarId" uuid NOT NULL,
    "eventId" uuid NOT NULL,
    "creationSourceId" uuid,
    "creationActorId" text NOT NULL,
    "creationCommandId" uuid NOT NULL,
    "creationDigest" text NOT NULL,
    "creationReceipt" text NOT NULL,
    "acceptedSourceId" uuid,
    "basisSourceId" uuid,
    "baselineDigest" text,
    "acceptedAt" timestamp without time zone,
    "lastActorId" text,
    "lastCommandId" uuid,
    "lastCommandDigest" text,
    "lastReceipt" text,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "cal_incoming_publication_link_entry_unique" ON "serverpod_calendar_incoming_publication_link" USING btree ("scopeKey", "recipientKey", "entryId");
CREATE UNIQUE INDEX "cal_incoming_publication_link_event_unique" ON "serverpod_calendar_incoming_publication_link" USING btree ("eventId");
CREATE UNIQUE INDEX "cal_incoming_publication_link_creation_unique" ON "serverpod_calendar_incoming_publication_link" USING btree ("scopeKey", "recipientKey", "creationCommandId");
CREATE UNIQUE INDEX "cal_incoming_publication_link_latest_unique" ON "serverpod_calendar_incoming_publication_link" USING btree ("scopeKey", "recipientKey", "lastCommandId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_incoming_publication_receipt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "ingressDigest" text NOT NULL,
    "originDigest" text NOT NULL,
    "sourceId" uuid NOT NULL,
    "entryId" uuid NOT NULL,
    "outcome" text NOT NULL,
    "entryRevision" bigint NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "cal_incoming_publication_receipt_unique" ON "serverpod_calendar_incoming_publication_receipt" USING btree ("scopeKey", "recipientKey", "ingressDigest");
CREATE INDEX "cal_incoming_publication_receipt_source_idx" ON "serverpod_calendar_incoming_publication_receipt" USING btree ("sourceId");
CREATE INDEX "cal_incoming_publication_receipt_expiry_idx" ON "serverpod_calendar_incoming_publication_receipt" USING btree ("scopeKey", "recipientKey", "expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_incoming_publication_source" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "entryId" uuid NOT NULL,
    "normalizedSource" text,
    "byteCount" bigint NOT NULL,
    "digest" text NOT NULL,
    "kind" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "outcome" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "inactiveAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "cal_incoming_publication_source_digest_unique" ON "serverpod_calendar_incoming_publication_source" USING btree ("entryId", "digest");
CREATE INDEX "cal_incoming_publication_source_time_idx" ON "serverpod_calendar_incoming_publication_source" USING btree ("entryId", "inactiveAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_incoming_publication_link"
    ADD CONSTRAINT "serverpod_calendar_incoming_publication_link_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_incoming_publication_link"
    ADD CONSTRAINT "serverpod_calendar_incoming_publication_link_fk_1"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_incoming_publication_receipt"
    ADD CONSTRAINT "serverpod_calendar_incoming_publication_receipt_fk_0"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_incoming_publication_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_incoming_publication_source"
    ADD CONSTRAINT "serverpod_calendar_incoming_publication_source_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_incoming_publication"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261113075420884-incoming-publications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261113075420884-incoming-publications', "timestamp" = now();

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
    VALUES ('serverpod_auth_idp', '20261015164015382', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261015164015382', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261113075358506-incoming-publications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261113075358506-incoming-publications', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_calendar_feed
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar_feed', '20261103113431434-serverpod-4-1', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103113431434-serverpod-4-1', "timestamp" = now();

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
