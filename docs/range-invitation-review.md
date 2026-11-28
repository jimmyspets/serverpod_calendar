# Trusted range invitation review

Accepted [ADR 0154](adr/0154-trusted-range-invitation-review.md) adds private review of one verified known-series REQUEST or CANCEL with `RECURRENCE-ID;RANGE=THISANDFUTURE`. This is source intake, review and dismissal. It changes no calendar event, accepted source checkpoint, personal participation choice, free/busy, alarm or outbound intent.

## Admission and identity

Trusted host ingress resolves recipient/scope and verified organizer origin before private state is disclosed. Source participants never establish authority. Require one supported detached component, exact DATE/UTC/named-zone original, existing source budgets and a current active recurring master REQUEST, falling back to the linked accepted baseline only when that retained source is unavailable. Validate exact original membership/profile and roster against that basis, independently of local drafts. A known cancelled, removed or incompatible basis rejects new admission; missing/corrupt/exhausted proof fails explicitly. The calendar date and whole-second profile is unchanged.

The original anchor is the first affected source original, not the moved DTSTART. Omitted cancellation timing, including an otherwise legal DURATION without DTSTART, remains unanchored source data. Review never fabricates a start or claims future native cancellation is implemented.

The existing entry/source/receipt tables retain their limits and retention. Existing `master` and `instance-v1` identities stay unchanged; `range-v1` uses the same exact kind/zone/civil identity with a separate prefix. One range and one single at the same anchor, and ranges at different anchors, remain separate review entries. These private partitions are not a claim that RFC component identity contains RANGE. Later reconciliation must coordinate same-original and overlapping notices.

REQUEST keeps its existing kind; CANCEL uses `rangeCancellation`. Protected immutable views derive `isThisAndFuture`; pruned markers retain kind, target and original. For every retained current/historical source, validate RANGE presence against the exact target as well as UID, organizer, original, digest, size and source version. Unknown target namespaces, corrupt bindings and unsupported source data fail unavailable rather than being repaired. No SQL schema change is required; upgrade hosts/clients together.

## Ordering, authority and actions

Ordering/deduplication uses the existing SEQUENCE/DTSTAMP rules independently per exact range review target. Cancellation must advance that target's retained REQUEST history; first admission uses the known basis floor. No aggregate native cancellation floor over sibling components is invented. Exact retained ingress retries reauthorize and return their receipt before new-source/basis admission, never reactivating a dismissed entry or dismissing a newer notice. Queue pruning does not invent missing body evidence.

`receiveRange` is independently required alongside ordinary receive and, for CANCEL, receiveCancellation. It replaces the single-only receiveOccurrence gate for ranges. Host context contains the complete parsed source, exact range/original, actual selected entry/proposed result and known-series basis when available. Preliminary/final checks and the declared consistency guarantee apply; fresh external checks retain their documented revocation race. Summary, source and dismissal keep their independent gates and actual range view context.

All master-only link/adoption/application and single-only preview/application APIs reject ranges on the server before correlation fallback. Personal response read/activity/send require source-read authorization before returning a type-specific range rejection, and reject before response-state/history lookup; worker/retained-record validation cannot drop RANGE to manufacture a single reply. Ordinary master/single choices, eligibility and delivery are unchanged by range receipt in this review-only increment. Cross-target lifecycle coordination remains required release work.

The Flutter example labels “this and future”, shows the original anchor separately from moved source timing, permits source/history review and dismissal, and offers no calendar or participation action for range notices. Fixed development/test simulators use synthetic MIME and trusted host ingress; they expose neither arbitrary sender proof nor production email.

## Validation and remaining scope

Focused coverage exercises DATE/UTC/named-zone/DST anchors, omissions, exact versions, single/range separation, historical retries, known-series failures, preliminary/final authorization, shared quotas and current/historical source corruption. All calendar/response action guards are tested independently of UI visibility. Two independent hosts exercise same-command/distinct-target races and actual process loss around commit. Generated clients and Flutter exercise exact synthetic MIME and review/dismissal. See [actual batch evidence](scaffold-validation.md) for commands/results; this guide does not establish external client interoperability.

Native range application, future cancellation/restoration, overlapping-range precedence and versions, range participation, arbitrary-original sending, wider methods and real transport remain separate required work. Ordinary import/export and HTTP feeds retain their own contracts.
