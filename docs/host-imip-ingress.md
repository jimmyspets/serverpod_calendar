# Host MIME ingress into native scheduling

The wrapper now carries the approved [single-instance review profile](single-instance-invitation-review.md) under ADR 0149 into the existing trusted native intake. Exact decoded bytes, independent origin/recipient/occurrence authority and known-series membership checks still apply. A successfully received instance notice changes no calendar or participation state and sends nothing.

Accepted [ADR 0145](adr/0145-host-mime-native-ingress.md) adds two example-server functions in lib/src/imip_ingress.dart. They connect [bounded raw MIME extraction](raw-imip-extraction.md) to existing server-only calendar APIs. No table, migration, generated endpoint, new dependency, production mail receiver or network sending is added.

| Function | Explicit host input beyond original MIME/protection | Existing native destination |
| --- | --- | --- |
| receiveHostImipInvitation | Session, namespace, delivery key, origin reference | One non-recurring VEVENT REQUEST or whole-meeting CANCEL; private review only |
| receiveHostImipReply | Same, plus host-resolved scope key and native event UUID | Existing non-recurring, recurring-master and single-instance VEVENT REPLY handling |

The caller selects the wrapper. Neither function discovers a route, calendar, event, actor or recipient from UID, participant addresses, From/To/Reply-To, Subject or Message-ID. Server-side arguments are references for the installed host to verify, not proof merely because they were supplied. The actual Session is passed unchanged; no login or actor is fabricated. Production provider/sender verification and target resolution remain a replacing host's responsibility and are not implemented by this example.

## Validation and authority

Both functions require the actual outer-protection marker and complete original raw bytes. The entire raw MIME/calendar gate must pass before accessing the native module. Wrong wrapper methods, VFREEBUSY and other unsupported component/routes reject explicitly without fallback. The invitation carrier has a 256-KiB decoded limit; the reply carrier has 512 KiB. Raw transport remains limited to 1 MiB. Lower configured native limits are still enforced by the module.

The exact decoded calendar bytes enter the existing immutable delivery carrier. The wrappers do not regenerate VCALENDAR, strip METHOD, add missing timing/versions or manufacture native defaults. Existing native parsers still reject unsupported shapes, recurring invitation intake, delegation and RANGE replies. A successful pure parse therefore does not promise native acceptance. Native normalized source storage and digest rules remain unchanged; byte forwarding is not a new raw-mail archive.

Installed invitation resolveDelivery/authorize and reply authorizeReply checks retain their preliminary/final phases, actual object/publication context and declared consistency guarantees. Current source/version/original-membership rules, recipient isolation, unknown/expired-source checks and rollback remain native responsibilities. MIME/header success never bypasses them.

HostImipMimeException reports only existing bounded host error kinds for MIME/protection/profile/limit failures. Existing native CalendarException results propagate unchanged. Denial, unavailability or malformed input never returns a successful receipt or retries another native handler.

## Retries and state changes

Only the explicit host namespace/delivery key establishes delivery identity. Supported transfer encoding, alternative-container layout and Message-ID can change around the same calendar bytes without creating a different native retry. Conflicting content under the same key follows the existing native rejection policy. Reusing the fixed synthetic Message-ID with a different host key does not merge deliveries.

REQUEST/CANCEL intake changes only authorized private invitation review state. It never adds/applies an event, arms an alarm or sends participation mail. REPLY handling changes only the existing private source/receipt/attendee-response state. Local event drafts, canonical event source state and outgoing messages are preserved.

## Synthetic example and probes

The existing development/test simulators retain their signatures, login/current-user/role checks, example.invalid restrictions and server-built origin references. They now compose bounded base64 MIME through the existing enough_mail library and invoke the corresponding wrapper. Clients still cannot submit arbitrary raw mail or origin proof.

The fixture composer uses fixed transport@example.invalid and fixture@example.invalid envelope addresses, fixed subject/date and the same synthetic Message-ID for every input. These deliberately differ from participant identity and prove nothing about it. UTF-8 bytes/CRLF are preserved; invalid UTF-8, a leading BOM and over-limit input reject rather than repair. MIME is not archived or sent. Library errors remain non-echo failures.

Invitation and reply independent-process probes now enter through these same wrappers. Their competing claims, before/after-commit loss, stable receipts and source effects remain the assertions. Existing invitation/reply Flutter journeys use the unchanged generated APIs and now exercise this MIME bridge.

## Evidence and remaining requirements

Focused tests cover route/protection rejection before native access, exact immutable bytes/omissions, byte-cap asymmetry, lower configured caps, forged headers/origin denial, final rollback, source UID/target isolation, all selected transfer encodings, flat alternatives, stable retry keys and conflicting content. Exact commands/results and broader validation are recorded in [the validation guide](scaffold-validation.md).

Real provider authentication/ingress, network transport, attendee participation sending, recurring invitation reconciliation, remaining scheduling methods/lifecycle and external interoperability remain separate requirements. This bridge does not complete RFC 6047 or authorize real mail.
