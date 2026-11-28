# Single-instance invitation review

[Accepted ADR 0149](adr/0149-trusted-single-instance-invitation-review.md) extends trusted recipient intake with one detached single-occurrence VEVENT REQUEST or CANCEL. It adds private review notices, not calendar reconciliation or attendee replies for instances. Ordinary file import continues to require its master. Transport remains synthetic in the example.

## Admission and authority

The host verifies origin and recipient before private lookup. Independent `receiveOccurrence` permission supplements ordinary receive and cancellation permissions, with preliminary and final checks in the shared scope transaction. `CalendarInvitationPolicyContext.occurrenceBasis` identifies either an actual retained master source or an accepted linked baseline, its known version and the incoming original. Preliminary and historical-retry contexts may have no current basis; this never fabricates evidence or weakens host authorization. External fresh checks retain their documented after-check revocation race.

New sources require a known recurring master in the same recipient/scope/UID/organizer correlation. Prefer its current trusted REQUEST body; otherwise validate a surviving link and its accepted import baseline/checkpoint. Current locally edited content is not the accepted source. A current whole-meeting cancellation blocks new admission. Missing proof rejects, corrupt required proof fails unavailable, and the recipient must occur in the selected source roster.

RECURRENCE-ID is the original civil identity, independent of a moved DTSTART. Validate exact DATE/UTC/named-zone profiles and membership including RRULE, RDATE/PERIOD, earlier explicit additions and EXDATE precedence. Candidate work has the existing 200,000-unit ceiling; exhaustion is an explicit failure with no partial entry. Whole seconds, ordinary 1970–2099 dates and full-horizon pinned-zone validation remain unchanged. Bundles, RANGE, instance patterns, delegation and unknown series reject explicitly.

## Private identity, ordering and retention

Two fields refine the existing entry: `targetKey` defaults to `master`, and nullable `originalStart` retains a typed point with no end/duration. Instance keys use `instance-v1:` plus SHA-256 of length-prefixed kind, exact zone and civil fields. Stored typed originals and incoming source must agree; hashes do not replace identity checks. The uniqueness index includes this target, so notices do not overwrite the master or a sibling. Existing rows remain master/null through generated migration; all existing content, receipts, links and response state are preserved.

Upgrade all hosts and generated clients together. Older readers select by master correlation alone and do not implement target isolation; mixed old/new host versions are not a supported rollout profile. A development reset is not required for this generated data-preserving upgrade.

Ordering is per target using SEQUENCE then DTSTAMP, with omitted SEQUENCE compared as zero while preserved as omitted. A first instance cancellation must advance the selected master REQUEST's sequence floor. Later target cancellations use that target's retained REQUEST/version history, without borrowing unrelated sibling or newer master versions. `instanceCancellation` is distinct from whole-meeting cancellation and can retain omitted DTSTART without inventing a span.

Retained delivery-key retries verify exact target/source/origin and reauthorize before returning the original receipt. They do not require a new admission basis, reactivate dismissed notices or retarget after parent changes. New keys still require current eligibility. An admitted notice remains historical review data after parent edits, pruning or deletion; it makes no claim about current membership or availability and pins no parent/deletion dependency.

The existing shared caps and retention apply: 64 pending plus 64 dismissed markers, 256 sources/16 MiB, 16 sources per entry, 1,024 receipts and configurable 30-day terminal retention. Typed originals remain private marker data only while the entry survives. Content-free native event/calendar deletion markers are unchanged.

## Example and remaining work

The invitation screen labels unapplied occurrence updates/cancellations, shows original and replacement timing separately, and supports protected source review and dismissal. A recurring synthetic invitation can generate a fixed Jan 3, 2030 update, then its minimal cancellation. Uncertain retries retain their command and source-defining values. No network address or source claim grants authority.

Instance cards hide Add/link/application/participation controls. The module also rejects instance entries server-side before master-link correlation fallback, including direct generated-client requests. Receiving/dismissing a notice changes no event, accepted baseline, participation, alarm, feed generation or outbound intent. Instance application/replies and RANGE reconciliation remain required separate reviewed work.

## Validation commands

Run focused database tests sequentially in the example server with `dart test --concurrency=1 test/integration/instance_invitations_test.dart`. `python tool/metadata_upgrade_smoke.py --instance-invitations-only` verifies populated target/index upgrades. `dart run tool/invitation_work_smoke.dart --instances` uses two actual hosts, races shared and distinct targets, and terminates an owned host before/after commit to verify atomic recovery.

The complete root check includes these tests, generated-client multi-host checks and the Flutter notice/source/dismiss journey. Record actual batch conclusions in [validation](scaffold-validation.md) and the implementation PR; focused success alone is not complete runtime or interoperability evidence.
