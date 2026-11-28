# Serverpod 4.1.0 dependency alignment

The maintainer requested this maintenance batch after ADR 0168. The workspace pins CLI, runtime, generated clients, Flutter integration, authentication and test packages to Serverpod 4.1.0. Flutter 3.47.7 and Dart 3.13.5 remain selected. The lockfile records the actual resolution; generation uses CLI 4.1.0.

The [official changelog](https://pub.dev/packages/serverpod/changelog) describes generated typed copyWith sentinels, reactive ORM helpers and runtime/tooling fixes. Regenerated output is reviewed as generator output, never patched by hand. Generated watch helpers do not establish a supported calendar subscription API or PostgreSQL watch capability. Existing authenticated query/streaming contracts remain authoritative.

Existing JWT authentication, email/password example configuration, opaque host authorization, synthetic transports and calendar timing policies remain the application profile. The dependency upgrade alone does not select passwordless OTP, offline synchronization, new runner workflows or real mail. Historical 4.0.4 validation and ADR evidence stays intact; current setup instructions use 4.1.0.

Use the root generation/check scripts in [local development](development.md). Keep CLI and SDK pins aligned, resolve the root workspace, regenerate all modules and the example, inspect generated/schema changes and verify fresh plus existing synthetic storage before readiness. Never apply test resets to development storage.

Actual local and exact-commit hosted results are recorded in [validation](scaffold-validation.md). Full hosted repository checks remain required before marking the upgrade ready.

The generated example-host migration adds only the upstream serverpod_auth_idp_email_account_otp_login_request table and advances module version markers. The generated feed-module migration refreshes its imported calendar schema snapshot with previously approved scheduling/invitation tables and fields. Calendar and notification module migration checks report no changes. No domain model source was edited and no generated migration metadata was hand-edited.

The migration smoke helper now snapshots all prior populated tables, applies the host SDK migration, checks exact row preservation and verifies empty new OTP request storage. The existing-database two-host client run retained both synthetic user identities and passed JWT login, refresh/rotation, logout and refresh revocation. Fresh-storage and worker/Flutter conclusions are recorded separately below.

The example explicitly retains JwtConfigFromPasswords and EmailIdpBaseEndpoint. The upstream OTP endpoint is a separate EmailOtpIdpBaseEndpoint, so the new storage does not select that endpoint profile here.
