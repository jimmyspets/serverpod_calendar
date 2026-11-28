# ADR 0098: Task source storage model

Status: **scoped implementation of confirmed read-only source retention and assignment-version separation; concrete mechanics under draft review**. Date: 2026-10-23.

## Context

Native tasks currently retain timing, recurrence, basic text, priority, independently optional progress, assignments and a master protocol version. The pure VTODO adapter additionally retains text annotations, grouped metadata, participants, relationships, attachments, unarmed DISPLAY/snooze definitions and progress-component source distinctions. Import cannot discard those supported values or manufacture history. A historical import baseline cannot serve as the current source state after a native edit.

ADR 0097 confirms create-only import, destination-local exact UID conflicts, independent source versions, separate permissions and a private baseline. Imported non-recurring tasks must retain unknown prior progress, including when their present values are neutral. This increment implements the storage prerequisite; it does not approve a new native editor, arm alarms or implement import/export endpoints.

## Representation

Keep existing native identity, parent, revision and active-data rows. Keep protocol UID as exact text, with digest candidates followed by exact comparison under the shared scope lock. Add optional structured current source state and a separate optional private import baseline to active data. Existing/native rows remain baseline-free. Missing current-state fields must have an explicit local-initialization policy, never be interpreted as evidence of import or clean progress.

Use generated immutable nested DTOs for current decoded values, with validation that copies and freezes every nested collection. Do not use an original ICS file or an opaque JSON bag as the canonical current metadata model. A versioned, bounded canonical JSON string is appropriate only for the private comparison baseline.

Use `.spy.yaml` definitions and pinned generation for these nested models. Serverpod's [current 4.0 model documentation](https://docs.serverpod.dev/concepts/data-and-the-database/models) distinguishes `serverOnly` generation from public DTOs and documents immutable final fields/value equality. Neither a final list field nor server-only generation establishes deep collection immutability, endpoint authorization or baseline privacy; enforce those separately and verify generated behavior with the pinned 4.0.4 toolchain.

| Model | Fields and purpose |
| --- | --- |
| `CalendarTaskSourceMetadata` | Optional URL/CLASS; ordered category groups, annotated comments/contacts, organizer/attendees, relationships, attachments and unarmed alarms. No native assignees, provider tokens or delivery state. |
| `CalendarTaskSourceText` | Decoded text plus optional existing `CalendarTextParameters` LANGUAGE/ALTREP. Preserve empty versus omitted singular values and repeated source groups. |
| `CalendarTaskSourceCategoryGroup` | Ordered decoded values, including duplicates, plus optional LANGUAGE. No ALTREP and no native category-search authority. |
| `CalendarTaskSourceParticipant` | Exact source calendar address and bounded standard parameter names/decoded ordered values. Distinguish organizer from attendee contexts during validation. Optional source values remain separate from effective defaults. |
| `CalendarTaskSourceRelationship` | Decoded target UID and optional profiled PARENT/CHILD/SIBLING type. Missing, self and cyclic targets remain unresolved source data. |
| `CalendarTaskSourceAttachment` | Inert URI, optional media type and meaningful source presence. No binary payload, fetching or automatic host file link. |
| `CalendarTaskSourceAlarm` | Annotated DISPLAY description; relative signed duration/optional START-or-END anchor or absolute UTC trigger; optional UID/ACKNOWLEDGED, paired repeat/interval and optional sibling snooze target. No armed flag, recipient or verified action. |
| `CalendarTaskSourceDuration` | Sign plus weeks/days/hours/minutes/seconds. Retain units and explicit zero where the wire profile permits it; reject fractions. Do not force signed alarm triggers into the positive task-duration model. |
| `CalendarTaskSourceState` | Complete decoded master and occurrence components keyed by exact original identity, with native query projections checked against them. Current state only, excluding the historical baseline. |
| `CalendarTaskSourceComponent` | Optional exact original start; own version, raw native content/progress, text annotations and full raw metadata. Undated override timing represents omitted milestones; metadata lists retain raw presence. Preserve explicit defaults such as PRIORITY:0 and CLASS:PUBLIC even when the master omits them. |
| `CalendarTaskImportBaseline` | Versioned profile, bounded canonical last-accepted source value and source sequence information needed by future reconciliation. No native API UUID/revision, audit time, host assignment or regenerated envelope decoration. |

Keep current occurrence progress in the existing per-original row. An imported explicit component creates a row even when every progress property is absent. Without such a row, use the entire master progress. Never merge individual absent fields from an explicit sparse row with the master. Imported source components create no history rows. Current source component state and occurrence progress must identify the same exact original and be validated together.

The existing public master protocol-version DTO remains independently disclosed. Occurrence versions require both original timing and protocol-identity disclosure; they must not disclose hidden content or baseline values. Current rich source data is available to trusted host policy through immutable current/final proposed context, separately from baseline privacy. The maintainer selected source retention now and native editors later; no new ordinary detail disclosure group is added.

## Mutation and version rules

Native edits preserve source annotations and metadata unless an explicit authorized operation changes them. Validate the complete retained state after timing/content/pattern edits. For example, removing a required alarm anchor must reject rather than remove the alarm, and changing a pattern must not orphan progress or source components. Explicit repeated occurrence content must remain a valid projection of the edited master; reject a change that the supported progress-only wire profile cannot faithfully retain.

Advance a component's SEQUENCE and nondecreasing whole-second protocol timestamps only when its own normalized decoded state changes. Omitted source SEQUENCE compares as zero when a native change first advances it; reject overflow. Preserve exact source timestamps and omissions on initial import. A native occurrence progress action changes that occurrence's version, while API revision and scope generation still cover the whole task. A master edit can change explicitly repeated occurrence content; compare and advance each affected component independently. Inherited omissions remain omissions.

Native assignments are host state, separate from source ORGANIZER/ATTENDEE. The maintainer confirmed that assignment-only changes leave component SEQUENCE and protocol timestamps unchanged; native revision, audit time and scope generation still advance; source import alone must never assign a person. Accepted native no-op writes retain existing API-revision behavior while unchanged normalized components retain protocol state. A command that is already satisfied must not pin an inherited default by creating an occurrence row or history.

New local components have known creation time. Existing masters may initialize from known audit times with sequence zero only when a protocol checkpoint is genuinely absent; existing occurrence components must omit unknown CREATED and use a documented local modification baseline. Neither operation creates an import baseline or asserts source history. Imported non-recurring tasks set the prior-progress checkpoint to unknown, not false. Existing conversion checks remain effective until a separate adoption/reconciliation operation exists.

## Baseline, limits and migration

The private baseline retains the last accepted decoded source, including values later removed locally. Exclude it from ordinary views, host snapshots, receipts, cursors, logs and current-state exports. Scrub it with the active row at deletion. Validate profile/version/UID before future comparison; reject unknown profiles rather than guessing or adopting native data. Pin IANA evidence in normalized source state without archiving unused zones or original VCALENDAR presentation.

Reuse the supported pure wire caps and aggregate recurrence/text/alarm budgets. Use a 2 MiB UTF-8 baseline cap, with Unicode and oversized nested input tests. Source-bearing mutations must stay within the supported wire profile and its aggregate caps; ordinary native tasks retain their existing larger recorded-original cap. Do not reset a database merely to add optional nested fields. Determine SQL migration need with pinned generation; generate module and example-host migrations if table fields change, then test fresh and populated upgrades. Preserve old source omissions and unknown progress checkpoints.

## Alternatives and consequences

Keeping only the original file makes ordinary edits, policy context and current export depend on stale source content. Flattening metadata or using only the master version loses supported source distinctions. Duplicating complete repeated metadata on every progress component is simpler to decode but increases storage and synchronization costs; bounded complete raw component values are used for straightforward validation and exact source presence; native query projections and source copies must agree or fail closed. A richer exception profile must extend this representation explicitly.

The proposal adds validation and versioning work before import, but gives the importer a single faithful, bounded storage conversion and keeps historical conflict state separate from current values. The maintainer selected read-only source preservation now and native participant/attachment/alarm editors later. Source data is initially server-only current policy context, with no new ordinary detail disclosure implied. Concrete representation and service mechanics remain under draft review.

## Acceptance conditions

Before adding the endpoint, verify DATE/UTC/named-zone and undated/due-only/duration forms; independently optional progress/versions; exact original membership; explicit component presence/defaults; annotations/groups/order; participants/references/attachments and all supported unarmed alarms/snoozes. Include immutable host-context tests, invalid retained alarm-anchor rejection, orphan protection, independent component/no-op/overflow versioning, baseline privacy/deletion, unknown checkpoint conversion rejection, generated round trips and populated upgrades. Then run the full agreed native batch checks. Pure conversion or schema generation alone is not authenticated import, runtime activation or client interoperability.

## Concrete table additions

Add optional server-only `sourceState` and `importBaseline` nested fields to `CalendarTaskDataRecord`, and optional `protocolVersion` to `CalendarTaskOccurrenceRecord`. Complete source components retain raw content/progress/version/annotations/metadata; compare them with native master and per-original projections before use. Existing source-free tasks stay source-free and baseline-free. Existing occurrence rows initialize their own local protocol baseline on the next actual change, omitting unknown CREATED; new rows start at SEQUENCE 0 with known creation time. Master content edits propagate explicit repeated text/priority and advance only affected component versions; incompatible explicit timing or retained alarm anchors reject. Native occurrence writes leave the master protocol version unchanged. Public rich metadata editors/disclosure and an import endpoint are not added by these fields.

## Scoped validation

See [the storage guide](../task-source-storage.md) for generated migration IDs, focused tests and batch evidence. The source-bearing database fixtures are synthetic direct storage setup, not an import endpoint. No original-file archive, native alarm activation or client interoperability is claimed.
