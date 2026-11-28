BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
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
ALTER TABLE ONLY "serverpod_calendar_invitation_source"
    ADD CONSTRAINT "serverpod_calendar_invitation_source_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261028182538524-invitation-review', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261028182538524-invitation-review', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261028182520278-invitation-review', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261028182520278-invitation-review', "timestamp" = now();

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
