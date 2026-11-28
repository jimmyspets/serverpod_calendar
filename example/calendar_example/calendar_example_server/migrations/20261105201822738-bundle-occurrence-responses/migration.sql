BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_invitation_response" ADD COLUMN "targetKey" text NOT NULL DEFAULT 'entry'::text;
ALTER TABLE "serverpod_calendar_invitation_response" ADD COLUMN "responseOriginalStart" json;
--
-- ACTION ALTER TABLE
--
DROP INDEX "calendar_invitation_response_state_unique";
ALTER TABLE "serverpod_calendar_invitation_response_state" ADD COLUMN "targetKey" text NOT NULL DEFAULT 'entry'::text;
ALTER TABLE "serverpod_calendar_invitation_response_state" ADD COLUMN "responseOriginalStart" json;
CREATE UNIQUE INDEX "calendar_invitation_response_state_unique" ON "serverpod_calendar_invitation_response_state" USING btree ("scopeKey", "recipientKey", "entryId", "targetKey");

--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261105201822738-bundle-occurrence-responses', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261105201822738-bundle-occurrence-responses', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261105201702355-bundle-occurrence-responses', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261105201702355-bundle-occurrence-responses', "timestamp" = now();

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
