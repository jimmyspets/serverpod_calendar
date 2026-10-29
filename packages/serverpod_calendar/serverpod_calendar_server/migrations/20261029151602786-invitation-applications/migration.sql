BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation_application" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "linkId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "invitationId" uuid NOT NULL,
    "sourceId" uuid NOT NULL,
    "digest" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "baselineDigest" text NOT NULL,
    "creationDigest" text NOT NULL,
    "eventRevision" bigint NOT NULL,
    "invitationRevision" bigint NOT NULL,
    "appliedAt" timestamp without time zone NOT NULL,
    "requestDigest" text NOT NULL,
    "resultId" uuid NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_application_link_unique" ON "serverpod_calendar_invitation_application" USING btree ("linkId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_application"
    ADD CONSTRAINT "serverpod_calendar_invitation_application_fk_0"
    FOREIGN KEY("linkId")
    REFERENCES "serverpod_calendar_invitation_link"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261029151602786-invitation-applications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261029151602786-invitation-applications', "timestamp" = now();

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
