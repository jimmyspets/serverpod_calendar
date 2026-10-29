# Trusted invitation intake and private review

Accepted [ADR 0137](adr/0137-trusted-invitation-intake-and-review.md) adds a bounded attendee-side queue for authenticated non-recurring organizer REQUESTs. Receiving or dismissing one creates no event, booking, participation response, notification or outbound message. Calendar addition, existing-meeting updates, recurrence/CANCEL reconciliation and mail remain separate requirements. This calendar scheduling queue is separate from the reusable notification module.

## Trusted ingress and host context

Install `CalendarInvitationRuntime(host: ..., options: ...)` through `CalendarModule.install(invitations: ...)`. Call server-only `CalendarModule.receiveSchedulingInvitation(session, delivery)` from trusted code. The reusable module exposes no RPC accepting origin proof, recipient IDs or raw invitation bytes. `CalendarInvitationDelivery` bounds/copies bytes into an unmodifiable view before asynchronous work; namespace, delivery key and origin reference are bounded opaque strings.

`CalendarInvitationHost.resolveDelivery` resolves an actual trusted scope, opaque recipient key and exact calendar address, and verifies origin authority for the exact ORGANIZER. A source attendee must match that target address. Neither message fields, HTTP/mail headers nor knowledge of a UID supplies authority. `resolveCurrent` derives the native recipient from trusted actor context and receives the actual transaction. The module checks scope/recipient consistency again before returning native results.

Independent `receive`, `list`, `readSummary`, `readSource` and `dismiss` operations use the adapter’s `authorize` callback. Preliminary origin/target approval precedes private history lookup. Proposal/final receive checks include immutable source/normalized text/digest, actual current summary, allocated entry/source/receipt IDs, proposed state and complete receipt. Before lookup, absent current is not evidence of a new entry; allocated IDs distinguish the later proposal. Retained retries carry current queue state separately from the original receipt’s revision/outcome. Final denial or unavailability rolls back row writes and housekeeping.

The host declares coordinated or external fresh-check guarantees. Installation and every callback reject a downgrade. Same-database reads alone do not prove coordinated revocation, and external final checks retain their after-check revocation race. Native APIs also retain current actor/policy-epoch checks. The shared database scope lock and uniqueness constraints serialize independent instances; calendar generation is not advanced by inbox-only changes.

## Supported source and ordering

Require one non-recurring VEVENT REQUEST with supported DTSTART/SUMMARY/UID/DTSTAMP/ORGANIZER and target attendee data. Reject recurrence properties/RECURRENCE-ID, detached/range components, delegation/SENT-BY, other methods and unprofiled properties explicitly. Reuse strict UTF-8/CRLF, whole-second timing, ordinary 1970–2099 dates and complete pinned-IANA zone validation. DATE, UTC, named zones, explicit end/duration forms, versions and omissions remain distinct. Nothing is fetched or armed.

Correlation is scoped by recipient and exact source UID/organizer. Different organizer claims are not automatically merged or treated as verified organizer replacement. Omitted SEQUENCE compares as zero but remains omitted in storage/review. Higher SEQUENCE wins even with an earlier DTSTAMP; equal-sequence later stamps select the newer source, earlier versions/stamps are stale, and equal version/stamp with different normalized text is a conflict. Retain unapplied source for independently authorized review; none of it updates a calendar.

Deterministic serialization preserves supported source groups/order/omissions and does not claim universal semantic equivalence. Digests are checked against retained text. Exact retained delivery-key retries return the original receipt after fresh authorization without changing the selected version/dismissal. Cross-key duplicates share an existing validated source and retain separate receipts. Reusing a key with changed payload/target/origin evidence rejects. An old retained source is validated before a new duplicate receipt can reference it.

## Storage, limits and retention

Three server-only tables hold invitation entry/current marker, normalized source and ingress receipt. Scope/recipient keys are bounded to 512 UTF-8 bytes. Correlation uses an unambiguous length-prefixed UID/organizer digest plus retained-value checks, avoiding indexes on long raw identifiers. Source digest uniqueness and recipient-wide delivery-key uniqueness coordinate races. The pinned module/example migrations add only these tables, indexes and references; no existing domain content is transformed.

Initial caps are 64 pending entries and 64 retained dismissed markers per recipient, 16 sources per entry, 256 retained sources/16 MiB source bytes and 1,024 receipts per recipient, and 256 KiB per input/normalized message. Hosts can lower caps. Admission fails atomically without evicting live evidence; retained receipt retries bypass new-row capacity checks. Hard bounded scans keep existing readable data available if admission limits are lowered.

Terminal source/receipt retention defaults to 30 days, configurable to a positive bounded duration up to 365 days. Pending current source is protected. Unexpired receipts retain their source; superseding/dismissing starts inactivity without inventing prior history. Housekeeping removes expired receipts before eligible inactive bodies and markers. It runs on authorized recipient activity before admission/listing and new dismissal capacity checks, with hard bounded scans. Retention means eligibility for that housekeeping, not a guaranteed global background-erasure deadline; global cleanup orchestration remains separate roadmap work.

A dismissed entry keeps minimal UID/organizer/version/digest state if its current body expires while other retained references keep the entry alive. `sourceId`/summary/timing may then be absent; a pending entry always has validated current source. A digest-only marker cannot prove exact body equality: a cross-key replay matching that pruned digest fails unavailable without creating a fabricated duplicate receipt or reopening review. An unexpired same-key receipt still retains its body and remains retryable. A genuinely newer source can reopen review. After all relevant retention expires and the entry is purged, an old delivery may reappear for review; it never automatically recreates an event.

## Native API and example

Generated `calendarInvitation.list` returns the complete bounded pending queue with per-entry summary authority and no total. Deny omits an entry; unavailable policy fails the whole request. `getInvitation` resolves actual recipient ownership. Summary views include source UID/organizer, typed timing/summary, source version and receipt/dismissal data; they omit other attendees, CONTACT and raw source. This is a fixed summary projection with an independent full-source gate.

`sources(entryId)` and `source(entryId, sourceId)` additionally require source-read permission. History reports original classification plus an independent `isCurrent`; an historically selected source is not necessarily current. `dismiss(id, expectedRevision)` independently authorizes, rejects stale revisions and retains a no-op’s current revision. A duplicate stays dismissed; a strictly newer selected source reopens only review. Calendar revisions, protocol state and busy calculations are unchanged.

The example review screen renders inert text and source history, supports refresh/dismissal and preserves stale-write errors. Its preview shows source civil date/clock and explicit DATE/UTC/zone, identifies exclusive DATE ends and preserves duration units/omitted end form without device-zone conversion. Its simulator exists only in development/test, constructs synthetic organizer/recipient evidence from the actual signed-in demo identity and accepts no arbitrary bytes or claimed sender proof. Uncertain simulator retries retain command/body identity until success. No Add/accept/decline/mail action is provided by this increment. Production hosts replace the adapter and transport integration.

Focused database, populated-upgrade, real two-process loss/race and connected client/Flutter evidence is recorded in [validation](scaffold-validation.md). Generated sources and migrations come from the pinned CLI; participating hosts/clients must upgrade together. This increment establishes no MIME, external calendar-client or complete iTIP conformance.


## Explicit calendar addition

The separately accepted [calendar-addition batch](invitation-calendar-adoption.md) adds an explicit local copy and stable link under ADR 0138. Receipt/review/dismissal remain separate and never create that event automatically. Source updates and participation replies remain unimplemented reconciliation work.
