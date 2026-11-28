# ADR 0183: Incoming event publication review and calendar workflow

Status: **Accepted by explicit maintainer agreement, 2026-11-13.** The maintainer approved the complete grouped workflow, four-table/cursor storage and API/retention mechanics in PR #197 after separately confirming review first and explicit Add/Apply. Implementation and actual validation remain separate.

## Context and inspected evidence

ADR 0182 implements native outgoing PUBLISH/update and whole cancellation/reopening in [PR #196](https://github.com/jimmyspets/serverpod_calendar/pull/196), commit `4e8ff4a4da937a5cef72cb761bbfe64db71078c9`. Its local group passed; exact-head [run 43386362933](https://github.com/jimmyspets/serverpod_calendar/actions/runs/43386362933) has successful inspection and runtime still in progress at this proposal's preparation. That is not a runtime success claim.

[RFC 5546 section 3.2.1](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.1) defines informational PUBLISH with an organizer and without attendees, subsequent PUBLISH updates and CANCEL withdrawal. [The publication examples](https://www.rfc-editor.org/rfc/rfc5546.html#section-4.1) distinguish this one-way exchange from participation replies. These facts do not prescribe automatic calendar adoption, mailbox trust or the storage design below.

The current pure codec and decoded/raw MIME boundaries can validate these source methods. Existing invitation intake instead requires an attendee/recipient relationship and has permanent invitation/bundle/instance/range histories. Removing that attendee check or relabeling a publication as an invitation would manufacture participation or weaken existing purpose guards. The next group should reuse the established review/conflict/retry workflow and shared pure/transaction helpers while keeping publication inbox persistence and APIs separate.

## Proposed complete feature group

Implement trusted intake, private paginated review/source read/dismissal, explicit one-event Add to calendar, explicit clean-series PUBLISH update, whole CANCEL application and newer PUBLISH reopening together. Include generated APIs, example synthetic MIME ingress, Flutter, fresh/populated migrations and real two-host/process-loss validation in one feature commit. Receipt and dismissal never create/update a calendar, book time, arm alarms, create attendee state or send mail.

The first wire profile accepts exactly one non-detached VEVENT master with the current supported DATE/UTC/named-zone, text/metadata and RRULE/RDATE/EXDATE/PERIOD profile. Keep the whole-second 1970–2099 storage bounds and full-horizon pinned-zone validation. Retain source UID, independently optional SEQUENCE/status/transparency/timestamps and legal annotations/metadata. Do not infer API identity or ownership from source claims. A complete PUBLISH with CANCELLED status is retained as such and requires lifecycle authority when adopted/applied; native confirmed fallback for an omitted source status retains the omission.

Every VALARM, attendee, instance/range component, multi-event packet or unprofiled property rejects explicitly. The first CANCEL slice accepts the existing supported whole-master cancellation shape with explicit STATUS:CANCELLED and no attendees, not every legal RFC cancellation form. Supplied ordinary timing/claims must match the retained complete publication basis; cancellation-specific source comments remain source data and never silently replace event comments. Unknown-correlation cancellations reject; no placeholder calendar event is created.

The first accepted correlation fixes recurring/non-recurring mode. Mode conversion, organizer change, detached/complete occurrence publication, ADD/REFRESH/COUNTER, reviewed overwrite/merge and native organizer adoption remain separate. These exclusions are required follow-up scope, not claims that the RFC forbids them.

## Trusted purpose and authorization

Add a server-only immutable delivery carrier and replaceable incoming-publication host adapter. The host resolves the actual scope and opaque recipient, verifies publisher/delegate authority and the intended publication purpose for the exact message/correlation, then separately authorizes each operation. MIME headers, ORGANIZER, sender-display strings, client IDs and absence of ATTENDEE are not proof. A cancellation never falls back between invitation and publication handlers; an ambiguous route requires trusted resolution or rejection.

Keep dedicated publication operations for intake, header listing/read, raw source, dismissal, protected link state, adoption, update, cancellation and reopening. Source reads, mutation and lifecycle permissions remain independent. Calendar writes also require actual native create/update/lifecycle permissions and same-scope destination context; updates require current complete native detail/source access because clean/conflict results can reveal hidden content. Hosts may map operations to their own rules. Source addresses grant no host role, assignment or resource reservation.

Host contexts carry actual recipient, private entry/current source, exact normalized bytes/digest/version, accepted basis, actual target calendar/event and current/final proposed native state. Recheck declared coordinated/fresh-check guarantees at preliminary/final phases without silent downgrade. External checks retain their after-check revocation race. Intake runs without a fabricated login; Add/Apply resolve the actual authenticated actor and recipient authority. Generic invitation reads/adoption/application/response paths cannot discover or operate on these separate rows.

## Identity, versions and command behavior

Private logical identity is exact publication-purpose/scope/recipient/verified-organizer/UID correlation, separate from native event UUID and source/delivery/command UUIDs. An invitation with the same organizer/UID remains a different purpose. One recipient publication can link to one event in one explicitly chosen calendar. Exact Add retries return that event; never create a second copy, change calendar or recreate a deleted event implicitly. Destination-calendar active protocol-UID conflicts reject atomically.

Use the existing invitation-style source ordering as an explicit application policy: lower effective SEQUENCE rejects even with a later stamp; equal SEQUENCE needs a later DTSTAMP for changed source; exact normalized source/version equality is a duplicate. Omitted SEQUENCE compares as zero but stays omitted in stored/source views. Equal version tuples with different content reject as conflict. A higher SEQUENCE may carry an earlier timestamp; no source timestamp proves authority. Preserve accepted versus newer private-review source independently, and recheck both floors before application. Exact retained ingress receipts are handled before new admission/quotas without reactivation.

Add and Apply require selected entry/source identity and expected inbox revision; Apply also requires the linked event's expected API revision and a clean entire accepted native series. Any local content, timing, exception or lifecycle edit blocks replacement; personal alarm/actions are separate and survive compatible changes. No occurrence merge is attempted. Preserve canonical source distinctions and source protocol versions while recording native API/audit time separately.

A linked event uses imported origin and the existing private import-baseline machinery. Ordinary file source replacement rejects publication-linked events on every host, even without an installed intake adapter. Full new PUBLISH replacement updates native content/baseline and accepted source together. Whole CANCEL projects cancellation/version onto the retained publication without erasing text, timing, source omissions or the complete basis. Preserve that exact basis and cancellation's independent descriptor, as in the lossless invitation lifecycle policy. A newer complete PUBLISH explicitly reopens/replaces only through the clean-baseline and independent lifecycle gates.

Creation command/result identity is immutable. Keep one separate latest Apply command/result on the link; a later Apply supersedes older Apply retries, while the retained creation receipt stays valid. Bind principal, source/digest, operation, criteria, expected revisions and chosen target before admission. Retained retries reauthorize actual proof/current access and return the historical result without editing later state. Identical already-accepted source is a true write-free no-op. Source-version changes are not that no-op. Commit entry review state, event/baseline/link/checkpoint, scope/feed/alarm fencing and receipt atomically under the shared database scope transaction.

## Proposed storage boundaries

Reuse shared core projections, temporal validation, normalized-source/version comparisons, bounded work and transaction helpers; do not fork a second scheduling codec or RPC-to-RPC mutation path. Propose four new server-only tables rather than widening every legacy invitation correlation/response path:

| Record | Private contents and purpose |
| --- | --- |
| `CalendarIncomingPublicationRecord` | Stable entry UUID; trusted scope/recipient; exact organizer/UID correlation digest; fixed mode; current review source/version/digest; revision, dismissal and audit state |
| `CalendarIncomingPublicationSourceRecord` | Entry/source UUIDs; bounded normalized one-master PUBLISH/CANCEL; digest, exact optional version and kind; receipt/expiry/retention times |
| `CalendarIncomingPublicationReceiptRecord` | Scope/namespace/trusted-recipient ingress identity; criteria/source bindings and stable outcome; received/retention time; no copied source body |
| `CalendarIncomingPublicationLinkRecord` | One protected entry-to-calendar/event identity; immutable Add command/result and creation-source reference; accepted current/complete-basis source references and baseline digest; independent cancellation descriptor; latest Apply command/result; deletion marker |

Use module-prefixed table names and generated UUIDs, unique private correlation/ingress/one-entry-one-event constraints, and indexes for recipient/entry/source expiry. Add one nullable server-only `incomingPublicationState` JSON value to the existing cursor table; old cursor families retain null and their behavior. Its immutable state contains only publication family/recipient/criteria, authorized-scan basis digest and continuation identity, never source text or cached grants. Require actual principal/scope/policy/expiry/criteria binding and fresh bounded candidate-basis validation before continuation. No totals or partial-success pages. Under the entry cap, rechecking a source/revision basis avoids adding a process-local cache or a sixth generation table.

The link pins its immutable creation source, current accepted source and complete lifecycle basis while needed. Those references must remain reconstructable after ordinary review history pruning. The existing event import baseline is private active-data content; do not invent a baseline or infer a clean history. Deleting the linked event scrubs accepted proof/baseline copies and releases those source pins atomically, retaining only a content-free private link/command marker that prevents recreation. Independently received inbox source data remains under its explicit inbox retention, like received source mail; event deletion is not a promise to erase a separate private inbox. Never return a deleted event through ordinary event APIs.

## Proposed limits and retention

These are host-configurable application limits within fixed hard wire/work ceilings, not RFC requirements:

- At most 512 KiB decoded calendar data per message and one master; existing stricter syntax/parameter/zone/core budgets still apply.
- Default 256 entries per recipient and 1,024 per scope; 32 retained source bodies and 64 ingress receipts per entry. Reject capacity exhaustion without silently dropping required proof.
- Default 16 MiB retained source/proof bytes per recipient and 64 MiB per scope, counting pinned sources and active private baseline/proof storage; one link's complete source/baseline/proof is bounded to 2 MiB. Shared accounting is transactional across hosts, not independent per-call limits.
- Authorized pages default to 20 and cap at 100; charge at most 1,000 raw candidates per request before disclosure filtering and reject incomplete work rather than imply exhaustion.
- Superseded/unaccepted terminal source/receipt history defaults to 30 days. Retain active/creation/accepted-basis references while the link needs them; prune receipts/references before unpinned bodies. Deletion markers remain bounded by entry/link caps until a separately reviewed purge policy, not an unbounded restore feature.

The concrete generated sources must implement only these approved boundaries; do not add schema, hidden history, a notification inbox or larger limits opportunistically. All current tables/roles/receipts remain unchanged by this proposal; populated upgrades must prove that.

## Example and validation acceptance

Add a separate **Published events** review screen and explicit Add/update/cancel/reopen controls, no Accept/Tentative/Decline controls. Carry original command IDs through uncertain retries and show current versus accepted source versions/local conflicts distinctly. The example host adds a purpose-specific raw-MIME wrapper and synthetic provider-proof adapter only; no public endpoint accepting a claimed trusted sender, SMTP, real email, provider authentication, automatic image/URI retrieval or alarm activation.

Validate master DATE/UTC/zoned recurrence/PERIOD and omission preservation; PUBLISH with/without explicit status; minimal supported CANCEL and complete producer CANCEL; wrong-purpose/forged-origin/foreign-recipient denial; duplicate/stale/equal-tuple conflicts; trusted version/order; final authorization rollback; private list/source/link disclosure; cursor stale/family/criteria/policy/work limits; same-calendar UID conflicts; exact Add/latest Apply retries; dirty-entire-series rejection; cancellation/reopening with personal state intact; deletion scrubbing/pin retention/capacity; and unchanged invitation/outgoing-information behavior.

Exercise at least two real host processes sharing test storage, competing same-correlation receipt/Add/Apply commands, actual loss before/after commit, cross-host policy changes and source/history pruning. Send ADR 0182 synthetic PUBLISH/update/CANCEL/reopen MIME through the new trusted receiver and generated JWT/Flutter workflow without real mail. Run focused tests during development, broader package VM/Chrome and relevant integrations at group end, fresh/populated migrations, stable generation, release build and the full exact-head hosted gate before readiness. Commit/push the complete approved implementation once.

## Alternatives and consequences

Automatic receipt-to-calendar mutation contradicts the confirmed review-first policy. Reusing invitation rows with an implicit no-attendee fallback would require purpose/index/retention/response rewrites across existing histories. Four separate private records cost schema but keep role/correlation and API isolation explicit while sharing established helpers. A detached source-document archive or generic mailbox is outside this bounded feature. This proposal completes only one-master publication consumption and whole lifecycle; occurrence/bundle publications, remaining methods, retirement/recipient changes, real transport and external-client release evidence stay on the roadmap.


## Accepted implementation refinement

Review of the producer-to-consumer lifecycle exposed a distinct pending-update case: a CANCEL can describe the publisher's newer PUBLISH while the recipient's linked event still contains the older accepted publication. Matching that cancellation against only the native accepted basis would reject it or accidentally require adopting an update the recipient has not approved.

Propose preserving both meanings. A CANCEL source gets one nullable `basisSourceId` referencing a retained complete PUBLISH source for its exact source-timing/content match. The link's existing `basisSourceId` continues to mean the native accepted complete basis. Applying CANCEL changes only status/version on the accepted native values, leaving pending newer values unadopted. Source views/host context distinguish the cancellation source basis from the accepted native basis. Each referenced basis must be a complete same-correlation PUBLISH, never another CANCEL; no recursive chain is permitted.

Protect this source-to-basis reference transitively while the current review or any retained accepted/creation/link proof needs the cancellation. A terminal cancellation/source basis may prune together after ordinary retention. Count every distinct referenced body and baseline against the existing entry, link, recipient and scope byte/slot caps. Add only that one nullable source-reference field (and immutable source/host-view projection), no table or capacity expansion. Existing legacy invitation/outgoing tables stay unchanged. Prove receive-review-cancel of an unapplied newer update, native text/timing preservation, later explicit newer reopening, pruning and multi-host rollback/retries. The maintainer explicitly approved this separate source-basis field, immutable projections and transitive retention under unchanged caps on 2026-11-13.
