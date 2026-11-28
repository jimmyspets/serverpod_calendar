# Inert event source relationships and attachments

Status: scoped implementation of the confirmed task-style source policy under [ADR 0109](adr/0109-inert-event-source-references.md). Concrete mechanics remain under draft review; actual commands/results belong in [the validation record](scaffold-validation.md).

VEVENT RELATED-TO values stay unresolved source UIDs. Missing, self-referencing, forward and cyclic references are preserved without lookup. They create no native graph edges, host identities, ownership, access rights, dependency rescheduling, cascade deletion or bookings. A source UID is not a native UUID or proof that an accessible target exists. Native graph editing, target authorization and publication mapping remain separate.

ATTACH values stay inert absolute URI references. The module/example never opens, fetches, inspects, copies into mail or grants access to their targets. A declared media type does not verify contents or prove that a host manages a file. The source-preservation profile accepts URI references such as HTTP/HTTPS, CID and URN under the existing absolute ASCII/no-userinfo rules; future native host-managed file integration remains separate. No file bytes are stored by this profile.

## Bounded wire behavior

Immutable `IcalendarEventReferences` contains ordered relationship and attachment lists. RELATED-TO preserves decoded nonempty TEXT targets up to 4,096 code points, duplicate values and optional PARENT/CHILD/SIBLING RELTYPE. Omission remains absent, with separately named effective PARENT. Extended relation types, GAP, URI-valued relationships and unprofiled parameters reject until individually supported; this does not implement RFC 9253.

ATTACH preserves its URI, optional explicit VALUE=URI presence and optional FMTTYPE spelling. URIs allow up to 4,096 ASCII characters; media type/subtype tokens allow up to 127 characters without parameters or wildcard ranges. VALUE=BINARY, ENCODING and data-scheme payloads reject, including uppercase DATA. Each reference list allows 64 entries per component. Decoded targets, relation tokens, URIs and media types share the 65,536-code-point event metadata budget across a file or stored series. These are application-profile limits, not RFC maxima; rejection never silently removes values or returns partial imports.

Omitted occurrence lists inherit only through `referencesFor(component)`; raw omissions remain absent for source output. Supplied lists must match the master in order, exact target UID/effective relation or exact URI/case-insensitive media type. Explicit PARENT can match an omitted master RELTYPE; explicit VALUE=URI can match the default URI form while retaining its own source presence. Different occurrence references reject, including at future timing anchors. Foreign components cannot use another series' effective projection. `decodeIcalendarEventReferences` validates reference properties under the same bounded profile without resolution or retrieval.

## Storage and authorization

Nullable relationship/attachment lists extend existing server-only event metadata JSON. Immutable `CalendarEventSourceRelationship` stores targetUid and optional relationType; `CalendarEventSourceAttachment` stores uri, optional mediaType and explicitUri. Empty lists normalize to absence. No new table columns or migration are needed, and older metadata/participant event-source-v2 snapshots remain compatible.

Compatibility testing exposed a prior participant edge case: canonical snapshots omit empty maps, while generated participant decoding requires a parameters map. Baseline decoding now reconstructs only absent required parameter maps at known master/own participant paths. It preserves canonical bytes and source versions, adds no address/parameter claims and does not adopt local edits or reset data. Invalid/noncanonical state still rejects.

Native text/timing/lifecycle edits preserve references, own component history and private baselines. Metadata-only originals remain in membership/orphan checks and survive single/future timing transfers while staying hidden from ordinary details/previews/component-version lists. Export of unrepresentable inherited timing still rejects. Source replacement compares complete reference state under existing baseline/local-conflict/no-op rules. Event deletion scrubs active source data/private snapshots without traversing source links.

Existing independent `readEventSource` gates current-source export and replacement, including final checks, no-op classification and retries. Complete immutable host intents include current/proposed references; historical baselines remain private. Ordinary event response groups do not disclose this source data. No target/file authorization is inferred from source syntax or the caller's right to edit the source event.

The synthetic example imports/exports references as read-only source metadata. Two-host/Flutter fixtures exercise retained source values, ordinary-response privacy and timing transfers; database checks cover replacement/no-op and late malformed-input atomicity. Native graph/file editors, selected relationship extensions, alarms, scheduling, HTTP feeds and external-client evidence remain separate.

See [RFC 5545 RELATED-TO](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.5), [ATTACH](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.1), [task source policy](adr/0093-vtodo-source-references.md), [source metadata](event-source-metadata.md) and [participants](event-source-participants.md).
