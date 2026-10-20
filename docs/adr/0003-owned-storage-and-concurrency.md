# ADR 0003: Authorized storage, atomic imports, and revision conflicts

Status: **Proposed; revised 2026-10-19**. External user/group associations replace the earlier owner-only proposal; see [ADR 0005](0005-external-subjects.md).

## Context

A host application owns identities and membership. Concurrent calendar/series edits, imports, and publication changes must not bypass authorization or overwrite data silently.

## Proposal

Enforce host-supplied authorization for every management/read/write/import/export operation. Namespace tables and constrain parent relationships. Store source series identity separately from subscription publication identity. Enforce uniqueness of series UID within a calendar and exception recurrence identity within a series. A master and its overrides are valid related components, not duplicate-UID conflicts.

Require expected revisions for changes/deletes, including association and feed selection edits; update atomically. Keep application revisions distinct from iCalendar SEQUENCE. Validate complete import batches before atomic insertion; existing-series collisions conflict rather than silently merging. Read feed content and its validator from a consistent committed snapshot.

Define calendar deletion semantics before API release. Proposed feed behavior is fail closed when a selected calendar disappears until authorized selection repair. Retain cancellation/exception state required for recurring series; do not conflate single-occurrence deletion with deleting the entire series. Broader synchronization tombstones remain separate design work.

## Multiple active Serverpod instances

[ADR 0018](0018-automated-example-and-multiple-instances.md) makes concurrent active instances required. Transactions, revision checks, uniqueness and snapshots must hold across processes sharing storage. Do not depend on process-local locks or sticky routing. Mutable caches and host policy must remain safe across instances, including committed feed revocation. Durable shared claims/deduplication need explicit reclaim and stale-owner behavior; exact database/framework mechanisms remain proposed until the toolchain is selected.

Automate competing writes/imports, cross-instance committed reads, policy/cache changes and process-loss recovery in the real example host setup. If a separate exclusive-booking policy is approved, its conflict-check/write must also be safe across instances.

## Alternatives

Client-side filtering cannot enforce access. Last-write-wins loses edits. Persisting host membership snapshots risks stale authorization and violates the external identity boundary.

## Consequences

Host authorization and database transaction behavior require integration tests. Feed revision/cache invalidation must track all relevant mutations. This storage is not a CalDAV synchronization protocol.

## Acceptance conditions

Verify migrations, durable restart, concurrent edits, complete rollback, group/tenant isolation, forged subject references, membership changes, recurrence identity constraints and feed deletion/invalidation behavior. No ADR is accepted merely by merging these documents.
