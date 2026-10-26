# ADR 0120: Remaining pure event scheduling methods

Status: **Previously selected first-release methods; concrete pure-profile mechanics under draft review**. Date: 2026-10-26.

## Context

The RFC 5546 inventory already selects ADD, REFRESH, COUNTER and DECLINECOUNTER. Extend the ADR 0119 pure adapter with these methods as one batch, preserving the existing source-only authority boundary, typed timing, UID/original identity and work limits. No database, endpoint, native command, automatic response or mail delivery is included.

## Profile

Follow the individual [RFC 5546 section 3.2 method tables](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2), rather than treating all event messages as ordinary import. All existing explicit payload/recurrence/parameter limits remain; unsupported data rejects without partial results.

ADD contains exactly one event with DTSTART, SUMMARY and a positive explicit SEQUENCE, in addition to the common source UID/DTSTAMP/ORGANIZER. It forbids RECURRENCE-ID, RRULE, RDATE and EXDATE. Its timing is source data for an addition, not a replacement master; proving a sequence increment or association with an existing series requires later trusted reconciliation.

REFRESH contains exactly one event and one ATTENDEE. Its payload whitelist is UID, DTSTAMP, ORGANIZER, ATTENDEE, optional COMMENT and optional RECURRENCE-ID. It cannot smuggle timing, SEQUENCE, event metadata or result data into a refresh request. It causes no lookup or automatic reply here.

COUNTER contains exactly one event with DTSTART and SUMMARY. Preserve optional SEQUENCE as a source distinction: the table's presence column lists one, while its comment explicitly permits the zero case. This reader interprets that conditional comment by preserving omission without inventing zero or claiming it matches a stored request; later reconciliation must verify the original sequence and reject an incompatible omission. ATTENDEE values may propose participation, but none identify the trusted sender or grant authority.

DECLINECOUNTER allows the existing bounded one-UID component set, requires explicit SEQUENCE and at least one ATTENDEE per component, and permits only tentative/confirmed STATUS if supplied. It does not cancel or mutate an event. REQUEST-STATUS becomes permitted source data in COUNTER and DECLINECOUNTER as well as REPLY; no numeric result executes retries or state changes.

All methods still require later verification of sender/recipient roles, prior state, versions and occurrence identity before any transition. A parsed COUNTER with cancelled status is a proposal, not execution of cancellation. Alarms, delegated REPLY workflows, arbitrary extensions, VFREEBUSY and VTODO scheduling remain outside this adapter slice. Ordinary import/export and bearer feeds keep their own contracts.

## Alternatives and acceptance

Requiring SEQUENCE on every COUNTER would reject the table comment's conditional omission; silently filling zero would lose source distinctions and could mask a nonzero stored request. This bounded reader preserves the claim and defers the prior-state decision. A generic method passthrough would miss cardinality, forbidden-property and lifecycle distinctions.

Test minimal and populated messages, per-method required/forbidden fields and component/attendee counts, zero/positive/absent sequence distinctions, detached identities, allowed status/result combinations, untrusted participant claims, budgets and unchanged standalone rejection. Run focused tests during development, then broader pure suites and directly affected integration checks before one batch check-in. No complete scheduling or external mail/client conformance claim follows from these codecs.
