# ADR 0135: Native event and task text/link metadata editors

Status: **Proposed. Editable categories, event/task comments, URL and host-controlled classification are already selected requirements. The concrete subset models, permissions, lifecycle and projection mechanics below require explicit agreement.**

## Context

The selected RFC 5545 CATEGORIES, COMMENT, URL and CLASS profile is preserved in event/task source storage and ordinary interchange, but native editors/disclosure remain incomplete. ADR 0134 completes the analogous event priority/GEO/RESOURCES increment. This batch closes the text/link editing gap before broader invitation reconciliation; category search, participants, file access and mail remain separate; CONTACT remains import-only.

Reuse the existing bounded property profiles and source evidence in ADRs 0091/0107. Class labels do not grant access, create ownership or automatically publish. Categories never identify authorized groups or reserve resources; URI values are inert data.

Primary sources checked 2026-10-28: [RFC 5545 descriptive properties](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.2), [URL](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.6), and [current Serverpod 4 model guidance](https://docs.serverpod.dev/concepts/data-and-the-database/models), against the pinned 4.0.4 workflow. Limits and the patch/authority design below are application-profile choices, not new RFC requirements.

## Proposed models and storage

Add shared immutable client-visible CalendarItemCategoryGroup (values and optional LANGUAGE), CalendarItemComment (value and optional CalendarTextParameters), CalendarItemTextMetadataField (url/classification/categories/comments), CalendarItemTextMetadataPatch and separate event/task revision-checked request models. Keep existing private event/task source containers, source participants, contacts, references, attachments and alarms separate. Expose only this explicit subset through ordinary event/task views and the new editor.

Use existing source/protocol JSON, without new SQL tables/columns/indexes or migrations. Generate protocols/clients normally and verify schema stability. Older missing values remain absent; do not invent source baselines or history.

Preserve class absence versus explicit PUBLIC, PRIVATE or CONFIDENTIAL. Keep the existing HTTP/HTTPS absolute URL profile without embedded credentials and no fetching. Groups preserve order, duplicate labels and language spelling. Reuse the category profile: at most 64 combined nonblank single-line values of 256 code points, at least one value per group, up to 64 groups and optional validated LANGUAGE. Category spelling/internal spacing remain exact. Each comment is independent plain multiline TEXT up to 4,096 code points, with optional legal LANGUAGE/ALTREP; at most 32 comments and existing aggregate budgets. Empty comment text remains present; empty group/comment lists clear those properties. No translation, URI rendering or source CONTACT editor follows.

## Proposed operations and disclosure

Add updateEventTextMetadata and updateTaskTextMetadata, each taking actual item UUID, expected API revision and a selected-field patch. selectedFields contains one to four unique field names. Selected URL/classification with a null value explicitly clears it; selected category/comment fields require a list, with an empty list clearing it. Unselected payload fields must be absent/null and remain unchanged. Reject duplicate fields, empty selection and conflicting payload shapes. Ordinary content/progress/assignment/timing operations retain the metadata. Neither editor can mutate contacts, source participants, attachments, relationships, alarms, private baselines or protocol versions directly.

Use separate write operations; hosts may map them to ordinary edit rules. Resolve actual scope/parent/item and authorize before exposing retained-source compatibility, then validate the complete proposed state and repeat authorization at commit under the declared guarantee. Host policy sees the immutable validated patch selection, actual current and final proposed metadata, so it can apply field-specific rules and validate allowed category/class values independently of their source claims. The module performs no silent repair/normalization. Source replacement requires the applicable subset-write authority when these values change on the master or explicit occurrence components, including matching-value pin/unpin presence. Derive its changed-field selection from validated current/incoming state rather than trusting a client claim, alongside existing import/replacement/full-source/read and lifecycle/progress rules.

Add independently grantable url, classification, categories and comments groups to event/task views. Reuse read/list decisions and opaque cursor group binding; no totals or new category filters. Full export/replacement and event scheduling require complete applicable native disclosure plus existing source rights. CONTACT and unrelated rich source data remain behind raw source-read authority and never appear in this subset. Busy responses include none of these fields.

## Proposed lifecycle and supported occurrence behavior

Keep the existing ordinary wire profiles: occurrence omission inherits while explicit metadata must match the master, including grouped spelling/annotations (CLASS PUBLIC may match an omitted master default). Master edits that would conflict with retained explicit occurrence metadata reject atomically without rewriting or dropping it. This first editor is master-only; no new per-occurrence metadata, future content or source adoption policy is introduced.

Actual metadata changes advance the relevant master protocol version, API revision/audit state and publication generation. Normalized identical native saves retain protocol versions and feed generation under existing accepted-write revision rules. Native edits preserve private import baselines, so future differing source replacements detect local conflicts. Task edits do not alter progress, completion history, assignments or unknown prior-progress checkpoints.

Event scheduling compares effective inherited text/link metadata when allocating outgoing component versions, extending ADR 0134's complete-message comparison from retained validated master evidence. Unchanged effective components retain their versions; native inheritance/source versions, legacy checkpoint reads, collision floors and exact retry messages remain separate. Ordinary local edits send nothing; complete-message host approval remains mandatory. No new scheduling tables or mail follows.

Existing event feed serialization may publish these fields only under continuing complete authority, with requiredEventGroups including the new groups and deterministic byte/ETag changes after actual edits. Bearer authority is checked before 200/304. Task feeds remain outside the existing event subscription profile; alarms stay excluded.

## Example, alternatives and acceptance

Add master editors to event/task example screens with separate fields per comment/category value, preserving multiline comments, source groups and annotations. Category values are single-line. Only expose editors for granted groups and submit explicitly changed/granted fields; withheld/unselected fields stay unchanged. Preserve source omissions and show stale/compatibility rejection without clearing values. CONTACT, participants and links that require file/directory authority remain read-only source data.

Flattening groups or hiding annotations would lose supported data; exposing an entire source-container editor would allow unintended participant/alarm mutations. The selected-field subset avoids requiring unrelated hidden fields merely to edit one granted group. Search remains an explicit next query batch rather than claiming that editable labels are searchable.

Review models, write operations/read groups and effective outgoing comparisons before implementation. Test VM/Chrome text/group limits, Unicode/empty/omission handling, native/import/export/replacement round trips, immutable selected-field host context, independent disclosure and final rollback, compatibility/local-conflict preservation, task progress/assignment/history separation, deletion scrubbing, outgoing versions, feed ETags/withdrawal, real two-host races and the connected Flutter editors. Use focused tests during development and broader checks before one feature-batch commit. No maps, directory creation, reservation, source CONTACT authoring, incoming reconciliation or real mail is included.
