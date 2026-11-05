# ADR 0174: Complete bundled invitation updates

Status: **Accepted by explicit maintainer agreement on 2026-11-05**, including the grouped protocol, API, checkpoint and retry mechanics below. Implementation and validation evidence remain separate.

## Context and verified baseline

[ADR 0173](0173-initial-bundled-invitation-adoption.md) implements initial complete REQUEST review and one-event adoption. Its implementation, commit `b12d8f7f12ec82c9549c8aa635531534892dffd7` in [PR #178](https://github.com/jimmyspets/serverpod_calendar/pull/178), passed hosted inspection and the full runtime job in [run 41913066740](https://github.com/jimmyspets/serverpod_calendar/actions/runs/41913066740). Current code deliberately rejects changed known bundles, including after inbox pruning.

Existing source rows and active import baselines already preserve every supported component, its independent DTSTAMP and optional SEQUENCE. The one-per-link `CalendarInvitationApplicationRecord` stores the latest accepted source, full-baseline digest and latest immutable command/result. Its ordinary reader currently requires scalar master advancement and rejects bundled links. That scalar rule cannot represent an update which changes only an exception while leaving the master version unchanged.

## Proposed complete group

Implement component-aware trusted intake/private review, explicit clean-series Apply bundle update, exact retries, generated clients and synthetic MIME/Flutter/recovery checks together. Restrict new update admission to an existing active imported event linked by `bundledRequest=true`; unadopted bundles, ordinary single-created links and mode conversions retain their current guards. Receipt/dismissal change no calendar or participation state.

Each incoming REQUEST includes one master and every previously accepted original/range component, preserving exact typed identities, UID, organizer and fixed attendee roster. New supported exceptions may be added within existing limits. Omission, removal, single/future identity conversion and recurrence changes orphaning an included original reject. Partial merging, explicit exception removal/reset, roster changes, whole/partial CANCEL and participation remain separate required work. Retain VALARM, delegation, SENT-BY and all other existing unsupported-profile rejection.

## Proposed component version contract

Use separate keys for the master and each exact DATE/UTC/named-zone original plus its single/THISANDFUTURE kind. Source versions remain independent; do not copy a master SEQUENCE into children. Compare `(SEQUENCE or effective zero, DTSTAMP)` lexicographically, matching existing invitation source ordering, while preserving omitted versus explicit zero in stored/exported state.

For every previously accepted component, a lower tuple rejects the whole packet. An unchanged tuple is allowed only for an unchanged normalized component payload, including supported source-presence distinctions and optional CREATED/LAST-MODIFIED. A changed payload requires a strictly greater tuple. A greater tuple may retain unchanged content. Compare source component fields rather than inherited effective fields, so an unchanged child does not need a new version merely because the master changes. Normalize component ordering for comparison while preserving meaningful grouped values, annotations and omissions. Envelope PRODID, folding and regenerated timezone presentation are not component content.

A new explicit component for an accepted original must advance over its previously effective master/range/single source version, using the existing effective-component selection policy. For an original newly introduced by the candidate recurrence, require exact bounded proof of previous absence and advancement over the accepted master's tuple as an explicit admission floor. Validate candidate membership; no budget failure proves absence. These are conservative application rules, not universal RFC requirements. A higher SEQUENCE can accompany an earlier DTSTAMP under tuple ordering; preserve the source timestamp rather than inventing monotonic source clocks. Database audit times and API revisions remain separate.

Before new admission, compare against both the accepted full baseline and any retained currently selected review bundle. Require inclusion and non-regression against both; reject incomparable packets rather than selecting newer parts from each. Exact retained ingress retries reauthorize before these new-admission checks. A complete identical normalized state is a duplicate and does not reactivate dismissed review.

When a pending marker survives but its different source body has expired, missing component evidence is unavailable, never a scalar fallback. When normal retention has removed that unaccepted marker entirely, reconstruct new review only from the surviving validated accepted baseline and permanent link profile. This does not promise indefinite ordering against expired unaccepted messages. Missing/corrupt accepted baseline or a deleted linked event rejects reconstruction.

## Proposed atomic application and existing storage

Reuse `CalendarInvitationApplicationRecord`, with `kind=requestBundle`, one current full-baseline digest and the existing immutable latest-command fields. No new SQL table, column, index or JSON history chain is proposed. Master sequence/stamp columns describe only the master; bundle readers validate the complete baseline/version map and must not require scalar master advancement. Accept child-only advancement. Continue binding the current row to the immutable creation link, actual scope/recipient/event and complete baseline digest; creation receipts never change.

The active event's existing private import baseline holds the full accepted content/component versions. Ordinary native edits leave it unchanged, making whole-series local-change detection possible without retaining another copied source document. Source bodies may expire under existing rules; authorized historical retries then use the existing unavailable-source descriptor plus the validated full baseline/checkpoint, never fabricated MIME or component claims. Retain the latest application result, not an unbounded command history. A later application supersedes older update retries; exact latest retries remain write-free despite newer local drafts or inbox epochs. Deletion scrubs active payload/baseline and never recreates an event on retry.

Under the shared scope transaction, require the selected invitation/source/link and expected invitation, calendar, event and application revisions. Reject any local series/occurrence change since the accepted baseline. Apply the entire supported incoming series, source versions/omissions, new full baseline, current acceptance row/result and review state atomically. Advance native event/scope generations through the existing feed/alarm invalidation path. Preserve native identities, associations and private personal alarm/action state; imported data activates no alarm and sends no message.

## Proposed API and authority

Add dedicated `bundleApplication` and `applyBundleUpdate` operations. Reuse the existing immutable `CalendarInvitationApplyRequest` tuple and `CalendarInvitationApplyReceipt`, with `kind=requestBundle`; require `expectedOccurrenceRevision=0` because the older occurrence-acceptance ledger does not belong to this link profile. Existing master/single/range application and every participation path remain explicitly guarded for bundled links.

Propose two read-only generated DTOs:

- `CalendarInvitationBundleComponentVersion`: optional `originalStart` (null only for master), `isThisAndFuture`, optional `sequence` and required `stamp`.
- `CalendarInvitationBundleApplicationView`: actual link/invitation/calendar/event IDs and revisions; accepted invitation/source/time and component-version list; `acceptedSourceUnavailable`; current content/overrides and `hasLocalChanges`; optional incoming source/invitation revision, content/overrides, complete source text and component-version list; `canApply` and optional latest application receipt. Source absence stays explicit, not an empty version list.

Version maps and full candidate projections require full current event/source disclosure; ordinary inbox summaries gain no component-count/version endpoint. Add independent `readBundleApplication` and `applyBundleUpdate` host operations, retaining receive/receiveBundle, summary/source/link and applicable native import/edit/lifecycle gates. Trusted host context carries the complete immutable message, current/proposed native snapshots, actual parent/link, accepted and incoming vectors and final result. Read eligibility never replaces preliminary/final write checks. Preserve the configured consistency guarantee and documented external after-check race.

## Bounds, example and complete acceptance

Keep the existing 256 KiB source, 65-component/64-override, 200,000 shared-work, source/receipt/link/native-baseline and 30-day terminal-retention bounds. Share work across baseline reconstruction, both vector comparisons, membership, candidate validation and final baseline generation; fail without partial admission/application. No retention expansion, network fetch, real transport, dependency update or publication follows.

Extend synthetic example MIME generation and the Flutter review/Apply journey with child-only and mixed master/child changes, explicit version labels, stale revision/local-conflict handling and unchanged native creation identity. Keep calendar application and participation separate. Add focused DATE/UTC/exact-zone/DST, additions, omission/collision, tied-version conflicts, backwards tuple, source omission, pruning, corruption, authority/final-denial and no-recreation tests. Verify two hosts racing intake/application and actual loss before/after each commit, preserving immutable latest results, full series and private actions. Run complete relevant pure/browser/database suites, generation/analysis/formatting and the full exact-head hosted check before readiness. Commit code only once the complete approved group is finished.

## Alternatives and consequences

Scalar master ordering loses child-only changes; selecting the newest parts independently silently merges invitations. Treating omitted exceptions as deletion contradicts the confirmed complete-component policy. A new vector table is unnecessary while each accepted update remains one complete series; the existing baseline/checkpoint can bind it without an additional retention boundary. If implementation requires new persisted fields or broader semantics, return with that concrete refinement rather than overloading unrelated occurrence-history JSON. This increment advances complete linked REQUEST updates, not full scheduling reconciliation or interoperability.
