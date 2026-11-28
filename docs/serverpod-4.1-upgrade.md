# Serverpod 4.1 dependency alignment

## Serverpod 4.1.0

The maintainer requested this maintenance batch after ADR 0168. It pinned the CLI, runtime, generated clients, Flutter integration, authentication and test packages to Serverpod 4.1.0 with Flutter 3.47.7 and Dart 3.13.5. Generation used CLI 4.1.0.

The [official changelog](https://pub.dev/packages/serverpod/changelog) describes generated typed copyWith sentinels, reactive ORM helpers and runtime/tooling fixes. Regenerated output is reviewed as generator output, never patched by hand. Generated watch helpers do not establish a supported calendar subscription API or PostgreSQL watch capability. Existing authenticated query/streaming contracts remain authoritative.

Existing JWT authentication, email/password example configuration, opaque host authorization, synthetic transports and calendar timing policies remain the application profile. The dependency upgrade alone does not select passwordless OTP, offline synchronization, new runner workflows or real mail. The validation record retains the 4.0.4 results.

Use the root generation/check scripts in [local development](development.md). Keep CLI and SDK pins aligned, resolve the root workspace, regenerate all modules and the example, inspect generated/schema changes and verify fresh plus existing synthetic storage before readiness. Never apply test resets to development storage.

Actual local and exact-commit hosted results are recorded in [validation](scaffold-validation.md). Full hosted repository checks remain required before marking the upgrade ready.

The generated example-host migration adds only the upstream serverpod_auth_idp_email_account_otp_login_request table and advances module version markers. The generated feed-module migration refreshes its imported calendar schema snapshot with previously approved scheduling/invitation tables and fields. Calendar and notification module migration checks report no changes. No domain model source was edited and no generated migration metadata was hand-edited.

The migration smoke helper now snapshots all prior populated tables, applies the host SDK migration, checks exact row preservation and verifies empty new OTP request storage. The existing-database two-host client run retained both synthetic user identities and passed JWT login, refresh/rotation, logout and refresh revocation. Fresh-storage and worker/Flutter conclusions are recorded separately below.

The example explicitly retains JwtConfigFromPasswords and EmailIdpBaseEndpoint. The upstream OTP endpoint is a separate EmailOtpIdpBaseEndpoint, so the new storage does not select that endpoint profile here.

## Serverpod 4.1.2

The workspace pins the CLI and Serverpod package family to 4.1.2 with Flutter 3.50.1 and Dart 3.14.0. The 4.1.2 generator separates module endpoint registration and module-owned table definitions. The upstream Serverpod and authentication migration files are identical between 4.1.0 and 4.1.2. [Serverpod changelog](https://pub.dev/packages/serverpod/changelog#412)

The maintainer approved a temporary exception in the two-host feed smoke test. It accepts `Content-Length: 0` for a nonempty selected feed only when the workspace resolves Serverpod 4.1.2 and `relic_io` 2.0.1. The test still requires status 304, an empty response body and the matching ETag. Other length values and dependency versions use the normal RFC 9110 check. Remove the exception when adopting the upstream fix. [Calendar issue #209](https://github.com/jimmyspets/serverpod_calendar/issues/209) · [Relic issue #454](https://github.com/serverpod/relic/issues/454)

PR #210 recorded the following results on its branch. `flutter pub get --enforce-lockfile`, `tool/generate.ps1`, `dart format tool/feed_smoke.dart`, and `dart analyze --fatal-infos` passed. The core suite passed 540 cases each on VM and Chrome, and the iCalendar suite passed 642 each. The calendar module passed 789 VM and 31 Chrome cases. The feed module passed 13 VM cases, and all nine Flutter widget tests and the Web release build passed. `tool/build-host.ps1` compiled the example host. All 17 cases in `test/integration/feed_test.dart` passed using fresh synthetic test storage.

`dart run tool/host_smoke.dart --feeds --flutter` passed. The two-host HTTP smoke log recorded the issue #209 exception before the feed check passed. Cross-host JWT rotation and revocation and the connected Flutter feed journey also passed.

GitHub Actions reported success for both `inspect` and `runtime` on PR #210's
recorded head `a68314589ef6b55ce87b7893e408d392ccb498e1`. The eventual PR head
`ab72ead` and main merge `f6c2994` have identical trees, with 31 files changed
from `a683145`.
[Upgrade PR](https://github.com/jimmyspets/serverpod_calendar/pull/210) ·
[Hosted run 46058419488](https://github.com/jimmyspets/serverpod_calendar/actions/runs/46058419488)

On 2026-11-28, a manual dispatch started the full repository check on main
at `f6c2994a803b22f3033e7e368dc626e7777a51e5`. Inspection passed and runtime
was in progress when checked.
[Hosted run 46131904608](https://github.com/jimmyspets/serverpod_calendar/actions/runs/46131904608)
