# ADR 0107: Read-only event source metadata

Status: **confirmed source-first scope, independent source-read permission and bounded task-style occurrence policy; mechanics under draft review**. Date: 2026-10-24.

## Confirmed scope

Preserve VEVENT CLASS, URL and separate CATEGORIES/COMMENT/CONTACT source groups with legal LANGUAGE/ALTREP annotations. Ordinary native event edits retain these values; native metadata editors follow separately. Reading/exporting rich source metadata requires independent host source-read authority. Like the existing VTODO profile, omitted occurrence metadata inherits, while explicit values must match the master; differing occurrence metadata rejects until its own profile is designed. Source labels do not grant access, resolve identities, fetch links or trigger contact/mail actions.

## Proposed representation and boundaries

Use immutable server-only metadata/text/category-group DTOs in existing event JSON: optional master metadata in protocol state, optional own metadata on single/future overrides. Nullable override fields use Serverpod's per-field serverOnly scope, plus explicit detail filtering and metadata-only-node suppression. Verify generated client/protocol serialization and database persistence rather than inferring either from class visibility. No new table columns are proposed. Metadata-only originals remain in membership/orphan validation and preserve timing inheritance when an explicit timing edit is cleared. Such inherited timing still rejects lossy export. Native selected-text/timing/lifecycle commands preserve source metadata and component history; it remains independent of host authority and ordinary content disclosure.

Add readEventSource to export and replacement source-read checks, including final/retry/no-op paths, regardless of whether a particular series currently has metadata. Create-only import keeps existing import/create/lifecycle gates. Current complete host proposals include metadata, never historical baselines. Extend canonical source comparisons with normalized metadata; existing v2 baselines without these nullable values remain compatible rather than inventing metadata/history.

The bounded profile accepts HTTP/HTTPS URLs without embedded credentials, standard PUBLIC/PRIVATE/CONFIDENTIAL labels, at most 64 category values and 32 each COMMENT/CONTACT per component, preserving groups/order/annotations. Omitted CLASS retains source absence (RFC effective default PUBLIC); explicit occurrence PUBLIC can match that default. Other valid but unprofiled values/parameters reject explicitly. Add a shared whole-file metadata code-point budget (65,536) in pure wire/native source validation. No source metadata implies native ownership, scheduling, publication or network activity.

## Evidence and acceptance

RFC 5545 [VEVENT grammar](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1), [classification](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.3), [comment](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.4), [contact](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.2) and the existing task profile supply the property/cardinality baseline. [Serverpod model visibility](https://docs.serverpod.dev/concepts/data-and-the-database/models#limiting-visibility-of-a-generated-class) documents nullable per-field scope; the pinned generator must verify it locally. This is a stricter bounded application profile, not blanket RFC conformance.

Test source grouping/annotations/omissions, explicit occurrence matching/differences, raw protocol privacy, immutable storage/host contexts, edits/clear/transfer/orphan preservation, versions/baselines/no-op/conflicts, authorization before classification and after serialization, complete import/export/replacement atomicity, budgets/negative fixtures and no retrieval. Extend generated-client/two-host/Flutter example evidence, run focused checks during development and broader checks before the single batch commit. Keep CI and external-client evidence separate.
