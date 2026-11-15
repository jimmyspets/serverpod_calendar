# Incoming complete information-publication bundles

[Accepted ADR 0185](adr/0185-incoming-information-publication-bundles.md) extends the separate [incoming publication workflow](incoming-event-publications.md) with complete recurring PUBLISH packets. The grouped implementation is undergoing validation; [recorded checks](validation-incoming-information-publication-bundles.md) distinguish focused results from full batch and hosted readiness. Transport remains synthetic.

## Review, Add and Apply

A supported packet contains one recurring master and 1–64 single-occurrence or timing-only THISANDFUTURE components, with one UID and organizer. Receiving or dismissing it changes only private review state. Explicit Add creates one imported native series; explicit Apply requires the entire native series to match its accepted baseline. Local master or occurrence edits cause a conflict. These actions send no participation response.

DATE, UTC, exact IANA names/aliases, PERIOD additions, text annotations and independent component versions retain their supported meanings. Existing whole-second [1970, 2100) and full-horizon VTIMEZONE validation apply. Future timing propagates; supported content remains local to its anchor. Source participants grant no host authority. ATTENDEE, VALARM, detached packets, multiple series and cancelled PUBLISH components reject explicitly.

Master-only and bundled histories remain separate permanent profiles. Receipt, cancellation, pruning and deletion cannot convert one into the other. The default-false migration flags identify previously enforced master-only profiles; they do not infer missing history.

## Component ordering

Updates must contain every accepted and current-review component. Removal, single/range kind conversion and orphaning reject the whole packet. New components must pass the conservative existing-original/master version floors and bounded membership checks.

Each component compares its own `(SEQUENCE or effective zero, DTSTAMP)`. A lower tuple rejects. Equal tuples require identical normalized component values, including source omissions and CREATED/LAST-MODIFIED. Omitted SEQUENCE stays distinct from explicit zero. An independently newer child can update while the master version stays unchanged. Envelope decoration is not component content; a duplicate cannot reactivate a dismissed entry.

Whole CANCEL requires a known correlation and an explicit SEQUENCE above all affected accepted/current component versions and earlier cancellation floors. Reopening is an explicit complete PUBLISH whose master crosses the cancellation floor and whose components satisfy every retained vector. These conservative floors are application rules, not universal RFC requirements.

## Separate cancellation bases

A sender can cancel a newer packet that the recipient has reviewed but not applied. The cancellation source's `basisSourceId` validates supplied fields against that sender packet. The link's accepted PUBLISH basis preserves the native values. Applying cancellation does not install the unapplied packet, flatten child versions, or alter personal reminder state. Both bases remain authorized and retained through pruning under existing limits. Missing retained vector proof is unavailable; it never becomes an empty vector or scalar fallback.

## API and authority

Common list/header/dismiss operations expose only their authorized projections and profile flag. Bundles use dedicated generated methods:

| Method | Result and independent host operation |
| --- | --- |
| `getBundleSource` | Authorized complete source and exact component versions; `readBundleSource` |
| `getBundleLink` | Protected link, accepted PUBLISH vector, separate cancellation version and current review vector; `readBundleLink` |
| `addBundleToCalendar` | Stable creation receipt; `adoptBundle` |
| `applyBundleSource` | Revision-bound latest-only receipt; `applyBundleUpdate`, `applyBundleCancellation` or `reopenBundle` |

Intake separately requires `receiveBundle` or `receiveBundleCancellation`. Existing raw-source, native create/import/edit/lifecycle and complete native disclosure permissions also apply. Scalar source/link/Add/Apply methods reject bundle profiles before correlation fallback. A deleted link retains its profile and stable creation receipt, with no active payload or recreation capability.

Actual source IDs/digests, complete messages, both bases and current/proposed native state reach the host adapter. Stored proof reads are checked independently at preliminary and final write phases. Query-local caches contain only immutable pure validation results; they cache no access decision, current vector or database coordination guarantee. External fresh checks retain their documented after-check revocation race.

The unchanged limits include 512 KiB/source, 65 components, 200,000 shared recurrence work, 32 sources and 64 receipts/entry, 2 MiB link proof and existing recipient/scope quotas. Capacity exhaustion rolls back atomically. Creation and latest Apply retries reauthorize without reactivation or another write; deletion scrubs active proof while retaining the approved marker. The Flutter example selects dedicated routes from the authorized profile and displays versions only after the protected read.

Partial merging, occurrence/range information cancellation, replies, alarm adoption, provider trust and real mail remain separate work.
