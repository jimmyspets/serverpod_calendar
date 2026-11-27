BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "categoryFilter" json;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_data" ADD COLUMN "supplementalMetadata" json;

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261021051112409-calendar-links-categories', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261021051112409-calendar-links-categories', "timestamp" = now();

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
