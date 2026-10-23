# Native non-recurring tasks

The first durable task increment implements the confirmed choices in [ADR 0083](adr/0083-first-native-task-contract.md), with concrete mechanics under draft review in [ADR 0084](adr/0084-first-native-task-implementation.md). It adds module storage, authenticated generated-client APIs, replaceable host authorization and an example Flutter task screen. Recurrence, occurrence completion/history, VTODO interchange, scheduling and alarms remain separate work. Pure-core recurring task calculations do not establish durable recurring task support.

## Timing and content

Task content has optional summary, description, location and priority, plus explicit undated, DATE, UTC or named-zone timing. Undated tasks carry no milestones or zone. Other forms require a start or due value; start-only and due-only tasks are valid. A duration requires a start and cannot coexist with explicit due. Preserve nominal weeks/days versus elapsed clock units through the existing temporal core. DATE durations cannot contain clock units. The server validates chronology, zone coverage and the whole-second [1970, 2100) profile. **Task DUE and an effective due calculated from duration are ordinary values before 2100, not exclusive event endpoints.** No due date is inferred. Floating, fractional, mixed-profile and recurring input rejects explicitly.

Summary/location accept up to 4,096 Unicode code points; description accepts 16,384. Plain text preserves spacing and Unicode spelling. Optional priority is 0–9; absence stays absent. An omitted/empty summary is allowed; “Untitled task” is an example-only placeholder. Tasks and assignments never create occupied free/busy periods or reservations.

## Progress and assignments

Native creation starts NEEDS-ACTION, 0 percent, without completion time. Content, progress and assignment writes are separate commands:

| Action | Result |
| --- | --- |
| Set percentage | 0–99 on an unfinished, uncancelled task; 0 means NEEDS-ACTION, otherwise IN-PROCESS. |
| Complete | COMPLETED/100 with a whole-second server UTC completion time; repeating completion preserves that time. Reopen a cancelled task first. |
| Cancel | CANCELLED with the existing percentage, clearing the current completion time. |
| Reopen | NEEDS-ACTION/0, clearing the current completion time. |

These relationships are native application rules, not additional RFC 5545 constraints. The timestamp describes the **current completed state**; no completion history is implemented. Reopening a completed/cancelled task is required before percentage editing. A non-percentage action rejects a supplied percentage rather than ignoring it.

Assignments are opaque namespace/kind/external-ID references, sorted and deduplicated by exact values. Namespace/kind are 1–64 ASCII token characters, starting with a letter/digit and otherwise allowing letters/digits/underscore/dot/hyphen. External IDs are nonempty bounded plain text, at most 256 code points. Raw input is capped before deduplication at 128 and the configured `maxAssociations` budget (default 64). Hosts approve actual proposed references; they do not grant ownership, membership, ATTENDEE status or booking authority. The private demo host permits only its current signed-in user in `demo/user` references.

## API, authority and queries

The generated `calendarTask` endpoint requires login and exposes `create`, `getTask`, `list`, `update`, `changeProgress`, `changeAssignments` and `deleteTask`. Native mutations require expected task revisions, except creation. Missing/deleted/foreign-scope objects fail closed; actual parentage comes from stored identity. Active tasks block calendar deletion under the shared scope lock. Deletion scrubs content, progress, assignments, protocol values and audit payload, retaining only task UUID, calendar UUID, revision and deletion time. There is no restore/archive API.

Independent host operations are `listTasks`, `readTask`, `createTask`, `updateTask`, `changeTaskProgress`, `changeTaskAssignments` and `deleteTask`. Nonempty initial assignments require both creation and assignment permission. Preliminary and final write checks receive actual calendar/task identity, current state and immutable validated final content/progress/assignments/version; progress checks also receive the requested action. The host supplies rules without a required owner/role scheme. Existing [authorization consistency guarantees](authorization-consistency.md) apply, including the declared external-check race. Receipts appear only when every final operation permits disclosure; mutation authority does not establish read authority.

Eight independent disclosure groups cover summary, description, location, timing, priority, progress, assignments and protocol identity. A withheld group produces no value and is absent from `disclosedGroups`. `planTaskQuery` provides a bounded optional candidate-ID set; each candidate still requires actual read authority. Initial lists select one calendar, with no task-specific filters. Pages have authorized tasks and an opaque continuation, no totals. Cursors bind task query kind, calendar, groups, page size, actor/scope, policy revision, scope generation and expiry. Calendar/event/task continuations are not interchangeable. Any accepted write invalidates older scope-generation cursors. Scanning fails explicitly at `maxScannedTasks` (default 1,000), never treating a truncated scan as complete.

## Stored and generated models

Edit `.spy.yaml` sources under the calendar module and run the pinned [generation workflow](development.md); generated Dart/client/test tools are not hand maintained.

| Model | Fields and responsibility |
| --- | --- |
| `CalendarTaskRecord` | Server-only identity table: server UUID `id`, actual `calendarId`, API `revision`, optional `deletedAt`. |
| `CalendarTaskDataRecord` | Server-only active payload: `taskId`, denormalized validated `calendarId`, `protocolUid`, `uidDigest`, `protocolVersion`, `content`, `progress`, `assignees`, database `createdAt`/`updatedAt`. |
| `CalendarTaskContent` | Optional summary/description/location/priority, required timing; reserved optional recurrence rejects when supplied in this initial profile. |
| `CalendarTaskTiming` / `CalendarTaskTimeKind` | Undated/DATE/UTC/zoned meaning; optional start/due/duration/zone. Uses existing typed `CalendarEventCivil`/`CalendarEventDuration` transport primitives, with task-specific validation. |
| `CalendarTaskProgress` / `CalendarTaskStatus` | Current status, percentage, optional current completed UTC time. |
| `CalendarTaskAssignee` | Opaque namespace/kind/externalId, without user profile or implied authority. |
| `CalendarTaskProtocolVersion` | Optional sequence, required stamp, optional created/lastModified; native initialization uses known server times and sequence 0. No source history is invented. |
| `CalendarTaskCreateRequest` | Calendar UUID, content and initial assignees; no client-selected task/protocol identity or initial progress. |
| `CalendarTaskUpdateRequest` | Task UUID, expected revision and complete content; cannot change progress/assignments. |
| `CalendarTaskProgressRequest` / `CalendarTaskProgressAction` | Task UUID, expected revision, action and optional percentage. |
| `CalendarTaskAssignmentsRequest` | Task UUID, expected revision and complete proposed assignees. |
| `CalendarTaskReceipt` | Final-authorized task/calendar UUIDs, revision and deletion flag. |
| `CalendarTaskView` / `CalendarTaskFieldGroup` | Identity/revision, disclosed groups and optional projected content/progress/assignments/protocol values. |
| `CalendarTaskPage` | Authorized task views and optional next cursor, without total counts. |
| `CalendarCursorRecord` additions | Server-only nullable `taskCalendarId`/`taskFieldGroups`; other query kinds leave these absent. |

Host-only `CalendarTaskPolicySnapshot` freezes current task state; `CalendarTaskCandidatePlan` freezes optional query candidates. They are adapter classes, not public endpoint input models.

Task UUID and independently generated protocol UID remain stable through writes. UID digests provide bounded non-unique candidates; exact text comparisons determine conflicts within a calendar. Actual saved changes increment protocol sequence and use nondecreasing whole-second stamp/lastModified; accepted normalized no-op writes retain protocol state while advancing API revision, database audit time and scope generation. API revisions remain authoritative within one second. Parent calendar protocol time does not change. These checkpoints do not claim VTODO import/export or scheduling support.

## Validation

Focused `task_values_test.dart` covers typed timing, duration/DUE constraints, fractions/zones, progress transitions, assignment normalization and protocol checkpoints. Focused task cases in the example `calendar_test.dart` exercise independent/final authorization, immutable context, stale writes, disclosure, cursor boundaries, scan limits, malformed stored parentage, rollback, dependency checks, scrubbing and unchanged busy time. The additive generated migration is exercised on fresh synthetic storage and populated upgrades without inventing tasks/history. Two-host generated-client checks cover assignment rules, progress, continuations, competing revisions and parent-deletion races; the Flutter journey covers creation, editing, assignments, percentage/completion/cancellation/reopening and stale-draft recovery. Batch results are recorded after the checks complete.

Batch validation on 2026-10-23: `./tool/check.ps1` passed in full, including locked generation stability, formatting/analysis, core 471 VM + 471 Chrome, wire 217 VM + 217 Chrome, module 123 VM + 17 Chrome, 3 widget tests, 198 database/policy tests, populated upgrades, two independent JWT hosts/generated clients, the connected Flutter task journey and release Web build/Wasm compilation dry run. Focused task values (9) and database/policy cases (15) also passed separately. This does not establish recurring-task, VTODO, feed or external calendar-client support.
