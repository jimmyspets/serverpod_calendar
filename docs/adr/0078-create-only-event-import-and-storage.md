# ADR 0078: Create-only VEVENT import and storage prerequisites

Status: **Accepted scope, identity, source-version, permission, default-status, private-baseline and source-normalization, native version/annotation retention and legacy initialization choices; schema/API mechanics proposed**. Date: 2026-10-22.

## Confirmed choices

After [per-calendar VFREEBUSY output](0077-privacy-safe-calendar-freebusy-export.md), the maintainer selected VEVENT import/export next, starting with a contract and storage prerequisites:

1. Extend storage to preserve the current supported event-component profile before adding the import endpoint: text protocol UIDs, PERIOD additions, text annotations and independent master/occurrence versions.
2. First import creates new event series only. Exact protocol UID conflicts concern active events in the destination calendar; copies in another calendar remain independent native objects. Updates and scheduling reconciliation follow separately.
3. Retain source SEQUENCE, DTSTAMP and optional CREATED/LAST-MODIFIED, including omissions, independently of API revisions and database audit time. Source values establish neither authority nor freshness.
4. Require a separate host import permission plus creation permission for each series. Cancelled masters or single-occurrence components additionally require lifecycle authority.
5. Omitted source STATUS uses CONFIRMED as an explicit native application default while retaining source omission for export. This does not assert an RFC default.
6. Record one private normalized source baseline inside each imported event's active-data row from the first import. Ordinary views/exports omit it; deletion scrubs it. This prepares future conflict detection without implementing updates or adoption.
7. Preserve decoded event components and their source distinctions, while future export regenerates calendar presentation and zones from pinned data. Original PRODID, unused zones and timezone names/comments/URLs are not retained. Exact source-document preservation is separate scope.
8. Every actual saved component change is significant, including metadata. Identical normalized saves retain protocol timestamps/SEQUENCE; accepted native writes keep their existing API-revision behavior. Changed native components use nondecreasing whole-second protocol timestamps.
9. Native text edits retain LANGUAGE/ALTREP until an explicit authorized change or clear. The example must make retention/editing clear.
10. Existing native events initialize a documented local protocol checkpoint from known database audit times with SEQUENCE 0. Existing occurrence components omit CREATED because actual creation times are unknown. No imported baseline or source history is invented.


## Proposed implementation order

[The event import contract](../event-import.md) maps actual storage gaps and records review gates. First implement source-preserving event storage, validators, native-edit retention, projections, populated/fresh schema checks, and generated-client/Flutter adaptation. Then add authenticated full-file create-only import. Authorized export follows independently; no feed, scheduling method, mail or alarm activation follows from source identity or parsing.

Keep existing native UUID/actual-parent/revision/deletion rows. Propose text protocol UID plus a non-unique fixed-size candidate digest and exact destination-scoped comparison under the durable scope lock. Separate source component versions from audit time, and preserve PERIOD geometry/original identities and property presence/annotations. The private import baseline is not a substitute for current protocol state, a historical file store or an authority grant. Unknown canonical profiles must fail closed when a future update operation is designed.

Exact per-component transition mapping, field-group disclosure, typed model layout, index placement, DTOs, comparison limits and migration details remain proposals. Do not treat this document as approval of every physical field or as implemented event import. Breaking pre-beta schemas/reset requirements are authorized, but any reset must identify development/test targets; no reset is required or performed by this documentation batch.

## Consequences and acceptance

A narrower import would reject source shapes already supported by the pure adapter; the maintainer selected storage extension. Global protocol-UID uniqueness would prevent legitimate separate-calendar copies. Resetting source versions or conflating STATUS omission with an explicit source property would lose selected distinctions. Full original-file retention would require a different privacy/lifecycle boundary and is not selected.

Require no-loss component conversion, long UID/digest-collision handling, native edit retention, independent permissions/disclosure, full rollback, complete free/busy/preview semantics, bounded work, two independent hosts and generated-client/Flutter evidence before claiming implementation. Keep the current whole-second [1970,2100) profile and full-horizon known-zone validation. Detailed schema review precedes model/migration changes. Preserve earlier accepted decisions and distinguish native behavior, wire acceptance and client interoperability.

Sources: [RFC 5545 VEVENT](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1), [UID](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.7), [change-management properties](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.7), and the implemented pure profiles in ADRs [0065](0065-first-vevent-wire-adapter.md), [0067](0067-vevent-period-additions.md) and [0068](0068-vevent-occurrence-components.md). Standards define source semantics, not this repository's authorization, identity-conflict or transaction policy.
