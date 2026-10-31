# Pure occurrence invitation projection

Accepted [ADR 0150](adr/0150-pure-instance-invitation-projection.md) implements `projectInvitationOccurrence` in the Serverpod module's value-adaptation layer. It accepts a complete accepted series, its independent component protocol state, one parsed detached REQUEST/CANCEL and the expected recipient address. It returns an immutable proposal and the original immutable parsed source. No endpoint calls it yet.

The accepted values and recipient are caller-supplied data. Success proves no sender authority, freshness, clean database baseline or permission. The helper reads no database and allocates no UUID, API revision, clock time, history or outbound intent. It does not read or change personal alarms. Later transactional application must independently resolve the actual link, reauthorize and verify the **entire linked series** against its accepted source baseline. Any local series or occurrence change must block that later application under the maintainer's confirmed policy.

## Selected behavior

Require exact UID, organizer and recipient correlation, an active recurring accepted master, and one exact original DATE/UTC/named-zone member. RRULE/RDATE/PERIOD/EXDATE and earlier explicit additions retain their existing meanings. Original identity remains distinct from moved timing. RANGE, bundles, delegation, same-original single/future collisions and unsupported differences reject without changing inputs.

| Source | Canonical proposal |
| --- | --- |
| REQUEST | Replace only this single occurrence's complete timing and supported own text/annotations; omitted text inherits, empty text remains explicit. A selected cancellation can be replaced. |
| CANCEL with STATUS:CANCELLED | Retain accepted timing, content and inheritance; set only this original's cancellation flag. Supplied timing/text/metadata must agree with its effective accepted values. |
| Attendee-removal CANCEL without STATUS | Reject in this projection; the pure parser's broader source support does not imply application support. |

Master content, recurrence, status and protocol version remain unchanged, as do unrelated singles/future edits and their versions. Future timing propagates according to the existing core policy; future-anchor content stays local to its anchor. The incoming selected component's independently optional source protocol values are preserved rather than passed through native timestamp/version allocation. The helper deliberately does not decide which version is newer.

Minimal cancellation keeps a null replacement null. An independently supplied DTSTART does not acquire a default end for comparison; only actually supplied timing fields are compared. A positive CANCEL DURATION may omit DTSTART, as permitted by the independently optional fields in [RFC 5546 section 3.2.5](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5). Parsing retains that duration without a derived span. Projection compares it using the known accepted anchor, without inserting a source start. Other methods retain their existing DURATION/start requirements.

For accepted DATE timing, cancellation DURATION requires day/week syntax; clock syntax such as `P1DT0H` rejects even when its numeric clock part is zero. For named-zone timing, nominal duration units retain calendar-first DST behavior: `P1D` and `PT24H` can yield different ends. End-versus-duration exclusivity and the whole-second [1970, 2100) profile remain unchanged.

Supplied text is compared after TEXT decoding; category/resource groups retain escaped-comma boundaries. Keywords and numeric priority use their profiled semantics. URI values and exact decimal coordinate spelling remain exact. Supplied legal parameters must match the retained property; omitted parameters do not erase accepted annotations. Differing metadata outside the supported occurrence profile rejects.

## Source, output and bounds

The result carries canonical content, overrides, protocol state, exact original and the original parsed message separately. Source omissions are never inferred from retained canonical cancellation fields. Standalone export retains its faithful-mapping guards: a follow-series cancellation may still reject export, and no invented time bypasses that restriction.

The default syntax envelope is reapplied even when a caller parsed with larger limits. The existing zone-count ceiling also applies. One candidate budget covers accepted recurrence validation, membership and the temporary REQUEST wire projection; callers can lower the 200,000 ceiling but cannot raise it. The **128 native override slots** remain independent of smaller wire/publication limits. A temporary REQUEST projection contains only the master and selected component, so unrelated native slots are preserved without promising larger wire export support.

Focused tests cover DATE/UTC/zoned values, DST, PERIOD and earlier additions, exclusions, independent versions/omissions, minimal/end-only/duration-only cancellation, annotations and grouped values, preservation/reopening, slot/work/syntax exhaustion and immutable results. Existing trusted intake also tests duration-only cancellation as review-only for linked and unlinked series. Actual commands and broader results are recorded in [validation](scaffold-validation.md).

Durable target checkpoints, source retention, master-update composition, latest-only retries and independently authorized application actions require a subsequent concrete review. Instance replies, RANGE reconciliation and real mail remain separate first-release work.
