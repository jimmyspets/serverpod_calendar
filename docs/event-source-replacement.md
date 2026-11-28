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
