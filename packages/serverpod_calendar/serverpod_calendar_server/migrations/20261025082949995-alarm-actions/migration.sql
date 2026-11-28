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
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261025082949995-alarm-actions', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025082949995-alarm-actions', "timestamp" = now();

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
    VALUES ('serverpod_notifications', '20261019170648369', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261019170648369', "timestamp" = now();


COMMIT;
