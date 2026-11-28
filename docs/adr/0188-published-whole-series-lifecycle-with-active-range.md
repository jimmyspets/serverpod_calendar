# ADR 0188: Published whole-series lifecycle with an active range cancellation

Status: **The pure bounded projection was explicitly approved by the maintainer; scoped implementation is available for draft review.** Durable lifecycle mechanics remain a draft and require separate approval. Validation and readiness are recorded separately in [the implementation guide](../published-finite-suffix-projection.md).

## Context

Accepted [ADR 0172](0172-durable-published-range-controls.md) requires restoring
an outgoing range cancellation before whole-series cancellation or reopening.
Accepted [ADR 0187](0187-durable-exceptional-range-controls.md) extends which
anchors can be restored, but keeps that lifecycle guard. The current write path
rejects a new whole-series command when the last checkpoint has an active range;
exact retained retries are handled separately. Removing that guard alone would
lose range proof because the existing checkpoint carry operation also rejects
an active control.

## Proposed product policy

Allow an explicit whole-series Cancel and notify while a published suffix is
cancelled. Preserve the suffix cancellation, individual cancellations, their
provenance and newer unpublished native edits. A subsequent explicit reopening
must retain the suffix cancellation; only the separate range-restoration action
may clear it. The source of reopened values is the last published active basis,
never the newer private draft. A whole-series cancellation is an intentional
complete-UID supersession and may supersede pending deliveries under the
existing whole-series policy; it does not assert that a recipient received them.

## Proposed first batch: pure finite-suffix projection

Add a pure helper operating on an immutable, already decoded supported active
REQUEST bundle and an exact original cutoff. The input is a claim: the helper
does not prove publication, cancellation provenance, authorization or recipient
state. Require one recurring master, supported source components and exact
DATE/UTC/named-zone identity. Reject unsupported shapes, orphaned or
ambiguous original identities, incompatible profiles and a cutoff that is not
a member of the source recurrence set.

Require a rule with COUNT or UNTIL and prove complete enumeration within the
ordinary supported horizon. Generate original identities, including explicit
RDATE/PERIOD starts, in original order before applying the selected suffix
mask; retain existing source exclusions distinctly. An earlier explicit
inclusion stays visible when it precedes the cutoff. Never infer completeness
from a query window, assume an unbounded rule ends at 2100, or silently drop an
out-of-profile or work-exhausting occurrence.

Create one REQUEST candidate by retaining the master rule, inclusion data,
source exclusions and earlier supported occurrence components, adding
publication-only EXDATEs for every otherwise included original at or after the
cutoff, and omitting explicitly supplied components at those suppressed
originals. Preserve the unmodified source and return an immutable manifest of
generated exclusions and suppressed components alongside the candidate.
Identities are original civil identities, not moved starts. Source EXDATEs and
independent cancellation masks are inputs whose provenance a future durable
caller must establish; this helper does not reclassify either as a new mask.
If an independently cancelled cutoff was masked from the supplied basis, the
caller must supply a separately validated unmasked basis; the helper must not
guess the hidden occurrence from the exclusion itself.
The candidate must round-trip through the existing scheduling codec and remain
within its existing raw input, explicit-date, property, component, byte and
shared recurrence-work limits. Any incomplete proof or limit failure rejects
the entire operation. Source SEQUENCE/DTSTAMP values are placeholders: the
helper allocates no outgoing versions and performs no database write.

The generated EXDATE projection is a proposed application profile based on
[RFC 5545 EXDATE](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.1)
and the existing [ADR 0130](0130-preserved-cancellations-reopening.md)
individual-mask approach. Pure round trips do not prove that external clients
remove old detached exceptions. The helper must not claim such interoperability.
Unbounded series and any finite suffix too large for the existing budgets stay
rejected; an ordered REQUEST/range-CANCEL delivery group remains separate.

## Durable mechanics requiring further design

Reopening must provide a faithful complete supported REQUEST that keeps every
original from the cutoff suppressed, including later exceptions, while
preserving ordinary source EXDATEs and separately cancelled originals. A finite
suffix might be representable with publication-only exclusions, but an
unbounded suffix cannot be represented that way within existing budgets. It is
not yet established that the current message profile and target clients can
faithfully represent every case in a single message. An alternative ordered
REQUEST and range-CANCEL group needs a shared generation, durable ordering,
partial delivery and retry contract. Neither alternative is selected here.

Any implementation needs self-contained bounded checkpoint evidence for the
pre-cancellation published basis, active cutoff, independent cancellation
ledger and exceptional-anchor proof, without recursive predecessor growth or
unreviewed retention expansion. It must define how actual master/component
versions advance through cancellation and reopening, how effective attendee
replies resolve while the suffix stays cancelled, and how workers fence and
reauthorize the exact immutable outgoing messages. The existing native-cutoff
ownership rule must continue to protect unrelated revisions and private edits.

## Pure-batch acceptance

Test DATE, UTC and exact named-zone identities, DST gaps and folds, COUNT and
UNTIL, explicit earlier and later RDATE/PERIOD inclusions, source exclusions,
cutoff at DTSTART or the last original, and exceptions moved across the cutoff.
Verify output recurrence membership, omitted suffix components, unchanged
source and immutable manifest, stable text/version values and parse/serialize
round trips. Test unsupported input, unbounded and beyond-horizon rules, missing
cutoffs, exhausted shared work, explicit-date/component/byte limits and no
partial output. Run focused tests while developing, then the affected package's
VM and Chrome suites, formatting and analysis. No endpoint, SQL, worker,
native mutation or Flutter change is part of this batch.

## Acceptance work before durable approval

Complete a concrete message/projection and checkpoint proposal, identify exact
representability and capacity limits, and define atomic transactions,
authorization, retries and process-loss recovery. Validate COUNT/UNTIL and
unbounded series, source and module-generated exclusions, exceptional anchors,
individual cancellations, moved/PERIOD exceptions, exact zones and DST. The
eventual batch must include focused tests, competing hosts, delivery recovery
and the Flutter example. No SQL expansion, real mail or external-client
compatibility follows from this draft.

The maintainer explicitly approved the pure-batch contract. Any later durable
lifecycle contract requires separate review.
