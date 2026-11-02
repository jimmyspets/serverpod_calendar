# ADR 0163: Pure restore-only range source projection

Status: **Proposed. The maintainer confirmed restore-only/same-cutoff/preserve-retained-values behavior; concrete pure-profile mechanics require explicit approval.**

## Context and bounded scope

[ADR 0162](0162-master-lifecycle-with-accepted-range-cancellation.md), implemented in PR #155, supports whole-master cancellation/reopening while retaining accepted range cancellation. Grouped local, client and Flutter checks passed; implementation-head hosted inspect passed and runtime remains in progress. New source-cutoff restoration is still guarded.

The maintainer selected a first restore-only action: a newer THISANDFUTURE REQUEST at the exact saved cutoff, matching retained uncancelled values, clears the entire cutoff and preserves exceptions. A request that also reschedules or uses another original follows separately. Implement the pure validation/candidate helper first; do not lift durable service guards or infer acceptance from a proposal.

Add `projectInvitationRangeRestoration` and immutable `CalendarInvitationRangeRestorationProjection` in the existing exported invitation occurrence-values library, using a dedicated part if useful. Inputs are protocol UID, current content/overrides/protocol state, the independently supplied accepted cancellation version, typed scheduling message, recipient address and bounded candidate-work option. The result separates retained canonical state from source restoration version/floor and exact original. No table, generated model, endpoint, private checkpoint version, UI action, dependency or delivery change is proposed.

## Identity and input profile

Require an active recurring DATE/UTC/named-zone master and an existing validated cutoff. The whole master must be reopened separately if cancelled. A native cutoff or supplied cancellation version alone proves neither accepted source provenance nor permission; later trusted reconciliation must verify both against its private checkpoint.

Require exactly one detached THISANDFUTURE REQUEST, the same exact UID and original kind/zone/civil identity as the saved cutoff, and exact recurrence-set membership. Use RECURRENCE-ID for identity, never its moved DTSTART or instant order. Preserve EXDATE precedence and earlier/PERIOD additions. No different anchor, floating time, fraction, recurrence pattern/date additions on the override, extra component, scheduling delegation or alarm is accepted. Continue the existing known-zone/full-horizon source validation and ordinary 1970–2099 profile without widening either.

Reuse the existing bounded organizer/recipient claim checks: a retained organizer exists, the source organizer address agrees, the recipient appears in retained and supplied attendees, and unprofiled sent-by/delegation claims reject. These are data checks only; participant addresses never establish host identity, sender trust or authority. A detached pure component does not prove a stored series exists.

## Match retained values without rescheduling

For comparison, remove the cutoff temporarily and resolve the anchor through retained single/future timing and content. If the anchor has an individual cancellation, lift that flag only for comparison. The output must retain every actual individual cancellation, including at the cutoff itself. A source restoration is not replacement of that canonical exception.

Require supplied DTSTART and the complete supported timing representation to match the retained uncancelled anchor: exact DATE/UTC/named-zone profile and civil fields, with matching end/duration form and preserved nominal duration units. Do not accept merely equal instants with a different civil value/profile, silently change nominal units or reinterpret an omitted end as a retained positive interval. Existing default-end rules apply only when they produce the same supported retained form. This intentionally bounded first profile can reject alternative representations that require a wider equivalence policy.

Supplied basic text, transparency, descriptive/source metadata, participants and legal annotations must agree under the existing bounded property/parameter profile; unsupported distinctions reject. Omitted inheritable properties preserve their retained values and source distinctions. No native CONFIRMED default is applied to omitted source STATUS. If STATUS is supplied, it must match the active retained comparison status. An individual cancellation remains in the result even when the comparison uses its underlying active status.

Preserve current content, timing/end/duration meaning, recurrence/additions/exclusions, canonical single/future edits, metadata/annotations/groups/alarms and every master/component protocol version. Only clear `cancelledFrom`, using the existing canonical nullable/empty-override convention. Do not allocate or pin a timing exception, replace a co-located component, drop an old edit or overwrite inherited/native values. Tests must cover own/inherited matching and reject any unsupported supplied difference rather than flattening it.

## Independent restoration version and work

Validate the supplied accepted cancellation version, including its required non-null SEQUENCE and whole-second UTC source timestamps. Treat it as untrusted evidence supplied by the caller; the helper does not authenticate it or reconstruct a stored source history.

The incoming REQUEST must have SEQUENCE strictly greater than that cancellation version and the existing range-CANCEL comparison floor: effective anchor component, underlying range/master beneath a single, and every accepted single/later-range component at or after the cutoff in original civil order. Omitted retained component SEQUENCE compares as zero without rewriting its omission. Reuse the approved underlying-segment rule; do not compare moved starts or let a later DTSTAMP waive this conservative restoration floor. Exhausted work cannot prove a lower floor or membership. Maximum versions can make a new restoration unrepresentable.

Return the exact validated original, independently validated cancellation/restoration source versions, required sequence floor and immutable source message alongside the candidate canonical content/overrides/protocol state. Preserve source DTSTAMP and optional CREATED/LAST-MODIFIED and their omissions separately; do not copy them onto retained native components or invent database audit time. The proposal is not a new accepted import baseline, scheduling freshness guarantee or durable retry receipt.

Apply the existing syntax/component/zone/source-size/slot and candidate-work ceilings, charging raw work before filtering/deduplication where required. Share bounded recurrence work across input validation, membership/comparison and cleared-cutoff candidate validation. Sanitize diagnostics and preserve existing limit-error distinctions. Do not mutate input state or cache permission/source decisions.

## Consequences and alternatives

Reusing ordinary range replacement would allocate/change a component and can collide with a retained single, contrary to restore-only behavior. Clearing the native flag without checking source identity/version/content would accept an unrelated or stale request. Restoring and rescheduling together would need additional replacement/overlap semantics. The proposed independent pure candidate preserves all current values at the cost of a deliberately stricter matching profile.

An accepted candidate still needs a separately reviewed durable contract: actual accepted-cutoff/source binding, clean-state comparison, restoration evidence/version retention, independent authority, revisions, concurrency/retries, master composition, privacy/quota/deletion, invalidation and generated-client/Flutter behavior. No current v4/v5/v6 service/API guard changes in this pure batch. Ordinary wire export/feed support and outgoing range restoration are separate from this scheduling-data proposal.

## Validation and acceptance

After explicit approval, cover DATE/UTC/named zones/DST gaps/folds, whole-second/exclusive-end limits, exact versus moved identity, earlier/PERIOD originals, same-anchor single/future edits and individual cancellations, preserved inheritance and source metadata/omissions. Test every mismatched timing/content/profile/participant/status case; different anchors, missing cutoffs, cancelled masters, unprofiled recurrence/alarms/delegation; equal/lower/maximum/omitted version values, underlying/later floors and work/size/slot exhaustion. Verify detached immutable results, no canonical version changes and unchanged prior pure range/single/cancellation behavior.

Use focused pure VM tests during development. At batch completion run formatting/full workspace analysis, complete core/iCalendar VM+Chrome, module VM/Chrome and relevant native source-lifecycle regressions before one code commit. Full implementation-head repository CI remains the readiness gate. Pure tests do not establish authenticated restoration, persistence, external-client interoperability or delivery support. Explicit maintainer agreement is required before implementing these protocol/model mechanics.
