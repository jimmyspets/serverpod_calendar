# Native event information publication validation

Initial validation: 2026-11-07; resumed verification: 2026-11-13. Approved contract: [ADR 0182](adr/0182-native-event-information-publication.md). Implementation branch: `feat/native-event-information-publication`. The complete scoped feature group passed the local checks below and is prepared as one feature commit. Full exact-head hosted checks remain a separate readiness gate; the PR stays draft.

## Observed checks

- `dart test --concurrency=1 test/integration/information_publication_test.dart test/unit/scheduling_mime_test.dart` from the example server: **63 passed**, including source-alarm preservation, version overflow, actual-event identity binding, corrupt-proof rejection and private-occurrence lifecycle preservation. The final reply regression group passed **79 tests**: all **33** information-publication SDK cases plus **46** existing non-recurring/recurring reply cases. Routing recipients cannot create attendee response/source/receipt state. These use disposable test storage and generated APIs/migrations.
- All **164** existing `test/integration/scheduling_test.dart` cases completed without failures during the directly affected regression run. The initial combined run failed only two obsolete MIME expectations that still rejected PUBLISH; both were updated to the approved method profile and the focused MIME run then passed.
- `python tool/metadata_upgrade_smoke.py`: **passed** all populated upgrades, including comparison of all prior rows across the information-purpose migration. Existing populated scheduling bindings receive only `purpose=invitation`; other fields/receipts/history remain intact. The process-owned upgrade database was removed by the harness.
- `dart run tool/scheduling_work_smoke.dart --information-commands`: **passed** actual host loss before and after cancellation/reopening commit, atomic single-intent recovery and stable cross-process retries.
- End-of-batch suites: core **540 VM / 540 Chrome**, iCalendar **631 VM / 631 Chrome**, calendar module **714 VM / 31 Chrome**, optional feed **13**, Flutter unit **9**, example unit **155**: **all passed**. Commands match the package VM/Chrome/unit portions of `tool/check.ps1`.
- All **12 generated roots** remained byte-stable through `./tool/generate.ps1` with the pinned toolchain.
- `dart run tool/host_smoke.dart --information-only --information --flutter`: **passed** two independent JWT hosts and the connected Flutter initial/no-op/update/cancel/reopen journey, with native private-draft preservation and cross-purpose/privacy guards.
- Module changed-file `dart analyze --fatal-infos`: **passed**. New client/host/worker harness analysis: **passed**. Flutter `flutter analyze --no-pub`: **passed**; the final full workspace fatal analysis also includes the added journeys.
- `dart run tool/scheduling_work_smoke.dart --information`: **passed** the transport/recovery portion before command-loss coverage was added: PUBLISH/cancel/reopen on two independent workers, competing claims, actual holder loss before/after synthetic acceptance, stable delivery IDs and byte-identical MIME/decoded bodies.
- Serverpod MCP `hot_reload` and `tail_runner_logs`: tools are exposed, but no interactive runner/log exists. CLI rebuild and newly launched harness processes provide actual validation; no MCP reload success is claimed.
- `./tool/build-host.ps1`: **passed**, producing the owned example bundle. It was rebuilt only after verifying no owned bundle was running.

## Final checks and hosted readiness

`dart format --output=none --set-exit-if-changed` passed for all **520 handwritten Dart files**, after formatting the changed source/test files. Full workspace `dart analyze --fatal-infos` passed, including the final added journeys and recipient-isolation test. `flutter build web --no-pub` passed, including its Wasm dry run; this does not claim an actual Wasm browser test.

`python tool/check_docs.py` verified repository-relative links and consecutive ADRs. Changed-file, unchanged Apache 2.0 LICENSE, whitespace and local-credential checks passed. The only changed Python file is the existing `tool/metadata_upgrade_smoke.py`; no new ignored Python helper was created.

A resumed SDK attempt failed setup because test storage was stopped; only the dedicated synthetic PostgreSQL/Redis services were restarted, and the complete affected group then passed all 79 tests. Earlier 2026-11-07 runtime results are retained as dated evidence; resumed 2026-11-13 checks are identified above.

The entire `tool/check.ps1` pipeline was **not** rerun end-to-end locally for this batch: the relevant integration suites, complete package VM/Chrome/unit checks, populated migrations, actual process-loss probes, two-host JWT/connected Flutter, generation, formatting, analysis and release build were run explicitly. Other full-repository SDK and host journeys remain part of the configured full hosted run. Inspect the exact feature-head inspection/runtime conclusions in the PR before marking it ready. No prior successful commit establishes success for this head.


All addresses/data/transport are synthetic. No real email, deployment or package publication was attempted. External Apple/Google/Outlook scheduling compatibility remains unverified by these tests.
