# ADR 0118: Scheduling reply status and payload metadata

Status: **Selected first-release properties; concrete pure-profile mechanics proposed for review**. Date: 2026-10-26.

## Context and scope

ADR 0117 implements the approved pure four-method, non-recurring message boundary. The RFC scope already selects REQUEST-STATUS, PRIORITY, GEO and RESOURCES; that first slice explicitly rejected them. Implement their bounded pure message codecs together before extending message recurrence. No new table, migration, endpoint, identity mapping or scheduling transition is proposed.

The primary property definitions are [RFC 5545 sections 3.8.1 and 3.8.8.3](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.8.3); [RFC 5546's per-method tables](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2) determine scheduling placement and cardinality. Ordinary event/task source adapters are not expanded by this increment.

## Proposed bounded representation

REQUEST-STATUS is accepted only in REPLY, with at most 32 source properties. Each retains its exact numeric code spelling, immutable two/three numeric levels, decoded description, optional decoded extra data and optional LANGUAGE. Bound each numeric level to a nonnegative signed-32-bit magnitude, code spelling to 32 characters and each text component to 4,096 code points. Preserve absent versus empty extra data, source ordering and escaped separators. Unrecognized numeric codes remain uninterpreted source data; they never establish success, retry policy, trusted authority or an automatic response.

PRIORITY is an independently optional integer 0–9. Its omission remains absent rather than being replaced with zero. GEO is independently optional, with signed decimal latitude/longitude and exact range checks. Retain both decimal spellings without rounding, cap each at 64 characters and expose approximate doubles only as a convenience. Coordinate precision is unrelated to whole-second calendar precision. No maps or geocoding follow.

RESOURCES preserves repeated scheduling source groups, comma-separated decoded text, LANGUAGE and ALTREP. Cap groups at 32, combined values at 64 and each label at 4,096 code points. Empty labels and original spelling remain data, not host resource identifiers or reservations. URI annotations remain inert. This scheduling cardinality follows the RFC 5546 method tables; it is not a blanket change to ordinary component cardinality.

Existing aggregate event-metadata and syntax budgets also apply. Unknown/custom parameters reject rather than being discarded. The serializer re-emits validated source values and groups, with deterministic physical folding. No native editor, host identity adoption or database import mapping is introduced.

## Alternatives and consequences

Flattening groups or normalizing decimal/status-code spelling loses source distinctions. Treating a received status as an executable retry instruction crosses the untrusted-source boundary. Extending canonical database storage at the same time would require a separate model/authorization review. Keeping this batch pure adds useful message coverage while retaining those boundaries; recurrence, delegation and durable scheduling remain separate work.

## Acceptance

Test method-specific rejection, repeated/escaped statuses, absent/empty data, numeric and precision boundaries, exact coordinate range comparisons, resource groups/annotations and immutable values. Test parameter/cardinality/input/aggregate-budget failures and unchanged standalone rejection. Run focused development tests, then broader wire/core and directly affected regressions before one feature-batch check-in. Record the actual checks and remaining release gates without claiming full RFC conformance, native storage, scheduling transitions or email delivery.
