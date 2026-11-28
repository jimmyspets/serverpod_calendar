# ADR 0124: Recurring organizer masters and whole-series cancellation

Status: **Proposed; maintainer review required before implementation.**

## Context and proposed batch

[ADR 0122](0122-explicit-native-organizer-publication.md) and [ADR 0123](0123-explicit-native-organizer-cancellation.md) implement explicit non-recurring native REQUEST/CANCEL through bounded durable delivery. The next batch would extend that workflow to recurring masters, using the already implemented native recurrence and pure message profiles. First-class occurrence-component publication and instance/range scheduling follow as separate required work; this increment would not complete recurring scheduling.

Accept native recurring masters with the supported RRULE, start-valued RDATE/EXDATE and timed PERIOD additions, DATE/UTC/named-zone timing and fixed verified organizer/recipients. Publish source patterns rather than flattening occurrences. Preserve the existing whole-second horizon, nominal durations, exact zone identifiers, ISO presentation and rule-specific WKST behavior without new temporal policies. Existing pure method/property/zone/resource limits remain mandatory; unsupported content rejects atomically rather than being dropped.

## Canonical edits and publication boundary

A first recurring publication must originate from an already recurring native event. Keep non-recurring/recurring mode conversions blocked while an organizer binding is active; imported/unknown adoption, recipient changes and binding deletion remain separate. Within recurring mode, ordinary local edits may change the supported master pattern, timing and text under existing native validation and permissions. They send nothing until explicit Save and notify.

The first recurring REQUEST profile publishes one master component only. Existing native single/future timing/content/cancellation exceptions remain canonical capabilities, but their stored override state makes REQUEST publication unavailable until explicitly removed or the later component profile is implemented. Never silently clear, pin, retarget or flatten those edits to fit a message. This restriction belongs to the outbound profile and must be visible in the example; ordinary canonical occurrence edits are not disabled merely because publication is narrower.

## Whole-series cancellation and reopening

Cancel and notify cancels the complete published UID using its last published recurring master and a newer whole-event CANCEL. Preserve unsent native pattern, timing, text and exception state. Host context includes actual current/final native overrides and the distinct outgoing master; native override protocol state is retained rather than invented or reset. Local saved exceptions do not become outgoing cancellation components.

Ordinary local reopen sends nothing and leaves the published CANCEL eligible. Explicit newer REQUEST reopening remains subject to the same master-only representability check. A published cancellation followed by new local exceptions therefore cannot be reopened through REQUEST until those exceptions are explicitly resolved or the later outbound component profile supports them. No implicit exception deletion or automatic workaround is allowed.

## Versions, storage and authority

Reuse the approved binding/publication/delivery/attempt tables, private snapshot retention, finite capacities and fencing. No new table/column or retention expansion is proposed. The snapshot/projection retains recurrence source meaning and periods; complete native override state is supplied to policy even when excluded from the outgoing master. New publications use SEQUENCE greater than the previous publication, preserving an already newer saved component version when applicable; CANCEL advances beyond both prior states. Retained exact retries and normalized no-ops keep their current semantics.

Preserve independent publish/cancel/lifecycle/edit/detail/source authority plus current dedicated organizer/recipient approval. Background work checks the exact stored master, current origin/parent/authority, publication generation, route and expiry. Local drafts never regenerate queued bytes. A cancelled native parent blocks REQUEST; local reopen does not silently retract published CANCEL. Stable retry keys and at-least-once uncertainty remain unchanged.

## Alternatives and acceptance

Publishing only expanded dates would lose pattern/DST semantics and create unbounded work. Dropping native exceptions would erase canonical intent. Publishing arbitrary occurrence components before defining their inherited fields and independent versions would overstate support. A master-only increment retains existing safe boundaries while full recurring scheduling remains required.

Test RRULE/RDATE/EXDATE/PERIOD source round trips, COUNT/UNTIL and WKST, earlier inclusions, DATE/UTC/named-zone DST behavior, pattern/timing draft isolation, mode-change rejection, unsupported exception publication, preservation of native exceptions on whole-series cancellation, explicit reopening/no-op/retry, version/capacity/authorization rollback, current-generation withdrawal and independent-worker recovery. Add generated-client and Flutter recurring publication/cancel/reopen journeys and run broader checks after the batch. Instance/range messages, authenticated inbound reconciliation, real email and external-client evidence remain separate.
