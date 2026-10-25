BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_alarm" ADD COLUMN "armed" boolean NOT NULL DEFAULT false;
ALTER TABLE "serverpod_calendar_alarm" ADD COLUMN "generation" bigint NOT NULL DEFAULT 1;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_alarm_action" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "alarmId" uuid NOT NULL,
    "originalKey" text NOT NULL,
    "revision" bigint NOT NULL,
    "acknowledgedAt" timestamp without time zone,
    "dismissedAt" timestamp without time zone,
    "pendingSnoozeAt" timestamp without time zone,
    "snoozeRevision" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_alarm_action_identity_unique" ON "serverpod_calendar_alarm_action" USING btree ("alarmId", "originalKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_alarm_firing" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "alarmId" uuid NOT NULL,
    "generation" bigint NOT NULL,
    "originalKey" text NOT NULL,
    "kind" text NOT NULL,
    "repeatOrdinal" bigint NOT NULL,
    "snoozeRevision" bigint NOT NULL DEFAULT 0,
    "dueAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "state" text NOT NULL DEFAULT 'pending'::text,
    "reason" text,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "acceptedAt" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "leaseOwner" uuid,
    "leaseUntil" timestamp without time zone,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_alarm_firing_identity_unique" ON "serverpod_calendar_alarm_firing" USING btree ("alarmId", "generation", "originalKey", "kind", "repeatOrdinal", "snoozeRevision");
CREATE INDEX "calendar_alarm_firing_due_idx" ON "serverpod_calendar_alarm_firing" USING btree ("state", "nextAttemptAt", "leaseUntil");
CREATE INDEX "calendar_alarm_firing_terminal_idx" ON "serverpod_calendar_alarm_firing" USING btree ("terminalAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_alarm_plan" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "alarmId" uuid NOT NULL,
    "scopeKey" text NOT NULL,
    "generation" bigint NOT NULL,
    "timingDigest" text,
    "windowStart" timestamp without time zone,
    "windowEnd" timestamp without time zone,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "reason" text,
    "dirty" boolean NOT NULL DEFAULT true,
    "nextScanAt" timestamp without time zone NOT NULL,
    "lastCompletedAt" timestamp without time zone,
    "leaseOwner" uuid,
    "leaseUntil" timestamp without time zone,
    "leaseFence" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "calendar_alarm_plan_alarm_unique" ON "serverpod_calendar_alarm_plan" USING btree ("alarmId");
CREATE INDEX "calendar_alarm_plan_due_idx" ON "serverpod_calendar_alarm_plan" USING btree ("nextScanAt", "leaseUntil");
CREATE INDEX "calendar_alarm_plan_scope_idx" ON "serverpod_calendar_alarm_plan" USING btree ("scopeKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_alarm_action"
    ADD CONSTRAINT "serverpod_calendar_alarm_action_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_alarm_firing"
    ADD CONSTRAINT "serverpod_calendar_alarm_firing_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_alarm_plan"
    ADD CONSTRAINT "serverpod_calendar_alarm_plan_fk_0"
    FOREIGN KEY("alarmId")
    REFERENCES "serverpod_calendar_alarm"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261025064211248-alarm-work', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025064211248-alarm-work', "timestamp" = now();

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
