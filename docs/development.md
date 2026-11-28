# Local example development

Status: **scoped native calendar/event/availability implementation plus pure iCalendar foundations**. See [the roadmap](roadmap.md) and [validation evidence](scaffold-validation.md) for implemented native increments, and [temporal core](temporal-core.md) for pure date/time/recurrence semantics. The iCalendar package has [generic syntax](icalendar-syntax.md) and [typed temporal value codecs](icalendar-temporal-values.md); a [first non-recurring event/zone adapter](icalendar-event-adapter.md) now adds scoped wire-to-core mapping. Scoped authenticated event/task/availability interchange and native tasks/alarms now extend that baseline. The optional HTTP event-feed profile passed local batch validation under ADR 0116; ADR 0117 adds a bounded pure scheduling-message adapter with selected broader checks passed. Remaining component profiles, scheduling reconciliation/email and release evidence remain pending; see the current roadmap and live notification guide. The example exercises host-owned authentication, generated clients and scoped native journeys. CI orchestration is described in the hosted CI section below; the optional Flutter GUI package follows later.

## Pinned tools and packages

Use Flutter **3.47.7 stable**, bundled Dart **3.13.5**, and Serverpod CLI/runtime/auth/client/test packages **4.0.4**. Pins are recorded in `toolchain.json`, `.flutter-version`, SDK constraints and package manifests; `pubspec.lock` locks the workspace resolution. Docker/Compose are required; the initial local checks used Docker **29.8.2** and Compose **v5.6.0**. Compose images are pinned by digest in the Compose file and toolchain.json. Chrome, a matching ChromeDriver and PowerShell 7 are used by the local scripts. The browser setup helper downloads a matching official Windows ChromeDriver into ignored .local/webdriver when absent or when its build no longer matches installed Chrome; CHROMEDRIVER can point to an existing driver. Transitive dependencies can include prerelease dependencies selected by the stable Serverpod release; the lockfile records actual resolution.

The core pins `timezone` 0.11.2 with generated IANA 2026e data; toolchain.json records source/artifact checksums and the profile. Ordinary calendar dates are [1970-01-01, 2100-01-01), with whole seconds, explicit exclusive endpoints and UTC calculation padding. Unknown offsets still reject; future projections assume pinned rules remain unchanged. See [ADR 0041](adr/0041-whole-second-1970-2100-profile.md) and the [timezone generation/update procedure](timezone-data.md).

The root workspace now contains eleven packages: pure core and iCalendar foundations, calendar server/client, notification server/client, optional feed server/client, example server/client and example Flutter Web. Serverpod module templates require `_server` and `_client` package suffixes. The agreed names identify the logical modules; there is no additional umbrella pub package. All packages are initially non-publishable.

Follow the scoped [example guidance](../example/calendar_example/AGENTS.md) alongside the root guidance. The root `.gitignore` incorporates the example's local agent/MCP, pub override and Serverpod Cloud state exclusions; nested ignore files retain package-specific rules. Keep the root workspace `pubspec.lock` tracked.

## First checkout

Run these commands from the repository root. Install the pinned SDK/CLI if not already available; no global upgrade is performed by these scripts.

```powershell
flutter pub get --enforce-lockfile
dart run tool/setup.dart
```

Setup generates random local secrets in ignored `.local/credentials.json`, `.local/compose.env` and the example server's `config/passwords.yaml`. Subsequent setup retains existing secrets, initializing missing JWT configuration only. Keep these files private and do not commit or paste their contents into issues. Synthetic account addresses are `alice@example.invalid` and `bob@example.invalid`; their generated passwords are the corresponding `demoAlicePassword`/`demoBobPassword` entries for the `development` mode. Test credentials are separate. Auth email is recorded locally, never delivered.

Start the server in one terminal:

```powershell
./tool/start-server.ps1
```

This starts only the local development Compose services, builds the host bundle, applies migrations and idempotently seeds the two synthetic accounts. Seeding is gated to local development/test modes and an explicit process environment flag, with no seed/reset endpoint. The example refuses staging/production modes. It uses Serverpod's built-in JWT token manager and refresh endpoint, as selected by the maintainer, with the pinned SDK defaults (ten-minute access tokens and fourteen-day refresh-token lifetime). Logout clears local credentials and revokes refresh credentials; an already-issued access JWT remains valid until expiry. Current calendar authorization and feed-token revocation remain separate checks; reusable modules do not mandate a host authentication scheme.

Start Flutter Web in another terminal:

```powershell
./tool/start-flutter.ps1
```

Sign in with a local demo account. **Check connection** calls the host and both modules through generated clients. The calendar/event/task screens expose the implemented scoped services; private personal alarm editors create unarmed definitions and require explicit arming. The home screen presents live reminders through the authorized notification stream and fresh recovery. Pause/resume controls the connection without disarming definitions. **Sign out** clears projections and local credentials. Module diagnostics and all domain operations require their respective server-side authorization; sign-in alone does not grant calendar access.

Development API/Insights/web ports are **18080–18082**, and the Flutter development origin is **http://localhost:18083**. PostgreSQL/Redis bind only to loopback at **18090/18091**. Test services use **19090/19091**; test host A uses **18180–18182**, and host B **18280–18282**. Use dedicated test storage, not development data, for tests. Services remain available between local runs; stop them without removing data using:

```powershell
docker compose --env-file .local/compose.env -f example/calendar_example/calendar_example_server/docker-compose.yaml --profile test stop
```

The local server is an API host; Flutter's development server serves the Web app separately. A production web/deployment configuration is deliberately not provided by this milestone.

## Interactive Serverpod MCP development

Stop the compiled development host, then run from the repository root:

```powershell
./tool/start-server.ps1 -Interactive
```

This retains the pinned tool checks, local setup, Compose services and synthetic account seeding, then runs `serverpod start` in watch mode. It disables the TUI, automatic Docker management and automatic Flutter launch: the script already configures Compose, and Flutter can be started separately or through MCP. Keep the runner alive while using MCP. Stop the development runner before the complete check script rebuilds native assets.

The MCP client must launch `serverpod --no-analytics mcp-server --server-dir <absolute-example-server-directory>`. In this monorepo, always specify `example/calendar_example/calendar_example_server` explicitly rather than relying on server auto-detection. The bridge connects to the runner's local `.dart_tool/serverpod/mcp.sock`; starting the compiled bundle alone does not expose that runner connection.

For Codex, configure `[mcp_servers.serverpod]` in ignored root `.codex/config.toml`. The verified local Windows entry uses `command = "cmd.exe"`, arguments `/d`, `/c`, `serverpod`, `--no-analytics`, `mcp-server`, `--server-dir`, followed by the absolute example-server path, an explicit repository `cwd`, and `startup_timeout_sec = 60`. The companion `dart_mcp` entry uses `cmd.exe /d /c dart mcp-server --force-roots-fallback`. Preserve any existing local settings. `codex mcp list` verifies registration, not connection; verify initialization, tool discovery and a read-only log call separately. Restart the MCP client after adding configuration so it can load the new servers.

See the official [Serverpod MCP reference](https://docs.serverpod.dev/concepts/cli/commands/mcp-server) and [Codex MCP configuration](https://developers.openai.com/codex/mcp). Local machine paths/configuration remain ignored; neither credentials nor a global MCP configuration is required.

## Generation and local checks

After editing endpoints or `.spy.yaml` source models:

```powershell
./tool/generate.ps1
```

Never hand-edit generated protocol Dart or test tools. Calendar domain table models require the [model review gates](models.md) before implementation. Serverpod-created migrations are retained for the scaffold and authentication schema.

### Feature batches and focused iteration

During a feature, run its VM tests plus directly affected regressions. For example, from `packages/serverpod_calendar_core`:

```powershell
dart test test/date_event_exception_test.dart test/date_event_exception_set_test.dart test/date_event_series_test.dart --reporter expanded
```

After finishing the agreed feature group, run formatting, workspace analysis and the complete core suite on VM and Chrome. Add relevant server/database/generated-client/Flutter checks when those surfaces change. Record commands actually run and checks deferred; focused success is not full-suite evidence. Commit and push only after the batch is complete, using one commit for the group. Run the full repository sequence before marking the PR ready.

### Complete local sequence

Run the complete local check sequence:

```powershell
./tool/check.ps1
```

The script verifies tool pins and locked dependency resolution, retains local credentials, regenerates all three server/client pairs and checks byte-for-byte generated-output stability, checks formatting and analysis, runs the pure Dart core and metadata profile tests on VM/Chrome plus Flutter sign-in, explicit metadata-copy and supplemental-editor widget tests, resets only the dedicated synthetic test database, runs calendar database/policy tests and the populated metadata-schema upgrade check, builds a host bundle, runs two independent host processes against shared test storage, runs real-client JWT login/refresh/rotation/logout and calendar CRUD/race checks and Flutter WebDriver calendar journeys, and builds the Flutter Web release output. `-SkipBrowser` skips the core/module Chrome tests and connected Chrome journey; the widget test and Web build still run. The same complete entry point runs in [GitHub Actions](continuous-integration.md) for runtime changes; Markdown-only changes use the separate documentation gate.

The test reset is intentionally destructive only to the dedicated `calendar_example_test` Compose database. Run no other test hosts against that database while the checks run. The harness owns its test processes and stops them on success/failure; logs stay under ignored `.local/`. Development storage is not reset. A standalone reset is available with `./tool/reset-test.ps1` after local setup.

For a targeted rerun after building the host and starting the test services:

```powershell
./tool/build-host.ps1
dart run tool/host_smoke.dart --flutter
```

On Windows, the harness runs two copies of a single compiled host bundle. Launching two `dart run` commands can conflict when the second command tries to replace the native Argon2 DLL loaded by the first. The bundle avoids that tooling conflict; it does not supply distributed correctness. Do not rebuild a bundle while its executable is running. The example can also be used with Serverpod's interactive development tooling, but the scripts above are the repeatable local acceptance workflow.

For interactive work, prefer Serverpod MCP operations when exposed and connected. On 2026-10-19, the local configuration and watch runner were verified using real STDIO initialization, discovery of all nine Serverpod tools and a successful read-only `tail_server_logs` call. The companion Dart MCP handshake/tool discovery also passed. The existing chat's tool catalog still did not expose these newly configured tools; local transport verification is distinct from loading them into an already running client. See [validation evidence](scaffold-validation.md).

Full cross-instance calendar/feed/scheduling/worker recovery tests arrive with those features under [ADR 0018](adr/0018-automated-example-and-multiple-instances.md). Connected streaming/replay contracts remain future work under [ADR 0020](adr/0020-notification-delivery-scope.md); this authentication scaffold does not claim durable notification delivery or mobile background delivery.

The browser journey follows Flutter's documented integration_test/WebDriver workflow; the deprecated Chrome widget-test backend stalled before executing tests in this environment. The successful runner and exact commands are recorded in the validation evidence.

See [scaffolding choices](scaffolding-plan.md), [scaffold implementation record](adr/0021-initial-workspace-scaffold.md) and [validation evidence](scaffold-validation.md).

For focused calendar work, run `dart test test/unit` in `packages/serverpod_calendar/serverpod_calendar_server`, or `dart test test/integration/calendar_test.dart` in the example server after starting test storage. Database integration tests use ephemeral databases but the test-configured service ports; run them sequentially with the two-host harness to avoid port conflicts. The full root script already does this. See [calendar host integration and API limits](calendar-crud-implementation.md).

The metadata increment adds pure profile tests in `test/unit/calendar_presentation_test.dart` and scoped real database cases in `calendar_test.dart`. Use `--name` to focus the database cases while developing; the full batch check runs the complete file and all Flutter widget tests.

`python tool/metadata_upgrade_smoke.py` checks the generated pre-metadata-to-text-metadata, text-to-supplemental-metadata and supplemental-to-protocol-identity migrations on a temporary synthetic database using the existing dedicated Compose test service. It preserves fixture rows/revisions and drops only the database it creates. It runs automatically in the complete local sequence.

Native event DTO adapter tests in `test/unit/event_values_test.dart` are VM-only because they import server-generated models. The core remains tested on VM/Chrome; Flutter Web exercises generated event clients. Focus event database cases with `--name "event "`; complete checks include event lifecycle/cursors and two-host write/parent-delete races. The populated upgrade helper also applies the native event schema.

The root batch check also runs the dedicated `serverpod_calendar_icalendar` syntax suite on VM and Chrome under [ADR 0062](adr/0062-bounded-icalendar-syntax-foundations.md). Focused development can run `dart test packages/serverpod_calendar_icalendar/test/icalendar_syntax_test.dart` from the root. This does not imply calendar-profile validation or domain import/export.


## Pre-beta database compatibility

For attendee replies under accepted ADR 0131, run `dart test test/integration/scheduling_replies_test.dart` from the example server against test storage. Actual competing-process and before/after-commit loss checks use `dart run tool/scheduling_work_smoke.dart --replies` from the root. After building the current host bundle, `dart run tool/host_smoke.dart --flutter --replies --browser-only` runs only the focused reply review journey; it explicitly skips the generated-client/worker prerequisites. The full root check retains all suites and the complete browser journey.

Breaking APIs/schema and fresh-database requirements are authorized before beta. A feature may document a reset instead of preserving unpublished compatibility. Use only the identified local development or isolated synthetic test database, and record which reset is required. Existing historical upgrade checks remain evidence of their own batches. ADR 0073 import uses the existing schema and requires no reset.

ADR 0076 adds an additive nullable availability baseline column; no reset is required. Existing/native-created definitions remain ineligible for replacement without a recorded source baseline. Focus replacement checks with `dart test test/integration/calendar_test.dart --plain-name "availability replacement"` from the example server. The populated upgrade helper also verifies old availability content is unchanged and baselines remain null.

VFREEBUSY export under ADR 0077 requires no schema/reset. Focus with `dart test packages/serverpod_calendar_icalendar/test/icalendar_free_busy_output_test.dart` at the root and `dart test test/integration/calendar_test.dart --plain-name "free busy export"` in the example server. Full checks include generated-client calls across two hosts and a Flutter snapshot export journey.

## Module watch-cache recovery, observed with Serverpod 4.0.4

During the task-content increment, connected MCP migration creation reported no changes before the example runner had refreshed the module definition. The pinned module CLI and example CLI generated the expected nullable-column migrations; MCP applied the example migration. The watch runner then reported the new column missing even though a read-only database catalog check confirmed it existed. Restarting that runner alone retained the stale view.

A fresh test process passed against the generated schema. With the owned interactive runner stopped, moving only `example/calendar_example/calendar_example_server/.dart_tool/serverpod/server.dill` and `server.dill.incremental.dill` to ignored `.local/` backups forced a fresh watch compilation and restored startup. This is generated compiler-cache recovery, not a database repair. Do not reset development data or generate a repair migration merely from this symptom; compare actual schema and generated definitions first. Stop the owned runner before moving its cache files, verify paths stay inside this workspace, and keep unrelated IDE/app processes intact. Root checks use fresh test/build processes and remain the validation authority.

Use connected MCP for supported live operations. If its model view is stale after reusable-module changes, generate the module migration with the pinned CLI in `packages/serverpod_calendar/serverpod_calendar_server`, then the example migration in its server directory, and verify fresh/upgrade behavior through the root workflow. Generated protocols/migration metadata must still come from the tools.

### Focused task replacement browser journey

After the host bundle is built and isolated test storage is ready, `dart run tool/host_smoke.dart --flutter --task-replacement` runs the real two-host/client/JWT checks and only `integration_test/task_replace_smoke_test.dart` for Flutter. The default `--flutter` retains the complete connected journey. Reset only the synthetic test database before independent reruns if a failed journey left test objects. The multiline typing step explicitly registers the supported Flutter test keyboard so simulated input does not compete with the real browser IME; unregister it at teardown. This is automated input evidence, not physical keyboard/clipboard interoperability.

If an owned web-server preview serves the page but its debug proxy returns HTML where metadata JSON was expected, inspect Serverpod/Dart MCP logs rather than assuming a valid app VM. The task replacement batch verified the fallback `flutter run --no-pub -d chrome --web-hostname=localhost --web-port=18083 --web-browser-flag=--headless=new --web-browser-flag=--disable-gpu` after stopping the owned failed Flutter process. Connect Dart MCP to that Flutter DTD and target its app URI; Serverpod MCP remains available for the separately running server. Never stop unrelated IDE apps or reset development storage to fix a preview.

For the analogous focused event source editor journey, use `dart run tool/host_smoke.dart --flutter --event-replacement` with a current host bundle and dedicated synthetic test storage. It selects `integration_test/event_replace_smoke_test.dart`; the default complete journey remains unchanged.

## Focused event content browser checks

After an interrupted browser journey, run `./tool/reset-test.ps1` before rerunning the real-host harness; it resets only the dedicated synthetic test database. Interrupted Flutter fixtures may otherwise remain and invalidate clean-list assertions. Never reset the development database for a test retry.

`dart run tool/host_smoke.dart --flutter --event-content` runs the existing two-host/generated-client checks followed by the focused event occurrence-content editor journey. The full `--flutter` target retains the complete journey, including selected content and timing edits. Tests use the supported simulated keyboard for dialog/source text and scroll lazy preview rows explicitly; this is not physical keyboard or clipboard compatibility evidence.

The full Flutter journey has a six-minute outer process guard, including compilation and shutdown; focused targets retain four minutes. Individual widget/action waits remain bounded. The larger full guard follows a run that reported passing tests/application completion but exceeded the previous four-minute shutdown deadline.


## Alarm worker process check

`dart run tool/alarm_work_smoke.dart` starts two real isolated Serverpod test hosts on ports 18380–18382 and 18480–18482. Each verifies `calendar_example_test` before applying generated migrations. The harness creates only synthetic namespaced rows, races committed leases, kills the winning owned process, waits for its short test lease, and verifies takeover/stale fencing before cleanup. Test-control files/logs stay under ignored `.local/`; file communication is only harness control, never work ownership. Root `tool/check.ps1` runs this once per broad batch after database checks. Keep these ports free and do not run competing local check harnesses against the same synthetic database.


## Reusable live notification increment, 2026-10-25

[ADR 0114](adr/0114-reusable-notification-delivery.md) approves the generic three-table storage/defaults and live-reminder profile. The [delivery guide](reusable-notification-delivery.md) describes durable idempotent acceptance, fenced retry/publication, fresh authorized source projection and the example Redis/Flutter streaming path. This supersedes earlier unconnected-delivery/scaffold-only wording for this scoped increment; the full local batch checks passed, with actual evidence recorded in the validation guide. Imported alarms remain unarmed; provider delivery, adoption and the remaining first-release requirements stay separate.

## Focused event-feed checks

The optional feed pair and example integration are described in [the feed guide](http-event-feeds.md). After `./tool/build-host.ps1`, run `dart run tool/host_smoke.dart --feeds` for only the two-host feed/JWT flow, or add `--flutter` for its focused browser target. The full root check includes all feed tests and the full journey. Stop owned interactive runners before native bundle builds on Windows. Wrap the host entry point in the documented feed logging guard; the test transport-fault fixture is enabled only by the owned test harness.


## Synthetic organizer publication

The example installs the optional [native organizer runtime](native-organizer-scheduling.md). Create a new non-recurring event, open **Meeting invitations**, enter synthetic `mailto:...@example.invalid` recipients and use **Save and notify**. Ordinary saves remain local. Existing migrated events have unknown origin and cannot publish; create fresh synthetic events without resetting the development database. The example transport writes ignored `.local/scheduling-mail/` fixtures and sends no email.

`tool/check.ps1` includes the scheduling database suite, populated-schema upgrade check, generated-client cross-host publication races, `tool/scheduling_work_smoke.dart` independent-worker/loss checks and the Flutter publication/local-dirty journey. The scheduling worker probe uses only isolated test storage and kills only its owned fixture processes. Trusted hosts schedule `CalendarModule.runSchedulingMaintenance(session)`; the example invokes it from recurring maintenance every 15 seconds. No client worker endpoint or process-local lock is required.


The accepted cancellation increment adds **Cancel and notify** for existing non-recurring organizer bindings. It cancels using the published snapshot and retains saved local fields. **Reopen and notify** explicitly publishes a newer REQUEST; ordinary local lifecycle edits still send nothing. The generated cancellation-request/status DTOs require `tool/generate.ps1` but add no table migration. The scheduling worker smoke now covers both REQUEST and CANCEL, including actual holder loss before and after synthetic acceptance. The full connected Flutter journey covers cancellation, draft retention and explicit reopening.


The accepted recurring-master increment publishes saved RRULE/RDATE/EXDATE/PERIOD master patterns through the same meeting screen and generated APIs. Save recurring mode before the first publication; bound mode conversions remain blocked. Native occurrence edits stay available, but the meeting screen explains and disables a new REQUEST while saved exceptions exist. Whole-series Cancel and notify preserves them. The worker loss probes, generated-client races and connected Flutter journey now use recurring masters; the browser also checks the exception-publication limit. No new model generation or migration is required by this increment.


### Focused scheduling browser journey

With the isolated test services running and the example host bundle rebuilt, run `dart run tool/host_smoke.dart --flutter --scheduling` for the organizer scheduling screen alone. The harness still exercises its shared two-host generated-client prerequisites; only the Flutter target is narrowed. For UI-only iterations after the server prerequisites passed, add `--browser-only` to skip the repeated generated-client and worker-loss journeys; the harness reports that skip explicitly and still starts isolated test hosts. The normal `--flutter` invocation retains the complete connected journey, with an eight-minute total budget; focused browser targets keep four minutes and bounded per-action waits. Use focused database cases during edits and the broader root checks at the batch boundary.

### Focused scheduling reply integration

After building the owned host bundle with `./tool/build-host.ps1`, use `dart run tool/host_smoke.dart --replies --replies-only --flutter` for reply clients/JWT checks on two hosts plus the focused master/instance Flutter journey. This explicitly skips unrelated domain/feed/notification and producer-loss journeys; the default full check retains them. `dart run tool/scheduling_work_smoke.dart --replies --instances` exercises actual instance-reply races and loss before/after commit. `python tool/metadata_upgrade_smoke.py --instance-replies-only` checks populated master defaults/identity and target uniqueness in a process-owned test database. Never reset development storage.

For the bounded event descriptive editor after building the owned host bundle, `dart run tool/host_smoke.dart --flutter --descriptive --browser-only` runs the focused real-host Flutter journey and explicitly skips client/worker prerequisites. `--flutter --descriptive --feeds` includes the two-host generated-client/feed prerequisite sequence and metadata race/ETag checks. The default full batch retains all domain, worker and browser checks.

After building the owned host bundle, `dart run tool/host_smoke.dart --flutter --text-metadata --feeds` exercises two-host metadata/feed races plus the focused event/task editors. `--flutter --text-metadata --browser-only` explicitly skips already-passed client/worker prerequisites. The default full root checks retain all feature journeys.

After rebuilding the owned host bundle, `dart run tool/host_smoke.dart --flutter --categories --feeds` exercises cross-host category continuation/write races and the focused event/task Apply/Clear journey. For browser-only iterations after client checks pass, use `--flutter --categories --browser-only`; this explicitly skips those prerequisites. Focus database work with `dart test --concurrency=1 test/integration/item_category_search_test.dart` from the example server. Full root checks retain these new cases and the complete connected Flutter journey.

The complete generated-client prerequisite sequence has a bounded four-minute budget after adding category continuation/write-race coverage; reply-only checks retain three minutes. Per-request/worker waits remain independently bounded. Browser targets retain their existing focused/full budgets.

For invitation feature work, run `dart test --concurrency=1 test/integration/invitation_test.dart` in the example server. `python tool/metadata_upgrade_smoke.py --invitations-only` owns an isolated upgrade database; `dart run tool/invitation_work_smoke.dart` runs actual independent hosts and before/after-commit loss. After `./tool/build-host.ps1`, `dart run tool/host_smoke.dart --flutter --invitations --invitations-only` narrows clients/browser to the new queue plus JWT checks; unrelated prerequisites are explicitly skipped. `--flutter --invitations --browser-only` skips already-passed client prerequisites. The default root checks retain all features and the complete browser journey. Focused reply/invitation clients retain a three-minute budget; the full client sequence has four minutes. Never reset development storage.

The invitation probe also races explicit adoption and kills its owner before/after the event/link/review transaction commits. `python tool/metadata_upgrade_smoke.py --adoption-only` checks populated invitation-to-adoption upgrades on a process-owned synthetic database. The focused browser target is `dart run tool/host_smoke.dart --invitations-only --invitations --flutter`; the first flag narrows generated-client work and the second selects its Flutter journey. Complete root checks retain all features.

SDK integration-test groups use ephemeral databases by default, but still bind configured HTTP ports. Database isolation alone does not make them independent of a running host/worker/browser harness. Keep both storage and ports separate, or run the root sequence serially; do not overlap a focused withServerpod suite with final smoke-host startup on 18180.

The invitation process probe now also races explicit updates and kills their owner before/after commit. `python tool/metadata_upgrade_smoke.py --applications-only` verifies populated checkpoint upgrades with immutable creation receipts and no invented history. Use `dart run tool/host_smoke.dart --invitations-only --invitations --flutter` for focused JWT/client/Flutter update work. Run SDK integration groups serially with HTTP harnesses because ephemeral databases do not isolate the configured API ports.


For host MIME ingress work, run `dart test test/unit/imip_ingress_test.dart` and `dart test --concurrency=1 test/integration/imip_ingress_test.dart` in the example server. The complete root check includes these cases. Existing invitation/reply process probes and generated-client/Flutter selectors now exercise MIME wrappers without opening a raw-mail client endpoint; use those focused selectors before the broader batch check.


If Dart package-exploration MCP reports no registered roots, register this workspace through its roots tool before retrying read_package_uris/rip_grep_packages. The searchDir argument is a directory; select a file with ripgrep -g instead. This package-access registration is separate from the DTD/VM connection used for runtime reloads.

## Private attendee responses

See [the scoped guide](private-attendee-responses.md). With isolated test services available, run the example server's `dart test test/integration/invitation_responses_test.dart test/unit/invitation_response_mime_test.dart` for focused response work. `dart run tool/invitation_work_smoke.dart` additionally exercises independent hosts and actual response-worker loss before/after synthetic acceptance; fixture files under ignored `.local/` provide test control/evidence only.

After rebuilding the owned example host bundle, `dart run tool/host_smoke.dart --invitations-only --flutter --invitations` exercises generated-client invitation/response behavior and the focused Flutter journey. The normal root check includes these response regressions, populated upgrade checks and the full connected journey. Keep configured host ports exclusive to each harness. No test sends real mail or resets development storage.

## Calendar-wide occurrence queries

See [the API/authorization guide](calendar-occurrence-queries.md). During feature work, run `dart test test/unit/event_occurrence_query_test.dart` in the calendar server module and `dart test test/integration/occurrence_queries_test.dart` in the example server. Core DATE/snapshot work regressions are in `test/shared_date_event_work_test.dart`, including Chrome. With isolated test storage available, `python tool/metadata_upgrade_smoke.py --occurrence-cursors-only` verifies the nullable-column upgrade on populated ordinary cursor rows in its own database.

After stopping owned native runners and rebuilding with `./tool/build-host.ps1`, `dart run tool/host_smoke.dart --occurrences-only --flutter --occurrences` runs focused two-host clients and the occurrence view. It explicitly skips unrelated feature/recovery and JWT-refresh journeys. The normal root check includes the new database suite, full populated upgrades, generated clients and connected Flutter flow. Keep SDK integration groups and the owned smoke hosts serial on their configured ports. No development reset or real transport is involved.

## Recurring-master invitation checks

Accepted ADR 0148 extends the existing invitation client/Flutter journeys to recurring masters. During development use `dart test test/integration/recurring_invitations_test.dart` from the example server; `python tool/metadata_upgrade_smoke.py --recurring-invitations-only` from the root verifies populated upgrades. `dart run tool/invitation_work_smoke.dart --recurring` runs the independent recurring invitation/response/adoption/application/cancellation recovery group. Run recovery/host checks sequentially against owned test ports and storage. Rebuild with the owned runner stopped, then `dart run tool/host_smoke.dart --invitations-only --flutter --invitations` exercises focused generated-client and Flutter flows. Root `./tool/check.ps1` includes both original and recurring recovery profiles and the complete batch suites. See [the supported workflow](recurring-master-invitations.md).

## Hosted CI

[Repository checks](continuous-integration.md) uses the same complete local-check entry point on GitHub Actions. Markdown-only changes run documentation checks; runtime changes exercise isolated storage, two actual hosts, process-loss recovery and Flutter Web. Local focused development remains unchanged. `python tool/check_docs.py` checks relative documentation targets and consecutive ADR filenames without requiring SDK installation.


## Focused single-instance invitation review checks

Accepted [ADR 0149](adr/0149-trusted-single-instance-invitation-review.md) adds [known-series occurrence notices](single-instance-invitation-review.md). From the example server, run `dart test --concurrency=1 test/integration/instance_invitations_test.dart` against isolated synthetic test storage. Test files sharing real test-server ports must run sequentially. `python tool/metadata_upgrade_smoke.py --instance-invitations-only` checks populated target/index upgrades; `dart run tool/invitation_work_smoke.dart --instances` runs actual competing hosts and before/after-commit loss recovery through synthetic MIME.

After a current host build, `dart run tool/host_smoke.dart --invitations-only --flutter --invitations` includes generated-client instance review and the Flutter original/source/cancellation/dismiss journey alongside existing master workflows. Full root checks retain all implemented feature and recovery profiles. Only dedicated synthetic test storage may be reset; development data is preserved. Instance calendar application and responses remain unavailable.
