# Availability opening edits and metadata

[ADR 0059](adr/0059-availability-occurrence-edits-and-metadata.md) extends native working hours with opening-occurrence previews/edits and scoped metadata. All calendar, subject and common-free calculations use saved timing changes; raw definitions remain authenticated-only. Wire import/export is still pending.

## Occurrence API

Use `client.modules.serverpod_calendar.calendarAvailability`:

| Operation | Contract |
| --- | --- |
| `preview` | Definition/opening UUIDs, expected definition revision and whole-second UTC bounds, at most 31 days |
| `changeOccurrence` | Definition/opening UUIDs, expected revision, exact original start, action and replacement only for timing replacement |
| `getRule` | Returns current content and separate `timingOverrides` under raw read authority |

Actions reuse `CalendarEventOccurrenceAction`: replace/clear single timing, `cancelSingle`/`restoreSingle` (skip/restore an opening), and replace/clear future timing. This naming shares a timing adapter; openings do not acquire event STATUS or transparency. Opening replacements require a positive end or duration, never a timed point, DATE or floating value. No future skip/cancellation or per-occurrence text is supported in this increment.

Keep original identity after moving an occurrence. A skipped single retains its replacement timing; restoring exposes that timing. Clearing single timing leaves its skip flag intact. Future timing shifts apply in original recurrence order until the next future anchor; independent singles retain precedence. Explicitly clear a same-anchor single before creating a future change, or vice versa. Shared zone/whole-second/ISO/WKST/DST and duration rules remain in [the temporal core](temporal-core.md) and [timezone limits](timezone-data.md).

Ordinary pattern/timing updates preserve and revalidate edits for surviving opening UIDs. Incompatible/orphaning changes reject until the relevant edit is cleared. Deliberately deleting an opening removes its series and edits; changing identity never silently retargets them. State lives outside ordinary content in a nullable active-data JSON column. No bulk-clear field can bypass retained-state validation. Definition revision covers all metadata, opening and occurrence actions.

Preview returns full effective opening occurrence geometry and original anchors for the bounded series query. It is **not** clipped availability or a reservation: free/busy additionally clips openings to envelope/query bounds, applies priority/fallback and overlays bookings. Thus a raw preview can show an occurrence outside or extending beyond the definition's validity range. Unknown/denied/over-limit calculation still establishes no free time.

## Metadata API and contexts

Definitions support summary, description, location, categories, comments, URL and a confidentiality label. Openings support summary/description/location/categories/comments; URL/classification are absent from that component model. The enum label can be public/private/confidential or unspecified. Labels never grant access/publication, and location text never creates or reserves a resource.

Use `updateMetadata(CalendarAvailabilityUpdateRequest(...))` with saved complete content and expected revision to change metadata independently of opening settings. Structural/timing/recurrence/UID/order changes reject on this endpoint. Use ordinary `update` for configuration replacement; it requires availability authority plus metadata authority if its metadata signature changes, including opening identity/order changes. Start from saved content to preserve fields not being edited. The example timing editor preserves unrelated metadata explicitly. Metadata changes preserve occurrence edits and do not alter calculated opening geometry.

`list(calendarId, category: 'Work')` returns raw-authorized definitions whose envelope or any opening contains that exact category. Case, language-free spelling and spacing remain significant; this first profile has no language tags. Authorize raw reads before matching; category filtering never supplies availability source coverage. Categories carry no ownership or permission meaning.

| Native metadata limit | Value |
| --- | --- |
| Summary / location | 4096 Unicode code points each |
| Description | 16384 code points |
| Categories | 64 raw values, 256 code points each, nonblank/single-line |
| Comments | 32 values, 4096 code points each |
| Aggregate definition/opening metadata | 65536 code points, charged before category deduplication |
| URL | Existing absolute HTTP/HTTPS profile; no embedded credentials or fetching |

Categories preserve first-seen order and remove exact duplicates; comments preserve order, duplicates, empty text and multiline values. Other text is preserved without trimming. Optional list fields allow old JSON to decode, then validators freeze canonical empty lists in memory. Reads do not rewrite stored content or modification times. The small Flutter metadata form treats empty scalar text as cleared; the native API can preserve explicit empty text where valid.

## Host permissions, storage and evidence

Preview requires both `readAvailability` and `previewAvailabilityOccurrences`. Dedicated actions require `changeAvailabilityOccurrence`; metadata-only updates require `updateAvailabilityMetadata`. Mixed ordinary updates require all applicable gates. Hosts receive actual parent/definition snapshots, current edits, exact opening/action/query and validated final proposed edits; category queries include the filter. Preliminary action authorization precedes target-specific validation. Receipts remain independently disclosable. No read permission, calendar membership or scheduling authority is inferred.

Writes share the durable scope transaction, stale checks and final authorization across instances. Active data stores nullable timing overrides separately from content, so existing rows gain null without rewriting UID/revision/time/content. Removing active data also removes metadata/edits; minimal deletion markers retain none of them. Calculation responses contain no raw labels, categories, comments, URLs or edit identities. Existing complete/unknown rules and bounded expansion remain authoritative.

Caps add 16 edited-opening entries and 128 combined raw single/future edits per definition. Core membership/expansion budgets remain; exhausted work fails atomically or yields unknown during free/busy. See [validation](scaffold-validation.md), [working hours](native-working-hours.md) and [subject search](subject-availability-search.md).

Organizer authority, language/ALTREP, extensions, imported CONTACT preservation, full protocol stamps/SEQUENCE, envelope DURATION shorthand, future cancellation, occurrence text overrides and wire interoperability remain pending. No mail, alarm, feed or resource-booking side effect is introduced.
