# ADR 0019: Model contracts and storage/API separation

> Notification scope update: [ADR 0020](0020-notification-delivery-scope.md) supersedes earlier requirements for direct iOS/Android push delivery. Durable alarms remain required; a reusable notification module and connected Serverpod streaming example replace the platform-provider release gate. Earlier platform examples below are historical proposals.

Status: **Proposed**. Date: 2026-10-19. The maintainer requested documentation of the necessary models using current repository scope and Serverpod's model documentation. This request authorizes model documentation, not final schema selection or acceptance of this ADR.

Authorization refinement: [ADR 0043](0043-host-authorization-context.md) confirms host-defined rules with module enforcement and requested collection/object context. Internal context models and precise API/transaction/query contracts remain proposals in the catalog.

## Context

The architecture and RFC matrices describe required capabilities but do not provide a consolidated model catalog. One event table or a direct copy of ICS properties cannot express personal alarm state, recurring task progress, complete availability coverage, feed credential lifecycle and durable multi-instance scheduling work safely. Serverpod serialization/persistence models also need an explicit boundary from framework-independent calendar semantics.

## Proposal

Use the [model catalog](../models.md) as the logical contract for subsequent schema/API review. Separate pure semantic values, server-only persistence records, writable command models, authorized response views and adapter projections. Names and fields are candidates, not generated YAML or migrations. Pin and verify Serverpod 4.x-or-later syntax/toolchain during scaffolding.

Propose explicit scoped ownership, aggregate revision checks, stable source/publication/scheduling identities and sparse exception/occurrence state. Store canonical civil/zone/date meaning instead of treating all times as UTC. Shared property values preserve legal parameters and import-only metadata; per-component profiles still govern field legality. Schema normalization, exact identifier types and constraint implementation remain open.

Keep calendar/feed descriptions distinct from credential digests. Keep availability rules and coverage distinct from booked events. Keep task occurrence progress separate from recurrence exceptions. Keep scheduling inbox/order/participation/proposal/outbox state separate from ordinary import. Personal alarm definitions/actions, bounded planning state and durable reminder intents remain separate from shared item metadata and host notification device/provider records.

Use shared durable work identities, reclaimable claims with ownership generations and transactional intent. A proposed request receipt ledger supports retries across instances; determine where it is necessary and its retention before implementation. No process-local lock or generated model is a substitute for database consistency and current host policy. Provider acceptance can remain uncertain after a crash.

## Alternatives

- A single universal component/payload table reduces table count but makes component constraints, authorization, query indexing and lifecycle boundaries harder to review.
- Exposing persistence records directly minimizes mapping but risks making credentials, internal authority and workflow state part of the client protocol.
- Materializing every recurring instance loses boundedness for open series; using only transient state loses task completion, alarm actions and recovery history.
- Finalizing YAML now would commit to unverified SDK/storage details and unresolved task, temporal and projection policies.

## Consequences and open decisions

The catalog adds mapping and validation work, but makes scope and privacy boundaries reviewable before implementation. Every selected feature must have storage or a deliberate value/projection home; not every catalog entry needs a table. Host identities, membership, provider credentials and device registries remain external. Full native capability remains independent of the narrower feed subset.

Review collection/UID uniqueness, physical schema/IDs, legal property cardinalities, typed patches, task lifecycle/range edits, DST/zone updates, retention/deletion, snapshots/pagination, trusted scheduling authority, notification cancellation/retry and claim fencing before schema approval. Preserve existing ADR history and feature statuses. This ADR neither approves those detailed policies nor changes first-release scope.

## Acceptance conditions

Obtain explicit maintainer agreement on material model choices. Trace the catalog to FR-01–FR-31, NFR-01–NFR-15 and RFC tables; resolve the catalog's review gates before dependent implementation. Verify generated serialization/migrations with pinned SDKs, database uniqueness/transactions and server-side authorization. Exercise actual generated APIs and two host processes, including stale writes, feed revocation, scheduling replay and competing/recovered workers. Use synthetic fixtures; retain separate external-client and mobile evidence. Keep the architecture PR draft while these design questions remain.

Sources: [Serverpod models](https://docs.serverpod.dev/concepts/data-and-the-database/models) (reviewed 2026-10-19), [requirements](../requirements.md), [architecture](../architecture.md), [RFC profiles](../rfc/README.md), ADRs [0002](0002-compatibility-and-time.md), [0003](0003-owned-storage-and-concurrency.md), [0008](0008-module-clients-tasks-and-search.md), [0009](0009-alarms-and-notification-boundaries.md), [0014](0014-rfc-extension-decisions.md), [0017](0017-profile-review-clarifications.md) and [0018](0018-automated-example-and-multiple-instances.md).
