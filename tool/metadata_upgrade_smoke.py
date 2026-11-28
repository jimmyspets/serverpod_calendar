"""Exercise generated metadata/identity upgrades on synthetic populated storage."""

import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
SERVER = ROOT / "example/calendar_example/calendar_example_server"
COMPOSE = [
    "docker", "compose", "--env-file", str(ROOT / ".local/compose.env"),
    "-f", str(SERVER / "docker-compose.yaml"), "exec", "-T", "postgres_test",
    "psql", "-U", "postgres", "--set", "ON_ERROR_STOP=1",
]


def sql(database, statement):
    result = subprocess.run(
        [*COMPOSE, "-d", database], input=statement, text=True,
        encoding="utf-8", capture_output=True, cwd=ROOT,
    )
    if result.returncode:
        raise RuntimeError(result.stderr)


def verify_instance_reply_upgrade(database):
    # Only synthetic rows in this process-owned upgrade database.
    sql(database, """
INSERT INTO serverpod_calendar_identity (id,"scopeKey",revision)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','instance-upgrade-test',1);
INSERT INTO serverpod_calendar_event (id,"calendarId",revision)
VALUES ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',3);
INSERT INTO serverpod_calendar_scheduling_meeting
(id,"scopeKey","calendarId","eventId","organizerAddress","authorityRef",revision,generation,"createdAt","updatedAt")
VALUES ('cccccccc-cccc-4ccc-8ccc-cccccccccccc','instance-upgrade-test',
'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
'mailto:organizer@example.invalid','synthetic-upgrade',1,0,'2026-10-28','2026-10-28');
INSERT INTO serverpod_calendar_scheduling_reply_source
(id,"scopeKey","meetingId","attendeeAddress",digest,"normalizedSource",sequence,stamp,
"sourceParticipation","effectiveParticipation",outcome,"publishedSequence","publishedCancelled","receivedAt")
VALUES ('dddddddd-dddd-4ddd-8ddd-dddddddddddd','instance-upgrade-test',
'cccccccc-cccc-4ccc-8ccc-cccccccccccc','mailto:bob@example.invalid',repeat('a',64),
'Synthetic preserved legacy source',0,'2026-10-28','accepted','accepted','applied',0,false,'2026-10-28');
INSERT INTO serverpod_calendar_scheduling_reply_receipt
(id,"scopeKey","meetingId","sourceId","ingressDigest",outcome,"receivedAt")
VALUES ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee','instance-upgrade-test',
'cccccccc-cccc-4ccc-8ccc-cccccccccccc','dddddddd-dddd-4ddd-8ddd-dddddddddddd',repeat('b',64),'applied','2026-10-28');
INSERT INTO serverpod_calendar_scheduling_attendee_response
(id,"scopeKey","meetingId","attendeeAddress",revision,"sourceId",sequence,stamp,
"sourceParticipation","effectiveParticipation","receivedAt")
VALUES ('ffffffff-ffff-4fff-8fff-ffffffffffff','instance-upgrade-test',
'cccccccc-cccc-4ccc-8ccc-cccccccccccc','mailto:bob@example.invalid',4,
'dddddddd-dddd-4ddd-8ddd-dddddddddddd',0,'2026-10-28','accepted','accepted','2026-10-28');
CREATE TABLE instance_source_guard AS SELECT id,to_jsonb(t) AS payload FROM serverpod_calendar_scheduling_reply_source t;
CREATE TABLE instance_response_guard AS SELECT id,to_jsonb(t) AS payload FROM serverpod_calendar_scheduling_attendee_response t;
CREATE TABLE instance_receipt_guard AS SELECT id,to_jsonb(t) AS payload FROM serverpod_calendar_scheduling_reply_receipt t;
""")
    sql(database, (SERVER / "migrations/20261028072139405-instance-replies/migration.sql").read_text(encoding="utf-8"))
    sql(database, """
DO $verify_instance_replies$
BEGIN
 IF EXISTS (SELECT 1 FROM instance_source_guard g LEFT JOIN serverpod_calendar_scheduling_reply_source s USING(id)
  WHERE s.id IS NULL OR to_jsonb(s)-'targetKey'-'originalStart'-'targetBasisKey' IS DISTINCT FROM g.payload
  OR s."targetKey" <> 'master' OR s."targetBasisKey" <> 'master' OR s."originalStart" IS NOT NULL)
 THEN RAISE EXCEPTION 'Instance upgrade changed source/history identity'; END IF;
 IF EXISTS (SELECT 1 FROM instance_response_guard g LEFT JOIN serverpod_calendar_scheduling_attendee_response r USING(id)
  WHERE r.id IS NULL OR to_jsonb(r)-'targetKey' IS DISTINCT FROM g.payload OR r."targetKey" <> 'master')
 THEN RAISE EXCEPTION 'Instance upgrade changed response/history identity'; END IF;
 IF EXISTS (SELECT 1 FROM instance_receipt_guard g LEFT JOIN serverpod_calendar_scheduling_reply_receipt r USING(id)
  WHERE r.id IS NULL OR to_jsonb(r) IS DISTINCT FROM g.payload)
 THEN RAISE EXCEPTION 'Instance upgrade changed stable receipt'; END IF;
 IF (SELECT indexdef FROM pg_indexes WHERE indexname='calendar_attendee_response_address_unique')
  NOT LIKE '%("meetingId", "attendeeAddress", "targetKey")%'
 THEN RAISE EXCEPTION 'Instance target uniqueness index missing'; END IF;
 BEGIN
  INSERT INTO serverpod_calendar_scheduling_attendee_response
  ("scopeKey","meetingId","attendeeAddress",revision,"sourceId",sequence,stamp,"effectiveParticipation","receivedAt")
  VALUES ('instance-upgrade-test','cccccccc-cccc-4ccc-8ccc-cccccccccccc','mailto:bob@example.invalid',1,
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',0,'2026-10-28','accepted','2026-10-28');
  RAISE EXCEPTION 'Upgrade lost master-response uniqueness';
 EXCEPTION WHEN unique_violation THEN NULL;
 END;
END;
$verify_instance_replies$;
DROP TABLE instance_source_guard;
DROP TABLE instance_response_guard;
DROP TABLE instance_receipt_guard;
""")


def verify_invitation_upgrade(database):
    # This process owns the synthetic database; snapshot every existing domain row.
    sql(database, """
CREATE TABLE invitation_upgrade_guard(table_name text, rows jsonb);
DO $snapshot_invitation$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
  AND (tablename LIKE 'serverpod_calendar_%' OR tablename LIKE 'serverpod_notifications_%') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO invitation_upgrade_guard VALUES(item.tablename, contents);
 END LOOP;
END;
$snapshot_invitation$;
""")
    sql(database, (SERVER / "migrations/20261028182538524-invitation-review/migration.sql").read_text(encoding="utf-8"))
    sql(database, """
DO $verify_invitation$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT * FROM invitation_upgrade_guard LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.table_name) INTO contents;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Invitation migration changed %', item.table_name; END IF;
 END LOOP;
 IF (SELECT count(*) FROM serverpod_calendar_invitation)<>0
 OR (SELECT count(*) FROM serverpod_calendar_invitation_source)<>0
 OR (SELECT count(*) FROM serverpod_calendar_invitation_receipt)<>0
 THEN RAISE EXCEPTION 'Invitation migration invented intake state'; END IF;
END;
$verify_invitation$;
DROP TABLE invitation_upgrade_guard;
-- Structural index fixtures only, never adopted or interpreted as source.
INSERT INTO serverpod_calendar_invitation(id,"scopeKey","recipientKey","correlationDigest",uid,organizer,revision,stamp,digest,"createdAt","updatedAt","dismissedAt")
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','invitation-upgrade','recipient',repeat('0',64),repeat('u',4096),'mailto:'||repeat('o',2048),1,now(),repeat('1',64),now(),now(),now());
DO $verify_invitation_key$
BEGIN
 BEGIN
  INSERT INTO serverpod_calendar_invitation(id,"scopeKey","recipientKey","correlationDigest",uid,organizer,revision,stamp,digest,"createdAt","updatedAt","dismissedAt")
  SELECT 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',"scopeKey","recipientKey","correlationDigest",uid,organizer,revision,stamp,digest,"createdAt","updatedAt","dismissedAt" FROM serverpod_calendar_invitation;
  RAISE EXCEPTION 'Missing invitation correlation uniqueness';
 EXCEPTION WHEN unique_violation THEN NULL;
 END;
END;
$verify_invitation_key$;
INSERT INTO serverpod_calendar_invitation_source(id,"entryId","normalizedSource","byteCount",digest,stamp,outcome,"receivedAt","inactiveAt")
VALUES ('cccccccc-cccc-4ccc-8ccc-cccccccccccc','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','structural fixture',18,repeat('2',64),now(),'selected',now(),now());
INSERT INTO serverpod_calendar_invitation_receipt(id,"scopeKey","recipientKey","ingressDigest","sourceId","originDigest",outcome,"entryRevision","receivedAt","expiresAt")
VALUES ('dddddddd-dddd-4ddd-8ddd-dddddddddddd','invitation-upgrade','recipient',repeat('3',64),'cccccccc-cccc-4ccc-8ccc-cccccccccccc',repeat('4',64),'selected',1,now(),now()+interval '30 days');
DO $verify_invitation_receipt_key$
BEGIN
 BEGIN
  INSERT INTO serverpod_calendar_invitation_receipt(id,"scopeKey","recipientKey","ingressDigest","sourceId","originDigest",outcome,"entryRevision","receivedAt","expiresAt")
  SELECT 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',"scopeKey","recipientKey","ingressDigest","sourceId","originDigest",outcome,"entryRevision","receivedAt","expiresAt" FROM serverpod_calendar_invitation_receipt;
  RAISE EXCEPTION 'Missing invitation delivery-key uniqueness';
 EXCEPTION WHEN unique_violation THEN NULL;
 END;
END;
$verify_invitation_receipt_key$;
""")


def verify_invitation_adoption_upgrade(database):
    sql(database, """
CREATE TABLE adoption_upgrade_guard(table_name text, rows jsonb);
DO $snapshot_adoption$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
  AND (tablename LIKE 'serverpod_calendar_%' OR tablename LIKE 'serverpod_notifications_%') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO adoption_upgrade_guard VALUES(item.tablename, contents);
 END LOOP;
END;
$snapshot_adoption$;
""")
    sql(database, (SERVER / "migrations/20261029065023341-invitation-adoption/migration.sql").read_text(encoding="utf-8"))
    sql(database, """
DO $verify_adoption$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT * FROM adoption_upgrade_guard LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.table_name) INTO contents;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Adoption migration changed %', item.table_name; END IF;
 END LOOP;
 IF (SELECT count(*) FROM serverpod_calendar_invitation_link)<>0 THEN RAISE EXCEPTION 'Invented adoption links'; END IF;
 IF (SELECT count(*) FROM pg_indexes WHERE indexname IN ('calendar_invitation_link_correlation_unique','calendar_invitation_link_original_unique','calendar_invitation_link_event_unique') AND indexdef LIKE 'CREATE UNIQUE%')<>3
 THEN RAISE EXCEPTION 'Missing link uniqueness'; END IF;
 IF (SELECT count(*) FROM pg_constraint WHERE conrelid='serverpod_calendar_invitation_link'::regclass AND contype='f' AND confdeltype='a' AND convalidated)<>2
 THEN RAISE EXCEPTION 'Missing restrictive identity references'; END IF;
END;
$verify_adoption$;
-- Structural synthetic references only; historical inbox/source IDs need no rows.
INSERT INTO serverpod_calendar_invitation_link
(id,"scopeKey","recipientKey",uid,organizer,"correlationDigest","invitationId","sourceId","sourceDigest",stamp,"calendarId","eventId","requestDigest","eventRevision","invitationRevision","adoptedAt")
VALUES ('99999999-9999-4999-8999-999999999999','instance-upgrade-test','recipient',repeat('u',4096),'mailto:'||repeat('o',2048),repeat('a',64),
'88888888-8888-4888-8888-888888888888','77777777-7777-4777-8777-777777777777',repeat('b',64),now(),
'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',repeat('c',64),1,2,now());
DO $verify_link_identity$
BEGIN
 BEGIN
  DELETE FROM serverpod_calendar_event WHERE id='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  RAISE EXCEPTION 'Physical identity deletion lost link';
 EXCEPTION WHEN foreign_key_violation THEN NULL;
 END;
END;
$verify_link_identity$;
DROP TABLE adoption_upgrade_guard;
""")


def verify_invitation_application_upgrade(database):
    sql(database, """
CREATE TABLE application_guard AS SELECT id,to_jsonb(t) payload FROM serverpod_calendar_invitation_link t;
""")
    sql(database, (SERVER / "migrations/20261029151703500-invitation-applications/migration.sql").read_text(encoding="utf-8"))
    sql(database, """
DO $verify_applications$
BEGIN
 IF EXISTS (SELECT 1 FROM application_guard g LEFT JOIN serverpod_calendar_invitation_link l USING(id)
   WHERE l.id IS NULL OR to_jsonb(l) IS DISTINCT FROM g.payload)
 THEN RAISE EXCEPTION 'Application upgrade changed creation receipts'; END IF;
 IF (SELECT count(*) FROM serverpod_calendar_invitation_application)<>0
 THEN RAISE EXCEPTION 'Upgrade invented application history'; END IF;
END;
$verify_applications$;
INSERT INTO serverpod_calendar_invitation_application
(id,"scopeKey","recipientKey","linkId",revision,"invitationId","sourceId",digest,stamp,
"baselineDigest","creationDigest","eventRevision","invitationRevision","appliedAt","requestDigest","resultId")
VALUES ('66666666-6666-4666-8666-666666666666','instance-upgrade-test','recipient',
'99999999-9999-4999-8999-999999999999',1,'88888888-8888-4888-8888-888888888888',
'77777777-7777-4777-8777-777777777777',repeat('a',64),now(),repeat('b',64),repeat('c',64),2,2,now(),repeat('d',64),
'55555555-5555-4555-8555-555555555555');
DO $verify_application_constraints$
BEGIN
 IF (SELECT sequence FROM serverpod_calendar_invitation_application LIMIT 1) IS NOT NULL
 THEN RAISE EXCEPTION 'Invented source sequence zero'; END IF;
 BEGIN
  INSERT INTO serverpod_calendar_invitation_application
  SELECT '44444444-4444-4444-8444-444444444444',"scopeKey","recipientKey","linkId",revision,"invitationId","sourceId",digest,sequence,stamp,
  "baselineDigest","creationDigest","eventRevision","invitationRevision","appliedAt","requestDigest","resultId"
  FROM serverpod_calendar_invitation_application;
  RAISE EXCEPTION 'Missing one-checkpoint-per-link uniqueness';
 EXCEPTION WHEN unique_violation THEN NULL;
 END;
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='serverpod_calendar_invitation_application'::regclass
   AND contype='f' AND confdeltype='a' AND convalidated)
 THEN RAISE EXCEPTION 'Missing restrictive checkpoint identity reference'; END IF;
END;
$verify_application_constraints$;
DROP TABLE application_guard;
""")



def verify_invitation_cancellation_upgrade(database):
    sql(database, """
CREATE TABLE cancellation_guard(table_name text, rows jsonb);
DO $snapshot_cancellation$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
  AND tablename LIKE 'serverpod_calendar_%' LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO cancellation_guard VALUES(item.tablename, contents);
 END LOOP;
END;
$snapshot_cancellation$;
""")
    sql(database, (SERVER / "migrations/20261029170510929-cancellation-review/migration.sql").read_text(encoding="utf-8"))
    sql(database, """
DO $verify_cancellation$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT * FROM cancellation_guard LOOP
  IF item.table_name='serverpod_calendar_invitation' THEN
   SELECT COALESCE(jsonb_agg(v ORDER BY v::text), '[]'::jsonb) INTO contents
    FROM (SELECT to_jsonb(t)-'kind' AS v FROM serverpod_calendar_invitation t) s;
  ELSE
   EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.table_name) INTO contents;
  END IF;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Cancellation migration changed %', item.table_name; END IF;
 END LOOP;
 IF EXISTS (SELECT 1 FROM serverpod_calendar_invitation WHERE kind IS DISTINCT FROM 'request')
 THEN RAISE EXCEPTION 'Legacy REQUEST marker misclassified'; END IF;
 UPDATE serverpod_calendar_invitation SET kind='meetingCancellation';
 IF EXISTS (SELECT 1 FROM serverpod_calendar_invitation WHERE kind IS DISTINCT FROM 'meetingCancellation')
 THEN RAISE EXCEPTION 'Cancellation kind not retained'; END IF;
END;
$verify_cancellation$;
DROP TABLE cancellation_guard;
""")



def verify_cancellation_application_upgrade(database):
    sql(database, """
CREATE TABLE cancellation_application_guard AS
 SELECT id,to_jsonb(t) payload FROM serverpod_calendar_invitation_application t;
""")
    sql(database, (SERVER / "migrations/20261029183508485-cancellation-application/migration.sql").read_text(encoding="utf-8"))
    sql(database, """
DO $verify_cancellation_application$
BEGIN
 IF EXISTS (SELECT 1 FROM cancellation_application_guard g
   LEFT JOIN serverpod_calendar_invitation_application a USING(id)
   WHERE a.id IS NULL OR (to_jsonb(a)-'kind') IS DISTINCT FROM g.payload OR a.kind<>'request')
 THEN RAISE EXCEPTION 'Accepted-kind upgrade changed REQUEST state or retry digest'; END IF;
 IF (SELECT count(*) FROM serverpod_calendar_invitation_application) <>
    (SELECT count(*) FROM cancellation_application_guard)
 THEN RAISE EXCEPTION 'Upgrade invented accepted source history'; END IF;
 BEGIN
  UPDATE serverpod_calendar_invitation_application SET kind=NULL;
  RAISE EXCEPTION 'Nullable accepted source kind';
 EXCEPTION WHEN not_null_violation THEN NULL;
 END;
END;
$verify_cancellation_application$;
DROP TABLE cancellation_application_guard;
""")


def verify_invitation_response_upgrade(database):
    sql(database, """
CREATE TABLE response_upgrade_guard(table_name text, rows jsonb);
DO $snapshot_responses$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
  AND (tablename LIKE 'serverpod_calendar_%' OR tablename LIKE 'serverpod_notifications_%') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO response_upgrade_guard VALUES(item.tablename, contents);
 END LOOP;
END;
$snapshot_responses$;
""")
    sql(database, (SERVER / "migrations/20261030125640323/migration.sql").read_text(encoding="utf-8"))
    sql(database, """
DO $verify_responses$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT * FROM response_upgrade_guard LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.table_name) INTO contents;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Response migration changed %', item.table_name; END IF;
 END LOOP;
 IF (SELECT count(*) FROM serverpod_calendar_invitation_response_state)<>0
 OR (SELECT count(*) FROM serverpod_calendar_invitation_response)<>0
 OR (SELECT count(*) FROM serverpod_calendar_invitation_response_attempt)<>0
 THEN RAISE EXCEPTION 'Upgrade invented personal responses or delivery history'; END IF;
END;
$verify_responses$;
DROP TABLE response_upgrade_guard;
""")


def main():
    # Drop only a database this process successfully creates on the test service.
    database = f"calendar_metadata_upgrade_{os.getpid()}"
    assert re.fullmatch(r"calendar_metadata_upgrade_[0-9]+", database)
    sql("postgres", f"CREATE DATABASE {database};")
    try:
        if any(arg in __import__("sys").argv for arg in ["--instance-replies-only", "--invitations-only", "--adoption-only", "--applications-only", "--cancellations-only", "--cancellation-applications-only"]):
            sql(database, (SERVER / "migrations/20261027194429192-attendee-replies/definition.sql").read_text(encoding="utf-8"))
            verify_instance_reply_upgrade(database)
            if any(arg in __import__("sys").argv for arg in ["--invitations-only", "--adoption-only", "--applications-only", "--cancellations-only", "--cancellation-applications-only"]):
                verify_invitation_upgrade(database)
                if any(arg in __import__("sys").argv for arg in ["--adoption-only", "--applications-only", "--cancellations-only", "--cancellation-applications-only"]):
                    verify_invitation_adoption_upgrade(database)
                    if any(arg in __import__("sys").argv for arg in ["--applications-only", "--cancellations-only", "--cancellation-applications-only"]):
                        verify_invitation_application_upgrade(database)
                        if any(arg in __import__("sys").argv for arg in ["--cancellations-only", "--cancellation-applications-only"]):
                            verify_invitation_cancellation_upgrade(database)
                            if "--cancellation-applications-only" in __import__("sys").argv:
                                verify_cancellation_application_upgrade(database)
                                print("PASS: accepted-kind upgrade preserves populated REQUEST checkpoints, exact retry digests and results without invented history.")
                                return
                            print("PASS: populated cancellation upgrade preserves all prior rows and classifies legacy REQUEST markers without invented native state.")
                            return
                        print("PASS: populated application upgrade preserves immutable links, invents no history and enforces one bounded checkpoint per link.")
                        return
                    print("PASS: populated invitation adoption upgrade preserves prior rows, invents no links, retains historical references and enforces identity/uniqueness constraints.")
                    return
                print("PASS: invitation upgrade preserves populated prior domain rows, creates no invitation state and enforces bounded digest correlation/delivery keys.")
                return
            print("PASS: populated master reply source/response/receipt rows preserved, master defaults and target uniqueness verified.")
            return
        sql(database, (SERVER / "migrations/20261020142844886-calendar-crud/definition.sql").read_text(encoding="utf-8"))
        sql(database, """
INSERT INTO serverpod_calendar_identity (id, "scopeKey", revision)
VALUES ('11111111-1111-4111-8111-111111111111', 'metadata-upgrade-test', 7);
INSERT INTO serverpod_calendar_data
("calendarId", "displayName", "availabilityZoneId", "noRuleFallback", "createdAt", "updatedAt")
VALUES ('11111111-1111-4111-8111-111111111111', 'Upgrade fixture', 'Europe/Stockholm', 'free',
        '2026-01-01 00:00:00', '2026-01-02 00:00:00');
INSERT INTO serverpod_calendar_subject
("calendarId", namespace, kind, "externalId", "contributesAvailability")
VALUES ('11111111-1111-4111-8111-111111111111', 'fixture', 'room', 'room-1', true);
INSERT INTO serverpod_calendar_scope ("scopeKey", revision) VALUES ('metadata-upgrade-test', 11);
""")
        sql(database, (SERVER / "migrations/20261020150003755-calendar-metadata/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify$
BEGIN
  IF (SELECT count(*) FROM serverpod_calendar_identity WHERE
      id = '11111111-1111-4111-8111-111111111111' AND "scopeKey" = 'metadata-upgrade-test'
      AND revision = 7 AND "deletedAt" IS NULL) <> 1 THEN
    RAISE EXCEPTION 'Identity/revision changed during upgrade';
  END IF;
  IF (SELECT count(*) FROM serverpod_calendar_data WHERE
      "calendarId" = '11111111-1111-4111-8111-111111111111'
      AND "displayName" = 'Upgrade fixture' AND "availabilityZoneId" = 'Europe/Stockholm'
      AND "noRuleFallback" = 'free' AND "createdAt" = '2026-01-01 00:00:00'
      AND "updatedAt" = '2026-01-02 00:00:00' AND description IS NULL
      AND color IS NULL AND "protocolMetadata" IS NULL) <> 1 THEN
    RAISE EXCEPTION 'Active content changed or new fields gained defaults';
  END IF;
  IF (SELECT count(*) FROM serverpod_calendar_subject WHERE
      "calendarId" = '11111111-1111-4111-8111-111111111111'
      AND namespace = 'fixture' AND kind = 'room' AND "externalId" = 'room-1'
      AND "contributesAvailability") <> 1 THEN
    RAISE EXCEPTION 'Association changed during upgrade';
  END IF;
  IF (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey" = 'metadata-upgrade-test') <> 11 THEN
    RAISE EXCEPTION 'Scope generation changed during upgrade';
  END IF;
END;
$verify$;
""")
        sql(database, """
UPDATE serverpod_calendar_data SET description = 'Native before links', color = '#112233',
"protocolMetadata" = '{"__className__":"serverpod_calendar.CalendarProtocolMetadata","names":[{"__className__":"serverpod_calendar.CalendarTextVariant","value":"Preserved protocol"}],"descriptions":[],"color":"red"}';
INSERT INTO serverpod_calendar_cursor
(token,"scopeKey","principalId","policyRevision","dataRevision","afterId","pageSize","fieldGroups","expiresAt")
VALUES (repeat('a',43),'metadata-upgrade-test','fixture','v2',11,'11111111-1111-4111-8111-111111111111',1,'["metadata"]','2026-01-03');
""")
        sql(database, (SERVER / "migrations/20261021051116035-calendar-links-categories/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $links$
BEGIN
  IF (SELECT count(*) FROM serverpod_calendar_data WHERE description = 'Native before links'
      AND color = '#112233' AND "protocolMetadata"->'names'->0->>'value' = 'Preserved protocol'
      AND "supplementalMetadata" IS NULL AND "displayName" = 'Upgrade fixture'
      AND "updatedAt" = '2026-01-02 00:00:00') <> 1 THEN
    RAISE EXCEPTION 'Prior presentation/protocol content changed during links upgrade';
  END IF;
  IF (SELECT count(*) FROM serverpod_calendar_cursor WHERE "categoryFilter" IS NULL
      AND token = repeat('a',43) AND "dataRevision" = 11 AND "pageSize" = 1) <> 1 THEN
    RAISE EXCEPTION 'Old cursor filter or binding changed';
  END IF;
  IF (SELECT revision FROM serverpod_calendar_identity WHERE id = '11111111-1111-4111-8111-111111111111') <> 7 THEN
    RAISE EXCEPTION 'Identity revision changed';
  END IF;
END;
$links$;
""")
        sql(database, """
UPDATE serverpod_calendar_data SET "updatedAt" = '2026-01-02 03:04:05.987654';
INSERT INTO serverpod_calendar_identity (id, "scopeKey", revision)
VALUES ('22222222-2222-4222-8222-222222222222','metadata-upgrade-test',2),
       ('33333333-3333-4333-8333-333333333333','metadata-upgrade-test',3);
UPDATE serverpod_calendar_identity SET "deletedAt" = '2026-01-03'
WHERE id = '33333333-3333-4333-8333-333333333333';
INSERT INTO serverpod_calendar_data
("calendarId", "displayName", "availabilityZoneId", "noRuleFallback", "createdAt", "updatedAt")
VALUES ('22222222-2222-4222-8222-222222222222','Second active fixture','UTC','free','2026-01-01','2026-01-02 03:04:05.987654');
""")
        sql(database, (SERVER / "migrations/20261021061921307-calendar-protocol-identity/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $identity$
DECLARE first_uid uuid;
BEGIN
  IF (SELECT count(DISTINCT "protocolUid") FROM serverpod_calendar_data) <> 2
     OR EXISTS (SELECT 1 FROM serverpod_calendar_data WHERE "protocolUid" = "calendarId") THEN
    RAISE EXCEPTION 'UID backfill is not distinct from other active/API identities';
  END IF;
  IF (SELECT count(*) FROM serverpod_calendar_data WHERE
      "calendarId" = '11111111-1111-4111-8111-111111111111'
      AND description = 'Native before links' AND color = '#112233'
      AND "protocolMetadata"->'names'->0->>'value' = 'Preserved protocol'
      AND "supplementalMetadata" IS NULL AND "displayName" = 'Upgrade fixture'
      AND "updatedAt" = '2026-01-02 03:04:05.987654') <> 1 THEN
    RAISE EXCEPTION 'Content or precise timestamp changed during identity upgrade';
  END IF;
  IF (SELECT revision FROM serverpod_calendar_identity WHERE id = '11111111-1111-4111-8111-111111111111') <> 7
     OR (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey" = 'metadata-upgrade-test') <> 11
     OR (SELECT count(*) FROM serverpod_calendar_cursor WHERE "categoryFilter" IS NULL AND "dataRevision" = 11) <> 1
     OR (SELECT count(*) FROM serverpod_calendar_data WHERE "calendarId" = '33333333-3333-4333-8333-333333333333') <> 0 THEN
    RAISE EXCEPTION 'Upgrade changed revisions, cursors or deleted payloads';
  END IF;
  SELECT "protocolUid" INTO first_uid FROM serverpod_calendar_data
  WHERE "calendarId" = '11111111-1111-4111-8111-111111111111';
  BEGIN
    UPDATE serverpod_calendar_data SET "protocolUid" = first_uid
    WHERE "calendarId" = '22222222-2222-4222-8222-222222222222';
    RAISE EXCEPTION 'UID unique index is missing';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
END;
$identity$;
""")
        sql(database, (SERVER / "migrations/20261021064805603-native-single-events/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $events$
BEGIN
  IF (SELECT count(*) FROM serverpod_calendar_event) <> 0
     OR (SELECT count(*) FROM serverpod_calendar_event_data) <> 0
     OR (SELECT count(*) FROM serverpod_calendar_data) <> 2
     OR EXISTS (SELECT 1 FROM serverpod_calendar_cursor WHERE "eventCalendarId" IS NOT NULL OR "eventFieldGroups" IS NOT NULL)
     OR (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey" = 'metadata-upgrade-test') <> 11
     OR (SELECT count(*) FROM serverpod_calendar_data WHERE "protocolUid" IS NOT NULL AND "updatedAt" = '2026-01-02 03:04:05.987654') <> 2 THEN
    RAISE EXCEPTION 'Event schema upgrade modified existing payloads, time, scopes or cursors';
  END IF;
END;
$events$;
""")
        sql(database, """
INSERT INTO serverpod_calendar_event (id, "calendarId", revision)
VALUES ('55555555-5555-4555-8555-555555555555', '11111111-1111-4111-8111-111111111111', 9);
INSERT INTO serverpod_calendar_event_data ("eventId", "protocolUid", content, "createdAt", "updatedAt")
VALUES ('55555555-5555-4555-8555-555555555555','66666666-6666-4666-8666-666666666666',
'{"summary":"Before timing overrides","timing":{"kind":"date","start":{"year":2026,"month":3,"day":29}},"status":"confirmed","transparency":"opaque"}',
'2026-01-01 00:00:00','2026-01-02 03:04:05.987654');
""")
        sql(database, (SERVER / "migrations/20261021094608490-event-occurrence-timing/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $occurrences$
BEGIN
  IF (SELECT count(*) FROM serverpod_calendar_event_data WHERE "timingOverrides" IS NULL
      AND content->>'summary' = 'Before timing overrides'
      AND content->'timing'->>'kind' = 'date'
      AND "protocolUid" = '66666666-6666-4666-8666-666666666666'
      AND "updatedAt" = '2026-01-02 03:04:05.987654') <> 1
     OR (SELECT revision FROM serverpod_calendar_event WHERE id = '55555555-5555-4555-8555-555555555555') <> 9
     OR (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey" = 'metadata-upgrade-test') <> 11 THEN
    RAISE EXCEPTION 'Occurrence upgrade changed existing event content/UID/time/revision or added overrides';
  END IF;
END;
$occurrences$;
""")
        sql(database, (SERVER / "migrations/20261021121924598-availability-rules/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $availability$
BEGIN
  IF (SELECT count(*) FROM serverpod_calendar_availability) <> 0
     OR (SELECT count(*) FROM serverpod_calendar_availability_data) <> 0
     OR (SELECT count(*) FROM serverpod_calendar_event_data WHERE
       content->>'summary' = 'Before timing overrides' AND "timingOverrides" IS NULL
       AND "protocolUid" = '66666666-6666-4666-8666-666666666666'
       AND "updatedAt" = '2026-01-02 03:04:05.987654') <> 1
     OR (SELECT revision FROM serverpod_calendar_event WHERE id='55555555-5555-4555-8555-555555555555') <> 9
     OR (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey"='metadata-upgrade-test') <> 11
     OR (SELECT count(*) FROM serverpod_calendar_data WHERE "protocolUid" IS NOT NULL) <> 2 THEN
    RAISE EXCEPTION 'Availability upgrade changed existing calendars/events, identity, revisions or time';
  END IF;
END;
$availability$;
""")
        sql(database, """
INSERT INTO serverpod_calendar_availability (id,"calendarId",revision)
VALUES ('77777777-7777-4777-8777-777777777777','11111111-1111-4111-8111-111111111111',4);
INSERT INTO serverpod_calendar_availability_data ("availabilityId","protocolUid",content,"createdAt","updatedAt")
VALUES ('77777777-7777-4777-8777-777777777777','88888888-8888-4888-8888-888888888888',
'{"summary":"Before opening edits","priority":0,"closedKind":"unavailable","openings":[]}',
'2026-01-01','2026-01-02 03:04:05.987654');
""")
        sql(database,(SERVER / "migrations/20261021144851473-availability-opening-edits/migration.sql").read_text(encoding="utf-8"))
        sql(database,"""
DO $opening$
BEGIN
  IF (SELECT count(*) FROM serverpod_calendar_availability_data WHERE "timingOverrides" IS NULL
      AND content->>'summary'='Before opening edits' AND "protocolUid"='88888888-8888-4888-8888-888888888888'
      AND "updatedAt"='2026-01-02 03:04:05.987654')<>1
     OR (SELECT revision FROM serverpod_calendar_availability WHERE id='77777777-7777-4777-8777-777777777777')<>4
     OR (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey"='metadata-upgrade-test')<>11 THEN
    RAISE EXCEPTION 'Opening edit upgrade changed identity, contents, time or revisions';
  END IF;
END;
$opening$;
""")
        sql(database, (SERVER / "migrations/20261021192957814-availability-protocol-state/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $protocol$
BEGIN
  IF (SELECT count(*) FROM serverpod_calendar_availability_data WHERE "protocolState" IS NULL
      AND "timingOverrides" IS NULL AND content->>'summary'='Before opening edits'
      AND "protocolUid"='88888888-8888-4888-8888-888888888888'
      AND "createdAt"='2026-01-01' AND "updatedAt"='2026-01-02 03:04:05.987654')<>1
     OR (SELECT revision FROM serverpod_calendar_availability WHERE id='77777777-7777-4777-8777-777777777777')<>4
     OR (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey"='metadata-upgrade-test')<>11 THEN
    RAISE EXCEPTION 'Protocol state upgrade changed legacy contents, identity, timestamps or revisions';
  END IF;
END;
$protocol$;
""")
        sql(database, """
UPDATE serverpod_calendar_availability_data SET content = jsonb_set(content::jsonb, '{openings}',
  '[{"uid":"99999999-9999-4999-8999-999999999999","timing":{"kind":"utc","start":{"year":2026,"month":3,"day":29,"hour":9,"minute":0,"second":0,"microsecond":0},"duration":{"weeks":0,"days":0,"hours":1,"minutes":0,"seconds":0,"microsecond":0}},"categories":["Work"],"comments":["Desk"],"textParameters":{"categoryLanguage":"en","comments":[{"language":"sv"}]}}]'::jsonb)::json
WHERE "availabilityId"='77777777-7777-4777-8777-777777777777';
CREATE TABLE availability_before_storage AS SELECT * FROM serverpod_calendar_availability_data;
""")
        sql(database, (SERVER / "migrations/20261022151001963-availability-import-storage/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $storage$
DECLARE item record;
BEGIN
  SELECT * INTO STRICT item FROM serverpod_calendar_availability_data WHERE "availabilityId"='77777777-7777-4777-8777-777777777777';
  IF (SELECT column_default FROM information_schema.columns
      WHERE table_schema='public' AND table_name='serverpod_calendar_availability_data' AND column_name='protocolUid') IS NOT NULL
     OR (SELECT data_type FROM information_schema.columns
      WHERE table_schema='public' AND table_name='serverpod_calendar_availability_data' AND column_name='protocolUid') <> 'text'
     OR EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='calendar_availability_data_uid_unique')
     OR NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='calendar_availability_data_uid_candidates'
       AND indexdef NOT LIKE 'CREATE UNIQUE%') THEN
    RAISE EXCEPTION 'Upgraded protocol UID schema differs from generated target';
  END IF;
  IF item."protocolUid" <> '88888888-8888-4888-8888-888888888888'
     OR item."calendarId" <> '11111111-1111-4111-8111-111111111111'::uuid
     OR item."uidDigest" <> encode(sha256(convert_to(item."protocolUid", 'UTF8')), 'hex')
     OR item.content->'openings'->0->>'protocolUid' <> '99999999-9999-4999-8999-999999999999'
     OR item."protocolState" IS NOT NULL THEN
    RAISE EXCEPTION 'Storage upgrade changed protocol/native identity or fabricated dates';
  END IF;
  IF EXISTS (SELECT 1 FROM availability_before_storage AS old
    JOIN serverpod_calendar_availability_data AS current ON current.id=old.id
    WHERE current."availabilityId" <> old."availabilityId"
      OR current."createdAt" <> old."createdAt" OR current."updatedAt" <> old."updatedAt"
      OR current."timingOverrides"::jsonb IS DISTINCT FROM old."timingOverrides"::jsonb
      OR (current.content::jsonb #- '{openings,0,protocolUid}') IS DISTINCT FROM old.content::jsonb)
     OR (SELECT revision FROM serverpod_calendar_availability WHERE id='77777777-7777-4777-8777-777777777777') <> 4
     OR (SELECT revision FROM serverpod_calendar_scope WHERE "scopeKey"='metadata-upgrade-test') <> 11 THEN
    RAISE EXCEPTION 'Storage upgrade lost native content audit or revision state';
  END IF;
END;
$storage$;
DROP TABLE availability_before_storage;
""")
        sql(database, "CREATE TABLE availability_before_baseline AS SELECT * FROM serverpod_calendar_availability_data;")
        sql(database, (SERVER / "migrations/20261022203640730-availability-replacement/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $baseline$
BEGIN
  IF EXISTS (SELECT 1 FROM serverpod_calendar_availability_data WHERE "importBaseline" IS NOT NULL)
     OR EXISTS (SELECT 1 FROM serverpod_calendar_availability_data current
       JOIN availability_before_baseline old ON current.id=old.id
       WHERE (to_jsonb(current)-'importBaseline') IS DISTINCT FROM to_jsonb(old))
     OR (SELECT is_nullable FROM information_schema.columns WHERE table_schema='public'
       AND table_name='serverpod_calendar_availability_data' AND column_name='importBaseline') <> 'YES' THEN
    RAISE EXCEPTION 'Baseline upgrade invented history or changed existing data';
  END IF;
END;
$baseline$;
DROP TABLE availability_before_baseline;
""")
        sql(database, "CREATE TABLE event_before_storage AS SELECT * FROM serverpod_calendar_event_data;")
        sql(database, (SERVER / "migrations/20261023050029245-event-source-storage/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $event_storage$
BEGIN
 IF EXISTS (SELECT 1 FROM serverpod_calendar_event_data current
   JOIN event_before_storage old ON current.id=old.id
   WHERE (to_jsonb(current)-'calendarId'-'uidDigest'-'protocolState'-'importBaseline')
      IS DISTINCT FROM (to_jsonb(old)-'protocolUid') || jsonb_build_object('protocolUid',old."protocolUid"::text))
 OR EXISTS (SELECT 1 FROM serverpod_calendar_event_data d JOIN serverpod_calendar_event i ON i.id=d."eventId"
   WHERE d."calendarId"<>i."calendarId" OR d."uidDigest"<>encode(sha256(convert_to(d."protocolUid",'UTF8')),'hex')
   OR d."protocolState" IS NOT NULL OR d."importBaseline" IS NOT NULL)
 OR (SELECT count(*) FROM serverpod_calendar_event_data)<>(SELECT count(*) FROM event_before_storage)
 OR (SELECT data_type FROM information_schema.columns WHERE table_schema='public'
   AND table_name='serverpod_calendar_event_data' AND column_name='protocolUid')<>'text'
 OR (SELECT column_default FROM information_schema.columns WHERE table_schema='public'
   AND table_name='serverpod_calendar_event_data' AND column_name='protocolUid') IS NOT NULL
 OR EXISTS (SELECT 1 FROM pg_indexes WHERE indexname='calendar_event_data_uid_unique')
 OR NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname='calendar_event_data_uid_candidates' AND indexdef NOT LIKE 'CREATE UNIQUE%')
 THEN RAISE EXCEPTION 'Event storage upgrade lost data or invented source history'; END IF;
END;
$event_storage$;
DROP TABLE event_before_storage;
""")
        preserved = ["serverpod_calendar_identity", "serverpod_calendar_data", "serverpod_calendar_event", "serverpod_calendar_event_data", "serverpod_calendar_availability_data", "serverpod_calendar_cursor", "serverpod_calendar_scope"]
        for table in preserved:
            sql(database, f"CREATE TABLE {table}_before_tasks AS SELECT * FROM {table};")
        sql(database, (SERVER / "migrations/20261023065425278-native-tasks/migration.sql").read_text(encoding="utf-8"))
        for table in preserved:
            strip = "-'taskCalendarId'-'taskFieldGroups'" if table == "serverpod_calendar_cursor" else ""
            sql(database, f"""
DO $tasks$
BEGIN
 IF (SELECT count(*) FROM {table}) <> (SELECT count(*) FROM {table}_before_tasks)
 OR EXISTS (SELECT 1 FROM {table} current JOIN {table}_before_tasks old ON current.id=old.id
   WHERE (to_jsonb(current){strip}) IS DISTINCT FROM to_jsonb(old))
 THEN RAISE EXCEPTION 'Task upgrade changed existing {table} state'; END IF;
END;
$tasks$;
DROP TABLE {table}_before_tasks;
""")
        sql(database, """
DO $task_schema$
BEGIN
 IF EXISTS (SELECT 1 FROM serverpod_calendar_task) OR EXISTS (SELECT 1 FROM serverpod_calendar_task_data)
 OR EXISTS (SELECT 1 FROM serverpod_calendar_cursor WHERE "taskCalendarId" IS NOT NULL OR "taskFieldGroups" IS NOT NULL)
 OR NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname='calendar_task_data_identity_unique' AND indexdef LIKE 'CREATE UNIQUE%')
 OR NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname='calendar_task_data_uid_candidates' AND indexdef NOT LIKE 'CREATE UNIQUE%')
 THEN RAISE EXCEPTION 'Task upgrade invented tasks/history/cursor bindings or differs from generated indexes'; END IF;
END;
$task_schema$;
""")
        sql(database, """
INSERT INTO serverpod_calendar_task (id, "calendarId", revision)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '11111111-1111-4111-8111-111111111111', 8);
INSERT INTO serverpod_calendar_task_data ("taskId","calendarId","protocolUid","uidDigest","protocolVersion",content,progress,assignees,"createdAt","updatedAt")
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','11111111-1111-4111-8111-111111111111','legacy-task',encode(sha256(convert_to('legacy-task','UTF8')),'hex'),
'{"sequence":2,"stamp":"2026-03-01T00:00:00.000Z"}', '{"summary":"Legacy task","timing":{"kind":"undated"}}',
'{"status":"completed","percentComplete":100,"completedAt":"2026-03-01T00:00:00.000Z"}', '[]', '2026-02-01','2026-03-01');
""")
        task_preserved = [*preserved, "serverpod_calendar_task", "serverpod_calendar_task_data"]
        for table in task_preserved:
            sql(database, f"CREATE TABLE {table}_before_recurrence AS SELECT * FROM {table};")
        sql(database, (SERVER / "migrations/20261023101136436-task-recurrence/migration.sql").read_text(encoding="utf-8"))
        for table in task_preserved:
            strip = "-'taskHistoryTaskId'-'taskHistoryOriginalKey'-'taskHistoryAfterRevision'" if table == "serverpod_calendar_cursor" else "-'hasRecordedProgress'" if table == "serverpod_calendar_task_data" else ""
            sql(database, f"""
DO $task_recurrence$
BEGIN
 IF (SELECT count(*) FROM {table}) <> (SELECT count(*) FROM {table}_before_recurrence)
 OR EXISTS (SELECT 1 FROM {table} current JOIN {table}_before_recurrence old ON current.id=old.id
 WHERE (to_jsonb(current){strip}) IS DISTINCT FROM to_jsonb(old))
 THEN RAISE EXCEPTION 'Recurring task migration changed {table}'; END IF;
END;
$task_recurrence$;
DROP TABLE {table}_before_recurrence;
""")
        sql(database, """
DO $task_history$
BEGIN
 IF EXISTS (SELECT 1 FROM serverpod_calendar_task_occurrence) OR EXISTS (SELECT 1 FROM serverpod_calendar_task_history)
 OR EXISTS (SELECT 1 FROM serverpod_calendar_task_data WHERE "hasRecordedProgress" IS NOT NULL)
 OR EXISTS (SELECT 1 FROM serverpod_calendar_cursor WHERE "taskHistoryTaskId" IS NOT NULL OR "taskHistoryOriginalKey" IS NOT NULL OR "taskHistoryAfterRevision" IS NOT NULL)
 THEN RAISE EXCEPTION 'Recurring task migration invented checkpoint, occurrence history or cursor state'; END IF;
END;
$task_history$;
""")
        source_preserved = [*task_preserved, "serverpod_calendar_task_occurrence", "serverpod_calendar_task_history"]
        for table in source_preserved:
            sql(database, f"CREATE TABLE {table}_before_task_source AS SELECT * FROM {table};")
        sql(database, (SERVER / "migrations/20261023152631227/migration.sql").read_text(encoding="utf-8"))
        for table in source_preserved:
            strip = "-'sourceState'-'importBaseline'" if table == "serverpod_calendar_task_data" else "-'protocolVersion'" if table == "serverpod_calendar_task_occurrence" else ""
            sql(database, f"""
DO $task_source$
BEGIN
 IF (SELECT count(*) FROM {table}) <> (SELECT count(*) FROM {table}_before_task_source)
 OR EXISTS (SELECT 1 FROM {table} current JOIN {table}_before_task_source old ON current.id=old.id
 WHERE (to_jsonb(current){strip}) IS DISTINCT FROM to_jsonb(old))
 THEN RAISE EXCEPTION 'Task source migration changed {table}'; END IF;
END;
$task_source$;
DROP TABLE {table}_before_task_source;
""")
        sql(database, """
DO $task_source_absence$
BEGIN
 IF EXISTS (SELECT 1 FROM serverpod_calendar_task_data WHERE "sourceState" IS NOT NULL OR "importBaseline" IS NOT NULL OR "hasRecordedProgress" IS NOT NULL)
 OR EXISTS (SELECT 1 FROM serverpod_calendar_task_occurrence WHERE "protocolVersion" IS NOT NULL)
 THEN RAISE EXCEPTION 'Task source migration invented source/protocol/history state'; END IF;
END;
$task_source_absence$;
""")
        sql(database, """
INSERT INTO serverpod_calendar_task_occurrence ("taskId", "originalKey", "originalStart", progress)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'synthetic-upgrade-original', '{"kind":"date","start":{"year":2026,"month":3,"day":1}}', '{"status":"completed","percentComplete":100,"completedAt":"2026-03-01T00:00:00Z"}');
""")
        for table in source_preserved:
            sql(database, f"CREATE TABLE {table}_before_task_timing AS SELECT * FROM {table};")
        sql(database, (SERVER / "migrations/20261023170429702-task-occurrence-timing/migration.sql").read_text(encoding="utf-8"))
        for table in source_preserved:
            strip = "-'replacementTiming'" if table == "serverpod_calendar_task_occurrence" else ""
            sql(database, f"""
DO $task_timing$
BEGIN
 IF (SELECT count(*) FROM {table}) <> (SELECT count(*) FROM {table}_before_task_timing)
 OR EXISTS (SELECT 1 FROM {table} current JOIN {table}_before_task_timing old ON current.id=old.id
 WHERE (to_jsonb(current){strip}) IS DISTINCT FROM to_jsonb(old))
 THEN RAISE EXCEPTION 'Task timing migration changed {table}'; END IF;
END;
$task_timing$;
DROP TABLE {table}_before_task_timing;
""")
        for table in source_preserved:
            sql(database, f"CREATE TABLE {table}_before_task_future AS SELECT * FROM {table};")
        sql(database, (SERVER / "migrations/20261023203819827-task-future-timing/migration.sql").read_text(encoding="utf-8"))
        for table in source_preserved:
            strip = "-'futureTiming'" if table == "serverpod_calendar_task_occurrence" else ""
            sql(database, f"""
DO $task_timing$
BEGIN
 IF (SELECT count(*) FROM {table}) <> (SELECT count(*) FROM {table}_before_task_future)
 OR EXISTS (SELECT 1 FROM {table} current JOIN {table}_before_task_future old ON current.id=old.id
 WHERE (to_jsonb(current){strip}) IS DISTINCT FROM to_jsonb(old))
 THEN RAISE EXCEPTION 'Task future migration changed {table}'; END IF;
END;
$task_timing$;
DROP TABLE {table}_before_task_future;
""")
        sql(database, """
DO $task_future_absence$
BEGIN
 IF EXISTS (SELECT 1 FROM serverpod_calendar_task_occurrence WHERE "futureTiming" IS NOT NULL)
 THEN RAISE EXCEPTION 'Task future migration invented range timing'; END IF;
END;
$task_future_absence$;
""")
        for table in source_preserved:
            sql(database, f"CREATE TABLE {table}_before_task_content AS SELECT * FROM {table};")
        sql(database, (SERVER / "migrations/20261023211410837-task-occurrence-content/migration.sql").read_text(encoding="utf-8"))
        for table in source_preserved:
            strip = "-'contentOverrides'" if table == "serverpod_calendar_task_occurrence" else ""
            sql(database, f"""
DO $task_timing$
BEGIN
 IF (SELECT count(*) FROM {table}) <> (SELECT count(*) FROM {table}_before_task_content)
 OR EXISTS (SELECT 1 FROM {table} current JOIN {table}_before_task_content old ON current.id=old.id
 WHERE (to_jsonb(current){strip}) IS DISTINCT FROM to_jsonb(old))
 THEN RAISE EXCEPTION 'Task content migration changed {table}'; END IF;
END;
$task_timing$;
DROP TABLE {table}_before_task_content;
""")
        sql(database, """
DO $task_future_absence$
BEGIN
 IF EXISTS (SELECT 1 FROM serverpod_calendar_task_occurrence WHERE "contentOverrides" IS NOT NULL)
 THEN RAISE EXCEPTION 'Task content migration invented content overrides'; END IF;
END;
$task_future_absence$;
""")
        # This increment adds one empty private table. Every pre-existing row
        # must survive byte-equivalent JSON projection, including source state.
        sql(database, """
CREATE TABLE personal_alarm_upgrade_guard (table_name text PRIMARY KEY, rows jsonb NOT NULL);
DO $snapshot$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
   AND tablename NOT IN ('serverpod_migrations', 'personal_alarm_upgrade_guard') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO personal_alarm_upgrade_guard VALUES (item.tablename, contents);
 END LOOP;
END;
$snapshot$;
""")
        sql(database, (SERVER / "migrations/20261024195955583-personal-alarm-definitions/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify_personal$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT * FROM personal_alarm_upgrade_guard LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.table_name) INTO contents;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Personal alarm migration changed %', item.table_name; END IF;
 END LOOP;
 IF (SELECT count(*) FROM serverpod_calendar_alarm) <> 0 THEN RAISE EXCEPTION 'Invented personal alarms'; END IF;
END;
$verify_personal$;
DROP TABLE personal_alarm_upgrade_guard;
""")
        # Additive worker storage must not arm existing definitions or invent
        # any work/action history, and must preserve every previous row.
        sql(database, """
INSERT INTO serverpod_calendar_alarm
(id, "scopeKey", "calendarId", "parentKind", "parentId", "recipientNamespace", "recipientKey",
 revision, definition, "createdAt", "updatedAt")
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'metadata-upgrade-test',
 '11111111-1111-4111-8111-111111111111', 'event', '55555555-5555-4555-8555-555555555555',
 'fixture', 'recipient', 7, '{"absoluteUtc":"2026-03-29T12:00:00.000Z"}', '2026-01-01', '2026-01-02');
CREATE TABLE alarm_work_upgrade_guard (table_name text PRIMARY KEY, rows jsonb NOT NULL);
DO $snapshot_work$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
   AND tablename NOT IN ('serverpod_migrations', 'alarm_work_upgrade_guard') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO alarm_work_upgrade_guard VALUES (item.tablename, contents);
 END LOOP;
END;
$snapshot_work$;
""")
        sql(database, (SERVER / "migrations/20261025064233961-alarm-work/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify_work$
DECLARE item record; contents jsonb; strip text;
BEGIN
 FOR item IN SELECT * FROM alarm_work_upgrade_guard LOOP
  strip := CASE WHEN item.table_name='serverpod_calendar_alarm' THEN '-''armed''-''generation''' ELSE '' END;
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t)%s AS v FROM %I t) s', strip, item.table_name) INTO contents;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Alarm work migration changed %', item.table_name; END IF;
 END LOOP;
 IF EXISTS (SELECT 1 FROM serverpod_calendar_alarm WHERE armed OR generation<>1)
 OR (SELECT count(*) FROM serverpod_calendar_alarm_plan)<>0
 OR (SELECT count(*) FROM serverpod_calendar_alarm_firing)<>0
 OR (SELECT count(*) FROM serverpod_calendar_alarm_action)<>0
 THEN RAISE EXCEPTION 'Migration armed alarms or invented work/action state'; END IF;
END;
$verify_work$;
DROP TABLE alarm_work_upgrade_guard;
""")
        sql(database, """
INSERT INTO serverpod_calendar_alarm_action
(id, "alarmId", "originalKey", revision, "acknowledgedAt", "snoozeRevision", "createdAt", "updatedAt")
SELECT '33333333-3333-4333-8333-333333333333', id, 'item', 3, '2026-10-25 08:00:00', 2,
 '2026-10-25 07:00:00', '2026-10-25 08:00:00' FROM serverpod_calendar_alarm LIMIT 1;
CREATE TABLE action_upgrade_guard AS SELECT to_jsonb(a) AS content FROM serverpod_calendar_alarm_action a;
""")
        sql(database, (SERVER / "migrations/20261025083029145-alarm-actions/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify_actions$
BEGIN
 IF EXISTS (SELECT 1 FROM serverpod_calendar_alarm_action WHERE "resetAt" IS NOT NULL)
 OR EXISTS (SELECT 1 FROM serverpod_calendar_cursor WHERE "alarmActivityId" IS NOT NULL OR "alarmActivityKind" IS NOT NULL)
 THEN RAISE EXCEPTION 'Action migration invented reset or cursor context'; END IF;
 IF (SELECT jsonb_agg(content ORDER BY content::text) FROM action_upgrade_guard) IS DISTINCT FROM
 (SELECT jsonb_agg(to_jsonb(a)-'resetAt' ORDER BY (to_jsonb(a)-'resetAt')::text) FROM serverpod_calendar_alarm_action a)
 THEN RAISE EXCEPTION 'Action migration changed retained private state'; END IF;
END;
$verify_actions$;
DROP TABLE action_upgrade_guard;
""")
        sql(database, """
CREATE TABLE notification_upgrade_guard (table_name text PRIMARY KEY, rows jsonb NOT NULL);
DO $snapshot_notification$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
   AND tablename NOT IN ('serverpod_migrations', 'notification_upgrade_guard') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO notification_upgrade_guard VALUES (item.tablename, contents);
 END LOOP;
END;
$snapshot_notification$;
""")
        sql(database, (SERVER / "migrations/20261025122511973-live-notifications/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify_notification$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT * FROM notification_upgrade_guard LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.table_name) INTO contents;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Notification migration changed %', item.table_name; END IF;
 END LOOP;
 IF (SELECT count(*) FROM serverpod_notifications_delivery)<>0
 OR (SELECT count(*) FROM serverpod_notifications_scope)<>0
 OR (SELECT count(*) FROM serverpod_notifications_cursor)<>0
 THEN RAISE EXCEPTION 'Notification migration invented deliveries or identities'; END IF;
END;
$verify_notification$;
DROP TABLE notification_upgrade_guard;
""")
        sql(database, """
CREATE TABLE feed_upgrade_guard (table_name text PRIMARY KEY, rows jsonb NOT NULL);
DO $snapshot_feed$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT tablename FROM pg_tables WHERE schemaname='public'
   AND tablename NOT IN ('serverpod_migrations', 'feed_upgrade_guard') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.tablename) INTO contents;
  INSERT INTO feed_upgrade_guard VALUES (item.tablename, contents);
 END LOOP;
END;
$snapshot_feed$;
""")
        sql(database, (SERVER / "migrations/20261025165457443/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify_feed$
DECLARE item record; contents jsonb;
BEGIN
 FOR item IN SELECT * FROM feed_upgrade_guard LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(v ORDER BY v::text), ''[]''::jsonb) FROM (SELECT to_jsonb(t) AS v FROM %I t) s', item.table_name) INTO contents;
  IF contents IS DISTINCT FROM item.rows THEN RAISE EXCEPTION 'Feed migration changed %', item.table_name; END IF;
 END LOOP;
 IF (SELECT count(*) FROM serverpod_calendar_feed_identity)<>0
 OR (SELECT count(*) FROM serverpod_calendar_feed_data)<>0
 OR (SELECT count(*) FROM serverpod_calendar_feed_selection)<>0
 OR (SELECT count(*) FROM serverpod_calendar_feed_credential)<>0
 THEN RAISE EXCEPTION 'Feed migration invented publication or credential state'; END IF;
END;
$verify_feed$;
DROP TABLE feed_upgrade_guard;
""")
        sql(database, "CREATE TABLE scheduling_upgrade_guard AS SELECT id, to_jsonb(t) AS payload FROM serverpod_calendar_event_data t;")
        sql(database, (SERVER / "migrations/20261026092959392/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify_scheduling$
BEGIN
 IF EXISTS (SELECT 1 FROM scheduling_upgrade_guard g LEFT JOIN serverpod_calendar_event_data e USING(id)
   WHERE e.id IS NULL OR to_jsonb(e)-'origin' IS DISTINCT FROM g.payload OR e.origin <> 'unknown')
 THEN RAISE EXCEPTION 'Scheduling migration changed event data or invented provenance'; END IF;
 IF (SELECT count(*) FROM serverpod_calendar_scheduling_meeting) <> 0
 OR (SELECT count(*) FROM serverpod_calendar_scheduling_publication) <> 0
 OR (SELECT count(*) FROM serverpod_calendar_scheduling_delivery) <> 0
 OR (SELECT count(*) FROM serverpod_calendar_scheduling_attempt) <> 0
 THEN RAISE EXCEPTION 'Scheduling migration invented organizer or outbound state'; END IF;
END;
$verify_scheduling$;
DROP TABLE scheduling_upgrade_guard;
""")
        sql(database, "CREATE TABLE reply_upgrade_guard AS SELECT id, to_jsonb(t) AS payload FROM serverpod_calendar_event_data t;")
        sql(database, (SERVER / "migrations/20261027194429192-attendee-replies/migration.sql").read_text(encoding="utf-8"))
        sql(database, """
DO $verify_replies$
BEGIN
 IF EXISTS (SELECT 1 FROM reply_upgrade_guard g LEFT JOIN serverpod_calendar_event_data e USING(id)
   WHERE e.id IS NULL OR to_jsonb(e) IS DISTINCT FROM g.payload)
 THEN RAISE EXCEPTION 'Reply migration changed event data'; END IF;
 IF (SELECT count(*) FROM serverpod_calendar_scheduling_reply_source) <> 0
 OR (SELECT count(*) FROM serverpod_calendar_scheduling_reply_receipt) <> 0
 OR (SELECT count(*) FROM serverpod_calendar_scheduling_attendee_response) <> 0
 THEN RAISE EXCEPTION 'Reply migration invented attendee state'; END IF;
END;
$verify_replies$;
DROP TABLE reply_upgrade_guard;
""")
        verify_instance_reply_upgrade(database)
        verify_invitation_upgrade(database)
        verify_invitation_adoption_upgrade(database)
        verify_invitation_application_upgrade(database)
        verify_invitation_cancellation_upgrade(database)
        verify_cancellation_application_upgrade(database)
        verify_invitation_response_upgrade(database)
        print("PASS: populated schema upgrades preserve prior rows, initialize feed/scheduling/reply tables without invented state, retain unknown legacy provenance, and preserve populated replies/invitations/links/checkpoints through instance, adoption, cancellation and private attendee-response upgrades; no personal response history is invented.")
    finally:
        sql("postgres", f"DROP DATABASE {database} WITH (FORCE);")


if __name__ == "__main__":
    main()
