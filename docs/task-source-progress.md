# Source-preserving native task progress

[ADR 0096](adr/0096-source-preserving-native-task-progress.md) implements the maintainer's selected independently optional source progress and recurring master defaults as a prerequisite to task database import. Full source metadata/component-version storage and the import endpoint remain separate work. Tests seed synthetic source-shaped rows directly; this does not claim an authenticated VTODO import API exists.

## Values and native commands

`CalendarTaskProgress.status`, `percentComplete` and `completedAt` are independently optional. Generated deserialization does not insert NEEDS-ACTION or 0 when a field is absent. Every present percentage must be 0–100; completion time must be whole-second UTC inside the ordinary [1970,2100) profile. Status is the typed task enum. Preserve unusual combinations and omissions through storage, generated API responses, reads and unrelated content/assignment edits. A completion timestamp alone is source state, not proof of a native action or historical transition.

Native creation explicitly stores NEEDS-ACTION/0 with no completion time. Native actions remain explicit application behavior:

| Command | Result |
| --- | --- |
| Complete | COMPLETED/100/server whole-second UTC time. A cancelled status requires reopening first. Already COMPLETED/100 with an existing valid completion time remains a no-op; an unusual partial completed state is normalized by this explicit command. |
| Reopen | NEEDS-ACTION/0, completion time cleared. |
| Cancel | CANCELLED, existing percentage retained including absence, completion time cleared. |
| Set percentage | Explicit 0–99; 0 gives NEEDS-ACTION, otherwise IN-PROCESS; completion time cleared. Cancelled/completed status requires reopening first. |

Only explicit native commands normalize source combinations. Content changes never fill in or reconcile source progress. Actual normalized state changes still advance protocol state; accepted no-op write revision/audit/scope behavior remains unchanged. Native commands create current behavior, not retrospective evidence of an imported timestamp.

## Recurring defaults and history

Stored recurring master progress may be independently optional/unusual. For each exact original occurrence, use the master's entire progress value if no occurrence row exists. If a row exists, use its entire value, including omissions; never merge missing fields from the master. Preview output discloses that selected value with the existing progress/timing groups. Native occurrence actions start from the selected current value and replace only that occurrence. Other originals and master progress remain unchanged. Whole-series native progress commands still reject.

Source-shaped master/occurrence values alone create no history. An actual native occurrence transition records its before/after value, command, current API revision and server time under the existing history contract. Validate each source-shaped before value independently, then replay the native command to verify its recorded after value. No-op actions invent no transitions or new occurrence rows and do not pin an inherited default; explicit source occurrence rows still retain their presence. Keep aggregate membership/work limits, original identity, orphan protection, retention/scrubbing and final host authorization unchanged.

Native conversion from non-recurring to recurring still requires a known clean checkpoint and explicit NEEDS-ACTION/0/no completion timestamp. Missing status/percentage or an otherwise neutral value carrying a source completion timestamp is insufficient. Source adoption/import history and conversion reconciliation remain separate designs.

## API, storage and example

This is an authorized pre-beta breaking API change. Hosts and generated clients must handle nullable status/percentage. The example labels absence as unspecified, leaves an unspecified percentage input blank, and displays completion state independently. It does not display a fabricated stored default. Native create/reopen remain explicit defaults. No native source-progress setter is added; the existing independently authorized commands remain the editing surface.

Progress is nested JSON in existing task/occurrence/history rows. Regeneration changed server/client progress serialization, with no table-source or generated SQL-schema change, so no database migration is added. Existing explicitly stored JSON values retain their values. Missing values now remain missing; no database reset, clean-history inference or source baseline is manufactured. The existing populated-upgrade checks remain part of the native batch validation.

Actual/proposed host snapshots preserve optional source fields, current parent/object and independent operation/disclosure checks. Assignments still use opaque host references; source participants do not automatically map to them. Import permissions, complete wire-profile storage, component versions/baselines, unarmed alarm retention and authenticated task import/export remain separate prerequisites.

## Validation

Focused unit tests cover optional-field round trips, unusual combinations, strict percentage/UTC/range validation and explicit native command normalization/no-ops. Focused database cases cover read/content/disclosure preservation, master defaults, sparse occurrence values, actual history replay and conversion guards. Full native batch results are recorded after completion; pure source fixtures and service tests do not establish task import or external-client interoperability.

Batch validation on 2026-10-23: focused values/recurrence 16 and database cases 3 passed. `./tool/check.ps1` passed stable generation/formatting/fatal-info analysis, core 471 VM + 471 Chrome, wire 308 VM + 308 Chrome, module 130 VM + 17 Chrome, 3 widget tests, 214 database/policy tests, populated upgrades, two-host/JWT/native-client checks, the complete Flutter browser journey, and release Web build with Wasm compilation dry run. The browser assertions were aligned with the independent completion timestamp display before their stage ran; final formatting/analysis passed separately. Links/ADRs/diff/local credential checks passed. No table-schema migration was generated or required; development data was not reset. Full source storage and authenticated task import remain separate.
