# Timing-only imported alarm adoption

Status: scoped implementation under [ADR 0115](adr/0115-timing-only-source-alarm-adoption.md), with focused and full local batch validation passed. API mechanics remain draft review material. No table changes or migration are required.

Users may explicitly copy master-component DISPLAY alarm timing from an imported event or task into a new personal definition. The copy is **unarmed**. It uses current authorized event/task text when later delivered; source custom reminder text is not copied. Source DESCRIPTION, UID, ACKNOWLEDGED and snooze relationships remain unchanged source data and create no native identity, acknowledgement, snooze or delivery state.

## Review and copy

`calendarAlarm.sourceTimings(parent, dateZoneId)` returns the actual native parent revision and a bounded ordered list of timing definitions. It requires `readEventSource` or `readTaskSource` independently of ordinary detail groups and personal-alarm permissions. Only timing is disclosed: absolute UTC or relative sign/units/anchor, paired repeats and the explicit optional DATE zone. It does not disclose source text or participant addresses. An unsupported mapping fails the complete review; it is never silently omitted.

`calendarAlarm.adopt(parent, expectedParentRevision, sourceIndex, dateZoneId)` selects a zero-based index under that exact current parent revision. The server loads actual scope/calendar/parent and source timing; clients cannot supply trusted timing, recipients or source parentage. Source-read permission is required before source-dependent revision/index errors. Independent `adoptPersonalAlarm` and `createPersonalAlarm` gates receive actual object/recipient, selected `alarmSourceIndex` and validated proposed settings. Final checks repeat source/create/adopt authority and recipient/context validation under the host's declared consistency guarantee. The external fresh-check revocation race remains documented in the shared authorization guide.

Creation reuses the existing scope lock, 16-definition per-recipient/item cap, fresh native UUID, hidden receipt behavior and audit clock. It changes no shared item/protocol revision, source baseline or public scope generation. It creates no plan, firing or action row and never arms anything. Ordinary arming has its own permission and revision check.

Relative DATE timing needs an explicitly supplied exact named zone, using the existing midnight-anchor policy. The example displays a prefilled editable zone; the server never infers a device/server/calendar zone. Calendar duration units and repeat units remain intact rather than becoming elapsed seconds. Invalid zones, native-limit violations and unavailable parent anchors reject atomically.

## Example and ongoing behavior

The personal-alarm screen provides **Review imported alarm timing**, displays trigger/repeat settings and the reviewed revision, then offers **Copy as unarmed**. Editing the zone invalidates the preview. A stale parent change requires another review. Source custom text is deliberately absent from the review/copy; current authorized item text supplies future live presentation.

The definition is an independent copy, not a synchronized source link. Later source-alarm changes do not rewrite its settings. Parent timing/lifecycle edits still affect ordinary compatibility and planning. Selecting a source snooze alarm copies its explicit timing only; it does not preserve the relationship or acknowledge an original native alarm. Only master alarms are selectable in this first profile; separate occurrence-source adoption is not implied.

Repeating a copy operation can intentionally create another definition within the existing cap. After an uncertain response, refresh your private list before retrying. There is no persistent source association, adoption idempotency ledger, copied-text field or provider data. Private exports and richer adoption profiles remain separate work.

See [personal definitions](native-personal-alarms.md), [live delivery](reusable-notification-delivery.md) and [actual validation](scaffold-validation.md). Ordinary file import remains inert; this explicit action does not activate source alarms automatically.
