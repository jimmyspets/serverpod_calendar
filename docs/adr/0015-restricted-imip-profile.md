# ADR 0015: Restricted iMIP profile without S/MIME

Status: **Maintainer-confirmed first-release scope; implementation pending**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

## Context and decision

During RFC 6047 review the maintainer selected component MIME hints, but explicitly deferred S/MIME signatures and encryption and accepted a restricted profile. This narrows the email requirement in ADR 0007; it does not remove event/free-busy email exchanges or enable deferred VTODO scheduling.

Support the optional component MIME parameter: accept absence, validate a present hint against actual calendar content and emit it for supported outgoing messages. A MIME hint never bypasses payload/component/method validation.

Defer S/MIME signing/verification and encryption/decryption from the module's first-release contract. RFC 6047 sections 2.2.2 and 3 require S/MIME authentication/support; therefore describe this delivery/ingress capability as a restricted iMIP-compatible profile, not complete RFC 6047 conformance. Do not advertise unsupported cryptographic capabilities.

## Trust and module boundaries

Existing host-verified sender/calendar-address authority and method/role authorization remain mandatory before scheduling mutation. SMTP/MIME From, organizer/attendee text, feed tokens or DNS email checks alone are insufficient. A host adapter must supply an explicitly validated origin/authority contract; absence of such evidence means reject/quarantine without mutation or automatic reply. The precise trust mechanism remains implementation design work.

Unsupported signed/encrypted input is rejected/quarantined explicitly under the selected ingress profile. Do not strip protection and process inner text as authenticated, claim signature verification/decryption occurred, or silently send plaintext when host confidentiality policy requires protection. A transport provider's independent capabilities do not establish module-level S/MIME support or conformance.

Mail transport/configuration and any optional host cryptographic services remain host-owned. This decision does not prescribe custom cryptography, embed a mail server, grant automatic mail-sending authorization or claim end-to-end confidentiality.

## Alternatives and consequences

S/MIME through evaluated host/library adapters was offered and deferred. The chosen restricted profile reduces initial integration scope and retains a documented interoperability/security limitation. Full RFC 6047 authentication/conformance requires a future explicit profile change and implementation evidence.

## Acceptance conditions

Test absent/matching/mismatched component hints against actual payloads, spoofed/unknown authority and role/delegate checks, rejection/quarantine of unsupported protected messages, no plaintext downgrade of required protection, and no mutation/response side effects on rejection. Preserve transactional inbox/outbox ordering, retries, duplicate handling and VTODO rejection.

Documentation and release/client matrices must state the restricted profile. Test supported messages through the selected trusted host ingress; parser acceptance alone does not prove sender authority or interoperability.

Sources: [RFC 6047 authentication](https://www.rfc-editor.org/rfc/rfc6047.html#section-2.2.2) and [security requirements](https://www.rfc-editor.org/rfc/rfc6047.html#section-3).

Traceability: [RFC 6047 matrix](../rfc/rfc-6047.md), [requirements](../requirements.md), [compatibility](../compatibility.md), [ADR 0007](0007-scheduling-and-email.md), [mail integration work](../roadmap.md#scheduling).
