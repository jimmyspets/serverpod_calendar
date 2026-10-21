# ADR 0061: Availability protocol lifecycle and envelope duration

Status: **Accepted protocol version/opening timestamp choices; implementation mechanics under review**. Date: 2026-10-21.

## Context and sources

[ADR 0060](0060-availability-publication-metadata.md) completes the preceding native metadata batch. RFC 7953 requires DTSTAMP for VAVAILABILITY and AVAILABLE, allows CREATED/LAST-MODIFIED in both, permits SEQUENCE only on the definition and allows an envelope DURATION only with DTSTART and without DTEND. See [RFC 7953 section 3.1](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1) and [RFC 5545 section 3.8.7](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.7). This is native state preparation, not import/export, scheduling or feed support.

## Envelope duration

Add optional `validDuration` alongside the existing `validFrom`/`validUntil`. Require a start-only explicit UTC/named-zone `validFrom`, forbid `validUntil` together with duration and require a positive whole-second duration. Preserve weeks/days/hours/minutes/seconds instead of flattening into an explicit end. Reuse the existing core duration application policy: calendar weeks/days first with the selected gap/fold resolution, then elapsed clock units. One calendar day can differ from 24 elapsed hours across DST. Apply existing supported-date, zone-coverage and exclusive-end guards, including the explicit 2100-01-01 midnight upper boundary.

Calculate the effective upper bound for validation/composition without replacing the stored representation. Host proposed state sees the original duration units. Treat duration as structural state, so metadata-only writes cannot change it. The example's bounded editor can author UTC envelope durations with separate unit fields and retains its existing restriction against flattening advanced named-zone envelope configurations. No parser is introduced and no table migration is presumed for this optional nested JSON field.

## Maintainer-selected protocol lifecycle

Use server-managed whole-second UTC DTSTAMP/CREATED/LAST-MODIFIED using the shared database clock, with native application revisions remaining authoritative for multiple writes within one second. Native protocol SEQUENCE starts at zero and remains separate from application revision. The maintainer selected this significance policy: every actual normalized content or occurrence-state change increments sequence, including metadata; an identical accepted save still advances API revision but leaves protocol version/timestamps unchanged.

The maintainer selected independent opening timestamps by stable opening UID. New openings have known creation time; existing openings omit CREATED because true historical creation time is unknown. Use the containing definition's known modification time as an explicitly documented initial version baseline, then track each opening independently. This inherited baseline is not a claim about actual historical opening edits. AVAILABLE never gets SEQUENCE.

Definition timestamps can use known existing creation/modification records. The following storage and API mechanics remain reviewable in the draft implementation PR. Without METHOD, DTSTAMP has LAST-MODIFIED semantics; scheduling-message stamp/version handling remains separate. Do not manufacture historical creation times or let clients set server-managed native values.

## Acceptance conditions

Focused tests cover duration/end exclusion, missing start, positive whole seconds, preserved units, DST day/hour differences, range endpoints and zone failures, structural permission checks and free/busy clipping. For the lifecycle choices, verify unchanged saves, actual metadata/geometry/override changes, stable creation identity, independent retained/new/deleted opening state, legacy baseline disclosure, whole-second timestamps, sequence overflow, stale/final-denied atomicity, immutable actual/proposed host context and cross-instance visibility/races. Verify generated clients and the Flutter journey, then broader batch checks. Record actual results separately from this proposal and commit only the completed batch.

## Native storage and adapter mechanics

Add nullable typed JSON `protocolState` to active availability data; new definitions persist sequence zero and whole-second UTC creation/modification stamps. A null legacy state is projected from the known parent creation/modification records without a read write-back; opening CREATED is absent, and opening stamp/last-modified inherit the documented parent baseline. First accepted writes persist that baseline or its successor without changing identities or inventing earlier sequence history. No destructive transformation/backfill is required. Deletion still removes all active content/state and leaves only the existing minimal identity marker.

Use a separate read-only `CalendarAvailabilityProtocolState` in raw rule views/current host snapshots, with definition sequence/created/stamp/lastModified and a frozen opening-UID state list. The native `lastModified` view field now reflects this protocol value, including stability on identical saves. Internal high-resolution updatedAt, API revision and scope generation retain their existing accepted-write behavior. Sequence is bounded to RFC INTEGER maximum 2147483647; an actual change at that limit fails explicitly, while unchanged writes remain possible. No wrap, reset or equality with API revision is implied.

Compare validated preserved native content and separate occurrence state. Metadata, envelope representation/units, opening additions/removals/order and actual occurrence-state changes advance the definition sequence once per mutation. Existing openings advance their own stamp only when that opening's content or occurrence state changes; sibling/envelope edits do not rewrite them. New openings get known whole-second creation time; deletion drops their active timestamp entry. Current state is validated/frozen, and final host requests include the exact proposed server-managed state through `proposedAvailabilityProtocolState`. These native opening-series timestamps include their retained occurrence state; distinct serialized override-component timestamp/source-history rules remain interchange work, not a claim that each future wire exception has been independently modeled.

Read baseline projection does not alter stored UIDs, revisions, precise timestamps, scope generation or content. Tests must distinguish the inherited legacy baseline from known opening creation time. Server-managed values cannot be submitted through content requests; no protocol version permits bypassing optimistic revision checks, organizer approval or declared policy guarantees.
