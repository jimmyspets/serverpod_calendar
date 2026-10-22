# ADR 0071: Create-only availability import and storage prerequisites

Status: **Accepted product choices; storage/API/migration mechanics proposed**. Date: 2026-10-22.

## Confirmed decisions

After [ADR 0070](0070-availability-wire-metadata.md), the maintainer selected create-only authenticated availability import, rejecting existing protocol UIDs rather than updating/reconciling source data. On 2026-10-22 they confirmed:

1. Extend native storage first to preserve the full supported wire profile, including repeated metadata groups, CONTACT, arbitrary text UIDs and PERIOD additions; do not narrow the initial import to existing native shapes.
2. A UID conflicts with an existing active definition in the destination calendar. The same source definition may be copied into separate calendars while native API UUIDs remain distinct.
3. Retain source SEQUENCE, DTSTAMP and optional CREATED/LAST-MODIFIED as the initial protocol version. Record database import time and API revision separately; native changes subsequently advance protocol state and absent source dates are not fabricated.
4. Require a separate host import permission in addition to creation permission for every definition. Hosts can map both permissions to the same rule.
5. Keep a stable server-generated native UUID for each opening and store its iCalendar UID separately as text. Native occurrence-edit references remain UUIDs.

These decisions authorize the prerequisite storage work, not every proposed physical model or API detail below. This documentation is not an implemented import or migration. Existing whole-second/Gregorian/named-zone/profile constraints remain unchanged.

## Context and proposal

Current native storage uses UUID protocol UIDs, one category group, no CONTACT/PERIOD inclusion storage and local-clock protocol invariants. The pure adapter accepts broader supported shapes. Copying only the representable fields would lose data; storing an old raw file beside mutable native state would not ensure correct current export.

The [storage/import contract](../availability-import.md) proposes distinct native/protocol opening identities, typed repeated metadata and availability-specific PERIOD storage, source component metadata, imported protocol lifecycle, destination UID conflict lookup and data-preserving upgrade paths. It proposes full-file atomic import with separate import/create rights, actual parent/proposed-state host context, current organizer/extension checks and declared policy guarantees. No source metadata grants authority or causes delivery/network actions. CONTACT stays import-only and survives ordinary edits.

Long text UIDs need an exact, bounded lookup strategy; a direct unique B-tree text index may reject adapter-supported lengths. The proposed digest candidate index plus exact comparison under the durable scope lock must be reviewed and proven across all writers/instances, including distinct UIDs sharing a digest. Digest equality alone must never identify or merge objects.

Source protocol times are not local audit history. The contract proposes retaining missing/independent source values, then applying nondecreasing whole-second native stamps and significant-change SEQUENCE without conflating API revision. Affected master/override lifecycle mechanics, request/result shapes, opening caps and physical schema/constraints remain review gates. It extends the proposed future storage boundary of ADRs [0060](0060-availability-publication-metadata.md)/[0061](0061-availability-protocol-lifecycle-and-envelope-duration.md), without claiming their existing runtime changed.

## Alternatives and consequences

A narrower import is simpler but rejects selected supported source shapes; the maintainer chose storage extension instead. Host-wide UID uniqueness prevents legitimate separate-calendar copies; the maintainer selected destination-calendar conflicts. Resetting protocol versions loses source lifecycle information; separate database audit times preserve the distinction. Silent merge, flattening or dropping fields is not an alternative.

Storage migration, generated client/host/editor adaptation, authorization snapshots and calculation mapping must be completed together in the first implementation batch. Add import only after those prerequisites pass their focused and broader checks. Existing bounded query failures remain explicit unknown/failure, not manufactured free time.

## Acceptance and sources

Review the linked contract's models, migration and lifecycle mechanics before schema changes. Require populated/fresh upgrades, no-loss metadata/period/identity mapping, actual native-edit retention, host-boundary and rollback tests, long UID/digest-collision tests and two independent host races. The following import batch must add real generated-client/Flutter journeys and complete atomicity/current-policy evidence. Updates/reconciliation, authorized export, feeds, scheduling and external-client compatibility remain pending.

Primary sources: [RFC 7953](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1), [RFC 5545 UID/version properties](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.7) and [Serverpod model documentation](https://docs.serverpod.dev/concepts/data-and-the-database/models), checked 2026-10-22. Standards supply protocol semantics, not approval of the proposed physical schema, transaction or endpoint contracts.
