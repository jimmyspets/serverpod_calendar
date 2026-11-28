BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_notifications_cursor" (
    "id" bigserial PRIMARY KEY,
    "token" text NOT NULL,
    "scopeKey" text NOT NULL,
    "principalId" text NOT NULL,
    "policyRevision" text NOT NULL,
    "recipientNamespace" text NOT NULL,
    "recipientKey" text NOT NULL,
    "afterId" uuid NOT NULL,
    "pageSize" bigint NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_cursor_token_unique" ON "serverpod_notifications_cursor" USING btree ("token");
CREATE INDEX "notification_cursor_expiry_idx" ON "serverpod_notifications_cursor" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_notifications_delivery" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientNamespace" text NOT NULL,
    "recipientKey" text NOT NULL,
    "sourceNamespace" text NOT NULL,
    "sourceVersion" bigint NOT NULL,
    "sourceRequestId" text NOT NULL,
    "requestDigest" text NOT NULL,
    "sourceReference" text NOT NULL,
    "dueAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "state" text NOT NULL DEFAULT 'queued'::text,
    "reason" text,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "leaseOwner" uuid,
    "leaseUntil" timestamp without time zone,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "publishedAt" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_request_unique" ON "serverpod_notifications_delivery" USING btree ("scopeKey", "sourceNamespace", "sourceRequestId");
CREATE INDEX "notification_due_idx" ON "serverpod_notifications_delivery" USING btree ("state", "nextAttemptAt", "leaseUntil");
CREATE INDEX "notification_recipient_idx" ON "serverpod_notifications_delivery" USING btree ("scopeKey", "recipientNamespace", "recipientKey", "expiresAt", "id");
CREATE INDEX "notification_terminal_idx" ON "serverpod_notifications_delivery" USING btree ("terminalAt", "expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_notifications_scope" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_scope_key_unique" ON "serverpod_notifications_scope" USING btree ("scopeKey");


--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261025122511973-live-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025122511973-live-notifications', "timestamp" = now();

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
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261025082949995-alarm-actions', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025082949995-alarm-actions', "timestamp" = now();

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
