"""Exercise the generated nullable-column upgrade on synthetic populated storage."""

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
        print("PASS: populated schema upgrades preserve identity, revisions, content, associations and old cursor bindings.")
    finally:
        sql("postgres", f"DROP DATABASE {database} WITH (FORCE);")


if __name__ == "__main__":
    main()
