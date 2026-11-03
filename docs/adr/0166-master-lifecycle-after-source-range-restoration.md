# ADR 0166: Master lifecycle after accepted source range restoration

Status: **Proposed. Active-master restoration preservation is approved under ADR 0165; extending it to whole-series lifecycle and the following v9/source-floor mechanics requires explicit agreement.**

## Context and first scope

[ADR 0165](0165-master-updates-after-source-range-restoration.md), implemented in PR #161, permits active master REQUEST composition after source restoration, with one frozen v7/baseline/master proof and current v8 bindings. Its local grouped, two-host recovery, client/feed and connected Flutter checks passed; new implementation-head CI is tracked separately. Whole-series source CANCEL/reopening remains guarded. Extend only the existing explicit applyCancellation/applyUpdate workflow; receiving/reviewing a notice still changes nothing and sends no reply.

Preserve the cleared source-cutoff state, all canonical single/future edits and individual cancellations through whole-series cancellation and later explicit reopening. A historical range cancellation must not become active again. Native local changes still conflict with the entire verified expected state; this is not the outgoing organizer workflow that preserves unpublished drafts around a historical publication.

## Independent lifecycle and version rules

For a new whole-series CANCEL, require its explicit SEQUENCE to exceed the current accepted master, every canonical accepted component (including originals before the former cutoff), and the historical restoration and range-cancellation source versions. Missing retained component SEQUENCE compares as zero without rewriting omissions; a later source timestamp cannot waive this floor. This is a conservative application rule, not a universal RFC requirement. An exhausted maximum/work budget rejects atomically.

Project only master cancelled status and the independent incoming source protocol version through the existing cancellation helper, retaining other canonical values. Other supplied cancellation values remain inert review data. Source DTSTAMP and optional CREATED/LAST-MODIFIED/omissions remain exact, independent of database audit time.

A later explicit active REQUEST reopens under existing accepted-master SEQUENCE/DTSTAMP ordering, including equal SEQUENCE with a later DTSTAMP where currently supported. Recompose with retained canonical targets and keep the restoration original in the exact profile/recurrence set. Preserve all individual cancellations and keep the cutoff absent. No higher master version alone replaces range history; new single/range messages, restoration/cancellation cycles and ordinary source replacement remain separately guarded. A REQUEST supplying CANCELLED native status remains unsupported in this lifecycle profile; use the explicit CANCEL flow.

## Existing-table v9 state

Reuse the one frozen restoration descriptor introduced by v8, unchanged across lifecycle transitions. The original v7 acceptance is replayed against its recorded cutoff-free baseline/nullable master snapshot, never the later cancelled master. Do not freeze another current-content snapshot or nest v8/v9 histories.

Introduce v9 current-kind/status/composition binding in the same JSON column. Record the actual current accepted master kind and bind it with distinct lifecycle composition and historical-restoration receipt namespaces. Require request kind with active native master, or meetingCancellation kind with explicit CANCELLED protocol status and a non-null cancellation sequence. Compare current master/baseline/native state independently from frozen history. Keep exact original restoration receipt/source/version unchanged. After lifecycle has occurred, later REQUEST updates remain v9 rather than downgrading to v8.

Preserve strict v7/v8 readers and retries, and the initial v7-to-v9 path where cancellation precedes any post-restoration REQUEST composition. A marker-only kind/version, missing field, contradictory status, altered frozen/current/receipt binding or unsupported nesting fails unavailable without a legacy or flattened fallback. No lazy upgrade on reads.

Existing 4 MiB/link, 16 MiB/recipient, 64 MiB/scope and configurable lower byte ceilings count the complete state. Source/work/slot limits and private deletion/retention boundaries stay unchanged. Charge any added kind/binding bytes before writes, reject rather than drop evidence, and scrub the whole active checkpoint on event deletion. No SQL, endpoint/view field, dependency or retention expansion is proposed.

## Authority, previews, atomicity and retries

Use the existing independent applyCancellation/apply, source/link/raw detail, accepted-occurrence/cancellation/restoration composition and native import/replacement/update/lifecycle rights. No source address or frozen record grants host authority. Read previews check the applicable action/native rights and conservative floor; actual commands recheck preliminary/final authority with immutable current/proposed event/private snapshots. Authorize retained original cancellation/restoration sources by their actual descriptors/body after pruning, and preserve declared coordinated/external fresh-check guarantees.

Re-use current APIs/history flags and Flutter actions. Explain that whole cancellation suppresses the meeting while restoration history remains; reopening restores current retained values without reinstating the old range cutoff or reopening individual cancellations. No new endpoint/control is needed beyond lifting scoped eligibility for existing explicit actions.

Atomically write native master status/protocol state, master acceptance and v9 current-kind binding, advance event/master/occurrence revisions and database audit state, dismiss only the selected notice, and invalidate scope/feed/alarm generations and leases. Keep calendar metadata time, personal alarm definitions/actions, accepted-firing deduplication and independent canonical component versions. Fresh query/busy/feed/reminder checks must reflect actual master lifecycle, preserve expiry/access rules and prevent accepted reminder replay. Send no response and arm no source alarm.

Retain separate latest master and original restoration receipts. Exact retries reauthorize and return the original result without touching later drafts, local cutoffs, source notices, generations or reminders. A new master command supersedes only the latest master slot; original restoration remains stable across cancellation/reopening. Prior occurrence commands remain superseded. Same-command competitors converge; competing sources respect revisions and actual process loss before/after commit cannot duplicate or partially expose a transition.

## Validation and acceptance

After explicit approval cover v7/v8 to v9, continued v9 REQUESTs and repeated lifecycle transitions for DATE/UTC/named zones/DST. Test retained individual cancellations/clear cutoff, canonical exceptions, versions lower/equal/higher than each independent floor (including a high pre-cutoff single), source omissions/backwards clocks, equal-sequence later-stamp reopening, maximum values, exact membership/profile/orphan failures and local conflicts.

Cover independent read/preliminary/final/native authority and rollback, every frozen/current/kind/status/receipt binding, nesting/unknown versions, limits, source pruning/deletion and stable restoration/master retries across newer notices and local edits. Exercise actual two-host same/competing-source races, visibility and loss before/after both lifecycle commits; generated clients and Flutter; fresh busy/query/feed validators; relative/absolute/live/snooze suppression and restored action/dedup state. Use focused tests, grouped checks before one code commit and full implementation-head CI before readiness. New range transitions, real mail and external-client certification remain separate.
