# Native personal alarm definitions

Status: scoped definition/storage/editor implementation under [ADR 0111](adr/0111-native-personal-alarm-definitions.md). Confirmed product choices are separate from concrete mechanics under draft review. Commands/results belong in [validation evidence](scaffold-validation.md). Durable planning, arming, execution, acknowledgement, snooze and notification delivery remain unimplemented.

## Private definitions

The host resolves the authenticated current recipient through `CalendarHostPolicy.resolveAlarmRecipient`, returning an opaque namespace/key. Requests cannot select a recipient; source ORGANIZER/ATTENDEE or alarm UIDs never identify one. Hosts can replace this mapping without using a fixed user/owner/role model. Final writes re-resolve recipient and actor/scope context under the declared coordinated or external fresh-check guarantee. External checks retain the documented after-check revocation race.

`CalendarAlarmEndpoint` offers parent-scoped list/create/update/delete. Each request names one actual event or task; the server loads its real calendar and scope before policy checks. Separate `readPersonalAlarms`, `createPersonalAlarm`, `updatePersonalAlarm` and `deletePersonalAlarm` checks include trusted recipient, actual parent/calendar, current alarm/settings and validated proposed settings. Permission to read/edit an event or read its imported source alarms does not automatically grant these operations. Hosts must decide whether the alarm anchor-compatibility projection is disclosable.

One private `serverpod_calendar_alarm` row stores UUID, scope, calendar, typed event/task parent reference, recipient namespace/key, revision, immutable definition and database audit times. The typed reference represents exactly one parent; event/task membership is enforced by the transactional service, rather than a polymorphic database foreign key. The calendar has a database foreign key. UUIDs are opaque references, never authorization. No provider/device tokens or host user profiles are stored.

A shared scope lock serializes private limits, stale revisions and parent-deletion races across hosts. Each recipient/item has at most 16 definitions. The list is complete and bounded, has no totals or continuation, and fails if any required authorization is unavailable/denied; it never queries another recipient through a client identity. Create/update return a nullable view honoring host mutation-receipt disclosure. Independently authorized list can retrieve current state. Alarm revisions advance on accepted updates; item content/API/protocol versions and import baselines stay unchanged. Private writes do not advance public scope generation, avoiding unnecessary invalidation from private activity.

## Timing settings and limitations

A definition contains exactly one absolute whole-second UTC instant or signed relative duration plus START/END anchor. Relative triggers apply to each original recurring occurrence. Absolute UTC has one anchor per item/definition, followed by any configured repeats. Per-occurrence personal overrides are separate future work. Absolute triggers can be defined on undated tasks. Relative START needs a start; END needs explicit event end/task due or start/duration. Implicit all-day event ends and timed points are insufficient END anchors.

DATE-relative settings require an explicit exact named IANA zone, with midnight in that zone as the selected future planning anchor. The example prefills a zone but the server never infers one. A relative definition may retain that explicit DATE zone while the parent has timed values; it is unused until needed. Absolute definitions have no relative anchor/zone. Pinned IANA/profile limits and RFC gap/fold rules remain unchanged. Future calculation must apply weeks/days in calendar fields before elapsed clock units; defining settings does not yet calculate a firing instant.

Duration units and sign are preserved, with 366-day equivalent offset/interval/repeat-span limits, 0–100 additional repeats, and a required paired positive interval. Nonzero fractions, mixed week/other-unit durations, invalid exact zones, unsupported trigger shapes and exhausted limits reject rather than normalize away settings. Ordinary calendar dates remain 1970–2099; calculation padding does not extend storage.

Creating/replacing settings requires a compatible current master anchor. Later shared edits can remove an end/start or switch to DATE without a stored DATE zone: retain the private definition and report `anchorCompatible=false` (needs attention). This diagnostic describes the current master only; it is not readiness for delivery and does not promise that every effective occurrence is valid. Future planning must check each effective occurrence, timezone coverage, calculated instant, recipient access, lifecycle and expiry. Private definitions cannot block another user's authorized shared edit. Cancellation/progress retains configuration; worker suppression policy follows separately.

Authorized parent deletion removes every recipient's definition rows atomically with event/task content, without an extra private-alarm permission or existence disclosure. Deleting a definition removes the row completely, retaining no marker/archive/restore state. A later request against a missing/deleted/wrong-parent/foreign-recipient alarm is denied. Development database resets are not required; generated migrations add an empty private table and retain existing data.

## Example and boundaries

Event/task lists open a Personal alarms screen for the current host recipient. Editors cover relative units/sign/anchor, optional repeat settings, absolute UTC and DATE zone. They explicitly say **unarmed** and provide no activation/acknowledgement/snooze controls. Notification text will derive later from freshly authorized parent content; custom text remains separate.

Native definitions are independent of [unarmed event source alarms](event-source-alarms.md) and retained VTODO source alarms. Import creates none, export includes none, and this API does not adopt source data. No firing rows, historical actions, notification intent, stream, provider acceptance, display or mobile background delivery is implied. Planner/outbox/action/notification contracts and multi-instance crash/retry evidence remain required before the first release.


## Confirmed next execution choices — not implemented

The maintainer selected explicit authorized arm/disarm, a rolling 30-day bounded planning horizon with refill, and host-configurable late eligibility with a 15-minute example default. Native creation remains unarmed; imported-source adoption remains separate.

Task alarms will suppress delivery for any explicit completion/cancellation signal: COMPLETED/CANCELLED status, a COMPLETED instant or 100 percent complete. This does not rewrite independent imported source fields. Acknowledge/dismiss/snooze will suppress remaining automatic repeats for that original occurrence only; snooze will acknowledge the original and create one replacement firing. Recovery will select the latest eligible overdue firing per definition, recording other eligible firings as suppressed and older ones as expired. These are confirmed product choices for subsequent implementation, not current execution behavior.

Persistent work/lease mechanics, density/resource bounds, background recipient authorization, action-state handling across replanning, snooze bounds and notification handoff/retry still need concrete review and tests before arming/delivery. They must retain the shared-storage/two-instance recovery requirements.


## Host upgrade

This is an unpublished breaking host-adapter change: implement `resolveAlarmRecipient(Session, CalendarHostContext, Transaction, CalendarAuthorizationPhase)` and explicitly decide the four personal-alarm operations. The [demo adapter](../example/calendar_example/calendar_example_server/lib/src/calendar_policy.dart) maps its trusted private demo principal to one namespaced recipient; production hosts supply their own mapping and declared coordination. Apply the generated additive module/example migrations through the normal pinned workflow; a fresh development database is not required. Never derive a recipient from source addresses or client request fields.
