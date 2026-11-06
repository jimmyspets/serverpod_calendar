BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "calendar_inv_response_selection_evidence" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "headId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "evidenceJson" text NOT NULL,
    "digest" text NOT NULL,
    "byteCount" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "retiredAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "inv_response_selection_evidence_unique" ON "calendar_inv_response_selection_evidence" USING btree ("headId", "revision");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "calendar_inv_response_selection_head" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "recipientKey" text NOT NULL,
    "correlationDigest" text NOT NULL,
    "masterEntryId" uuid NOT NULL,
    "revision" bigint NOT NULL,
    "currentEvidenceId" uuid,
    "state" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "inactiveAt" timestamp without time zone,
    "purgedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "inv_response_selection_head_unique" ON "calendar_inv_response_selection_head" USING btree ("scopeKey", "recipientKey", "correlationDigest");
CREATE INDEX "inv_response_selection_head_scope" ON "calendar_inv_response_selection_head" USING btree ("scopeKey", "recipientKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "calendar_inv_response_selection_pin" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "evidenceId" uuid NOT NULL,
    "sourceId" uuid NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "inv_response_selection_pin_unique" ON "calendar_inv_response_selection_pin" USING btree ("evidenceId", "sourceId");
CREATE INDEX "inv_response_selection_pin_source" ON "calendar_inv_response_selection_pin" USING btree ("sourceId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_invitation_response" DROP CONSTRAINT IF EXISTS "serverpod_calendar_invitation_response_fk_2";
ALTER TABLE "serverpod_calendar_invitation_response" ADD COLUMN "selectionEvidenceId" uuid;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "calendar_inv_response_selection_evidence"
    ADD CONSTRAINT "calendar_inv_response_selection_evidence_fk_0"
    FOREIGN KEY("headId")
    REFERENCES "calendar_inv_response_selection_head"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "calendar_inv_response_selection_head"
    ADD CONSTRAINT "calendar_inv_response_selection_head_fk_0"
    FOREIGN KEY("masterEntryId")
    REFERENCES "serverpod_calendar_invitation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "calendar_inv_response_selection_pin"
    ADD CONSTRAINT "calendar_inv_response_selection_pin_fk_0"
    FOREIGN KEY("evidenceId")
    REFERENCES "calendar_inv_response_selection_evidence"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "calendar_inv_response_selection_pin"
    ADD CONSTRAINT "calendar_inv_response_selection_pin_fk_1"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_invitation_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_3"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_invitation_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_invitation_response"
    ADD CONSTRAINT "serverpod_calendar_invitation_response_fk_2"
    FOREIGN KEY("selectionEvidenceId")
    REFERENCES "calendar_inv_response_selection_evidence"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261106101314651-recurring-response-proof', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261106101314651-recurring-response-proof', "timestamp" = now();

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
