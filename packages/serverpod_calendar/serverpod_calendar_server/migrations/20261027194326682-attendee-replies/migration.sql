BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_scheduling_attendee_response" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "attendeeAddress" text NOT NULL,
    "revision" bigint NOT NULL,
    "sourceId" uuid NOT NULL,
    "sequence" bigint NOT NULL,
    "stamp" timestamp without time zone NOT NULL,
    "sourceParticipation" text,
    "effectiveParticipation" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_attendee_response_address_unique" ON "serverpod_calendar_scheduling_attendee_response" USING btree ("meetingId", "attendeeAddress");
CREATE INDEX "calendar_attendee_response_source_idx" ON "serverpod_calendar_scheduling_attendee_response" USING btree ("sourceId");
CREATE INDEX "calendar_attendee_response_scope_idx" ON "serverpod_calendar_scheduling_attendee_response" USING btree ("scopeKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_scheduling_reply_receipt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "sourceId" uuid NOT NULL,
    "ingressDigest" text NOT NULL,
    "outcome" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_reply_receipt_key_unique" ON "serverpod_calendar_scheduling_reply_receipt" USING btree ("scopeKey", "meetingId", "ingressDigest");
CREATE INDEX "calendar_reply_receipt_source_idx" ON "serverpod_calendar_scheduling_reply_receipt" USING btree ("sourceId");
CREATE INDEX "calendar_reply_receipt_scope_time_idx" ON "serverpod_calendar_scheduling_reply_receipt" USING btree ("scopeKey", "receivedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_scheduling_reply_source" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "attendeeAddress" text NOT NULL,
    "digest" text NOT NULL,
    "normalizedSource" text NOT NULL,
    "sequence" bigint,
    "stamp" timestamp without time zone NOT NULL,
    "sourceParticipation" text,
    "effectiveParticipation" text NOT NULL,
    "outcome" text NOT NULL,
    "publishedSequence" bigint NOT NULL,
    "publishedCancelled" boolean NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "inactiveAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "calendar_reply_source_message_unique" ON "serverpod_calendar_scheduling_reply_source" USING btree ("meetingId", "attendeeAddress", "digest");
CREATE INDEX "calendar_reply_source_scope_inactive_idx" ON "serverpod_calendar_scheduling_reply_source" USING btree ("scopeKey", "inactiveAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_attendee_response"
    ADD CONSTRAINT "serverpod_calendar_scheduling_attendee_response_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_scheduling_attendee_response"
    ADD CONSTRAINT "serverpod_calendar_scheduling_attendee_response_fk_1"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_scheduling_reply_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_reply_receipt"
    ADD CONSTRAINT "serverpod_calendar_scheduling_reply_receipt_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_scheduling_reply_receipt"
    ADD CONSTRAINT "serverpod_calendar_scheduling_reply_receipt_fk_1"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_scheduling_reply_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_scheduling_reply_source"
    ADD CONSTRAINT "serverpod_calendar_scheduling_reply_source_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261027194326682-attendee-replies', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261027194326682-attendee-replies', "timestamp" = now();

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
