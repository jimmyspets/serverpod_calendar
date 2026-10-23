# Durable recurring tasks and occurrence progress

> Progress follow-up: [source-preserving native progress](task-source-progress.md) under ADR 0096 supersedes earlier mandatory status/percentage and neutral-recurring-master read rules. Native create/reopen defaults and command separation remain; imported source-shaped fields stay independently optional, and unrecorded occurrences use the master value. Full task source import remains separate.
This increment implements the confirmed choices in [ADR 0085](adr/0085-recurring-task-progress-and-history.md), with concrete schema/API/query mechanics under draft review in [ADR 0086](adr/0086-durable-task-recurrence-implementation.md). It extends [native non-recurring tasks](native-tasks.md). VTODO parsing/export, timing/content exceptions, all-series lifecycle changes, scheduling and alarms remain separate. Core recurrence calculations alone never establish wire/client compatibility.

## Recurrence and previews

Task content/view now carries canonical rule and start-only inclusion/exclusion values, disclosed with timing. An explicit DTSTART is required. Undated and due-only tasks remain valid **non-recurring** forms; their due date is never invented as a recurrence anchor. Reuse the existing DATE/UTC/named-zone recurrence rules, sorted duplicate-free filters, strict DTSTART match, exact zone/profile, inclusion union and exclusion precedence. Earlier inclusions remain additions without changing rule COUNT. PERIOD additions are not task due overrides and reject in this profile.

`calendarTask.previewOccurrences` takes task UUID, expected API revision and a bounded half-open window. DATE tasks use DATE bounds; UTC/zoned tasks use UTC bounds. It returns starts within the window, their exact original typed identities, optional projected due and independent current progress. This is **start-based**, not an overlap/deadline search or booking query. Preserve nominal duration units; explicit timed due propagates elapsed length. For example, a nominal day over Stockholm's spring change can be 23 elapsed hours, while a stored explicit elapsed due offset remains that same elapsed length for later occurrences. Due/effective due stays ordinary before 2100.

Use at most 366 query days, 500 results, 200,000 candidate work and 10,000 rule occurrences. Explicit recurrence-date and rule-part limits are inherited from native recurrence. Incomplete work fails explicitly, never returning a truncated successful preview. Ordinary query bounds remain within the [1970,2100) profile, with only explicit exclusive query endpoints at 2100 midnight. UTC calculation padding is not additional query/storage permission.

Calendar presentation uses ISO 8601 Monday-first week numbering; an explicit recurrence WKST remains authoritative for its own grouping and rule week numbers. See [week conventions](week-conventions.md). The example's basic editor changes frequency, interval, COUNT and WKST while retaining existing filters, UNTIL and inclusion/exclusion dates. Advanced rule editing is available through the typed API; the basic editor does not silently discard those values.

## Independent progress and history

Native series creation starts NEEDS-ACTION/0 without completion time. Under ADR 0096, stored source-shaped master progress may be independently optional/unusual and supplies the complete default for originals with no own progress row; explicit rows replace that value without field merging. Whole-task progress commands reject for a recurring series. `changeOccurrenceProgress` instead takes expected task revision and an exact original typed start. Original identity never follows a deadline, completion timestamp or display position. Missing, excluded, wrong-profile or interval-valued originals reject. Each occurrence independently uses the existing complete/cancel/reopen/percentage rules; completing one leaves the others unchanged. Task assignment remains series-level.

Actual progress changes persist current state and one transition with action, before/after progress, resulting task revision and whole-second server-recorded time. Repeating an already satisfied action does not invent history or change protocol version, although an accepted write advances API revision/audit/scope generation as before. Reopening clears current completion time but retains the earlier completion transition. A later cancellation clears the active timestamp while retaining percentage and historical completion evidence. No actor identity appears in the initial history projection.

Retain occurrence history with the active task until deletion, without automatic expiry. This is the confirmed initial retention policy; configurable pruning is separate. Deletion transactionally scrubs current occurrence rows and **all** history with the active payload, leaving only the approved content-free task marker. Bulk deletion does not materialize the entire history in memory. At most 1,000 recorded originals are allowed per active task; reaching the limit rejects a new actual progress state without pruning existing records. Transition pages are bounded rather than loading the whole history.

## Pattern changes and conversion

Timing/rule edits preserve every recorded original and its progress/history. Reject exclusion, identity/profile changes, rule shortening that removes a recorded original, or recurrence removal while records remain. Reopening to neutral progress does not release the original identity or erase history. Explicit reconciliation is future work; this batch provides no implicit discard, retarget or history deletion action. Validate retained membership with one aggregate generation budget for the set of recorded originals, rather than multiplying a full budget by each record. An edit too expensive to prove safe fails.

New non-recurring tasks store an explicit clean `hasRecordedProgress=false` checkpoint. Any actual whole-task progress change sets it permanently true, including when later reopened. Conversion to recurrence requires a known false checkpoint and neutral progress. Legacy rows receive **null/unknown**, not a fabricated clean history; conversion rejects until a separately designed adoption/reconciliation flow. Native edits preserve unknown status unless actual progress makes it true. No old completion transitions are invented from audit times. Pre-beta development data may be recreated through the authorized development workflow; no automatic database reset follows from migration.

## Authorization and paging

Preview independently requires `readTask` and `previewTaskOccurrences`, both with timing/progress disclosure. History independently requires `readTask` and `readTaskHistory`, with those same current-state groups. Progress changes use the separate `changeTaskProgress` operation. Hosts receive actual parent/task, current master and recorded originals, the exact original query/action, current occurrence state and final validated proposed progress/version. Context lists are immutable. Existing final-write guarantees, opaque receipt disclosure, stale checks and shared scope locking apply across processes. The host decides policy; assignees and source/protocol identifiers grant no authority.

`occurrenceHistory` returns authorized transition entries and an opaque continuation, **no totals**. Bind to task/original, page size, caller/scope/policy revision, scope generation and expiry; require a current expected task revision on each page. Recheck authority on every request. Calendar/event/task-list/history cursors cannot be substituted. Stored transition evidence is validated against its native progress action before disclosure; corrupt evidence fails closed.

## Models and migration

All generated models come from `.spy.yaml` sources under the calendar module, using the pinned generation workflow.

| Model/change | Fields and responsibility |
| --- | --- |
| `CalendarTaskOccurrenceQuery` | Task UUID, expected revision; optional DATE or UTC from/until bounds, exactly one matching profile. |
| `CalendarTaskOccurrence` | Original typed start, optional start UTC/due DATE/due UTC and independent progress. |
| `CalendarTaskOccurrencePreview` | Task UUID, revision and bounded projected occurrences. |
| `CalendarTaskOccurrenceProgressRequest` | Task UUID, expected revision, original typed start, action, optional percentage. |
| `CalendarTaskOccurrenceRecord` | Server-only current state: task FK, canonical exact original key/start and progress; unique `(taskId, originalKey)`. |
| `CalendarTaskHistoryRecord` | Server-only transition: task FK, original key/start, resulting API revision, action, before/after progress and recorded time; unique `(taskId, revision)` and indexed original history. |
| `CalendarTaskHistoryQuery` | Task UUID, expected revision, original typed start, page size and optional opaque cursor. |
| `CalendarTaskHistoryEntry` / `CalendarTaskHistoryPage` | Projected transition values; task/revision/original, authorized entries and optional continuation. No total or actor profile. |
| `CalendarTaskDataRecord.hasRecordedProgress` | Nullable private conversion checkpoint: explicit false for clean new tasks, true after actual native progress, unknown for legacy rows. |
| `CalendarTaskView.recurrence` | Canonical recurrence under timing disclosure; absence is retained. |
| `CalendarCursorRecord` additions | Nullable history task UUID/original key/after-revision bindings, separate from ordinary task lists. |

The additive migration preserves existing task/calendar/event state, revisions and cursor bindings, leaving legacy checkpoints unknown and new occurrence/history tables empty. It does not invent transitions, source versions or protocol component history. Native task protocol checkpoints currently track aggregate actual task changes; faithful VTODO master/occurrence source checkpoints remain a separate interchange prerequisite.

Focused tests cover DATE/zoned due projections, exact identities/exclusions, start requirements, budgets, independent progress, history/no-ops, permission/group boundaries, stale/final-denied rollback, orphan protection, history cursor isolation, conversion checkpoints, record limits, corrupt evidence and deletion scrubbing. Two-host checks cover DST, concurrent progress and history continuations. The Flutter journey creates a series, completes independent occurrences, reads history and rejects an orphaning rule edit. Broader batch results are recorded after completion; no task wire/client interoperability is implied.


Batch validation on 2026-10-23: `./tool/check.ps1` passed generation stability, formatting/analysis, core 471 VM + 471 Chrome, wire 217 VM + 217 Chrome, module 129 VM + 17 Chrome, 3 widget tests, 211 database/policy tests, populated upgrades and two-host/JWT/client checks. Its browser stage exposed a stale enum-key selector. After making the key/test explicit, `dart analyze --fatal-infos` and `dart run tool/host_smoke.dart --flutter` passed the complete journey, including recurring progress/history/orphan protection; `flutter build web --no-pub` passed with the Wasm compilation dry run. Unchanged core/database suites were not repeated for the selector-only fix. Focused values/direct event regressions (33), initial new DB cases (11) and final history/limit regressions (10) passed separately. Relative links/ADR numbering and local credential scan passed; Apache 2.0 LICENSE is unchanged. None of this is VTODO or external-client interoperability evidence.
