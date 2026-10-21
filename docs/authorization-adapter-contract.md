# Proposed server authorization adapter interfaces

**Current implementation:** the first native calendar CRUD/association slice is described in [the implementation guide](calendar-crud-implementation.md) and [ADR 0049](adr/0049-first-calendar-crud-implementation.md). Broader model/interface proposals below remain future design unless explicitly covered there; this adds no iCalendar/feed-client compatibility.


Status: **concrete interface proposal for implementation review, not Dart code or approved final signatures**. The confirmed responsibilities, permission separations, disclosure and consistency choices are in ADRs [0043](adr/0043-host-authorization-context.md), [0044](adr/0044-authorized-query-projections-and-pagination.md) and [0045](adr/0045-authorization-consistency-guarantees.md).

## Proposed contracts

| Responsibility / illustrative method | Trusted input | Result and module enforcement |
| --- | --- | --- |
| `HostContextResolver.resolveRequestContext` | Authenticated server session plus any explicitly untrusted scope-selection hint | Trusted actor and validated host scope; reject unresolved/unauthorized scope selection before looking up targets. Client tenant/role/member values are not identity |
| `HostContextResolver.resolveExecutionContext` | Server-issued, purpose-specific background/publication/verified-ingress context | Trusted execution actor/scope/authority references; not callable through a client-supplied system flag |
| `AuthorizationPolicy.describeGuarantees` | Host deployment configuration | Explicit supported consistency guarantees and policy integration metadata; module rejects missing/unsupported required configuration, without fallback |
| `AuthorizationPolicy.authorizeBatch` | Host context, bounded keyed operation/target requests, relevant current/proposed state and attempt/snapshot context | One explicit decision per request: allow/deny/unavailable, plus permitted typed field groups for supported read projections and relevant server-only decision evidence |
| `AuthorizationPolicy.planQuery` | Authorized bounded collection query, trusted host scope and requested projection | Trusted typed candidate constraints; module intersects these with mandatory scope/containment and query bounds. Coarse constraints do not grant object detail access |
| `AuthorizationCommitCoordinator.withCommitGuard` | Active write attempt, authoritative targets/revisions/change and required coordinated guarantee | Execute the module's guarded commit only under effective host revocation/commit coordination; every relevant revocation path must participate. Callback shape/mechanism requires implementation review |

No actor, policy decision, transaction handle, commit guard or scope authority becomes a generated-client payload. These contracts live in the Serverpod server integration boundary; pure temporal code remains independent. The example supplies implementations, not a mandatory ownership/ACL scheme.

An illustrative grouping is `CalendarModule.configure(contextResolver, authorizationPolicy, commitCoordinator, authorizationRequirements, limits)`. This is documentation only; it neither exists nor finalizes a configuration constructor. A commit coordinator is required only where the configured guarantee requires one; external fresh-check integration is not misrepresented as coordinated. Configuration must declare requirements rather than silently invent a default.

## Batch evaluation rules

The module assigns each request a unique correlation key and binds it to its actual actor/scope, action, target/parent references, current revision, validated proposed change and attempt. Returned decisions must match that exact batch/context. Missing, duplicate, foreign or malformed keys fail closed; one allow cannot authorize a different item or action. Unknown actions/groups/guarantees never default to permissive behavior.

Allow is scoped to the requested operation; disclosed groups are restricted to the requested and view-supported groups. A host cannot use a group name to expose raw credentials or records. Deny and unavailable remain distinguishable internally; external errors remain privacy-safe. For an atomic mutation, any denied/unavailable required gate prevents the entire requested change. A read query may legitimately omit denied objects, but cannot treat an unavailable decision as an invisible object and claim complete pagination.

Batch size, candidate scan, expansion, payload and timeout limits are module/host configuration validated independently. The host may evaluate batches efficiently or delegate to its own service; the module never assumes that a calendar allowlist describes every object rule. `planQuery` may provide coarse scope-constrained candidates when a policy cannot be translated into database constraints; bounded per-object batches still enforce the policy. Exact supported constraint variants and batch/result classes must be selected during implementation review, not passed as arbitrary client SQL or closures.

## Read/query call sequence

1. Resolve trusted actor/scope and validate the bounded query shape/requested groups.
2. Authorize the collection query and obtain its candidate plan.
3. Load deterministic bounded candidates within mandatory scope/parent constraints; assemble minimal policy metadata.
4. Evaluate object visibility/groups in bounded batches; construct permitted views and authorized lookahead before visible page boundaries.
5. Return only authorized views and protected continuation under [the query contract](authorization-queries.md). No totals, raw records or false exhaustion. Reestablish current authorization on every page.

Single-object reads use the same keyed decision/view path without pretending to be a list query. An internal scope-limited lookup supplies policy context without itself granting client disclosure. Inaccessible and nonexistent objects must not be distinguished through unauthorized revision or dependency diagnostics.

## Write call sequence

Use [the consistency protocol](authorization-consistency.md): resolve/validate, establish snapshot/revisions, authorize every gate, apply the configured final check/coordination and commit domain changes/invalidation/outbound intent together. The adapter does not own calendar mutation SQL or bypass module validation. The coordinator guards the module-owned commit; a returned version string alone is not a coordination mechanism.

A proposed callback guard must execute the intended commit at most once for its active attempt, reject late/reused decisions and propagate failures without an abandoned mutation. Transaction retries create a fresh attempt and reauthorize. Authorization callbacks must not send business mail, deliver notifications or mutate external business state. Every write result is projected under current authorized disclosure; an allowed mutation is not a full-read grant.

The concrete same-database locking/serialization protocol and external authoritative-check implementation must be proved by two-host tests. No generic interface signature by itself proves either guarantee. Numeric timeouts, attempt/evidence persistence, result/receipt shapes and provider profiles remain implementation gates.

## First implementation acceptance

- Implement the [minimal calendar contract](calendar-crud-contract.md) through these enforcement paths, rather than adding parallel endpoint-only checks.
- Supply a synthetic example host policy and a replacement object-specific policy using the same interfaces.
- Test batch correspondence errors, missing configuration, denied/unavailable gates, field-group validation, forged scopes/parents and current result disclosure.
- Test create/metadata/settings/association/delete gates, stale revisions and mixed-request rollback; verify unsupported guarantee rejection and no fallback.
- Test full authorized pages and continuation, late external allows and declared revocation ordering across two independent hosts. Keep concrete protocol tests distinct from the existing authentication-only scaffold evidence.

[ADR 0047](adr/0047-calendar-names-identifiers-and-deletion-storage.md) selects native UUID identity, separate display/protocol names and minimal deletion markers. Adapters must distinguish active targets from internal deleted identities without granting access through markers. No domain runtime code, generated models, migrations or final interfaces are introduced by this document.

## Implemented availability organizer check

The scoped native extension under [ADR 0060](adr/0060-availability-publication-metadata.md) adds required `CalendarHostPolicy.approveAvailabilityOrganizer(session, context, request, transaction, phase)`, returning `CalendarAuthorizationVerdict`. It is independent of `authorizeBatch` and does not replace operation rights. Existing unpublished host adapters must implement it; absent approval cannot silently accept an organizer. The [native guide](availability-publication-metadata.md) defines current/final proposed context, removal/retention checks, failures and declared guarantee boundaries.

## Availability protocol lifecycle context

[ADR 0061](adr/0061-availability-protocol-lifecycle-and-envelope-duration.md) adds immutable `currentAvailability.protocolState` and final `proposedAvailabilityProtocolState` for native create/content/occurrence writes. The proposal can be absent before server timestamp allocation; final checks receive the exact state to persist, including unchanged versions on identical saves. This grants no additional authority. API revision remains the optimistic-concurrency value; internal updatedAt and scope generation still advance on accepted identical writes, while protocol stamps/SEQUENCE do not. Raw rules retain all-or-nothing disclosure and busy summaries expose none of this metadata. See [native lifecycle guarantees and legacy baseline](availability-protocol-lifecycle.md).
