# ADR 0104: Explicit task source replacements

Status: **confirmed replacement policy; concrete implementation mechanics under draft review**. Date: 2026-10-24.

## Confirmed scope

Reuse the availability replacement policy for tasks: select existing series and expected API revisions in one calendar, require a recorded current-profile import baseline, reject changed replacements after local content/progress edits, preserve native assignments, reject lower source SEQUENCE (omission is 0), allow equal SEQUENCE, and make identical replacements true no-ops. No implicit creation, deletion of unselected tasks, adoption, scheduling or alarm activation follows.

## Scoped contract and models under review

Add immutable CalendarTaskReplaceRequest (calendarId, expectedRevision, selection of existing CalendarTaskExportSelection, bytes), CalendarTaskReplaceReceipt (receipt, changed), and CalendarTaskReplaceResult (receipts). Snapshot selection and the exact byte slice before awaiting. Match the exact complete selected protocol UID set. Preserve source versions, timestamps and omissions, including backwards timestamps; native revision and audit time are independent.

Use dedicated replaceTasksFromImport and importTasks permissions on the actual parent and each selected task, plus complete readTask disclosure and readTaskSource before classification. Changed replacements also require updateTask and changeTaskProgress when either old or incoming components supply progress. Give the host an immutable batch of actual current/proposed objects and baseline profile/sequence, never the private historical snapshot. Repeat final checks under the durable scope transaction; no silent guarantee downgrade.

Compare normalized current source against incoming and the recorded v3 baseline. An identical incoming/current state is a no-op even when locally changed: preserve the old baseline rather than adopting local edits. A differing incoming state conflicts when current differs from baseline. Native assignments do not dirty source and survive replacements. Retain matching occurrence row identities by exact original key; never retarget history. A changed replacement with recorded history rejects conservatively; identical retries preserve history. No replacement invents progress transitions or clears the unknown prior-progress checkpoint.

All selected replacements are atomic. Changed tasks advance API revision, nondecreasing database audit time and scope generation once per batch; identical tasks change none of these or protocol/baseline state. Source-free tasks and unsupported older baselines require a future explicit adoption/reimport flow. Existing tables suffice; no schema migration is selected.

## Acceptance

Test exact selection, permissions and disclosure, baseline/local/version conflicts, preserved assignments/history/occurrence identity, exact source timestamps, no-op state, stale revisions, frozen inputs, final denial and rollback, generated-client cross-host races and the explicit Flutter replacement flow. Run focused tests during development and full repository checks before the batch commit. This is ordinary authenticated import reconciliation, not scheduling or external-client compatibility.
