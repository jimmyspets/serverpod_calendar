BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_refresh_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "resendId" uuid NOT NULL,
    "attemptNumber" bigint NOT NULL,
    "leaseToken" uuid NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "finishedAt" timestamp without time zone,
    "outcome" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_refresh_attempt_number_unique" ON "serverpod_calendar_refresh_attempt" USING btree ("resendId", "attemptNumber");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_refresh_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "namespace" text NOT NULL,
    "deliveryKey" text NOT NULL,
    "originReference" text NOT NULL,
    "sourceDigest" text NOT NULL,
    "attendeeAddress" text NOT NULL,
    "sourceStamp" timestamp without time zone NOT NULL,
    "comments" json NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "dismissedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "calendar_refresh_request_delivery_unique" ON "serverpod_calendar_refresh_request" USING btree ("scopeKey", "namespace", "deliveryKey");
CREATE INDEX "calendar_refresh_request_review_idx" ON "serverpod_calendar_refresh_request" USING btree ("scopeKey", "meetingId", "id");
CREATE INDEX "calendar_refresh_request_retention_idx" ON "serverpod_calendar_refresh_request" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_refresh_resend" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "meetingId" uuid NOT NULL,
    "requestId" uuid NOT NULL,
    "commandId" uuid NOT NULL,
    "actorId" text NOT NULL,
    "publicationId" uuid NOT NULL,
    "generation" bigint NOT NULL,
    "payloadDigest" text NOT NULL,
    "recipientAddress" text NOT NULL,
    "routeRef" text NOT NULL,
    "state" text NOT NULL DEFAULT 'pending'::text,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "leaseToken" uuid,
    "leaseUntil" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "resultCode" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_refresh_resend_request_unique" ON "serverpod_calendar_refresh_resend" USING btree ("requestId");
CREATE UNIQUE INDEX "calendar_refresh_resend_command_unique" ON "serverpod_calendar_refresh_resend" USING btree ("scopeKey", "commandId");
CREATE INDEX "calendar_refresh_resend_due_idx" ON "serverpod_calendar_refresh_resend" USING btree ("terminalAt", "nextAttemptAt", "leaseUntil");
CREATE INDEX "calendar_refresh_resend_published_idx" ON "serverpod_calendar_refresh_resend" USING btree ("publicationId");
CREATE INDEX "calendar_refresh_resend_scope_idx" ON "serverpod_calendar_refresh_resend" USING btree ("scopeKey", "meetingId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_refresh_attempt"
    ADD CONSTRAINT "serverpod_calendar_refresh_attempt_fk_0"
    FOREIGN KEY("resendId")
    REFERENCES "serverpod_calendar_refresh_resend"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_refresh_request"
    ADD CONSTRAINT "serverpod_calendar_refresh_request_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_refresh_resend"
    ADD CONSTRAINT "serverpod_calendar_refresh_resend_fk_0"
    FOREIGN KEY("meetingId")
    REFERENCES "serverpod_calendar_scheduling_meeting"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_refresh_resend"
    ADD CONSTRAINT "serverpod_calendar_refresh_resend_fk_1"
    FOREIGN KEY("requestId")
    REFERENCES "serverpod_calendar_refresh_request"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_refresh_resend"
    ADD CONSTRAINT "serverpod_calendar_refresh_resend_fk_2"
    FOREIGN KEY("publicationId")
    REFERENCES "serverpod_calendar_scheduling_publication"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261128121233666-authenticated-event-refresh', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261128121233666-authenticated-event-refresh', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261128121110483-authenticated-event-refresh', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261128121110483-authenticated-event-refresh', "timestamp" = now();

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
