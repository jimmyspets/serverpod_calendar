# ADR 0001: Reusable core with a Serverpod module

Status: **Proposed**. Date: 2026-10-19.

## Context

The accessible discussion asks whether a Serverpod package is preferable to integrating Stalwart, and how to publish a public library. The answer and detailed module design are unavailable; no product comparison is established by this record.

## Proposal

Develop calendar semantics in a pure Dart core, an explicit iCalendar adapter, and a Serverpod persistence/API module with its generated client. Prove integration through an authenticated Serverpod host and Flutter app using generated Dart clients for calendar/task CRUD, scheduling and list-based availability search. External feed clients consume a documented subset and do not define the full module model. Choose physical package names and versions during scaffolding; defer an independently reusable Flutter UI package.

The current first-release requirements also need a plain HTTP subscription adapter for GET/HEAD feeds alongside authenticated Serverpod management endpoints. Keep subscription transport and token/validator handling outside the reusable core; feed persistence and host authorization stay in module services. See [ADR 0004](0004-subscription-feeds.md) and [ADR 0005](0005-external-subjects.md). This is a proposed boundary for the maintainer-stated feed and external-identity scope.

First-release scope now includes RFC 7953 availability rules plus scheduling and email adapters; see ADRs [ADR 0012](0012-calendar-availability-policy.md) and [0007](0007-scheduling-and-email.md). Keep iTIP state processing independent of iMIP transport and host mail providers.

See [ADR 0008](0008-module-clients-tasks-and-search.md) for native tasks, Flutter interfaces and availability search.

## Automated example acceptance

The maintainer requires the example host/Flutter app to be the automated integration-test application, using the actual module/generated client and database migrations. CI includes Flutter journeys, generated-client API/feed tests and at least two concurrently running host instances with shared test storage under [ADR 0018](0018-automated-example-and-multiple-instances.md). A manual demonstration or mocked module alone does not satisfy this requirement; pure core unit tests remain independent.

## Alternatives

- Integrate an external calendar server such as Stalwart: evaluate its actual capabilities, operational requirements, API fit, and license before choosing; this draft makes no claim about current feature support.
- Put all logic in the Serverpod module: fewer packages but couples format/domain tests and future adapters to the backend.
- Start with a full CalDAV server: expands protocol and interoperability scope before a working application exists.

## Consequences

The core can be tested without a server, and future protocol adapters have a clear boundary. Multiple packages introduce dependency/version management. A native module takes responsibility for storage and access control; it does not inherit another server's synchronization features.

## Acceptance conditions

The maintainer has selected a Serverpod module as the primary product. Recover earlier discussion if available without making it a prerequisite; verify the selected Serverpod template and SDK constraints; record module boundaries and package naming in the scaffolding PR. Do not accept this ADR solely because it is included in a merged documentation PR.
