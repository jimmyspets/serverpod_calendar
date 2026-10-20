# ADR 0042: Optional Serverpod module for iCalendar HTTP feeds

Status: **Accepted module boundary; detailed APIs/schema remain proposed**. Date: 2026-10-20.

## Decision

The maintainer explicitly decided that the iCalendar HTTP feed capability belongs in a separate optional Serverpod module. Hosts using only authenticated calendar APIs need not install feed publishing. Feeds remain a required first-release capability and part of the automated example/integration tests. This supersedes the combined calendar/feed ownership in ADR 0001 without changing feed semantics in ADRs 0004 and 0016.

The calendar module owns calendar/event/task/availability storage, domain operations and the host policy boundary. The iCalendar adapter owns parsing/serialization independently of HTTP. The optional feed module owns subscription routes, feed selections and presentation metadata, bearer-token digests/revocation, feed-management operations and deterministic HTTP/ETag handling. It depends on the calendar module and iCalendar adapter. The calendar module must function without a dependency on the feed module.

Subscription access is read-only. The feed module consumes a defined calendar publication projection and policy contract rather than directly querying calendar tables or copying authorization. Check continuing publication permission and active token/feed state before both content and 304 responses, across all active hosts. A feed credential grants no calendar management or availability-query rights. Retain transactional selection changes, revisions, stable publication identities, bounded generation and redacted bearer URLs.

Authenticated calendar import/export, native availability queries and scheduling are not moved into the optional feed module. The adapter remains independently reusable; native/calendar capabilities must not depend on installing subscriptions. Raw availability rules remain excluded from bearer feeds under ADR 0012.

## Alternatives and consequences

Keeping feeds in the calendar module would simplify initial wiring but require every host to take feed-specific storage and transport. Splitting only the HTTP routes would leave calendar installations coupled to feed credentials and lifecycle. The chosen module adds a package pair, migrations and explicit integration contracts, while allowing hosts to omit subscriptions entirely.

`serverpod_calendar_feed_server` and `serverpod_calendar_feed_client` are working package names, not a confirmed naming decision. The current nine-package scaffold is unchanged; extraction/scaffolding belongs to a following implementation batch. No module code or migration is claimed by this decision.

## Acceptance conditions

Define projection, policy, revision and invalidation contracts before feed schemas/routes. Test a host without the feed module and a host with it, generated-client management, real GET/HEAD/conditional requests, revocation before 304, concurrent selection edits and cross-instance consistency. Extend the automated example with feed cases as implementation lands; keep external-client evidence separate. Merging this decision does not accept unrelated proposed ADRs.

See [architecture](../architecture.md), [scaffolding plan](../scaffolding-plan.md), [feed policy](0004-subscription-feeds.md), [HTTP profile](0016-subscription-http-profile.md) and [multi-instance requirements](0018-automated-example-and-multiple-instances.md).
