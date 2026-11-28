# Standalone VTODO adapter

The pure `serverpod_calendar_icalendar` package now parses, validates and reserializes a bounded standalone VTODO master profile under [ADR 0088](adr/0088-vtodo-wire-master-implementation.md), extended with progress-only occurrence components under [ADR 0090](adr/0090-vtodo-occurrence-component-implementation.md) and the confirmed [ADR 0089 contract](adr/0089-vtodo-occurrence-component-contract.md), following the confirmed source-progress choice in [ADR 0087](adr/0087-vtodo-wire-master-contract.md). It does not import into module storage, change native task progress, assign users, publish HTTP feeds, send scheduling messages or activate alarms. Native [recurring task progress/history](recurring-tasks.md) is a separate service.

## Supported profile

Require one strict VCALENDAR with VERSION 2.0, nonempty PRODID, optional Gregorian CALSCALE and at least one VTODO. UID and UTC DTSTAMP are required once per component. Duplicate masters for one exact UID reject; occurrence components share their master's UID and require a distinct exact original RECURRENCE-ID. Source UID is text, independent of native UUID/authority. Multiple bounded masters and necessary VTIMEZONE components are supported; mixed component calendars reject in this adapter.

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

## Progress-only occurrence components

Each override requires its exact matching master in the same file, even if it appears before that master. RECURRENCE-ID identifies an original member of the master's recurrence set, never a completion timestamp. Excluded, absent, duplicate or differently profiled originals reject the whole file. Exact named-zone identity matters even when another representation has the same instant. Generated gap times are absent unless separately included by the supported explicit-date rules. See [RFC 5545 §3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4).

Omitted timing, text and priority inherit only in the linked projection. Raw properties retain their absence for reserialization. Explicit repetitions must match the projected start/deadline and text annotations; explicit priority 0 may match an absent master priority's undefined meaning. Equivalent supported DUE/DURATION forms retain their source form when the actual projected deadline agrees. A DURATION still requires DTSTART in that source component. Compare timed deadlines as instants, including DST folds; a repeated clock label that selects the wrong fold rejects.

STATUS, PERCENT-COMPLETE and COMPLETED may differ independently and remain independently optional on each component. Checkpoints are independent too. No effective native progress, 100-percent default, retrospective history or assignment is inferred. A consumer reads raw source progress from `linked.component`; the adapter intentionally supplies no reconciled progress getter. Explicit timing/content changes, recurrence generators on overrides and all RANGE parameters remain unsupported.

Validate retained original targets with one aggregate generation per master and the shared file-wide recurrence work budget. No per-override fresh full budget or partial success is allowed. Serialization retains original component order and source presence; `tasks` contains masters only and `series` links the occurrence components.

## Rejection and boundaries

Reject detached occurrence components, occurrence timing/content differences, RANGE, PERIOD-valued additions, VALARM, METHOD, organizer/attendee/scheduling data, categories/comments/contact, URL/CLASS, private extensions and other unprofiled properties/parameters. Those requirements remain tracked for subsequent increments. Unsupported input rejects the entire file; no successful partial task list, silent property removal, recurrence flattening, network retrieval or delivery follows. VTODO scheduling remains deferred under [ADR 0011](adr/0011-defer-vtodo-scheduling.md).

Reuse strict UTF-8/CRLF/BOM handling and existing syntax/component/temporal diagnostics. Diagnostics omit source values. Validate manually constructed syntax trees through the same profile boundary as parsed bytes. Definitions must match the full supported IANA horizon even if a narrower zone would be correct for a task's immediate dates; pre-1970 observance seeds only establish in-horizon rules. See [zone validation](icalendar-event-adapter.md) and [timezone maintenance](timezone-data.md).

## Pure model/API catalog

Import `package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart`:

| Type/API | Fields/responsibility |
| --- | --- |
| `IcalendarTaskCalendar` | Immutable source syntax, producer ID, source-ordered master `tasks`, linked `series` and validated time-zone map. |
| `IcalendarTask` | Source component, text UID, required stamp, optional created/lastModified/sequence, DATE or timed core task timing (both absent for undated), optional recurrence/text/priority/status/percentage/completed, original DATE/timed identity and `isOverride`. Override raw timing may be absent; that does not mean an undated master. |
| `IcalendarTaskSeries` | Master and immutable source-ordered linked overrides. |
| `IcalendarTaskOccurrenceComponent` | Raw `component` and master, exact original identity, resolved DATE timing or timed projection, inherited text/priority. Optional source progress stays on the raw component. |
| `IcalendarTaskText` | Decoded value plus optional language and alternative URI. |
| `IcalendarTaskStatus` | Source status token projection without a default/native transition. |
| `IcalendarTaskRecurrence` | Immutable DATE or timed recurrence set; no PERIOD additions; linked progress components are separate from this set. |
| `parseIcalendarTaskCalendar` | Validate strict bytes and the whole bounded calendar before returning semantic tasks. |
| `validateIcalendarTaskCalendar` | Apply the same profile to an immutable manually constructed syntax tree. |
| `serializeIcalendarTaskCalendar` | Deterministic reserialization of validated source syntax, including FREQ-first RRULE output, quoting and UTF-8 folding. |

Typed core sets/timing are semantic projections; retained source trees preserve optional VALUE annotations, numeric spelling, repeated date-property grouping, text parameters and envelope/zone details. Serialization is source-preserving semantics, not original-byte storage or an authorized current-state module export. It does not regenerate a native calendar or serialize private transition history. No Serverpod generated models, tables or migrations change in this increment.

Defaults include `maxTasks=128` (all VTODO components), `maxOverridesPerTask=64` and `maxTaskMetadataCodePoints=65536` to the existing trusted component limits. Charge decoded UID/text/annotations across all tasks before returning results. Existing syntax, zone, observance/onset, per-rule/list and shared calendar recurrence-work/explicit-date limits remain active across the file. Invalid trusted limits reject; no budget exhaustion becomes a truncated successful file.

## Validation

The focused 17 tests include 40 independently optional progress combinations across five status-presence cases, sparse milestones, annotations/checkpoints, recurrence/WKST, DST, full-horizon zones, unsupported data, duplicates/parameters, strict syntax/manual trees, immutability and aggregate budgets. Full package/core/module batch results are recorded after completion. This is no evidence of native VTODO import/export, feed publication, external-client compatibility or task scheduling interoperability.

Batch validation on 2026-10-23: focused VTODO tests 17 passed; full wire package 234 VM + 234 Chrome, temporal core 471 VM + 471 Chrome, and module unit regressions 129 VM + 17 Chrome passed. Changed Dart formatting, `dart analyze --fatal-infos`, relative links/ADR numbering, diff review and local credential scan passed. Connected Serverpod and Dart MCP hot reloads succeeded. No models/endpoints/tables changed, so database/two-host/Flutter journey checks were not repeated for this pure adapter increment; their latest native-task evidence is in the preceding batch. Full repository checks remain required before marking the draft stack ready.

Occurrence batch validation on 2026-10-23: 35 focused master/occurrence tests passed; complete wire 252 VM + 252 Chrome, core 471 VM + 471 Chrome and module units 129 VM + 17 Chrome passed. Formatting, workspace fatal-info analysis, documentation links/consecutive ADRs and diff/credential checks passed. Serverpod MCP reload succeeded; Flutter logs reported reload timeouts despite the Dart tool success response, so no new connected Flutter validation is claimed. No tables, endpoints, native task/history state or Flutter screens change in this batch; database, two-host and Flutter/release checks are not repeated. Full repository checks remain required before marking the draft stack ready.
