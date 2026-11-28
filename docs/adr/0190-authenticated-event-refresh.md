# ADR 0190: Authenticated organizer handling of VEVENT REFRESH

Status: **Proposed for maintainer review.**

## Context

An attendee can use REFRESH to ask the organizer for the latest description
and version of an existing event. The message identifies the original event
by UID and can identify an instance by RECURRENCE-ID. It carries no SEQUENCE.
The repository already validates the source envelope under [ADR 0120](0120-remaining-pure-event-scheduling-methods.md).
The host owns trusted origin verification and target resolution under
[ADR 0145](0145-host-mime-native-ingress.md). The organizer outbox already
stores the authorized published REQUEST separately from newer private
calendar edits. [RFC 5546 section 3.2.6](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.6)

## Proposed first profile

Handle organizer-side receipt, private review and explicit **Resend published
invitation** for a native-created, non-recurring invitation with a current
complete REQUEST. Keep the attendee-side command, recurring masters and
instances, RANGE, delegation, cancelled publications, informational PUBLISH
and real transport as separate roadmap work. The bounded MIME adapter would
accept the method only through a dedicated trusted host ingress.

The host supplies an explicit scope and event binding, a namespace, a stable
delivery key and a verified origin reference. The module validates one
profiled REFRESH and requires the verified origin to match its single
ATTENDEE. It verifies the actual invitation binding, UID and organizer, and
requires that attendee in the current fixed publication recipients. Principal
or binding discovery from MIME headers and bare UID fallback are forbidden.
The supplied DTSTAMP and optional COMMENT are source claims. They cannot
select a publication version or order receipt admission.

Receipt creates one private review entry and queues nothing. An authenticated
organizer can list private entries for an authorized binding using keyset
pagination with no totals. Cursors bind principal, scope, event, declared
authorization guarantee and data/policy revisions. The view may include the
requester's address, receipt time, supplied stamp/comment and disposition
under independent disclosure authority. Dismiss closes a review entry without
mutating the event or its audience. Reviews, status and outcomes remain scoped
to the organizer. Preserve no-echo failures for unknown, inactive or
unauthorized sources.

## Proposed explicit response and storage

The resend command names the review entry, a stable command UUID and the
publication ID and generation reviewed by the organizer. Verify the actual
current binding and exact publication again before queueing. A publication
change requires a new review action against the current source. Require the
requesting recipient's original delivery to be terminal. Resend the exact
current published REQUEST bytes to just the verified requester's currently
approved route. Keep wire ATTENDEE properties, SEQUENCE and DTSTAMP intact.
Use a new delivery identity for the explicit resend and preserve that identity
through retries. Native content, publication generation and prior delivery
status remain as recorded. No receipt or synthetic submission implies
remote display, application or participation.

Use separate server-only storage so a resend cannot replace the latest
publication or appear as an extra recipient on the original delivery.

| Proposed record | Contents and identity |
| --- | --- |
| Refresh request | Scope and binding, verified attendee/origin, bounded source digest and profiled fields, receipt time and disposition. Unique scope/namespace/delivery-key identity. Raw MIME retention belongs to the host. |
| Refresh resend | One per review entry and unique scope/command identity. Immutable publication ID, generation and digest, actor receipt, verified recipient and route, delivery identity, and database-timed queue, expiry, lease and outcome fields. |
| Refresh attempt | Unique resend ID and attempt number, bounded diagnostic outcome and timestamps using the existing transport result meanings. |

Compare the admitted digest, origin and exact binding on delivery retries.
Compare immutable command criteria on resend retries. Reauthorize retained
receipts through current disclosure/route checks before returning them.
Superseded or terminal commands cannot reactivate. Refuse reuse of a stable
key with different inputs. The resend holds a private reference to the actual
publication through delivery and receipt retention. Publication cleanup
must honor the reference under the existing scope fence. Make bounded
maintenance prune terminal attempts and resends before the corresponding
review entry. Missing or corrupt proof fails closed.

Proposed admission caps are 32 KiB of decoded calendar bytes, 64 retained
reviews or resends per binding, 2,048 of each per scope and 16 pending resends
per scope. Use the existing organizer outbox payload bound and worker defaults
of eight attempts, a 120-second lease, at most a 30-second transport timeout,
seven-day expiry and 30-day terminal retention. Open reviews also expire after
seven days, with delivery-key receipts retained to the same terminal
retention limit. Count pinned publications under existing caps. Apply all
limits atomically and bound scans and pruning per maintenance invocation.

## Proposed authority and evidence

Require independent trusted ingress, organizer review/dismiss, resend action,
scheduling read and full event/source disclosure. Resolve and approve the
requester's exact current route and the frozen message/digest at preliminary
and final writes. Background dispatch uses an actor-free host context and
checks the current binding, generation, payload, recipient, route, expiry
and fenced lease. Host policy must reapprove the current disclosure and
delivery both before claim and before send under the declared guarantee.
A successful external check retains its documented after-check race.

Automatic replies would expand untrusted intake into disclosure. Repurposing
the publication generation would alter RSVP version and delivery semantics
for unrelated recipients. The proposed private request and explicit resend
keep existing organizer publication semantics and permit independent review.

Before runtime implementation, obtain explicit agreement on this boundary,
permissions, storage and limits. Validate import and MIME purpose isolation,
exact payload and single-route delivery, authorization denial and final
rollback, pending and superseded records, retention and proof corruption.
Exercise generated-client review/dismiss/resend in Flutter, two real host
processes racing admission, and loss around commits and synthetic delivery.
Run fresh and populated upgrade checks and full exact-head hosted validation
before readiness.
