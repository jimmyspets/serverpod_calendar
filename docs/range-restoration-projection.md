# Pure restore-only range source projection

[Accepted ADR 0163](adr/0163-pure-restore-only-range-source-projection.md) adds `projectInvitationRangeRestoration` in the calendar server module's existing exported invitation-values library. It validates one detached THISANDFUTURE REQUEST against retained canonical values with a cancellation cutoff. The immutable result clears only that cutoff. It is a proposal for later trusted reconciliation, not authenticated acceptance, a database mutation or a native restore action.

## Exact restoration profile

Require an active recurring DATE, UTC or named-zone master, a validated saved cutoff, matching UID and exact RECURRENCE-ID kind/zone/civil original at that cutoff. Membership follows the retained recurrence set, including earlier inclusions, PERIOD additions and EXDATE precedence. A moved DTSTART never changes the original identity. Whole-master cancellation must be reopened separately.

Resolve the retained uncancelled anchor through existing single/future timing and anchor content. An individually cancelled anchor is lifted only for comparison; its actual flag survives in the result. Match DTSTART fields/profile and the retained end form exactly: explicit end, nominal-unit duration or omitted default end. Equal elapsed intervals do not permit replacing PT1H with PT60M, P1D with PT24H, an end with a duration, a named civil time with UTC, or one exact zone key with another. This stricter application profile can reject equivalent source representations.

Supplied text, annotations, transparency, participants and supported source metadata must match the existing bounded property profile. Omitted inheritable values retain their distinctions; supplied STATUS must match the active retained status, and omission introduces no CONFIRMED default. Organizer/recipient address checks establish data agreement only. Delegation, source alarms and unprofiled data reject. Existing accepted unarmed alarms and all canonical metadata remain intact.

Single and future edits cannot coexist at the same original under the existing model. Either valid anchor form is supported, including a single inside an earlier future segment. Restoration allocates no exception, pins no inherited value and changes no retained component version. With no remaining edits, the normal canonical representation is a null override object.

## Separate source version

The caller supplies the cancellation's independently validated protocol version, with a required SEQUENCE. It does not prove a source cancellation was actually accepted. The incoming restoration SEQUENCE must be strictly greater than that version and the shared range-cancellation comparison floor: the underlying master/range at the anchor plus all canonical components at or after it in original civil order. An anchor single cannot hide a newer underlying segment. Omitted retained SEQUENCE compares as zero without changing its omission. A later DTSTAMP never waives the floor; maximum versions can prevent restoration.

The result retains independent cancellation/restoration versions, the comparison floor, exact original and immutable source message. Incoming DTSTAMP and optional CREATED/LAST-MODIFIED may predate retained values and are preserved exactly, including omissions. They never overwrite native component protocol state or become a database audit clock.

## Work and trust boundaries

Input, exact membership, anchor comparison and candidate validation share one bounded recurrence-work budget. Existing syntax/source/zone ceilings apply even when a caller parsed with larger limits. Native override limits stay separate from smaller wire component limits; clearing a cutoff cannot silently discard native exceptions. Limit exhaustion is an error, never partial agreement. Diagnostics omit source/private values.

Current durable v4/v5/v6 services still reject new source restoration. Later acceptance must verify the actual stored cutoff/source, clean entire series, authority, revisions, atomicity, retained source evidence/version, retry identity, privacy/byte caps and deletion/invalidation. No table, migration, generated model, endpoint, dependency or UI control changes in this batch. This helper establishes neither full RFC interoperability nor transport support.

Focused tests cover exact matching, preserved native/source state, DATE/UTC/zones, DST gap/fold inclusions, 23/25-hour nominal days, earlier/PERIOD originals, individual cancellations, independent version floors, raw-source/work/native-slot bounds, detached immutable output and ordinary 1970–2099/exclusive-end limits. Actual grouped/hosted results are recorded in [validation evidence](scaffold-validation.md).

The next [durable acceptance proposal](adr/0164-first-durable-source-range-restoration.md) is under review. Its v7 evidence/API/UI mechanics are not implemented by this pure helper.
