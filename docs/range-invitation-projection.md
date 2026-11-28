# Pure range REQUEST projection

Accepted [ADR 0155](adr/0155-pure-range-invitation-projection.md) adds `projectInvitationRangeRequest` to the Serverpod value-adaptation layer. It proposes one detached THISANDFUTURE REQUEST against complete accepted UID/content/override/protocol values, returning the existing immutable `CalendarInvitationOccurrenceProjection`. It performs no SQL, permission check, clock/version allocation, native write, alarm activation or network operation.

## Supported projection

Require an active recurring accepted master, one REQUEST component with exact UID/organizer/recipient correlation, undelegated participants and exact DATE/UTC/named-zone original/profile/membership. Source parsing and caller-supplied accepted values prove no authority, freshness or clean database baseline. EXDATE and recurrence-generated nonexistent local originals reject; earlier RDATE and PERIOD additions retain exact original identity. Existing source byte/shape and timezone validation remain required.

Add or replace only the future component at the selected original. Preserve master content/protocol state, all explicit singles/cancellations and every other future component and its independent version. A single at the selected anchor rejects; no implicit deletion/conversion occurs. Later future anchors retain their own segments, and shifts replace the active shift rather than compounding it. Original recurrence identities control order even when a single's moved start lies elsewhere.

Only timing propagates under the existing core policy. Supported explicit SUMMARY/DESCRIPTION/LOCATION values, including empty text and legal annotations, remain local to the range anchor. Later originals inherit master text. REQUEST still requires SUMMARY in the existing iTIP parser; missing SUMMARY is rejected, not repaired. Omitted DESCRIPTION/LOCATION inherit. Existing master-matching constraints apply to richer metadata, participants and references, with ordinary status/transparency restrictions. This is a bounded profile, not general future-content propagation.

The scheduling parser continues to reject source VALARM even when it matches accepted data. Accepted unarmed master alarms remain intact, and a proposed timing change incompatible with them rejects through the existing wire/core validation. No source data is stripped to manufacture an accepted message, and no alarm executes.

Explicit end versus DURATION and nominal weeks/days versus elapsed clock units remain distinct, including across DST. Preserve independent incoming SEQUENCE/DTSTAMP and optional CREATED/LAST-MODIFIED, text/source-presence flags and the original immutable parsed message. No master or unrelated component is reclocked. An omitted source SEQUENCE stays omitted, distinct from explicit zero; this pure helper does not decide whether a version is newer.

## Bounds and immutability

Ordinary whole-second dates remain in [1970-01-01, 2100-01-01), with only approved exclusive endpoints at 2100 midnight. Explicit gaps/folds use the selected RFC rules; no fractions, floating times or guessed zones are introduced. Subsequent occurrence calculations retain their existing horizon checks; accepting a range does not extend supported dates or promise every future result fits the horizon.

One shared RecurrenceWorkBudget covers accepted-state validation, membership, required master/incoming source projection and merged validation, with the existing 200,000 work ceiling. Preserve the 128-slot native cap independently of smaller wire export limits: only the master and incoming component pass through the required wire profile. Unrelated native exceptions are validated/preserved without exporting them or forcing them into the smaller wire component cap. No unbounded series is enumerated or flattened into singles. Exhausted work/slots fail explicitly; other invalid projections use non-echo errors.

Inputs are not mutated; validated result collections are immutable and detached from mutable caller lists. The existing single REQUEST/CANCEL helper still rejects RANGE. Its request mapping shares a private master/component validation helper; its single/cancellation behavior is unchanged.

## Validation and remaining work

Focused tests cover DATE/UTC/zoned end/duration/default forms, source omissions/versions, anchor text, prior/later ranges, singles/cancellations, DST civil shifts/gaps/folds, nominal duration, horizon endpoints, PERIOD/earlier inclusions, exclusions, identity/participant/metadata rejection, work/source/slot caps and immutability. Existing single projection tests remain regressions. Grouped checks include complete core/iCalendar VM+Chrome, module suites and affected real database application/guard checks; see [actual evidence](scaffold-validation.md) for commands/results and deferred checks. This generated Serverpod-carrier boundary is VM-only; reusable temporal semantics remain independently tested on Chrome.

Range notices remain [review-only](range-invitation-review.md). Current calendar/response APIs still reject range actions. Durable clean-series range application, cross-target version/overlap coordination, accepted checkpoints/retention, transactional authorization/concurrency, exact retries, future cancellation/restoration and range replies require separate review. Ordinary import/export, feeds, organizer publication and real mail retain their own boundaries. Pure success is neither native reconciliation nor interoperability evidence.


## Pure incoming range cancellation

Accepted [ADR 0159](adr/0159-pure-range-cancellation-projection.md) implements a separate pure cutoff candidate and independent cancellation source version, preserving retained master/occurrence data and versions. Incoming SEQUENCE must exceed all affected versions, including the underlying segment beneath an anchor single. See [the implementation guide](range-cancellation-projection.md) for the exact profile, floor, limits and omissions. Actual validation is recorded separately. No native write, accepted baseline, generated protocol, endpoint or wire export changes; durable range CANCEL/retry/composition/restoration remains separate.
