# ADR 0008: Serverpod capabilities, Flutter clients, tasks and availability search

Status: **Proposed**. Date: 2026-10-19. The maintainer clarified that the main product is a calendar module for Serverpod projects, including free/busy, scheduling and tasks; Flutter clients provide most of the GUI. External subscription clients only need a subset. The concrete contracts below await review.

## Primary interface and projections

Expose the full authorized calendar, task, scheduling and availability services through Serverpod endpoints and generated Dart clients. Host Flutter apps use those services for calendar/task screens, participant/resource selection and availability search; enforce all access and temporal rules on the server. The module's data model and capabilities are not restricted to what Apple/iOS, Google Calendar or Outlook can display.

Keep the canonical model, general iCalendar interchange, scheduling messages and read-only subscription feed projections distinct. External feed acceptance covers only the declared feed subset. Proposed initial projection is published VEVENT data with necessary time-zone/recurrence definitions and approved calendar descriptions; task data, availability rules, internal permissions and workflow state need not be included. Record the profile and every intentional output exclusion. This is deliberate publication policy, not permission for import to discard unsupported data or for exports to silently change event meaning. An unrepresentable published event must fail explicitly unless a reviewed semantic transformation exists.

iTIP/iMIP remain required module interoperability capabilities. Validate their supported method/profile behavior independently of the feed-client matrix. Scheduling mail client/account targets are selected separately; all three subscription clients are not automatically release gates for full scheduling, task or availability UI behavior.

## Task model and services

Provide durable, authorized task CRUD, assignment through host-resolved user/group references, list/filter queries and lifecycle updates for needs-action/in-progress/completed/cancelled states. Proposed fields include task UID, calendar, title/description, optional typed start/due, priority, completion timestamp/percentage, external assignees and application revision. Recurring tasks are included under [ADR 0017](0017-profile-review-clarifications.md). Define constraints for per-occurrence completion, optional dates and recurrence/series behavior before schema approval; an undated task is valid and must not be forced into an event interval.

Use [RFC 5545 VTODO](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.2) as the task interchange baseline. Approve exact properties/parameters and query semantics separately from VEVENT. Native Flutter task management and supported VTODO import/export are first-release work; external feed task rendering is not required. The maintainer subsequently deferred all VTODO iTIP methods and inbound/outbound iMIP task scheduling mail under [ADR 0011](0011-defer-vtodo-scheduling.md). Native assignments, standalone VTODO import/export and task alarms/push remain in scope; do not route task scheduling through event handlers or reinterpret scheduling input as ordinary import.

A task's start/due dates do not automatically consume availability. Proposed baseline blocks time only through an explicitly linked scheduled event/time reservation using the normal booking semantics. Define whether task completion/cancellation changes such a block before enabling automation. Preserve independent task and event identities and revisions. Task relationships must not bypass host authorization; selected RFC 9253 relationships are metadata under ADR 0014; exact graph and projection constraints remain under review.

## Availability search contract

Subsequent clarification in [ADR 0012](0012-calendar-availability-policy.md) requires separate calendar results and per-calendar no-rule fallback. The maintainer subsequently confirmed an optional derived person/resource summary using host-selected contributing calendars, where any blocking booking contributes to busy time. Separate calendar results remain available under their own permissions. The maintainer then confirmed intersection: each contributor independently applies its RFC rules, no-rule fallback and bookings; the summary is free only where every contributor is free with complete coverage. Common-free search uses these subject results. Calendar priorities and permissive fallbacks cannot override another contributor.

Provide a Serverpod query accepting an explicit list of namespaced subject references (people, rooms, venues or equipment), a required bounded start/end window, and optional minimum free duration. Return each requested target with complete/unknown coverage and free/busy/unavailable intervals over that window. Do not treat a list as implicitly meaning everyone must be free: expose explicit per-target candidate results and an optional common-free calculation for all requested targets.

Per-target search supports choosing any available room/person from the supplied list. Common-free search intersects known free intervals for a meeting requiring all listed participants/resources. Resolve each target's complete contributing calendars through the host; apply RFC 7953 rules, recurrence, overrides, time zones and privacy. An unresolved/denied/over-limit target is not free; a common-free result requires complete coverage for every requested target. Deduplicate repeated references, bound targets/window/expansion/result counts, and expose truncation/errors without silently dropping requested targets. A free/busy-only caller receives no event details.

Return stable subject references, interval boundaries, coverage and calculation snapshot metadata so Flutter can render a comparison grid, available-resource list or suggested common slots. Instants are unambiguous; any local input/display zone is explicit, never the server's implicit local zone. The result is a snapshot, not an exclusive reservation.

Examples (conceptual, not implemented APIs):

- Search rooms A/B/C from 08:00 to 17:00 Europe/Stockholm with a 30-minute minimum; return each room's free intervals so the Flutter app can select an available room.
- Search three people plus one room over the same window in common-free mode with a 60-minute minimum; return intervals where all four have complete coverage and are free.

First-release alarms and an iOS/Android push integration were subsequently required by the maintainer. [ADR 0009](0009-alarms-and-notification-boundaries.md) proposes separate calendar timing/state, generic notification delivery and Flutter platform integration; task completion invalidates affected pending reminders according to the task occurrence lifecycle, which must be specified for recurring tasks.

## Acceptance conditions

Approve task schema/lifecycle, assignment, recurrence/interchange profile and optional scheduling/blocking policy. Exercise Flutter through the generated client for tasks, scheduling and both availability-search modes. Test task ownership/assignment changes, stale writes, completion/due validation and restart; search mixed/duplicate targets, all busy, one unknown, inaccessible calendars, minimum durations, adjacent boundaries, DST, recurring exceptions, opening hours and result limits. Keep protocol fixtures, native app behavior and subset feed interoperability evidence separate. See FR-25–FR-27 and roadmap task/availability work.
