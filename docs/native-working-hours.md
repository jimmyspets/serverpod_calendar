# Native working-hours definitions

The native module stores recurring opening hours and composes them into per-calendar free/busy under [ADR 0057](adr/0057-native-working-hours.md). [Opening-occurrence edits and scoped metadata](availability-occurrences-and-metadata.md) now extend that native profile, and [person/resource/common-free search](subject-availability-search.md) uses the per-calendar results. Wire import/export, organizer/language/ALTREP/extensions and the remaining protocol metadata profile are still pending.

## API and timing

Use `client.modules.serverpod_calendar.calendarAvailability`:

| Operation | Contract |
| --- | --- |
| `create` | Calendar UUID and complete validated content; server generates definition/opening identities |
| `getRule` | Definition UUID; authorized full raw definition |
| `list` | Calendar UUID; bounded authorized configuration collection, UUID order, no totals/cursor |
| `update` | Definition UUID, expected revision and complete replacement content |
| `deleteRule` | Definition UUID and expected revision; removes active content, keeps minimal marker |

`CalendarAvailabilityContent` contains optional summary, `validFrom`/`validUntil`, priority, `closedKind` and openings. Bounds are optional start-only `CalendarEventTiming` values: UTC or exact named-zone civil DATE-TIME; `validUntil` is exclusive. Each opening has its own `timing`, optional `recurrence` and server-issued `uid`. Reusing timing/recurrence DTOs does not make openings events. Positive end or duration is required; no event status, transparency or booking side effects are implied.

Example: an unbounded priority-0 definition with Monday–Friday 09:00–17:00 Europe/Stockholm openings remains anchored to that zone even if the calendar's availability zone changes. Supply a DTSTART matching its weekly weekday filter. Explicit recurrence dates retain that opening's UTC/named-zone profile. Use exclusions for whole opening occurrences omitted on holidays, or a higher-priority bounded definition with no openings for a closure. All evaluation requests remain bounded, at most 31 days, within [1970,2100). Optional envelope bounds do not extend supported dates.

The shared recurrence engine preserves WKST and its rule-specific week numbers; presentation remains ISO Monday-first. Explicit gap/fold and generated-gap behavior, exact-end versus nominal duration, whole-second rejection and generated IANA future-data limitations remain as documented in [the temporal core](temporal-core.md), [week conventions](week-conventions.md) and [timezone updates](timezone-data.md). Native envelope DURATION shorthand remains pending; opening-occurrence edits now follow [ADR 0059](adr/0059-availability-occurrence-edits-and-metadata.md).

Updates are full configuration replacements, including explicit date lists. Fetch the current definition, preserve fields not being edited and send its expected revision. Supply existing opening UIDs unchanged; use null for a new opening. Foreign or duplicate UIDs reject. Removing entries deliberately deletes them. UIDs are stable independently of list position; application revisions are separate from future protocol SEQUENCE.

## Priority and results

1. Within each effective envelope, the highest priority wins: **1, 2, …, 9, 0**. Omitted priority defaults to 0, the lowest.
2. Equal-priority openings combine by union. Where none opens a segment, equal-priority closed types rank **BUSY > BUSY-UNAVAILABLE > BUSY-TENTATIVE**.
3. Higher-priority definitions replace lower-priority hours throughout their effective envelope, including closed portions. Openings clip to their envelope and the query.
4. Apply calendar fallback only where **no definition is effective**. An effective definition with no openings is closed, even if fallback is free.
5. Overlay opaque confirmed/tentative bookings and occurrence edits/cancellations. Openings never erase bookings. The native final-result order remains **unavailable > busy > tentative > free**, distinct from equal-priority rule BUSYTYPE ordering.

For example, priority-0 weekday hours can be replaced by a priority-5 holiday closure, then by a priority-1 temporary opening over a narrower interval. A booking in that temporary opening still blocks it. Separate calendars retain independent rule priorities; cross-calendar [summary/search](subject-availability-search.md) intersects complete independently evaluated results. Results describe a snapshot, not an exclusive reservation.

These rules follow [RFC 7953 sections 4–5](https://www.rfc-editor.org/rfc/rfc7953.html#section-4). No external-client rendering or full RFC interchange claim follows from native tests.

## Authorization and limits

Hosts independently grant management operations and `projectAvailability`. A caller may obtain free/busy without seeing raw hours or rule labels. The module supplies actual calendar/definition IDs, immutable snapshots, full proposed content and query context. Raw reads are all-or-nothing for this slice. Missing/denied/corrupt/over-limit required rule projection produces unknown coverage with no periods; filtered management lists never supply calculation coverage. Rule IDs, labels, opening UIDs and source counts are absent from free/busy responses.

Writes, parent-dependency checks and free/busy share the durable scope transaction; expected revisions and final authorization are enforced across hosts. Child changes advance scope generation and their own revision/time, without changing the parent's metadata timestamp. No process-local cache or lock provides correctness. Deletion has no restore/archive/cascade feature.

| Trusted cap | Value |
| --- | --- |
| Active definitions per calendar / management list | 64 |
| Stored opening masters per definition | 128 under ADR 0072; query source caps remain separate |
| Source openings evaluated per query, combined | 64 |
| Expanded opening intervals, combined | 5000 |
| Expansion candidate / raw-base / result budget per opening | 200000 / 10000 / 500 |
| Rule background / final classified periods | 1000 each |
| Summary length | 4096 Unicode code points |

The query source cap includes all active definitions/openings, including outside the query; larger stored configurations can return unknown. Event-source limits in [free/busy](calendar-free-busy.md) remain. Work is bounded per opening and by source count; no global 200000-work guarantee is claimed. Failures do not truncate results or manufacture free time.

The Flutter example offers simple daily/weekly single-opening hours, explicit dates, closures, priority and UTC validity fields. Unsupported advanced native definitions stay readable and cannot be saved through that small form. Stale saves retain the draft and require reopening current values. Full native definitions remain accessible through generated APIs. See [validation evidence](scaffold-validation.md).

Ordinary configuration updates now preserve/revalidate separate occurrence edits on retained opening UIDs, and require additional metadata authority for metadata-signature changes. The timing form preserves unrelated metadata. See [the current editing contract](availability-occurrences-and-metadata.md).

Subsequent native scope: [protocol lifecycle and envelope duration](availability-protocol-lifecycle.md) under [ADR 0061](adr/0061-availability-protocol-lifecycle-and-envelope-duration.md) supersedes earlier pending wording for these native values. Wire/source histories, CONTACT and scheduling remain pending.

## Source-preserving storage extension

[ADR 0072](adr/0072-source-preserving-availability-storage.md) and [the current storage guide](availability-storage.md) extend the native model with exact text protocol UIDs distinct from UUID references, grouped categories/read-only CONTACT, availability-only PERIODs and independent source component versions. Existing single-group/comment representations remain supported. Authenticated import/export and scheduling remain pending. A larger stored definition can exceed the unchanged 64-source-opening query cap and return unknown; storage acceptance never guarantees complete query coverage.
