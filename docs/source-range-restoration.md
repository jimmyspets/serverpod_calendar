# Explicit source range restoration

[Accepted ADR 0164](adr/0164-first-durable-source-range-restoration.md) adds `rangeRestorationApplication` and `applyRangeRestoration`. Receiving a source REQUEST remains review-only. The recipient must explicitly review and apply a matching restoration of the exact accepted cancellation cutoff. Ordinary range-update APIs never infer this action.

Require a clean entire linked series, a verified v4/v5/v6 cancellation checkpoint and an active accepted master. Whole-master cancellation must first be reopened separately. The [pure matcher](range-restoration-projection.md) checks exact original membership/profile, retained uncancelled timing/end form/nominal units and supported content/participant agreement. The source SEQUENCE must exceed the cancellation and effective/underlying/affected component floor. A later source timestamp alone is insufficient. Different anchors or rescheduling remain unsupported.

## Authorization and private evidence

Independent `readRangeRestorationApplication` and `applyRangeRestoration` operations accompany existing source/link/master/range read and composition rights. Native import, replacement, event update, lifecycle, full detail and source-read rights remain necessary. Checks use actual old cancellation and current restoration source identities with preliminary/final immutable current/proposed context. Source calendar addresses grant no authority. The host chooses its coordinated or external fresh-check guarantee; existing external-check revocation limitations remain.

The existing private occurrence-application row holds v7 JSON: one nonrecursive `preRestoration` descriptor with the validated v4/v5/v6 state/revision/time, one restoration source/evidence layer, expected native/master/baseline bindings and the latest command/receipt. No duplicate canonical target list is stored. Decoding revalidates the predecessor and replays restoration; a marker, missing binding, unsupported nesting or changed source fails unavailable. The predecessor retains private historical source/basis content until linked event deletion within existing limits.

The event's ordinary import baseline remains cutoff-free and unchanged. Restoration SEQUENCE/DTSTAMP/CREATED/LAST-MODIFIED and omissions live separately from retained canonical component versions. Existing ceilings remain: 4 MiB per link, 16 MiB per recipient and 64 MiB per scope (hosts can lower them), plus source/work/slot bounds. The complete representation is charged before writing; evidence is never silently dropped to fit. No SQL migration, new table/column or dependency is introduced. Two read-only derived view fields and the new endpoint/client/test bindings are generated from their sources.

## Atomic effect, retries and limits

One transaction clears only the cutoff, records acceptance, advances event/checkpoint/audit state, dismisses only the selected notice and invalidates scope/feed/alarm generations and leases. It preserves timing, recurrence, individual cancellations, text/annotations, source metadata, protocol versions, personal definitions/actions and parent calendar metadata time. No reply is sent and no imported alarm is armed.

Queries/free-busy and reminders use the restored native state. Representable feeds become available under fresh publication checks and validators; all other unrepresentable-state restrictions remain. Alarm grace/expiry, acknowledgements, dismissal/reset/snooze and accepted-firing deduplication across generations retain their existing rules. Restoration does not replay already accepted reminders.

An exact latest restoration retry reauthorizes and returns the same receipt without clearing a later local cutoff, overwriting a draft, dismissing a newer notice or changing revisions/generations. Prior occurrence commands, including cancellation, are superseded under the existing latest-only slot. Their retained predecessor receipts validate evidence and cannot replay their effect. Latest master-command retries remain a separate write-free path.

`hasAcceptedRangeCancellation` records accepted source history; `hasAcceptedRangeRestoration` records its explicit restoration. Both can be true. Actual native cutoff/individual/master status determines current suppression. Flutter distinguishes this history from an active cancelled suffix and exposes an explicit Review source restoration / Apply range restoration flow with stable uncertain retries.

This first v7 profile guards every new master/single/range source application after restoration, including another cancellation/restoration, pending a separate composition/version-evidence contract. Guards follow authorization and retained-retry recognition. Ordinary native edits and private review/dismissal retain existing boundaries. No outgoing range restoration, wider reconciliation, real mail or external-client certification is implied. See [validation evidence](scaffold-validation.md) for checks actually completed.
