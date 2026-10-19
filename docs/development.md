# Local example development

Status: **initial scaffold**. Calendar semantics, iCalendar interchange, tasks, feeds, availability, scheduling and alarm/notification delivery are not implemented. The example verifies normal host-owned authentication and generated-client wiring for both reusable modules. CI configuration and the optional Flutter GUI package follow later.

## Pinned tools and packages

Use Flutter **3.47.7 stable**, bundled Dart **3.13.5**, and Serverpod CLI/runtime/auth/client/test packages **4.0.4**. Pins are recorded in `toolchain.json`, `.flutter-version`, SDK constraints and package manifests; `pubspec.lock` locks the workspace resolution. Docker/Compose are required; the initial local checks used Docker **29.8.2** and Compose **v5.6.0**. Compose images are pinned by digest in the Compose file and toolchain.json. Chrome, a matching ChromeDriver and PowerShell 7 are used by the local scripts. The browser setup helper downloads a matching official Windows ChromeDriver into ignored .local/webdriver when absent; CHROMEDRIVER can point to an existing driver. Transitive dependencies can include prerelease dependencies selected by the stable Serverpod release; the lockfile records actual resolution.

The root workspace contains nine packages: pure core and iCalendar foundations, calendar server/client, notification server/client, example server/client and example Flutter Web. Serverpod module templates require `_server` and `_client` package suffixes. The agreed names identify the logical modules; there is no additional umbrella pub package. All packages are initially non-publishable.

## First checkout

Run these commands from the repository root. Install the pinned SDK/CLI if not already available; no global upgrade is performed by these scripts.

```powershell
flutter pub get --enforce-lockfile
dart run tool/setup.dart
```

Setup generates random local secrets in ignored `.local/credentials.json`, `.local/compose.env` and the example server's `config/passwords.yaml`. Subsequent setup retains existing secrets, initializing missing session configuration only. Keep these files private and do not commit or paste their contents into issues. Synthetic account addresses are `alice@example.invalid` and `bob@example.invalid`; their generated passwords are the corresponding `demoAlicePassword`/`demoBobPassword` entries for the `development` mode. Test credentials are separate. Auth email is recorded locally, never delivered.

Start the server in one terminal:

```powershell
./tool/start-server.ps1
```

This starts only the local development Compose services, builds the host bundle, applies migrations and idempotently seeds the two synthetic accounts. Seeding is gated to local development/test modes and an explicit process environment flag, with no seed/reset endpoint. The example refuses staging/production modes. It uses Serverpod's database-backed sessions with an eight-hour absolute and one-hour inactivity limit; this is an example host choice, not a mandatory module auth scheme.

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

## Generation and local checks

After editing endpoints or `.spy.yaml` source models:

```powershell
./tool/generate.ps1
```

Never hand-edit generated protocol Dart or test tools. Calendar domain table models require the [model review gates](models.md) before implementation. Serverpod-created migrations are retained for the scaffold and authentication schema.

Run the complete local check sequence:

```powershell
./tool/check.ps1
```

The script verifies tool pins and locked dependency resolution, retains local credentials, regenerates all three server/client pairs and checks byte-for-byte generated-output stability, checks formatting and analysis, runs the sign-in form test, resets only the dedicated synthetic test database, builds a host bundle, runs two independent host processes against shared test storage, runs real-client and Flutter WebDriver integration journeys, and builds the Flutter Web release output. `-SkipBrowser` skips only the connected Chrome journey; the widget test and Web build still run. CI has not been configured.

The test reset is intentionally destructive only to the dedicated `calendar_example_test` Compose database. Run no other test hosts against that database while the checks run. The harness owns its test processes and stops them on success/failure; logs stay under ignored `.local/`. Development storage is not reset. A standalone reset is available with `./tool/reset-test.ps1` after local setup.

For a targeted rerun after building the host and starting the test services:

```powershell
./tool/build-host.ps1
dart run tool/host_smoke.dart --flutter
```

On Windows, the harness runs two copies of a single compiled host bundle. Launching two `dart run` commands can conflict when the second command tries to replace the native Argon2 DLL loaded by the first. The bundle avoids that tooling conflict; it does not supply distributed correctness. Do not rebuild a bundle while its executable is running. The example can also be used with Serverpod's interactive development tooling, but the scripts above are the repeatable local acceptance workflow.

Full cross-instance calendar/feed/scheduling/worker recovery tests arrive with those features under [ADR 0018](adr/0018-automated-example-and-multiple-instances.md). Connected streaming/replay contracts remain future work under [ADR 0020](adr/0020-notification-delivery-scope.md); this authentication scaffold does not claim durable notification delivery or mobile background delivery.

The browser journey follows Flutter's documented integration_test/WebDriver workflow; the deprecated Chrome widget-test backend stalled before executing tests in this environment. The successful runner and exact commands are recorded in the validation evidence.

See [scaffolding choices](scaffolding-plan.md), [scaffold implementation record](adr/0021-initial-workspace-scaffold.md) and [validation evidence](scaffold-validation.md).
