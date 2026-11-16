# Durable exceptional-range controls: validation in progress

ADR 0187 is approved and its scoped implementation is available for draft
review. The batch is not release-ready: the full 4.1.2 check reaches an
independent feed 304 failure, and exact-head hosted validation remains open.

Focused checks performed on synthetic data:

- The exceptional-range proof unit suite passed eight tests, including rejection
  of changed content, missing trusted versions, altered masks, corrupt proof
  and exhausted shared work, oversized input and more than 64 masks.
- The final example-host scheduling integration selection `durable exceptional
  range` passed 28 tests against isolated PostgreSQL and Redis services.
  These covered multiple individual cancellations, an individually cancelled
  anchor, moved DATE/UTC/zoned anchors, retries, repeated cancellation and
  restoration, source-only exclusions and omitted optional text.
- A separate 4.1.2 database regression verified final host-authorization
  denial rolls back publication and native state for cancellation and
  restoration, and exact retries reauthorize both actions.
- Ten exceptional cancellation/restoration checks independently denied each
  scheduling-read, event-read, source-read, lifecycle and action permission;
  every denial preserved the event and publication count.
- `dart run tool/scheduling_work_smoke.dart --exceptional-range` passed on
  two independent 4.1.2 hosts with a retained reset anchor, including actual
  process loss before and after cancellation and restoration commits. The
  surviving host recovered the same receipt with one publication intent.
- `dart run tool/scheduling_work_smoke.dart --exceptional-race-only` passed
  concurrent same-command cancellation and restoration on two hosts; each pair
  converged on one receipt and one publication. Different-command cancellation
  and restoration races also passed: one winner committed and the other was
  fenced without a second publication.
- After shared-work-budget and retained-reset fixes, 29 ordinary and
  exceptional range database tests passed on isolated 4.1.2 storage, including
  the independent permission and private-draft regressions.
- A further exceptional-range database test passed with a newer private draft:
  restoration published the retained values while preserving local content and
  timing state.
- A database corruption regression passed after changing the active proof
  digest and, separately, the restored checkpoint's frozen source version;
  both cases failed closed.
- Restoration also passed after terminal history pruning removed the earlier
  publication, leaving the latest exceptional cancellation as its proof source.
- An unbounded exceptional series was rejected without changing event state or
  adding a publication.
- A named-zone regression passed with the exact `US/Eastern` alias retained
  in the native original and serialized restoration components.
- A DATE series bounded by UNTIL passed cancellation and restoration at its
  final original occurrence while retaining its moved native exception.
- A timed series with a later PERIOD addition retained the addition's
  two-hour duration in native state and the serialized restoration.
- Named-zone recurrences passed spring-gap and autumn-fold restoration checks:
  the gap skipped its nonexistent generated time, while the fold retained its
  repeated-time original and the moved anchor.
- Sequence exhaustion rejected an exceptional cancellation without changing
  the event or allocating a publication.
- Authority withdrawal blocked both queued exceptional cancellation and
  queued restoration before any further synthetic transport submission.
- Route-change checks initially failed because the synthetic host changed its
  interactive resolver but still approved the old route at background
  dispatch. After its dispatch policy was corrected to model that change,
  cancellation and restoration both blocked without transport submission.
- An unrelated source EXDATE remained present in both native state and the
  serialized restoration after an exceptional cancellation cycle.
- Workspace analysis passed on 4.1.2, and focused analysis of the recovery
  fixture passed after its lint correction.
- The first connected Flutter attempt failed when the new scenario reused an
  anchor already occupied by a prior range projection. A revised journey uses
  a separate series; the focused connected browser retry passed on 4.1.2.

The complete repository check passed its database and two-host recovery stages
on 4.1.2 but failed at the independent feed 304 assertion before the full
browser journey. Exact-head hosted CI and release compatibility remain open.
No external-client or real-mail claim follows from the focused checks. A separate hosted check for the preceding
pure projection failed in the free/busy Flutter journey when a delivery was
still queued after the withdrawal interaction. A focused 4.1.2 retry first
reproduced a missed-action symptom, then passed twice after the test waited for
scrolling and asserted that its target was hit-testable; the original hosted
commit has not been rerun with that change. A full local check for that earlier feature passed, but began
before its last source adjustment and therefore is not exact-head evidence.
