BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "eventCalendarId" uuid;
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "eventFieldGroups" json;
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
    "protocolUid" uuid NOT NULL DEFAULT gen_random_uuid(),
    "content" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_event_data_identity_unique" ON "serverpod_calendar_event_data" USING btree ("eventId");
CREATE UNIQUE INDEX "calendar_event_data_uid_unique" ON "serverpod_calendar_event_data" USING btree ("protocolUid");

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
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261021064805603-native-single-events', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261021064805603-native-single-events', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261021064801824-native-single-events', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261021064801824-native-single-events', "timestamp" = now();

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
