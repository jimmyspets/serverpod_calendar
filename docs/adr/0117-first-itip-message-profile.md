# ADR 0117: First pure iTIP message profile

Status: **Proposed; maintainer scope decision pending**. Date: 2026-10-25.

## Context

The optional event feed has completed local batch validation under ADR 0116. Scheduling remains a first-release requirement. Standalone import, subscription publication and source participant preservation do not authorize scheduling transitions. The next increment should establish a transport-independent message boundary before adding reconciliation tables, trusted ingress or an outbox.

[RFC 5546](https://www.rfc-editor.org/rfc/rfc5546.html), sections 3.1 and 3.2, supplies component- and method-specific restrictions. Ordinary event validation cannot substitute for those restrictions. The first-release method inventory in [the RFC table](../rfc/rfc-5546.md) remains unchanged.

## Proposed first batch

Implement a pure Dart adapter in the existing iCalendar package for **PUBLISH, REQUEST, REPLY and CANCEL**, initially with exactly one non-recurring VEVENT per VCALENDAR. This is an incremental application profile, not the full RFC or first-release scheduling capability. Other methods/components, recurrence properties, RECURRENCE-ID and RANGE reject explicitly in this first slice. Required later increments include recurring masters/instances, ADD, REFRESH, COUNTER, DECLINECOUNTER and the selected VFREEBUSY methods.

The parser and writer must validate the common envelope and each method's required, optional and forbidden properties against its own RFC restriction table. A message exposes its method, source identity/version and method-appropriate payload through immutable types. Minimal replies and cancellations must not acquire invented event timing, summaries, native defaults or participant state merely to fit the ordinary event DTO. Source omissions remain distinguishable from supplied values. Unknown or unprofiled properties/parameters reject rather than disappear.

Reuse the strict UTF-8/CRLF syntax boundary, whole-second timing, DATE/UTC/named-zone meanings, full-horizon VTIMEZONE validation and resource budgets already implemented. Ordinary dates remain [1970-01-01, 2100-01-01), with only approved exclusive endpoints. No floating times, fractional normalization, timezone replacement or fetching follows from parsing. Alarms and extension properties reject until their scheduling-specific profile is reviewed; canonical standalone support remains unchanged.

ORGANIZER, ATTENDEE, delegation and SENT-BY values remain decoded claims. The adapter validates their supported syntax and method constraints; it cannot prove their authority. It produces no host identity mappings, event mutations, participant responses, resource bookings, notifications, automatic replies or email. Scheduling UIDs remain source identities and are never replaced with feed publication UIDs. Parsing SEQUENCE/DTSTAMP establishes no ordering decision against stored state.

## Boundaries and subsequent work

No table, migration, Serverpod endpoint, inbox, outbox, SMTP/IMAP integration or native scheduling command is included. The existing authenticated import/export and bearer-feed paths retain their own behavior and continue rejecting scheduling envelopes where they currently do so. VTODO scheduling remains deferred under ADR 0011.

Before durable scheduling implementation, separately review trusted sender/recipient/address adapters, organizer/delegate/attendee authority, replay and cancellation ordering, local edit conflicts, retention, resource acceptance and transactional inbox/outbox storage. Before email implementation, select and validate the MIME dependency and the restricted ADR 0015 profile. Tests use synthetic messages; real email is not authorized by this proposal.

## Alternatives and consequences

Implementing every method and recurrence form together gives a broader first increment but delays focused verification of the message boundary. Starting directly with database/email operations couples wire validity to authority, reconciliation and delivery failures. Reusing ordinary import after removing METHOD would miss method-specific constraints and could manufacture fields absent from a valid message. The proposed pure slice keeps those concerns explicit at the cost of initially rejecting recurring scheduling messages.

## Acceptance

Use method-specific positive/negative fixtures, required/forbidden property and cardinality checks, source-omission round trips, malformed/unsupported/mixed-component rejection, timezone/precision boundaries and input/output budget failures. Demonstrate unchanged ordinary event import/export and feed behavior through directly affected regressions. During development run focused VM tests; at batch completion run the full wire VM/Chrome suites and required repository checks. Record exact results without claiming reconciliation, mail, external-client or full first-release interoperability.

Approval requested: the four-method, one non-recurring event, pure-adapter batch boundary. Detailed property mappings must be documented alongside implementation and reviewed against the cited method tables; this proposal does not silently approve unlisted scheduling extensions.
