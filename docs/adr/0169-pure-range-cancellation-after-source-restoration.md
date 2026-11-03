# ADR 0169: Pure range cancellation after source restoration

Status: **Accepted by explicit maintainer agreement on 2026-11-03, including the historical restoration floor and pure API/result mechanics.**

## Context and next batch

[ADR 0168](0168-range-request-applications-after-source-restoration.md) implemented range REQUEST application after restoration. PR #167 passed full hosted inspect/runtime for commit edf9779a4f50f82968237cbf7a27bde895be84e2. The subsequent Serverpod 4.1.0 maintenance batch passed its recorded local checks; its exact-head hosted runtime remains separately pending when checked.

A later THISANDFUTURE CANCEL is still blocked after restoration. Complete repeated cancellation/restoration needs a separately reviewed durable history format, source retention, authority, receipts and composition. First add the missing pure version/projection prerequisite without changing those guards or selecting that storage design. This is a grouped pure batch covering all timing profiles, preservation, limits and rejection regressions; it does not claim authenticated cycle support.

[RFC 5546 section 3.2.5](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) defines range cancellation through RECURRENCE-ID with RANGE=THISANDFUTURE. Our current stricter freshness and source profiles remain application choices, rather than a claim of unrestricted RFC support.

## Approved pure API and result

Add a separate exported projectInvitationRangeRecancellation helper alongside projectInvitationRangeCancellation. Require the same protocol UID, current canonical content/overrides/protocol state, source message, recipient address and bounded candidate-work input, plus a previousRestorationVersion. The distinct entry point makes the extra requirement explicit; the existing first-cancellation helper and its callers retain their current behavior.

Validate the supplied previous restoration version using existing protocol-version validation: non-null SEQUENCE in 0..2147483647 and legal whole-second UTC timestamps/optional values. Zero is a valid untrusted comparison input, not proof that the durable workflow could have accepted such a restoration. Missing, invalid, fractional or out-of-profile values reject. No default version is invented.

Return a final-field CalendarInvitationRangeRecancellationProjection with defensively detached validated values containing the same candidate content/overrides/protocol state, exact original, source message and cancellation version, plus the validated previous restoration version and combined requiredAfterSequence. This is a handwritten pure carrier, not a generated model, storage field or endpoint DTO. Do not expose a nested first-cancellation result whose comparison floor contradicts the combined result.

Share the validated internal projection path with the existing helper. Do not reparse/revalidate or expand recurrence twice with separate work budgets to implement a wrapper. The public first helper remains behaviorally unchanged; sanitize diagnostics and preserve existing limit-error distinctions.

## Conservative source-version floor

Require incoming explicit CANCEL SEQUENCE strictly greater than both:

- The existing range-cancellation floor: the underlying master/range at the selected anchor, including beneath an anchor single, and every affected accepted single/later-range component in original order.
- The supplied previous restoration SEQUENCE, independently of its timestamp or canonical component versions.

The maximum of those values is requiredAfterSequence. Missing retained canonical component sequences continue to compare as zero while their omissions remain intact. Equal sequence with a later DTSTAMP never waives either floor. An exhausted maximum rejects without allocating an increment or partially returning a candidate.

For example, canonical floor 4 plus previous restoration 10 rejects CANCEL 10 even with a later clock, and permits 11 only if all other checks pass. Canonical floor 20 plus restoration 10 still rejects 11 or 20. Backwards incoming source timestamps may remain exact when the sequence and existing profile checks succeed; timestamps are not authority or a database audit clock.

This historical floor is the approved conservative application policy, not a universal RFC rule and not already implied by the approved range REQUEST policy. A later durable workflow must establish which restoration is actually accepted and bind it to the current series; callers cannot establish that by passing a version to this pure function.

## Candidate semantics and preserved data

Require an active supported recurring master, no current native cutoff and the existing bounded CANCEL/source-property/participant profile. A new cancellation may name any exact original member of the current accepted recurrence set; it need not reuse the former restoration anchor. The supplied historical version does not authenticate an earlier anchor. Preserve DATE/UTC/exact named-zone meaning, PERIOD additions, earlier inclusions, exclusions and DST rules.

Apply the already-confirmed cancel-all policy: suppress the selected original and every later original, including moved singles and later timing ranges, while retaining their timing, content, inheritance, individual cancellation flags and independent canonical versions. Original identity, not moved start time, determines the suffix. Preserve the current master, source metadata and unarmed alarms. Do not replace a canonical REQUEST component with the new CANCEL or copy either control version onto native components.

Retain existing checks for any supplied CANCEL timing/content. Minimal legal CANCEL source stays minimal; no missing DTSTART/summary/source version is manufactured. Whole-cancelled masters, an existing cutoff, missing membership, wrong kind/zone/UID/claims, delegation, unprofiled data and budget exhaustion reject as before. Overlapping active cutoffs and restoration-plus-rescheduling remain separate designs.

Keep the ordinary accepted import baseline cutoff-free. The pure candidate is neither an accepted baseline nor an export/feed projection, and cannot authorize restoring or applying a source cancellation. Preserve all current masked export/feed guards.

## Limits, trust and scope

Use existing whole-second [1970-01-01, 2100-01-01) timing, explicit exclusive-end handling, pinned zones and source/zone/slot ceilings. Charge one shared recurrence-work budget through content/override validation, exact membership, comparison and candidate validation. Never report partial coverage or infer that an exhausted scan found no conflicting component.

Native candidate slots remain separate from private durable history capacity; this helper does not reserve a cycle slot or prove that retained source history fits. No database, JSON checkpoint version, source-history replacement/pruning, retention expansion, permission change, generated API, migration, dependency, UI, queue or network action is proposed. Existing v1-v11 service reads/retries/guards remain unchanged. No reply, delivery or automatic arming follows.

## Alternatives and consequences

Using only canonical versions could let an old range cancellation undo a newer restoration because restoration intentionally preserved canonical component versions. Rewriting canonical versions would violate the accepted source-preservation policy. Passing an optional history floor into all existing cancellation paths would make the required restored-state distinction easier to miss; a separate pure entry point keeps it explicit. Replaying full private checkpoints in this helper would mix the pure and durable boundaries.

This increment deliberately does not solve repeated durable cycles. Their bounded, nonrecursive evidence format, unchanged byte/slot limits, legacy proof retention, actual historical/current source authorization, current-kind flags, receipt supersession and subsequent master/single/range composition need the next concrete ADR review. No old proof is discarded by this proposal.

## Validation and acceptance

The approved batch adds focused pure VM cases for DATE/UTC/named zones, gap/fold anchors, exact versus moved originals, earlier/PERIOD additions and exclusions; same-anchor singles/underlying ranges/later components; both independent floors, missing/zero/equal/maximum sequences, later/backwards timestamps and source omissions; unchanged inheritance/flags/versions/metadata/alarms; input nonmutation, detached result ownership, immutable source messages and bounded work/source/zone/slot failures. Retain all existing first-CANCEL and restore-only regressions. Include repeated pure CANCEL/restore-only round trips, at the same and different anchors, using the existing restore helper with each new independent cancellation version; verify that every successive control version advances without rewriting canonical versions. This closes the pure cycle prerequisite as one batch.

At batch completion run formatting and full fatal-info analysis, complete module VM/Chrome suites and directly affected native guard regressions. Core/iCalendar semantics are unchanged; rerun their suites only if source/dependency changes or failures justify it, with the full repository CI still required before readiness. No database or Flutter execution claim follows from pure tests. Commit/push code only after the complete approved batch; documentation approval is not implied by merging this proposed ADR.


## Scoped implementation

See [the pure helper profile](../range-recancellation-projection.md) and [actual validation](../scaffold-validation.md). Durable cycle guards remain unchanged; their history format and workflows require separate review.
