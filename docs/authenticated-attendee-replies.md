# Authenticated attendee replies

The accepted [ADR 0131](adr/0131-first-authenticated-attendee-replies.md) adds an organizer-side, non-recurring REPLY increment. The scoped local batch checks passed in phases; see the validation record for commands and limits. It preserves the exact supported source distinctions and stores participation separately from native event content. Recurring/instance replies, other inbound methods, delegation, mail transport and manual conflict adoption remain separate requirements.

## Trusted ingress

Call `CalendarModule.receiveSchedulingReply(session, delivery)` only from trusted server code. Install `CalendarSchedulingRuntime.replies` with a `CalendarSchedulingReplyHost` and bounded options. There is no reusable ingestion endpoint or client-supplied verified-sender flag. The host selects an actual event in a trusted scope and supplies a namespaced delivery key and origin reference. It must verify that origin may respond for the exact stored attendee address. Source UID, ORGANIZER, ATTENDEE, session display addresses and SMTP headers establish no such authority.

The module loads the actual calendar/event/binding and committed publication, requires explicit native provenance, a non-recurring published series, the exact protocol UID/organizer and a member of the fixed roster, and validates one bounded pure REPLY. Detached/recurring components and delegated/SENT-BY flows reject. Ordinary file import and bearer feeds never provide scheduling authority.

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
