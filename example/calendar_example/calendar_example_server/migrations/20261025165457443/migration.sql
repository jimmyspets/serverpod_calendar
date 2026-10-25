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
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261025165457443', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025165457443', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261025082949995-alarm-actions', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025082949995-alarm-actions', "timestamp" = now();

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
