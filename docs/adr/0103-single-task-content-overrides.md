# ADR 0103: Selected single-task content overrides

Status: **scoped implementation of confirmed selected-field inheritance and anchor-only content; concrete mechanics under draft review**. Date: 2026-10-23.

## Confirmed scope

After task future timing, add single-occurrence summary, description, location and priority changes. Only selected fields override the series; unmodified fields keep following it. Offer explicit clear and restore-inheritance actions. If the original also anchors a future timing change, content applies only at that original, like progress; only timing propagates. Future content propagation, richer source editors and source reconciliation remain separate.

## Scoped model and wire integration under review

Use immutable sparse `CalendarTaskOccurrenceContent` with nullable summary/description/location/priority: null means inherit; explicit empty text or PRIORITY 0 means cleared. Store nullable contentOverrides on an original's existing occurrence row. Add a dedicated immutable request with task UUID, expected revision, exact original and one to four unique selected-field changes. Each change names summary/description/location/priority and set/clear/inherit action with the corresponding typed value only. Normalize empty override objects to absence. Existing text limits/Unicode preservation and priority 0–9 apply; native set uses nonempty text and clear is explicit. Source empty values remain preserved as clear.

Wire omission inherits per field; explicit source values are independent overrides, even if they currently equal the master. RANGE content remains anchor-only in this bounded application profile. Keep raw source annotations/versions/metadata and independently optional progress. Native set preserves existing own annotations (a newly overridden inherited field captures its effective annotations); clear removes that field's annotations and inherit removes own annotations. No automatic fetching, participant mapping, alarm activation or history follows.

Earlier v2 raw repetitions were constrained to equal the master and rewritten by native master edits. Their meaning now changes to independent overrides. Advance private baseline profile to v3 and fail closed on older imports pending explicit pre-beta recreation/reimport, without automatic adoption or development reset. Source-free existing rows remain inherited; nullable generated migrations invent no overrides. Native master edits preserve own fields rather than rewriting them. Pattern edits preserve every recorded original and reject orphans.

## Scoped authority and projections under review

Use independent updateTask authority, actual parent/task/original/current/final merged and stored content, retained records and component version under the durable scope transaction/stale/final checks. Progress, assignments, timing and history stay unchanged. A new own component captures current effective progress without adding history. Only changed anchor protocol state advances; no-op/native revision rules remain as in ADR 0102.

Task previews opt into summary/description/location/priority disclosure groups; existing timing/progress requirements stay mandatory. Require every requested group and expose only requested effective fields and corresponding override state, with explicit disclosed groups. Default previews and history gain no content disclosure. Internal trusted policy snapshots remain complete. Export still requires full ordinary/source-read authority; private historical baselines remain excluded.

## Acceptance

Record model fields before generation/migrations. Test wire omission/empty/0/differences/range-local content and versions; native selected set/clear/inherit, master-following versus pinned fields, completed progress/history, sparse progress capture, independent permissions/disclosure/context, stale/final/rollback/orphan bounds, source annotations and baseline rejection, export/reimport, populated upgrades, two-host content/progress races and Flutter journeys. Focused checks during work, full checks and one commit only after the complete batch. Concrete mechanics remain draft-review material; no blanket client compatibility follows.
