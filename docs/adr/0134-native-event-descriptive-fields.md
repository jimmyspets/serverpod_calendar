# ADR 0134: Native event descriptive fields and interchange

Status: **Proposed. The maintainer confirmed exact bounded decimal strings for coordinates. The native model/API/disclosure and wire/version mechanics below require explicit agreement before implementation.**

## Context and confirmed direction

The RFC feature tables select editable event coordinates, priority and descriptive resource labels. ADR 0118 already implements these in pure scheduling messages, but ordinary VEVENT/native event storage does not yet represent them. Closing this gap precedes faithful incoming invitation handling; it does not implement attendee inboxes, reconciliation or mail.

Primary sources checked 2026-10-28: [RFC 5545 GEO](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.6), [PRIORITY](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.9), [RESOURCES](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.10), [verified erratum 2677](https://www.rfc-editor.org/errata/eid2677), and RFC 5546 method tables. The erratum removes the erroneous single-RESOURCES restriction, matching the repeated component grammar. Reuse the bounded source codec rather than flattening groups or inheriting that obsolete restriction.

## Proposed native representation and storage

Add optional priority, geographicPosition and resourceGroups to the existing immutable CalendarEventSourceMetadata, which is already stored in event protocol/source JSON and supported occurrence source metadata. Add client-visible immutable geographic-position and resource-text-group DTOs plus an explicit descriptive-field request/view shape. Do not duplicate values into CalendarEventContent or infer them from location text. All other source participants, relationships, attachments, alarms and metadata remain preserved; this editor cannot mutate them.

Priority is independently optional 0–9; absent stays absent and explicit zero stays present. It means event importance, not availability-rule priority, alarm urgency or reservation precedence.

The confirmed geographic DTO stores latitudeText/longitudeText exactly, up to 64 characters each, validates signed plain decimal syntax and exact latitude/longitude ranges using the existing source profile, and never rounds or canonicalizes spellings. Null means no coordinate; explicit zero coordinates remain a real value. Both values are required as a pair. Geographic fractions do not relax whole-second calendar timing. Approximate doubles may be derived only for presentation; no maps, geocoding or timezone inference follows.

Resource groups preserve ordered decoded labels, duplicates/empty labels, optional LANGUAGE and ALTREP. Reuse ADR 0118's caps: 32 groups, 64 combined values, 4,096 code points per label, plus aggregate metadata/payload limits. A group has at least one value; an empty label is distinct from an absent property. Clearing all groups removes the property list. Annotations use the existing validated language/URI profile and cause no retrieval. Labels never create directory entities, associations, bookings or permissions.

The nested JSON additions require no new table/column/index or migration. Generate models/clients normally and verify SQL schema stability. Legacy missing fields remain absent; do not invent defaults, history or import baselines. Preserve active-data deletion/scrubbing and baseline conflict rules.

## Proposed API, permissions and example

Add an explicit revision-checked updateEventDescriptiveMetadata operation replacing only these three fields. It uses independent updateEventDescriptiveMetadata authority with actual parent/event/current/final validated protocol state; hosts may map it to ordinary edit rules. Existing native event content edits retain these fields automatically. Lifecycle/association permissions remain separate. Actual changes advance existing event protocol/API versions and publication generations under their normal rules; normalized no-ops keep protocol values stable.

Expose coordinates within the existing location disclosure group. Add separate priority and resources groups/read permissions, allowing hosts to hide labels or importance independently. Full-source import/export/scheduling/feed projections require the applicable complete native groups in addition to their existing rights; hidden fields never become exportable via a new shortcut. Busy summaries include none of these values and their calculations do not change.

The example edits master metadata only, with exact coordinate text, optional priority and resource groups/annotations. No per-occurrence descriptive editor is included. Retained explicit matching source metadata must remain compatible: native edits that would make preserved component metadata violate the supported profile reject atomically instead of clearing or rewriting it. Broader per-occurrence differences/clear/inherit editors follow separately.

## Proposed wire, scheduling and feed behavior

Extend the ordinary pure VEVENT master profile with optional singular GEO/PRIORITY and repeated grouped RESOURCES, preserving source omissions, decimal spelling and resource annotations. Unknown parameters still reject. For this first occurrence profile, omitted values inherit and explicit values must match the master under the bounded existing metadata policy; per-occurrence differences reject rather than flatten. Preserve supplied component properties/presence in storage and round trips.

Authenticated create/export/replacement preserves these values and full authorization, exact baselines, source versions and no-op rules. Native edits use the shared bounded semantic validation; parsing/serialization stays behind the explicit wire boundary. General VTODO extension and attendee invitation intake remain separate.

Outgoing scheduling compares the effective new fields for each supported component as well as its own wire fields. An inherited-coordinate/priority/resource change must advance affected outgoing occurrence versions even when the optional property was omitted there. Derive the comparison from the validated complete message and retained master ledger; no expanded occurrences or new table is required. Preserve native inheritance/source versions, independent unchanged versions, legacy reads, ADR 0133 collision floors and exact retries. Complete host message approval still applies.

The optional feed's declared native-field projection may include the new properties only with the new applicable disclosure rights and continuing complete publication approval. Metadata edits update deterministic bytes/ETags; revocation is checked before 200/304 as before. No copied credentials or other bearer URLs are added. Alarms remain excluded. Serializer evidence does not establish Apple/Google/Outlook rendering or scheduling-mail interoperability.

## Alternatives, consequences and acceptance

Binary doubles can change accepted source values/spelling; the confirmed strings avoid that loss. Flattened resource text discards source grouping and language/alternative representations. Requiring raw source-read permission for every native coordinate view would prevent useful independent location disclosure, while unrestricted source metadata writes could mutate participants/alarms. The explicit subset editor and disclosure groups keep those boundaries visible.

Review the concrete nested models, operation/read groups, strict occurrence compatibility and effective scheduling-version comparisons before implementation. Test exact numeric boundaries on VM/Chrome, groups/annotations/cardinality/errata, omissions and zero, authenticated native/import/export/replacement round trips, stale revisions/rollback/disclosure, source preservation/deletion/baselines, outgoing inheritance/version/current-reply behavior, feed ETags/withdrawal, two-host races and the Flutter editor. Run focused tests during development and full batch checks before one code commit. No real email, maps, geocoding, resource reservation or blanket client conformance is authorized.
