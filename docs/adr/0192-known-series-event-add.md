# ADR 0192: Incoming VEVENT ADD for known recurring invitations

Status: **Proposed. Runtime, model and limits await maintainer approval.**

## Context

An organizer can send one VEVENT ADD to add an instance to an existing
event. The recipient treats the new instance as an additional recurrence
date. A pure ADD parser already preserves the component's DTSTART, SUMMARY,
positive source SEQUENCE and supplied fields. An authenticated recipient
workflow also needs the exact current series, trusted organizer and clean
accepted calendar baseline. [RFC 5546 section 3.2.4](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.4)
[ADR 0120](0120-remaining-pure-event-scheduling-methods.md)

## Proposed first profile

Accept one verified ADD for a known, already adopted, ordinary recurring
REQUEST series with a retained current master and complete accepted
baseline. Resolve the authenticated target recipient and exact organizer
through trusted delivery and the permanent invitation link. Require the
same UID, verified organizer address, attendee authority and source
provenance. When the packet omits ATTENDEE, verify recipient membership
from the retained REQUEST and trusted route. A supplied attendee set must
be consistent with those trusted roles. Delegation and SENT-BY remain
outside this first profile.

Derive the added original from the typed DTSTART. Match the master date,
UTC or exact named-zone profile. Prove that the original is new to the
accepted recurrence set and absent from retained exclusions, existing
overrides, cancellations and earlier ADD history under a shared work
budget. Permit the projection only when the complete ADD values can be
represented by one plain RDATE and the inherited occurrence. Check the
timing and duration, required SUMMARY, supplied optional content and
participant fields against that projection. Reject differences that need
independent occurrence content or a PERIOD and preserve source omissions
for review. Missing proof, unresolved time, participant changes, alarm
payloads, mixed profiles and exhausted budgets fail closed.

Track the ADD's SEQUENCE and DTSTAMP separately from the master
REQUEST SEQUENCE and the native event revision. A new ADD needs a
positive SEQUENCE above the accepted master and applied ADD floors. Keep
one pending addition per invitation. An exact authorized delivery retry
returns the historical receipt before new admission. An independently
verified repeat of the same source preserves the same addition identity.
A changed use of a retained delivery key or a competing retained payload
at the same sequence fails atomically.

## Proposed review, application and lifecycle

Private receipt makes a notice available for explicit review or dismissal.
Applying it requires independent source, action, calendar/write and
proposed occurrence authorization. The command binds the source, accepted
baseline, current event revisions and a stable command UUID. Construct and
validate the full resulting recurrence under the existing database scope
fence, then atomically add the RDATE, advance the native revision and
record the exact addition and immutable receipt. Check the full current
and proposed snapshots at preliminary and final authorization. A local
draft or changed source prevents apply until it reconciles through the
ordinary explicit workflow.

Keep the accepted REQUEST basis distinct from the added-original ledger.
Compose the effective accepted series from both while additions remain
active. A later full REQUEST can absorb an addition only with a newer
series version and proof that it represents the exact added original and
effective occurrence. Conflicting or unproved changes remain privately
reviewable. Guard existing application, whole cancellation/reopening and
occurrence response paths before scalar correlation fallback whenever
they cannot preserve the augmented baseline. Preserve prior source and
command identity through absorption and pruning. Keep accepted active
proof until absorption, explicit link deletion or the source lifecycle
removes the series.

Use three private record families for normalized notices, trusted ingress
receipts, and applied originals with immutable command results. Use the
existing invitation link, source references and scope fence. Proposed caps
are 16 retained notices per linked series, 128 per recipient, 1,024 per
scope, and one pending notice per link. Cap each source at 32 KiB after
normalization. Terminal notice and receipt retention is 30 days after
resolution, with 32 retained receipt keys per link and 512 per recipient.
Retain actively applied proof and pin its exact source under existing
invitation source caps. Reject work beyond the caps atomically and prune
only eligible records.

## Proposed acceptance

Exercise trusted MIME intake, missing and mismatched attendees, wrong
series or organizer, retained delivery retries, sequence floors, exact
DATE/UTC/named-zone identities, membership/cancellation rejection,
preservation of local draft conflicts and final authorization rollback.
Verify explicit apply, duplicate apply, shared scope races, source
retention, later REQUEST absorption and guarded lifecycle paths. Include
generated-client and connected Flutter journeys, actual two-host process
loss around commit, fresh and populated migration tests, and full hosted
checks. Use synthetic fixtures. Organizer origination, unadopted series,
more general addition projections, unknown-UID REFRESH fallback and real
mail remain separate work.
