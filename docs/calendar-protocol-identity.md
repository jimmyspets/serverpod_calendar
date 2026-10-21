# Native calendar protocol identity and modification time

[ADR 0052](adr/0052-calendar-protocol-identity-and-revision-time.md) records the confirmed generated-UID and automatic-timestamp policy. This increment adds read-only native data and host disclosure; it does not parse, export or publish ICS.

## Models and ownership

| Model/field | Role |
| --- | --- |
| `CalendarDataRecord.protocolUid` | Server-only active-data UUID with random model/database defaults and a unique index |
| `CalendarProtocolIdentity.uid` | Stable random UUID text for this native calendar, independent of its API UUID |
| `CalendarProtocolIdentity.lastModified` | Automatic UTC whole-second projection of the persisted calendar revision time |
| `CalendarView.protocolIdentity` | Nullable immutable view controlled by its own disclosure group |
| `CalendarPolicySnapshot.protocolIdentity` | Actual server-loaded immutable identity/time for trusted host authorization |

Creation generates UID; callers cannot supply, rename or reset it. Every accepted metadata, settings or association command preserves it, including name-only edits and full replacement of text/supplemental metadata. UID is neither a credential nor an identity/membership reference. Imported source UIDs and aggregate-feed UIDs remain separate future fields/contracts; do not replace imported identity or deduplicate calendars from this field alone.

Request `CalendarFieldGroup.protocolIdentity` through existing get/list APIs. The host must grant that group as well as object access; otherwise the field is null. Requesting it alone does not reveal native text, settings, protocol text or supplemental values. UID and modification time are one predefined group; hosts should consider that modification time discloses activity. No new write operation/permission exists for these server-managed fields. Host snapshot construction gains a required immutable identity field; unpublished APIs may break as approved.

The example shows read-only UID and UTC time when disclosed. It sends no UID/time editor commands and makes no automatic publication choice.

## Time and revisions

Creation samples the shared PostgreSQL clock after final authorization while holding the transaction's scope lock. All successful calendar mutation families use one save path that updates precise `updatedAt`, the calendar revision and scope generation atomically. Sample database time and retain the previous timestamp if the clock has moved backwards. Different hosts do not substitute their local clocks. Creation `createdAt` remains stable.

The native protocol view removes the fraction from UTC `updatedAt` without changing its persisted precision. It always has zero milliseconds/microseconds. This is server timestamp projection, not acceptance or rounding of fractional event/task input: the whole-second temporal input policy is unchanged.

Two writes in one second can have the same LAST-MODIFIED and different revisions. Clock correction can also hold time unchanged; never invent future seconds to distinguish revisions. Expected revisions remain the concurrency guard. Accepted no-op commands still increment revision and touch time, following existing behavior. Reads, denied/stale/invalid changes and rolled-back work do not modify these values. Administrative clock timestamps do not expand supported scheduled dates.

This timestamp concerns the calendar's own metadata, settings and associations. Event/task timestamps and eventual publication must also account for contained object additions, changes and removals. Selection, disclosure and serializer changes also affect future feed representations. Do not use this value alone as a complete VCALENDAR LAST-MODIFIED, ETag or HTTP validator; imported source LAST-MODIFIED preservation is not implemented.

## Storage and upgrade

The generated module/host migration adds `protocolUid uuid NOT NULL DEFAULT gen_random_uuid()` plus a unique index. Existing active rows receive independent random values; precise timestamps, content, scope/aggregate revisions, associations and cursor bindings remain unchanged. The generated Dart model also defaults to a fresh random UUID; service updates retain the persisted value. The unique-index generation warning is reviewed against the new random column and exercised on populated synthetic data.

Deleting a dependency-free calendar removes its active UID/content. Keep only the approved API UUID/scope/revision/deletion-time marker; no protocol identity is added to it, exposed after deletion or used for restoration. A new calendar receives new identities. No retention or sync tombstone contract is added. The example's policy epoch changes to v4 so older continuations must restart under the updated disclosure contract.

See [the validation record](scaffold-validation.md) for commands actually run, [calendar CRUD](calendar-crud-implementation.md) for authorization/transaction limits and [RFC 7986 sections 5.3–5.4](https://www.rfc-editor.org/rfc/rfc7986.html#section-5.3) for protocol semantics. No wire conformance or client interoperability follows from generated native DTOs.
