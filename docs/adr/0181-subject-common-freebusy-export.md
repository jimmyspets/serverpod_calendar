# ADR 0181: Complete subject and common-free VFREEBUSY exports

Status: **Proposed; explicit maintainer agreement required before implementation.** This closes an existing roadmap export gap without adding another durable scheduling workflow. ADR 0180 validation remains independent; no pending hosted result is treated as successful.

## Evidence and bounded group

[ADR 0058](0058-subject-availability-search.md) implements host-resolved subject/common-free search, and [ADR 0077](0077-privacy-safe-calendar-freebusy-export.md) implements per-calendar VFREEBUSY download. The roadmap still requires subject/common-free export. Existing search exposes complete/unknown partitions and derived minimum-duration slots, while export requires a final complete authority check before returning bytes. The new export must use the complete partitions, never infer a busy complement from duration-filtered slots. RFC 5545 sections 3.6 and 3.6.4 permit multiple VFREEBUSY components and define required UID/DTSTAMP with optional scheduling roles; a method-free download remains distinct from RFC 5546 mail. Source checked: [RFC 5545](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.4).

Group a stateless subject/common-free export endpoint, one immutable request DTO, independent permission/context, shared calculation/final-source rechecks, pure packaging, generated clients, Flutter and focused/two-host validation. No SQL tables, migrations, stored snapshots, worker, email method, recipients, routes or HTTP feed changes are proposed.

## Input and output

Propose `exportSubjectFreeBusy(CalendarSubjectFreeBusyExportRequest) -> ByteData` with explicit UTC from/until, selected opaque host targets and `perTarget` or `commonFree` mode. Use existing subject validation/deduplication: at most 32 raw target inputs, eight distinct targets, eight calendars per target and 16 total calendar evaluations in one host scope and transaction. First occurrence order survives deduplication. The window is positive, whole-second UTC, at most 31 days within [1970,2100), with only the existing exclusive-midnight endpoint exception.

The request has no minimum-duration filter. Calculate with a one-second minimum only for compatibility with the existing query shape, and serialize the complete partition independently of derived slots. `perTarget` creates one VFREEBUSY component per normalized selected target, in that order. `commonFree` creates one component from the complete aggregate partition, where free requires every selected target to be free. Preserve busy/tentative/unavailable classifications through the existing complete-partition combiner. Do not expose contributor identities, event IDs, labels, titles, counts or host resolution revisions.

Use independent fresh UUID protocol UIDs per component and an actual whole-second database DTSTAMP for the file. These are ephemeral snapshot identities, not native IDs, source UIDs or subscription identities. The caller maps per-target component order to its own normalized selection; the file contains no automatic native-target identifier or label. Emit VCALENDAR/VFREEBUSY without METHOD, ORGANIZER, ATTENDEE or scheduling claims. No delivery/booking or automatic source retrieval follows. Preserve the existing half-open native calculation and emit the same enclosing VFREEBUSY bounds without subtracting a second or claiming coverage beyond the native end.

All requested targets must be complete and authorized before any bytes are returned. A denied, missing, cross-scope, changed-resolution, unknown or over-budget contributor rejects the complete download; never omit it, emit an empty success or return partial components. A genuinely complete all-free partition may produce an empty FREEBUSY set under the existing snapshot profile. Existing query APIs retain their complete/unknown response semantics.

## Authorization and calculation

Add independent `CalendarPermission.exportSubjectFreeBusy` for each actual selected subject, alongside `readSubjectAvailability`, existing per-calendar `projectCalendarAvailability` and every actual event/rule source projection. Reuse the immutable complete query/target context and actual parent/object snapshots. Subject-summary rights remain independent of direct calendar-detail or direct per-calendar export rights; an export-specific subject gate controls downloading this summary.

Normalize/freeze all client collections before async work. Resolve every target through the trusted host adapter, retaining its complete contributor set/revision privately. Keep data loading, candidate planning, calculation and serialization inside the active scope transaction. Collect every actual authorization request, not detail-list filters. Before returning output, recheck all target/export/source permissions and every trusted resolution revision/set plus the actor/policy revision. Changed or incomplete resolution fails the whole export. Preserve declared coordinated versus external fresh-check guarantees; an after-check external revocation race remains.

Reuse the existing shared source/projection/recurrence limits across all targets rather than resetting them per component. Preserve per-partition caps and impose a 1,000-period aggregate wire limit and 262,144-byte output limit; over-limit output rejects atomically rather than clipping. These are native editing/export profile limits, not universal RFC limits. Existing native query budgets/behavior and per-calendar export stay unchanged.

## API/example and validation

The generated immutable DTO contains only targets, UTC bounds and mode. The example adds explicit per-target/common export controls to its availability query screen, explains selected-target ordering and snapshot semantics, and shows failures without implying free time. It never fetches remote content or publishes the download to bearer feeds.

Validate single/multiple/duplicate targets, common versus per-target meaning, exact ordering, complete all-free versus unknown, independent subject export/read/source denials, hidden contributor exclusion, final revocation/resolution changes, raw/shared/output budgets, DATE/DST/recurrence/tentative/working-hours composition, second precision/range and supported standalone wire structure. Test final failure after candidate serialization with no returned partial bytes and no native state changes. Two real hosts/JWT clients must observe committed source changes; the connected Flutter journey must exercise both modes and failure recovery. Run focused tests during development, complete core/iCalendar/module VM/Chrome and affected SDK/client/Flutter checks at group completion, and full exact-head hosted checks before readiness. Commit the whole group once.

## Alternatives and consequences

One target per download would simplify anonymous component mapping, but require separate requests and lose one atomic multi-target snapshot. Publishing native target IDs/labels would make files self-identifying at the cost of new disclosure rules; this profile instead preserves only caller-known selection order. It does not promise that an external calendar UI retains that order or associates components with people. Reusing duration-filtered free slots would discard valid short intervals and is rejected. Reusing durable mail would add authority/storage/retention work unnecessary for a download.

The chosen profile keeps export authority independent and makes incomplete coverage fail visibly. A host must still supply complete contributor resolution; this does not create an exclusive reservation or extend the existing cross-scope/search limits.

## Remaining scope

This is an authenticated download, not subject/common-free scheduling mail. Durable publication would require a separately reviewed owner/mailbox/source basis and deletion/dispatch contract. Larger/cross-scope searches, provider trust, real mail, remaining selected scheduling methods, operational cleanup and external-client/release evidence remain required separate work. No contract acceptance or synthetic round trip establishes blanket client interoperability.
