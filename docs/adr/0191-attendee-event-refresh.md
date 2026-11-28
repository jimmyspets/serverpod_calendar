# ADR 0191: Explicit attendee VEVENT REFRESH

Status: **Proposed for maintainer review.**

## Context

An attendee can request a current invitation from its organizer with VEVENT
REFRESH. The organizer normally answers with REQUEST, which continues
through ordinary invitation reconciliation. The bounded pure adapter is
implemented under [ADR 0120](0120-remaining-pure-event-scheduling-methods.md),
and [ADR 0190](0190-authenticated-event-refresh.md) implements private
organizer review and explicit resend. The remaining direction needs an
attendee identity, a verified source and a separate authorized delivery.
[RFC 5546 sections 3.2.2 and 3.2.6](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.6)

## Proposed command and source

Expose **Request current invitation** on the organizer invitation's private
attendee view. An explicit command names the entry, its reviewed revision,
and a stable command UUID. Resolve the actual scope and recipient through
the existing private invitation runtime. Require the current exact retained
non-recurring REQUEST containing one master. Detached components, delegation
and sent-by roles remain outside this profile. Apply the same verified-address
and exact source checks before
the command can view or send data. The action is independent of whether a
recipient added or applied the invitation to a calendar. Native drafts,
dismissal, adopted links, calendars and participation remain independent.
A cancelled invitation or current source other than a REQUEST makes new
work unavailable.

Create a minimal VEVENT REFRESH with UID and ORGANIZER from the retained
source, the single host-verified ATTENDEE and an actual whole-second
database DTSTAMP. Use the bounded pure parser to verify the composed bytes.
The first action carries no optional COMMENT, SEQUENCE, original identity,
recurrence, proposed timing or participation fields. Preserve the source
version, including missing versus zero SEQUENCE, in private proof so source
changes are detected even though the wire message has no SEQUENCE. The
stamp records the send request time and allocates no participation version.

## Proposed durable delivery

Reuse the attendee-sender routing and disclosure patterns of
[ADR 0146](0146-explicit-private-attendee-responses.md). Add independent
read and send authorization for REFRESH and an optional host adapter with
separate admission and dispatch approval. Verify that the approved sender
is the actual private recipient named in the retained REQUEST and the
destination corresponds to its verified organizer. As with REPLY, the
actor is present on an interactive command and absent on dispatch.
Authorize the full immutable candidate and route at preliminary and final
checks under the declared host guarantee. Preserve the documented
after-check race for external fresh-check hosts.

Use two new private tables in the invitation module:

| Proposed record | Contents and identity |
| --- | --- |
| Attendee refresh delivery | Scope, recipient, entry, command UUID and actor, exact criteria and receipt identity, source ID/revision/digest and optional version, attendee/organizer, authority and route references, immutable payload/digest, database-timed queue/lease/expiry and terminal outcome. Unique scope/recipient/command identity. The record UUID is the transport delivery identity. |
| Attendee refresh attempt | Delivery/attempt number, fenced lease token, start and completion times and bounded result. Unique delivery/attempt identity. |

Allow one pending refresh per invitation, at most 16 pending per recipient,
32 retained deliveries per entry, 512 per recipient and 4,096 per scope.
Use a 32 KiB wire ceiling and the attendee outbox worker defaults of eight
attempts, a 120-second lease, at most a 30-second submission timeout,
seven-day expiry and 30-day terminal retention. All admission counts and
the source pin are checked under the same database scope fence. The pin
retains the actual source through delivery and receipt retention and counts
toward existing source caps. Bounded maintenance removes terminal attempts
before their delivery, then allows eligible invitation cleanup.

A matching retained command retry reauthorizes access to the pinned source
and exact route and returns the same queue identity even if the current
source advanced. Changed criteria or route under the same UUID reject. A
retry never reactivates a terminal delivery. A new command UUID is a new
explicit request and requires a currently eligible source. Dispatch checks
the current entry, exact source and route, origin authority, expiry and
lease token before claiming and again before submission. A newer source,
CANCEL or revoked authority withdraws queued work. Uncertain transport
acceptance retries the same delivery identity and bytes. A late result cannot
overwrite a newer lease holder.

The organizer's eventual REQUEST continues through normal trusted invitation
receipt, deduplication, review and explicit application. No inferred
correlation to an outgoing refresh, forced update, synthetic reply or
participation change occurs. A synthetic transport receipt establishes
acceptance by that transport only.

## Alternatives and acceptance

An automatic refresh on read or dismissal would make a private UI operation
send mail. Sharing the REPLY choice head would tie the refresh's lifetime
to participation state. Separate explicit delivery preserves both lifecycles
and allows verified organizer intake to exercise the method end to end.

Before implementation, obtain agreement on the source profile, permissions,
tables, quotas and retention. Validate unadopted and adopted source review,
stale/cancelled or recurring source rejection, independent authority,
expired leases, pinned cleanup, cross-host races, process loss around commit
and transport, and exact bytes and route on retry. In a synthetic loopback,
pass the REFRESH through the ADR 0190 host with separately trusted origin
proof. Verify that explicit organizer resend returns through ordinary
REQUEST intake and causes no silent apply. Exercise generated-client and
connected Flutter controls, fresh and populated migrations, and full
exact-head hosted checks. Real transport and recurring REFRESH remain
separate release work.
