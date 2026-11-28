# ADR 0159: Pure incoming range CANCEL projection

Status: **Proposed. The maintainer confirmed newer-than-all-affected-component SEQUENCE policy. Concrete projection, version-floor and result mechanics await explicit approval.**

## Context and evidence

ADR 0158 implements native cutoff cancellation/restoration; implementation PR #147 passed full exact-head hosted inspect/runtime CI. Trusted range notices remain review-only for CANCEL. Existing pure REQUEST/single CANCEL projectors reject native cutoffs, and ordinary source baselines deliberately remain cutoff-free. An incoming cancellation has its own source version; copying it onto the retained master or a timing component would lose independent version meaning.

The maintainer selected incoming range cancellation only when its SEQUENCE exceeds the effective source version at the anchor and all accepted single/later-range components it suppresses. This conservative application policy may reject otherwise usable sender data. It is not a universal RFC freshness requirement, and exact accepted retries must remain possible in a later durable workflow.

Inspected pure occurrence/range projection, cancellation timing/property matching, original membership/effective timing, independent protocol state, native cutoff validation and v1/v2/v3 accepted checkpoints. [RFC 5546 section 3.2.5](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) defines range CANCEL and required SEQUENCE; [RFC 5545 section 3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) supplies original-identity ordering. Source grammar, pure semantics, host authority, persistent freshness and external-client behavior remain distinct.

## Proposed grouped increment

Add a separate pure `projectInvitationRangeCancellation` helper beside the current projectors. Its inputs are protocol UID, accepted content/overrides/protocol state, one parsed scheduling message, recipient address and the existing optional work ceiling. It validates and freezes input values; it performs no SQL, authorization, network access, clock/version allocation, native mutation or automatic reply.

Require one detached THISANDFUTURE CANCEL component with STATUS:CANCELLED, exact UID/organizer/recipient correlation and the existing undelegated participant profile. Require an active recurring accepted master and an exact ordinary DATE/UTC/named-zone effective original after exclusions. Earlier RDATE/PERIOD additions remain valid anchors; excluded/orphan/generated-gap/floating/fractional/profile-mismatched values reject. Whole-master/single/attendee-removal cancellation, patterns on the cancellation and unrelated components reject. Parsing participant claims never establishes identity or authority.

Reject an input that already has a native cutoff. This first helper proposes one cancellation against an unmasked accepted basis; it must not erase a local cutoff or guess an existing cancellation ledger. Previously cancelled individual originals remain valid anchors. For validation only, inspect the selected original's retained effective timing/content while temporarily ignoring its individual cancellation flag; preserve that flag in the result.

Minimal source timing/text omissions remain omissions. If DTSTART/DTEND/DURATION or other supported properties are supplied, require agreement with the anchor's effective preserved timing/content using the existing bounded cancellation profile. Honor single own values, future-anchor own values and master inheritance without propagating anchor content. Any unsupported/differing supplied data rejects; do not discard it. Keep explicit end/duration forms, annotations, source groups and optional protocol dates intact. Source VALARM remains rejected; accepted unarmed alarms remain unchanged and unarmed.

## Affected source-version floor

Require an explicit valid incoming SEQUENCE. Compare numerically with the maximum of:

- The effective component at the selected original: its exact single if present, otherwise the latest range at/before it, otherwise the master.
- The underlying range/master governing the suffix at that position, even when a single controls the anchor. This prevents a low-version single from hiding a newer surrounding segment. Conservatively include it without enumerating whether another non-single original remains.
- Every accepted single and every range at/after the original, including cancelled singles and a co-located timing component.

Use original civil/profile ordering, not moved actual start or source timestamp order. Unrelated earlier singles and superseded earlier ranges do not raise the floor. Missing accepted SEQUENCE counts as zero only for comparison; retain its omission. Incoming SEQUENCE must be strictly greater; an equal value rejects even with a later DTSTAMP. Do not require source timestamps to advance or normalize them. Compare directly, without adding one to a maximum value; a maximum accepted sequence leaves no representable newer cancellation.

The second floor above is an explicit proposed conservative refinement of the confirmed policy: it covers the segment beneath an anchor single. Review it as application mechanics, not a new RFC claim. Pure checks use only the supplied accepted snapshot; the future service must verify that snapshot is current and authorized under transaction/revision fences. Exact durable retries will use their retained acceptance evidence rather than reapply this first-acceptance test to already-cancelled state.

## Result and preserved versions

Return a distinct immutable `CalendarInvitationRangeCancellationProjection` containing validated protocol UID/content, candidate `CalendarEventTimingOverrides` with `cancelledFrom` set to the original, the unchanged validated `CalendarEventProtocolState`, original identity, exact source `CalendarEventProtocolVersion`, the numeric `requiredAfterSequence` floor and the original immutable source message. This is a Dart semantic carrier, not a generated storage/API model.

Keep master, singles, timing ranges, flags, text/metadata and all their independent source versions unchanged, including at the selected anchor. The cutoff suppresses every subsequent original under the selected cancel-all policy, including moved singles and later timing ranges. Do not replace a REQUEST component with the CANCEL or copy the cancellation's version onto the master. Candidate native state and cancellation source version remain separate.

The candidate is not an ordinary accepted file-import baseline and cannot be serialized as one. A later durable contract must bind a private cancellation/source layer to the retained cutoff-free accepted basis, revisions, permissions, retries, master composition and cleanup. Do not weaken `validateEventImportBaseline` or export guards to store this proposal as source data. Native restoration policy alone does not authorize restoring an accepted source cancellation.

## Bounds, alternatives and follow-up

Reuse current syntax/source/component limits and one aggregate `RecurrenceWorkBudget` through accepted-state validation, membership, effective anchor checks and merged validation. Keep the 200,000 work ceiling and combined 128 native override slots; the cutoff costs its own slot. The version scan is bounded by stored components and never enumerates an unbounded suffix or manufactures single cancellations. Invalid/budget failures return no partial proposal and use non-echo diagnostics. Preserve unrelated native exceptions without exporting them through a smaller wire-component cap.

Replacing a timing-range component would lose its data/version; truncating recurrence or expanding future EXDATEs would lose identities or require unbounded work. A separate projection/cancellation version preserves the intended layers, but does not solve persistence or synchronization by itself.

No table/SQL/generated protocol/endpoint/Flutter/feed/worker or dependency change is proposed. Existing durable range CANCEL and source-cutoff guards remain. Later work must review acceptance storage/layer binding, independent cancel authority, clean-series comparison, command retries, continuing cancellation/version floors, master composition, explicit source restoration and two-host/worker behavior. Outgoing range CANCEL, range replies, ordinary wire mapping, tasks/openings and real mail remain separate.

## Acceptance conditions

After explicit maintainer agreement, implement and test DATE/UTC/zoned anchors, earlier/PERIOD additions, single/future co-location, moved/later exceptions, retained individual cancellation, end/duration/DST meaning, minimal omissions and matching/differing source properties. Verify preserved component versions/source dates, null-as-zero comparison without normalization, equal/lower/higher and maximum sequence, high-version later exceptions, the anchor-single/underlying-segment case and unrelated earlier versions. Cover current-cutoff, pattern/identity/participant/profile rejection, horizon/work/slot/source limits, immutability and no partial result. Existing single/range REQUEST tests remain regressions.

Use focused VM development tests, then formatting/workspace analysis, complete core/iCalendar VM+Chrome and module suites plus affected native/range database guards at batch completion. Full repository CI remains the readiness gate. Commit only the completed agreed batch and record actual/deferred evidence; pure success is not durable cancellation or interoperability support.
