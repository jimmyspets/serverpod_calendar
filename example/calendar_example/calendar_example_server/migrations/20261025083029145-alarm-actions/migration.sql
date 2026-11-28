BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_alarm_action" ADD COLUMN "resetAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "alarmActivityId" uuid;
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "alarmActivityKind" text;

--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261025083029145-alarm-actions', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025083029145-alarm-actions', "timestamp" = now();

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
