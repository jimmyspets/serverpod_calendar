# ADR 0114: Reusable notification delivery and connected recovery

Status: live-reminder profile confirmed on 2026-10-25; three-table storage and defaults approved on 2026-10-25; implementation mechanics under review. Date: 2026-10-25.

## Context and scope

Native alarm planning/actions now have scoped implementations under [ADRs 0112](0112-bounded-durable-alarm-planning.md) and [0113](0113-native-alarm-actions.md). Before this batch their delivery port was deliberately unconnected. [ADR 0020](0020-notification-delivery-scope.md) requires a reusable notification module plus a real connected Flutter example. The reusable module must also work for non-calendar producers, without importing calendar, Flutter, provider SDKs or host identity models.

The next recommended batch supplies durable idempotent acceptance, a fenced publication/retry worker, authorized bounded recovery, and an example server-event/stream adapter with in-app presentation/actions. No FCM/APNs, OS background delivery, device tables or imported-alarm adoption is included.

## Confirmed live-reminder profile

The maintainer selected live reminders: recover only still-unexpired, currently authorized source references, and project presentation text freshly rather than storing copied titles/bodies. A persistent content inbox remains separate scope and would require its own retention, source-deletion, redaction and read-state policies.

Under this confirmed profile, stream hints can be duplicated or lost; durable accepted records plus authorized recovery establish correctness. Published means a transport hint was posted, never human display, read state or acknowledgement. Expired or no-longer-authorized source data does not appear in recovery. Native calendar actions remain calendar commands; the generic module does not invent acknowledgement history.

## Approved storage boundaries

The maintainer explicitly approved the following three-table design, 30-day terminal-reference retention and default 10,000-record recipient capacity on 2026-10-25. No content inbox, device directory or provider table is proposed.

| Model | Fields and constraints |
| --- | --- |
| `NotificationScopeRecord` | Server UUID and unique trusted `scopeKey`. A shared database lock row serializes scoped acceptance/capacity/cursor mutations across hosts; it contains no ownership or membership claim. Keep this minimal operational row in the initial profile; host scope retirement needs a later explicit cleanup contract. |
| `NotificationDeliveryRecord` | Server UUID; trusted scope and recipient namespace/key; registered source namespace/version; bounded opaque source reference; producer request ID and normalized request digest; due/expiry; queued/published/suppressed/expired state and bounded reason; next attempt/count; lease owner/until/fence; optional published/terminal times and audit times. Unique `(scopeKey, sourceNamespace, sourceRequestId)`. Index due claims, recipient/unexpired recovery and terminal pruning. No copied calendar text, provider credentials or user profile. |
| `NotificationCursorRecord` | Random opaque token with unique index; trusted scope/principal/policy epoch and recipient; after-UUID, page size and expiry. Server-only live keyset continuation; no total count, raw offset or client-selected channel. |

Use a source reference limit of 4 KiB UTF-8, 256-byte opaque identity limits, and a bounded trusted source registry. Reject unknown versions/namespaces, oversized input and request-ID reuse with different normalized recipient/source/timing. Enqueue is a trusted server API, not a public client endpoint. A source registration validates the actual source and recipient before acceptance; an opaque reference itself grants no authority.

Use a configurable initial cap of 10,000 retained deliveries per recipient, 100 claims per sweep, 30-second fenced leases and 30-second retry delay. Use 30-day terminal retention, but never prune a still-unexpired published record needed for recovery. Pending/retryable work is not terminal history. Idempotency is bounded by retention; an expired source retry must fail fresh validation before it could recreate a pruned record. The maintainer approved these notification-specific defaults separately from the calendar worker policy.

## Concrete field and index review

Use `serverpod_notifications_` table prefixes and server-only ORM models. All times below are UTC database/transport instants; operational audit/lease times retain database precision. Delivery due/expiry are explicit supported whole-second instants, with `dueAt < expiresAt`. The generic module does not import the calendar's year/zone/recurrence model.

- `NotificationScopeRecord`: `id: UuidValue?` (server generated), `scopeKey: String`; unique scope key. This row is a synchronization marker, not a user/tenant directory. It contains no principal/recipient or notification content and remains until a future explicit host scope-retirement procedure.
- `NotificationDeliveryRecord`: `id: UuidValue?` (server generated); `scopeKey`, `recipientNamespace`, `recipientKey`, `sourceNamespace`, `sourceRequestId`, `requestDigest`, `sourceReference: String`; `sourceVersion: int`; `dueAt`, `expiresAt`, `nextAttemptAt`, `createdAt`, `updatedAt: DateTime`; `state: NotificationDeliveryState`; `reason: String?`; `attemptCount`, `leaseFence: int` (initially 0); `leaseOwner: UuidValue?`, `leaseUntil`, `publishedAt`, `terminalAt: DateTime?`. Unique scope/source/request identity; indexes on state/next-attempt/lease, scope/recipient/expiry/id, and terminal time/expiry. Source references are bounded adapter-validated pointer encodings, not arbitrary content documents.
- `NotificationCursorRecord`: generated internal ID; `token`, `scopeKey`, `principalId`, `policyRevision`, `recipientNamespace`, `recipientKey: String`; `afterId: UuidValue`; `pageSize: int`; `expiresAt: DateTime`. Unique token and expiry indexes. Continuations are source/actor/recipient-authorized live traversals; no client chooses another recipient.

`NotificationDeliveryState` has `queued`, `published`, `suppressed`, `expired`. A transient source/transport failure keeps queued work retryable; it must not become permanent suppression. Source denial/withdrawal is distinct from source unavailability. Published records remain recoverable only while unexpired and freshly authorized; terminal retention does not grant read access or a right to see historical content. The approved 30-day default covers operational terminal records only.

Keep identity fields and the normalized request fingerprint immutable after insertion. Reusing a source request ID with changed recipient/reference/timing rejects atomically. A matching duplicate still rechecks current source authority before returning durable acceptance. Scope-row serialization protects capacity and request-ID races across independent instances. No cross-module foreign key or calendar schema change is proposed by these generic tables.

## Acceptance and fresh authorization

Register producer adapters in trusted host composition. Generic contracts carry validated source/recipient/scope, logical request identity and lifecycle/expiry reference. The module never resolves users, membership or calendar parentage from client claims. Recheck source eligibility on duplicate acceptance, before publication, after queue delays/retries, and before every recovered projection. Check shared database time after slow callbacks. Missing/unavailable adapters fail closed.

Declare coordinated versus external fresh-check guarantees. A coordinated adapter must hold its required source/policy locks through the supplied notification transaction; a callback that opens and closes a separate source transaction supplies only a fresh check. Reject a stronger configured requirement when the adapter cannot provide it. Do not infer coordination from use of the same PostgreSQL database. Source mutation after a final external check can race an accepted handoff; no recall or exactly-once human delivery is promised.

For calendar delivery, the example adapter binds the firing UUID as producer request identity and retains the minimal `CalendarAlarmDeliveryIntent` reference. It must call `CalendarModule.checkAlarmDelivery`, retaining eligible/withdrawn/unavailable distinctions, before every publication/recovery, including after the calendar worker has recorded acceptance. Recipient-specific presentation requires explicit current host approval; do not fabricate a JWT or treat a source ORGANIZER/ATTENDEE as an identity. Calendar actions are reauthorized by the existing action API.

Do not hold an unrelated module lock while awaiting arbitrary external work without bounded timeouts. Establish and test a consistent lock order for same-database source adapters; external source checks remain explicitly weaker. A failed or unavailable check must not be recorded as a permanent authorization denial or expose a partial response.

## Publication and recovery

Commit the durable delivery before returning acceptance to the calendar port. Claim due work briefly with shared database time and `FOR UPDATE SKIP LOCKED`, then validate/publish outside the claim transaction. Commit a result only for the exact unexpired owner/fence and current record. A publication followed by process loss may repeat the same hint ID; consumers deduplicate. Retry reuses the same notification UUID rather than allocating a new logical delivery.

Server events carry only minimal invalidation hints on host-derived recipient channels. Channel names/IDs never authorize a subscription or fetch. The example must explicitly use `MessageScope.global`, so missing Redis cannot silently downgrade cross-instance delivery. Redis/server events are not the durable queue or replay store. This matches the inspected pinned 4.0.4 SDK and [current server-events documentation](https://docs.serverpod.dev/concepts/server-events/).

Recovery returns authorized live pages with opaque, actor/recipient/policy-bound continuations and no totals. Recheck each source before producing any text/actions. UUID order is deterministic, not chronological; this is not a frozen snapshot. Subscribe before initial recovery, refresh after hints and reconnect, and perform bounded periodic reconciliation while connected so lost hints do not become lost durable reminders. Source expiry, cancellation, acknowledgement, task completion and access removal must remove obsolete views on reconciliation; already displayed information cannot be recalled.

Keep the streaming endpoint and channel adapter in the example host, following [Serverpod streaming methods](https://docs.serverpod.dev/concepts/endpoints-and-apis/streaming). Require authenticated caller/current recipient and fresh host access before every hint/heartbeat and recovery request. Close/reconnect bounded streams and revalidate authentication through the host's supported handler; do not keep a cached handshake identity indefinitely. Client logout cancels subscriptions and clears projections. An already-issued valid JWT is not automatically revoked by logout; preserve the existing documented Serverpod behavior.

## Example and validation gates

Flutter subscribes through generated clients, deduplicates hints, recovers current views and invokes separately authenticated calendar actions. Recipient IDs, raw channels and arbitrary source references are never client selectors. A non-calendar synthetic producer must demonstrate the module has no calendar dependency. No imported alarm is armed or activated by this integration.

Before completion, verify fresh/populated migrations, atomic concurrent acceptance/capacity, duplicate/conflicting request IDs, missing adapters, final denial/timeouts, expiry and terminal pruning, source mutation/revocation, fenced ownership and acceptance/publication crash windows. Test two actual hosts with shared storage/Redis: accept on A, observe on B, lose an instance, reconnect on the survivor, recover unexpired authorized data and reject stale/withdrawn references. Record actual Redis routing and connected Flutter evidence separately from durable acceptance. A log line, local map or successful pub/sub call alone is insufficient.

The maintainer explicitly approved the three-table storage and defaults. The scoped implementation now follows this contract; API mechanics and batch validation remain under draft review. See [the delivery guide](../reusable-notification-delivery.md). This creates no persistent content inbox.
