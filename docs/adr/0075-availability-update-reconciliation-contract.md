# ADR 0075: Explicit availability replacement and conflict detection

Status: **Accepted product choices; baseline, API, schema and transaction mechanics proposed**. Date: 2026-10-22.

## Confirmed decisions

After [ADR 0074](0074-authenticated-availability-export.md), the maintainer selected:

1. Explicitly select existing definitions and expected API revisions, then atomically replace their complete supported contents. Unselected definitions stay unchanged; no missing definition is created or deleted. Mixed create/update and broader synchronization follow separately.
2. Reject an incoming replacement that differs from current locally edited data. No force-overwrite flow is included in this first batch.
3. Allow equal source SEQUENCE and reject values lower than the last accepted source version. Omitted SEQUENCE has effective value 0 for this comparison, while its omission remains preserved. Timestamps are retained metadata, not proof of source freshness.
4. Retain a native opening UUID when its exact protocol UID matches a current opening. Allocate UUIDs for new openings and remove openings absent from the explicitly approved full replacement.
5. Require an import baseline recorded by a previous import. Native-created or older imported definitions without one are ineligible until a separately designed adoption flow; do not guess history. Pre-beta development data can be reimported into fresh storage.
6. Identical authorized updates are true no-ops: retain API revision, database audit times, protocol state and scope generation. Changed replacements advance the API revision normally.
7. Require a dedicated host replacement permission in addition to import and applicable timing/metadata/occurrence-edit permissions.
8. Preserve incoming source timestamps and omissions exactly on authorized changed replacements, including regressions. Later native edits retain their nondecreasing rule relative to the newly accepted state; API revision remains concurrency control.

These choices authorize the contract, not every physical/model/permission-mapping detail below. Replacement is **not implemented** by this ADR. Existing create-only import and authenticated export remain unchanged.

## Proposed contract

[The update guide](../availability-update.md) proposes full-file/explicit-selection matching, server-owned canonical source baselines, conservative local-edit conflicts, exact UID/native-identity mapping, read/equality disclosure safeguards and preliminary/final host checks in one durable scope transaction.

Compare incoming source SEQUENCE to the **last accepted source** version, not the locally advanced current sequence. Equal SEQUENCE does not prove freshness, and a higher one never defeats a local-edit conflict or grants authority. This is an explicit replacement API, not automatic source discovery or a universal RFC reconciliation order. Source clocks can be unrelated to the local clock; do not use DTSTAMP/LAST-MODIFIED as a hidden tie-breaker.

A server-owned baseline must retain enough normalized source state for exact comparisons, independently of API revisions/audit time. A hash may accelerate comparison but is not the sole equality test. The initial proposal stores a bounded canonical component snapshot and a normalization-profile version alongside active data. It is comparison state, not a raw-file or user-visible history archive. Deleting a definition must scrub this retained content with the rest of its active payload.

## Alternatives and consequences

Mixed upsert/snapshot synchronization could create or delete objects unintentionally; the maintainer selected explicit replacements. Unconditional import overwrite loses local work; the selected first profile rejects conflicts. Reallocating every opening UUID invalidates native references; exact current UID matches instead retain identity. Comparing API revisions alone treats accepted native no-op saves as content edits; actual canonical-state comparison avoids that mistake. Using source timestamps or a large sequence as authority is not an alternative.

Baselines require new reviewed storage and create-import integration. Existing rows lack evidence and must not be silently marked clean. Fresh database requirements are permitted before beta, but an implementation must identify the reset target and document its effects; this documentation authorizes no reset. A lower source SEQUENCE rejects even if a source intentionally reset its counter; recovery/adoption remains separate. Equal-sequence changed data can be explicitly accepted on a clean, revision-matched target, so this profile does not claim to detect every stale external file.

Exact source replacement can reset the protocol timestamp baseline; the native-edit nondecreasing rule is not a global monotonicity promise across source replacements. Do not silently clamp incoming values or preserve an omitted field from an older source version.

No-op requests still parse, validate, authorize and check expected revisions/source versions. They do not clear a dirty baseline or replace known protocol history. Local changes that return text to its previous spelling can still differ through protocol versions or retained occurrence state; do not equate a matching summary with an unchanged definition.

## Review and evidence gates

Review the baseline's canonical fields/version, bounded retention, schema shape, source-only field protection, permission mapping, complete source/selection matching, component UUID remapping and no-op/changed receipts before implementation. Preserve committed ADR/migration history. Use pinned generation and focused tests, then full batch checks and a draft PR; do not hand-edit generated clients or migration metadata.

Required evidence includes true no-op and mixed-batch generation behavior, stale/wrong-parent/no-baseline/local-dirty rejection, equal/lower/omitted sequence cases, native no-op writes, actual native edits and restoration, exact opening identity reuse/removal/readdition, source omission/CONTACT/override retention, preliminary/final denial and registry/organizer failure, full rollback, two-host competing replacements/native edits/deletion, generated-client and Flutter journeys. Sources/UIDs never grant actor, organizer, membership or scheduling authority.

Protocol sources: [RFC 5545 revision properties](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.7) and [RFC 7953 component grammar](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1). They supply wire properties; the replacement, baseline and concurrency rules here are repository product/implementation choices. No CalDAV, iTIP availability-update transport, upstream fetching, source reconciliation runtime or external-client compatibility is established.
