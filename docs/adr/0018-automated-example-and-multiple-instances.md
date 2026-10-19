# ADR 0018: Automated example tests and multiple active instances

Status: **Maintainer-confirmed requirements; implementation design proposed**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

## Context and confirmed requirements

The maintainer requires the example host/app to be used for automated testing and the module to work with more than one active Serverpod instance. These are first-release requirements, alongside the selected RFC feature scope.

The example is a maintained integration/test application using the actual calendar module and generated client, not only a manual demonstration. A supported deployment can run at least two Serverpod instances concurrently against the same logical calendar data. Requests and background work must remain correct when handled by different instances or after one stops.

## Proposed deployment and consistency boundaries

Instances of one deployment share the transactional database and compatible module/schema/serializer/time-zone configuration. Host authorization and publication policy must be current and usable on every instance. Any shared cache, messaging or scheduler infrastructure is selected and verified during scaffolding; this ADR does not assume a particular Serverpod version's distributed guarantees or require a new service without evaluation.

Do not rely on sticky routing, process-local locks, local files, an in-memory ledger or a singleton worker for correctness. Local immutable/pure-computation caches are allowed; caches of mutable data or authority need a validated version/invalidation strategy, or must be bypassed where stale reuse could violate the contract. Loss of invalidation messages cannot make a revoked feed or obsolete reminder valid again.

Use database transactions, constraints and expected revisions across all instances. Define the commit/visibility boundary for reads and in-flight requests; a request starting after committed revocation cannot serve successful content or 304 from another instance's warm cache. A query still describes its documented snapshot rather than a reservation. If exclusive booking is enabled under a separate approved policy, its conflict check/write must be safe across instances.

## Background work, deduplication and recovery

Alarm planning/refill, due work, scheduling ingress and transactional mail/notification outboxes use durable shared identities and coordination. Duplicate wake-ups or deliveries must not create duplicate logical occurrences, scheduling transitions or outbox intents. Validate the pinned Serverpod scheduler behavior instead of assuming that one scheduled callback implies one execution.

Proposed workers claim bounded work transactionally with leases/ownership generations and uniqueness constraints. Define reclaim, renewal and stale-owner rejection so a paused worker cannot overwrite work after another instance takes over. Use a shared time authority or explicitly validated clock-skew policy for leases and due/expiry checks. No process-local mutex substitutes for database coordination.

Persist item/state changes and outbound intent together. Recheck current generation, cancellation, recipient authority and expiry at submission/retry boundaries; coordinate cache invalidation and publication authority across nodes. The reusable notification service also needs shared durable deduplication/lifecycle behavior for the agreed port contract.

Stable request/idempotency identities span retries and instance changes. External mail/push delivery can still be duplicated around provider acceptance and crash recovery; specify uncertain-outcome/retry behavior and use provider/adapter deduplication where available. Do not claim end-to-end exactly-once delivery, guaranteed display or recall after acceptance.

## Automated example test application

Run the real example Serverpod host and its real database migrations with synthetic host identities/resources and policy adapters. Exercise generated-client APIs and feed HTTP routes; run automated Flutter app integration journeys against that host. Core unit tests remain independent and do not replace these integration checks.

Provide isolated test databases/data, deterministic seed/reset, controlled time/scheduler hooks and bounded waits with observable state assertions. Mail/push adapters in routine CI are deterministic test doubles that record submission, retry, cancellation and failure; production credentials, personal calendars and actual recipients are not needed for these checks. Test controls must be restricted to the test harness/build and never exposed as ordinary production endpoints.

CI must launch at least two independently running host processes with distinct instance identities/ports and shared test storage. Verify pinned framework configuration during scaffolding. Direct requests to each instance and route app/client requests across them; a single process with two clients does not satisfy this requirement. Stop/restart a process and simulate worker interruption at controlled points.

Automate Flutter calendar/task CRUD, recurrence exceptions, availability/search, scheduling and reminder actions using the actual generated client. Provider doubles establish application behavior only; they do not replace the separately required working iOS/Android push path or measured external feed-client compatibility.

## Acceptance evidence

| Scenario | Required result |
| --- | --- |
| Write through A, read/query/export through B | Committed state, revision and selected temporal semantics agree |
| Competing stale writes/imports on A and B | Constraints, stale-revision rejection and atomic rollback hold without lost updates |
| Feed representation fetched on either instance | Same committed representation/configuration yields equivalent bytes/strong ETag; node identity and fetch time do not change it |
| Token or publication authority revoked on A, warm-cache conditional fetch on B | A request after the committed revocation is denied; no successful content/304 |
| Rule/booking/association edits on one instance, search on another | Snapshot and complete/unknown coverage stay correct; stale cache cannot manufacture free time |
| Duplicate inbound scheduling messages on A and B | One logical transition/outbox intent under the method's ordering rules; no invitation resurrection |
| Competing alarm planners/workers/outbox consumers | Durable occurrence/intent uniqueness, bounded claiming and idempotent handoff; cancelled/stale work suppressed |
| Claim holder stops or pauses, another instance recovers it | No lost durable work; stale owner cannot commit a reclaimed generation; retry identity retained |
| Cancellation, access loss or task occurrence completion races with dispatch | Enforce the documented submission/acceptance boundary and report outcomes honestly |
| Automated Flutter journeys with host restart/instance switching | Real API behavior, authorization, stale revisions and reconnection are exercised |

Record the commands, pinned versions, topology, test fixtures and results. Define measurable timeouts and recovery expectations during implementation rather than using unbounded sleeps. No runtime implementation or multi-instance compatibility is claimed by this document.

## Alternatives and consequences

A demonstration-only app and single-instance testing would miss the requested acceptance surface. Independent per-instance queues/caches or an uncoordinated singleton job cannot establish correctness under competing processes and failures. The proposed shared durable coordination adds database and test-harness work while keeping deployment/notification providers replaceable.

Scope is concurrent instances of one configured deployment. This does not select cross-region database replication, disconnected operation or a production hosting provider.

Traceability: [requirements](../requirements.md), [architecture](../architecture.md), [compatibility and test evidence](../compatibility.md), [roadmap](../roadmap.md), ADRs [0001](0001-module-boundaries.md), [0003](0003-owned-storage-and-concurrency.md), [0004](0004-subscription-feeds.md), [0007](0007-scheduling-and-email.md) and [0009](0009-alarms-and-notification-boundaries.md).
