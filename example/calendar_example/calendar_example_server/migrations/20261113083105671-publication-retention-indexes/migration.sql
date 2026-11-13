BEGIN;

--
-- ACTION ALTER TABLE
--
CREATE INDEX "cal_incoming_publication_link_creation_source_idx" ON "serverpod_calendar_incoming_publication_link" USING btree ("creationSourceId");
CREATE INDEX "cal_incoming_publication_link_accepted_source_idx" ON "serverpod_calendar_incoming_publication_link" USING btree ("acceptedSourceId");
CREATE INDEX "cal_incoming_publication_link_basis_source_idx" ON "serverpod_calendar_incoming_publication_link" USING btree ("basisSourceId");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "cal_incoming_publication_receipt_entry_idx" ON "serverpod_calendar_incoming_publication_receipt" USING btree ("entryId");
CREATE INDEX "cal_incoming_publication_receipt_due_idx" ON "serverpod_calendar_incoming_publication_receipt" USING btree ("expiresAt");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "cal_incoming_publication_source_basis_idx" ON "serverpod_calendar_incoming_publication_source" USING btree ("basisSourceId");
CREATE INDEX "cal_incoming_publication_source_expiry_idx" ON "serverpod_calendar_incoming_publication_source" USING btree ("inactiveAt");

--
-- MIGRATION VERSION FOR calendar_example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('calendar_example', '20261113083105671-publication-retention-indexes', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261113083105671-publication-retention-indexes', "timestamp" = now();

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
    VALUES ('serverpod_calendar', '20261113083045903-publication-retention-indexes', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261113083045903-publication-retention-indexes', "timestamp" = now();

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
