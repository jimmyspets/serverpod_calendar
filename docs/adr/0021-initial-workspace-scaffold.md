# ADR 0021: Initial workspace scaffold and example authentication

Status: **Proposed implementation of maintainer-confirmed scaffold choices**. Date: 2026-10-19. This records the concrete implementation, not approval of future calendar schemas or all earlier ADRs.

## Context

The maintainer approved a single repository, logical package names, stable SDK policy, Flutter Web first, local Docker services, self-contained synthetic example identities, local checks before CI, and a first milestone limited to buildable package wiring and authenticated generated-client calls. Seeded demo sign-in was selected; registration/reset screens follow later. See the [scaffolding plan](../scaffolding-plan.md).

## Implementation proposal

Use one Dart pub workspace with nine packages: pure Dart core and iCalendar foundations, Serverpod calendar and notification server/client pairs, and example server/client/Flutter packages. Preserve the generated `_server`/`_client` module conventions under the selected logical module names. Do not create the optional GUI package before extraction or implement unreviewed calendar schemas in the scaffold.

Pin Flutter 3.47.7, Dart 3.13.5 and the Serverpod 4.0.4 package family/CLI. Preserve the Apache 2.0 repository license; dependency licenses remain separate. Installed package LICENSE files identify `serverpod` 4.0.4 as SSPL v1 and the official auth package inspected as BSD-3-Clause. Dependency licensing is not changed by the repository license. Record further dependency review before parser/recurrence selection and publication; no legal compatibility conclusion is made here.

The host owns email/password authentication and synthetic accounts through official Serverpod auth APIs. Reusable modules expose authenticated diagnostic endpoints only. They store no user/group directories or domain calendar tables. Actual calendar authorization adapters and subject/resource semantics remain gated by the model review.

The maintainer selected Serverpod's built-in JWT authentication to match their production setup. Use `JwtConfigFromPasswords()` and the standard `RefreshJwtTokensEndpoint`, with the pinned SDK defaults (ten-minute access tokens and fourteen-day refresh-token lifetime). Logout clears local client credentials and revokes refresh credentials; an issued access JWT intentionally remains valid until expiry. The earlier database-backed session implementation satisfied an extra immediate-invalidation test assumption that was not a maintainer-selected requirement; it is superseded by this JWT selection. Reusable modules continue to support host-selected authentication with independently enforced current authorization.

Setup generates ignored random development/test credentials. Account seeding is idempotent, transactionally creates each host auth user/email account and requires development/test mode plus an explicit environment flag. No network seed/reset endpoint exists. Auth mail uses a local recording adapter; no cloud mail/storage provider or platform push implementation is included.

Local Compose supplies separate development/test PostgreSQL and Redis services. The integration harness builds one host bundle and starts two independent processes sharing only isolated test storage. Building once avoids the Windows native-DLL replacement conflict observed when starting two `dart run` hosts. Test resets affect only the synthetic test database; child host processes are cleaned up after the test.

## Alternatives

Separate nested workspaces complicate cross-package resolution and require multiple lockfiles. Keeping the template's cloud email/storage setup does not match the selected local-only milestone. Database-backed sessions offer immediate token revocation but do not match the selected example authentication strategy. JWT smoke tests exercise refresh/rotation, local logout, revoked-refresh rejection and continued acceptance of an unexpired copied access token; they do not wait for the default ten-minute expiry. Current calendar permissions and feed-token revocation remain separate authorization concerns with either token manager. Requiring every calendar model decision before an empty scaffold would block the selected incremental milestone.

## Consequences and acceptance

The scaffold proves package/SDK/auth wiring only. Pure semantic packages have no implemented calendar behavior, notification delivery remains a skeleton, and no provider-independent delivery persistence contract is finalized. Generated clients are regenerated from sources; migrations come from the CLI. Tests must cover anonymous rejection, normal sign-in, identity consistency across modules, separate host processes, JWT refresh/rotation and refresh revocation, local sign-out and real Flutter interactions. Full feature/multi-instance release tests and CI configuration remain required later.

Record actual commands/results in [scaffold validation](../scaffold-validation.md). Keep the architecture PR draft while detailed designs remain proposed. The focused branch is `feat/example-workspace`.

Sources: [Serverpod modules](https://docs.serverpod.dev/concepts/server-fundamentals/modules), [Serverpod token-manager comparison](https://docs.serverpod.dev/concepts/authentication/token-managers/managing-tokens), installed 4.0.4 auth source and generated templates, [ADR 0018](0018-automated-example-and-multiple-instances.md), [ADR 0020](0020-notification-delivery-scope.md), and the maintainer's walkthrough choices. Dependency resolution and local checks establish only the pinned environment tested here.
