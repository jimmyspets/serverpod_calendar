# Native personal alarm definitions

Status: scoped definition/storage/editor implementation under [ADR 0111](adr/0111-native-personal-alarm-definitions.md). Confirmed product choices are separate from concrete mechanics under draft review. Commands/results belong in [validation evidence](scaffold-validation.md). A later [ADR 0112 execution increment](durable-alarm-planning.md) adds explicit arming, complete durable planning and guarded host handoff. Acknowledgement/dismiss/snooze commands and notification delivery remain unimplemented.

## Private definitions

The host resolves the authenticated current recipient through `CalendarHostPolicy.resolveAlarmRecipient`, returning an opaque namespace/key. Requests cannot select a recipient; source ORGANIZER/ATTENDEE or alarm UIDs never identify one. Hosts can replace this mapping without using a fixed user/owner/role model. Final writes re-resolve recipient and actor/scope context under the declared coordinated or external fresh-check guarantee. External checks retain the documented after-check revocation race.

`CalendarAlarmEndpoint` offers parent-scoped list/create/update/delete. Each request names one actual event or task; the server loads its real calendar and scope before policy checks. Separate `readPersonalAlarms`, `createPersonalAlarm`, `updatePersonalAlarm` and `deletePersonalAlarm` checks include trusted recipient, actual parent/calendar, current alarm/settings and validated proposed settings. Permission to read/edit an event or read its imported source alarms does not automatically grant these operations. Hosts must decide whether the alarm anchor-compatibility projection is disclosable.

One private `serverpod_calendar_alarm` row stores UUID, scope, calendar, typed event/task parent reference, recipient namespace/key, revision, immutable definition and database audit times. The typed reference represents exactly one parent; event/task membership is enforced by the transactional service, rather than a polymorphic database foreign key. The calendar has a database foreign key. UUIDs are opaque references, never authorization. No provider/device tokens or host user profiles are stored.

A shared scope lock serializes private limits, stale revisions and parent-deletion races across hosts. Each recipient/item has at most 16 definitions. The list is complete and bounded, has no totals or continuation, and fails if any required authorization is unavailable/denied; it never queries another recipient through a client identity. Create/update return a nullable view honoring host mutation-receipt disclosure. Independently authorized list can retrieve current state. Alarm revisions advance on accepted updates; item content/API/protocol versions and import baselines stay unchanged. Private writes do not advance public scope generation, avoiding unnecessary invalidation from private activity.

## Timing settings and limitations

A definition contains exactly one absolute whole-second UTC instant or signed relative duration plus START/END anchor. Relative triggers apply to each original recurring occurrence. Absolute UTC has one anchor per item/definition, followed by any configured repeats. Per-occurrence personal overrides are separate future work. Absolute triggers can be defined on undated tasks. Relative START needs a start; END needs explicit event end/task due or start/duration. Implicit all-day event ends and timed points are insufficient END anchors.

DATE-relative settings require an explicit exact named IANA zone, with midnight in that zone as the selected future planning anchor. The example prefills a zone but the server never infers one. A relative definition may retain that explicit DATE zone while the parent has timed values; it is unused until needed. Absolute definitions have no relative anchor/zone. Pinned IANA/profile limits and RFC gap/fold rules remain unchanged. Calculation applies weeks/days in calendar fields before elapsed clock units; saving settings alone does not arm a definition.

Duration units and sign are preserved, with 366-day equivalent offset/interval/repeat-span limits, 0–100 additional repeats, and a required paired positive interval. Nonzero fractions, mixed week/other-unit durations, invalid exact zones, unsupported trigger shapes and exhausted limits reject rather than normalize away settings. Ordinary calendar dates remain 1970–2099; calculation padding does not extend storage.

Creating/replacing settings requires a compatible current master anchor. Later shared edits can remove an end/start or switch to DATE without a stored DATE zone: retain the private definition and report `anchorCompatible=false` (needs attention). This diagnostic describes the current master only; it is not readiness for delivery and does not promise that every effective occurrence is valid. The planner checks each effective occurrence, timezone coverage, calculated instant, recipient access, lifecycle and expiry. Private definitions cannot block another user's authorized shared edit. Cancellation/progress retains configuration; current worker suppression is documented in the execution guide.

Authorized parent deletion removes every recipient's definition rows atomically with event/task content, without an extra private-alarm permission or existence disclosure. Deleting a definition removes the row completely, retaining no marker/archive/restore state. A later request against a missing/deleted/wrong-parent/foreign-recipient alarm is denied. Development database resets are not required; generated migrations add an empty private table and retain existing data.

## Example and boundaries

Event/task lists open a Personal alarms screen for the current host recipient. Editors cover relative units/sign/anchor, optional repeat settings, absolute UTC and DATE zone. Creation remains **unarmed**; separate arm/disarm controls and private planning status now follow under ADR 0112. Acknowledgement/snooze controls remain separate. Notification text will derive later from freshly authorized parent content; custom text remains separate.

Native definitions are independent of [unarmed event source alarms](event-source-alarms.md) and retained VTODO source alarms. Import creates none, export includes none, and this API does not adopt source data. A definition alone grants no notification, stream, display or mobile background delivery. Explicit arming now creates durable planning work; source/native actions remain separate. Planner/outbox/action/notification contracts and multi-instance crash/retry evidence remain required before the first release.


## Confirmed execution and later action choices

The maintainer selected explicit authorized arm/disarm, a rolling 30-day bounded planning horizon with refill, and host-configurable late eligibility with a 15-minute example default. Native creation remains unarmed; imported-source adoption remains separate.

Task alarms suppress delivery for any explicit completion/cancellation signal: COMPLETED/CANCELLED status, a COMPLETED instant or 100 percent complete. This does not rewrite independent imported source fields. Acknowledge/dismiss/snooze will suppress remaining automatic repeats for that original occurrence only; snooze will acknowledge the original and create one replacement firing. Recovery selects the latest eligible overdue firing per definition, recording other eligible firings as suppressed and older ones as expired. Planning/lifecycle/recovery now have the scoped ADR 0112 implementation. Native action commands remain confirmed future work.

Persistent work/lease mechanics, density/resource bounds, background recipient authorization, action-state handling across replanning, snooze bounds and notification handoff/retry still need concrete review and tests before arming/delivery. They must retain the shared-storage/two-instance recovery requirements.


## Host upgrade

This is an unpublished breaking host-adapter change: implement `resolveAlarmRecipient(Session, CalendarHostContext, Transaction, CalendarAuthorizationPhase)` and explicitly decide the four personal-alarm operations. The [demo adapter](../example/calendar_example/calendar_example_server/lib/src/calendar_policy.dart) maps its trusted private demo principal to one namespaced recipient; production hosts supply their own mapping and declared coordination. Apply the generated additive module/example migrations through the normal pinned workflow; a fresh development database is not required. Never derive a recipient from source addresses or client request fields.


## Execution policies and calculation foundation

[ADR 0112](adr/0112-bounded-durable-alarm-planning.md) records the next execution contract: a complete rolling 30-day window within a configurable budget (initially 1,000 firings per definition), otherwise needs attention. Automatic repeats count before suppression or recovery coalescing. Acknowledgement/dismissal remains attached to the same alarm and exact original occurrence across timing/settings edits until explicit reset; removed originals are never retargeted. A native snooze will require a future whole-second UTC instant within seven days of database time, replacing the pending snooze without chains. The native action APIs are not implemented yet.

The pure `AlarmTiming` core value now calculates UTC, named-zone and explicitly zoned DATE anchors. Calendar weeks/days precede elapsed clock units; repeats start at the preceding resolved firing, preserving later-fold instants. END requires an explicit end or duration. Negative offsets can use the permitted exclusive endpoint, but every resulting firing must be ordinary supported UTC time. A failed calculation returns no partial firing list.

The pure `AlarmPlan.complete` primitive validates a caller-supplied complete candidate sequence for a bounded window. It rejects duplicate original/repeat identities, enumeration failure and work/firing budget overflow before returning any plan. It snapshots action suppression, classifies expiry separately and retains only the latest eligible overdue candidate, with deterministic identity ordering for ties. This primitive does not enumerate series, prove that supplied candidates are complete, persist work, authorize access or deliver anything. The future worker must establish completeness and revalidate actual state and authority itself. Operational clock fractions are preserved when checking expiry; stored firing times remain whole seconds.


## Later execution increment — supersedes unarmed-only wording

[Durable planning](durable-alarm-planning.md) under ADR 0112 now implements explicit separate-authority arm/disarm, private planning status, whole-window planning, fenced workers and guarded host handoff. Creation and imported source alarms remain unarmed. Calculation and task lifecycle suppression are implemented; native action commands and reusable notification/stream delivery remain pending. The example port does not claim acceptance or display. Earlier sections describe the initial definition-only batch; they no longer mean that every saved native definition must remain unarmed.

## Native action extension

[ADR 0113](adr/0113-native-alarm-actions.md) now adds [private activity pages and acknowledgement/dismiss/reset/snooze](native-alarm-actions.md). Snooze responds to a due/accepted automatic origin; reset cancels the selection and restores future automatic eligibility only. Action writes retain definition/public/protocol revisions and scrub private continuations on alarm/parent deletion. Notification delivery remains unconnected.


## Connected live delivery extension

[ADR 0114](adr/0114-reusable-notification-delivery.md) now connects the example delivery port through the [generic live notification module](reusable-notification-delivery.md). This supersedes earlier unconnected-delivery wording for that scoped path. Recovery uses fresh source/recipient authorization and current text, without copied content; the example declares fresh-check consistency. Imported adoption, advanced actions, providers and the remaining release gates stay separate. See [the actual local validation](scaffold-validation.md).


## Timing-only source alarm adoption, 2026-10-25

[ADR 0115](adr/0115-timing-only-source-alarm-adoption.md) implements [explicit master-timing copying](imported-alarm-adoption.md) into new unarmed personal definitions, using current authorized item text. It reuses existing storage without a migration and enforces source-read/adopt/create rights, actual parent revisions and trusted recipients. This supersedes earlier adoption-pending wording only for this bounded flow. Source text/UID/acknowledgement/snooze state stays inert; broader profiles, private exports and release gates remain separate. Full local batch validation passed; see the validation record for exact evidence.
