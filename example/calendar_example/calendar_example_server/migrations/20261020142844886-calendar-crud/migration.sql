BEGIN;

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
    "expiresAt" timestamp without time zone NOT NULL
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
    "displayName" text NOT NULL,
    "availabilityZoneId" text NOT NULL,
    "noRuleFallback" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_data_identity_unique" ON "serverpod_calendar_data" USING btree ("calendarId");

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
ALTER TABLE ONLY "serverpod_calendar_subject"
    ADD CONSTRAINT "serverpod_calendar_subject_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261020142844886-calendar-crud', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261020142844886-calendar-crud', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261020142826866-calendar-crud', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261020142826866-calendar-crud', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_notifications
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_notifications', '20261019170648369', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261019170648369', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
