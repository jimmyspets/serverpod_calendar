# ADR 0088: Bounded VTODO wire master implementation

Status: **scoped implementation of the confirmed ADR 0087 source-preservation choice; concrete mechanics under draft review**. Date: 2026-10-23.

Add immutable `IcalendarTaskCalendar`, `IcalendarTask`, `IcalendarTaskRecurrence`, annotated task text and source task-status projections to the pure adapter package. A complete strict VCALENDAR contains bounded standalone masters and validated VTIMEZONE definitions; exact duplicate source UIDs reject. Preserve undated/DATE/UTC/zoned milestone and explicit DUE/duration forms, independently optional STATUS/PERCENT-COMPLETE/COMPLETED and source checkpoints/annotations. Do not invoke native progress validation or synthesize history.

Reuse strict temporal/component helpers and recurrence generation, preserving source syntax with deterministic FREQ-first reserialization. Require explicit DTSTART for recurrence and reject PERIOD additions, occurrence components, METHOD/scheduling, alarms, participant authority and unprofiled metadata. Validate optional due as ordinary, not an exclusive event endpoint. Add `maxTasks` and aggregate task metadata ceilings to existing trusted component limits; retain shared zone/recurrence budgets across the file.

Test semantic/source round trips, independent progress combinations, annotated text, whole-second/profile/chronology rules, date/due/duration and recurring masters, WKST, exact full-horizon zone validation, malformed grammar, unsupported inputs, immutable results and aggregate limits on VM/Chrome. No database schema, authenticated import/export, assignments, feed routes or scheduling behavior changes. Source UID/progress never grants authority.
