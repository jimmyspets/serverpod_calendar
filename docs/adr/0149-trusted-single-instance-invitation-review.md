# ADR 0149: Trusted single-instance invitation intake and private review

Status: **Accepted on 2026-10-31 by explicit maintainer agreement covering the review batch and model refinement. Implementation and validation are recorded separately.**

## Context and sources

Accepted ADR 0148 implements the recipient workflow for one non-recurring or recurring master; its complete local batch checks passed in implementation PR #126. PR #127 adds hosted CI for the existing checks. The pure adapter already accepts detached scheduling components under ADR 0119, but parsing does not establish stored identity, membership or permission. Incoming native instance messages remain rejected.

Inspected the invitation record/view, correlation uniqueness index, source-kind enum, intake/parser and native link/application/response paths. Current correlation has only UID/organizer within a private recipient scope; treating an instance as another master would overwrite series review state or route it through master actions. This proposal first adds separate instance review, before designing native reconciliation and response sending.

Primary sources checked 2026-10-31: [RFC 5545 RECURRENCE-ID](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) and [RFC 5546 instance examples](https://www.rfc-editor.org/rfc/rfc5546.html#section-4.4.2), including [single cancellation](https://www.rfc-editor.org/rfc/rfc5546.html#section-4.4.3). Original recurrence identity remains distinct from a replacement DTSTART. Requiring known current series evidence, rejecting wider shapes and keeping review separate are project profile choices, not RFC-wide restrictions.

## Proposed first profile and known series

Accept exactly one detached single-instance VEVENT REQUEST or CANCEL through existing trusted host ingress. Require RECURRENCE-ID, the supported DATE/UTC/named-zone profile, exact UID/organizer correlation and a host-verified recipient. No RANGE, bundled master/exception components, recurrence patterns on the instance, delegation/SENT-BY or additional native methods enter this profile. Preserve independently optional timing/version data, including a minimal CANCEL with no DTSTART; never manufacture a replacement span from the series.

New sources must have a known active recurring-master basis in the same private scope/recipient correlation. Prefer its retained current trusted REQUEST body, even if not yet added/applied. If that body is unavailable, use a surviving calendar link's validated accepted-source baseline/checkpoint. Do not substitute current locally edited event content for accepted source evidence. A current whole-meeting CANCEL blocks new instance admission until a newer trusted master REQUEST is current. Missing/denied parent evidence rejects without creating an entry; corrupt required stored evidence fails unavailable.

Verify the actual recipient against the selected basis's roster, the original's exact kind/zone/civil profile and its membership in the supported recurrence set. Honor RRULE/RDATE/PERIOD and EXDATE precedence, including earlier explicit additions. A moved DTSTART is not an original key. Charge bounded candidate work using the existing 200,000-unit native membership ceiling; parser/zone/input limits still apply. Failure or uncertainty never becomes a successful membership result. This is admission-time validation, not proof that an original still exists after later parent edits.

Keep ordinary dates in [1970-01-01, 2100-01-01), whole-second precision, exact pinned zone keys and existing exclusive-end rules. Source VTIMEZONE validation remains full-horizon; calculation padding does not widen storage. ISO calendar presentation and recurrence-specific WKST keep their existing meaning.

## Proposed entry identity and migration

Add **two fields to the existing CalendarInvitationRecord**:

- `targetKey: String`, non-null/default `master`. A single instance uses `instance-v1:` plus SHA-256 of length-prefixed canonical original kind, exact zone identifier and civil fields. Use an explicit stable field order, not incidental map serialization or effective timing.
- `originalStart: CalendarEventTiming?`, nullable JSON containing only the original kind/start/zone, with no end or duration. Master entries require null; instance entries require a validated value, `recurring=true` and the matching derived target key.

Replace the existing unique `(scopeKey, recipientKey, correlationDigest)` index with unique `(scopeKey, recipientKey, correlationDigest, targetKey)`. Preserve the base correlation digest and exact UID/organizer checks. Verify retained typed originals against incoming source after lookup; a hash collision or malformed key/profile fails closed rather than retargeting an entry. Protocol UIDs and native API UUIDs remain separate.

Expose a read-only nullable original on CalendarInvitationView; the caller never supplies an authoritative target key or parent identity. Append `instanceCancellation` to CalendarInvitationSourceKind so whole-meeting and single-instance notices remain explicit while existing representations are preserved. No new table or source-proof snapshot is proposed. Generate carriers/clients and fresh/upgrade migrations from approved sources.

Existing rows are proven master entries by the earlier accepted profile, so upgrade initializes `master`/null and preserves their mode, source pointers, receipts, links, checkpoints and personal response state. Test index replacement against populated rows and demonstrate distinct originals can coexist without weakening master uniqueness.

The private target marker retains its typed original while the entry survives, including body-pruned markers. This is explicit private scheduling-correlation data, subject to the existing bounded marker retention; it does not change the content-free native calendar/event deletion markers or create an indefinite history promise.

## Proposed authority, ordering and retries

Retain preliminary origin/target authorization before private lookup, then independent `receiveOccurrence` authority in addition to ordinary receive and applicable cancellation authority. The new server-only immutable occurrence-basis context identifies its actual retained-master or accepted-baseline variant, trusted parent/link descriptors, validated canonical content/version and exact incoming original. It must not fabricate a source document from a baseline or treat participant text as permission. Final checks include the complete selected target/outcome and actual basis in the same scope transaction. Keep declared coordinated/fresh-check guarantees and the external after-check revocation race explicit.

Match retained delivery-key retries to their original entry/source/target and origin evidence, reauthorize historical access, and return the original receipt before requiring current-parent eligibility for a new source. A later master cancellation, pattern change or deletion must not reactivate a retained receipt or silently change its target. Missing current basis is explicit in retry context; host policy can deny access, but the module invents no replacement basis.

For new sources, order within each exact target using the existing SEQUENCE-then-DTSTAMP policy, preserving omission while comparing it as zero. Duplicate, stale and conflict sources do not replace that target's current source or alter master/sibling rows. Current means current within this review target; it is not proof of the current effective series invitation version. Cross-component reconciliation remains separate.

A first instance CANCEL must advance the selected parent REQUEST's known sequence floor. Once that target has ordering history, use its own retained REQUEST floors and source/marker ordering, rather than unrelated sibling or later master versions. A first cancellation that cannot establish the required floor rejects without constructing a source-less pending entry. Subsequent retained duplicate/stale/conflict handling keeps its existing meaning. No result automatically sends a protocol reply.

## Review-only scope and retention

The bounded recipient queue can contain separate master and instance entries. Summary/source/history/dismiss permissions remain independent; summaries disclose the incoming original and optional source replacement timing, not hidden native IDs, current membership or availability. Label instance updates/cancellation as unapplied review notices. A selected source is not an applied calendar change, participation decision or guarantee that its series is still current.

Reject instance entries in existing Add/link/application/response APIs before their UID/organizer fallback could resolve a master link. Hide those controls for instance cards in the example, and enforce the rejection server-side for forged requests or direct navigation. Parent master workflows remain available. Explicit instance application, independent accepted target versions/local-conflict baselines and instance replies require a later reviewed batch.

Reuse the existing shared recipient limits: 64 pending entries plus 64 retained dismissed markers, 256 retained sources/16 MiB, 16 sources per entry, 1,024 receipts and 30-day configurable terminal retention. Master and instance entries consume the same budgets; do not add a separate unbounded allowance. Existing active receipts/response references retain their own source as before.

Do not pin parent bodies or block shared event/calendar deletion because an instance notice exists. After admission, its own immutable source/typed target remains reviewable as historical data even if parent evidence changes or expires; no current membership or application authority is inferred. Future application must independently resolve and validate the then-current accepted series. Native events, baselines, scope content generation, feeds, alarms, participation and outbound intent remain unchanged by receipt/dismissal.

## Validation, alternatives and decision gate

Test unknown/denied/corrupt/whole-cancelled bases, retained master versus accepted-baseline selection, local draft separation, exact DATE/UTC/named-zone originals, DST, PERIOD/RDATE/EXDATE, moved timing and explicit work failures. Verify per-target ordering/duplicates, master/sibling isolation, key/profile collisions, final rollback, historical retries after parent changes/deletion, source pruning/capacity and server-side master-action rejection.

Exercise generated clients, protected Flutter notice/source/dismiss journeys, MIME ingress, two actual hosts racing target/receipt writes and loss around commit. Verify fresh and populated target/index upgrades, then complete grouped checks before one implementation commit. Unknown detached notices could instead be quarantined by a host outside this bounded module profile; treating them as known instances or auto-creating a master would invent identity. Applying updates during intake would violate the confirmed review-first boundary.

Open issues/PRs were checked; no overlapping incoming-instance implementation was found. The maintainer explicitly approved the proposed review batch and model refinement on 2026-10-31, including the known-series profile, private target retention, index mechanics, authority and master-only guards. The scoped [implementation guide](../single-instance-invitation-review.md) and separate validation record distinguish implementation from complete batch evidence. [AGENTS.md](../../AGENTS.md) retains the explicit approval gate for later material changes.
