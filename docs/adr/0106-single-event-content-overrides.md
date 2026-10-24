# ADR 0106: Selected single-event content overrides

Status: **scoped implementation of confirmed selected-field/anchor-only wire policy and preserved timing inheritance; concrete mechanics under draft review**. Date: 2026-10-24.

## Confirmed scope

Add selected summary, description and location changes on one original event occurrence, with explicit set/clear/restore-inheritance actions. Omitted source fields inherit; explicit fields, including empty TEXT, independently override only that original, even at a future timing anchor. Future content propagation and per-occurrence status/transparency remain separate. A new content-only exception preserves timing inheritance rather than capturing a time. Reject export of that unrepresentable state until a faithful mapping exists; never invent DTSTART. Existing explicit timing/range components can carry local content faithfully in the bounded wire profile.

## Proposed model and native integration

Use immutable CalendarEventOccurrenceContent with nullable summary/description/location and optional per-property CalendarEventTextParameters. Null fields inherit; empty text clears. Add nullable contentOverrides to existing single/future override DTOs stored in the event's JSON payload. Add CalendarEventContentField/CalendarEventContentAction enums, selected field/action/optional-text changes and a request with eventId/expectedRevision/originalStart/changes. One to three unique changes use existing text/annotation limits. Native set retains own annotations or captures effective annotations when first overriding an inherited field; clear/inherit removes own annotations. No network retrieval follows.

Content requires a recurring series (including PERIOD additions). Preserve exact original identity, cancellation, timing and parent metadata. Content-only singles participate in original-membership/orphan validation but not temporal projection or occupied time. Clearing timing retains content; a content-only single may transfer to a future timing anchor and back without resetting its component creation/version history. Existing explicit single/future timing collisions remain rejected. Removing the final content field removes a now-empty content-only component; no unrelated state is cleared.

Require updateEvent and actual parent/event/original/current/final source context, stale/final/declared-guarantee checks under the durable scope lock. Change no lifecycle rights or status. Accepted native writes retain ordinary API revision/scope behavior; actual component changes alone advance its protocol version with nondecreasing whole-second timestamps. Master content edits preserve pinned own text/annotations rather than rewriting them.

## Proposed wire/storage/disclosure integration

Preserve explicit own source text/annotations separately from source property-presence checkpoints. Change private baseline profile to event-source-v2 because old explicit repetitions followed the master. Reject older imported profiles fail-closed rather than silently reinterpret them; pre-beta recreation/reimport into fresh development data is explicit, never an automatic reset/adoption. Existing source-free timing state remains compatible. No table-column changes are selected; verify generated schema stability.

Occurrence queries optionally request summary/description/location groups in addition to the existing mandatory timing group. Snapshot the list before awaits, require all requested groups and return explicit disclosedGroups plus only authorized effective content/override fields. Normalize all-null filtered objects to absence so hidden override presence does not leak. Default previews and free/busy acquire no content disclosure. Imported content with explicit DTSTART retains its timing; sparse native timing inheritance rejects whole-series export until represented faithfully.

## Acceptance

Test wire omitted/repeated/different/empty fields and anchor-local RANGE content; source annotations and v1 rejection; set/clear/inherit, cancellation/completion-independent timing, range transfers and stable versions; no-op protocol state; original/orphan/limit boundaries; unchanged occupancy; each permission/disclosure and hidden override presence; immutable request/query snapshots; stale/final/rollback; export rejection and explicit-timing round trips. Run focused pure/module/database tests, generated schema verification and broader VM/Chrome/two-host/Flutter checks before the single batch commit. No blanket RFC/client compatibility, future content/cancellation, scheduling or alarm runtime follows.
