# Authenticated per-calendar VFREEBUSY export

Status: **scoped implementation under ADR 0077; concrete mechanics under draft PR review**. Date: 2026-10-22. The maintainer confirmed per-calendar-first export and independent export authority. [ADR 0077](adr/0077-privacy-safe-calendar-freebusy-export.md) records those choices. Native [free/busy](calendar-free-busy.md), [working hours](native-working-hours.md) and [subject search](subject-availability-search.md) remain distinct services.

`CalendarEndpoint.exportFreeBusy(session, CalendarFreeBusyQuery)` returns `ByteData` containing one standalone VCALENDAR/VFREEBUSY snapshot. The immutable request selects one actual calendar and explicit UTC bounds. Existing whole-second and ordinary **[1970-01-01, 2100-01-01)** guards apply, with midnight 2100 allowed only as an explicit exclusive upper endpoint. Queries are increasing and at most 31 elapsed days. No schema, stored export object, migration or reset is added.

## Calculation and complete coverage

Use every required booking and availability-rule projection, including recurring/overridden DATE/UTC/named-zone events, all-day calendar zone, status/transparency, RFC 7953 rules and no-rule fallback. This is the same bounded calculation used by native free/busy, never the privacy-filtered detail list. Tentative opaque events block time with a distinct classification; cancelled, transparent and point events do not create occupied intervals. The existing shared work/source limits and 1,000-interval result bound still apply.

Unknown/incomplete/denied/over-cap source coverage rejects export with no file (`unavailable` for the calculation's unknown result). Do not serialize an unknown result as all free, omit an inaccessible source, or silently return a partial configuration. The pure output adapter also requires a contiguous, ordered, nonoverlapping complete partition of its supplied window; empty input, holes, out-of-window intervals and unsupported timing reject before any result is returned.

## Output profile and identities

| Native classification | Output |
| --- | --- |
| busy | `FREEBUSY;FBTYPE=BUSY:<UTC start>/<UTC end>` |
| tentative | `FREEBUSY;FBTYPE=BUSY-TENTATIVE:...` |
| unavailable | `FREEBUSY;FBTYPE=BUSY-UNAVAILABLE:...` |
| free | Omitted only after complete coverage is established |

Adjacent equal classifications merge. Emit one PERIOD per FREEBUSY property in ascending start/end order; no property mixes types. All-free complete coverage emits the required metadata and bounds with no FREEBUSY properties. The output is bounded to 1 MiB using the existing CRLF/UTF-8/folding writer. The pure `serializeIcalendarFreeBusy` writer accepts supplied UID/stamp/window/complete partition and independently validates timing, structure and limits. It is output-only; standalone file import remains deferred.

Each successful endpoint call creates a fresh unrelated protocol UUID and whole-second database-clock DTSTAMP for this newly constructed snapshot. These are not calendar/event/rule identities, persistent scheduling identities, an update counter or a stable ETag. Database audit clock precision is converted explicitly to a generated whole-second protocol stamp; user-supplied fractional calendar timing is still rejected. Repeated reads may have different UID/DTSTAMP even when intervals are unchanged. Stored revisions, content, protocol state, audit times and scope generation remain unchanged.

The component includes UID, DTSTAMP, UTC DTSTART/DTEND and occupied FREEBUSY periods; the envelope includes VERSION and PRODID. It contains no calendar/event/rule IDs or names, event counts, title, location, participant/organizer/contact data, URLs, recurrence, raw working-hours definitions or VTIMEZONE. RFC 5545 describes DTSTART/DTEND as an inclusive enclosing VFREEBUSY window. Native calculation retains `[from, until)` intervals and emits these same enclosing bounds: no second is subtracted and no additional interval beyond the native end is inferred. The explicit 2100 endpoint does not extend ordinary supported dates.

## Current authorization and transaction

Require `readFreeBusy` and independent `exportFreeBusy` on the actual parent before calculation. Each actual required event uses `projectEventBusy`; each actual availability definition uses `projectAvailability`. Event detail, calendar metadata and raw-rule read rights are not required and do not substitute for these projection rights. Hosts can map independent permissions to the same rule.

Policy requests carry trusted actor/scope, actual parent/object snapshots and the immutable query. The complete projection request set is retained privately during calculation. Under the shared durable scope transaction, serialize first, repeat parent query/export and every source projection check in bounded policy batches, then verify actor/scope/policy context immediately before returning bytes. Denial or unavailable policy at either stage returns no file. Scope locking coordinates module writes across hosts; external policy services retain their documented after-check revocation race. No generic source authorization cache or response reuse is introduced.

## Example and remaining boundaries

The Flutter calendar free/busy screen can calculate native results or request a fresh VFREEBUSY snapshot for its entered bounds, display the returned text and explicitly copy it. It never constructs a file from a previous client-side result. Errors clear old export text. The automated browser journey inspects actual returned output and absence of private titles/IDs; clipboard behavior is not separately claimed as tested.

This is authenticated standalone output. It installs no bearer URL, HTTP route, ETag, subscription, scheduling METHOD, mail/notification job or reservation. The optional feed module remains separate. Subject/common-free export, standalone VFREEBUSY import (deferred), RFC 5546 REQUEST/REPLY/PUBLISH authority and external-client interoperability require their own work. A complete calendar snapshot does not claim complete availability for a person with other contributing calendars.

Validation commands/results are recorded in [the validation record](scaffold-validation.md#privacy-safe-vfreebusy-export-2026-10-22).

Sources: [RFC 5545 VFREEBUSY](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.4), [UTC PERIOD output](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.2.6) and [busy classifications](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.2.9).
