BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "calendar_attendee_response_address_unique";
ALTER TABLE "serverpod_calendar_scheduling_attendee_response" ADD COLUMN "targetKey" text NOT NULL DEFAULT 'master'::text;
CREATE UNIQUE INDEX "calendar_attendee_response_address_unique" ON "serverpod_calendar_scheduling_attendee_response" USING btree ("meetingId", "attendeeAddress", "targetKey");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_scheduling_reply_source" ADD COLUMN "targetKey" text NOT NULL DEFAULT 'master'::text;
ALTER TABLE "serverpod_calendar_scheduling_reply_source" ADD COLUMN "originalStart" json;
ALTER TABLE "serverpod_calendar_scheduling_reply_source" ADD COLUMN "targetBasisKey" text NOT NULL DEFAULT 'master'::text;

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261028072122700-instance-replies', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261028072122700-instance-replies', "timestamp" = now();

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
    VALUES ('serverpod_notifications', '20261025122205313-live-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025122205313-live-notifications', "timestamp" = now();


COMMIT;
