# ADR 0187: Durable exceptional-anchor range controls

Status: **Proposed; explicit maintainer agreement is required before implementation.** This document proposes no change to the current runtime guard.

## Context

[ADR 0172](0172-durable-published-range-controls.md) admits range cancellation only when the published original can already be restored faithfully. It rejects an anchor with a published single component or individual cancellation. [ADR 0186](0186-exceptional-range-restoration-projection.md) now provides a bounded pure REQUEST candidate for moved and excluded anchors; it does not establish publication history, authority or durable outgoing versions. See [the pure profile](../exceptional-range-restoration-projection.md).

This proposal groups cancellation, restoration and subsequent repeated cycles for the exceptional cases that can be proved faithfully representable. It keeps all existing restrictions for unprovable candidates and is not a claim about arbitrary RFC client behavior. It does not add a provider, send real mail, deploy or publish packages.

## Proposed boundary and provenance

Use the existing explicit range cancel/restore APIs, native-created organizer bindings, exact original identities, fixed recipients, independent permissions and terminal-prior-delivery gate. An exceptional anchor can be admitted only if the last published unmasked REQUEST basis and all retained publication identities validate, and a complete future restoration is constructed and checked **before** committing cancellation. Native drafts never supply the published basis and are not overwritten by a historical command.

Distinguish an ordinary source EXDATE from a module-owned individual cancellation. The latter requires a validated retained individual-cancellation ledger and exact original/profile/membership proof; an EXDATE by itself never authorizes unmasking or proves cancellation. Derive the unmasked basis from authenticated self-contained checkpoint evidence, run the pure candidate against it, then reapply every independently cancelled original as a publication-only exclusion. Check that the selected cancelled anchor and all other individual cancellations remain excluded and that source EXDATEs and private native flags remain unchanged. Reject overlapping or ambiguous identities, altered source exclusions, missing/pruned proof, scope/profile changes and unsupported message shapes rather than guessing or restoring an individual cancellation.

The first profile is bounded to inputs the pure helper can completely prove, including finite COUNT/UNTIL rules and the existing DATE/UTC/exact named-zone horizon. Unbounded rules, an incompatible single at the needed successor, unrepresentable PERIODs, unsupported source metadata and exhausted work/byte/64-original limits reject without mutation. This is an additional exceptional-anchor restriction only; existing ADR 0172 ordinary-anchor support must not regress. Expanding this profile remains required work.

## Proposed checkpoint and outgoing versions

Keep all storage in the four approved organizer publication/outbox tables and existing bounded columns. A flat version-8 checkpoint would extend the current version-7 facts with a typed exceptional-anchor proof: selected original/profile, unmasked-basis digest, immutable pure candidate or equivalent bounded reconstructable data, retained individual-mask identities, and digests of the final masked message and relevant component/version ledger. The complete encoded state, including any candidate bytes retained for validation, must fit existing byte, slot and retention caps. No nested v8 history, new SQL columns or automatic eviction is permitted. A capacity failure rejects before changing native state, generation, receipts or deliveries.

The candidate's copied master SEQUENCE/DTSTAMP is only a pure-validation placeholder. Allocate every outgoing component's scheduling version under the existing collision-safe/floor and overflow rules, including new single/future projections and effective-component reply selection. Revalidate the complete actual REQUEST after applying versions and masks, not merely the placeholder. Original source/native versions and inheritance remain untouched. Preserve v1–v7 reads, historical exact-retry/no-op behavior and self-contained active proof after earlier terminal records are pruned; corrupted, inconsistent or unsupported checkpoint data fails closed.

## Proposed transaction and delivery

Require the existing complete-message, range, lifecycle, scheduling-read and full-source/detail host checks against immutable published and proposed native snapshots at preliminary and final phases. Preserve declared coordinated/external policy guarantees and reauthorize exact retries without reactivating them. Atomically commit the cutoff, versioned checkpoint, complete publication intent and fixed-recipient deliveries under current database fencing. Only install or clear a native cutoff when the existing exact-profile, membership and unchanged-revision ownership conditions are satisfied. Existing active-cutoff restrictions, prior-delivery gate, fenced retries, stable transport identity and actor-free dispatch rechecks remain.

Restoration sends complete published values derived from the proved basis, not newer drafts; it removes only the owned range cutoff and retains independent cancellations and their ledger. Subsequent Save and notify, individual controls, whole lifecycle and another range cycle must preserve existing version and orphan guards. No client can supply the restored content or cancellation ledger.

## Proposed acceptance and validation

- Exercise active single anchors, retained single/reset anchors and individually cancelled anchors; distinguish module-owned masks from source exclusions. Cover DATE/UTC/exact aliases, DST gaps/folds, COUNT/UNTIL, finite last originals, RDATE/PERIOD and moved exceptions crossing the anchor.
- Prove unchanged effective timings/content, every retained individual cancellation, independent source versions and native draft values before and after actual serialized/masked messages. Test unsupported successor collisions, orphaning, unbounded/horizon uncertainty, 64-slot, byte/work and version overflow rejection with no partial writes.
- Test v7 legacy reads/retries, v8 malformed/tampered bindings, pruning/reconstruction, repeated cycles, unrelated retained and historical retries, competing commands, independent host-policy denial, changed routes/revocation and worker lease/process-loss recovery.
- Cover generated client and Flutter control journeys, synthetic MIME and two active host processes. Run focused tests during work, then complete core/iCalendar/module VM and Chrome checks and affected SDK/database/process/Flutter checks. Full exact-head hosted checks are required before readiness; real-client and real-mail evidence remain separate.

The maintainer must explicitly approve this concrete checkpoint, provenance, version and transaction contract before implementation under the repository's ADR review rule.
