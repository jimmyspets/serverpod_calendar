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
| `dart run tool/setup.dart` | Local secrets created; subsequent runs retain existing secret values and initialize missing local session configuration |
| `pwsh -NoProfile -File tool/check.ps1` | **Passed completely**, including every step below |
| Generation via `tool/generate.ps1` | All three server/client pairs regenerated; protocol/test-tool file sets and SHA-256 hashes unchanged |
| Formatting check on authored Dart sources | 18 files checked; zero changes required. Generator-owned code is checked by regeneration, not manually reformatted |
| `dart analyze --fatal-infos` | No issues found |
| `flutter test --no-pub test/sign_in_test.dart`, from example Flutter package | Passed: empty form validates required input and does not expose the authenticated connection UI |
| `tool/reset-test.ps1` | Only dedicated Compose test database dropped/recreated; fresh auth/framework migrations applied by the first test host |
| Host bundle via `dart build cli --target bin/main.dart --output ...`, from example server | Native bundle built successfully; both test processes use the same build |
| `dart run tool/host_smoke.dart --flutter` | Both independent hosts ready; actual generated-client and browser checks passed; owned test processes cleaned up |
| `flutter build web --no-pub`, from example Flutter package | Release Web build passed; compiler's WASM dry run also passed, without a separate WASM runtime compatibility claim |
| `pwsh -NoProfile -File tool/start-server.ps1` | Development services healthy, development migrations applied and synthetic accounts seeded |
| `dart run tool/client_smoke.dart --development` | Normal generated-client auth/module/sign-out smoke passed against the documented development host |
| `pwsh -NoProfile -File tool/start-flutter.ps1` | Passed: Chrome debug service connected and app started on http://localhost:18083 |

The two-host test uses distinct processes/server IDs and ports 18180/18280, sharing only dedicated test PostgreSQL/Redis storage. It verifies anonymous host/module rejection, ordinary email/password login, the same caller identity through host/calendar/notification generated clients on both instances, and committed session revocation on A being enforced on B. Sequential idempotent seeding on both hosts avoids duplicate account creation. It does not test domain edits, feed revocation, competing workers, crashes or every NFR-14 scenario yet.

The Flutter WebDriver integration test drives the actual example UI through sign-in, connection check across the host and both modules, visible result and sign-out using the real host APIs. It uses the Flutter SDK integration_test driver and a matching local ChromeDriver. No mock backend replaces the example module/client/migrations.

## Implementation observations and choices

The template JWT configuration kept an access token usable on another host after refresh-token sign-out. This is [Serverpod's documented JWT behavior](https://docs.serverpod.dev/concepts/authentication/token-managers/managing-tokens): existing access tokens remain valid until expiry. Immediate rejection was an added test assumption, not a maintainer-selected requirement or a JWT defect. The current example uses built-in database-backed sessions and passes that additional cross-host revocation check; its token-manager choice remains under review in [ADR 0021](adr/0021-initial-workspace-scaffold.md).

Starting two Windows `dart run` hosts collided when rebuilding a loaded native Argon2 DLL; the final harness builds once and runs two bundle processes. The deprecated Chrome widget-test backend stalled before test execution; the final browser test uses Flutter's documented integration_test/WebDriver runner and passed.

The template emitted a macOS entitlement-update failure during creation on Windows. Native target folders were removed for the selected Web-only initial scaffold; the final Web builds/tests passed. Native target generation and mobile delivery remain later/external work. SDK-generated Windows CPU/memory metric warnings do not provide performance evidence.

## Review and limits

Relative documentation links/anchors, ADR numbering, changed-file list, unchanged Apache 2.0 LICENSE and generated-secret exclusions are checked separately before commit. Generated local secrets were compared against all tracked/candidate text files without printing their values; no matches were found. Password/config/build artifacts remain ignored. Dependency LICENSE observations are in ADR 0021; no blanket dependency license compatibility is claimed.

The current checks do not prove full calendar/RFC support, external feed-client compatibility, durable notification delivery, OS background notifications, CI readiness or complete production multi-instance behavior. Those remain roadmap acceptance work. See [local commands](development.md), [scaffolding choices](scaffolding-plan.md) and [ADR 0021](adr/0021-initial-workspace-scaffold.md).
