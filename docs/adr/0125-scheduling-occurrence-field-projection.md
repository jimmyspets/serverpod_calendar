# ADR 0125: Scheduling-only occurrence field projection

Status: **Proposed wire-projection decision; no occurrence-publication implementation or physical storage design is approved by this record.**

## Context and source evidence

Accepted [ADR 0124](0124-recurring-organizer-masters.md) currently publishes only recurring masters. Native occurrences can inherit their summary and participants from the series. The [RFC 5546 REQUEST table](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.2) requires SUMMARY, ORGANIZER and at least one ATTENDEE on each emitted event component, alongside DTSTART/DTSTAMP/UID. It permits multiple event components with one UID. The [sequencing rules](https://www.rfc-editor.org/rfc/rfc5546.html#section-2.1.5) correlate instances by UID and RECURRENCE-ID and compare their versions. These rules were checked against the RFC Editor text on 2026-10-26; parsing a source message still grants no authority.

A plain canonical-source serialization can omit inherited component fields. That creates a distinct scheduling projection question, independent of ordinary authenticated file export and native inheritance. Sending an empty SUMMARY when a native occurrence inherits a nonempty series title would misrepresent its current value.

## Recommended decision for maintainer review

Permit an outgoing occurrence REQUEST projection to include explicit current inherited SUMMARY and host-approved organizer/attendee properties, without pinning or rewriting those properties in native storage. Copy actual values and legal annotations/parameters; preserve explicit own values and explicit empty text. Use empty SUMMARY only when the current effective value is empty, never the example's display placeholder. Resolve participants from trusted host authority and the approved fixed roster, not from arbitrary source claims.

Native inheritance remains live: a later series edit can change an inheriting occurrence, and a later explicit publication must project its then-current effective value. Ordinary edits remain local and never regenerate queued bytes. Each publication snapshot remains immutable and privately retained under the reviewed limits. The host must see current/final canonical state separately from the exact projected outgoing component and approve disclosure to every recipient.

This is a scheduling-only projection. Ordinary authenticated iCalendar export keeps its existing source-preserving profile and rejection rules. Imported messages do not pin native fields, assign identities, arm alarms or grant scheduling authority automatically. Approval of text/participant projection does not approve invented timing: follow-series exceptions that cannot be represented faithfully still reject until their timing mapping is designed.

## Boundaries still requiring design

Before implementing occurrence publication, specify per-instance version advancement/no-op comparison for changed projected values while retaining native source presence/inheritance; current versus historical component identity; and a complete snapshot/projection representation that reads existing master-only records. Do not infer approval of a shared series-wide counter or a new table from this proposal.

Instance cancellations need CANCEL semantics and reviewed transactional message coordination. Removing a previously published exception or changing its original membership also needs an explicit reset/reconciliation policy; silently omitting it is not an approved remote-state reset. A single/future pair sharing one original identity requires separate review before publication. These lifecycle, version, bundle/storage and retention mechanics remain unapproved. Complete occurrence/instance/range scheduling stays a first-release requirement.

Continue current fixed organizer/recipients, independent publish/lifecycle/detail/source authority, bounded work/payloads, stable retry identity, fresh authorization and fencing. Whole-series cancellation remains governed by ADR 0124. No new endpoint, model, migration, delivery capability or real mail is introduced by this document.

## Alternative and future acceptance

The alternative is to keep such components unsupported until a separately reviewed native-own-value authoring workflow exists. The current module does not provide a general native occurrence participant editor. That avoids a scheduling projection but restricts existing canonical inheritance. The recommended projection retains native behavior and makes the external representation explicit; native and wire state must be tested separately.

Future implementation evidence must cover inherited/own/empty summary and legal annotations, approved participant projection, native immutability, later master edits, exact original IDs, method/property constraints, unauthorized disclosure, projected-version/no-op behavior, unsupported timing/cancellation/reset rejection and immutable retries across independent workers. External-client and real-mail evidence remain separate.
