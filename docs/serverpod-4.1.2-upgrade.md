# Serverpod 4.1.2 dependency alignment

This record covers the initial upgrade of the pinned CLI, runtime, client,
Flutter integration, authentication and test packages from Serverpod 4.1.0
to 4.1.2 with Flutter 3.47.7 and Dart 3.13.5. See the
[current upgrade record](serverpod-4.1-upgrade.md#serverpod-412). The [upstream changelog](https://pub.dev/packages/serverpod/changelog)
describes the 4.1.1 and 4.1.2 changes. The [4.1.0 upgrade record](serverpod-4.1-upgrade.md)
retains its historical validation and migration evidence.

`flutter pub get` resolved the 4.1.2 packages and updated the workspace
lockfile. The 4.1.2 CLI regenerated the four modules; workspace analysis
and the calendar module's 795 VM and 31 Chrome unit tests passed. Core (540)
and iCalendar (642) tests passed in both VM and Chrome. Nine Flutter example unit tests and
seven focused scheduling integration tests passed on an isolated
synthetic database. The example host, calendar
and notification module migration checks reported no changes. The feed
module's older imported calendar snapshot produced a unique-index warning.
An inspection migration succeeded from that older snapshot but failed on a
current host database because calendar tables already existed; the generated
inspection migration was discarded. The example host started on a fresh
synthetic database with 4.1.2. A repository-wide `tool/check.ps1` run was
stopped during analysis after review identified a scheduling work-budget
correction. A subsequent full run passed its unit suites but failed at database
setup because the existing synthetic Compose volume used different credentials.
A separate synthetic Compose run passed its database, worker and two-host
checks, then failed the feed smoke test: a 304 response reported an incorrect
representation length of zero for a nonempty representation. A local raw
`dart:io` probe reproduced the zero-length header when the new Relic adapter
closes a 304 without sending a body; an empty stream before close avoids it,
but the resolved Relic adapter consumes rather than writes that stream and
suppresses application-supplied framing on 304.
The feed smoke test rejected the incorrect header in this validation run.
The hosted check for commit `4d4b735` also failed at this same feed smoke
assertion: its 304 carried `Content-Length: 0` for a 692-byte representation.
The inspection job passed, and the runtime job reached the feed check after
its earlier database and two-host checks passed. See
[hosted run 43927075625](https://github.com/jimmyspets/serverpod_calendar/actions/runs/43927075625).
Existing-database upgrades, feed snapshot reconciliation and a successful
full hosted check remain outstanding.

The maintainer initially held the upgrade in draft. The later approval for
the version-specific test exception is recorded in
[calendar issue #209](https://github.com/jimmyspets/serverpod_calendar/issues/209).
