# Local example development

Status: **scoped native calendar/event/availability implementation plus pure iCalendar foundations**. See [the roadmap](roadmap.md) and [validation evidence](scaffold-validation.md) for implemented native increments, and [temporal core](temporal-core.md) for pure date/time/recurrence semantics. The iCalendar package has [generic syntax](icalendar-syntax.md) and [typed temporal value codecs](icalendar-temporal-values.md); a [first non-recurring event/zone adapter](icalendar-event-adapter.md) now adds scoped wire-to-core mapping. Complete component coverage, authorized database import/export, tasks, HTTP feeds, scheduling and alarm/notification delivery remain pending. The example exercises host-owned authentication, generated clients and scoped native journeys. CI configuration and the optional Flutter GUI package follow later.

## Pinned tools and packages

Use Flutter **3.47.7 stable**, bundled Dart **3.13.5**, and Serverpod CLI/runtime/auth/client/test packages **4.0.4**. Pins are recorded in `toolchain.json`, `.flutter-version`, SDK constraints and package manifests; `pubspec.lock` locks the workspace resolution. Docker/Compose are required; the initial local checks used Docker **29.8.2** and Compose **v5.6.0**. Compose images are pinned by digest in the Compose file and toolchain.json. Chrome, a matching ChromeDriver and PowerShell 7 are used by the local scripts. The browser setup helper downloads a matching official Windows ChromeDriver into ignored .local/webdriver when absent; CHROMEDRIVER can point to an existing driver. Transitive dependencies can include prerelease dependencies selected by the stable Serverpod release; the lockfile records actual resolution.

The core pins `timezone` 0.11.2 with generated IANA 2026e data; toolchain.json records source/artifact checksums and the profile. Ordinary calendar dates are [1970-01-01, 2100-01-01), with whole seconds, explicit exclusive endpoints and UTC calculation padding. Unknown offsets still reject; future projections assume pinned rules remain unchanged. See [ADR 0041](adr/0041-whole-second-1970-2100-profile.md) and the [timezone generation/update procedure](timezone-data.md).

The root workspace contains nine packages: pure core and iCalendar foundations, calendar server/client, notification server/client, example server/client and example Flutter Web. Serverpod module templates require `_server` and `_client` package suffixes. The agreed names identify the logical modules; there is no additional umbrella pub package. All packages are initially non-publishable.

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

Sign in with a local demo account, select **Check connection**, then **Sign out**. The check calls the real host and both modules through generated clients. There is no calendar UI or notification delivery demo yet. Module diagnostic endpoints require authentication and return only the current caller's identifier. Future calendar operations still require host policy checks beyond being signed in.

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

The script verifies tool pins and locked dependency resolution, retains local credentials, regenerates all three server/client pairs and checks byte-for-byte generated-output stability, checks formatting and analysis, runs the pure Dart core and metadata profile tests on VM/Chrome plus Flutter sign-in, explicit metadata-copy and supplemental-editor widget tests, resets only the dedicated synthetic test database, runs calendar database/policy tests and the populated metadata-schema upgrade check, builds a host bundle, runs two independent host processes against shared test storage, runs real-client JWT login/refresh/rotation/logout and calendar CRUD/race checks and Flutter WebDriver calendar journeys, and builds the Flutter Web release output. `-SkipBrowser` skips the core/module Chrome tests and connected Chrome journey; the widget test and Web build still run. CI has not been configured.

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
