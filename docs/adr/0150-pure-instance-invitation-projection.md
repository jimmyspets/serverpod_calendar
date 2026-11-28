# ADR 0150: Pure single-instance invitation application projection

Status: **Proposed on 2026-10-31. The maintainer confirmed a clean entire linked-series baseline for later explicit application; the concrete projection mechanics below require review.**

## Context and source evidence

ADR 0149 separates trusted single-instance REQUEST/CANCEL notices from master queue state. Receipt remains review-only. The maintainer selected explicit application with a clean entire linked series: any local series/occurrence change blocks later application. This policy is confirmed; database mechanics are not inferred from it.

Inspected event wire storage/output, single overrides, protocol-state/source-presence records, invitation import baselines and the one-per-link master application checkpoint. The existing whole-meeting checkpoint assumes its version belongs to the master and its digest matches the complete accepted projection. Reusing it for an instance would conflate master and occurrence versions. Minimal CANCEL may omit DTSTART, while ordinary standalone override export requires explicit DTSTART; manufacturing timing would pin native inheritance or lose source omissions.

Primary sources checked 2026-10-31: [RFC 5546 REQUEST](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.2), [CANCEL](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) and [RFC 5545 RECURRENCE-ID](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4). Original identity remains separate from moved timing. The stricter project profile below is not a claim that the RFC prohibits other payloads.

## Proposed pure prerequisite batch

Implement one bounded pure projection in the Serverpod module's value-adaptation layer, before proposing new durable target checkpoints. It receives a validated complete accepted series projection (UID/content/overrides/protocol state), one parsed detached REQUEST/CANCEL and the expected recipient address. It returns immutable proposed canonical values plus the original parsed source/omissions and exact original. It allocates no API revision, timestamp, outgoing version, identity or baseline history and performs no database access, authorization, mutation, arming, network operation or reply.

The caller-provided recipient and accepted values are data, not proof of trusted origin, ownership or a clean database baseline. Later transactional application must resolve the actual link, verify the full clean baseline, current source/versions, recipient/host authority and concurrency independently. Success here never establishes freshness or permission.

Require exact UID/organizer/recipient correlation, an active recurring accepted master, one supported detached original and exact original kind/zone/membership. Reuse RRULE/RDATE/PERIOD/EXDATE and earlier-addition semantics; charge bounded work across existing state and incoming target, with the existing 200,000 candidate ceiling and existing 128 native override slots. Preserve ordinary whole-second 1970–2099 dates, exclusive endpoint rules and full-horizon known-zone validation. RANGE/bundles/mode conversion/delegation and unsupported source differences reject explicitly.

## Proposed projection behavior

- REQUEST replaces only the selected single-occurrence component. Preserve its complete source timing/end-or-duration form and supported own text/annotations, with omitted text inheriting from the master and explicit empty text remaining an own override. Reuse existing occurrence wire/native profile checks; differing metadata outside that profile rejects rather than being discarded. A REQUEST may replace an accepted cancellation for this target; no other target is reopened.
- CANCEL sets only this original's cancellation state while retaining its accepted timing/content/inheritance. Missing DTSTART is not filled into the source or pinned into native replacement timing. Independently supplied timing/text/metadata must agree with the retained effective target under this first bounded application profile; reject unsupported differences. Preserve the exact parsed cancellation source and independently optional fields separately from the canonical cancellation projection. An end-only or duration-only payload is checked only for the fields actually supplied, without native defaults.
- Keep original identity, master content/pattern/status/version and every unrelated single/future edit unchanged. Preserve existing source/native distinctions and keep imported source alarms inert; the helper neither reads nor changes personal alarm definitions or execution state. Reject a single/future identity collision at the same anchor without removing the range component. Preserve the incoming component's independent source version/omissions; do not advance the master or call native automatic-version/timestamp rules. If the existing DTO profile cannot faithfully hold a particular distinction, reject that projection explicitly; do not add an unreviewed carrier/model field.
- Standalone export remains subject to its existing faithful-mapping guards. In particular, follow-series cancellation can remain unrepresentable for ordinary export; this helper does not invent an outgoing time to bypass that guard. The retained source remains separate from a canonical export projection.

The result carries the original parsed message so optional CANCEL data is not confused with the canonical values retained from the prior series. No raw source is silently stripped to make a standalone import profile pass. Caller mutation of inputs cannot alter the immutable result.

## Bounds, evidence and remaining work

Use focused pure VM tests for DATE/UTC/named zones and DST, PERIOD/earlier additions/exclusions, original-versus-replacement, selected content inheritance/empty values, source version omissions, minimal and independently optional CANCEL fields, preservation of unrelated components, cancellation/reopening and invalid/unrepresentable inputs. Verify work/slot exhaustion and no mutation on failure. The existing generated server-carrier boundary remains VM-only; reusable temporal semantics remain independent of Serverpod and Flutter. Run complete grouped repository checks before one implementation commit.

No SQL/table/generated-model/endpoint or Flutter editor change is proposed. Durable application, per-target accepted checkpoints/retention, master-update composition, latest retry identity and independently authorized native actions require a subsequent concrete storage/API review. That later design must enforce the confirmed clean-entire-series policy and must not reuse master version fields as instance versions. Instance replies, RANGE and real mail remain separate requirements.

## Alternatives and consequences

Implementing durable writes immediately would require committing to target-checkpoint and minimal-source storage before demonstrating a faithful value mapping. Reusing the master checkpoint would mix component versions; inventing DTSTART would change inheritance. The pure prerequisite exercises those boundaries without introducing partially reviewed persistence. It is not a new claim that review-only notices can already mutate calendars, and it does not remove any remaining first-release requirement. Existing native and wire caps remain separate; support for 128 native slots does not promise a 128-component wire export.

## Review gate

Approve the pure projection prerequisite and its explicit reject/retain boundaries before implementation. Acceptance of this ADR would not approve a database schema or enable instance calendar mutation. [AGENTS.md](../../AGENTS.md) requires: “Proposed ADRs become accepted only after explicit maintainer agreement.” This review covers the pure mechanics only; later storage/API approval remains separate.
