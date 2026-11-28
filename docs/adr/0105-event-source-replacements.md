# ADR 0105: Explicit event source replacements

Status: **scoped implementation of confirmed replacement policy and cancellation lifecycle gates; concrete mechanics under draft review**. Date: 2026-10-24.

## Confirmed scope

After task replacements, apply the same explicit selection, revision, recorded-baseline/local-conflict, source SEQUENCE and true no-op policy to VEVENT. Require separate replacement/import/full-detail permissions and lifecycle permission when adding or removing cancellation. This is ordinary authenticated replacement, not scheduling reconciliation, force overwrite, adoption or mixed synchronization.

## Contract and model mechanics under review

CalendarEventReplaceRequest contains calendarId/expectedRevision, a list of existing CalendarEventExportSelection and strict bytes. CalendarEventReplaceReceipt contains minimal receipt and changed; CalendarEventReplaceResult contains the disclosed receipts. Snapshot the exact byte slice and selection before awaits. Parse the existing bounded complete supported event profile, require an exact selected protocol UID set and replace all selected contents atomically under actual parent/scope locks. Preserve native UUID/creation time; no table changes are needed.

Require importEvents and replaceEventsFromImport on the actual parent and each selected event, plus readEvent with all six groups before equality/conflict classification. Changed replacements require updateEvent. Require changeEventStatus for any effective master status transition or change in the exact set of individually cancelled originals, including removal of cancelled components. Native occurrence-timing authority remains updateEvent. Give the host complete immutable current/proposed content, overrides and protocol state plus baseline profile/sequence and authorized classification; never the historical baseline payload. Recheck final context and declared authorization guarantee without downgrade.

Require a validated current-profile recorded baseline. Compare canonical content, exact timing/overrides, text annotations, source omissions and independent component versions. Differing incoming source conflicts with local changes; lower master SEQUENCE rejects, equal is allowed, omitted is 0. Preserve incoming source timestamps/omissions exactly, including backwards corrections. Identical incoming/current source is a true no-op even after local edits and never adopts the dirty state as a new baseline. Native/source-free events and unsupported older baselines require a separate explicit adoption/reimport flow.

Changed members advance native revision/nondecreasing database audit time and the scope generation once per batch; unchanged members alter nothing. Retain exact original identities defined by the supported source series; validation must reject unsupported/lossy data, not silently flatten it. No alarms, invitations, mail, relationships, subscriptions or participant authority are created by replacement.

## Acceptance

Test independent gates/disclosure/current context, cancelled master and removed own cancellation gates, status transitions, baseline/local/lower-sequence rejection, equal versions and backwards timestamps, exact omissions, true no-op state, stale/foreign/duplicate selection, immutable input/intent, whole-batch final denial and late rollback. Exercise real generated clients on two hosts and the explicit Flutter editor. Use focused tests first, complete batch checks before the single commit, and report actual evidence without client-interoperability claims.
