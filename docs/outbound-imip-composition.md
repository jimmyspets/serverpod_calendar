# Synthetic outbound iMIP composition

Accepted [ADR 0143](adr/0143-synthetic-host-outbound-imip-composition.md) adds a bounded MIME composer to the example Serverpod host. Its existing authorized REQUEST/CANCEL transport now records a single-part calendar email locally. It opens no SMTP/IMAP/POP connection and sends no real mail. This narrow profile is not complete MIME/RFC 6047 interoperability.

## Dependency and host boundary

Only `calendar_example_server` pins `enough_mail: 3.0.0`. Workspace resolution added that package plus basic_utils 5.8.2, encrypter_plus 5.1.0, enough_convert 1.7.1 and json_annotation 4.12.0 without changing previously locked versions. Published source/license evidence is in [the evaluation](mime-library-evaluation.md); upstream notices for these five packages are preserved in [THIRD_PARTY_NOTICES](../THIRD_PARTY_NOTICES.md). The repository's Apache 2.0 LICENSE is unchanged. No upstream source was patched or vendored.

Reusable calendar/core/iCalendar packages and the replaceable `CalendarSchedulingTransport` interface remain independent of this optional MIME library. No Serverpod model/table, migration, endpoint or production provider configuration is added. Other hosts replace the example adapter and resolve their own trusted mailbox/provider policy.

## Composer and exact payload

The host-local `composeSyntheticSchedulingMime(submission, requireProtection: ...)` returns one ASCII MIME string. `SyntheticSchedulingMimeException` exposes only a bounded error kind. Its input is the current worker-approved submission, not an ordinary generated-client sender claim. It does not grant authority or replace worker checks.

The composer bounds the input string before UTF-8 allocation, then enforces a 512 KiB decoded-byte cap before parsing. It reads METHOD through the existing strict syntax parser and validates the complete original payload through [the decoded iMIP profile](imip-calendar-parts.md). Only VEVENT REQUEST/CANCEL are selected. Existing recurrence, component/zone budgets, omissions and historical original identities remain intact. Calendar bytes are not regenerated or normalized; the emitted base64 decodes to exactly `utf8.encode(submission.payload)`, including source folds, spelling and CRLF.

Every component's organizer must exactly match the trusted submission organizer. The example allows only lowercase `mailto:` addresses with ASCII dot-separated nonempty local atoms made of letters, digits, underscore, plus or hyphen, at `example.invalid`, with a 2,048-character cap. Organizer, recipient, source organizer/attendees and corresponding sender/delegation claims obey this stricter synthetic subset. URI metadata remains inert. This restriction belongs to the example sink and does not narrow canonical native identities or authorize any real mailbox.

## Deterministic envelope

The evaluated library generates a single `text/calendar` body with explicit UTF-8, matching METHOD and VEVENT hints and base64 Content-Transfer-Encoding. Final output must be ASCII and at most 1 MiB. No multipart/HTML/plain-text alternative or embedded attachment is generated in this increment.

From is the trusted organizer; To is exactly the one trusted recipient route. Subject is fixed `Calendar update`. There are no Cc/Bcc, Reply-To, Sender, custom/forwarded source headers or copied private titles. Message-ID is `<calendar-DELIVERY_UUID@example.invalid>`. Date is the first outgoing component's immutable DTSTAMP. This is a documented example policy, not a new calendar timestamp or a wall-clock retry date. The stamp can precede the publication when its first component is unchanged; MIME Date is not freshness evidence. A genuine mail-origination timestamp policy remains part of the later provider/transport review. Fresh builders and separate workers produce identical MIME for the same retained submission/key under the pinned library.

A required-protection request rejects before composition; the synthetic transport explicitly selects unprotected output. No signing, verification, encryption/decryption or silent downgrade is implemented. A replacing host must enforce actual confidentiality requirements and continue to reject unsupported protected input.

## Recording, errors and concurrency

`DemoSchedulingTransport` retains development/test-only and synthetic organizer/recipient guards. It adds `mime` to each existing ignored `.local/scheduling-mail/` attempt JSON record while keeping `payload`, publication/delivery identities and receipt behavior unchanged. Use these fixtures only with synthetic data; address guards do not prove that arbitrary event text is synthetic. MIME and body are never written to ordinary application logs; no new raw-message database archive is created.

Profile/protection/size failures return permanent failure. Unexpected library failures return transient failure with no library diagnostic. Recording I/O errors retain the worker's existing uncertainty/retry behavior. Stable delivery keys survive retries; attempt files are not a duplicate-suppression service or proof of remote receipt/display. MIME composition does not advance calendar protocol versions, change native drafts or alter payload hashes.

Existing complete-message/parent/recipient authority, current routes, generation, expiry, lease ownership and dispatch fencing remain required. The example has no production mail configuration and no source-header authority inference. No participant reply, native import, inbound mutation, alarm adoption or automatic response follows from composing an envelope.

## Validation and remaining work

Focused VM tests inspect hints, headers and exact independently base64-decoded calendar bytes; Unicode/folds, stable identities/date, recurring bundles, named zones, minimal historical cancellation, organizer/recipient/delegate mismatch, injection, malformed/unsupported source, protection and input caps. Output-size/ASCII invariants are asserted. The final size guard is defensive: bounded body and fixed/bounded headers already keep ordinary generated output below it.

The scheduling process probe uses this composer and checks decoded hashes at every synthetic acceptance. Loss/retry assertions compare MIME hashes across actual independent hosts for REQUEST, CANCEL, instance cancellation, restoration and reopening. Generated-client smoke checks inspect newly created fixture records without treating them as an inbound parser. Exact commands, failures/corrections and completed/deferred phases are recorded in [validation](scaffold-validation.md).

Complete inbound MIME/raw-parameter ambiguity and protection checks, multipart/transfer profiles, other outgoing methods/free-busy mail, trusted provider integration, remaining participant lifecycle, real transport configuration and external calendar/mail evidence remain separate required work. The enough_mail normalized parameter map is still insufficient for our strict inbound ambiguity boundary.
