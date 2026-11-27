# Initial scaffold validation

Date: 2026-10-19. Status: **initial workspace/authentication milestone passed locally**. This is evidence for package/auth wiring only. Calendar domain features, notification delivery, protocol compatibility, full multi-instance worker recovery and CI remain unimplemented/unverified.

## Environment

Windows x64, Flutter 3.47.7 stable, Dart 3.13.5 and Serverpod CLI/runtime/auth/client/test 4.0.4. Docker client/engine 29.8.2, Compose v5.6.0, Chrome 155.0.8059.82 and ChromeDriver 155.0.8059.84 (same browser build family). Exact database/cache image digests are in toolchain.json and Compose. All test identities/data are synthetic; no real email/push is sent.

The pub.dev package metadata reported 4.0.4 as the latest stable Serverpod family when checked. `git ls-remote https://github.com/flutter/flutter.git refs/heads/stable refs/tags/3.47.7` returned the installed revision `abaf9c523780a608bd46686fd5e53740a07077f8` for both references. Resolution and execution below establish the compatibility tested here, rather than relying on installed-version inspection alone.

## Commands actually run

Commands are from the repository root unless a working directory is stated.

| Command/check | Result |
| --- | --- |
| `flutter --version`, `serverpod version`, `docker version`, `docker compose version` | Tools available; Docker engine reachable with local execution access |
| `serverpod --no-analytics create --template module --no-interactive --ide none serverpod_calendar` and equivalent notification module command, from packages/ | Official 4.0.4 module templates generated; then connected into the root workspace |
| `serverpod --no-analytics create --template fullstack --database --redis --auth --webapp --no-website --no-interactive --ide none calendar_example`, from example/ | Official host/app template generated; unused platform/cloud/deployment defaults removed from the final scaffold |
| `flutter pub get --enforce-lockfile` | Nine workspace packages resolve with the committed lockfile |
| `dart run tool/setup.dart` | Local secrets created; subsequent runs retain existing secret values and initialize missing local JWT configuration |
| `pwsh -NoProfile -File tool/check.ps1` | **Passed completely**, including every step below |
| Generation via `tool/generate.ps1` | All three server/client pairs regenerated; protocol/test-tool file sets and SHA-256 hashes unchanged |
| Formatting check on authored Dart sources | 19 files checked; zero changes required. Generator-owned code is checked by regeneration, not manually reformatted |
| `dart analyze --fatal-infos` | No issues found |
| `flutter test --no-pub test/sign_in_test.dart`, from example Flutter package | Passed: empty form validates required input and does not expose the authenticated connection UI |
| `tool/reset-test.ps1` | Only dedicated Compose test database dropped/recreated; fresh auth/framework migrations applied by the first test host |
| Host bundle via `dart build cli --target bin/main.dart --output ...`, from example server | Native bundle built successfully; both test processes use the same build |
| `dart run tool/host_smoke.dart --flutter` | Both independent hosts ready; actual generated-client JWT lifecycle and browser checks passed; owned test processes cleaned up |
| `flutter build web --no-pub`, from example Flutter package | Release Web build passed; compiler's WASM dry run also passed, without a separate WASM runtime compatibility claim |
| `pwsh -NoProfile -File tool/start-server.ps1` | Development services healthy, development migrations applied and synthetic accounts seeded |
| `dart run tool/client_smoke.dart --development` | Normal generated-client auth/module/sign-out smoke passed against the documented development host |
| `pwsh -NoProfile -File tool/start-flutter.ps1` | Passed: Chrome debug service connected and app started on http://localhost:18083 |

After the maintainer selected JWT, `pwsh -NoProfile -File tool/check.ps1` was rerun completely and passed with the regenerated refresh endpoint/client. The development host was restored from the validated bundle using `main.exe --mode=development --server-id=development --apply-migrations` with local seeding enabled; `dart run tool/client_smoke.dart --development` also passed with JWT.

The two-host test uses distinct processes/server IDs and ports 18180/18280, sharing only dedicated test PostgreSQL/Redis storage. It verifies anonymous host/module rejection, ordinary email/password login, the same caller identity through host/calendar/notification generated clients on both instances, and successful JWT refresh/rotation on B, refreshed identity on both hosts, local credential clearing on logout from A, revoked-refresh rejection on B and continued acceptance of a copied unexpired access JWT on B. Sequential idempotent seeding on both hosts avoids duplicate account creation. It does not test domain edits, feed revocation, competing workers, crashes or every NFR-14 scenario yet.

The Flutter WebDriver integration test drives the actual example UI through sign-in, connection check across the host and both modules, visible result and sign-out using the real host APIs. It uses the Flutter SDK integration_test driver and a matching local ChromeDriver. No mock backend replaces the example module/client/migrations.

## Implementation observations and choices

The initial template JWT configuration kept an access token usable on another host after refresh-token sign-out. This is [Serverpod's documented JWT behavior](https://docs.serverpod.dev/concepts/authentication/token-managers/managing-tokens): existing access tokens remain valid until expiry. Immediate rejection was an added test assumption, not a maintainer-selected requirement or a JWT defect. The earlier database-backed session implementation is superseded by the maintainer's explicit JWT selection in [ADR 0021](adr/0021-initial-workspace-scaffold.md). The revised smoke checks refresh/rotation and revocation of refresh credentials, local sign-out and acceptance of a copied unexpired access JWT; it does not wait for the ten-minute access-token expiry or exercise automatic refresh at expiry.

Starting two Windows `dart run` hosts collided when rebuilding a loaded native Argon2 DLL; the final harness builds once and runs two bundle processes. The deprecated Chrome widget-test backend stalled before test execution; the final browser test uses Flutter's documented integration_test/WebDriver runner and passed.

The template emitted a macOS entitlement-update failure during creation on Windows. Native target folders were removed for the selected Web-only initial scaffold; the final Web builds/tests passed. Native target generation and mobile delivery remain later/external work. SDK-generated Windows CPU/memory metric warnings do not provide performance evidence.

## Local MCP repair verification

The initial session had no Serverpod MCP registration, and the compiled host did not run the development bridge. Project-local ignored `.codex/config.toml` now registers the Serverpod bridge with an explicit example-server directory and companion Dart MCP. Global configuration and credentials were unchanged.

Commands/checks actually run on 2026-10-19:

- `codex mcp list --json`: both `serverpod` and `dart_mcp` enabled with the intended local commands and sixty-second startup timeouts.
- `pwsh -NoProfile -File tool/start-server.ps1 -Interactive`: passed setup/tool checks, retained local Compose storage, started the watch runner and its MCP socket, applied no new migrations and seeded synthetic accounts idempotently.
- Local Python JSON-RPC probes launched the exact configured STDIO commands, performed `initialize`, `notifications/initialized` and `tools/list`. Serverpod bridge 4.0.4 exposed nine tools and a real `tail_server_logs` call returned without error. Dart MCP 1.2.1 initialized and exposed fourteen tools. No migration or reload tool was invoked by the probes.
- `dart run tool/client_smoke.dart --development`: the JWT lifecycle smoke passed against the watch runner.
- PowerShell parser, documentation links, ignore rules and `git diff --check`: passed. The complete build/browser/two-host suite was not repeated for this tooling-only change; its JWT implementation results above remain the earlier evidence.

The existing chat's tool catalog did not dynamically add the servers after configuration. A client restart/reload is still needed to test agent-native calls in a fresh tool catalog. Registration and successful external MCP protocol calls establish local bridge connectivity, not that this chat already has those tools. Flutter was not auto-launched by this runner; Flutter launch/DTD operations remain untested here.

## Review and limits

Relative documentation links/anchors, ADR numbering, changed-file list, unchanged Apache 2.0 LICENSE and generated-secret exclusions are checked separately before commit. Generated local secrets were compared against all tracked/candidate text files without printing their values; no matches were found. Password/config/build artifacts remain ignored. Dependency LICENSE observations are in ADR 0021; no blanket dependency license compatibility is claimed.

The current checks do not prove full calendar/RFC support, external feed-client compatibility, durable notification delivery, OS background notifications, CI readiness or complete production multi-instance behavior. Those remain roadmap acceptance work. See [local commands](development.md), [scaffolding choices](scaffolding-plan.md) and [ADR 0021](adr/0021-initial-workspace-scaffold.md).

## Pre-merge review and full revalidation, 2026-10-20

The maintainer authorized review and merge on success. PR #1 had no submitted GitHub reviews or unresolved review threads; this is an agent source review with local execution evidence, not independent human approval or hosted CI. Reviewed package/domain boundaries, diagnostic authentication, synthetic fixture/seeding isolation, JWT lifecycle expectations, generated/secret exclusions, temporal profile guards and bounded recurrence behavior. Remaining schema/lifecycle/protocol proposals are future work; merging the milestone does not accept every ADR or claim first-release completion.

Review found a due-only zoned task validation bug: without DTSTART, the constructor validated its due instant as an ordinary UTC date. Valid local dues at 1970 in Tokyo or late 2099 in New York could therefore reject their necessary UTC spillover. A regression test reproduced the failure before the fix. Validation now uses the due value's named zone when no start exists; tasks still reject the exclusive 2100 local endpoint. Also corrected obsolete timezone limits in the development guide and an outdated fractional-precision source comment.

Commands/checks actually run:

- `./tool/check.ps1`: **passed completely**. Locked dependencies, unchanged regeneration of all three server/client pairs, formatting/analysis, core VM/Chrome suites, sign-in widget test, isolated test database reset/fresh migrations, native host bundle, two independent shared-storage hosts, real-client JWT refresh/rotation/logout/revocation, Flutter WebDriver sign-in/module calls/sign-out and release Web build all passed. The WASM dry run passed without a separate runtime claim.
- After the task review fix, focused `dart test test/task_timing_test.dart test/calendar_profile_test.dart`: **12 passed**. Complete core `dart test --reporter expanded` and `dart test --platform chrome --reporter expanded`: **443 passed each**. The full sequence's earlier core count was 442; the added regression accounts for the difference.
- Final root `dart analyze --fatal-infos`: no issues; formatting of all 76 authored Dart files: no changes. Framework-generated output, dependency lockfile and LICENSE are unchanged by this review batch.
- Documentation relative links/anchors and consecutive ADRs 0001–0042 validated. Seventeen distinct locally generated secret values checked against all 265 then-candidate files without printing values: no matches. `git diff --check` passed. Local logs remain ignored.

The maintainer also confirmed a separate optional HTTP feed module. [ADR 0042](adr/0042-optional-http-feed-module.md) records the accepted boundary; its code, migrations and final package names remain a following batch. Calendar/native APIs stay independent of installing feeds. No feed-domain, scheduling, alarm, provider or external-client interoperability is inferred from these scaffold tests.

## First calendar CRUD batch, 2026-10-20

Implemented the limited [native name/settings/association slice](calendar-crud-implementation.md), not event/task/feed/availability calculation. Source review checked host-policy replacement, trusted scope/object snapshots, disclosure, transactional revisions, durable scope locking, cursor binding, dependency checks and content-free deletion. Review found mutable generated request objects could change during a direct service call; the service now takes private command copies, with a reproducing regression. This is agent review and local execution evidence, not independent review or hosted CI.

Commands/checks actually run:

- Pinned `serverpod --no-analytics create-migration --tag calendar-crud` in the calendar module server and example server: generated migrations successfully. Reviewed server-generated UUID identity, unique active-data/subject relations, foreign keys and module-prefixed tables. The running MCP's initial create-migration returned no changes before the CLI generated the host revision; CLI generation and actual database application establish schema evidence.
- `./tool/check.ps1`: locked dependency resolution and stable three-pair regeneration, Windows-batched formatting, fatal-info analysis, **443 core tests on VM and 443 on Chrome**, **3 native-text tests on VM and 3 on Chrome**, existing Flutter sign-in widget test, synthetic database reset, then-current 16 database tests, fresh host migrations and two-host generated-client checks passed. The initial complete command stopped at the new browser wait helper; it is not reported as a wholly successful script run.
- Final focused `dart test test/integration/calendar_test.dart` from the example server: **17 passed**, including the command-snapshot regression, duplicates, private scope, actual object/field-group disclosure, separate permissions, stale revisions, markers/payload removal, associations/deletion, final denial rollback, malformed/unavailable policy responses, policy timeout, bounded hidden scan, cursor query/policy/data binding, explicit guarantee rejection/downgrade and failed dependency checks. An overlapping attempted rerun hit the harness's service ports; rerunning sequentially passed. Ephemeral database isolation does not isolate configured HTTP ports.
- `./tool/build-host.ps1`, test-storage reset and `dart run tool/host_smoke.dart --flutter`: **passed on final affected-surface rerun**. Two independent compiled hosts exercised generated calendar CRUD, scope isolation, authorized projection, cross-host cursor use/invalidation, stale writes and competing delete/attach. Exactly one race contender succeeds; a surviving association blocks deletion until explicitly removed. JWT login/refresh/rotation/local logout/refresh revocation checks remain intact.
- Flutter WebDriver calendar journey: **passed** create, rename, explicit zone/settings, self-association, dependency-blocked delete, detach, successful delete and sign-out. The idle helper was corrected to ignore text-caret frames and treat a confirmation dialog as awaiting input; neither change bypasses request or result assertions. Synthetic labels are unique per run. The CLI owns and cleans up its test hosts/browser processes.
- Restored the hidden interactive development runner: it applied the calendar migration to existing development storage successfully. An agent-native Serverpod MCP `hot_reload` then completed; current MCP access is verified, not inferred from configuration.
- Final `flutter build web --no-pub` from the example Flutter package: **passed**, including the toolchain's Wasm dry-run compile (no Wasm runtime compatibility claim).
- Final `dart analyze --fatal-infos`, formatting of all 85 authored Dart files, relative documentation links, consecutive ADRs and whitespace checks: passed. No local credential values were found in candidate repository files; LICENSE remains unchanged. Logs/config/generated credentials/build output stay ignored.

Only the example's declared `freshCheck` policy ships. Strong-mode configuration/downgrade rejection is tested; no production transaction-coordinated authorization provider or revocation/recovery guarantee for future module families is claimed. Description/color/protocol metadata editing, real event/feed/worker dependencies, marker retention and global cursor cleanup remain following work. The optional feed module is not required or installed for these tests. No RFC/native calendar timing or external-client compatibility is inferred from CRUD tests.

## Calendar presentation and decoded protocol text batch, 2026-10-21

[ADR 0050](adr/0050-calendar-presentation-and-protocol-text.md) and [the metadata guide](calendar-metadata.md) distinguish the implemented native editing/storage slice from still-pending parsing/export/feed support. The maintainer selected separate native/protocol values, opaque native RGB, RFC CSS3 names, preserved multiline native descriptions capped at 16,384 code points and a first NAME/DESCRIPTION/COLOR batch. Exact generated schema, limits and host methods remain implementation review choices.

Source review checked field/permission separation, nested snapshot immutability, request freezing before callbacks, plain text/color/language validation, atomic aggregate/scope revisions, disclosure and deletion scrubbing. It also found that refreshing after one section save could otherwise rebase an old draft over a concurrent change: the example now accounts only for its own known revision increment and requires explicit reload after an unexpected revision or stale response. This is agent review, not independent human review or hosted CI.

Commands/checks actually run during the batch:

- Pinned module and example `serverpod --no-analytics create-migration --tag calendar-metadata`: generated successfully; reviewed SQL adds only nullable description/color/typed-JSON columns, retaining existing identity, names/settings/revisions and active timestamps. The MCP create-migration call reported no changes; the CLI-generated host revision and actual migration tests establish schema evidence.
- Focused native/profile unit tests: **7 new cases passed**. Focused database metadata subset: **5 new cases passed**. Flutter explicit-copy widget test: **passed** without network access, verifying no automatic synchronization, preservation of translated variants and explicit save/reset behavior.
- Batch check regeneration stability, formatting, analysis, **443 core tests on VM and 443 on Chrome**, **10 module text/profile tests on VM and 10 on Chrome**, **2 Flutter widget tests**, and **22 real database/policy tests**: passed. A first attempt stopped at formatting of automatic brace fixes; formatting was applied before restarting the checks.

Database evidence includes separate native/protocol values and gates, group-redacted pages, empty/clear semantics, invalid/stale/final-denied rollback, nested request/policy immutability, cursor invalidation and rich active-payload removal with minimal markers. BCP47 fixtures establish well-formed syntax only, not registry validity, matching or translation. CSS3 tests do not imply arbitrary CSS support. No accepted raw ICS/property-parameter preservation, wire round trip, ETag behavior or external-client rendering is claimed.

Final batch results:

- `./tool/check.ps1`: **passed** after the formatting correction. Both independent compiled hosts passed native/protocol metadata isolation, multilingual generated-client round trips, independent group projection, name-only retention, invalid-color rejection, native clearing, existing stale/cursor/delete-attach races and JWT lifecycle checks.
- The expanded Flutter WebDriver journey **passed** native descriptions/RGB, translated protocol NAME plus explicit default-name/description copy, independent CSS3 color, retention across native edits, an external concurrent protocol change, stale draft rejection with unchanged server data, explicit reload and the existing association/dependency/delete/sign-out journey.
- Flutter Web release build **passed**, including its Wasm dry-run compile; no Wasm runtime interoperability claim follows.
- `python tool/metadata_upgrade_smoke.py`: **passed** against a separate temporary database on the dedicated test service. It loads the generated pre-metadata schema, populates synthetic identity/revision/content/timestamps/subject/scope fixtures, applies the generated host upgrade and verifies preservation plus null new fields. The temporary database is dropped only after this process successfully creates it. This helper is now included in the root check sequence; it was also executed separately in this run.
- Final formatting covered all **89 authored Dart files**; analysis, PowerShell/Python syntax, relative links, ADR numbering, whitespace, unchanged LICENSE and local-credential exclusion were checked separately before commit. Build/config/log artifacts remain ignored.

No ICS parser/serializer, ALTREP/extension-parameter acceptance, source metadata round trip, calendar/feed UID/LAST-MODIFIED implementation, ETag behavior or external-client UI support was verified by these metadata tests. The host example still declares fresh-check authorization; a coordinated production policy and other domain families remain separate work.

The restored hidden development runner applied host migration `20261020150003755-calendar-metadata` to existing development storage. Agent-native Serverpod MCP log access confirmed that exact migration, and a subsequent MCP hot reload completed successfully.


## Calendar links, categories, images and refresh batch, 2026-10-21

[ADR 0051](adr/0051-calendar-links-categories-images-refresh.md) and [the implementation guide](calendar-links-and-categories.md) record this limited native editing/storage/query profile. The maintainer confirmed HTTP/HTTPS references without user information, exact category text matching with optional language tags and unit-preserving positive whole-second refresh hints with a one-year editing cap. The implementation defines that cap as a 365-day equivalent; schema, API and numeric limits remain review choices.

Agent source review checked independent replacement/clearing, disclosure and write permissions, immutable nested commands/policy context, filter-bound durable cursors, final-check rollback, scope revisions and minimal deletion markers. Links are not fetched, remote images are not loaded and refresh hints do not schedule work. This is local agent review and execution evidence, not independent human approval or hosted CI.

Commands/checks actually run:

- Pinned module/host `serverpod --no-analytics create-migration --tag calendar-links-categories`: generated nullable supplemental-metadata and cursor-filter JSON columns. Reviewed SQL preserves existing rows and identities; generated files were not hand-edited.
- Focused unit profile subset: **7 passed**; focused database subset: **4 passed**; supplemental Flutter editor widget test: **passed**. These cover URI rejection/preservation, category text/language, image hint defaults/unknown values, preserved refresh units/bounds, atomic authorization and nested-data immutability.
- `./tool/check.ps1`: locked dependencies, unchanged regeneration of all three server/client pairs, formatting of **93 authored Dart files**, fatal-info analysis, **443 core tests on VM and 443 on Chrome**, **17 module profile tests on VM and 17 on Chrome**, **3 Flutter widget tests**, **26 database/policy tests**, populated-schema upgrades, compiled hosts and two-host generated-client/JWT checks passed. The complete script then stopped at a browser test assumption, so it is not reported as wholly successful.
- The browser journey initially assumed the edited UUID would appear on the first visible unfiltered page after clearing search. It now reopens through the already-verified exact category filter. An attempted rerun without resetting synthetic storage encountered leftover fixture matches; after `./tool/reset-test.ps1`, `dart run tool/host_smoke.dart --flutter` **passed**. No broader core rerun was needed for this test-only correction; final `dart analyze --fatal-infos` passed.
- Final two-host evidence includes unit-preserving metadata round trips, independent projections, filtered cursor use across instances and filter-change rejection, existing native/protocol isolation, stale writes, competing delete/attach and JWT refresh/rotation/local logout/refresh revocation. The Flutter WebDriver journey passed explicit supplemental editing, protocol-text retention, exact case-sensitive category/language search, clear/reapply search and existing revision/association/deletion/sign-out checks.
- `python tool/metadata_upgrade_smoke.py`, invoked by the batch check: **passed** on a temporary synthetic database on dedicated test storage. It verifies both earlier text-metadata and new supplemental migrations, preserving native/protocol content, revisions, identities, associations and old unfiltered cursor bindings, with new fields null. The helper drops only its temporary database.

- Final `flutter build web --no-pub`: **passed**, including the Wasm dry-run compile; no separate Wasm runtime claim follows.
- Restored the hidden interactive development runner. Agent-native Serverpod MCP `tail_server_logs` verified application of host migration `20261021051116035-calendar-links-categories`; `hot_reload` succeeded. Current MCP access is verified.
- Relative documentation links, consecutive ADRs 0001–0051, unchanged Apache 2.0 LICENSE, candidate-file credential exclusion and `git diff --check`: passed. Local logs, fixture credentials and build output remain ignored.

Parsing/serialization, arbitrary property parameters, SOURCE handling, feed bytes/ETags, external-client rendering, remote content verification and polling remain pending. No stronger production authorization or complete calendar interoperability guarantee follows from these tests.


## Calendar protocol identity and revision-time batch, 2026-10-21

[ADR 0052](adr/0052-calendar-protocol-identity-and-revision-time.md) records the maintainer-confirmed separate generated UID and automatic whole-second UTC calendar timestamp. [The guide](calendar-protocol-identity.md) distinguishes native calendar revision time from imported/source values and full publication change tracking. API/schema mechanics remain under review.

Agent source review checked server ownership, stable UID retention through every mutation family, independent read/list disclosure, immutable actual host snapshots, shared database-clock ordering, same-second revisions, denied/stale writes and unchanged content-free deletion. No independent human approval or hosted CI is claimed.

Commands/checks actually run:

- Pinned module/host `serverpod --no-analytics create-migration --tag calendar-protocol-identity --force`: generated the new non-null random UUID column and unique index. Generation first reported the standard unique-index warning; the new column's random backfill was reviewed and tested before applying to development. The MCP create-migration call reported no changes; the generated CLI revisions and actual schema tests establish migration evidence. Generated files were not hand-edited.
- Focused `dart test test/integration/calendar_test.dart --name 'protocol identity|automatic revision time|clock correction' --reporter expanded`, from the example server: **4 passed**. Tests cover distinct UID/API identities, host snapshots, independent disclosure, automatic time on all eight mutation forms, UTC whole seconds, precise native timestamp retention, synthetic clock correction, unchanged same-second time with increasing revisions, denied/stale/invalid commands and deletion scrubbing.
- `python tool/metadata_upgrade_smoke.py`: **passed** with populated synthetic pre-upgrade data. The upgrade gives two active rows distinct non-API UIDs, enforces the unique index, preserves exact fractional timestamps/content/revisions/cursors/associations and does not recreate deleted payloads. The helper drops only the temporary test database it creates.

- Final `./tool/check.ps1`: **passed completely**. Locked dependencies, stable regeneration of all three server/client pairs, formatting of 93 authored Dart files, fatal-info analysis, **443 core tests on VM and 443 on Chrome**, **17 module profile tests on VM and 17 on Chrome**, **3 Flutter widget tests**, **30 database/policy tests**, populated upgrades, native host build, two independent shared-storage hosts, generated-client/JWT checks, Flutter WebDriver and Web release build all passed. The Wasm dry-run compile passed without a separate runtime claim.
- Two-host evidence includes stable UID/time reads across instances, distinct protocol/native identities, UID retention after edits and nondecreasing revision time. Existing metadata isolation, category/cursor binding, stale-write/delete-attach races and JWT login/refresh/rotation/local logout/refresh revocation checks passed.
- The expanded Flutter browser journey passed read-only UID/time display, UID retention through edits and UTC whole-second generated-client values alongside existing metadata, category, stale/reload, association/deletion and sign-out assertions.
- Restored the hidden interactive development runner; Serverpod MCP logs verified application of `20261021061921307-calendar-protocol-identity` and MCP `hot_reload` succeeded. Dart MCP DTD discovery connected specifically to this repository's existing Flutter app; Flutter `hot_reload` succeeded. Unrelated apps were not reloaded.
- Relative Markdown links, consecutive ADRs 0001–0052, unchanged Apache 2.0 LICENSE, candidate-file local-credential exclusion and `git diff --check`: passed. Local credentials/logs/build output remain ignored.

These results establish the scoped native identity/time behavior. They do not establish ICS parsing/export, imported identity reconciliation, complete VCALENDAR freshness, feed validators, external calendar-client interoperability or a production coordinated host policy.


## First native non-recurring event batch, 2026-10-21

[ADR 0053](adr/0053-first-native-single-events.md) records maintainer-confirmed non-recurring CRUD first, optional summaries, distinct cancellation/deletion with minimal event markers and separate lifecycle permission. [The guide](native-single-events.md) defines the limited native API/storage profile. Recurrence persistence and full RFC/wire/client support remain pending; model/API/default/limit mechanics remain under review.

Agent source review checked immutable commands and actual parent/event/proposed host context, independent event permissions/groups, mixed edit/status checks, same-scope parent lookup, final checks/revisions, deletion scrubbing, scope locking and opaque query-kind-bound cursors. It identified hidden duration controls being validated after selecting omitted-end mode; only selected duration input is now validated, with a browser regression. This is local agent review, not independent human approval or hosted CI.

Commands/checks actually run:

- Pinned module/host `serverpod --no-analytics create-migration --tag native-single-events`: generated event identity/data tables, foreign keys/unique payload and UID indexes, and nullable event cursor bindings. Reviewed SQL has no existing-payload transformation; generated protocol/client/test/migration files were not hand-edited.
- Focused VM adapter `dart test test/unit/event_values_test.dart --reporter expanded`: **6 passed**, covering DATE defaults/explicit end, UTC points, retained day-versus-clock units over DST, explicit gap/fold rules, aliases, whole seconds/profile rejection and optional plain text/unsupported recurrence. These tests import server-generated models and are explicitly VM-only; no Chrome adapter-test claim is made.
- Focused example `dart test test/integration/calendar_test.dart --name 'event ' --reporter expanded`: the initial **6 event database cases passed**. The subsequent complete database run includes the added hidden-scan-budget case.
- `./tool/check.ps1`: locked dependencies, stable three-pair regeneration, formatting of **98 authored Dart files**, fatal-info analysis, **443 core tests on VM and 443 on Chrome**, **23 module tests on VM and 17 on Chrome**, **3 Flutter widget tests**, **37 real database/policy tests**, populated upgrades, native host build and two-host generated-client/JWT checks passed. An earlier attempt stopped on a race-test lint; the corrected run reached the browser journey and stopped there, so it is not reported as wholly successful.
- Populated `python tool/metadata_upgrade_smoke.py`, both standalone and in the batch check: **passed**. The native event migration adds empty event tables, leaves old cursor event fields null and preserves existing calendar rows, precise timestamps, revisions, associations and UID constraints. Only its own temporary synthetic test database is dropped.
- Two independent shared-storage hosts passed DATE/UTC/zoned event transport with retained duration form, optional summary, cross-host event cursors, competing stale event status writes, retained cancellation identity, cursor invalidation, active-child deletion blocking and a parent-delete/event-create race. Exactly one parent-race contender succeeds. Existing calendar metadata/category/cursor/delete-attach and JWT lifecycle checks also passed.

- The first browser failure showed that a renamed event summary had not been entered after stale reload. A stronger controller assertion reproduced failed text entry before any save request. The editor now unfocuses before disabling the form, and the journey waits for an enabled field and explicitly refocuses it. After formatting/fatal-info analysis and resetting dedicated synthetic storage, final `dart run tool/host_smoke.dart --flutter` **passed**, including actual stored-summary assertions. No backend/core rerun was needed for these final Flutter/test-only changes.
- The expanded Flutter journey **passed** optional-summary creation without storing the placeholder, hidden-duration switching, an external conflicting edit, stale rejection without overwriting stored text, explicit reload/refocus/save, cancellation, blocked parent deletion, reopening, content deletion and existing calendar metadata/association/sign-out assertions.

- Final `flutter build web --no-pub`: **passed**, including Wasm dry-run compilation without a separate Wasm runtime claim. Final affected Dart formatting and root `dart analyze --fatal-infos` passed.
- Restored the hidden interactive example runner. Agent-native Serverpod MCP logs verified application of host migration `20261021064805603-native-single-events`; Serverpod MCP hot reload succeeded. Dart MCP verified this repository's existing Flutter DTD connection and hot-restarted that app to initialize the new generated endpoint client. Unrelated apps were not restarted.
- Relative documentation links, consecutive ADRs 0001–0053, unchanged Apache 2.0 LICENSE, candidate-file local-credential exclusion and whitespace checks: passed. Credentials/logs/build artifacts remain ignored.

These checks establish the scoped non-recurring native event increment. They do not establish recurring event persistence, full canonical/interchange metadata, complete availability coverage, exclusive reservations, scheduling/notification execution, production coordinated authorization, HTTP feeds or external calendar-client interoperability.

## Native recurrence storage and previews, 2026-10-21

[ADR 0054](adr/0054-native-event-recurrence-and-previews.md) and [the native guide](native-event-recurrence.md) scope this batch. The maintainer selected storage/previews first, preserved explicit dates on pattern edits and rejection of incompatible changes. Single/range occurrence editing remains pending.

Commands/results for the pinned Dart 3.13.5, Flutter 3.47.7 and Serverpod 4.0.4 toolchain:

- Focused `dart test test/unit/event_values_test.dart` from the module server: **12 passed**. Coverage includes earlier RDATE/EXDATE precedence, canonical filters/start matching, generated DST gaps, nominal duration, overlap/points, mixed profiles/fractions and input/query/result limits.
- `./tool/reset-test.ps1`, then `dart test test/integration/calendar_test.dart --name 'recurrence|pattern changes|preview requires|preview caps|previous non-recurring'` from the example server: **5 passed**. Actual immutable parent/event/query policy context, separate read/preview rights and timing disclosure, preserved versus deliberate replacement dates, rollback, stale revisions, no read timestamp mutation and earlier JSON payload compatibility are exercised.
- `./tool/check.ps1`: stable generation across all three module/host pairs, authored formatting, fatal-info analysis, **443 core VM + 443 core Chrome**, **29 module unit VM + 17 module unit Chrome**, **3 Flutter widget** and **42 database/policy tests**, populated schema upgrades, compiled host, two independent host processes/generated clients/JWT, Flutter WebDriver and Flutter web release build. Recurrence DTO tests are VM-only server adapter tests; generated browser transport is exercised by Flutter.
- The two-host harness compares DATE/UTC/named-zone recurring projections across processes, verifies the 23-hour nominal day across Stockholm DST, races pattern edits at the same expected revision, and rejects stale previews. Existing event lifecycle/cursor/calendar dependency and JWT checks remain included.
- The Flutter journey saves a daily series with an earlier inclusion and an exclusion, previews the three expected dates through the live endpoint and continues cancellation/deletion/stale-edit checks.
- Serverpod MCP reports **no SQL schema changes**: optional recurrence is stored in the existing typed JSON content. A database test rewrites synthetic content to the prior `recurring:false` JSON form, then verifies unchanged UID/revision/time and absent recurrence.

Relative links, consecutive ADR numbering through 0054, unchanged Apache 2.0 LICENSE, candidate-file credential exclusions and `git diff --check` are checked separately. Local credentials, logs and build artifacts remain ignored. These results establish native storage/previews, not occurrence editing, complete availability, scheduling/alarm execution, ICS/feed support or external-client interoperability.

## Native occurrence timing edits, 2026-10-21

[ADR 0055](adr/0055-native-occurrence-timing-edits.md) and [the guide](native-occurrence-timing.md) scope the timing-only/single-cancellation batch. The maintainer selected preservation and orphan rejection, deferred content overrides and future cancellation, and authorized per-calendar free/busy as the next area.

- Focused module `dart test test/unit/event_overrides_test.dart test/unit/event_values_test.dart`: **18 passed**. Six new tests cover DATE/UTC/zoned single/range projection, moved original identities, separate single precedence, absolute later ranges, retained timing through cancellation/restoration, explicit clearing, orphan/excluded/collision/profile rejection, frozen collections and the raw 128-override cap.
- `./tool/reset-test.ps1`, then example-server `dart test test/integration/calendar_test.dart --name 'occurrence timing|occurrence action|occurrence overrides|occurrence stale'`: **5 passed**. Tests cover separate permissions and immutable actual/final proposal context, master-content preservation and orphan rejection, lifecycle-only restoration, revision/time/UID behavior, denied/stale/post-write rollback, disclosure/scope and payload deletion.
- Pinned CLI migration generation produced module `20261021094604875-event-occurrence-timing` and host `20261021094608490-event-occurrence-timing`. MCP creation reported no changes before the module migration existed; the CLI fallback generated the actual change, and MCP apply succeeded. Reviewed SQL adds only nullable JSON `timingOverrides` to active event data. The populated upgrade helper passed a prior event fixture without changing content, UID, precise time, revision or scope generation.
- `./tool/check.ps1` passed locked resolution, stable generation across three pairs, formatting/fatal-info analysis, **443 core VM + 443 core Chrome**, **35 module unit VM + 17 module unit Chrome**, **3 Flutter widget**, **47 database/policy tests**, populated upgrades, compiled host and two-host/generated-client/JWT checks. It then stopped at the browser assertion described below; it is not reported as an uninterrupted successful full-script run.
- Two-host checks exercise future timing plus an independent moved single, remote cancellation/restoration retaining its timing, competing occurrence writes with exactly one stale rejection, master/UID preservation, and existing calendar/event/recurrence/JWT checks.
- The first browser run timed out locating a future-moved date. Synthetic storage inspection confirmed the correct retained original anchor and April 2 replacement. The test now explicitly verifies the query-bound control and scrolls lazy ListView rows/actions before assertions. Final `./tool/reset-test.ps1` and `dart run tool/host_smoke.dart --flutter`: **passed**, including the full earlier journey and occurrence stale-draft, move/future, cancellation/restoration, explicit clearing and refreshed master lifecycle actions. No temporal/database implementation changed for that test fix, so their already-passing broader suites were not repeated.
- Final affected formatting and `dart analyze --fatal-infos`: **passed**. Runtime/browser evidence remains separate from future ICS/client interoperability, availability, scheduling and alarm execution.

Documentation links, consecutive ADR numbering through 0055, unchanged Apache 2.0 LICENSE, candidate-file credential exclusions and `git diff --check` were checked. Local synthetic data/logs/build artifacts remain ignored. These results establish the scoped native timing service, not content overrides, future cancellation, free/busy or full first-release support.

Final occurrence-batch `flutter build web --no-pub`: **passed**, including Wasm dry-run compilation without claiming a separately tested Wasm runtime.

## First per-calendar free/busy, 2026-10-21

[ADR 0056](adr/0056-first-calendar-free-busy.md) and [the guide](calendar-free-busy.md) scope the maintainer-selected per-calendar-first/tentative-blocking increment. Working-hours rules and subject/common-slot search remain pending; this is not full availability acceptance.

- Focused core `dart test test/free_busy_test.dart`: **5 passed**. Clipping/adjacency, native precedence, complete disjoint finite-tick coverage, input-order invariance and raw/output-limit failure are exercised independently of Serverpod.
- Focused module `dart test test/unit/free_busy_values_test.dart`: **4 passed**. Tests cover explicit calendar-zone DATE occupancy across Stockholm DST, timed geometry/clipping, points/transparent/cancelled masters and individual cancellation retaining/restoring timing.
- `./tool/reset-test.ps1`, then example-server `dart test test/integration/calendar_test.dart --name 'free busy'`: **6 passed**. Overlapping private bookings/tentative classification, detail-plan independence, denied-source unknown without partial periods, actual policy query/parent/event context, DATE recurrence/moved cancellation, fallback, source/recurrence caps, scopes/UTC precision/window validation and unchanged read revision/time are covered.
- End-of-batch `./tool/check.ps1` passed stable generation, formatting/fatal-info analysis, **448 core VM + 448 core Chrome**, **39 module unit VM + 17 module unit Chrome**, **3 Flutter widget**, **53 database/policy tests**, populated upgrades, compiled host and two-host/generated-client/JWT checks. The expanded Flutter WebDriver journey passed as well.
- Two-host free/busy results are compared byte-for-byte, retain tentative classification and contain no synthetic event UUID/title. A committed lifecycle change is reflected as busy on the other host, then transparency yields a complete free partition. Existing occurrence/recurrence/calendar/JWT races and journeys remain included.
- The Flutter journey calculates UTC-window coverage and observes tentative periods while asserting that the synthetic private title is absent, then continues the existing lifecycle/deletion flow.
- MCP migration creation reports **no changes**; this increment adds query DTOs, computation and policy context without a new table/column. No generated files or migration metadata were hand-edited.

Relative documentation links, consecutive ADRs through 0056, unchanged Apache 2.0 LICENSE, credential exclusions and `git diff --check` passed. The current source cap counts all active event records across a calendar; proven time-indexed candidates remain a roadmap item for larger calendars. No complete rule/subject availability, VFREEBUSY serialization, scheduling, alarms, reservation, CI or external-client evidence is inferred.

The free/busy `./tool/check.ps1` run completed successfully through the final Flutter web release build. Its Wasm dry run compiled successfully; a separate Wasm runtime was not exercised.

## Native working-hours batch, 2026-10-21

[ADR 0057](adr/0057-native-working-hours.md) adds native rule CRUD, recurring opening evaluation and composition into per-calendar free/busy. Pinned Dart 3.13.5 / Flutter 3.47.7 / Serverpod 4.0.4 remain unchanged. All fixtures are synthetic; no real mail, provider push, calendar feed or production service is exercised.

Focused commands passed during implementation:

- Core directory: `dart test test/availability_rules_test.dart` — 5 tests, covering optional bounds/clipping, default/high/equal priorities, closures, an independent hourly oracle, input-order invariance and limits.
- Calendar server module directory: `dart test test/unit/availability_values_test.dart` — 4 tests, covering explicit named-zone DST, recurring inclusion/exclusion dates, frozen collections, exclusive boundaries and rejected invalid timing/priority/type/caps.
- Example server directory: `dart test test/integration/calendar_test.dart --name availability` — the initial 4 focused CRUD/policy tests passed. A fifth zone-independence/source-cap test was added before the broader database run.

Serverpod MCP was verified with `tail_server_logs`. Its initial `create_migration` reported no host changes before the module migration existed. The pinned CLI created module `20261021121921134-availability-rules` and host `20261021121924598-availability-rules`; reviewed SQL only creates the two rule tables, indexes and foreign keys plus migration versions. MCP `apply_migrations` succeeded. Generated models/endpoints/client/test tools come from `.spy.yaml` and endpoint sources via `./tool/generate.ps1`; none were hand-edited.

The broader `./tool/check.ps1` passed stable generation, formatting, fatal-info analysis, **453 core VM + 453 core Chrome**, **43 module VM + 17 module Chrome**, **3 Flutter widget** and **58 real database/policy** tests. The populated upgrade helper replayed the new migration without changing old calendar/event content, UIDs, revisions, cursor bindings or precise timestamps. The host compiled and two independent host processes sharing test storage passed generated-client/JWT smoke checks, remote working-hours visibility, one-winner rule updates and parent-delete/rule-create races. Flutter WebDriver passed create/read, explicit-zone recurring hours/free-busy, stale draft preservation, disabled stale save and deletion through the real generated API. The final added timezone field input also passed focused fatal-info analysis of `connected_smoke_test.dart`.

The same uninterrupted broader run also passed the Flutter web release build, including its Wasm dry-run compilation (no Wasm runtime claim), and ended `All requested local checks passed.` The owned development runner was restored hidden afterwards, and the existing calendar Flutter app hot-restarted successfully through Dart MCP.

The batch log is ignored `.local/availability-batch-check.log`. The local link/numbering/credential checks found no missing relative Markdown links, consecutive ADRs 0001–0057, no candidate-file matches for local credential values and an unchanged Apache 2.0 LICENSE. Raw/projection permissions, final-denied atomic writes, minimal deletion markers, stable opening identities, parent dependencies, scope isolation, unavailable projection and source-cap unknown are covered by the new database cases. Named-zone hours remain unchanged when the calendar availability zone changes.

This is native calculation evidence. Rich availability metadata, opening-occurrence overrides, wire import/export, host-selected subject/common-slot search, indexed larger-calendar coverage and external-client interoperability remain pending. No full RFC 7953 or reservation guarantee is claimed.

## Subject availability and common-free batch, 2026-10-21

[ADR 0058](adr/0058-subject-availability-search.md) adds authoritative host contributor resolution, independent summary/source projection permissions and native per-target/common-free search within one trusted scope. The pinned toolchain remains Dart 3.13.5, Flutter 3.47.7 and Serverpod 4.0.4. Existing module associations/storage are reused; generated endpoint/DTO/client/test-tool changes come from sources via `./tool/generate.ps1`. Serverpod MCP `create_migration` reported no schema changes; no migration files were added or hand-edited.

Focused validation during implementation:

- Core directory: `dart test test/availability_search_test.dart` — 6 tests passed: complete-partition intersection, independent calendar priorities, elapsed minimum boundaries, empty/incomplete/overlapping source rejection, raw input budgets and an independent hourly oracle/order check.
- Example server directory: `dart test test/integration/calendar_test.dart --name 'subject search|free busy'` — 13 passed, covering the initial 7 subject cases and 6 existing free/busy regressions after extracting the shared evaluator.
- Same directory: `dart test test/integration/calendar_test.dart --name 'subject search intersects|subject search charges'` — 2 additional cases passed for per-calendar rule priority/minimums, required rule authority and shared event budgets.

One broader `./tool/check.ps1` passed generation stability, formatting, fatal-info analysis, **459 core VM + 459 core Chrome**, **43 module VM + 17 module Chrome**, **3 Flutter widget** and **67 database/policy** tests. The existing populated upgrade helper, compiled host, two independent host/generated-client/JWT tests, real Flutter WebDriver and web release build also passed. The web build includes Wasm dry-run compilation, not Wasm runtime evidence. The ignored log `.local/subject-batch-check.log` ends `All requested local checks passed.`

A final test-only addition checks mixed user/room/equipment references sharing an external ID. After the smoke hosts stopped, `dart test test/integration/calendar_test.dart --name 'subject search supports mixed'` passed that 1 additional case, and focused fatal-info analysis of the changed integration test file passed. Thus the final file has **68 covered database/policy cases**: 67 in the broader run plus the final focused case; the broad suite was not needlessly repeated after this test-only change. Its ignored log is `.local/subject-mixed-target-test.log`.

New database checks cover administrative-only links, independent summary/direct rights, no private source UUID/content/version output, denied target/calendar/event/rule projection, empty/incomplete/foreign/deleted contributor sets, final mapping revision/set/access changes, frozen query context, deduplication, query/minimum validation, aggregate work exhaustion, rule intersections and mixed resource kinds. Cross-host generated-client checks compare summary slots, observe a remotely committed closure and confirm remote contributor removal becomes unknown instead of free. Browser tests exercise both modes, invalidate old results on input changes, and distinguish an unauthorized target/common result from a separately complete target. Synthetic fixtures only; no real email, push, feed or production resource is touched.

Relative Markdown links, consecutive ADRs 0001–0058, candidate-file credential scanning, changed-file scope and unchanged Apache 2.0 LICENSE were checked. The owned development runner was restored hidden and the existing calendar Flutter app hot-restarted through Dart MCP. Single-scope snapshots do not supply cross-scope coordination, external authorization leases, directory group expansion, wire VFREEBUSY or exclusive reservations. Larger-calendar indexing and richer availability-rule/interchange work remain pending.

## Opening-occurrence edits and availability metadata batch, 2026-10-21

[ADR 0059](adr/0059-availability-occurrence-edits-and-metadata.md) adds shared single/future timing and skip/restore/clear semantics for openings, separate persisted edits, legal native metadata, exact category filtering and independent preview/action/metadata host gates. Toolchain remains Dart 3.13.5, Flutter 3.47.7 and Serverpod 4.0.4. No real mail, push, feeds, directory lookup or resource reservation is exercised.

Focused validation passed before the broader batch:

- Repository root: `dart test packages/serverpod_calendar/serverpod_calendar_server/test/unit/opening_values_test.dart` — 5 VM tests for original identity, retained timing/skip/restore, future changes/orphan rejection, positive spans/collisions/raw caps, frozen metadata/categories/comments, no-userinfo HTTP URL validation and metadata limits.
- Example server directory: `dart test test/integration/calendar_test.dart --name 'opening lifecycle|opening mutation|availability metadata is separate|deleting an opening'` — 4 database/policy cases for persisted lifecycle/calculation, separate gates, stale/final-denied atomicity, preserved metadata/overrides, exact authorized search, protected structure and deliberate opening deletion.

Generated sources come from `.spy.yaml` and endpoints via `./tool/generate.ps1`; generated protocols/clients/test tools were not hand-edited. MCP initially reported no host migration changes before the module migration existed. Pinned CLI created module `20261021144847729-availability-opening-edits` and host `20261021144851473-availability-opening-edits`; reviewed SQL adds only nullable JSON `timingOverrides` to active availability data plus version records. MCP `apply_migrations` succeeded. The populated upgrade fixture verifies old availability content/UID/revision/precise timestamp remain unchanged with null overrides, in addition to existing calendar/event preservation checks.

One uninterrupted `./tool/check.ps1` passed stable generation, formatting, fatal-info analysis, **459 core VM + 459 core Chrome**, **48 module VM + 17 module Chrome**, **3 Flutter widget** and **72 real database/policy** tests, populated upgrades, host compilation, two independent host/generated-client/JWT checks, Flutter WebDriver and the web release build. Wasm dry-run compilation passed; no Wasm runtime claim follows. The ignored `.local/opening-batch-check.log` ends `All requested local checks passed.`

New two-host checks round-trip metadata/category filtering, race two opening skips at one expected revision with exactly one winner, observe remote skip/restore and future shifts through preview/free-busy, and clean up the synthetic definition. Browser tests save description/categories/comments, move an opening in its explicit named zone, skip/restore/clear timing, retain metadata and existing stale-draft behavior. Definition revision, opening identity and original occurrence identity remain distinct. All existing subject/common-free and event regressions passed.

Relative Markdown links, consecutive ADRs 0001–0059, changed-file scope, candidate credential scanning and unchanged Apache 2.0 LICENSE were checked. The owned hidden development runner was restored and the existing calendar Flutter app hot-restarted successfully through Dart MCP. Organizer/LANGUAGE/ALTREP/extensions/CONTACT, full protocol timestamp/SEQUENCE handling, envelope duration shorthand, occurrence text/future cancellation and wire/client interoperability remain separate work.

## Availability organizer, text parameters and private extensions, 2026-10-21

[ADR 0060](adr/0060-availability-publication-metadata.md) records the maintainer-selected independent organizer approval, annotations on ordinary text and bounded host-validated private X-properties. Focused development commands:

- Root `dart test packages/serverpod_calendar/serverpod_calendar_server/test/unit/availability_publication_values_test.dart packages/serverpod_calendar/serverpod_calendar_server/test/unit/opening_values_test.dart --reporter expanded`: **10 VM tests passed**. Coverage includes legal parameter association, distinct comment positions, language spelling/invalid tags, URI syntax/no-fetch data, orphan rejection, immutable collections, aggregate/private-name limits and legacy JSON defaults, plus affected opening regressions.
- Example-server `dart test test/integration/calendar_test.dart --name 'publication |opening lifecycle|opening mutation|availability metadata is separate|deleting an opening' --reporter expanded`: **8 database/policy tests passed**. The four new tests cover create/removal/retention approval, final-denied/timeout atomicity, independent ordinary rights, trusted actual parent/final proposal, registry context/value/exception rejection, metadata retention through timing changes, stale writes and busy-summary privacy.
- `./tool/generate.ps1` regenerated source-driven models/clients/test tools. Pinned module CLI `serverpod --no-analytics create-migration --tag availability-publication-metadata` and host MCP `create_migration` both reported no schema changes; no table migration was created. Optional nested JSON additions decode legacy absent fields without a read rewrite.

One uninterrupted `./tool/check.ps1` passed stable generation for all module/host pairs, formatting, fatal-info analysis, **459 core VM + 459 core Chrome**, **53 module VM + 17 module Chrome**, **3 Flutter widget** and **76 real database/policy** tests, populated upgrades, host compilation, two independent host/generated-client/JWT checks, the expanded Flutter WebDriver journey and the web release build. Wasm dry-run compilation passed; no Wasm runtime claim follows. The command exited successfully with `All requested local checks passed.`; its detailed output is retained in ignored `.local/publication-batch-check.log`.

New generated-client checks reject a spoofed organizer and unregistered extension, round-trip the approved synthetic organizer, preserved language/ALTREP and configured private label across hosts, and retain the existing competing opening mutation race and remote free/busy checks. The browser edits description language/alternative URI, selects its trusted demo address and adds a configured private label, then verifies those fields survive the single move/skip/restore/clear journey. Existing subject/event/authentication checks also passed.

Relative Markdown links, consecutive ADR numbering through 0060, candidate credential scanning, changed-file scope and unchanged Apache 2.0 LICENSE were checked. This native increment does not establish ICS round trips, source property grouping, individually profiled IANA extensions, CONTACT import, scheduling/feeds or external-client compatibility.

The owned hidden development runner was restored; Serverpod MCP log inspection and hot reload succeeded. Its configured Flutter example was launched through MCP and its DTD connection verified. The first Dart MCP hot restart reported a web-client JSON decoding failure; the subsequent Dart MCP hot reload succeeded. This interactive tooling failure is separate from the passing fresh-browser integration journey.
