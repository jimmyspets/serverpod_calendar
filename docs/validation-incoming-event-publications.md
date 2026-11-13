# Incoming publication validation

ADR 0183 and its separate cancellation source-basis refinement were explicitly approved on 2026-11-13. This record covers synthetic local validation. All listed local checks passed. The full repository pipeline was not repeated locally; full exact-head hosted success remains required before readiness.

## Focused and affected regressions

From `example/calendar_example/calendar_example_server`:

```powershell
dart test --concurrency=1 test/integration/incoming_publications_test.dart test/integration/invitation_test.dart test/integration/invitation_adoption_test.dart test/integration/invitation_application_test.dart test/integration/invitation_cancellation_application_test.dart test/integration/information_publication_test.dart test/unit/imip_ingress_test.dart --reporter expanded
```

Passed **169 tests**, including **33 incoming-publication cases**. Coverage includes private review without booking/participation, origin/purpose denial, independent disclosure, cursor bindings, exact retries, version conflicts, atomic Add/Apply, native UID conflicts, local-series conflicts, source-basis retention, deletion and historical retries, final authorization rollback, independently authorized actual basis IDs, DATE/UTC/named-zone timing, recurrence PERIOD additions and source omissions. The producer-to-consumer case uses actual native outbox PUBLISH/update/CANCEL/reopen submissions and synthetic MIME before applying them through the dedicated receiver.

## Storage and process loss

From the repository root:

```powershell
python tool/metadata_upgrade_smoke.py --incoming-fresh-only
python tool/metadata_upgrade_smoke.py
dart run tool/incoming_publication_work_smoke.dart
```

All passed. The populated migration chain preserves legacy rows, initializes empty incoming tables/null cursor state, adds no guessed source history and preserves populated sources through the source-basis/index migrations. The separate fresh-only check applied the exact latest generated `definition.sql` to a new disposable database, verified the complete incoming table/basis/cursor shape and no invented data. Runtime SDK checks are recorded separately above.

The recovery harness uses two independent compiled Serverpod processes sharing isolated test storage. All ten before/after-commit cases passed for receipt, Add, update, cancellation and reopening. After-commit retries first deny revoked authority, then return the stable retained result when authority is restored; no duplicate native mutation occurs. Fresh ports avoid Windows teardown collisions. The probe compiles once per run and cancels stdout subscriptions during teardown; the final harness exited successfully. Earlier JIT runs exposed those harness issues and are not counted as successful complete runs.

## Broad batch checks

The existing check entry point's package commands were run serially:

| Check | Passed |
| --- | ---: |
| Core VM / Chrome | 540 / 540 |
| iCalendar VM / Chrome | 631 / 631 |
| Calendar module VM / Chrome | 714 / 31 |
| Feed module unit | 13 |
| Flutter unit | 9 |
| Example server unit | 155 |

Final formatting passed for **534 handwritten Dart files**; `dart analyze --fatal-infos` was clean. All **12 generated roots / 616 files** remained stable after regeneration. The final example host build and Flutter release web build passed, including the Wasm dry run. Relative-link, whitespace, unchanged Apache license and changed-file/private-credential checks passed. The Serverpod MCP tools were exposed, but hot-restart reported no running runner; actual CLI-built hosts and browser runs supplied the runtime evidence.

## Host and browser evidence

The final rebuilt-host runs passed actual two-host JWT review/source/Add, competing Apply, separate cancellation-basis preservation, reopening and deletion retries, plus the connected Flutter review/Add/cancel/reopen journey. The focused existing free/busy JWT and connected Flutter journey also passed with the original withdrawn/accepted requirement intact.

```powershell
./tool/build-host.ps1
dart run tool/host_smoke.dart --incoming-publications-only --incoming-publications --flutter
dart run tool/host_smoke.dart --freebusy-only --freebusy --flutter
```

The parent outgoing-publication commit's full hosted runtime failed in the complete free/busy browser withdrawal check; see [its validation follow-up](validation-native-event-information-publication.md#hosted-follow-up-2026-11-13). That failure is not waived. The free/busy browser helper now checks idle/enabled controls before clicking while retaining the original withdrawn/accepted assertion; its focused local rerun passed. The failed parent hosted result remains recorded, and full exact-head hosted success is still required before readiness.

All identities, events, MIME, policy markers and delivery adapters are synthetic. No real email, provider authentication, deployment, package publication or external Apple/Google/Outlook interoperability is established by these tests.
