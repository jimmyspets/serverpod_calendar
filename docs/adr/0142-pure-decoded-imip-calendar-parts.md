# ADR 0142: Pure decoded iMIP calendar-part profile

Status: **Accepted by explicit maintainer approval on 2026-10-29 for the complete pure decoded-part/MIME/address/protection/limit batch. Scoped pure implementation and local batch validation are recorded separately.**

## Context, evidence and boundary

[ADR 0015](0015-restricted-imip-profile.md) selects a restricted iMIP-compatible first-release profile, optional component hints and no module S/MIME capability. Existing pure event/free-busy scheduling adapters and durable native workflows still exchange calendar payloads through synthetic host transports. A common decoded calendar-part boundary is the next approved mail prerequisite, before complete host MIME/transport integration. This proposal adds no database, endpoint, migration, email account, native mutation or real sending.

[RFC 6047 sections 2.3–2.6](https://www.rfc-editor.org/rfc/rfc6047.html#section-2.3) require text/calendar with a method matching the calendar METHOD ignoring case; UTF-8 declaration is required for non-ASCII calendar data. Its optional component parameter describes actual component type. Filename hints do not determine payload type. The bounded choices below are application profiles, not complete MIME/RFC 6047 conformance. [The current matrix](../rfc/rfc-6047.md) keeps host/library MIME, multipart, headers, transport and authority work separate.

## Approved pure carrier and API

Add immutable pure Dart types/functions in serverpod_calendar_icalendar, independent of Serverpod and Flutter. Input is one already transfer-decoded MIME part: media-type string, ordered decoded parameter name/value pairs, raw decoded calendar bytes and an explicit outer-protection marker (none, signed, encrypted or unknown). The host MIME library/provider owns RFC 5322/MIME syntax, header unfolding, quoted parameter decoding, transfer encoding and part extraction; passing a decoded String must not normalize calendar bytes/line endings.

The ordered raw parameter list preserves case/spelling and exposes duplicates before normalization; no Map may erase ambiguity before validation. Freeze/copy inputs under bounds. The parser returns a typed existing VEVENT or VFREEBUSY scheduling payload plus immutable accepted source MIME metadata. It returns no authenticated/authorized sender flag, host user/role, delivery target, scheduling decision or native object.

Support all currently implemented pure VEVENT methods and the separate pure VFREEBUSY PUBLISH/REQUEST/REPLY profile without widening their component/property/recurrence/zone/time limits. Detect exactly the supported primary component kind; VTIMEZONE does not become the primary hint. Ordinary standalone ICS import remains separate. VTODO/VJOURNAL scheduling, mixed primary component kinds, unsupported source data and ambiguous calendar objects reject explicitly.

This API validates a single decoded calendar part. It does not parse/select a whole mail message, choose among multipart alternatives, claim to process every MIME part, resolve Content-ID references or preserve a complete RFC 5322 document. A later host/gateway contract must inspect all parts, enforce aggregate/transfer-decode budgets, reject unsupported ambiguity/protection and obtain trusted origin evidence before invoking any native ingress. Inert URI references remain source data; no fetching or embedding occurs.

## Approved MIME checks and canonical output

Require media type text/calendar, compared as bounded ASCII case-insensitive tokens. Require exactly one method parameter and compare it case-insensitively with the validated calendar METHOD. Missing/mismatched method is not accepted as an iMIP part; no fallback to file import occurs. Accept component absence; when supplied, require exactly the actual VEVENT or VFREEBUSY hint, case-insensitively.

Accept declared UTF-8; absent charset or US-ASCII requires an entirely ASCII decoded body. Other declared charsets reject without transcoding. Apply the existing strict UTF-8/CRLF/no-BOM calendar profile after MIME transfer decoding. Reject duplicate parameter names case-insensitively, empty/control-bearing required values and all unprofiled parameters explicitly; filename parameters are not inferred as calendar type. General filename/Content-Disposition handling belongs to the host/gateway profile.

A serializer revalidates an existing typed pure scheduling payload and returns a canonical decoded calendar part with text/calendar, explicit UTF-8, actual method and actual component hint. It does not emit RFC 5322 headers, MIME boundaries, transfer-encoded wire bytes or a deliverable email. Source metadata remains available on parsed results; canonical output is not exact original-mail preservation. The host MIME provider must apply the selected transfer encoding before SMTP delivery, including non-ASCII payload handling.

## Approved calendar-address subset

For this first mail-specific profile, ORGANIZER/ATTENDEE and any corresponding SENT-BY/delegation calendar-address values must be a single proper mailto URI within an explicitly bounded ASCII dot-atom mailbox/DNS-domain subset. Validate percent escapes without repair and preserve supplied URI spelling. Reject empty/multiple mailboxes, URI headers/fragments, controls, quoted local parts, domain literals and non-ASCII mailbox strings. Allow ASCII punycode domains without guessing/converting Unicode domains; Unicode display text inside the UTF-8 calendar payload remains supported. These stricter mailbox exclusions need later explicit expansion if selected mail targets require them.

This restriction applies only to the mail-part adapter, not general calendar/native identity or URI metadata. Directory/alternative/attachment links remain inert and do not become mailbox routing. Address syntax, matching MIME hints and decoded sender-looking data establish no ownership, verified sender, delegation permission or authority to apply scheduling changes. Host calendar-address/origin approval remains mandatory.

## Protection, limits and diagnostics

Reject signed, encrypted and unknown outer-protection markers under ADR 0015. The marker must come from the host/provider's actual MIME extraction context, never an email header or a claim of authentication. Do not strip protection and treat the inner part as authenticated. Outgoing serialization requires an explicit requireProtection choice; true rejects this unprotected profile rather than silently downgrading. No cryptographic verification/encryption or complete RFC 6047 conformance is claimed.

Default decoded body limit is 256 KiB with a hard configurable ceiling of 1 MiB; default parameter count 16 with hard ceiling 64. Bound names to 64 ASCII token characters and values to 1,024 UTF-8 bytes; bound each mailbox URI to 2,048 UTF-8 bytes before percent decoding. Charge raw inputs before duplicate/normalization checks and reuse the existing shared calendar/zone work limits. Reject before copying excessive carrier data. A later MIME gateway must bound raw message and transfer-decoder allocation independently; this part codec alone does not secure a whole message pipeline.

Errors are bounded non-echo diagnostics: no source addresses, subjects, payload fragments, attachment URLs or protected material. Parsed/canonical part acceptance triggers no lookup, query, mail, scheduling reconciliation, notification or alarm action.

## Alternatives, consequences and validation

Building a new complete MIME parser would conflict with the host/library boundary and expand scope. Treating arbitrary .ics attachments as iMIP would bypass method/type checks. Immediately wiring transport would mix content validation with unresolved provider/trust/lifecycle contracts. The proposed decoded-part adapter gives those later integrations one tested semantic gate while deliberately leaving their release requirements incomplete.

Test missing/matching/mismatched method/component/charset, case and duplicate parameters, unknown types/parameters, ASCII/Swedish UTF-8, transfer-decoded malformed UTF-8/CRLF/BOM, proper/rejected mailto forms and no URI repair. Exercise all selected source methods and both primary kinds, existing recurrence/zones/omissions, bounds before normalization, immutable carriers and canonical revalidation. Reject protected/unknown sources and required-protection output; diagnostics must not echo synthetic private values. Run focused VM/Chrome tests, then complete core/iCalendar VM/Chrome, relevant module regressions, formatting/analysis and documentation checks before one batch commit. No schema/native/real-mail interoperability claim follows.

## Accepted decision

The maintainer explicitly approved the complete concrete profile before implementation on 2026-10-29. See [the implementation/API guide](../imip-calendar-parts.md) and the separate validation record. Host MIME-library/provider selection, complete multipart/header/transfer integration, trusted ingress, durable participant responses/remaining reconciliation, actual mail delivery and external-client evidence remain separate required work. Existing RFC 6047 host/library and transport rows remain unimplemented until that integration exists.
