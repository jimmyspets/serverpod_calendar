# ADR 0153: Explicit single-instance attendee responses

Status: **Proposed 2026-10-31. No runtime or model approval is inferred from the preceding batch.**

## Context and evidence

Accepted ADRs 0146/0148 implement explicit private non-recurring/recurring-master participation replies, separately from calendar addition/application. ADRs 0149–0152 add known-series instance intake, application and preserved master composition. Sending a single-instance response remains unavailable: the response service enforces master-only entry guards, the minimal REPLY writer omits RECURRENCE-ID and workers admit only master REQUEST source kinds.

Inspected the response service, worker, host context, three response tables, known-series basis resolver, generated views, MIME recording and Flutter controls. [RFC 5546 section 3.2.3](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.3) profiles REPLY and its instance identity; [section 3.7.1](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.7.1) describes independent recurring-instance references and versions. Primary text checked 2026-10-31. The narrower admission, persistence and lifecycle rules below are application policy.

## Proposed grouped scope

Extend the existing explicit Accept/Tentative/Decline workflow to a selected current single-instance REQUEST already admitted through trusted known-series intake. Require its exact original and source/revisions; reject RANGE, bundles, detached unknown-series claims and instance CANCEL as new response bases. Do not add arbitrary occurrence selection from a master in this increment. A response changes only private participation/outbound state for that selected entry, never the master response or sibling instances.

Keep calendar actions independent: adding/applying the meeting is not required to respond, and local event edits neither send a reply nor become outgoing content. Reuse the existing known-series basis resolver: current retained recurring REQUEST first, otherwise a validated linked accepted baseline. Check exact kind/zone/original membership and attendee presence. A known cancelled master or removed original blocks a new response; unavailable evidence fails unavailable. This source-basis check does not authorize calendar mutation or imply a clean native draft.

The minimal outgoing REPLY includes exact UID and original RECURRENCE-ID, the selected REQUEST's independently optional SEQUENCE, actual strictly later whole-second database DTSTAMP, verified ORGANIZER route and one verified ATTENDEE/PARTSTAT. Never substitute moved DTSTART, master SEQUENCE, a calendar label or an unverified address. Preserve DATE versus UTC versus exact named-zone original identity, use bounded pinned-zone output/validation when required, and retain existing 32 KiB payload limits. Omit range, timing, title, source alarms, links, participants beyond the verified responder and optional descriptive data. An older component version is not silently normalized; the organizer still validates freshness.

## Proposed authority and lifecycle

Require existing invitation/source-read and personal response read/send/dispatch authority. Add `sendOccurrence` and `dispatchOccurrence` operations to the response host contract, checked in addition to ordinary send/dispatch for instance commands and workers; retained command retries still require the instance-send gate. Supply immutable actual selected invitation/source/original and available known-series basis, current/proposed private response, complete outgoing message/digest and trusted recipient/route to preliminary/final/dispatch authorization. Background workers fabricate no actor. Fresh external policy retains its documented after-check race.

Before dispatch/retry, recheck current selected source/generation, known-series membership/lifecycle, recipient access and complete payload/route authority. New selected instance source/CANCEL, changed intent, known removed original or known whole-series cancellation withdraws pending work. A newer master version alone does not rewrite an independent target's source version or replace its personal choice when the target remains valid. Unavailable evidence retries within existing expiry; no missing source is reconstructed. Accepted in-flight submissions cannot be recalled and delivery remains at least once under uncertain acceptance.

Preserve exact retained command retries before new admission. Reauthorize actual current/retained evidence, returning the original immutable receipt without resending, changing native state or dismissing a newer notice. Expose unavailable current basis explicitly to trusted policy rather than inventing it. Existing strictly later database-second clocks, command UUID criteria binding, CAS, source pins, terminal pruning, worker leases/fences, quotas and expiry remain.

## Proposed storage and API

Reuse the existing state/delivery/attempt tables and limits. They already key state by invitation entry, and instance entries have separate stable identities. No new SQL table/column, retention expansion or invented progress/history is proposed. Master payload bytes and retained hashes remain unchanged; first instance deliveries use the approved new target-aware projection and record validation.

Add optional `originalStart` (null for masters) and a derived `canSend` flag to protected response views, plus optional `occurrenceBasis` and explicit basis-unavailable context to the host adapter. Make the affected response-view carrier immutable so host snapshots remain stable. `appliesToCurrentSource` continues to describe the recorded choice's exact source; it does not establish current send eligibility. Generate the carriers from their sources. Keep existing command fields and explicit invitation/source/revision selection. Flutter labels the selected original, preserves uncertain command UUIDs and provides separate calendar and participation controls. Source and response information remain private, without totals or sibling content disclosure.

## Validation and alternatives

Test DATE/UTC/named zones and DST, moved originals, independent source sequence omission/zero/versions, master/sibling isolation, unadopted known-series replies, unavailable/pruned evidence, cancelled/orphaned sources, all separate gates/final rollback, clocks/CAS/retained retries, limits/source pins, supersession during submit, two-host workers and actual process loss. Exercise exact synthetic MIME bytes, trusted organizer single-instance REPLY loopback, generated clients and Flutter, followed by complete agreed batch checks before one implementation check-in.

Responding to arbitrary originals from a master requires a separate selection/version contract and is deferred. Requiring calendar adoption would break the confirmed separation between participation and calendar actions. Automatically copying master participation onto instances or changing local events would invent user intent. RANGE responses, delegation, counters, source adoption, broader reconciliation and real transport remain separate original-scope work. No external scheduling-client interoperability is claimed from synthetic evidence.

The repository requires explicit agreement on this concrete protocol/authority/model batch before implementation. This proposal does not change runtime behavior.
