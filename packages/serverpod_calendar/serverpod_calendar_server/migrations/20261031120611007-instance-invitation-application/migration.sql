BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation_occurrence_application" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "linkId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "stateJson" text NOT NULL,
    "eventRevision" bigint NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_occurrence_application_link_unique" ON "serverpod_calendar_invitation_occurrence_application" USING btree ("linkId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_occurrence_application"
    ADD CONSTRAINT "serverpod_calendar_invitation_occurrence_application_fk_0"
    FOREIGN KEY("linkId")
    REFERENCES "serverpod_calendar_invitation_link"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261031120611007-instance-invitation-application', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261031120611007-instance-invitation-application', "timestamp" = now();

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
