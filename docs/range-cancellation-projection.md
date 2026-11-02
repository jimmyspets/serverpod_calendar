# Pure incoming range CANCEL projection

Accepted [ADR 0159](adr/0159-pure-range-cancellation-projection.md) adds `projectInvitationRangeCancellation` and its distinct `CalendarInvitationRangeCancellationProjection` result. It proposes one cancellation against an unmasked supplied basis. It performs no SQL, permission check, native write, source acceptance, version allocation, notification or network operation.

## Supported proposal

Require an active recurring master, one detached THISANDFUTURE CANCEL with explicit STATUS:CANCELLED/SEQUENCE, and exact UID/organizer/recipient correlation under the existing undelegated profile. Source addresses are claims; their agreement is not authentication. Whole-master, single-instance and attendee-removal cancellation remain different operations.

Validate original effective recurrence membership in the exact DATE/UTC/named-zone profile. Earlier explicit inclusions/PERIODs are valid; orphan/excluded/generated-gap originals reject. Explicit gap inclusions retain the selected resolution rules. Existing whole-second ordinary `[1970,2100)` and exclusive-end rules remain. A supplied current cutoff rejects rather than being erased or interpreted as an accepted cancellation ledger.

The result sets `cancelledFrom` at the selected original while preserving all master content, singles, individual flags, timing ranges, source metadata and their independent protocol versions. Later moved/edited exceptions are suppressed by original order, including those moved earlier than the cutoff. A previously individually cancelled anchor remains a valid original: the helper inspects its retained timing with its flag ignored only in a temporary validation copy, then preserves the flag in the result.

Source timing/text omissions stay absent. Supplied timing must agree with the anchor's effective retained timing. Supplied text/parameters and richer metadata follow the existing bounded cancellation matching profile, including single or future-anchor own data and master inheritance. Explicitly conflicting annotations reject; omission does not synthesize annotations or widen the existing matching rules. Unprofiled data rejects rather than being discarded. The scheduling parser already rejects RRULE/RDATE/EXDATE and VALARM in this CANCEL profile. Accepted master alarms remain preserved and unarmed.

## Strict source-version floor

Incoming SEQUENCE must exceed the maximum of:

- The effective single/range/master version at the original.
- The range/master beneath that position, even when a single controls the anchor.
- Every accepted single or range at/after the original, including cancelled singles and co-located timing components.

This includes the underlying segment conservatively even for a last-member anchor single. Earlier unrelated singles and superseded ranges do not raise the floor. Compare original civil fields, not actual moved starts or resolved UTC ordering. No unbounded suffix is expanded just to find versions.

An omitted accepted SEQUENCE compares as zero but remains omitted. Incoming SEQUENCE is required; equality rejects even with a later DTSTAMP. Higher SEQUENCE can retain an older source timestamp exactly. Comparisons do not increment a maximum sequence or invent source values. These are selected conservative application rules, not universal RFC freshness rules.

## Separate cancellation source version

| Result field | Meaning |
| --- | --- |
| `protocolUid`, `content` | Validated supplied identity/content; no authority established |
| `timingOverrides` | Immutable retained timing/components plus candidate cutoff |
| `protocolState` | Unchanged validated master/component versions and source-presence flags |
| `originalStart` | Exact typed original targeted by the cancellation |
| `cancellationVersion` | Exact incoming SEQUENCE/DTSTAMP/optional CREATED/LAST-MODIFIED |
| `requiredAfterSequence` | Maximum numeric comparison floor, without normalization of retained versions |
| `sourceMessage` | Original immutable parsed message, retaining source omissions |

The cancellation version is never copied onto a master or retained REQUEST timing component. The candidate is not an accepted ordinary file-import baseline: existing cutoff-free baseline validation and export guards reject treating it that way. A future service needs separate source-layer binding, current/revision/authority verification, clean-series checks, atomic writes, exact receipts and master composition. Reusing a previously accepted receipt must not reapply first-acceptance checks to already-cancelled state. Native restoration alone does not authorize source-cancellation restoration.

## Budgets and integration limits

One aggregate `RecurrenceWorkBudget` covers accepted-state validation, original membership, effective-anchor validation and merged cutoff validation, under the existing 200,000 ceiling. A cutoff consumes one of the combined 128 override slots, even at an existing component anchor. Unrelated retained exceptions do not pass through a smaller wire-export component cap. Reapply ordinary syntax/source limits even if the caller parsed with larger limits. Limit/invalid failures return no partial candidate and use non-echo diagnostics.

The helper and result are exported by the existing server library and use generated immutable carriers; no generated source/model/schema/endpoint change is introduced. Existing single/range REQUEST behavior and durable range CANCEL guards remain. Authenticated range application, accepted cancellation layers, source restoration/composition, outgoing messages, ordinary wire mapping, range replies and real mail are separate required work.

Focused tests cover source/version independence, old/equal/maximum sequences, underlying and later versions, unrelated earlier versions, moved exceptions, DST, earlier additions/PERIODs, metadata/identity/profile rejection, work/source/slot bounds and immutable detached results. See [actual validation](scaffold-validation.md) and [focused development commands](development.md). Pure success establishes no durable reconciliation or external-client support.


## First durable range cancellation

[Accepted ADR 0160](adr/0160-first-range-cancellation-acceptance.md) implements explicit first incoming range-CANCEL acceptance with a separate private v4 layer, verified expected-native digest and cutoff-free ordinary baseline. Dedicated cancellation authority/API, protected views, atomic invalidation and exact write-free retries apply. New source applications temporarily reject after acceptance, including after local cutoff restoration; source composition/restoration remains separate. Existing component versions, SQL schema and retention caps are unchanged. See [the implementation profile](range-cancellation-acceptance.md) and actual validation for the supported boundary.
