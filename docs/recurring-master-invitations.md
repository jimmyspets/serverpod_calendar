# Recurring-master recipient invitations

Accepted [ADR 0149](adr/0149-trusted-single-instance-invitation-review.md) now adds separate [known-series single-instance review](single-instance-invitation-review.md). It supersedes the detached-instance intake rejection below only for that bounded review profile. Calendar application and participation actions remain master-only; RANGE and bundled input still reject.

Accepted [ADR 0148](adr/0148-recurring-master-invitation-workflow.md) extends the existing private recipient workflow to one supported recurring master. Its implementation builds on [review](invitation-intake-and-review.md), [calendar addition](invitation-calendar-adoption.md), [source updates](linked-invitation-updates.md), [cancellation/reopening](linked-invitation-cancellation.md) and [explicit responses](private-attendee-responses.md). Those guides' earlier non-recurring restriction is superseded only for this master profile. See [validation](scaffold-validation.md) for actual checks; the full release remains incomplete.

## Accepted source and preserved meaning

Trusted intake accepts one non-recurring or recurring VEVENT REQUEST master. Recurrence uses the existing DATE/UTC/named-zone, RRULE/RDATE/EXDATE and timed PERIOD profile, including full-horizon matching VTIMEZONE validation. Recurring REQUESTs also pass the standalone event/storage adapter before admission, so a source cannot be accepted into this new path while its canonical schedule is unrepresentable. Explicit-date-only sets count as recurring; a one-occurrence pattern is still a recurring master. The server derives the mode, never the caller.

The stored source retains supported syntax distinctions, annotations, UID and independently optional versions. Adoption creates one event series, never one row per generated occurrence. Native status defaults remain separate from source omission, and imported alarms remain unarmed. DATE values retain civil meaning; named-zone values retain local fields across DST. Whole-second timing, ordinary [1970-01-01, 2100-01-01), exact zone keys, ISO presentation and recurrence-specific WKST are unchanged.

Detached instances, bundled exceptions, RANGE intake, mode conversion, delegation/SENT-BY and other unsupported input reject explicitly. A pure scheduling codec can support data outside this narrower authenticated workflow; parser success grants no authority. This increment does not implement incoming instance/range reconciliation or future native cancellation.

## Private mode and surviving references

One non-null `recurring` boolean on the existing server-only `CalendarInvitationRecord` records validated source mode. The immutable `CalendarInvitationView` exposes a read-only flag under existing summary access. No new table, index or copied recurrence cache is added. Generated module/example migrations are `20261030224011648` and `20261030224037775`; existing rows initialize false because their accepted profile was non-recurring. No participation or response history is invented.

Mode survives newer sources, whole cancellation, dismissal, source pruning and retained markers. Retained REQUESTs are checked against it when decoded. A higher source version cannot convert an existing retained correlation's mode. A minimal CANCEL obtains its mode from known retained evidence; its absent recurrence never means non-recurring.

If the queue marker has expired while a calendar link survives, intake validates that link and accepted-source baseline/checkpoint before reconstructing a review entry. Current locally edited event content is not source-history proof. Missing, corrupt or inconsistent required evidence fails unavailable; it never falls back to creating a new event. Once all applicable unlinked ordering markers have expired, the existing documented retention boundary still applies—there is no indefinite duplicate-history promise.

Existing source/receipt bounds, retention, response pins and stable retry digests remain. No source-body or checkpoint hash format is changed merely for the view flag. Private source bodies and current native state remain independently protected.

## Explicit calendar and response actions

Receiving a recurring REQUEST or CANCEL is still review-only. Trusted host ingress must verify the actual organizer/recipient and approve the complete source/context. UID, organizer and attendee text establish no host authority. Ordinary edits, review and dismissal send nothing.

**Add to calendar** retains one stable recipient link and creates one imported-origin series in the explicitly selected calendar. Exact retries return the original receipt/event after fresh checks. **Apply update** requires the exact current newer source, expected revisions and a clean accepted baseline; it replaces the complete supported master atomically. Local content, timing or occurrence edits are conflicts, including local cancellation of an original. They are neither cleared nor retargeted by a source pattern change.

The bounded whole-series CANCEL profile supplies cancelled status and no RECURRENCE-ID or recurrence pattern. **Apply cancellation** requires a clean accepted baseline and preserves its schedule/content while updating status and the exact supported incoming protocol versions/omissions. Later source receipt does not reopen the event; a newer REQUEST must be explicitly applied. Existing checkpoint/source-kind, latest-result retry, independent lifecycle/source/read authority and database generation rules remain in force.

**Accept/Tentative/Decline** targets the complete selected master and stays independent of Add/Apply. Declining needs no calendar event. The minimal outgoing REPLY carries the source UID/SEQUENCE presence, verified recipient choice and database-second stamp, with no RECURRENCE-ID, copied recurrence or invented timing. An old choice is not acceptance of a newer source. The existing state/delivery/attempt tables, source pins, strict command clock, stable retries and fenced workers are reused. New sources or cancellation withdraw pending work through existing fresh-source checks.

All operations retain their separate permissions and immutable actual-object/proposal host context. Reconstructing a queue entry now supplies verified surviving-link context during intake as well as link operations; adapters must inspect the operation before interpreting optional historical-source fields. Scope transactions coordinate module state across hosts. Declared coordinated/fresh-check guarantees remain distinct; an external final check still has an after-check revocation race.

## Example and checks

Invitation review has a synthetic recurring fixture and a **Recurring series** label. Addition, application/cancellation/reopening and response screens explicitly describe whole-series effects. Synthetic fixture retries preserve mode and command identity after uncertain outcomes. The calendar's existing event/occurrence views show the adopted schedule. Source inspection still requires its independent permission.

The existing generated-client and Flutter invitation harnesses now include recurring cases. The independent recovery harness accepts `--recurring`, exercising the same command/lease/commit-loss paths with recurring sources. The populated upgrade helper offers `--recurring-invitations-only`. These use isolated synthetic test storage and local recording only. There is no provider authentication, real mail, organizer-receipt guarantee or external-client interoperability claim.
