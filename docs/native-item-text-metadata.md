# Native event and task text/link metadata

Accepted [ADR 0135](adr/0135-native-item-text-metadata-editors.md), including its separately approved private task-state refinement, adds master editing and independent disclosure for URL, CLASS, CATEGORIES and COMMENT. Source CONTACT stays import-only. Category search, participant/file workflows, differing occurrence metadata and mail remain separate. Validation is recorded in [the evidence guide](scaffold-validation.md).

## Selected-field API

Generated endpoints `calendarEvent.updateTextMetadata` and `calendarTask.updateTextMetadata` accept their item UUID, expected API revision and `CalendarItemTextMetadataPatch`. `selectedFields` must contain one to four unique field names: url, classification, categories or comments. Selected URL/classification with null explicitly clears it. Selected category/comment fields require a list; an empty list clears those properties. Unselected payloads must be absent/null and remain unchanged. Duplicate/empty selections and contradictory payload shapes reject.

URL uses the existing absolute HTTP/HTTPS profile without credentials. CLASS preserves absence versus explicit PUBLIC/PRIVATE/CONFIDENTIAL; the RFC effective PUBLIC default grants no access. Category groups retain order, duplicate labels, optional LANGUAGE spelling and exact internal/outer spacing. Bounds are 64 groups/combined values, with nonblank single-line labels up to 256 Unicode code points. COMMENT retains separate multiline TEXT values (including empty text), LANGUAGE and ALTREP; at most 32 comments of 4,096 code points each, within existing aggregate budgets. ALTREP uses the existing absolute ASCII URI profile (at most 4,096 characters, no embedded credentials or malformed escapes), shared through validateIcalendarMetadataUri. No value is truncated, translated, fetched or rendered as active content.

The module resolves actual scope/parent/item and authorizes the separate updateEventTextMetadata or updateTaskTextMetadata operation before checking private retained-component compatibility. It then validates complete final state and rechecks authority at commit under the host's declared consistency guarantee. Immutable itemTextMetadataPatch context identifies selected fields, alongside actual current/final state. Source replacement derives changed fields across master and explicit single/future components, including matching-value pin/unpin presence. Its patch payload describes the incoming master; full source replacement context identifies component-specific changes. A selected field never claims an actor, membership or permission.

## Disclosure and preservation

URL, classification, categories and comments are separate event/task read groups, granted through existing read/list decisions and cursor binding. The example submits only edited granted fields. Hidden/unselected values remain intact. CONTACT, source participants, attachments, relationships, alarms and private import baselines are outside the subset; no source-read bypass exposes them. Busy responses contain none of this metadata.

Ordinary content/timing/progress/assignment edits preserve metadata. Native metadata edits retain import baselines; later differing source replacements detect local conflicts. Actual metadata changes advance master protocol versions with nondecreasing whole-second times. Identical normalized native saves keep protocol/feed generation stable while preserving the established accepted-write API revision/audit behavior. Task progress, assignments, occurrence history and unknown prior-progress checkpoints are not initialized or reset by metadata editing.

Existing wire rules remain: omitted occurrence metadata inherits; explicitly supplied metadata must match the master, including groups/annotations and CLASS's effective default. A master edit that conflicts with retained explicit components rejects atomically instead of clearing or rewriting them. This batch adds no per-occurrence metadata editor or new wire property profile.

## Private native task storage

Existing imported task sourceState remains a complete strictly validated wire component set. For a task using row-backed native occurrence/history data, the trusted metadata service can create nativeMetadataOnly=true in existing sourceState JSON. It contains known current master content/progress/version and bounded native text/link metadata, with no source occurrence components or unrelated rich source claims. Only true or absence is valid. This private flag grants no provenance, identity or authority and does not invent a source baseline or historical component versions. Metadata-only requests do not preload occurrence/history rows; a history-dependent host rule must query actual rows using the trusted task ID and provided transaction. Neither an empty marked source component list nor this operation's unloaded recorded-occurrence context proves that no history exists.

Native master edits synchronize that marked master; occurrence timing/content/progress stays in existing rows. Metadata editing does not serialize those rows through narrower wire limits. Export explicitly combines marked master metadata with actual rows into an unmarked temporary wire projection. Existing export limits and unknown-history rejection remain; they do not limit native metadata editing. A task with 130 native occurrence rows is covered by focused preservation/export-limit tests. Imported state continues exact source/row consistency checks. Deletion scrubs marked metadata with active data and preserves only the approved marker.

These DTO/JSON changes require no SQL migration; pinned generation reports no schema changes. Upgrade participating hosts and regenerated clients together before writes; mixed old/new writers are outside the unpublished API profile.

## Scheduling, feeds and example

Local edits send nothing. Event Save and notify compares effective inherited text/link metadata when allocating outgoing single/range component versions, preserving independent unchanged versions, native inheritance/source versions, collision floors, retries and complete-message host approval. Full export/replacement/scheduling still requires all applicable native groups plus existing source permissions.

The event subscription projection keeps continuing complete publication authority, explicit required groups, deterministic bytes/ETags and revocation checks before 200/304. Alarms remain excluded; task feeds are not added. Byte-level evidence does not establish external client rendering or mail compatibility.

Event/task example screens offer separate editors. Category values and comments use separate fields, preserving grouping and embedded comment newlines without delimiter ambiguity. Language/ALTREP are retained until explicitly edited. Empty comments remain values; removal clears them. Stale revisions require returning and reloading; rejection preserves the user's local form.
