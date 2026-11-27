# Authenticated availability export

Status: **scoped current-state availability export under ADR 0074; concrete mechanics under draft review**. Date: 2026-10-22.

Call `calendarAvailability.exportCalendar(CalendarAvailabilityExportRequest(...))` through the authenticated generated client. Supply one calendar UUID, its expected revision and an explicit nonempty list of `CalendarAvailabilityExportSelection(availabilityId, expectedRevision)` values. The maximum is 64 distinct definitions. The result is `ByteData` containing one complete UTF-8/CRLF standalone availability calendar. Nothing is streamed before the complete request succeeds.

The maintainer confirmed explicit selection and all-or-nothing behavior. Export is independent of HTTP subscriptions: no bearer credentials, feed selections, ETags, routes or scheduling messages are created. Event/task export remains separate. [ADR 0074](adr/0074-authenticated-availability-export.md) records this boundary.

## Host authorization and consistent selection

The module resolves trusted actor/scope and the actual active calendar. An initial `exportAvailability` decision authorizes the parent before selected IDs are resolved. In the same durable scope transaction, resolve every actual definition and require that it belongs to that exact calendar. Require parent/member `exportAvailability` and every member's `readAvailability`, independently of ordinary management-list permissions or mutation-receipt disclosure. Reject the whole request for any denied, missing, deleted, foreign or mismatched member; never silently omit one. Unavailable policies fail unavailable.

The immutable `CalendarAuthorizationRequest.availabilityExport` contains the full normalized current selection after loading. Every member snapshot includes actual native parent/object IDs, revision, protocol UID, validated content, retained occurrence edits and protocol state. Individual member requests also contain `currentAvailability`; parent requests contain the actual current calendar snapshot. Hosts can evaluate both object and batch rules without trusting client parentage or a filtered list. The initial cheap parent check has no full selection yet. Policy calls respect the installed batch-size cap.

After initial selection authorization, check the supplied parent/member revisions. Reauthorize the exact same frozen selection after serialization and current extension validation; recheck trusted context before returning. Module data remains consistent under the shared database scope lock across hosts. Export increments no scope generation, revision, audit time, protocol stamp or SEQUENCE. An external fresh-check policy can still change after its last check; this is not a permission lease or an automatic commit-coordination guarantee. See [authorization consistency](authorization-consistency.md).

## Preserved component meaning

Output uses current stored semantics, including native edits after import:

- Exact definition/opening text UIDs, separate from native UUIDs. Native API identity fields, API revisions and database audit fields are not serialized. An independent protocol UID can have the same spelling as a native UUID; that does not turn it into an API reference.
- Independent component DTSTAMP and optional CREATED/LAST-MODIFIED; definition SEQUENCE omissions remain omissions. Export does not reset or advance protocol versions.
- Optional independent definition bounds or nominal duration, priority and closed-time kind; positive UTC/named-zone opening spans retain explicit end or duration forms.
- Supported RRULE with WKST, RDATE/EXDATE, PERIOD additions and single/THISANDFUTURE timing overrides. Native ISO week display conventions remain independent of rule-specific WKST.
- Supported text, legal LANGUAGE/ALTREP, repeated category/comment/contact groups, organizer/URL/class and registered decoded-TEXT private properties. Override metadata omission masks and independent source stamps survive output. No links or addresses are fetched or executed.

Definitions sort by protocol UID and zones by exact identifier, making repeated exports of unchanged selected state deterministic regardless of selection order. Metadata group/value order and duplicates remain intact. Output is semantic/canonical, not the original source bytes. Use the module PRODID and Gregorian VCALENDAR envelope; imported producer spelling, VTIMEZONE syntax and parent calendar/feed presentation are not component data being archived here.

Organizer data is stored publication metadata, not proof of ownership or authority. Export requires raw read plus export permission; it does not perform organizer write approval or send anything. A host can independently deny export based on organizer/current metadata in its snapshot. Installed private-extension validators run on emitted current data; missing registrations, false results or callback failure reject the export. Raw read rights alone do not imply export rights.

## Timezone generation and limits

Continue using the pinned `timezone` library and generated IANA database under [the update procedure](timezone-data.md). `NamedZoneResolver.calendarProfileObservances` exposes immutable known-offset publication evidence, including IANA daylight/standard flags. Calculation and offset-only matching semantics remain unchanged. The pure iCalendar `createIcalendarTimeZone` helper groups explicit onsets by from/to offsets and daylight flag, preserving unusual second offsets, half-hour changes and negative daylight saving. It includes only zones referenced by the selected definition timing, including retained overrides, without guessing aliases or changing supplied identifiers.

The seed and transitions cover calculation-only UTC [1969-12-31, 2100-01-02), matching existing import validation. The seed is not an ordinary stored event date. No unbounded future timezone RRULE is generated. Ordinary dates remain **1970-01-01 inclusive to 2100-01-01 exclusive**, whole seconds only, with the approved exclusive midnight endpoint. Generated definitions must not be assumed correct outside this horizon; future offsets assume the pinned IANA rules remain applicable. Updating data requires regeneration and the documented semantic checks, not manual payload edits. This batch supplies no real-client interoperability evidence.

The complete output is revalidated against the availability import profile. Defaults remain 1 MiB output, 64 definitions, 128 raw AVAILABLE components including timing overrides, 32 zones, 128 total timezone observance components, 8192 onsets, shared candidate/explicit-date/rule-value/metadata budgets and existing syntax limits. Reject over-cap selections without truncating components, dates or zone transitions. Storage may hold a selection too large or too expensive for one wire file. Host HTTP response/body handling also applies to ByteData's JSON/base64 transport representation.

## Native states that reject

The selected wire profile cannot represent every valid native state. Export fails explicitly for:

- Native skipped opening occurrences, whose independent skip/restoration state may retain a prior timing replacement. Replacing that state with EXDATE would lose restoration information. Existing ordinary stored EXDATE exclusions remain exportable.
- Timing components without a stored independent protocol checkpoint, including legacy shapes whose history is unknown. Export never invents DTSTAMP/CREATED history to force acceptance.
- Equal opening protocol UIDs across separately stored selected definitions. The current standalone file profile rejects these; export does not rename the source identities. Individual exports may still succeed.
- Other native state outside the current declared wire grammar or aggregate budgets. No unsupported field is silently dropped, recurrence flattened or partial file returned.

Input shape/profile failures use sanitized `validation`, exhausted limits use `limitExceeded`, stale authorized selections use `staleRevision`, missing/foreign/denied selection uses `accessDenied`, and policy/validator outages use `unavailable`. Errors contain no private source value or hidden object's identity/count. A rejected read leaves stored state untouched.

## Example and validation

Each definition in the example Working hours screen has an explicit Export action. The screen displays selectable iCalendar text and offers a user-triggered copy action. It fetches the current parent revision and uses the selected displayed rule revision; a stale rule rejects rather than silently exporting another version. This screen is not an HTTP subscription route or scheduling invitation.

Focused VM tests cover mapping/semantic round trips, independent host rights, complete current snapshots, denied/changed selections, stale/mismatched/deleted targets, extension outages, deterministic order, no mutation and profile rejection. Pure core/iCalendar tests cover pinned daylight evidence and full-horizon generated-zone validation. The complete batch additionally checks VM/Chrome, database/upgrades, two independent hosts/generated clients, Flutter export journeys and web build; actual results are recorded in [validation evidence](scaffold-validation.md).
