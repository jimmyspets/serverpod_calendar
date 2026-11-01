# ADR 0154: Trusted range invitation intake and private review

Status: **Accepted 2026-11-01 by explicit maintainer approval of the proposed batch and model/authority mechanics. Implementation and validation are recorded separately.**

## Context and evidence

ADRs 0149–0153 implement known-series single-instance intake, explicit calendar application/composition and selected-instance participation replies. The pure iTIP adapter accepts detached RANGE source components, but trusted recipient intake rejected every THISANDFUTURE component before this batch. Native future cancellation and range reconciliation still need their own policies; they cannot be inferred from the pure codec or single-instance actions.

Inspected native intake parsing/source validation, per-target uniqueness and version ordering, retained receipts, known-series basis lookup, source pruning, host/MIME adapters, single/master application guards and response workers. The existing entry table stores an opaque target key plus typed original, and its unique index already includes that key. Source kind is stored as text. [RFC 5546 REQUEST](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.2), [CANCEL](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) and [instance handling](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.7.1) supply protocol context, alongside [RFC 5545 RANGE](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.2.13) (checked 2026-11-01); the queue, authority and retention mechanics below are application policy.

## Approved grouped scope

Admit one verified known-series detached REQUEST or CANCEL with RECURRENCE-ID;RANGE=THISANDFUTURE into the existing private review queue. Preserve original DATE/UTC/exact named-zone anchor, source timing/end/duration forms and omissions, protocol versions and selected source properties. Minimal cancellation remains unanchored source data when timing is omitted; never manufacture DTSTART from the original. Reject bundles, unknown series, unsupported range tokens, delegation and unprofiled source data under the existing bounded parser/ingress limits.

New admission requires the current retained active recurring master REQUEST, otherwise a validated linked accepted baseline, with exact scope/recipient/UID/organizer and original membership/profile. Reuse existing bounded known-series validation and verified-origin resolution; source participant claims do not grant authority. A known cancelled or incompatible basis rejects new admission. Unavailable proof fails unavailable. An exact retained ingress retry remains separately authorized before new-source/basis admission and never reactivates or dismisses a newer source.

This increment is intake, private source/summary review and dismissal only. It changes no event, accepted baseline/checkpoint, personal response, availability, alarm, native generation or outbound message. A range notice does not cancel future native occurrences, move a series, choose precedence among overlapping ranges or imply that a later application is representable. Source review success is not range reconciliation or interoperability evidence.

## Approved target and model refinement

Reuse the three invitation entry/source/receipt tables and current quotas, byte budgets and retention. Keep existing `master` and `instance-v1` keys unchanged and add a domain-separated `range-v1` key using the same exact typed-original identity fields. A single and range at one anchor remain distinct entries; different range anchors remain distinct source targets. Do not flatten overlapping ranges into one entry or retarget a retained receipt.

These keys partition private review, not RFC component identity. A later reconciliation contract must coordinate notices sharing UID/original and overlapping ranges. This review-only slice does not reinterpret existing master/single action eligibility or delivery state from a range notice; that cross-target lifecycle coordination remains a release requirement, not an inferred feature of intake.

Bind stored source RANGE presence to the actual target key and typed original for current and historical sources. Unknown prefixes, mismatched kind/original/range or corrupt source bindings fail unavailable. Keep REQUEST kind, add a distinct `rangeCancellation` source kind, and expose a derived default-false `isThisAndFuture` on protected invitation views. No new SQL table/column/index or retention expansion is proposed; generation and schema inspection must confirm that existing text/index storage remains unchanged. Upgrade all hosts/clients together; mixed old/new writers are unsupported.

Ordering/deduplication is per exact range target using existing SEQUENCE/DTSTAMP rules and retained receipt/criteria checks. An accepted range **notice** is not an accepted native range action, and this review path imposes no invented aggregate cancellation version floor over master or single components. Future application/version precedence requires a separate reviewed contract.

## Approved authority and guarded APIs

Require dedicated `receiveRange` authority alongside ordinary REQUEST/CANCEL receive gates, with trusted recipient/scope, exact source/range/original, current/proposed selected entry and the complete known-series basis. Preserve preliminary/final checks and declared coordination guarantees; fresh external authority still has its documented revocation race. Summary, raw source and dismissal remain independently authorized with actual range context.

Master-only adoption/link/application remains master-only. Existing single-occurrence preview/application and all personal-response read/activity/send paths must reject range entries explicitly on the server before correlation fallback or history lookup. Worker/record validation must never turn a range into a single reply by dropping RANGE. Preserve normal master/single behavior and exact historical retries; no range actions are enabled by a UI omission or by sharing an original.

Flutter labels the original as the first affected source anchor and clearly marks the notice review-only. Show preserved source/moved timing separately, allow explicit dismissal and offer no calendar-apply or participation action for ranges. Extend only synthetic development/test MIME simulators, generated clients and focused journeys; real email remains unauthorized.

## Validation and consequences

Test DATE/UTC/named-zone/DST anchors, absent cancellation timing, full-horizon zone validation, exact source versions and same-original single/range separation. Cover stale/duplicate ingress, retained retries across newer notices/pruning, unknown/removed/cancelled basis, independent/final authority rollback, quotas, source corruption and fail-closed guards on every mutation/response path. Exercise actual two-host shared/distinct-target races, process loss before/after commit, exact synthetic MIME ingress, generated clients and Flutter, then complete agreed batch checks before one implementation code commit.

Executing ranges immediately would assume unreviewed future cancellation, overlap and restoration rules. Treating a range as a single occurrence would silently change its meaning. Reusing the target-aware queue preserves independent source data without another history store, at the cost of a clearly bounded review-only step. Native range application, future cancellation/restoration, range participation responses, arbitrary-original sending, other methods and real transport remain required separate work.

The maintainer explicitly approved this concrete target/protocol/authority/model batch on 2026-11-01. See [the scoped implementation guide](../range-invitation-review.md) and [actual validation](../scaffold-validation.md). Approval does not extend to native range application or responses.
