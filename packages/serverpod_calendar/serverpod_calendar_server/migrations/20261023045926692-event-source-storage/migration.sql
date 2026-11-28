BEGIN;

-- Preserve active rows while separating protocol identity from native identity.
DROP INDEX "calendar_event_data_uid_unique";
ALTER TABLE "serverpod_calendar_event_data"
    ALTER COLUMN "protocolUid" DROP DEFAULT,
    ALTER COLUMN "protocolUid" TYPE text USING "protocolUid"::text,
    ADD COLUMN "calendarId" uuid,
    ADD COLUMN "uidDigest" text,
    ADD COLUMN "protocolState" json,
    ADD COLUMN "importBaseline" json;
UPDATE "serverpod_calendar_event_data" AS d
SET "calendarId" = i."calendarId",
    "uidDigest" = encode(sha256(convert_to(d."protocolUid", 'UTF8')), 'hex')
FROM "serverpod_calendar_event" AS i
WHERE i.id = d."eventId";
ALTER TABLE "serverpod_calendar_event_data"
    ALTER COLUMN "calendarId" SET NOT NULL,
    ALTER COLUMN "uidDigest" SET NOT NULL;
CREATE INDEX "calendar_event_data_uid_candidates" ON "serverpod_calendar_event_data" USING btree ("calendarId", "uidDigest");

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261023045926692-event-source-storage', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023045926692-event-source-storage', "timestamp" = now();

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
