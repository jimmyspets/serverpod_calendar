BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_calendar_cursor" ADD COLUMN "freeBusyExchangeState" json;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_fb_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "ownerKey" text NOT NULL,
    "deliveryId" uuid NOT NULL,
    "generation" bigint NOT NULL,
    "ordinal" bigint NOT NULL,
    "leaseOwner" uuid NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "finishedAt" timestamp without time zone,
    "outcome" text,
    "reasonCode" text,
    "payloadDigest" text NOT NULL,
    "mimeDigest" text
);

-- Indexes
CREATE UNIQUE INDEX "calendar_fb_attempt_ordinal" ON "serverpod_calendar_fb_attempt" USING btree ("deliveryId", "generation", "ordinal");
CREATE INDEX "calendar_fb_attempt_owner" ON "serverpod_calendar_fb_attempt" USING btree ("scopeKey", "ownerKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_fb_command" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "ownerKey" text NOT NULL,
    "commandId" uuid NOT NULL,
    "criteriaDigest" text NOT NULL,
    "method" text NOT NULL,
    "action" text NOT NULL,
    "sourceId" uuid,
    "calendarId" uuid,
    "stamp" timestamp without time zone NOT NULL,
    "timezoneIdentity" text,
    "calculationProfile" bigint,
    "parentSettingsDigest" text,
    "arguments" text,
    "payload" text,
    "payloadDigest" text NOT NULL,
    "byteCount" bigint NOT NULL,
    "generation" bigint NOT NULL,
    "receipt" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "correlatableUntil" timestamp without time zone,
    "terminalAt" timestamp without time zone,
    "scrubbedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "calendar_fb_command_identity" ON "serverpod_calendar_fb_command" USING btree ("scopeKey", "ownerKey", "commandId");
CREATE INDEX "calendar_fb_command_calendar" ON "serverpod_calendar_fb_command" USING btree ("calendarId");
CREATE INDEX "calendar_fb_command_source" ON "serverpod_calendar_fb_command" USING btree ("sourceId");
CREATE INDEX "calendar_fb_command_expiry" ON "serverpod_calendar_fb_command" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_fb_delivery" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "ownerKey" text NOT NULL,
    "commandId" uuid NOT NULL,
    "recipientAddress" text,
    "routeRef" text,
    "authorityRef" text,
    "generation" bigint NOT NULL,
    "state" text NOT NULL,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "nextAttemptAt" timestamp without time zone NOT NULL,
    "leaseOwner" uuid,
    "leaseToken" uuid,
    "leaseFence" bigint NOT NULL DEFAULT 0,
    "leaseUntil" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "terminalAt" timestamp without time zone,
    "providerReceipt" text
);

-- Indexes
CREATE INDEX "calendar_fb_delivery_command" ON "serverpod_calendar_fb_delivery" USING btree ("commandId");
CREATE INDEX "calendar_fb_delivery_due" ON "serverpod_calendar_fb_delivery" USING btree ("terminalAt", "nextAttemptAt", "leaseUntil");
CREATE INDEX "calendar_fb_delivery_owner" ON "serverpod_calendar_fb_delivery" USING btree ("scopeKey", "ownerKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_fb_ingress" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "ownerKey" text NOT NULL,
    "namespace" text NOT NULL,
    "deliveryKey" text NOT NULL,
    "inputDigest" text NOT NULL,
    "sourceId" uuid NOT NULL,
    "result" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_fb_ingress_identity" ON "serverpod_calendar_fb_ingress" USING btree ("scopeKey", "ownerKey", "namespace", "deliveryKey");
CREATE INDEX "calendar_fb_ingress_source" ON "serverpod_calendar_fb_ingress" USING btree ("sourceId");
CREATE INDEX "calendar_fb_ingress_expiry" ON "serverpod_calendar_fb_ingress" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_fb_request_head" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "ownerKey" text NOT NULL,
    "correlationDigest" text NOT NULL,
    "calendarId" uuid,
    "mailboxAddress" text,
    "bindingRef" text,
    "requesterAddress" text,
    "fromUtc" timestamp without time zone,
    "untilUtc" timestamp without time zone,
    "currentSourceId" uuid,
    "sourceRevision" bigint NOT NULL,
    "replyRevision" bigint NOT NULL,
    "lastReplyStamp" timestamp without time zone,
    "latestCommandId" uuid,
    "conflicted" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "purgedAt" timestamp without time zone,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_fb_head_correlation" ON "serverpod_calendar_fb_request_head" USING btree ("scopeKey", "ownerKey", "correlationDigest");
CREATE INDEX "calendar_fb_head_owner" ON "serverpod_calendar_fb_request_head" USING btree ("scopeKey", "ownerKey");
CREATE INDEX "calendar_fb_head_calendar" ON "serverpod_calendar_fb_request_head" USING btree ("calendarId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_fb_source" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "ownerKey" text NOT NULL,
    "method" text NOT NULL,
    "headId" uuid,
    "requestCommandId" uuid,
    "payloadDigest" text NOT NULL,
    "byteCount" bigint NOT NULL,
    "payload" text,
    "header" text,
    "originRef" text,
    "bindingRef" text,
    "mailboxAddress" text,
    "sourceStamp" timestamp without time zone NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "dismissedAt" timestamp without time zone,
    "purgedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "calendar_fb_source_owner" ON "serverpod_calendar_fb_source" USING btree ("scopeKey", "ownerKey");
CREATE INDEX "calendar_fb_source_head" ON "serverpod_calendar_fb_source" USING btree ("headId");
CREATE INDEX "calendar_fb_source_request" ON "serverpod_calendar_fb_source" USING btree ("requestCommandId");
CREATE INDEX "calendar_fb_source_expiry" ON "serverpod_calendar_fb_source" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_calendar_fb_source_ref" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "scopeKey" text NOT NULL,
    "ownerKey" text NOT NULL,
    "commandId" uuid NOT NULL,
    "sourceKey" text NOT NULL,
    "eventId" uuid,
    "availabilityId" uuid,
    "revision" bigint NOT NULL,
    "contentDigest" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_fb_ref_unique" ON "serverpod_calendar_fb_source_ref" USING btree ("commandId", "sourceKey");
CREATE INDEX "calendar_fb_ref_event" ON "serverpod_calendar_fb_source_ref" USING btree ("eventId");
CREATE INDEX "calendar_fb_ref_availability" ON "serverpod_calendar_fb_source_ref" USING btree ("availabilityId");
CREATE INDEX "calendar_fb_ref_owner" ON "serverpod_calendar_fb_source_ref" USING btree ("scopeKey", "ownerKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_fb_attempt"
    ADD CONSTRAINT "serverpod_calendar_fb_attempt_fk_0"
    FOREIGN KEY("deliveryId")
    REFERENCES "serverpod_calendar_fb_delivery"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_fb_command"
    ADD CONSTRAINT "serverpod_calendar_fb_command_fk_0"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_fb_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_fb_command"
    ADD CONSTRAINT "serverpod_calendar_fb_command_fk_1"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_fb_delivery"
    ADD CONSTRAINT "serverpod_calendar_fb_delivery_fk_0"
    FOREIGN KEY("commandId")
    REFERENCES "serverpod_calendar_fb_command"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_fb_ingress"
    ADD CONSTRAINT "serverpod_calendar_fb_ingress_fk_0"
    FOREIGN KEY("sourceId")
    REFERENCES "serverpod_calendar_fb_source"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_fb_request_head"
    ADD CONSTRAINT "serverpod_calendar_fb_request_head_fk_0"
    FOREIGN KEY("calendarId")
    REFERENCES "serverpod_calendar_identity"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_fb_source"
    ADD CONSTRAINT "serverpod_calendar_fb_source_fk_0"
    FOREIGN KEY("headId")
    REFERENCES "serverpod_calendar_fb_request_head"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_fb_source"
    ADD CONSTRAINT "serverpod_calendar_fb_source_fk_1"
    FOREIGN KEY("requestCommandId")
    REFERENCES "serverpod_calendar_fb_command"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_calendar_fb_source_ref"
    ADD CONSTRAINT "serverpod_calendar_fb_source_ref_fk_0"
    FOREIGN KEY("commandId")
    REFERENCES "serverpod_calendar_fb_command"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_fb_source_ref"
    ADD CONSTRAINT "serverpod_calendar_fb_source_ref_fk_1"
    FOREIGN KEY("eventId")
    REFERENCES "serverpod_calendar_event"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_calendar_fb_source_ref"
    ADD CONSTRAINT "serverpod_calendar_fb_source_ref_fk_2"
    FOREIGN KEY("availabilityId")
    REFERENCES "serverpod_calendar_availability"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_calendar
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_calendar', '20261106202116854-freebusy-exchanges', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261106202116854-freebusy-exchanges', "timestamp" = now();

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
