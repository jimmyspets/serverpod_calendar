# Native calendar names, identifiers and storage

Status: **maintainer-confirmed name separation, server-generated UUID identity and minimal deletion marker; physical layout and generator validation proposed**. See [ADR 0047](adr/0047-calendar-names-identifiers-and-deletion-storage.md) and the [first CRUD contract](calendar-crud-contract.md). No calendar domain schema or migration exists yet.

## Confirmed name mapping

Use a required, nonempty native `displayName` for calendar lists and native CRUD. Preserve iCalendar NAME values separately as protocol metadata, including their legal language/parameter information. Importing protocol metadata does not silently rename the native calendar; renaming the native label does not silently rewrite preserved source metadata. These fields have distinct roles rather than being competing copies of the same mutable name.

| Name | Owner and intended use | Change behavior |
| --- | --- | --- |
| Native `displayName` | Calendar module; native list/detail UI | Explicit authorized native metadata changes |
| Calendar protocol NAME values | Explicit calendar interchange/publication metadata | Explicit authorized protocol metadata/import handling; preserve legal values/parameters |
| Feed name/description | Optional feed module; subscription presentation | Feed's own authorized metadata/revision; not inherited silently from a selected calendar |

Creating a feed may offer an explicit copy/prefill action, but the selected value becomes feed-owned metadata; no implicit ongoing synchronization is selected. Native renames alone do not change subscription bytes/ETags unless an explicitly approved projection depends on them. Actual published protocol/feed metadata changes still invalidate deterministic output/ETags. No publication fallback from the UI label is selected by this name-separation decision.

A valid ICS file may omit NAME. Preserve that absence through supported round trips instead of inventing a protocol name from the required native label. Imported NAME values do not establish ownership, uniqueness or authorization. Standalone import/export and feed projection remain separate profiles; their exact metadata editing/cardinality mappings require adapter implementation.

Source distinction: [RFC 7986 section 4](https://www.rfc-editor.org/rfc/rfc7986.html#section-4) makes NAME optional; [section 5.1](https://www.rfc-editor.org/rfc/rfc7986.html#section-5.1) permits language variants. The required native label is the maintainer's product rule under ADR 0046, not an extra RFC grammar restriction. [ADR 0048](adr/0048-calendar-name-validation-and-row-layout.md) selects outer-trimmed, nonempty, single-line native names of at most 256 Unicode code points, preserving internal spacing/Unicode spelling. Low-level validation/raw-byte limits, localization and duplicate-label behavior remain review gates; no unique-name constraint or locale-sensitive matching is selected here.

## Confirmed native identity

Calendar identities exposed by native APIs are **server-generated UUIDs**. The maintainer explicitly does not require a particular UUID version. Use a supported pinned generator, keep existing identifiers stable and treat IDs as opaque; clients must not infer order, creation time, uniqueness of names or permission from their encoding. A generation-version choice is an implementation detail, not a public API requirement. UUIDs are not bearer secrets or authorization evidence.

Native create commands do not accept a caller-chosen calendar identity. Read/update/delete commands reference an existing UUID that the server resolves within trusted scope. Public UUIDs do not replace `scopeKey`, parent checks, expected revisions or current authorization. Do not reuse a deleted identity for a new calendar.

Keep native row/API IDs distinct from original/imported iCalendar calendar or item UIDs, feed publication UIDs, original recurrence identities, host subject IDs and secret feed credentials. Do not coerce arbitrary legal source UIDs into UUID columns or expose a database ID as a subscription credential. Internal IDs for every other record are not automatically selected by this calendar decision.

## Proposed active storage shape

| Logical value | Candidate representation and invariant |
| --- | --- |
| Calendar identity | UUID, immutable and server generated; using it directly as the primary key is proposed, rather than adding an unnecessary second public identifier |
| Scope | Immutable host-resolved `scopeKey`; all lookups/references constrain actual scope/parent, even with globally unique UUIDs |
| Native label | Required nonempty `displayName`, separate from protocol metadata |
| Availability settings | Required exact named-zone key; free/unavailable no-rule fallback under ADR 0012, with free as the selected default |
| Native presentation/protocol metadata | Explicit writable fields versus preserved legal source properties/parameters; no raw unvalidated payload escape hatch |
| Revision and operational timestamps | Server-controlled revision and UTC created/updated instants for active aggregates; operational precision is separate from whole-second calendar timing |
| Subject associations | Separate scoped calendar/subject join, unique calendar/namespace/kind/external-ID tuple and contribution flag; no role or identity directory |

UUID primary keys, field types, table prefixes, text/index constraints and metadata normalization remain a physical schema proposal. Queries need authorized scope/identity paths and deterministic ordering; display names are not identity or an accepted unique lookup key. No default ordering or database collation is selected just by choosing UUIDs.

## Confirmed deletion marker

After the active-dependency check succeeds and deletion commits, retain only a minimal calendar deletion marker: UUID, trusted scope, final revision and deletion time. Remove the native label, zone/settings, protocol names/descriptions and other calendar content from the deleted calendar representation. This is not an archive, undelete feature, synchronization protocol or permission to keep the old payload in a generic JSON column. Ordinary get/list/update/query paths cannot return or resurrect the deleted calendar.

Delete/invalidation and marker creation must be atomic across hosts. Concurrent child/association creation must validate an active parent and participate in the reviewed dependency/delete coordination; a foreign key to a retained identity alone would not prove that the calendar is active. Native UUIDs are never reused, including after later marker purge. Retention duration, purge coordination, independent audit/receipt retention and exact key/index/constraint details remain unselected; ADR 0048 selects the identity/active-data split. Do not infer permission to retain calendar content indefinitely.

Markers exist for internal identity/retry/history reconciliation, not ordinary client discovery or public deleted-ID lookup. A marker is not an authorization grant, proof of prior ownership or a substitute for a trusted authorized mutation receipt. Repeated deletes, lost responses and stale IDs require privacy-safe current policy/result handling; inability to authorize a deleted target does not justify exposing its scope or former content. Marker data never becomes an iCalendar deletion feed or an implicit CalDAV sync token.

Physical storage now uses a small identity row and separate active-data row under ADR 0048; deletion removes active data and marks the identity, rather than creating a third marker table or retaining scrubbed payload columns. The [schema guide](calendar-schema.md) records the selected shape and proposed concrete fields; verify final keys/relations/indexes with pinned generation before claiming a physical schema. Preserve only explicitly required independent ledger/history records under their own retention policy; do not cascade them away or copy sensitive payload into the marker.

## Selected schema refinement

[ADR 0048](adr/0048-calendar-name-validation-and-row-layout.md) selects native name validation and identity/active-data rows. [The schema guide](calendar-schema.md) keeps identity revision authoritative, active timestamps with content, and deleted markers content-free. Exact key/index/metadata and transaction details still require generation and real tests.

## Toolchain evidence and implementation gate

The current [Serverpod table guide](https://docs.serverpod.dev/concepts/data-and-the-database/database/tables) documents UuidValue IDs; the [models guide](https://docs.serverpod.dev/concepts/data-and-the-database/models) documents serialization/defaults. Local pinned 4.0.4 source inspection found `serverpod_serialization` exporting UUID support, its UuidValue serialization path and `serverpod_database`'s ColumnUuid/UUID column mapping. These observations support the proposal; they are not calendar model-generation or database round-trip evidence.

Generate sources/migrations with the pinned toolchain, never hand-edit generated files. Before claiming implemented UUID storage, validate the chosen server-side generation path, generated-client serialization, foreign-key types/scope, uniqueness and real insert/read/update behavior on both hosts. Any future dependency upgrade must preserve existing calendar identities without imposing a client-visible UUID version contract.

## Acceptance before implementation completion

- [ ] Verify required native names/zones and separate protocol metadata; native rename/import cannot overwrite the other namespace implicitly.
- [ ] Test legal missing/multilingual NAME round trips in the later iCalendar adapter and explicit feed-owned names when feeds exist; do not claim those tests in calendar CRUD.
- [ ] Test server generation, UUID serialization and stable references without version-specific public assertions; reject forged scopes/parents and caller-chosen creation IDs.
- [ ] Verify active record/association constraints, stale revisions and authorization across two hosts; no unique-label or implicit owner assumption.
- [ ] Test atomic content removal/minimal marker creation, non-discoverability and no restore/UUID reuse across two hosts; settle marker retention/purge and final schema/index/text/metadata layout before generation.

The first CRUD implementation remains separate from this documentation. Source inspection and official documentation are evidence for feasibility, not completed migrations or domain behavior.
