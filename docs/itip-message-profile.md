# Pure scheduling messages

Status: scoped pure implementation under [ADRs 0117](adr/0117-first-itip-message-profile.md), [0118](adr/0118-scheduling-status-and-payload-metadata.md), the maintainer-approved detached boundary in [0119](adr/0119-recurring-itip-message-boundary.md), and the remaining event-method profile in [0120](adr/0120-remaining-pure-event-scheduling-methods.md). All four pure scheduling increments passed their selected broader batch checks. This is a pure message adapter, with no scheduling reconciliation or email runtime.

The iCalendar package exposes `parseIcalendarSchedulingMessage`, `validateIcalendarSchedulingMessage` and `serializeIcalendarSchedulingMessage`. They handle one source UID's VEVENT components inside one VCALENDAR, for PUBLISH, REQUEST, REPLY, CANCEL, ADD, REFRESH, COUNTER or DECLINECOUNTER. The ordinary standalone event parser still rejects METHOD. Source import/export, event feed publication and scheduling are distinct interfaces.

The method restrictions follow [RFC 5546 sections 3.1–3.2](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2). This first application profile is narrower than those RFC tables:

| Method | Additional message constraints |
| --- | --- |
| PUBLISH | DTSTART and SUMMARY required; no ATTENDEE; at most one CONTACT |
| REQUEST | DTSTART and SUMMARY required; at least one ATTENDEE; STATUS cannot be CANCELLED |
| REPLY | Exactly one ATTENDEE per component; timing and SUMMARY may be absent; at most one VTIMEZONE per envelope |
| CANCEL | SEQUENCE required; supplied STATUS must be CANCELLED; absent STATUS denotes attendee removal and requires an ATTENDEE |
| ADD | Exactly one component; DTSTART/SUMMARY and positive explicit SEQUENCE; RECURRENCE-ID/RRULE/RDATE/EXDATE forbidden |
| REFRESH | Exactly one component/ATTENDEE; only UID/DTSTAMP/ORGANIZER/ATTENDEE, optional COMMENT/RECURRENCE-ID |
| COUNTER | Exactly one component; DTSTART/SUMMARY required; optional source SEQUENCE needs later original-version verification; ATTENDEE values may be proposals |
| DECLINECOUNTER | Explicit SEQUENCE and at least one ATTENDEE per component; supplied STATUS limited to tentative/confirmed |

Every envelope requires VERSION 2.0, nonempty PRODID and a supported METHOD. Every component requires the same nonempty UID, its own UTC DTSTAMP and ORGANIZER; the method restrictions apply to each component. Empty SUMMARY is distinct from omission. SEQUENCE remains nullable where optional; a supplied zero is preserved. The adapter does not establish that a cancellation increments a stored version or that optional reply fields match an earlier request. Those checks require trusted prior scheduling state.

## Data and timing

`IcalendarSchedulingMessage` is an immutable envelope containing source syntax, product ID, method, common source UID, validated zones and an explicit `events` list of `IcalendarSchedulingEvent` values. Each component has its own source syntax, versions/timestamps, independently optional timing/text/status/participants/payload and original recurrence identity. This is a permitted unpublished API change: callers use `message.events.single` for an expected single component or explicitly iterate components. There is no implicit first-component selection.

Serialization preserves source values, omissions and order with deterministic syntax quoting/folding and FREQ-first RRULE output; the retained source tree remains unchanged. Original physical line breaks are not preserved.

An omitted start stays absent in REPLY/CANCEL. An independently supplied DTEND remains available without manufacturing a start or busy interval. Derived DATE/timed spans exist only when DTSTART exists; their ordinary default spans do not insert missing DTEND/DURATION properties into the message. This initial duration profile requires a supplied start and a positive duration, preserving DATE day/week restrictions and end-versus-duration exclusivity.

The strict UTF-8/CRLF boundary, whole-second precision, [1970-01-01, 2100-01-01) date profile, explicit exclusive endpoints and full-horizon pinned-zone validation remain unchanged. No floating values, fractions, guessed zones or network retrieval are introduced. Configurable existing syntax/component budgets apply to parsing, manually constructed trees and serialization; the one-event profile is an additional bound. Default event metadata budget is 65,536 code points, with existing per-property, participant and reference bounds.

## Supported properties and explicit rejections

In addition to the method fields, this increment supports optional DTEND/DURATION, DESCRIPTION, LOCATION, STATUS, TRANSP, CREATED and LAST-MODIFIED, plus the existing bounded event CLASS/URL, grouped CATEGORIES/COMMENT/CONTACT, ORGANIZER/ATTENDEE parameters, RELATED-TO and URI ATTACH codecs. Language/ALTREP annotations and source groups remain intact. Links and attachments remain inert; their presence causes no fetching or host association.

VTODO/VFREEBUSY/other component families, all VALARM components and arbitrary extension properties/parameters reject. Unknown methods never silently become PUBLISH or import. The one-attendee REPLY slice rejects PARTSTAT=DELEGATED: the RFC delegation workflow needs a separately validated multi-attendee profile. Ordinary source participant preservation is unchanged.

## Recurring masters and detached instances

The maintainer approved detached scheduling components without a master in the same message under ADR 0119. `originalDate`/`originalTime` and `isThisAndFuture` retain RECURRENCE-ID and the supported RANGE=THISANDFUTURE flag. A detached reply/cancellation may omit timing. No start, interval, master, native UUID or parent relationship is invented. Source RANGE or cancellation flags do not execute native range changes or future cancellation.

Masters reuse the existing bounded RRULE, start-valued RDATE/EXDATE and timed PERIOD profile, including unit-preserving durations, WKST and explicit source dates. Patterns require DTSTART. An occurrence component cannot also define RRULE/RDATE/EXDATE in this initial profile. Supplied occurrence timing must use its original identity's DATE/UTC/named-zone profile; when an incoming master has a start, original identities must match that profile too. Missing/mismatched zone evidence rejects even if only RECURRENCE-ID uses the zone.

Require one exact UID throughout, including a deliberately narrower PUBLISH profile, at most one master, unique original/range keys, and configurable existing bounds: default 128 event components and 64 overrides. Single and future components for the same original have distinct keys and remain source data, without application precedence being inferred here. Syntax, metadata, explicit-date and candidate-work budgets are shared across the message.

Components retain their own omissions: text, timing, status, participant values, timestamps and reply results are not inherited from another component by the parser. Even an original absent from an incoming master's new rule remains only an unverified source claim; prior stored state may be needed to reconcile a pattern change. Parsing proves no stored existence or membership, current version, authority or native representability. Later authenticated reconciliation must verify actual prior state before mutation, outbound intent or authoritative availability. Ordinary file import still requires and validates its matching master.

Scheduling zone observances additionally enforce the common iTIP restriction clarified by [verified erratum 3932](https://www.rfc-editor.org/errata/eid3932): RRULE and RDATE cannot coexist in one STANDARD/DAYLIGHT observance. This scheduling-only check does not narrow ordinary RFC 5545 source validation. The errata record was checked on 2026-10-26.

## Reply results and payload metadata

ADR 0118 first added REQUEST-STATUS in REPLY and independently optional PRIORITY/GEO/grouped RESOURCES. ADR 0120 also permits source results in COUNTER/DECLINECOUNTER; REFRESH forbids those payload properties. These codecs do not widen ordinary event/task import or native storage.

Each component's `requestStatuses` retains up to 32 reported results in source order where the method permits them. Each keeps its original numeric code spelling, immutable two/three integer levels, decoded description, optional extra data and LANGUAGE. Missing extra data differs from an explicitly empty third field. Escaped commas, semicolons, backslashes and text newlines remain text. Code spelling is capped at 32 characters, numeric levels at 2,147,483,647 and each decoded text component at 4,096 code points. Unknown numeric codes remain data; no success/retry decision or automatic response follows.

`priority` preserves omission independently of a supplied 0–9 value. `geographicPosition` retains exact latitude/longitude decimal strings, each at most 64 characters, with exact latitude ±90 and longitude ±180 bounds. Convenience double getters are approximate; serialization preserves the source decimals without rounding. Geographic fractions are independent of the whole-second timing rule. No mapping/geocoding is started.

`resources` keeps source groups and their LANGUAGE/ALTREP metadata, with at most 32 groups, 64 combined labels and 4,096 code points per label. Empty labels and internal spelling remain intact. Labels do not identify or reserve host resources; links remain inert. Repeated scheduling groups follow the method tables, without changing ordinary-component cardinality. Existing aggregate metadata/syntax budgets still apply, and unprofiled parameters reject.

ORGANIZER, ATTENDEE, SENT-BY and delegation parameters are unverified claims. Their syntax is not proof of identity, membership, sender authority or recipient consent. This adapter does not choose a host scope, compare versions against storage, update events, reserve resources, send automatic replies, activate alarms or dispatch email. Feed publication UIDs never replace scheduling UIDs. Future authenticated reconciliation must supply current trusted authority and prior state before any mutation or outbound intent.

## Validation and next work

Under accepted [ADR 0125](adr/0125-scheduling-occurrence-field-projection.md), `projectIcalendarRequestFields` accepts a validated standalone calendar containing one complete series and produces a REQUEST candidate. Missing SUMMARY inherits the master's property/annotations or becomes empty if absent there. Missing organizer/attendee properties copy the master's source claims; explicit own properties remain intact. The original immutable source, timing, recurrence identities and versions remain unchanged. Source order, legal parameters and PERIOD forms are retained; no versions, identities or authority are manufactured. Cancellation, alarms and other unsupported REQUEST data reject instead of being discarded. Input/output and copied-field growth are bounded. This pure prerequisite neither calls the durable service nor authorizes its participants; current Save and notify remains master-only until its occurrence version/reset/bundle contract is reviewed.

Focused fixtures cover method-specific required/forbidden fields and cardinality, omitted versus empty values, partial timing, DATE/UTC/named-zone semantics, source claims/metadata/references, strict rejection and budgets. [The validation record](scaffold-validation.md) records actual broader results. No new tables, migrations, endpoints or package dependencies are needed for this increment.

## Additional method boundaries

ADD's timing describes an untrusted proposed addition, not a replacement master. REFRESH's whitelist applies even to an explicit SEQUENCE:0 or an empty SUMMARY: neither is permitted. It triggers no lookup or automatic reply.

The COUNTER table's SEQUENCE presence column lists one while its comment permits the zero case. This reader interprets that conditional comment by preserving omission as null. It neither manufactures zero nor establishes that the source echoes a stored request; later reconciliation must reject an incompatible omission. Explicit zero remains distinct. Counter participant values do not identify a verified sender; a cancelled STATUS is only a proposal, not a cancellation action. DECLINECOUNTER likewise changes no event state.

The separate [VFREEBUSY source adapter](itip-freebusy-profile.md) now covers its bounded method tables. The next work remains authenticated VFREEBUSY scheduling and missing property/delegation profiles, followed by separately reviewed reconciliation/identity/authority/retention/inbox/outbox contracts. MIME and trusted inbound/outbound host adapters follow under the restricted email profile. No real mail or external scheduling-client interoperability follows from pure parser tests.
