# Explicit event source replacement

Status: scoped implementation under [ADR 0105](adr/0105-event-source-replacements.md), following the confirmed availability/task replacement policy. Concrete mechanics remain under draft review.

`calendarEvent.replaceFromImport(CalendarEventReplaceRequest)` atomically replaces an explicit selection of existing complete series in one calendar. Supply calendar UUID/revision, CalendarEventExportSelection entries with event UUID/revision, and strict iCalendar bytes. The supported master/occurrence components must contain exactly the selected protocol UID set. Unsupported data, wrong parents, stale revisions, empty/duplicate or oversized selections reject the entire request. There is no implicit create, unselected deletion, adoption/force overwrite or mixed synchronization.

## Baselines, versions and no-ops

Require a current-profile recorded import baseline. Validate its complete typed content/overrides/protocol state and canonical representation before comparison; valid existing generated baselines remain compatible. A source-free native event has no imported baseline and rejects with dependencyConflict. An incompatible or corrupt baseline fails unavailable rather than being invented from current content.

Canonical equality includes content, exact timing and original identities, source PERIOD additions, text annotations, supported single/future timing components, independent component versions and source omissions. A differing incoming state conflicts if current differs from the last accepted baseline. A higher source SEQUENCE cannot erase local work. Lower **master** SEQUENCE than the baseline rejects; equal is allowed and omitted means 0. This is the application replacement policy, not iTIP version reconciliation. Preserve incoming source timestamps and omissions exactly, including backwards clock corrections; they establish no authority or freshness.

Identical incoming/current state is a true no-op, including after local edits: recheck baseline, source version, revisions and authorization but alter no API revision, audit timestamp, protocol state, private baseline or scope generation. Never adopt a locally changed state merely because a file matches it. Source envelope/formatting and regenerated zones remain outside the canonical component comparison.

Changed members keep native UUID and creation time, replace the complete supported contents and baseline, increment API revision and use nondecreasing database audit time. Scope generation advances once iff any selected member changed. Protocol versions remain the source's exact independent values. Existing tables suffice; no migration is needed. No scheduling messages, participants, subscriptions or alarm activation follow from replacement. The existing strict full-horizon zone and whole-second 1970–2099 profiles remain unchanged.

## Independent host authority

Require importEvents and replaceEventsFromImport on the actual parent and each selected event, plus readEvent with all six field groups before equality/conflict classification. This matches the complete supported event export profile, including source annotations and versions; it does not preapprove disclosure for future richer metadata.

Changed replacements require updateEvent. Additionally require changeEventStatus for any effective master status transition or change to the exact set of individually cancelled originals. This covers adding/removing a cancelled component and restoring a cancelled master. Editing timing/text while the same cancellation state remains does not itself transition lifecycle. Identical retries need no edit/lifecycle gate because they change nothing. Unrepresentable or detached components still reject through the existing pure profile.

The trusted CalendarEventReplacementIntent contains immutable actual current/proposed series, actual parent/native IDs, baseline profile/sequence and, after authorized classification, changed/localChanges. Historical baseline payloads are excluded from intents and ordinary responses/exports. Snapshot bytes and selection before awaits; repeat final authorization/context checks under the durable scope transaction and declared guarantee. Fresh external checks retain the documented after-check revocation race. Denial, stale/invalid members, overflow and storage failures roll back the whole selection. Minimal changed receipts require host receipt disclosure and grant no additional content access.

## Example and evidence

The saved event editor offers an explicit source replacement screen when no unsaved draft exists. It loads the authorized current export and submits one selected series. A disclosed no-op leaves editing enabled because its expected revision remains valid; changed/undisclosed results require reopening, and stale/conflicting results have no automatic retry. The editor explicitly normalizes pasted line endings to CRLF; the byte API remains strict. Returning reloads the saved event revision.

Focused tests cover independent gates, each withheld group, master/own cancellation removal and addition, tentative transitions, canonical baseline corruption, exact omissions/backwards timestamps, equal/lower SEQUENCE, local conflicts/no-op baseline retention, frozen inputs/intents and whole-batch final-denial/overflow rollback. See [validation](scaffold-validation.md) for actual commands and broader two-host/Flutter outcomes. Adoption/overwrite, per-occurrence content, future cancellation, richer event metadata, scheduling, feeds and client interoperability remain separate.

## Selected event occurrence content, 2026-10-24

[ADR 0106](adr/0106-single-event-content-overrides.md) and [the content guide](event-occurrence-content.md) extend events with selected summary/description/location exceptions, explicit clear/inherit, protected preview groups and anchor-local own wire text/annotations. Content-only exceptions preserve timing inheritance and reject lossy export; explicit timing components can round-trip local content. Master edits preserve pinned fields. Private event-source-v2 baselines supersede v1, which rejects fail-closed and requires explicit development recreation/reimport; no automatic reset/adoption is performed. This supersedes earlier timing-only/content-pending wording only for this scoped slice. Future content/cancellation, richer profiles, scheduling and feeds remain separate.

## Read-only event source metadata, 2026-10-24

[ADR 0107](adr/0107-read-only-event-source-metadata.md) and [the metadata guide](event-source-metadata.md) add source-preserved CLASS/URL and grouped CATEGORIES/COMMENT/CONTACT with legal annotations. Native editors retain these values; source-only values grant no authority and cause no retrieval. Independent `readEventSource` gates complete export and source replacement, including no-op/final paths. Omitted occurrence metadata inherits and explicit values must match the master; native metadata-only originals preserve timing inheritance and reject lossy export. Nullable server-only JSON fields preserve v2 baseline compatibility, with no new table columns or automatic reset. Broader/native metadata editors and other profiles remain separate. Broader batch verification is recorded in scaffold-validation.md.


### Event source participants — ADR 0108

[Inert event source participants](event-source-participants.md) now extend the bounded read-only source profile with ORGANIZER/ATTENDEE, preserved through storage, native edits and authorized import/export/replacement. They remain outside ordinary responses under independent source-read permission, with no host identity mapping, authority or invitations. Omitted own claims inherit; explicit claims must match the master. Native participant editors, richer profiles and scheduling remain separate.


### Inert event source references — ADR 0109

[The bounded source-reference profile](event-source-references.md) preserves unresolved RELATED-TO UIDs and URI-only ATTACH values through storage, native edits and authenticated import/export/replacement. Existing source-read authority protects disclosure; no native graph, target/file access, fetching, mail copying or scheduling follows. Extended relationships and native editors remain separate. Nullable source JSON adds no table columns/migration and preserves prior v2 snapshots; a narrow decoder correction handles omitted empty participant parameter maps without changing canonical bytes.
