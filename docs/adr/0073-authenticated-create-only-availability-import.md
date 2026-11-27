# ADR 0073: Authenticated create-only availability import

Status: **Accepted product scope under ADR 0071; concrete API/transaction mechanics implemented for draft review**. Date: 2026-10-22.

## Decision and implementation

Use the source-preserving representation from [ADR 0072](0072-source-preserving-availability-storage.md) in one authenticated create-only operation. The maintainer authorized this next implementation batch. `CalendarAvailabilityImportRequest` contains the actual destination calendar UUID, expected calendar revision and `ByteData` input. It accepts no actor, scope, registry, native identity or authority claim. `CalendarAvailabilityImportResult.receipts` contains only final host-approved minimal mutation receipts, with no total or hidden-member placeholders. A successful response means the entire file committed, including members whose receipts are withheld.

Require `importAvailability` separately from `createAvailability` for every member. A cheap pre-parse import check has no proposal; subsequent preliminary/final requests carry the complete immutable batch, actual parent snapshot, allocated definition/opening UUIDs, source UIDs, validated content, retained timing edits and protocol states. Dedicated organizer and installed private-extension validation run at both content-write phases. Chunking respects the configured policy batch size. Existing declared coordinated/fresh-check guarantees apply; final external checks do not eliminate the after-check revocation race.

Parse one complete bounded standalone availability calendar outside the write transaction. In the durable scope transaction, reload the destination, recheck expected revision, all authority, exact destination-active UID equality and aggregate destination capacity before insertion. The shared scope lock coordinates native creation, import, deletion and parent deletion across host processes. Digest matches only narrow candidates; exact text equality decides conflicts. Failures roll back all rows and generation. Commit starts native revisions at 1 and advances scope generation once; parent calendar metadata/revision remains unchanged. Source protocol versions remain separate from database audit time. No import update, scheduling, alarms, delivery, export or feed is triggered.

## Limits, failures and example

Retain the existing strict UTF-8/CRLF/Gregorian/whole-second/full-horizon zone profile and wire budgets: 1 MiB decoded bytes, 64 definitions, 128 raw opening components, 64 overrides per series, shared parser/candidate/metadata limits. Destination capacity is 64 active definitions. Serverpod/host HTTP body limits also apply before this decoded-byte limit; hosts must account for JSON/base64 overhead when selecting transport limits. Oversized transport may reject before the module executes.

Map syntax/profile errors to value-free `validation`, exhausted budgets/capacity to `limitExceeded`, existing active UID to generic `dependencyConflict`, stale parent to `staleRevision`, policy denial to `accessDenied` and policy/extension failures to `unavailable`. Responses contain no conflicting UUID, UID, content or count. A retry reauthorizes and conflicts with still-active UIDs; there is no request-key recovery or exactly-once promise.

The example paste screen explicitly converts text-area newlines to CRLF; the module byte API does not repair malformed input. It obtains a parent revision, preserves input after rejection and requires reopening after staleness. Synthetic example loading and duplicate rejection are exercised through the generated client.

## Pre-beta evolution

The maintainer explicitly permits breaking APIs/schema changes requiring a fresh database before beta. Future batches may choose clean models and document development/test resets instead of preserving unpublished compatibility. This batch needs no schema change or database reset. Committed historical migrations and decision evidence remain intact; authorization is not permission to erase an unidentified database.

## Validation boundary

See [the import guide](../availability-import.md) and [validation record](../scaffold-validation.md) for commands/results. This implements the selected availability import profile only. Source reconciliation, authorized export, other component import, HTTP feeds, scheduling and external-client interoperability remain separate work.
