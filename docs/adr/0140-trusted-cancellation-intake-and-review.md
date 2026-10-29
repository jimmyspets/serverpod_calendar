# ADR 0140: Trusted whole-meeting cancellation intake and private review

Status: **Proposed; explicit maintainer approval is required before model or runtime changes.**

## Boundary and evidence

After accepted ADR 0139, a newer non-recurring REQUEST can be explicitly applied to its linked event with conflict protection. The next proposed batch receives a verified non-recurring whole-meeting CANCEL into the existing private review queue. Receipt and dismissal change no native event, accepted baseline, application checkpoint, alarm, busy time or outbound intent. Explicit cancellation application and subsequent reopening need a separate contract.

[RFC 5546 section 3.2.5](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) distinguishes whole-event cancellation, with STATUS:CANCELLED, from removing selected attendees, without STATUS. Its cancellation payload need not supply DTSTART or SUMMARY. The existing pure codec retains those omissions. The correlation, review, storage and retry policies below are application choices, not RFC requirements.

## Proposed trusted ingress

Accept exactly one non-recurring CANCEL component with explicit STATUS:CANCELLED, required source UID/ORGANIZER/SEQUENCE/DTSTAMP, no recurrence identity/rules/additions/exclusions and the existing bounded supported pure property profile. Require an ATTENDEE matching the actual trusted transport recipient under the current durable-ingress address rules; do not fabricate missing participants. The durable profile is narrower than the pure syntax/profile adapter. Attendee removal, delegated/SENT-BY authority, recurring/instance/range cancellation, unknown invitations and other inbound methods reject explicitly.

Resolve an existing entry/retained marker or stable creation link using the trusted scope/recipient and exact UID/organizer correlation. A source address or guessed UID is insufficient. Revalidate verified sender, actual transport target, host mapping epoch and complete host authority at preliminary/final phases under the shared database scope lock. If required retained evidence is unavailable, fail unavailable rather than inventing a recipient identity or applying weaker checks. A verified transport context is not an authenticated native user session.

Keep REQUEST intake behavior. A CANCEL may target an invitation not yet added to a calendar, or a linked event with newer local drafts. Those drafts remain untouched. Where a link exists, host context distinguishes the immutable creation descriptor, current accepted REQUEST checkpoint, actual current event and incoming cancellation; unavailable/deleted content is explicit. Context disclosure to the trusted host does not grant end-user event disclosure.

## Proposed ordering and atomicity

Reuse existing digest/key idempotency, source caps, bounded retention and per-recipient transaction serialization. Compare a genuinely new source against both the retained queue version and any known accepted REQUEST version. Never select a cancellation older than or tied with the accepted source merely because queue history expired. A new cancellation must have a greater SEQUENCE than each known correlated REQUEST version, honoring the cancellation increment rule. Order competing cancellation notices by SEQUENCE then DTSTAMP; preserve literal values. A later REQUEST retains its existing version-ordering rules and remains review-only. Same-version differing bodies conflict. If no queue entry remains and a source cannot advance the accepted descriptor, reject stale without manufacturing a review marker.

Retained exact-key and equivalent-source duplicate results keep their existing stable retry contract after fresh authority. They do not reopen dismissed review or replace a newer source. A selected newer cancellation atomically updates only queue/source/receipt state, resets dismissal and advances the invitation revision. Concurrent REQUEST/CANCEL reception, dismissal, source application and retries must converge through database locking, without process-local correctness assumptions.

## Proposed model and API refinement

Add a bounded CalendarInvitationSourceKind enum with request and meetingCancellation. Persist current source kind on CalendarInvitationRecord, defaulting existing rows to request because the previously accepted durable profile admitted REQUEST only. Preserve kind on content-expired markers. No new table or copied native content is proposed. Generate migrations and test fresh/populated upgrades; do not hand-edit generated schema metadata.

Expose kind on invitation summary/source views and incoming application review state. Historical bodies derive their own validated method/kind; do not compare an older REQUEST body to a newer entry's cancellation kind. Validate current body kind against its entry. Preserve source text and independently optional summary/timing. A cancellation without a start has no manufactured CalendarEventTiming; independently supplied ends remain in protected source data. UI labels distinguish cancellation notice, unavailable timing and the unchanged calendar event.

Add independent host authority for cancellation reception, in addition to normal ingress/source/recipient checks. Existing private summary/source/dismiss operations continue to authorize actual kind and source. Add to calendar and Apply update accept only REQUEST; a selected CANCEL cannot pass through ordinary METHOD removal or become a default event. Exact original creation and latest applied-REQUEST retries remain valid under their existing authority and never dismiss a newer cancellation. Existing linked reads keep current accepted REQUEST state and expose cancellation eligibility as false, rather than attempting REQUEST conversion.

The example provides synthetic cancellation intake, review and dismissal only. It displays that the calendar event is unchanged and offers no misleading Apply cancellation or participation control. No email transport, network fetching, notification or source-alarm activation follows.

## Proposed validation and rollout

Focused tests cover minimal cancellation omissions, required kind/status/recipient/correlation gates, unknown/deleted/unavailable evidence, historical REQUEST reads, expiry and accepted-version floors, stale/tied/conflicting sources, duplicate retries, independent/final authorization and rollback. Verify current and original creation/application retries remain stable and native payload/baseline/checkpoint/alarm/feed generation remain unchanged.

Test populated marker upgrades, real two-host REQUEST/CANCEL races and actual process loss before/after commit. Extend generated-client and Flutter review/dismiss journeys. At the completed batch boundary run the broader repository checks and document actual results before one implementation commit. Upgrade every participating host before enabling the new source kind; mixed old/new hosts are not supported.

## Alternatives and consequences

Automatic native cancellation would bypass explicit review and needs a separate local-draft/accepted-state contract. A second cancellation inbox would duplicate existing correlation, retention and receipts. Inferring kind only from a body fails after pruning, so a bounded current-kind field is proposed. Defaulting legacy rows to REQUEST is justified only by the prior strict durable profile, not a general method guess. The narrower known-correlation/recipient profile rejects otherwise parseable messages and must be documented; expanding it remains separate reviewed work.

## Decision requested

Approve this bounded intake/review scope, enum/current-kind storage and DTO refinements, independent cancellation authority, known-correlation and accepted-version ordering rules. No source implementation is authorized by merging this proposal alone. Explicit application, attendee removal, recurring intake, responses and RFC 6047 mail remain required separate work.
