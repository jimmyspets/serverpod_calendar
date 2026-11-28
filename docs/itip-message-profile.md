# Pure scheduling messages

Status: scoped implementation under the maintainer-approved batch boundary in [ADR 0117](adr/0117-first-itip-message-profile.md); selected broader batch checks passed. This is a pure message adapter, with no scheduling reconciliation or email runtime.

The iCalendar package exposes `parseIcalendarSchedulingMessage`, `validateIcalendarSchedulingMessage` and `serializeIcalendarSchedulingMessage`. They handle one non-recurring VEVENT inside one VCALENDAR, for PUBLISH, REQUEST, REPLY or CANCEL. The ordinary standalone event parser still rejects METHOD. Source import/export, event feed publication and scheduling are distinct interfaces.

The method restrictions follow [RFC 5546 sections 3.1–3.2](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2). This first application profile is narrower than those RFC tables:

| Method | Additional message constraints |
| --- | --- |
| PUBLISH | DTSTART and SUMMARY required; no ATTENDEE; at most one CONTACT |
| REQUEST | DTSTART and SUMMARY required; at least one ATTENDEE; STATUS cannot be CANCELLED |
| REPLY | Exactly one ATTENDEE; timing and SUMMARY may be absent; at most one VTIMEZONE |
| CANCEL | SEQUENCE required; supplied STATUS must be CANCELLED; absent STATUS denotes attendee removal and requires an ATTENDEE |

Every message requires VERSION 2.0, nonempty PRODID, a supported METHOD, nonempty UID, UTC DTSTAMP and ORGANIZER. Empty SUMMARY is distinct from omission. SEQUENCE remains nullable where optional; a supplied zero is preserved. The adapter does not establish that a cancellation increments a stored version or that optional reply fields match an earlier request. Those checks require trusted prior scheduling state.

## Data and timing

`IcalendarSchedulingMessage` is immutable and retains its validated source syntax. It exposes the method, source UID/version/timestamps, independently optional typed start/end/duration, text, status/transparency, participants, metadata, inert references and validated zones. Serialization preserves source property values, omissions and ordering while applying deterministic syntax quoting/folding; it does not preserve original physical line breaks.

An omitted start stays absent in REPLY/CANCEL. An independently supplied DTEND remains available without manufacturing a start or busy interval. Derived DATE/timed spans exist only when DTSTART exists; their ordinary default spans do not insert missing DTEND/DURATION properties into the message. This initial duration profile requires a supplied start and a positive duration, preserving DATE day/week restrictions and end-versus-duration exclusivity.

The strict UTF-8/CRLF boundary, whole-second precision, [1970-01-01, 2100-01-01) date profile, explicit exclusive endpoints and full-horizon pinned-zone validation remain unchanged. No floating values, fractions, guessed zones or network retrieval are introduced. Configurable existing syntax/component budgets apply to parsing, manually constructed trees and serialization; the one-event profile is an additional bound. Default event metadata budget is 65,536 code points, with existing per-property, participant and reference bounds.

## Supported properties and explicit rejections

In addition to the method fields, this increment supports optional DTEND/DURATION, DESCRIPTION, LOCATION, STATUS, TRANSP, CREATED and LAST-MODIFIED, plus the existing bounded event CLASS/URL, grouped CATEGORIES/COMMENT/CONTACT, ORGANIZER/ATTENDEE parameters, RELATED-TO and URI ATTACH codecs. Language/ALTREP annotations and source groups remain intact. Links and attachments remain inert; their presence causes no fetching or host association.

Recurrence properties, RECURRENCE-ID/RANGE, multiple VEVENT components, VTODO/VFREEBUSY/other component families, all VALARM components and arbitrary extension properties/parameters reject. REQUEST-STATUS, GEO, PRIORITY and RESOURCES are not yet profiled here and also reject. Other selected methods remain first-release work rather than being treated as successful input. The one-attendee REPLY slice rejects PARTSTAT=DELEGATED: the RFC delegation workflow needs a separately validated multi-attendee profile. Ordinary source participant preservation is unchanged.

ORGANIZER, ATTENDEE, SENT-BY and delegation parameters are unverified claims. Their syntax is not proof of identity, membership, sender authority or recipient consent. This adapter does not choose a host scope, compare versions against storage, update events, reserve resources, send automatic replies, activate alarms or dispatch email. Feed publication UIDs never replace scheduling UIDs. Future authenticated reconciliation must supply current trusted authority and prior state before any mutation or outbound intent.

## Validation and next work

Focused fixtures cover method-specific required/forbidden fields and cardinality, omitted versus empty values, partial timing, DATE/UTC/named-zone semantics, source claims/metadata/references, strict rejection and budgets. [The validation record](scaffold-validation.md) records actual broader results. No new tables, migrations, endpoints or package dependencies are needed for this increment.

The next work remains recurring messages/instances, the other selected methods and missing property/delegation profiles, followed by separately reviewed reconciliation/identity/authority/retention/inbox/outbox contracts. MIME and trusted inbound/outbound host adapters follow under the restricted email profile. No real mail or external scheduling-client interoperability follows from pure parser tests.
