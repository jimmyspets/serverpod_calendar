# ADR 0115: Timing-only imported alarm adoption

Status: timing-only/current-item-text product choice confirmed 2026-10-25; concrete API mechanics under draft review. Existing private storage is reused; no table changes or migration are proposed.

## Confirmed boundary

Explicit adoption copies selected imported DISPLAY alarm timing into a new **unarmed** personal definition for the host-resolved current recipient. Reminder presentation continues to use current authorized event/task text. Source DESCRIPTION, UID, ACKNOWLEDGED and snooze relationships remain source data; adoption copies no text, identity, acknowledgement, delivery, action or snooze state and never arms anything. Imported source data remains unchanged.

## Scoped API and authority

Expose a source-timing review response containing the actual parent revision and ordered timing definitions from the master component only. This does not expose source descriptions, addresses or actions. Require independent existing `readEventSource` or `readTaskSource` permission, including a final current context check. This is not an export operation and grants no export right.

Adoption names the actual typed parent, its expected revision, zero-based source index and optional explicit DATE anchor zone. Under the shared scope transaction, authorize source read before returning source-dependent validation/revision results. Load the actual selected timing, validate it against native limits/parent anchors, resolve the trusted recipient, and require both `adoptPersonalAlarm` and `createPersonalAlarm` permissions. Final checks include the actual object/calendar, current source revision/index, recipient and validated proposed definition. No client-supplied timing or recipient is authoritative.

Reuse ordinary personal creation's 16-definition cap, opaque UUID allocation, hidden mutation receipts, audit clock and unarmed defaults. Require an explicit named zone for DATE-relative adoption; the example may prefill one but the server never infers it. Preserve duration units, sign, anchor, absolute UTC and paired repeat settings. Unsupported mappings reject explicitly, without truncation or fallback. The review list fails rather than silently omitting an unsupported timing. Per-occurrence source adoption remains outside this first master profile.

A copied definition is independent: later source replacement does not mutate it. Repeating this creation operation can intentionally create another copy within the existing cap; it is not synchronization or an idempotent source link. After an uncertain response, refresh the private list before retrying. No source provenance/relationship row or permanent snapshot is stored. Native edits/arming remain separately authorized. Source acknowledgements and snooze links do not create native actions even when their timing is selected explicitly.

## Validation

Test event/task mapping, DATE zones, source-index and stale-parent rejection, recipient isolation, separate source/adopt/create authority, final denial/recipient changes, capacity, hidden receipts, unchanged source/protocol/public generation, and absence of plans/actions/firings. Exercise real generated clients across two hosts and the example review/copy/unarmed flow, then broader batch checks. No imported scheduling or provider delivery follows from adoption.
