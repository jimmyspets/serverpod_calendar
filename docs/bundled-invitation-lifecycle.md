# Bundled invitation whole-series lifecycle

[Accepted ADR 0175](adr/0175-bundled-invitation-whole-lifecycle.md), including its explicitly approved lossless-baseline refinement, extends [complete REQUEST updates](bundled-invitation-updates.md) with private whole-series CANCEL review, explicit cancellation and complete REQUEST reopening. This is the bounded whole-series profile; instance/range cancellation, partial merging/removal, roster changes, bundle participation and VALARM remain guarded. Actual grouped validation is recorded separately in [the validation log](scaffold-validation.md).

## Receipt and explicit calendar actions

A trusted host can receive one supported whole CANCEL for a known, active, imported event with the permanent bundled link profile. Intake authenticates through the host boundary, validates the actual recipient and source against accepted/pending state, and creates private review. Receipt, source review and dismissal do not cancel the native event, free time or send a participation response.

`applyBundleCancellation` requires matching invitation/source/link, calendar/event/application revisions and an unchanged entire native series. The scope transaction saves cancelled native state, the cancellation checkpoint/result, dismissed review and ordinary feed/alarm generation fences together. A final authorization denial rolls back every change. Local edits remain a conflict; cancellation is not permission to erase them.

Reopening requires a complete supported REQUEST, then the separate `applyBundleReopening` action. The ordinary update API never silently reopens a cancelled series. A newer REQUEST received while cancellation is still merely pending can replace that review while the native event stays active. Repeated accepted cancellation/reopening cycles reuse the same link, event UUID and application row. A private individual cancellation is a local series change and blocks source application; it is retained, never silently cleared. Accepting new single/range source cancellations on bundled links remains outside this profile.

## Source and version profile

The minimal native cancellation profile accepts UID, ORGANIZER, ATTENDEE, STATUS:CANCELLED, explicit SEQUENCE and DTSTAMP. There is no RECURRENCE-ID/RANGE, recurrence rule, timing or text edit. The organizer must match and attendees must be a subset of the fixed accepted roster containing the trusted recipient. Existing supported participant parameters remain inert source claims; delegation and SENT-BY remain unsupported. This is deliberately narrower than RFC 5546, which permits additional cancellation properties.

Cancellation SEQUENCE must exceed every retained REQUEST component, the last accepted cancellation, and all components of a different retained pending REQUEST or cancellation. A newer timestamp alone cannot cross that floor. Equal-version different normalized cancellation bodies reject; exact retained ingress retries reauthorize without reactivation. These conservative component-wide application floors are not a universal RFC rule.

Reopening retains complete-set/non-regression/orphan protection and independently optional source values from ADR 0174. Its master SEQUENCE must strictly exceed the distinct accepted or pending cancellation; unchanged children keep their own versions. A child-only update cannot reopen the series. A supported complete replacement may change timing/content, while retaining every required original/range identity.

## Lossless baseline and private state

The private import baseline remains the exact last complete REQUEST. It preserves original master/child versions, explicit/omitted status and other source distinctions even after old source bodies expire. The existing application row has `kind=bundleCancellation`, the actual cancellation version/source descriptor, and the digest of that retained REQUEST. No new stored field, SQL table/column, copied predecessor snapshot or larger retention limit is introduced.

Expected cancelled native state is derived from the retained REQUEST and cancellation version: cancelled master status, explicit presence and actual cancellation SEQUENCE/DTSTAMP, with absent CREATED/LAST-MODIFIED, plus retained timing/content/overrides and child protocol versions. Clean-state checks compare the actual native state with this derived state. The baseline itself must still be a valid uncancelled REQUEST, with a master at least as new as creation and every component below the cancellation floor. Corrupt state fails unavailable; it does not establish clean coverage.

The protected view labels retained REQUEST components separately from optional `acceptedCancellationVersion`. Incoming cancellation evidence is one actual master component, not a received copy of the retained REQUEST vector. `acceptedKind`, `incomingKind`, `canApplyCancellation` and `canReopen` distinguish source state and eligible actions. A missing historical body is reported explicitly rather than reconstructed into invented calendar or MIME bytes.

Native associations and private personal alarms/actions remain in place. Cancellation stops the whole series contributing occupied intervals and invalidates reminder eligibility through the normal generation fences. Reopening preserves acknowledgements and accepted-firing deduplication; it does not rearm imported alarms or replay accepted reminders. Parent deletion still rejects active event dependencies, while event deletion scrubs its active data/private alarm state and can never be undone by retry.

## Authority, retries and publication boundaries

Independent `receiveBundleCancellation`, `applyBundleCancellation` and `reopenBundle` operations supplement existing receive/cancellation/bundle, full source/detail and native import/replacement/edit/lifecycle authority. Reopening also needs ordinary bundle-update authority. Hosts see actual current/proposed native and review snapshots, retained REQUEST versions, the separate cancellation checkpoint/version and actual incoming message. Read eligibility never substitutes for preliminary/final write checks. External policies retain the documented after-check revocation race.

One latest immutable command/result spans updates, cancellation and reopening; each action has its own request-digest family. Exact latest retries freshly authorize and return their original receipt without writing, clearing newer review or overwriting local drafts. A later accepted action supersedes an older update/lifecycle retry. The original creation receipt remains separately stable. Existing source/receipt/body expiry, private baseline, byte/count and shared-work limits remain unchanged.

A surviving pending marker with a missing different source body is unavailable. After normal pruning removes unaccepted review history, reconstruction uses only surviving accepted proof. Expired unaccepted versions are not invented as permanent floors. Historical REQUEST/duplicate sources validate through a later cancellation-kind change using the permanent bundle profile.

Ordinary authenticated export and HTTP feeds keep their existing faithful-round-trip checks. They may reject a cancelled series whose retained child source-presence state cannot be mapped faithfully by the current wire profile. This increment does not bypass those guards, delete exceptions or manufacture child cancellations to obtain output. Broader faithful cancelled-bundle publication remains required separate work; native whole-series lifecycle support is not external-client interoperability evidence.

## Example and checks

The development/test-only synthetic MIME path supplies complete REQUESTs and minimal whole CANCELs. Flutter shows separate retained/cancellation versions, explicit Apply cancellation/Reopen actions, visible errors and frozen uncertain-retry commands. Refresh deliberately clears the frozen intent and loads current revisions. No real sending or provider identity is inferred.

Focused tests cover minimal claims, independent sequence floors, omitted values and bounded work; SDK cases cover timing profiles, repeated cycles, source preservation/pruning, local conflicts, authority/rollback, private reminders, free/busy, export rejection and deletion. Two independent processes exercise races and real loss before/after intake and application commits. The complete check entry point includes the lifecycle tests and connected Flutter flow. Only completed commands/results in the validation log establish evidence; no full hosted conclusion is implied by this guide.
