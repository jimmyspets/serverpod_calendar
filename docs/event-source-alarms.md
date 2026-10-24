# Unarmed event source alarms

Status: scoped implementation of the confirmed task-style DISPLAY/sibling-snooze profile under [ADR 0110](adr/0110-unarmed-event-source-alarms.md). Concrete mechanics remain draft review material. See [validation evidence](scaffold-validation.md) for commands and results.

VEVENT VALARM data is read-only source metadata. Import never creates a native personal alarm, resolves a recipient, arms a trigger, records an authorized acknowledgement or schedules delivery. UID, ACKNOWLEDGED and SNOOZE remain unverified source claims. They grant no access or host identity. Native definitions, consent/adoption, actions, durable planning, notification execution and connected-client delivery remain separate requirements.

## Supported bounded profile

DISPLAY requires DESCRIPTION, preserving optional LANGUAGE/ALTREP without fetching links. Triggers preserve signed duration units and optional RELATED=START/END, or an absolute whole-second UTC instant. Omitted RELATED has effective START while retaining source absence. END requires explicit DTEND or DTSTART/DURATION; the implicit end of a date-only event and a timed point are insufficient. Absolute triggers and ACKNOWLEDGED retain the ordinary supported date range. Source preservation selects no firing instant or date-only recipient zone.

REPEAT and positive DURATION must appear together; REPEAT counts additional repetitions. Application bounds are 100 additional repeats, 366-day equivalent duration/repeat span, 16 alarms per event component and 256 raw alarms across one file/stored series. Description, annotations, UID and snooze target share the existing 65,536-code-point event metadata budget. These are product limits, not RFC maxima. Unsupported actions, parameters, nested children, fractional/non-UTC instants and exhausted budgets reject explicitly without partial imports.

A sibling snooze needs its own UID, an absolute UTC trigger and one SNOOZE link to an acknowledged original in the same raw VEVENT. Detached/self links, chains and repeating snoozes reject. Source acknowledgement never implies a native user action. Full ordered own lists must match master definitions, including acknowledgement and snooze state; omitted own lists inherit only through the linked `alarmsFor` projection. Raw omission remains absent in output, including at future timing anchors. Different occurrence alarm state remains unsupported.

The parser is shared with the existing task profile. AVAILABLE/VAVAILABILITY still reject alarms despite sharing event timing helpers. Serialization emits properties before VALARM children and preserves supported alarm semantics, not original file formatting.

## Storage, edits and privacy

Immutable server-only `CalendarEventSourceAlarm` and signed `CalendarEventSourceDuration` DTOs extend nullable event metadata JSON. Empty lists normalize to absence. No new table columns or migration are needed; older event-source-v2 baselines remain valid without an alarms key. Existing private baselines remain private and are scrubbed with active content on deletion.

Native edits retain imported alarm definitions. A retained END trigger makes removal of the explicit master or occurrence end/duration invalid; such edits reject atomically. This protects source semantics and is distinct from the separately designed private native-alarm policy. Metadata-only occurrence nodes retain membership/orphan protection and timing-transfer behavior while staying hidden from ordinary details, previews and component-version lists. Unrepresentable inherited timing still rejects export.

Independent `readEventSource` authority protects full source export and replacement, including final checks and true no-op retries. Immutable host intents include current/proposed alarms, never historical baselines. Source replacements compare full supported alarm state using existing revision, clean-baseline, local-conflict and SEQUENCE rules. Ordinary event responses do not disclose alarm descriptions, UIDs, acknowledgement or hidden source nodes.

The example imports/exports synthetic unarmed definitions and sibling snoozes without an activation control. Focused tests cover trigger forms, explicit anchors, shared limits, raw/effective inheritance, immutable storage, source replacement/no-op, privacy, late invalid-file atomicity and native edit rejection. Broader two-host/Flutter fixtures retain source alarms through export and timing transfers. This is not native alarm runtime, scheduling or external calendar-client compatibility.

See [RFC 5545 VALARM](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.6), [TRIGGER](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.6.3), [RFC 9074](https://www.rfc-editor.org/rfc/rfc9074.html), [task DISPLAY profile](adr/0094-vtodo-display-alarm-source-profile.md), [task snooze profile](adr/0095-vtodo-snooze-source-profile.md), [event source metadata](event-source-metadata.md) and [event export](event-export.md).
