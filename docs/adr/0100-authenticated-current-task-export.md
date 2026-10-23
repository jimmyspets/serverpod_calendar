# ADR 0100: Authenticated current task export

Status: **scoped implementation of the confirmed separate source-read boundary; concrete selection/API mechanics under draft review**. Date: 2026-10-23.

## Context and decision

Task storage retains rich source participants, attachments and unarmed alarms that ordinary task responses do not disclose. The maintainer confirmed a separate host source-read permission in addition to export and ordinary detail permissions. Export must use current active data, never the private historical import baseline.

Profile `calendarTask.exportTasks` with immutable `CalendarTaskExportRequest` (calendar UUID, expected calendar revision, selection) and `CalendarTaskExportSelection` (task UUID, expected task revision). Select complete series from one actual calendar, explicitly and all-or-nothing. Require `exportTasks` on parent and members, `readTask` with every supported field group, and `readTaskSource` on each member, including native-only tasks. No redacted or implicit all-calendar output.

Host context contains actual parent/task snapshots and a complete immutable `CalendarTaskExportIntent` of current source components with independent versions, without historical baseline payloads. Resolve and authorize under the existing durable scope transaction, check revisions, serialize bounded complete output, then repeat every authority/context check before returning bytes. The declared external fresh-check revocation race remains; no stronger guarantee is inferred.

Generate source-free native tasks from current content/progress/protocol version and recorded original progress/components. Retain independently optional source properties and source annotations/metadata on imported tasks. Never translate native assignments into source ATTENDEE, fabricate history or arm alarms. Reject legacy occurrence records lacking protocol versions and any unsupported/over-limit state instead of inventing timestamps or flattening recurrence. Native data remains usable. Export is read-only.

Regenerate VCALENDAR presentation and exact full-horizon pinned VTIMEZONE definitions. Validate the aggregate pure VTODO profile and compare decoded current component semantics before returning deterministic bytes. Existing raw-component, per-series, metadata, alarm, syntax and recurrence budgets apply. No baseline persistence, HTTP feed, scheduling message, URI retrieval or alarm activation follows.

## Alternatives and consequences

Export permission alone would expose hidden source fields; omitting those fields would lose supported data. Both alternatives are rejected. Complete-field export is intentionally narrower than a future explicitly redacted profile. Rejecting missing legacy component versions avoids read-side data repair; an explicit adoption flow can follow separately.

## Acceptance

Verify each independent permission/disclosure group, actual parent/scope, stale/invalid selections, final revocation and immutable full-batch context, source/native round trips, independent versions and progress omissions, aggregate limits, deterministic read-only behavior and exclusion of private/native state. Add generated-client two-host and Flutter export journeys, then run the full batch checks. External-client interoperability remains separate evidence. No schema change is needed.
