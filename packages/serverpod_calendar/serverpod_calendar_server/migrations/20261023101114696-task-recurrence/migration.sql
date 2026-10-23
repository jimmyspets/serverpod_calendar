BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "taskHistoryTaskId" uuid;
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "taskHistoryOriginalKey" text;
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "taskHistoryAfterRevision" bigint;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_task_data" ADD COLUMN "hasRecordedProgress" boolean;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_task_history" (
    "id" bigserial PRIMARY KEY,
    "taskId" uuid NOT NULL,
    "originalKey" text NOT NULL,
    "originalStart" json NOT NULL,
    "revision" bigint NOT NULL,
    "action" text NOT NULL,
    "before" json NOT NULL,
    "after" json NOT NULL,
    "recordedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_task_history_revision_unique" ON "serverpod_calendar_task_history" USING btree ("taskId", "revision");
CREATE INDEX "calendar_task_history_original_idx" ON "serverpod_calendar_task_history" USING btree ("taskId", "originalKey", "revision");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_task_occurrence" (
    "id" bigserial PRIMARY KEY,
    "taskId" uuid NOT NULL,
    "originalKey" text NOT NULL,
    "originalStart" json NOT NULL,
    "progress" json NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_task_occurrence_identity_unique" ON "serverpod_calendar_task_occurrence" USING btree ("taskId", "originalKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_task_history"
    ADD CONSTRAINT "serverpod_calendar_task_history_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_task_occurrence"
    ADD CONSTRAINT "serverpod_calendar_task_occurrence_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "serverpod_calendar_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261023101114696-task-recurrence', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023101114696-task-recurrence', "timestamp" = now();

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
