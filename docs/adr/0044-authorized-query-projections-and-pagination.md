# ADR 0044: Authorized query projections and pagination

Status: **Accepted detail/free-busy separation, no-total initial pages and field-group granularity; implementation proposed**. Date: 2026-10-20.

## Context and confirmed choices

After confirming the host authorization/context boundary in ADR 0043, the maintainer selected separate detail and free/busy responses, authorized pages with opaque continuation cursors and no initial total counts, and predefined field groups rather than individual-field policy in the initial detail contract. This refines query/disclosure scope without selecting final adapter signatures or cursor/schema mechanics.

## Decision

Keep detail pages and calculated privacy-safe availability responses separate. The initial detail API does not mix readable events and redacted busy placeholders. Hidden detail objects do not disappear from availability calculations: authorized complete busy projections use the complete contributor set, and missing/denied projection coverage never becomes free time.

Initial list pages expose only authorized views and opaque continuation, without exact/estimated totals, denied counts or candidate counts. Null continuation must mean genuine authorized exhaustion under the eventual snapshot contract. Reauthorize continuation; no issued cursor preserves revoked access. Exact authorized totals are a possible later capability with explicit cost/disclosure approval.

Use module-defined typed field groups for detail disclosure, selected by host policy per object/projection. Requests cannot grant themselves groups. Exact group names/membership, minimum envelopes and a proposed disclosed-group mask need schema review. Distinguish undisclosed fields from legitimate null/empty values; private alarm/credential/internal state remains separately protected. Group grants confer no write permissions.

[Authorized query design](../authorization-queries.md) proposes trusted candidate constraints plus bounded object-policy batches, filtering before visible page boundaries, stable cursors with scope/query/actor/policy binding and explicit limit failures. These mechanics, query/result interfaces, cursor encoding/lifetimes, error behavior and transaction/external-policy consistency remain proposals. No database/HTTP/Flutter implementation is claimed.

Consistency refinement: [ADR 0045](0045-authorization-consistency-guarantees.md) confirms support for transaction-coordinated and external fresh-check guarantees with explicit declaration/no silent downgrade. Concrete algorithms, defaults, deadlines and operation requirements remain proposed.

## Alternatives and consequences

Mixed detail/busy lists complicate identity and source-count disclosure; separate responses keep their meanings explicit. A detail list is not proof of availability. Initial totals add database/policy cost and disclosure rules, so are omitted. Unrestricted field-level policies offer finer control but enlarge response mappings and test combinations; typed groups provide a bounded initial contract. Hosts may deny groups or map them to shared business rules without a fixed role model.

Post-filtering one ordinary database page can produce incorrect visible pagination. Supporting custom object policies therefore requires bounded query integration rather than only a calendar allowlist. Cursor authenticity alone does not ensure confidentiality or current authorization. Local-only state cannot guarantee cross-instance continuation.

## Acceptance conditions

Finalize group-to-view mappings, query constraints/batch results, deterministic ordering, snapshot/version/freshness rules, protected cursors and bounded failure behavior before schema/API implementation. Test interleaved/all-denied objects, complete/unknown busy projections, selective groups/null distinction, protected filter/sort behavior, resource limits, revocation/replay and continuation on two independent hosts. Documentation approval supplies no runtime evidence or external-client compatibility claim.
