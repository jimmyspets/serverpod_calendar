# ADR 0074: Authenticated availability export

Status: **Accepted explicit-selection/all-or-nothing product choice; concrete API/serialization mechanics implemented for draft review**. Date: 2026-10-22.

## Decision

After create-only import under [ADR 0073](0073-authenticated-create-only-availability-import.md), the maintainer selected explicit definitions from one calendar, rejecting the whole export if any selected member is unavailable or unauthorized. Implement a standalone authenticated availability export, independent of HTTP feeds and scheduling. Use current stored component state rather than an imported raw file.

The request identifies the actual calendar with its expected revision and 1–64 definition UUID/revision pairs. Require independent `exportAvailability` permission for the actual parent and each selected definition, plus `readAvailability` for every member. This permits hosts to restrict bulk/interchange disclosure separately from ordinary raw reads. The immutable `availabilityExport` host context contains the complete current selection, actual source/parent identities, source UIDs, content, retained timing overrides and component versions. It is absent only on the cheap initial parent check. Reauthorize after serialization, return no partial bytes and never derive the selection from a visibility-filtered list. Missing, deleted, foreign or mismatched selected objects fail without exposing another object's data.

## Current-state projection

Generate one deterministic UTF-8/CRLF VCALENDAR from the selected stored VAVAILABILITY/AVAILABLE components. Preserve supported metadata groups/annotations/CONTACT/private properties, source UIDs, timestamp/SEQUENCE omissions, end-versus-duration meaning, RRULE/RDATE/EXDATE/PERIOD and single/future timing components. Sort definitions by protocol UID and named zones by exact identifier. Never serialize native API identity fields or API revisions. An independently stored protocol UID can have the same spelling as a native UUID. Calendar/feed presentation and source VCALENDAR envelope syntax are separate; use a module PRODID and Gregorian scale, without implying an original-file archive.

Generate needed VTIMEZONE offset evidence from pinned IANA data across the existing calculation-only UTC [1969-12-31, 2100-01-02) horizon. Preserve actual IANA daylight/standard flags, including negative daylight saving; do not infer labels from offset increases. A seed establishes the initial offset, and grouped explicit DTSTART/RDATE onsets cover subsequent changes. No indefinite future RRULE or regenerated payload edit is introduced. Revalidate the whole generated calendar against the existing full-horizon import profile and aggregate budgets before returning bytes. This does not widen ordinary storage beyond [1970-01-01, 2100-01-01).

## Explicit limits and alternatives

The wire profile remains narrower than native capability. Reject, rather than discard or rename, native skipped-occurrence state that retains restoration timing, timing components without a stored version checkpoint, duplicate opening source UIDs across selected definitions and states exceeding aggregate wire/zone/metadata/recurrence/output limits. Some definitions therefore export individually but cannot be combined in one file. Do not flatten recurrence, turn native skips into lossy EXDATE values, fabricate protocol history or rewrite UIDs to force acceptance.

Ordinary export is a read: no scope generation, API revision, protocol stamp or database audit time advances. Current installed private-extension validators govern emitted data; failures are value-free. Organizer data is exported as stored metadata, not newly approved ownership or scheduling authority. Hosts receive it in current snapshots and can restrict disclosure through export/read decisions. No organizer write approval, network lookup, feed URL, invitation or alarm activation follows export. External authorization retains its documented after-check race; the scope transaction coordinates stored data, not an external ACL service automatically.

No schema change/reset is needed. Future pre-beta breaking changes remain authorized. Source updates/reconciliation, other component import/export, feeds, scheduling and external-client compatibility remain separate.

## Evidence and sources

See [the export guide](../availability-export.md) and [validation record](../scaffold-validation.md) for scoped checks. Protocol references: [RFC 5545 VTIMEZONE](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.5) and [RFC 7953 component definitions](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1). These specify wire semantics, not host permission or transaction design. Concrete mechanics remain under draft review.
