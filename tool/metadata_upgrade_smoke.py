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


def main():
    # Drop only a database this process successfully creates on the test service.
    database = f"calendar_metadata_upgrade_{os.getpid()}"
    assert re.fullmatch(r"calendar_metadata_upgrade_[0-9]+", database)
    sql("postgres", f"CREATE DATABASE {database};")
    try:
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
        print("PASS: populated schema upgrades preserve identity, revisions, content, associations, protocol UID strings and opening identities and old cursor bindings.")
    finally:
        sql("postgres", f"DROP DATABASE {database} WITH (FORCE);")


if __name__ == "__main__":
    main()
