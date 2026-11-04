# Pure published range-cancellation bundles

[Accepted ADR 0171](adr/0171-published-range-cancellation-bundles.md) adds `projectPublishedRangeCancellation` to the calendar server package's pure adaptation layer. It builds one bounded outgoing CANCEL message from a claimed unmasked active REQUEST basis. It does not publish a meeting, change native state, allocate versions, access storage or deliver messages. Durable outgoing range cancellation/restoration and bundled recipient reconciliation remain separate roadmap work.

## Input and output

Pass an immutable `IcalendarSyntaxDocument` with a REQUEST envelope. A syntax tree is deliberately used so legal omitted inherited occurrence claims can go through the existing scheduling-only required-field projection. The helper checks the METHOD before temporarily validating the complete component data as a standalone calendar, then validates the projected REQUEST. No unsupported property, cancellation or alarm is removed to manufacture a supported basis. Exactly one recurring active master is required. Current REQUEST rules reject source alarms; this helper never adopts or arms them.

Supply an exact `CalendarEventTiming` original point, an explicit cancellation sequence and whole-second UTC stamp. DATE, UTC and exact named-zone identities are supported within the ordinary [1970-01-01, 2100-01-01) profile. Spans, floating values, fractions, excluded/missing originals and guessed equivalent aliases reject. Earlier RDATE and PERIOD starts remain valid originals. Membership/work exhaustion never means absence.

`CalendarPublishedRangeCancellation` returns an immutable validated message, detached ordered `targets`, `requiredAfterSequence` and `minimumStamp`. Each target exposes its original point and `isThisAndFuture`; neither target nor result is a native edit or retry receipt. The result carries no actor, authorized route or database proof.

The output has a primary RANGE=THISANDFUTURE component at the selected original, followed by minimal cancellations for every explicit source component strictly later in original order. Later future components keep RANGE=THISANDFUTURE; later singles remain single. A component already at the anchor is represented exactly once by the primary component. Earlier originals are omitted even if moved into the suffix.

| Original identity | Current moved date | Projection when cutoff is January 3 |
| --- | --- | --- |
| January 2 single | January 7 | Omitted: its original precedes the cutoff |
| January 3 single | January 4 | One primary future cancellation |
| January 4 single | January 1 | Explicit single cancellation |
| January 5 future component | January 6 | Explicit future cancellation |

Components carry UID, the consistent published organizer/attendee claims, the new explicit SEQUENCE/DTSTAMP and STATUS:CANCELLED. They contain no invented DTSTART, end/duration, summary or private native draft content. Exact required named zones are regenerated from pinned data; unused definitions are not published. Input content, versions and spelling remain unchanged. Participant consistency uses the existing profile's token semantics; output preserves the master's actual claim properties. Conflicting claims, duplicate recipients and unprofiled combinations reject.

This explicit later-component coverage is a conservative application projection. Legal codec output does not establish receiver behavior or general client compatibility, and the existing recipient runtime does not automatically apply bundled controls.

## Bounds and versions

The first profile uses one version across the entire bundle. Its sequence must exceed all supplied master/occurrence sequences and `minimumSequence`, including source components before the cutoff. Its stamp must be nondecreasing against every source DTSTAMP and optional `minimumStamp`. Every basis component needs an explicit SEQUENCE for this publication profile; ordinary source interchange still preserves its independent omissions. Optional lower bounds represent caller-supplied constraints, not verified history. Later durable callers must prove actual published values, history/native floors, authority and concurrency separately. No clock or increment is fabricated by the helper; overflow and nonzero fractions reject.

Default/hard ceilings are 512 KiB for input, required-field projection and output, 64 emitted targets including the generated anchor, 64 source overrides, 32 input zones and 200,000 shared candidate-work units. Existing syntax/property/date/metadata limits also apply. `maxBytes`, `maxTargets`, `maxZones` and `maxCandidateWork` may lower their corresponding ceilings. The target ceiling applies to emitted identities; valid earlier source components still undergo complete validation. If the primary plus later exceptions exceed the ceiling, the complete operation rejects without dropping exceptions.

Raw source/projected/output work and semantic recurrence/zone validation share one `RecurrenceWorkBudget`. The scheduling parse/validation and required-field helpers now accept an optional trusted shared budget; existing callers retain their prior behavior. A supplied budget cannot widen the selected component ceiling, and failed attempts retain consumed work. Unused source zones and inherited claim expansion are bounded before output filtering. Diagnostics omit source content.

## Authority and validation boundary

The caller's source document does not prove it was ever published or that module-created masks were removed correctly. Participant addresses grant no ownership or scheduling authority. There is no Session, lookup, fetching, network submission, notification action, native cutoff or source-baseline mutation in this helper. Existing outgoing checkpoints, native REQUEST guards, feeds, incoming v12 state and permissions remain unchanged. No generated model, SQL migration or dependency is added.

The focused suite covers exact/moved originals, DATE/UTC/named aliases and DST, earlier/PERIOD inclusions/exclusions, minimal complete output, participant parameters and inheritance, whole-basis/history version bounds, immutable input/results, invalid profiles and all-or-nothing byte/target/zone/work failures. Direct codec tests verify aggregate budget forwarding. SDK regressions cover masked DATE/UTC/zoned events both before and after an organizer binding, proving REQUEST publication still rejects without state/outbox changes. Actual broader VM/Chrome and hosted conclusions are recorded separately in [validation](scaffold-validation.md); pure tests establish no durable delivery or external-client success.
