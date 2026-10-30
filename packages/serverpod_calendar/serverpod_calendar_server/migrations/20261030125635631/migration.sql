BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation_response" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "stateId" uuid NOT NULL,
    "entryId" uuid NOT NULL,
    "commandId" uuid NOT NULL,
    "criteriaDigest" text NOT NULL,
    "request" json NOT NULL,
    "receipt" json NOT NULL,
    "sourceId" uuid NOT NULL,
    "sourceRevision" bigint NOT NULL,
    "sourceDigest" text NOT NULL,
    "sourceSequence" bigint,
    "sourceStamp" timestamp without time zone NOT NULL,
    "recipientAddress" text NOT NULL,
    "organizerAddress" text NOT NULL,
    "authorityRef" text NOT NULL,
    "routeRef" text NOT NULL,
    "generation" bigint NOT NULL,
    "choice" text NOT NULL,
    "stamp" timestamp without time zone NOT NULL,
    "payload" text NOT NULL,
    "payloadDigest" text NOT NULL,
    "byteCount" bigint NOT NULL,
    "state" text NOT NULL DEFAULT 'queued'::text,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "leaseOwner" uuid,
    "leaseToken" uuid,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "leaseUntil" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_response_command_unique" ON "serverpod_calendar_invitation_response" USING btree ("scopeKey", "recipientKey", "commandId");
CREATE INDEX "calendar_invitation_response_due_idx" ON "serverpod_calendar_invitation_response" USING btree ("terminalAt", "nextAttemptAt", "leaseUntil");
CREATE INDEX "calendar_invitation_response_recipient_idx" ON "serverpod_calendar_invitation_response" USING btree ("scopeKey", "recipientKey", "stateId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation_response_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "responseId" uuid NOT NULL,
    "attemptNumber" bigint NOT NULL,
    "leaseToken" uuid NOT NULL,
    "leaseFence" bigint NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "finishedAt" timestamp without time zone,
    "outcome" text NOT NULL,
    "adapterReceipt" text,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_response_attempt_number_unique" ON "serverpod_calendar_invitation_response_attempt" USING btree ("responseId", "attemptNumber");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_invitation_response_state" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "entryId" uuid NOT NULL,
    "recipientAddress" text NOT NULL,
    "revision" bigint NOT NULL,
    "latestResponseId" uuid NOT NULL,
    "lastStamp" timestamp without time zone NOT NULL,
    "choice" text NOT NULL,
    "sourceId" uuid NOT NULL,
    "sourceRevision" bigint NOT NULL,
    "sourceDigest" text NOT NULL,
    "sourceSequence" bigint,
    "sourceStamp" timestamp without time zone NOT NULL,
    "outcome" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_invitation_response_state_unique" ON "serverpod_calendar_invitation_response_state" USING btree ("scopeKey", "recipientKey", "entryId");
CREATE INDEX "calendar_invitation_response_state_scope_idx" ON "serverpod_calendar_invitation_response_state" USING btree ("scopeKey", "recipientKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_0"
    FOREIGN KEY("stateId")
    REFERENCES "serverpod_calendar_invitation_response_state"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_1"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_2"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_invitation_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response_attempt"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_attempt_fk_0"
    FOREIGN KEY("responseId")
    REFERENCES "serverpod_calendar_invitation_response"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response_state"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_state_fk_0"
    FOREIGN KEY("entryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261030125635631', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261030125635631', "timestamp" = now();

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
