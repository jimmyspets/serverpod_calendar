# Explicit private attendee responses

[ADR 0146](adr/0146-explicit-private-attendee-responses.md) approves this bounded non-recurring response workflow. Accept, Tentative and Decline are explicit commands independent of Add to calendar, Apply update/cancellation and dismissal. Receiving a message or editing an event sends nothing. Declining requires no calendar event. The example records synthetic mail only.

## Integration and authority

Install optional `CalendarInvitationRuntime.responses` with a `CalendarInvitationResponseHost`, transport and bounded options. Existing hosts without this runtime acquire no automatic sending behavior. The dedicated host resolves a verified attendee and approved organizer route and authorizes immutable complete outgoing messages and digests. Source participant claims and MIME headers establish no authority. Clients supply no recipient, sender, route or scope. Identity resolution receives the source/read preflight; complete proposed-send context is provided to authorization after payload construction.

The module requires private invitation/source-read authority and separate response read/send authority. It supplies trusted scope/recipient, actual current invitation and source/version descriptors, current/proposed response state and retry markers. Worker contexts have no fabricated logged-in actor: the host must verify current recipient access, identity, source-read/send rights and the retained route on every dispatch. Coordinated and external fresh-check guarantees remain explicit; external checks retain the documented after-check revocation race.

## Commands, reads and clocks

The generated `calendarInvitation` API adds `response(id)`, `responseActivity(id)` and `sendResponse(request)`. Activity returns at most 32 retained commands, without totals. The command identifies invitation UUID, expected invitation revision, exact current source UUID, expected personal response revision (initially 0), client command UUID and choice. Only a current non-cancelled, non-recurring REQUEST can receive a new response.

The command atomically saves private state and outbound intent under the shared scope transaction. It changes no invitation source/revision/dismissal, adopted event, application baseline, calendar generation, task, alarm or organizer roster. Concurrent choices using one expected response revision have one winner. A retained exact retry reauthorizes and returns its immutable queue receipt without writes, including after a newer source or choice. Changed criteria under the same retained command UUID reject. A new UUID is a deliberate new send, even for the same choice; it supersedes older pending intent.

The minimal REPLY contains source UID, server/database whole-second UTC DTSTAMP, the source's exact optional SEQUENCE, ORGANIZER and one verified ATTENDEE with PARTSTAT. Omitted SEQUENCE stays omitted; explicit zero stays zero. No timing, summary, contact, attachment or alarm content is copied. Each new response stamp must come from actual database time and be strictly later than the last allocated stamp for this private invitation. Equal-second or backwards time returns temporarily unavailable without writes. Retry after the clock advances; no future stamp is fabricated.

## Durable delivery and private history

Three server-only tables separate current personal state, retained commands/delivery and attempts. Generation checks, database leases, lease-owner/token/fence checks, fresh source/authority validation and stable delivery UUIDs support competing hosts and loss recovery. Call `CalendarModule.runInvitationResponseMaintenance` from trusted maintenance; the example's existing maintenance future call does this automatically.

New source/CANCEL, superseding choice or denied authority withdraws pending work. Unavailable policy/evidence remains retryable within the attempt/expiry limits. An accepted in-flight submission cannot be recalled. A late result cannot overwrite a new lease owner. Retrying an uncertain acceptance can submit the same UUID/bytes again; exactly-once external delivery and organizer receipt are not promised.

Defaults are 128 states per recipient/4,096 per scope; 32 retained responses per state, 512 per recipient/4,096 per scope; 16 pending per recipient; 32 KiB per minimal payload, 8 MiB retained per recipient/64 MiB per scope. Workers default to 8 attempts, 120-second leases, at most 30-second transport timeout, 30-second initial backoff capped at one hour and seven-day expiry. Terminal command/attempt history defaults to 30 days. Options may lower admission limits; overflow rejects atomically without evicting retained work.

Retained commands pin their actual invitation/source body. Cleanup honors those pins without increasing invitation limits. Personal revision, stamp, choice and bounded outcome survive delivery-history pruning while the invitation entry exists; a historical choice is explicitly labelled when it does not apply to the current source. Idempotency history is bounded by retention: after pruning, stale expected revisions fence old retries; the command UUID is not a permanent lookup service. Entry pruning removes personal state only after retained commands/attempts no longer require it. Upgrades preserve prior domain data and create no inferred personal response or delivery history.

## Example and verification

The Flutter invitation screen opens separate participation-response controls. No choice is preselected. An uncertain result retains the original command; refresh never silently creates a new send. Starting another response explicitly refreshes and clears the previous command and selection. Queue acceptance, sending, retrying, transport acceptance, withdrawal, expiry and failure remain distinct.

The example verifies its synthetic recipient and example.invalid organizer route. `composeSyntheticInvitationResponseMime` uses enough_mail with the actual attendee From, organizer To, deterministic delivery-UUID Message-ID/date and exact retained calendar bytes. No SMTP/provider credentials or real sending are implemented.

Focused database/MIME tests cover independent authority, rollback, sequence omissions, clock/CAS/retry behavior, source pins, bounds, expiry, takeover fencing and source changes during submission. A synthetic MIME loopback uses separate trusted organizer ingress proof; headers alone fail authorization. The independent-process probe checks competing workers, actual loss before/after synthetic acceptance and stable UUID/bytes on takeover. Generated-client and Flutter journeys exercise separate response/calendar actions. Actual commands and results belong in [the validation record](scaffold-validation.md).

Recurring/instance/range attendee sending, delegation, counters, broader reconciliation, provider authentication, real transport and external scheduling interoperability remain required separate work. This profile does not claim complete RFC 5546/6047 support.
