# ADR 0119: Recurring iTIP message boundary

Status: **Detached scheduling components approved by the maintainer on 2026-10-26; concrete pure-profile mechanics under draft review**. Date: 2026-10-26.

## Context

The pure four-method message and payload increments under ADRs 0117–0118 have scoped local validation. Recurring scheduling is selected first-release work, but ordinary import's requirement for a matching master in the same file must not be assumed to be a scheduling decision.

[RFC 5546](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2) permits occurrence identity in scheduling methods; its examples include an instance cancellation without a master in the message. A pure parser has no stored event against which to verify that identity. Treating successful parsing as proof of occurrence membership would cross the later reconciliation boundary.

## Recommended next batch

Extend only the existing pure PUBLISH/REQUEST/REPLY/CANCEL adapter to recurring event messages, preserving the current method restrictions and payload fields. No database schema, endpoints, host identity directory, inbox/outbox, native mutation or mail delivery is included. Other selected methods and VFREEBUSY remain subsequent increments.

Represent the immutable envelope separately from its event-component list, with independently preserved source versions, fields and omissions on every component. Breaking the unpublished pure API is permitted; never keep an ambiguous convenience accessor that silently selects one component. Initially require one exact source UID throughout a message, including PUBLISH as a documented narrower profile, with at most one master. Bound total components and overrides using existing component limits, with duplicate original/range identities rejected. Preserve source identity rather than generating a native UUID or publication UID.

Reuse the implemented master RRULE, start-valued RDATE/EXDATE and timed PERIOD profile, typed DATE/UTC/named-zone values and pinned full-horizon zone validation. Recurrence patterns require an explicit DTSTART in this initial profile; a minimal reply/cancellation can still omit timing. Unsupported or over-budget data rejects as a complete message. Do not widen calendar dates or precision.

Parse RECURRENCE-ID and the profiled RANGE value without retargeting original identity or applying an occurrence/range edit. Named-zone original identities require validated zone evidence even when DTSTART is omitted. Master and instance components retain their own optional text, timing, status, participant and version values; omission is source data, not an automatic host-state inheritance command. Source future cancellation does not implement native future cancellation.

## Confirmed detached-instance boundary

**The maintainer approved detached occurrence components without a master in the same message.** Validate their envelope, method, source identity syntax, typed values and internally checkable constraints. Expose them as untrusted components; do not claim existence, recurrence membership, current version, participant authority or native representability. Later authenticated reconciliation must resolve and verify the actual stored series before any mutation, reply or outbound intent. Merely knowing a UID never grants lookup or write access.

When a master is supplied, use available source context for checks the bounded profile can establish; do not invent missing master content for detached input. Do not provide an availability/occurrence projection from an unresolved scheduling message. Ordinary authenticated file import continues requiring its matching master and retains its existing conflict behavior.

Alternative: initially require a matching master in every recurring scheduling message. This reuses more standalone validation but rejects legitimate detached updates/replies/cancellations, including common instance-cancellation messages. Supporting them would remain mandatory later; no silent fallback to ordinary import is acceptable.

## Acceptance and limits

Test recurring DATE/UTC/named-zone masters and additions/exclusions, per-component versions/omissions, detached identities, missing/mismatched zone evidence, UID/cardinality/duplicate constraints, RANGE preservation, malformed input and shared work/output budgets. Test ordinary import and feed regressions separately. Parsing cannot establish replay ordering, stored membership, external sender trust or interoperability with scheduling clients. Durable reconciliation and its model/authority/retention review follow separately.

The detached-component choice is confirmed for this next pure-message batch. Other profile mechanics remain draft review material and must be recorded with actual implementation evidence.

## Scoped implementation

The [message guide](../itip-message-profile.md) documents the implemented envelope/component split, recurrence profile, source-only original/range identities, one-UID/cardinality limits and explicit lack of stored-membership proof. The unpublished API now returns `message.events`; versions and optional fields belong to each `IcalendarSchedulingEvent`. Patterns require a start; overrides cannot also define recurrence patterns. Known incoming profiles are checked, but an original outside an incoming master's rule is not treated as proof of invalid stored membership. Focused tests passed; selected broader checks passed. No database or ordinary-import behavior is changed by this implementation.
