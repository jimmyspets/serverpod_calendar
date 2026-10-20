# ADR 0007: iTIP scheduling and iMIP email

Status: **Proposed**. Date: 2026-10-19. RFC 5546 and RFC 6047 are required from the first release. This introduces scheduling state and email adapters; it does not authorize sending real messages during documentation work.

## Boundaries and data

Keep scheduling validation/state transitions in a reusable service independent of email transport. Serverpod persists events, organizer/attendee participation state, protocol identity/version metadata, an inbound processing ledger and a transactional outbox. iMIP adapters decode/encode MIME and use host-provided outbound delivery and trusted inbound ingress. Host integration supplies verified calendar-address mappings and send/respond/delegate authorization without adding a user/group directory.

Organizer/attendee addresses and participation status are event metadata, not module-owned identities or credentials. A subscription publication UID is a separate identity from the scheduling UID: feed aggregation must never rewrite the UID used to correlate invitations/replies. SEQUENCE/DTSTAMP and RECURRENCE-ID are protocol metadata, distinct from application revisions and transport Message-ID.

## Scheduling behavior

Implement the component/method matrix in [standards scope](../standards.md): event publication, invitations/updates, replies, added instances, cancellations, refresh requests and counter proposals; free/busy publication/request/reply. Validate organizer/attendee roles and property constraints for each method. Exact delegation/forwarding and participation parameter coverage must be reviewed rather than implied by a generic METHOD parser.

Keep ordinary file import's duplicate-conflict behavior separate from scheduling reconciliation. An authorized inbound REQUEST may update an existing scheduled event; a duplicate delivery must not create another copy. Use component-specific ordering rules, recorded UID/organizer/occurrence identity and attendee state to handle replays, stale messages, late replies and out-of-order cancellation. Persist terminal/cancellation correlation state long enough that old invitations cannot resurrect cancelled events. Method acceptance and event/state changes commit atomically.

User/room/equipment replies follow host policy. An invitation does not automatically reserve an external resource or grant calendar write access. If the host chooses exclusive acceptance, availability/conflict checks and the booking transition must be atomic; failed/declined requests must not produce confirmed reservations. Define tentative holds, expiration and resource auto-accept separately before enabling them.

The maintainer confirmed host-authorized meeting participation delegation with DELEGATED-FROM/DELEGATED-TO and CN/CUTYPE metadata during the RFC 5545 review; see [ADR 0010](0010-rfc5545-property-decisions.md). Host validation is required and delegation never transfers calendar ownership or grants access. Batch 8 subsequently confirmed host-authorized SENT-BY native actions/scheduling interchange, host-validated MEMBER metadata and RANGE=THISANDFUTURE event edits. Imported claims never establish authority or group membership. Detailed trust/state and method/property rules remain under review; iTIP task methods are now deferred under ADR 0011.

## Email and security

The maintainer subsequently selected the restricted email profile in [ADR 0015](0015-restricted-imip-profile.md): support component hints, defer S/MIME signatures/encryption and do not claim complete RFC 6047 conformance. Existing host-verified scheduling authority remains mandatory; unavailable trust evidence or unsupported protected input must not mutate calendars or trigger automatic replies.

Under [RFC 6047](https://www.rfc-editor.org/rfc/rfc6047.html), generate/consume supported scheduling payloads in MIME mail with matching text/calendar method metadata. Delegate MIME/message syntax to maintained libraries; validate charset, transfer encoding, multipart variants and protocol constraints. Keep transport recipients, calendar addresses and permitted delegate identities distinct.

Host ingress must provide authenticated delivery context and verified address authorization. Neither a MIME From header, matching ORGANIZER/ATTENDEE text nor knowledge of a feed token authorizes state changes. Define trust policy for external organizers and attendee replies, delegation and spoofed senders; unknown/untrusted messages are rejected or quarantined without mutation or automatic responses. Document the RFC's authentication/integrity requirements and the selected mechanisms, including S/MIME handling, before claiming iMIP conformance. DNS email checks alone do not prove calendar authority.

Commit scheduling mutations and outbound intent together using an outbox. Track pending/sent/failed/retry state, idempotency keys and delivery attempts without exposing calendar bodies or bearer URLs in logs. Email delivery is at least once; design recipients/inbound processing for duplicate delivery rather than promising exactly once. Retries preserve scheduling meaning/version. Unsupported or malicious inbound traffic must not cause response loops, unsolicited amplification or network fetching of embedded content. Bound message size, components, recipients, expansion and retry work.

## Multiple-instance processing

[ADR 0018](0018-automated-example-and-multiple-instances.md) requires concurrent ingress and outbox consumers to remain correct across active host processes. Persist deduplication/order state and claims in shared durable storage, enforce uniqueness and reject stale-owner updates after recovery. Tests in the real example host send duplicate/stale messages to different instances and interrupt workers around commit/delivery; verify one logical transition/outbox intent and stable retry identities. Provider acceptance can remain uncertain across a crash, so the existing at-least-once transport limitation still applies.

## Alternatives and acceptance

Attachments without state transitions do not implement iTIP. A send-only mail adapter does not implement the requested inbound response lifecycle. Host-provided mail adapters avoid embedding an SMTP/IMAP server in the library while requiring a documented operational contract.

Approve method/property matrix, participant identity/trust/delegation, external organizer behavior, resource acceptance, retention and mail-provider contracts. Test both directions of invite/respond/update/cancel and supported additional methods, series/occurrence edits, stale/duplicate/spoofed messages, outbox crash recovery, provider failures and MIME mismatches. Validate free/busy request privacy and apply RFC 7953 rules. Validate protocol behavior and native Flutter scheduling separately from the feed-subset matrix. Select external scheduling/email clients independently; Apple/Google/Outlook feed targeting does not require full scheduling/task UI support in all three. Record any chosen mail-client evidence. Native tasks and VTODO interchange are required under [ADR 0008](0008-module-clients-tasks-and-search.md); all VTODO iTIP methods and their inbound/outbound iMIP email binding are deferred by the maintainer under [ADR 0011](0011-defer-vtodo-scheduling.md). See FR-20–FR-23, NFR-10/NFR-11 and roadmap scheduling/mail work.
