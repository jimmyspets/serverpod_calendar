# Explicit task source replacement

Status: scoped implementation under [ADR 0104](adr/0104-task-source-replacements.md), following the confirmed availability replacement policy. Concrete API and storage mechanics remain under draft review.

`calendarTask.replaceFromImport(CalendarTaskReplaceRequest)` atomically replaces explicitly selected existing task series in one calendar. Supply the calendar UUID/revision, task UUID/revision selections and strict iCalendar bytes. The file must contain exactly the selected protocol UIDs, with supported masters and matching occurrence components. There is no implicit create, unselected delete, mixed upsert, adoption or scheduling reconciliation.

## Conflicts and source versions

Each task must have validated source state and a recorded current `task-source-v3` import baseline. Source-free native tasks reject with dependencyConflict; unsupported old/corrupt baselines fail closed as unavailable. Do not infer a baseline from the current state. Pre-beta recreation/reimport is explicit; no development reset is performed.

Compare canonical source semantics, including component versions/omissions, content, timing, independently optional progress and rich source metadata. Native assignments, database audit time, API revisions and progress history are separate. Differing incoming source conflicts when current source differs from its accepted baseline. A larger source SEQUENCE never erases local edits. Lower **master** SEQUENCE than the accepted baseline rejects; equal is allowed and omission counts as 0. Source timestamps/omissions are preserved exactly, even backwards; they establish neither authority nor freshness. This is not iTIP version reconciliation.

Identical incoming/current source is a true no-op, including after local edits: still check the recorded baseline, source version, revisions and complete authorization, but leave API revision, audit times, protocol state, baseline and scope generation unchanged. In particular, an identical retry never adopts a locally changed source as a new baseline. Source-envelope formatting and regenerated zones are outside the semantic comparison.

Native assignments survive replacements and assignment-only edits do not dirty source. Retain matching occurrence database identities by exact typed original key, allocate new rows for new originals and remove absent own rows only within the explicitly selected full replacement. Changed replacement with recorded history rejects conservatively; identical retry retains history unchanged. No progress transitions are invented and the prior-progress checkpoint remains unchanged/unknown. Source participants assign nobody and source alarms remain unarmed.

## Authorization and atomicity

Require independent importTasks and replaceTasksFromImport permission on the actual parent and every selected task. Before returning equality/conflict information, require readTaskSource and readTask with all eight ordinary groups. Changed replacements additionally require updateTask and changeTaskProgress whenever either current or incoming master/occurrence components supply any progress field, including removing those fields. Native assignment authority is unnecessary because assignments are retained.

The trusted host receives CalendarTaskReplacementIntent with actual current/proposed identities and full validated proposed source, preserved proposed assignments, baseline profile/sequence and, after authorized classification, changed/localChanges. Historical baseline contents are never included. Recheck current host context and final decisions under the durable scope transaction and declared authorization guarantee. Fresh external checks retain their documented post-check revocation race.

Snapshot selection and the exact ByteData slice before awaiting. Apply existing byte/component/recurrence/baseline limits; empty, duplicate, stale, foreign, unsupported and inconsistent selections reject the entire batch. A changed member advances its API revision and nondecreasing database audit timestamp, preserving creation time and exact source versions. Advance scope generation once iff any member changed. Late denial, overflow or storage failure rolls back every member. Minimal changed/unchanged receipts require host receipt disclosure; no private baseline payload is returned. Existing tables suffice; there is no migration in this batch.

## Example

The Flutter task list offers “Replace task source” for one explicitly selected series. It loads the authorized current export into an editor, explains full replacement/local conflicts and requires an explicit submission. A disclosed identical result leaves the editor usable because the expected revision remains valid; changed or undisclosed results disable resubmission until reopened. The text editor normalizes line endings to CRLF; the byte API remains strict. Return to the task list and reopen to review fresh revisions after a stale/conflicting request; there is no automatic overwrite or stale retry. The typed API supports multiple selected series atomically.

Validation commands and outcomes are recorded in [the validation record](scaffold-validation.md). This increment does not implement adoption/force overwrite, native rich-source editors, future content/cancellation, feeds, scheduling, alarm runtime or external-client compatibility.
