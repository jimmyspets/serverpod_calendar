BEGIN;

-- Preserve active rows, native identities, content, revisions and audit times.
DROP INDEX "calendar_availability_data_uid_unique";
ALTER TABLE "serverpod_calendar_availability_data"
  ALTER COLUMN "protocolUid" DROP DEFAULT,
  ALTER COLUMN "protocolUid" TYPE text USING "protocolUid"::text,
  ADD COLUMN "calendarId" uuid,
  ADD COLUMN "uidDigest" text;
UPDATE "serverpod_calendar_availability_data" AS data
SET "calendarId" = identity."calendarId",
    "uidDigest" = encode(sha256(convert_to(data."protocolUid", 'UTF8')), 'hex')
FROM "serverpod_calendar_availability" AS identity
WHERE identity.id = data."availabilityId";
ALTER TABLE "serverpod_calendar_availability_data"
  ALTER COLUMN "calendarId" SET NOT NULL,
  ALTER COLUMN "uidDigest" SET NOT NULL;
CREATE INDEX "calendar_availability_data_uid_candidates"
  ON "serverpod_calendar_availability_data" USING btree ("calendarId", "uidDigest");
ALTER TABLE ONLY "serverpod_calendar_availability_data"
  ADD CONSTRAINT "serverpod_calendar_availability_data_fk_1"
  FOREIGN KEY("calendarId") REFERENCES "serverpod_calendar_identity"("id")
  ON DELETE NO ACTION ON UPDATE NO ACTION;
-- Native opening UUIDs remain API identities; add their initial protocol strings.
UPDATE "serverpod_calendar_availability_data" AS data
SET content = jsonb_set(data.content::jsonb, '{openings}', (
  SELECT COALESCE(jsonb_agg(opening.value || jsonb_build_object(
    'protocolUid', opening.value->>'uid') ORDER BY opening.ordinality), '[]'::jsonb)
  FROM jsonb_array_elements(data.content::jsonb->'openings') WITH ORDINALITY AS opening(value, ordinality)
))::json;
DO $opening_identity$
BEGIN
  IF EXISTS (SELECT 1 FROM "serverpod_calendar_availability_data" AS data,
    json_array_elements(data.content->'openings') AS opening
    WHERE opening->>'uid' IS NULL OR opening->>'protocolUid' IS NULL) THEN
    RAISE EXCEPTION 'Persisted opening lacks native identity';
  END IF;
END;
$opening_identity$;

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261022150826628-availability-import-storage', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261022150826628-availability-import-storage', "timestamp" = now();

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
