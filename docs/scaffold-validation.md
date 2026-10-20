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
