# Authenticated attendee replies

The accepted [ADR 0131](adr/0131-first-authenticated-attendee-replies.md) adds an organizer-side REPLY increment, extended to recurring masters by accepted [ADR 0132](adr/0132-recurring-master-attendee-replies.md). The scoped local batch checks passed in phases; see the validation record for commands and limits. It preserves the exact supported source distinctions and stores participation separately from native event content. RANGE replies (single instances now follow under ADR 0133), other inbound methods, delegation, mail transport and manual conflict adoption remain separate requirements.

## Trusted ingress

Call `CalendarModule.receiveSchedulingReply(session, delivery)` only from trusted server code. Install `CalendarSchedulingRuntime.replies` with a `CalendarSchedulingReplyHost` and bounded options. There is no reusable ingestion endpoint or client-supplied verified-sender flag. The host selects an actual event in a trusted scope and supplies a namespaced delivery key and origin reference. It must verify that origin may respond for the exact stored attendee address. Source UID, ORGANIZER, ATTENDEE, session display addresses and SMTP headers establish no such authority.

The module loads the actual calendar/event/binding and committed publication, requires explicit native provenance, a validated non-recurring or recurring published master, the exact protocol UID/organizer and a member of the fixed roster, and validates one bounded pure REPLY. RANGE and delegated/SENT-BY flows reject; single originals use the separate target profile below. Ordinary file import and bearer feeds never provide scheduling authority.

Preliminary host approval precedes private reply history lookup. Both proposal and final checks receive immutable actual current/published event and parent, complete normalized source, digest, origin reference, current response, proposed classification and server source/receipt IDs. The final check runs after proposed writes inside the scope transaction: denial or failure rolls back all three tables. Hosts declare coordinated or fresh-check guarantees; external fresh checks retain the documented after-check revocation race. No process-local lock or cached permission supplies correctness.

The initial origin-only check omits private history. Later proposal/final checks carry the actual current response or an explicit unknown descriptor, including on a retained retry whose original source has since been superseded. `isRetry` distinguishes returning an old receipt from proposing a new participation update.

## Classification

Compare with the latest committed published invitation, including pending delivery, rather than newer native drafts or provider success. Source SEQUENCE omission compares as zero and remains absent in source/storage responses. Lower versions remain stale; higher versions remain unmatched. A cancelled published invitation admits no participation update. Non-success REQUEST-STATUS remains an unapplied result and starts no retry or automatic message.

For an active matching invitation version, supplied ordinary event properties must match the published component under the selected exact value/parameter profile. Omitted properties stay omitted. COMMENT and REQUEST-STATUS belong to the response. Differences remain a reviewable conflict and never become event edits. Stale/unmatched records do not claim to validate optional values against unavailable historical invitations.

For that attendee and invitation version, a later DTSTAMP applies, an earlier stamp is stale, and an equal stamp with a different normalized source is a conflict. Exact source duplicates never advance the response. Arrival time is separate database audit time. A verified sender's future clock is retained; it can prevent older source stamps from applying until a separately designed correction policy exists. Hosts may impose an explicit clock policy through their adapter.

PARTSTAT retains optional source presence, with the RFC NEEDS-ACTION default exposed separately. Applied values are NEEDS-ACTION, ACCEPTED, DECLINED and TENTATIVE. A roster member without a response is **unknown/not recorded**. Outgoing invitation parameters do not create a response. A later invitation exposes the old checkpoint as prior-version data, never acceptance of the new invitation.

## Storage and retries

Three server-only tables hold normalized source, host-ingress receipts and one applied checkpoint per binding/attendee. Scope transactions and database uniqueness serialize independent instances. Normalization uses deterministic pure serialization and preserves supported source property/group order; it is not a universal semantic-equivalence test. Digests also require exact source comparison.

Same namespace/delivery key and exact source returns the retained receipt after fresh approval, without writes. Reusing that key with different source rejects. Exact source under a new delivery key shares the source and gets a duplicate receipt, without advancing participation. Transient host failures retry with the same key and exact body-defining values.

Default limits are 512 KiB source, 256 sources/1,024 receipts per binding and 4,096 sources/8,192 receipts per scope. Existing rosters remain bounded to 64. Options may lower the per-binding limits and configure scope budgets. Exhaustion rejects atomically; retained data is never evicted to admit new input. All received bytes are copied before awaits. Parsed and stored models are revalidated before protected disclosure or ordering updates.

The generated additive module/example migrations create empty tables and preserve existing content. No development reset is required. API revisions, native protocol versions/baselines, calendar/feed scope generation, outbound publication generation and delivery leases are unchanged by replies.

Upgrade every concurrently active publishing host to this module version before enabling reply intake. Older binaries do not record the inactivity boundary when publishing a new invitation; mixed-version retention behavior is not covered by this batch.

## Retention

Scheduling maintenance performs bounded cleanup, with a configurable 30-day default. Unapplied sources start retention at receipt time; superseded sources and replies to newly inactive invitation versions record a database-time inactivity boundary. Active-version applied source remains to preserve ordering even after receipts expire. Unexpired ingress receipts retain their source; duplicates can extend that reference lifetime. Cleanup removes expired receipts before obsolete checkpoints/sources. No automatic application follows pruning, and transport deduplication is guaranteed only while its receipt is retained.

Existing binding/parent deletion guards remain. This increment adds no binding deletion API or implicit cascade.

## Review APIs and example

`calendarEvent.schedulingResponses(eventId)` returns bounded current/prior/unknown roster summaries. `schedulingReplySources(eventId)` returns a bounded all-or-nothing descriptor list. `schedulingReplySource(eventId, sourceId)` returns one explicit source document. These APIs expose no totals, new cursors or host transport keys.

Independent `readSchedulingResponses` is required alongside scheduling and full event/source access. Review descriptors/documents additionally require `readSchedulingReplySource`, with actual source UUID/metadata/body supplied to host policy. Summary responses contain no comments/body. Ordinary event APIs, export and feeds never include reply tables.

The example installs a **development/test-only synthetic simulation**. The server verifies the authenticated private demo owner and fixed `example.invalid` roster; this does not verify a real mailbox. The Flutter **Attendee replies** screen shows current/prior/unknown responses, simulates a response with stable uncertain retries, and explicitly opens retained private source as inert selectable text. It never applies stale records or sends mail. Production hosts supply their own trusted ingress.

See [validation](scaffold-validation.md) for commands actually run and their limits. Synthetic tests do not establish RFC 6047 mail or external-client interoperability.

## Recurring master resolution

A master REPLY has no RECURRENCE-ID/RANGE. Minimal replies may omit timing and recurrence; supplied rule/date sets compare canonical typed values, exact DATE/UTC/named-zone profiles and preserved PERIOD end/duration forms. Source groups and omissions remain intact. Single-instance replies now use the ADR 0133 profile below.

The current target comes from validated self-contained checkpoint evidence. Complete REQUESTs use their master; detached cancellations/restorations retain their active master basis. v6 uses the actual last complete REQUEST, including publication-only exclusions. Whole-series CANCEL is inactive and uses its cancellation version. Missing or inconsistent evidence fails unavailable; cleanup of older publication rows does not require reconstructing from private drafts.

`publicationId` identifies the latest checkpoint carrier, while `publishedSequence` identifies the actual master version. `recurring` labels a whole-series response. A detached occurrence's higher SEQUENCE is not a newer master invitation. Unchanged masters preserve current responses and source ordering; changed masters or whole cancellation record source inactivity within the same scope transaction, including v6 reopening and complete masked restoration. All publishing hosts must carry this hook even without an inbound adapter.

Trusted reply policy receives `publishedMessage`, `publishedMaster` and `latestPublicationKind`, separately from canonical `publishedEvent` and actual `currentEvent`. The complete retained message is validated, including occurrence components; no stripping or native mutation manufactures a supported target. Read policy also receives the exact published message/master through `replyPublishedMessage`/`replyPublishedMaster`. Hosts must upgrade these unpublished interfaces together. ADR 0132 reused the three tables without a migration; ADR 0133's target fields below now require its additive migration. Limits and retention rules stay unchanged.

The example keeps whole-series and single-occurrence responses on distinct screens. Synthetic responses remain inert with respect to native content, mail and remote participant authority.

## Single-instance replies and legacy publication upgrade

Accepted [ADR 0133](adr/0133-single-instance-attendee-replies.md) admits one exact RECURRENCE-ID without RANGE or recurrence-pattern properties. Membership uses the actual published series and exact DATE/UTC/named-zone profile, including earlier inclusions/PERIOD originals. A moved DTSTART never changes the original identity. An explicit single component wins, otherwise the latest applicable timing-range component, otherwise the master. Range-anchor text stays local to its anchor under the existing publication profile. Supplied ordinary fields must match the effective occurrence; omitted source fields stay absent. A source pattern/RANGE rejects rather than being flattened.

`calendarEvent.schedulingInstanceResponses(eventId, originalStart)` returns the fixed bounded roster for that original, never inherited master acceptance. No response is unknown. Removed historical targets remain prior with nullable current publishedSequence/publishedCancelled; querying allocates no row. New intake for removed/unproven originals rejects. An exact retained delivery-key/body retry can return its original receipt after fresh authorization even after removal, without new writes or changing a newer response. Its host context declares an unknown current target version instead of substituting an old admission version. Master queries select only master checkpoints. Source descriptors/documents retain optional original identity under their separate read permission.

The source table adds targetKey, nullable originalStart and targetBasisKey; responses add targetKey and uniqueness across meeting/attendee/target. Existing source/receipt uniqueness, receipt columns and caps stay unchanged. Instance keys hash an explicit versioned scalar original representation; exact typed originals are compared after lookup to reject collisions/retargeting. The basis key is server-derived and grants no authority. Old rows become master records through generated defaults. Current ordering is protected per active target, and every publisher updates inactivity inside its shared scope transaction, even without an inbound adapter. Membership work shares one aggregate budget; failure never means absent/free.

New full publications carry `instanceVersionProfile: 1` in their existing v3 private checkpoint. Partial v4/v5 and v6 workflows inherit it from their validated self-contained basis; an outer claim cannot invent it. Unknown/malformed markers fail unavailable. A newly introduced component starts above the maximum retained outgoing version. Existing unchanged component versions stay stable; range applicability comparisons also include the master's recurrence/exclusion profile. The first deliberate full Save and notify for a legacy checkpoint allocates a common newer outgoing floor for master/components and sends an actual new invitation. No read, partial command or background job silently upgrades it. Exact retained retries stay immutable. Existing cancellation and terminal-delivery guards still apply. Native source versions and inheritance are not rewritten to pin these scheduling values.

Trusted ingress adds originalStart/publishedTarget/effectiveOccurrence. Read policy receives replyOriginalStart/replyPublishedTarget/replyEffectiveOccurrence, alongside the complete published message/master and actual parent/current native state. Current version/active fields may be null for an authorized retained retry whose original no longer has a current target; hosts must handle that explicit unknown. Source validation precedes protected disclosure and checks redundant target fields against the immutable normalized source.

The example has an explicit original civil-value/profile selector; it does not infer an original from moved timing or device timezone. It labels single responses as independent from other occurrences and the whole series. A selected original is frozen with an uncertain simulation retry. The development/test-only simulator remains synthetic and sends no mail.
