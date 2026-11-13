# Information-publication occurrence validation

ADR 0184 is explicitly approved. This records the local grouped implementation checks on 2026-11-13; full exact-head hosted readiness remains separate. No real email, package publication or deployment was performed.

## Focused and database evidence

- `dart test test/icalendar_publish_projection_test.dart test/icalendar_scheduling_projection_test.dart test/icalendar_projection_budget_test.dart --reporter expanded` in the iCalendar package: **32 passed** during development.
- Serial information master/occurrence SDK suites: **51 passed** after shared-budget integration. An earlier parallel attempt collided on the shared test port; it was rerun with `--concurrency=1`.
- Final `dart test --concurrency=1 test/integration/information_occurrence_publication_test.dart --reporter expanded`: **26 passed**, including DATE/UTC/zones, single/future versions, retained resets and empty-text clearing, legacy v1 upgrade/retries, corruption/capacity, complete-message final denial and incoming master-only rejection.
- Final `dart test --concurrency=1 test/integration/calendar_test.dart --name export --reporter expanded`: **68 passed**, covering event, task, availability and free/busy export regressions.
- The broader selected SDK run executed **253 passing cases** across occurrence (then 23 cases), master information (33), incoming publication (33) and scheduling (164). Its overall command failed on an additional nonexistent `event_export_test.dart` path, not a test assertion. The corrected final selection above ran the actual export cases and latest occurrence tests successfully. This selection error is not reported as a passing command.

Final focused output: `.local/184-final-sdk.log`; earlier focused output: `.local/184-focused-regressions.log`.

## Broader local checks

The repository's batch-check commands passed complete package suites:

| Suite | Result |
| --- | --- |
| Core `dart test`, then `dart test --platform chrome` | 540 VM / 540 Chrome |
| iCalendar same commands | 642 VM / 642 Chrome |
| Calendar server `dart test test/unit`, then Chrome unit tests | 714 VM / 31 Chrome |
| Feed server `dart test test/unit` | 13 |
| Example Flutter `flutter test --no-pub test` | 9 |
| Example server `dart test test/unit` | 155 |

`./tool/generate.ps1` used the pinned CLI; all **12 generated roots remained unchanged**. Formatting checked **537 authored Dart files** with no changes, and `dart analyze --fatal-infos` passed. `./tool/build-host.ps1` built the final stopped owned host bundle. These results are in `.local/184-generation-static-build.log`. No SQL/model-source change or new migration is introduced by this group.

## Real hosts, recovery and browser

`dart run tool/scheduling_work_smoke.dart --information-occurrences` passed all ten actual loss cases: cancellation/reopening before/after commit and PUBLISH/CANCEL/reopened PUBLISH before/after synthetic acceptance, plus competing claims. Single/future exceptions are published and reset before these tests; the complete retained packet is checked. Two independent processes share storage and recover through database leases. Calendar and MIME bytes and stable retry IDs stayed identical (`.local/184-worker-recovery.log`). The new mode compiles one owned probe instead of recompiling it after every deliberate loss.

The final `dart run tool/host_smoke.dart --information-only --information --flutter` passed both real JWT hosts and the connected Flutter journey, including single/future exception publication, retained resets, private-draft lifecycle and purpose/privacy guards (`.local/184-jwt-flutter.log`). `flutter build web --no-pub` also passed with a successful Wasm dry run (`.local/184-release-web.log`).

Serverpod MCP tools are exposed, but hot reload reported that its runner was not running. Actual runtime evidence uses the pinned CLI and compiled hosts; tool exposure is not treated as a working runner connection.

## Scope and hosted status

`python tool/check_docs.py` passed 3,993 relative links and consecutive ADR numbering. Changed-file checks found no local private configuration values in deliverables; the Apache LICENSE is unchanged. The approved group is retained as one feature commit; no intermediate feature-code check-ins were made.

Baseline PR #198 run 43449216068 failed on Unix graceful shutdown of a deliberately suspended transaction. Repair 98159c2 uses SIGKILL for actual process-loss testing; local Windows recovery passed. Repair run 43489862190 passed the Unix process-loss checks, then failed the complete live-notification check; it is not a passing full run. Feature run 43496258214 passed the new occurrence SDK/worker checks but failed the older range harness because an accidental replacement read a revision field absent from that fixture. This does not establish Linux/full hosted success. The full repository sequence and exact feature-head hosted result are still required before PR readiness. External-client compatibility and real mail remain separate release gates.


## Hosted follow-up repair

Two confirmed failures are addressed as one validation-repair group before ADR 0185 runtime work. Restore the legacy range fixture's explicit revisions/counts while keeping information fixtures independent. Allow the existing owned compiled probe for focused range verification. The notification probe now follows bounded recovery continuations and reports content-free durable/hint state rather than searching only page one.

The focused notification reproduction found durable recovery present but no Redis hint, with notification dispatch attempts still zero. The example's serial maintenance chain could prevent notification dispatch after an earlier phase failed. Give all independent module phases their wake-up, run notification dispatch directly after alarm handoff, and preserve the first exception/stack for framework diagnostics. Two focused unit tests verify continuation through synchronous/asynchronous failures and ordered completion; real two-host notification checks passed both normal and actual producer-loss recovery, fresh text, reconnect, blocking and acknowledgement withdrawal.

The first attempt at a new notification-only selector still ran unrelated feature probes and hit its shorter client deadline; the selector was corrected to enter before those probes and rerun. These failed diagnostic attempts are not counted as passes. Static fatal-info checks passed. The focused range group passed all eight actual command/acceptance-loss cases plus competing workers with stable identities/calendar/MIME bytes. The full `dart run tool/host_smoke.dart` client sequence also passed, including all current domain/feed/scheduling probes, matching Redis hints, JWT refresh/logout and actual producer-loss recovery (`.local/ci-repair-full-clients.log`). The example unit suite passed 157 cases and notification SDK regressions passed 18 (`.local/ci-repair-example-regressions.log`); exact repair-head hosted verification remains required before readiness.
