BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "taskCalendarId" uuid;
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "taskFieldGroups" json;
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
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_task_data_identity_unique" ON "serverpod_calendar_task_data" USING btree ("taskId");
CREATE INDEX "calendar_task_data_uid_candidates" ON "serverpod_calendar_task_data" USING btree ("calendarId", "uidDigest");

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
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261023065425278-native-tasks', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023065425278-native-tasks', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261023065205705-native-tasks', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023065205705-native-tasks', "timestamp" = now();

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
