BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation_link" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "uid" text NOT NULL,
    "organizer" text NOT NULL,
    "correlationDigest" text NOT NULL,
    "invitationId" uuid NOT NULL,
    "sourceId" uuid NOT NULL,
    "sourceDigest" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "calendarId" uuid NOT NULL,
    "eventId" uuid NOT NULL,
    "requestDigest" text NOT NULL,
    "eventRevision" bigint NOT NULL,
    "invitationRevision" bigint NOT NULL,
    "adoptedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_link_correlation_unique" ON "serverpod_calendar_invitation_link" USING btree ("scopeKey", "recipientKey", "correlationDigest");
CREATE UNIQUE INDEX "calendar_invitation_link_original_unique" ON "serverpod_calendar_invitation_link" USING btree ("scopeKey", "recipientKey", "invitationId");
CREATE UNIQUE INDEX "calendar_invitation_link_event_unique" ON "serverpod_calendar_invitation_link" USING btree ("eventId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_link"
    ADD CONSTRAINT "serverpod_calendar_invitation_link_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_invitation_link"
    ADD CONSTRAINT "serverpod_calendar_invitation_link_fk_1"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261029065003647-invitation-adoption', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261029065003647-invitation-adoption', "timestamp" = now();

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
