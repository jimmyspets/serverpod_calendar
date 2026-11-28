# First durable incoming range cancellation

[Accepted ADR 0160](adr/0160-first-range-cancellation-acceptance.md) adds one explicit first range-CANCEL acceptance per linked recurring event. Receipt/review sends nothing and changes no calendar. The caller invokes `calendarInvitation.applyRangeCancellation` using the protected range preview and expected invitation, source, parent, event and checkpoint revisions. `applyRangeUpdate` accepts REQUEST only.

The complete current series must match its accepted source and have no native cancellation cutoff. The pure [projection](range-cancellation-projection.md) checks exact original membership/profile and requires a SEQUENCE greater than every affected component, including the underlying segment beneath an anchor single. This is our conservative application policy. Independent source omissions and timestamps are retained; source values grant no authority.

## Authorization and atomic effects

The host independently approves `applyRangeCancellation`, range/master application reads, actual source/link and complete event disclosure. Native import, replacement, update and lifecycle permissions also apply. Preliminary/final contexts distinguish the cancellation message, cutoff-free baseline, candidate cutoff and private checkpoint. Final denial rolls everything back.

Acceptance suppresses every original at or after the anchor, including later moved exceptions, while retaining their content, timing, individual flags and component versions. It advances native/checkpoint revisions and database audit time, dismisses only the selected notice, advances publication generation and invalidates alarm plans/leases atomically. Busy queries, occurrence queries and current reminder checks reuse the native cutoff behavior. No reply, alarm activation or real delivery follows.

## Private state and retries

The existing checkpoint JSON v4 keeps the ordinary import baseline cutoff-free. A separate cancellation layer retains source identity/text/digest/version, required sequence floor, basis binding and acceptance time. A verified digest binds the complete expected native content/overrides/protocol state, including the cutoff, separately from revision/audit fields. Reads reconstruct the pure candidate and validate source/basis/native/receipt bindings. Legacy v1/v2/v3 reads remain; earlier canonical targets remain intact. No SQL migration or retention expansion is added. Existing 128-slot and byte limits include this layer.

At its accepted notice, `acceptedVersion`, `acceptedKind`, `acceptedSourceText` and `latestResult` describe the separate cancellation. Other notices retain their ordinary accepted fields. The derived `hasAcceptedRangeCancellation` and master composition guard require fresh authority over the actual accepted source, even when viewing another notice. Source bodies can be pruned from the inbox; the active checkpoint remains self-contained. Event deletion scrubs it.

An exact latest cancellation retry reauthorizes and returns its original receipt without writes, even after local edits or a newer notice. Independent retained master retries also survive. Older occurrence commands retain their latest-only supersession rule. Flutter retains the same request across an uncertain response and provides an explicit apply action.

## Temporary limitations

After acceptance, **all new master, single and range source application commands reject**. Reviews and ordinary native edits remain available. A native cutoff restoration is a local draft against the complete accepted candidate; it does not erase private source cancellation or unlock source applications. Source composition, replacement, multiple cutoffs and explicit source restoration require a subsequent reviewed design.

Ordinary export, feeds and new organizer REQUEST publication reject an active cutoff until a faithful mapping is supported; cached feed responses must not return stale 304. Range participation, outgoing range cancellation, tasks/openings and real mail remain separate. This is synthetic/native validation, not external client interoperability certification.

See [validation](scaffold-validation.md) and [development commands](development.md).
