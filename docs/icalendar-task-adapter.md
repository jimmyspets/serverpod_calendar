# Standalone VTODO master adapter

The pure `serverpod_calendar_icalendar` package now parses, validates and reserializes a bounded standalone VTODO **master** profile under [ADR 0088](adr/0088-vtodo-wire-master-implementation.md), following the confirmed source-progress choice in [ADR 0087](adr/0087-vtodo-wire-master-contract.md). It does not import into module storage, change native task progress, assign users, publish HTTP feeds, send scheduling messages or activate alarms. Native [recurring task progress/history](recurring-tasks.md) is a separate service.

## Supported profile

Require one strict VCALENDAR with VERSION 2.0, nonempty PRODID, optional Gregorian CALSCALE and at least one VTODO. UID and UTC DTSTAMP are required once per master. Exact duplicate UIDs in the file reject. Source UID is text, independent of native UUID/authority. Multiple bounded masters and necessary VTIMEZONE components are supported; mixed component calendars reject in this adapter.

| Properties | Supported meaning |
| --- | --- |
| DTSTART, DUE, DURATION | Undated, start-only or due-only tasks; DATE, UTC or named-zone milestones. Positive duration requires start and excludes DUE. Preserve explicit due versus duration units; no inferred deadline or occupied interval. |
| SUMMARY, DESCRIPTION, LOCATION | Optional decoded text with scoped LANGUAGE/ALTREP; preserve absence, spelling and annotations. Links are never fetched. Limits are 4,096/16,384/4,096 code points respectively. |
| PRIORITY | Optional source integer 0–9; preserve explicit zero versus absence. |
| STATUS | Optional NEEDS-ACTION, IN-PROCESS, COMPLETED or CANCELLED. |
| PERCENT-COMPLETE | Optional source integer 0–100, independent of status/completion-property presence. |
| COMPLETED | Optional explicit whole-second UTC completion value, independent of status/percentage-property presence. |
| CREATED, LAST-MODIFIED, SEQUENCE | Optional source checkpoints/omissions; no freshness or authority inference and no invented timestamps. |
| RRULE, RDATE, EXDATE | Bounded recurring masters requiring an explicit start, using the existing typed recurrence profile and start-only inclusion/exclusion values. |
| VTIMEZONE | Exact case-sensitive names/aliases and full supported-horizon agreement with the pinned IANA data, reusing existing zone validation. |

STATUS, PERCENT-COMPLETE and COMPLETED stay **independently optional**. The adapter does not fill in 100 percent, a current completion time or NEEDS-ACTION, and does not apply native completion/reopen constraints to source fields. It validates the fields individually without reconciling them into native progress or claiming a conflicting source combination is consistent. No historical transition is synthesized from COMPLETED. The database import mapping remains a separate design. See [RFC 5545 §3.6.2](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.2), [§3.8.1.8](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.8) and [§3.8.2.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.2.1).

Ordinary milestone/checkpoint values use whole seconds in [1970-01-01,2100-01-01). **DUE and effective due cannot use the exclusive event-end exception at 2100.** Floating times, mixed DATE/timed or differing named-zone profiles, invalid chronology, nonpositive durations and out-of-profile effective due reject. This bounded profile rejects some legal RFC combinations; these are application limits, not new RFC prohibitions. Nonzero/zero lexical fractions in iCalendar DATE-TIME are rejected by its strict whole-second grammar; native DateTime values with zero fractional fields are a separate input form.

Recurrence preserves explicit WKST and its rule-specific week grouping/numbers; native ISO presentation remains separate. Canonical core sets sort/deduplicate selections while source spelling/grouping remains in the retained syntax. Earlier RDATE additions are retained without changing rule COUNT; EXDATE wins. Generated nonexistent named-zone times follow the existing skip policy, with explicit values using the selected RFC gap/fold handling. Due projection uses task milestones, preserving nominal duration versus elapsed explicit due. Undated source tasks have no invented daily recurrence anchor.

## Rejection and boundaries

Reject RECURRENCE-ID/occurrence components, PERIOD-valued additions, VALARM, METHOD, organizer/attendee/scheduling data, categories/comments/contact, URL/CLASS, private extensions and other unprofiled properties/parameters. Those requirements remain tracked for subsequent increments. Unsupported input rejects the entire file; no successful partial task list, silent property removal, recurrence flattening, network retrieval or delivery follows. VTODO scheduling remains deferred under [ADR 0011](adr/0011-defer-vtodo-scheduling.md).

Reuse strict UTF-8/CRLF/BOM handling and existing syntax/component/temporal diagnostics. Diagnostics omit source values. Validate manually constructed syntax trees through the same profile boundary as parsed bytes. Definitions must match the full supported IANA horizon even if a narrower zone would be correct for a task's immediate dates; pre-1970 observance seeds only establish in-horizon rules. See [zone validation](icalendar-event-adapter.md) and [timezone maintenance](timezone-data.md).

## Pure model/API catalog

Import `package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart`:

| Type/API | Fields/responsibility |
| --- | --- |
| `IcalendarTaskCalendar` | Immutable source syntax, producer ID, source-ordered tasks and validated time-zone map. |
| `IcalendarTask` | Source component, text UID, required stamp, optional created/lastModified/sequence, DATE or timed core task timing (both absent for undated), optional recurrence/text/priority/status/percentage/completed. |
| `IcalendarTaskText` | Decoded value plus optional language and alternative URI. |
| `IcalendarTaskStatus` | Source status token projection without a default/native transition. |
| `IcalendarTaskRecurrence` | Immutable DATE or timed recurrence set; no PERIOD or occurrence override mapping. |
| `parseIcalendarTaskCalendar` | Validate strict bytes and the whole bounded calendar before returning semantic tasks. |
| `validateIcalendarTaskCalendar` | Apply the same profile to an immutable manually constructed syntax tree. |
| `serializeIcalendarTaskCalendar` | Deterministic reserialization of validated source syntax, including FREQ-first RRULE output, quoting and UTF-8 folding. |

Typed core sets/timing are semantic projections; retained source trees preserve optional VALUE annotations, numeric spelling, repeated date-property grouping, text parameters and envelope/zone details. Serialization is source-preserving semantics, not original-byte storage or an authorized current-state module export. It does not regenerate a native calendar or serialize private transition history. No Serverpod generated models, tables or migrations change in this increment.

Defaults add `maxTasks=128` and `maxTaskMetadataCodePoints=65536` to the existing trusted component limits. Charge decoded UID/text/annotations across all tasks before returning results. Existing syntax, zone, observance/onset, per-rule/list and shared calendar recurrence-work/explicit-date limits remain active across the file. Invalid trusted limits reject; no budget exhaustion becomes a truncated successful file.

## Validation

The focused 17 tests include 40 independently optional progress combinations across five status-presence cases, sparse milestones, annotations/checkpoints, recurrence/WKST, DST, full-horizon zones, unsupported data, duplicates/parameters, strict syntax/manual trees, immutability and aggregate budgets. Full package/core/module batch results are recorded after completion. This is no evidence of native VTODO import/export, feed publication, external-client compatibility or task scheduling interoperability.

Batch validation on 2026-10-23: focused VTODO tests 17 passed; full wire package 234 VM + 234 Chrome, temporal core 471 VM + 471 Chrome, and module unit regressions 129 VM + 17 Chrome passed. Changed Dart formatting, `dart analyze --fatal-infos`, relative links/ADR numbering, diff review and local credential scan passed. Connected Serverpod and Dart MCP hot reloads succeeded. No models/endpoints/tables changed, so database/two-host/Flutter journey checks were not repeated for this pure adapter increment; their latest native-task evidence is in the preceding batch. Full repository checks remain required before marking the draft stack ready.
