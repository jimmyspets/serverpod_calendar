# Pure finite-suffix publication projection

[ADR 0188](adr/0188-published-whole-series-lifecycle-with-active-range.md)
approves a pure projection of a claimed active REQUEST into a finite suffix of
publication-only EXDATE values. It retains the source, earlier components and
source exclusions, and reports detached generated original identities and
suppressed source components. The cutoff is an original DATE/UTC/exact-zone
identity, not an exception's moved start. COUNT and UNTIL rules must be proved
finite within the supported horizon and existing shared-work and wire limits;
unbounded, incomplete or over-limit input rejects without a partial result.

The helper proves no publication history, authority, source-exclusion provenance
or recipient behavior. It allocates no outgoing versions and changes no
database, worker or runtime guard. A later durable design must independently
establish those facts and distinguish its own masks from source EXDATEs. In
particular, an excluded cutoff cannot be reconstructed from its exclusion.
Pure validation does not establish external-client handling of old exceptions.

The focused VM suite covers DATE, UTC and exact named-zone aliases, spring gaps
and autumn folds, COUNT/UNTIL, source exclusions, RDATE/PERIOD, components
moved across the cutoff, DTSTART/final cutoffs, retained versions, immutable
results and bounded failure paths. The complete module unit suites passed
locally: 815 VM tests and 31 Chrome tests, before the last three focused cases
were added. The complete 21-test focused suite passed after those additions.
Workspace analysis also passed before the last three test-only additions. The new projection tests are VM-only;
the Chrome count covers other browser-compatible module tests. Full repository
and hosted readiness remain separate, including the known 4.1.2 feed failure.

On 2026-11-28, the merged stack at `f6c2994` passed all 29 focused VM cases
across `published_finite_suffix_projection_test.dart` and
`exceptional_range_proof_test.dart`. These tests exercise the existing
projection and proof. The proposed durable v9 reader and restoration bridge
still require review and validation under [ADR 0189](adr/0189-whole-series-lifecycle-with-published-cutoff.md).
