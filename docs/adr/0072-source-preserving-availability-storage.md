# ADR 0072: Source-preserving availability storage

Status: **Implemented scoped prerequisites for the accepted ADR 0071 choices; representation/migration mechanics under review**. Date: 2026-10-22.

## Context and selected scope

The maintainer selected extending native storage before create-only availability import, destination-calendar active UID conflicts, retained initial source versions, separate import/create authority and separate opening UUID/protocol UID under [ADR 0071](0071-create-only-availability-import.md). This batch implements storage/conversion/native-edit prerequisites. It does not implement the import endpoint, updates/reconciliation, export, feeds or scheduling.

## Implemented mechanics

[The storage guide](../availability-storage.md) records precise fields, validation, caps and evidence. Definition protocol UIDs become bounded exact strings with active parent/digest lookup; openings retain UUID API identity and gain a separate protocol UID. The non-unique fixed-size digest index narrows candidates; exact comparison under the durable scope write transaction determines equality. Digest collisions do not authorize merging. Deletion keeps existing minimal content-free markers.

Add ordered categoryGroups as a mutually exclusive alternative to the existing native single-group categories/language representation. Keep positional COMMENT annotations because they already preserve the selected repeated profile. Add read-only typed CONTACT retention. These representation choices refine ADR 0071's proposed DTO refactor without reducing supported wire shapes or introducing competing authoritative field copies. Native replacements preserve omitted groups/contacts/periods; explicit group/period clears and metadata rights remain checked, while CONTACT changes/clears reject. The example preserves additional groups and displays source-only contacts. Equality checks on echoed CONTACT/opening protocol UIDs require raw read authority before comparison and in final write checks, preventing a hidden-value oracle; omission still permits write-only editing with retention. Read decisions do not grant or suppress mutation receipts.

Availability-only PERIOD lists integrate into core recurrence, overlap previews, timing edits and free/busy. Raise stored masters to 128 while retaining separate query caps and complete/unknown behavior. Share recurrence candidate work across availability opening evaluations and through native subject-search budgets. Public event DTOs gain no new recurrence capability.

Retain omitted/independent source protocol versions and dates separately from native audit time, removing local-creation-only equality/order assumptions for imported state. Native creation remains known-clock/sequence-zero. Actual changes increment effective sequence and clamp affected component stamps without inventing CREATED. Typed single/future component states preserve original identities, independent timestamps and property omission. Native metadata evolution updates explicitly inherited component properties; unknown legacy component creation stays absent with a documented checkpoint baseline. Freeze nested source state before policy callbacks.

A pure server-internal wire-to-storage helper builds validated proposals; no records or authority result from conversion. Existing native writes still enforce current host/organizer/extension policy. The subsequent import must add its own selected permission, transaction, UID conflict and receipt surfaces; no import race or interoperability claim follows from storage conversion.

## Migration and alternatives

Generate model/client/migration metadata with the pinned SDK. The generated table-recreation SQL would lose existing active data; replace only migration.sql with the permitted necessary in-place cast/backfill/index/JSON transformation, preserving identity, audit, revisions, content and protocol state. Keep final fields/constraints/indexes equal to generated definition.sql and test populated/fresh databases. Promote the already-resolved crypto 3.0.7 to a pinned direct dependency.

Flattening categories, dropping CONTACT/PERIODs, parsing source UIDs as UUIDs or resetting source versions contradicts confirmed decisions. A raw-file shadow would become stale after native edits. A unique unbounded text B-tree key cannot cover all permitted UID lengths; use indexed candidates plus exact locked equality. Replacing all native metadata DTOs is unnecessary where existing positional comments already preserve the profile; maintain explicit, unambiguous alternatives instead.

## Validation and remaining work

Require focused mapping/lifecycle/core-adaptation regressions, populated/fresh migration checks, real policy/retention/deletion tests, long Unicode UID and injected candidate-index collision checks, two-host generated-client projection and full repository validation at batch completion. Record actual commands/results in [validation](../scaffold-validation.md), distinguishing transient failures and final results. No generated source is hand-edited.

This extends ADRs [0060](0060-availability-publication-metadata.md)/[0061](0061-availability-protocol-lifecycle-and-envelope-duration.md) for these scoped storage/native behaviors. Authenticated whole-file import is next; source updates/reconciliation, authorized serialization/publication, scheduling and external-client evidence remain pending. Detailed mechanics remain reviewable in the draft PR rather than being accepted merely by merging documentation.
