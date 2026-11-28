# Master updates preserving accepted range cancellation

[Accepted ADR 0161](adr/0161-master-updates-with-accepted-range-cancellation.md) extends first incoming range-CANCEL acceptance with explicit updates to an active accepted master REQUEST. The existing `calendarInvitation.applyUpdate` command keeps the exact cutoff and every canonical accepted single/future component. A higher master SEQUENCE does not reopen the suffix. Whole-series lifecycle, new occurrence applications, cancellation replacement and source restoration remain separate.

## Validation and authority

The entire native series must match its verified expected source state. Local edits, including a local cutoff restoration, remain conflicts. The proposed cutoff-free master is composed with retained canonical exceptions before validating the exact cutoff's kind/zone/original membership. Removing or excluding its anchor rejects; earlier and PERIOD additions retain their original identity. Work exhaustion is never proof of absence or membership.

Master source ordering remains independent of the historical cancellation version. Later master versions can be below or above that cancellation version without resetting it. Independent exception versions, source omissions and inheritance stay intact. No historical CANCEL is replayed as a fresh command against the newer master.

Ordinary import/replacement/update/full-event/source permissions, host application rights and `composeAcceptedOccurrences` still apply. Dedicated `composeAcceptedRangeCancellation` is also required, including when there are no ordinary accepted targets. Read-phase eligibility checks the relevant update permissions against immutable candidate state; denial disables application without hiding independently readable state. Actual writes reauthorize preliminary/final contexts. Accepted cancellation source information always requires authority over its actual source identity, independently of the selected master.

## Private frozen/current state

Existing checkpoint JSON v5 adds one private `cancellationBasis` and original `cancellationNativeDigest`. They preserve the cutoff-free basis and expected candidate against which the original cancellation was accepted. Its source, sequence floor, version, acceptance time and original binding remain unchanged and are reconstructed/verified from that frozen evidence.

Current master/baseline/checkpoint bindings advance separately. The ordinary event import baseline remains cutoff-free. A current expected-native digest binds the composed candidate including the cutoff, with a separate composition hash bound to actual scope/recipient/link/parent/event, current master and original cancellation evidence. V5 receipt binding retains the same original cancellation command/result across later compositions. Missing, corrupt or marker-only upgrades fail unavailable; v1/v2/v3/v4 reads remain supported and v4 reads/retries never lazily write an upgrade.

The frozen basis may retain superseded source values until event deletion. It is server-only active data, omitted from ordinary views and exports and scrubbed on deletion. The existing 4 MiB/link, 16 MiB/recipient and 64 MiB/scope ceilings include it, with no truncation or cap expansion. Only one original snapshot is kept across repeated updates; an update that cannot fit rejects atomically. No SQL migration or new history table is added. Upgrade writers/clients together.

## Atomic effects, retries and views

A successful explicit update atomically advances event/master/checkpoint revisions and audit time, replaces current accepted source state, dismisses only the selected notice and invalidates scope/feed/alarm generations and leases. The original cancellation version/time/receipt and independent occurrence versions remain intact. Final denial or a quota/membership failure rolls back the complete operation.

The latest exact cancellation retry remains write-free after repeated master updates, newer notices and local edits. The separate latest master retry also returns its retained receipt. Neither reapplies a cutoff nor dismisses a newer notice. Current rights are rechecked; cancellation retries do not require authority to compose a new master. Older occurrence commands retain their latest-only supersession rule.

The master view's protected `hasAcceptedRangeCancellation` is independent of `occurrenceCompositionBlocked`: an eligible master update can preserve cancellation while being applicable. Incoming content remains the source master projection; the flag describes the retained mask separately. Flutter explains this distinction and preserves the same command across an uncertain response. An accepted cancelled master requires a separate reopening workflow, and ordinary native restoration never implicitly accepts source reopening.

Existing active-cutoff export/feed/new organizer REQUEST rejection remains. HTTP checks must not return stale 304 or publish a lossy 200. No participation response, alarm activation or real mail follows. See [validation](scaffold-validation.md) and [development](development.md) for scoped synthetic evidence and remaining gates.
