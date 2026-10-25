# Durable native alarm planning and guarded handoff

[ADR 0112](adr/0112-bounded-durable-alarm-planning.md) records the confirmed execution policies, storage boundaries and retention choice. This increment implements pure calculations, explicit native arming, durable bounded planning, fenced retries and a host delivery port. It does **not** implement notification delivery, native acknowledgement/dismiss/snooze APIs, imported-alarm adoption or mobile providers. Broader validation evidence belongs in [the validation record](scaffold-validation.md).

## Private API and host configuration

Creation remains unarmed. `calendarAlarm.setArmed(parent, alarmId, expectedRevision, armed)` requires separate `armPersonalAlarm` authority, trusted current recipient, actual parent/current alarm and validated proposed armed state, including final checks. Arming requires installed `CalendarAlarmRuntime`; missing configuration fails closed. Disarming remains possible without it. Stale writes reject, and hidden mutation receipts remain hidden. Accepted writes advance the private API revision; identical settings/armed-state writes do not invalidate generation or replay work. Background replanning never advances that API revision, shared item/protocol versions or public scope generation.

An authorized private list includes armed state, planning status and the ready window endpoint. It never exposes leases, internal generation or other recipients. Dirty ready plans appear pending; a needs-attention/unavailable plan has no claimed complete coverage. Current-master anchor compatibility remains a separate diagnostic.

The host installs a dedicated `CalendarAlarmBackgroundPolicy`, with declared coordinated or external fresh-check guarantees, and `CalendarAlarmDeliveryPort`. The module never creates a JWT or impersonates a request actor. The background context declares the specific `plan` or `dispatch` operation as well as trusted recipient/scope and actual calendar, event/task and recorded occurrence state. Hosts can permit planning while denying dispatch independently. An external final check still has an after-check revocation race; configuration never silently downgrades a required coordinated guarantee.

## Complete bounded planning

Each plan targets the next 30 days, plus the configured late-eligibility lookback (15 minutes by example default). The target must fit the ordinary supported profile; a partial 30-day window near 2100 is rejected. Firings remain whole-second UTC in 1970–2099. Explicit exclusive endpoints may anchor negative offsets but never extend firing storage.

Source projection uses complete stored event/task data and existing bounded recurrence machinery, never filtered detail lists. Preserve original identities, moved single/future timings, PERIOD-specific event lengths, DATE midnight zones and RFC gap/fold rules. Calendar weeks/days precede elapsed clock units; successive repeats preserve resolved later-fold instants. END needs an actual explicit end/duration/deadline. Preserve explicit gap wall fields at their own template anchors; subsequent resolved projections retain their exact end instants, including later folds. Task END queries include conservative deadline lookback. Unsupported calculations or exhausted work return needs attention without partial insertion.

The initial complete-plan cap is 1,000 firings per definition, configurable up to 10,000. Repeats count before action/lifecycle suppression or recovery coalescing. Candidate enumeration is separately bounded at 100,000; native recurrence budgets remain active. Retained firing capacity defaults to 10,000 per definition, configurable up to 100,000. Capacity failure does not delete private history early or publish partial coverage.

Cancelled events/occurrences do not dispatch. Any task completion/cancellation signal suppresses its applicable firing: COMPLETED/CANCELLED status, COMPLETED timestamp or 100 percent. Independent imported fields remain unchanged, including unusual combinations and all-null occurrence progress. An occurrence's own progress replaces the master default; it is not merged field by field.

## Transactions and worker ownership

The approved schema adds armed/generation fields to definitions and separate plan, firing/retry and per-original action tables. Plan uniqueness is per alarm; firing uniqueness binds alarm/generation/original/kind/repeat/snooze revision; action uniqueness binds alarm/original. A firing UUID is its stable downstream idempotency key. No parent text, provider credential or source baseline is copied into work rows.

```mermaid
flowchart LR
  Edit[Authorized shared/private write] --> Dirty[Durable invalidation]
  Dirty --> Claim[Short database lease claim]
  Claim --> Calculate[Complete calculation outside locks]
  Calculate --> Commit[Scope lock and fresh source/policy/fence checks]
  Commit --> Firings[Complete durable firing set]
  Firings --> Guard[Current generation, access, lifecycle and expiry]
  Guard --> Port[Host durable delivery port]
  Port -. separate required increment .-> Notifications[Reusable notification delivery]
```

Shared writes dirty scope plans transactionally, without private list caps or recipient permission checks. Private settings/arming invalidate their own generation. A timing/lifecycle digest prevents unrelated text edits from replaying work. Deletion scrubs all recipients' firing/action/plan rows before definitions, in the parent transaction. Permanent parent markers retain no private alarm content.

Workers use shared database time, short `FOR UPDATE SKIP LOCKED` claims, random owner IDs and monotonic fences. Default lease duration is 30 seconds (configurable from one second to five minutes), with at most 100 claims per sweep (configurable to 1,000). Calculate after the claim transaction commits; commit only after reacquiring the trusted scope and checking current source, owner/fence/generation and unexpired lease again after final authorization. No process-local lock/cache establishes correctness.

Only ready, clean, armed current generations enter the due scan. Non-ready plans cannot monopolize it. Transient unavailable plans retry after 30 seconds, preserving pending work; invalid/budget-limited plans retry after an hour or immediately after a new invalidating edit. Recovery expires old firings and selects only the latest eligible overdue firing per definition, recording other eligible firings suppressed. Future automatic repeats remain pending until due or an explicit action suppresses them.

## Handoff and retention

Revalidate actual parent, current recipient policy, generation, source digest, lifecycle, action state and database-time eligibility before handoff. The port must durably accept once per firing UUID and return true only after acceptance. Failures/timeouts retry the same ID; the current handoff timeout is 20 seconds and retry delay is 30 seconds. Acceptance followed by process loss can cause transport redelivery. Acceptance is neither display nor acknowledgement, and recall after acceptance is not promised.

A downstream queue **must** call `CalendarModule.validateAlarmDelivery(session, storedIntent)` before every dispatch/retry. It must preserve the source reference and idempotency key; a previously accepted intent grants no lasting authority. The current reference carries identities, recipient, original key and due/expiry only, with no automatic parent text disclosure.

Terminal firing/delivery history has host-configurable retention, default 30 days, then bounded pruning. Pending/retryable work, active leases and records lacking a terminal timestamp do not qualify. Acknowledgement/dismissal is separate and remains until explicit reset/alarm deletion, even across timing/settings changes; removed originals are never retargeted. Pruning terminal history never deletes action rows. Native action/snooze commands remain a later increment; their confirmed policy is future whole-second UTC snooze within seven days of database time, replacing a pending snooze without chains.

## Example and evidence boundary

The example installs a private-user background policy that freshly checks the recipient's existing, unblocked auth account. Each host registers its own generated Serverpod recurring maintenance wake-up every 15 seconds. Wake-ups are not the durable work store; duplicate calls and lost instances are handled by module leases/fences. Hosts using another scheduler must arrange periodic bounded recovery themselves.

The Flutter example has explicit arm/disarm and private planning status. Its delivery port deliberately returns false because reusable notification delivery is not connected yet. This preserves retry state rather than pretending a log/stream emission is durable acceptance. No OS notification, connected stream or notification-provider compatibility follows from this increment.
