# Example workspace scaffolding plan

Status: **walkthrough selections confirmed; initial executable scaffold locally verified**. Date: 2026-10-19. This records the maintainer's choices for the first buildable milestone. It does not approve unresolved domain models or every proposed ADR.

## Confirmed choices

| Area | Selection |
| --- | --- |
| Repository | Reusable packages and example host/app together in this repository |
| Core | `serverpod_calendar_core`: independent Dart calendar semantics |
| iCalendar | `serverpod_calendar_icalendar`: explicit parsing/serialization adapter |
| Calendar module | `serverpod_calendar`: Serverpod persistence/API module and template-generated client structure |
| Notifications | `serverpod_notifications`: reusable provider-independent notification module; example streaming transport under ADR 0020 |
| Optional UI | `serverpod_calendar_flutter`: later extraction of widgets from the example; not a first-release publication gate |
| SDK policy | Latest compatible stable Serverpod 4.x-or-later, Dart and Flutter, with exact versions pinned during scaffolding |
| Initial Flutter target | Web first; keep example portable |
| Development services | Local Serverpod host with Docker Compose database/supporting services from the verified template |
| Example identity | Self-contained Serverpod authentication and synthetic host-owned users/groups/resources; calendar receives opaque references and host policy decisions |
| Example token manager | Serverpod JWT with its standard refresh endpoint and default lifetimes, selected to match the maintainer's production authentication |
| Initial sign-in | Seeded synthetic demo accounts using normal authenticated sign-in; registration/password-reset screens later; recording adapter for any local authentication email |
| Checks | Local repeatable automated checks first; CI configuration later, retaining release CI and multi-instance requirements |
| First milestone | Buildable workspace, example authentication and authenticated generated-client connection smoke test |

The selected template produces calendar/notification `_server` and `_client` package pairs in a root workspace; resolved pins and seeded-account JWT authentication are recorded in [ADR 0021](adr/0021-initial-workspace-scaffold.md) and the [development guide](development.md). Provider-specific iOS/Android delivery implementations remain external. No calendar domain YAML or migrations are approved solely by selecting the scaffold milestone.

## Local tools verified

Commands run on 2026-10-19: `flutter --version`, `serverpod version`, `docker version --format '{{.Client.Version}} / {{if .Server}}{{.Server.Version}}{{end}}'`, and `docker compose version`.

| Tool | Result |
| --- | --- |
| Flutter | 3.47.7, stable |
| Bundled Dart | 3.13.5 |
| Serverpod CLI | 4.0.4 |
| Docker client/engine | 29.8.2 / 29.8.2; engine reachable |
| Docker Compose | v5.6.0 |

The restricted session could not access Docker/shared tool state; the checks passed with the required local execution access. These are installed versions, not a claim of dependency compatibility or successful scaffolding. Pin package/CLI versions after resolving and validating the generated workspace against the stable policy.

## First milestone acceptance

The scaffold establishes package boundaries and a connection/authentication smoke path. Initial notification integration is a module dependency/compilation check; durable delivery, streaming/reconnect semantics and alarm features are subsequent implementation work under ADR 0020. Core/iCalendar packages may start as compilable skeletons without prematurely selecting parser/recurrence dependencies or calendar domain schemas.

- Local workspace dependencies resolve and generated Serverpod module/client imports compile.
- Example services and host start from documented clean-checkout instructions using local-only development configuration.
- Example authentication remains host-owned; synthetic identities never become calendar identity tables.
- Flutter Web signs in and calls one authenticated smoke operation through the actual generated client. Verify unauthenticated rejection too.
- Local formatting, analysis, generation consistency, migration/database smoke checks and generated-client/Flutter smoke journeys have recorded commands/results.
- Local setup allows later tests with two independent hosts sharing storage; full cross-instance feature tests arrive with the corresponding features.

Domain schemas, parser/recurrence dependency choices, scheduling lifecycle and durable notification implementation follow reviewed contracts in the [model catalog](models.md) and [roadmap](roadmap.md). Initial walkthrough choices are recorded; the initial executable scaffold has passed the local check script. Verified commands and their results are maintained separately in the development guide and scaffold-validation.md.

See [ADR 0001](adr/0001-module-boundaries.md), [ADR 0018](adr/0018-automated-example-and-multiple-instances.md), [ADR 0019](adr/0019-model-contracts.md) and the newer notification scope in [ADR 0020](adr/0020-notification-delivery-scope.md). Package responsibility/name selections above refine ADR 0001; physical template layout and remaining implementation policies still await review.

## Pre-scaffolding audit

Audited against all ten walkthrough steps on 2026-10-19: repository, package responsibilities/names and later UI extraction, notification correction, stable SDK policy, Web-first target, local Docker services, self-contained host identity, local checks before CI, initial smoke milestone and seeded sign-in. Every selected option is recorded above. Selecting a policy or milestone is distinct from completing its implementation.

| Remaining setup verification | Completion point |
| --- | --- |
| Resolve stable CLI/runtime/auth/test/client package versions together, pin exact versions and verify compatible Flutter/Dart constraints | During scaffolding, before claiming a buildable workspace |
| Inspect the pinned module/auth templates, select workspace folders and generated client names, and verify dependencies/licenses | Before generating the final workspace; preserve Apache 2.0 LICENSE |
| Verify normal seeded-account sign-in APIs, development-only seed/reset and recording auth mail; keep credentials/configuration untracked | Before the example auth smoke test; seed/reset must not become production endpoints |
| Configure local-only Compose services, isolated test storage and distinct instance ports; document two-host launch strategy | During scaffold setup; feature-specific cross-instance acceptance follows as features arrive |
| Establish repeatable local formatting, analysis, generation, database and real-client/Flutter smoke commands | Before marking the first milestone complete; CI configuration follows later |
| Check current issues/PRs before opening overlapping implementation work and use a focused branch/draft PR | Before creating implementation work; the earlier model branch push was blocked and remains unpublished |

Before scaffold implementation, the connected GitHub issue and PR searches returned no existing work; the audit itself had not refreshed that inventory. The initial environment checks did not verify browser tooling, dependency resolution, module generation or authentication behavior; their execution results are recorded in scaffold-validation.md rather than inferred from the environment checks. Detailed time/recurrence/task/authorization/storage contracts in the model catalog remain prerequisites for their dependent domain implementation, rather than for empty package scaffolding. There are no additional maintainer preference questions required for the selected initial milestone; report any concrete incompatibility found during setup instead of silently changing these selections.
