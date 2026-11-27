# ADR 0059: Opening-occurrence edits and scoped availability metadata

Status: **Accepted timing/metadata scope; storage/API mechanics under review**. Date: 2026-10-21.

## Maintainer choices and sources

The maintainer selected the existing event timing policy for availability openings: single/this-and-future move or resize, single skip/restore, and preservation with orphaning-pattern rejection. Future cancellation and occurrence-specific text remain separate. They selected description, location, categories and comments on definitions/openings, with URL and confidentiality labels on definitions only; organizer, language/ALTREP, extensions and interchange follow separately.

[ADR 0057](0057-native-working-hours.md) supplies rule storage/composition and [ADR 0058](0058-subject-availability-search.md) supplies subject/common-free projections. Reuse bounded recurrence/identity/range mechanics from [ADR 0055](0055-native-occurrence-timing-edits.md), not event status or scheduling behavior. [RFC 7953 section 3.1](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1) allows recurring AVAILABLE overrides and distinguishes legal component property contexts. Native tests do not establish wire interoperability.

## Separate occurrence state and native API

Add nullable `timingOverrides` typed JSON to active availability data, containing opening UID plus shared immutable timing-override values. Old rows migrate to null without rewriting content, UIDs, revisions or timestamps. Ordinary content DTOs cannot bulk-clear this state. No materialized occurrence table or local cache is added.

`calendarAvailability.changeOccurrence` accepts definition UUID, stable opening UID, expected definition revision, start-only original identity, action and optional full replacement. Reuse replace/clear single timing, skip/restore single (internally `cancelSingle`/`restoreSingle`) and replace/clear future timing. There is no AVAILABLE STATUS property or future cancellation API here. Replacement openings must have positive explicit end or duration; timed points, DATE and floating values reject. Keep exact UTC/named-zone profile and whole-second guards. Original identity remains stable after movement. Skipping retains single timing, restoration reveals it, and clearing timing does not restore a skipped opening. Future changes use original order and independent single precedence; same-anchor single/future collisions require explicit clearing first.

Validate all anchors against the effective original recurrence set and reject orphaning/incompatible pattern edits. Content updates retain and revalidate overrides for surviving opening UIDs. Deliberately removing an opening deletes that series and its edits; replacing a UID with a new opening is explicit identity replacement, not retargeting old edits. Up to 16 edited-opening entries and 128 combined raw single/future entries per definition are allowed, counted before normalization. Existing membership/expansion budgets remain.

`preview` takes definition/opening UUIDs, expected definition revision and bounded UTC bounds up to 31 days. It returns a complete-or-failure opening-series overlap preview with original identity and effective geometry, not a reservation or free/busy result. Preview displays full occurrence geometry independently of the envelope; actual calculation clips to definition/query bounds and overlays bookings. Single/future edits immediately affect calendar, subject and common-free calculations. Missing/denied/corrupt/over-limit required calculation never becomes free.

## Metadata and authorization

Add optional description/location/categories/comments to definition content, optional summary plus those fields to openings, and URL/classification to definitions only. CLASS is a label (`public`, `private`, `confidential`, or unspecified), never ownership, access or publication authority. LOCATION never creates/books resources. URLs reuse the current absolute HTTP/HTTPS/no-userinfo/no-fetch profile. Opening types do not expose URL or CLASS. Imported CONTACT, organizer/directory authority, language/ALTREP and extensions cannot yet be stored through this API.

Text is preserved plain text. Suggested native caps: summary/location 4096 code points, description 16384, 64 raw single-line nonblank categories at 256 each, 32 comments at 4096 each, and 65536 aggregate metadata code points across a definition/openings, charged before category deduplication. Categories match exact case-sensitive text, preserve first-seen order and remove duplicates; comments preserve order, duplicates and multiline text. Reject over-limit input instead of truncating. Freeze collections before host callbacks. Optional list fields permit old stored JSON to decode; validation supplies canonical immutable empty lists without writing on reads.

Separate `previewAvailabilityOccurrences`, `changeAvailabilityOccurrence` and `updateAvailabilityMetadata` permissions. Preview additionally requires raw `readAvailability`. Mutation needs its own operation and independently disclosable receipt, without an implied read grant. Host requests include actual definition/calendar snapshots with current edits, the exact opening/action/query and final proposed edits. Preliminary occurrence intent precedes target-specific validation. All changes use expected definition revision, the durable scope transaction and final checks across instances.

`updateMetadata` uses the full existing update DTO but rejects any structural/timing/recurrence/identity/order change; it requires metadata authority alone. Ordinary `update` retains full content-replacement semantics and always requires `updateAvailability`, plus metadata authority when the metadata signature changes. That signature includes opening identities/order as well as their metadata. Hosts see the validated complete proposal and preserved edits. The example timing editor explicitly preserves unrelated metadata. Reads remain all-or-nothing raw definition disclosure; fine-grained rule masking is not implemented. CLASS can inform host denial but cannot override it.

`list(calendarId, category: ...)` filters exact definition or opening categories only after raw read authorization. Pass the category filter to host requests; do not use a category-filtered list for source completeness. No totals, directory lookup or access inference are added. Metadata edits advance definition revision/time and scope generation without changing the parent's metadata time or altering opening geometry.

## UI, validation and remaining work

The Flutter example has a metadata editor for definitions/openings, exact category filtering, opening previews, single/future timing forms and retained skip/restore/clear controls. Stale drafts/actions require reload rather than silent rebasing. Timing forms expose only positive end/duration. Shared event timing DTOs/engine do not create fake stored events or event permissions.

Test temporal identity/skip/restore/ranges/orphaning, raw caps and zero-length rejection; legal metadata contexts, frozen collections, exact categories, URL/limit rejection and privacy; independent permissions, stale/final-denied atomic writes, deliberate opening deletion, populated nullable-column upgrades, two-host visibility/races and real Flutter journeys. Record actual commands/results in [validation](../scaffold-validation.md).

Organizer/language/ALTREP/extensions/import-preserved CONTACT, protocol stamp/SEQUENCE lifecycle, native envelope DURATION shorthand, occurrence-specific text, future cancellation, ICS import/export, VFREEBUSY serialization and external-client evidence remain separate work. The scoped native profile does not complete RFC 7953 or the first release.
