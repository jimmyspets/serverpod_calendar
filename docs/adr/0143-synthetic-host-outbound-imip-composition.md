# ADR 0143: Synthetic host-owned outbound iMIP composition

Status: **Accepted by explicit maintainer approval on 2026-10-30 for the complete library/pin/notice, bounded MIME/envelope and synthetic recording batch. Scoped implementation and complete local batch validation are recorded separately.**

## Context and evaluated evidence

Accepted [ADR 0142](0142-pure-decoded-imip-calendar-parts.md) validates decoded calendar mail parts; it deliberately does not parse whole email or deliver mail. Existing approved organizer REQUEST/CANCEL workflows already persist authorized payloads and stable recipient delivery identities. Their example transport records synthetic calendar payloads locally. The approved increment composes an actual bounded MIME message in that host adapter while preserving all existing authority, payload and retry boundaries.

[The source evaluation](../mime-library-evaluation.md) inspected verified published archives of enough_mail 3.0.0, mime 2.1.0 and mailer 7.2.0. An isolated Dart 3.13.5 probe resolved enough_mail and used its public MIME builder/binary parser without invoking SMTP; Unicode calendar bytes and exact CRLF survived base64 composition/reparse. Its decoded Content-Type parameter map collapses duplicates, so it cannot be accepted as the complete inbound ambiguity gate. Nothing has been added to workspace dependencies by this evaluation.

## Approved dependency and host boundary

Pin enough_mail **3.0.0** only in the example Serverpod host, using its public `mime.dart` builder API. Its published license is MPL-2.0; retain package attribution/license information in a third-party notice while preserving this repository's Apache 2.0 LICENSE. This is a concrete dependency choice for maintainer review, not a claim about legal compatibility or the safety of arbitrary upstream code. Do not vendor or patch upstream source. Verify actual workspace resolution, lockfile, generation/analysis and host compilation after approval; isolated resolution does not prove the full workspace graph.

Keep reusable core/iCalendar/calendar modules free of this MIME/provider dependency. The existing CalendarSchedulingTransport interface remains replaceable and unchanged; other hosts may select another evaluated provider. This batch adds no package pair, Serverpod model/table/migration/endpoint or production transport configuration. Do not instantiate SMTP/IMAP/POP/network clients, discover accounts, read mail credentials or send real mail.

## Approved bounded composition

Add a host-local, directly testable composer for the existing VEVENT REQUEST/CANCEL submissions only. Parse/validate the original immutable payload through the accepted iMIP part profile with a **512 KiB** decoded-body cap, matching the existing scheduling transport maximum. Do not serialize the calendar again or replace the authorized payload with normalized bytes. The emitted calendar body must decode to the exact original UTF-8 bytes; host-approved calendar digests/native protocol versions remain unchanged.

Use a single `text/calendar` MIME body, explicit UTF-8, matching method and VEVENT component hint, base64 transfer encoding, and a **1 MiB** final ASCII message cap. Let the evaluated library generate MIME syntax/encoding; do not implement a custom email parser/encoder. Multipart/plain alternatives, URI attachment embedding, other outgoing methods and free/busy mail follow separately. This narrow slice is not full RFC 6047 conformance.

From comes only from the current host-approved submission organizer, and To contains exactly its one current host-approved recipient route. Validate those addresses against the bounded mail profile and require every outgoing component's organizer to match the trusted submission organizer. Never infer sender authority from payload headers, participant text or successful MIME composition. Existing worker permission, route, generation, expiry, lease and complete-message checks remain mandatory before submit; this composer does not replace them.

Use fixed ASCII subject `Calendar update`; no custom headers, copied private title, Cc/Bcc, Reply-To, Sender or source-mail header forwarding. Message-ID is `<calendar-DELIVERY_UUID@example.invalid>` from the existing stable delivery key. Date is the first outgoing component's immutable DTSTAMP, rather than wall-clock retry time. The same approved submission and delivery key must produce byte-identical MIME across retries/instances under the pinned library. No library-generated default identity/date is relied on. These are example composition policies, not new calendar protocol semantics or production mailbox identities.

## Synthetic sink, errors and protection

Retain existing development/test-only and synthetic-address guards, tightening the organizer/recipient checks as needed. Record the ASCII MIME string as one additional `mime` field alongside the existing exact calendar `payload` in the ignored synthetic per-attempt JSON fixture. Existing delivery receipts, payload hashes, files' stable-key correlation and retry outcomes remain unchanged; the existing attempt file is not an authenticated mailbox or a duplicate-suppression service. Do not log the MIME/body or add a raw-message database archive. The recording can contain only synthetic test data, never credentials or real calendar exports.

Required protection must reject explicitly; only unprotected synthetic output is selected here under ADR 0015. No S/MIME operation, removal of protection, confidentiality downgrade or claim of verified mail origin follows. Profile/size failures produce bounded permanent-failure results without payload diagnostics; unexpected library/recording failures keep existing safe worker retry/uncertainty behavior and stable delivery identity. Do not expose third-party exception strings or source contents in ordinary logs/receipts.

## Validation and acceptance

Test exact MIME hints, ASCII/base64 output, Unicode and exact CRLF/body preservation, organizer/route mismatch, header-injection input, required protection rejection, body/output caps, unsupported methods and stable identity/date/bytes across duplicate attempts. Include recurring REQUEST bundles and historical whole/instance CANCEL without changing payload, independent component versions or local drafts. Inspect generated MIME with the library and byte-level assertions; do not call the general text-decoding API on inbound source data.

Integrate the composer into the synthetic example transport only after approval. Verify existing JSON consumers tolerate the additive field. Extend actual two-host scheduling/recovery probes to compare stable-key MIME/decoded calendar bodies while preserving all previously required race/loss/lease checks. Run focused checks during development, broader formatting/workspace analysis, relevant pure/module/database/client/Flutter evidence and the complete root check before marking the batch ready; record exact phases and any deferrals before one implementation commit.

## Alternatives and accepted decision

The mime package provides a smaller multipart utility but no complete outbound email builder; its header map also needs a separate inbound ambiguity design. Mailer is an outbound SMTP composition library, but it does not offer the same standalone public MIME builder/parser surface evaluated here. Provider-produced MIME remains a valid later host alternative. Custom whole-mail parsing would violate the delegated library/provider boundary. Treating enough_mail's normalized parameter map as sufficient inbound evidence would undermine ADR 0142.

The maintainer explicitly approved the complete concrete batch before source changes. See [the implementation guide](../outbound-imip-composition.md) and the separate validation record. Complete inbound MIME/raw-part ambiguity, multipart handling, trusted ingress, durable participant responses/remaining lifecycle, provider/network configuration, real sending and external-client evidence remain separate required work. This proposal changes no existing source authority or native state semantics.
