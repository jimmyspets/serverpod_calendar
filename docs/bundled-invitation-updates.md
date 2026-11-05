# Complete bundled invitation updates

[Accepted ADR 0174](adr/0174-complete-bundled-invitation-updates.md) extends initial bundle adoption with component-aware review and explicit Apply for an existing active imported event whose stable link has `bundledRequest=true`. It does not enable updates before adoption, ordinary-link conversion, partial merging, component removal/reset, roster changes, CANCEL, participation responses or VALARM.

## Complete packets and independent versions

Every packet contains the master and every accepted occurrence component, with unchanged exact original/range identities, UID, organizer and attendee address roster. New supported components may be added within existing bounds. Validate the complete candidate and compare it against both the accepted baseline and any retained currently selected review bundle. An incomparable packet rejects as a whole; the module never chooses newer pieces from different messages.

Each component has its own `(SEQUENCE or effective zero, DTSTAMP)` ordering. A lower tuple rejects. Equal tuples require equal normalized component payloads, including source-presence distinctions and optional CREATED/LAST-MODIFIED. Changed content requires advancement. An omitted SEQUENCE stays omitted; it is not rewritten to zero. A higher SEQUENCE may carry an earlier source timestamp under this ordering, without changing database audit time. These conservative application rules do not claim to be universal RFC requirements.

A child-only update leaves the master version unchanged. Comparison uses source-owned fields rather than inherited effective text. A new component for an existing original must advance over its prior effective master/range/single version. For a newly introduced recurrence original, prove previous absence within the work budget and use the accepted master's tuple as the admission floor. Exhaustion never proves absence. DATE, UTC and exact named-zone identities retain the existing whole-second 1970–2099 profile.

Component ordering, envelope PRODID and folding do not create a component change. A semantic duplicate does not reactivate dismissed review. If its normalized source differs, a bounded inactive duplicate source row retains that actual normalized body and digest for exact ingress retries. Reusing the same ingress key with a different normalized body still rejects.

## Explicit application and authorization

`bundleApplication` returns a protected complete-update view and source-component version lists. `applyBundleUpdate` reuses the immutable invitation/source/link and expected revision tuple; `expectedOccurrenceRevision` must be zero. Older master/single/range application and all participation paths remain guarded for bundled links.

Independent host operations `readBundleApplication` and `applyBundleUpdate` supplement existing summary/source/link rights and native full event/source disclosure. Application also requires native import/replacement/edit authority and applicable metadata/status permissions. Hosts receive the complete immutable source, actual parent/link, accepted and incoming vectors, original current native/review snapshots, final proposed state and result. Read eligibility does not replace preliminary/final write authorization. Declared coordinated/external guarantees and the external after-check race remain unchanged.

Apply requires a clean entire series and matching invitation, calendar, event and application revisions. One scope transaction replaces the complete supported native series and private import baseline, updates the existing acceptance checkpoint/result, dismisses the selected review and advances normal event/feed/alarm generations. Native event identity, associations and personal alarm/action state remain intact. Receipt, dismissal and application send no participation message; no source alarm is armed.

## Retention and retries

The existing one-per-link application table is reused with `kind=requestBundle`. Its scalar source fields describe only the master; its full baseline digest binds every component. Master advancement is not required for a child-only update, and the master cannot regress below its creation tuple. No new SQL storage, nested history or larger cap is introduced.

The latest exact command reauthorizes and returns its immutable result without saving, clearing a newer review or overwriting local drafts. Result revisions and source/invitation identities must match that original command. A later application supersedes older update retries; the separate creation receipt remains stable. Deleted events are never recreated by retry.

Accepted bodies may expire while the private baseline/checkpoint remains valid. Views explicitly report unavailable historical source instead of inventing bytes. A surviving pending marker with a different expired body is unavailable because its component evidence is missing. Once normal retention removes that unaccepted marker, new review may be reconstructed from the surviving validated accepted baseline; expired unaccepted versions are not an indefinite hidden floor. Missing/corrupt accepted state fails closed. Parent deletion scrubs its active content/baseline and private alarm state through the existing deletion path.

## Example and validation

The synthetic-only example supplies complete child-only and mixed master/child MIME updates. Flutter shows accepted/incoming versions, raw selected source, stale-revision retries and whole-series local conflicts. It never treats source participants as host identities or silently merges changes.

Focused checks use the module's `invitation_bundle_update_values_test.dart`, example server's `bundled_invitation_updates_test.dart` and `dart run tool/invitation_work_smoke.dart --bundles`. The complete check script includes these alongside initial-adoption regressions. Complete local pure suites, 373 invitation/MIME integration tests, two-host commit-loss recovery, generated-client checks and the connected Flutter update journey passed. Stable generation and static checks are recorded in [validation](scaffold-validation.md). Exact-head hosted checks remain a separate readiness gate; these tests do not establish external-client compatibility.
