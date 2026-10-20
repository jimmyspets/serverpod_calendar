# ADR 0006: Resource calendars and free/busy availability

Status: **Proposed**. Date: 2026-10-19. The maintainer requires calendars for rooms/venues and equipment, plus free/busy queries for users and other subjects. Required capability is confirmed; the model and policies below await review.

## Subject model

Extend external subject kinds to `user`, `group`, `room`, `venue`, and `equipment`, with an extension mechanism for host-defined kinds. Keep namespaced opaque references and host policy resolution. Proposed resource catalog ownership stays with the host, like user/group identities; module association rows do not copy a resource directory.

Distinguish an association that contributes events to a subject's availability from an association used for access/administration. A room's manager is not personally busy whenever the room is booked. Proposed association metadata explicitly marks availability contribution; host authorization independently defines who may view/manage a calendar. A subject can have several contributing calendars, and a calendar can contribute to several subjects. De-duplicate calendar selections and merge intervals rather than counting the same event twice.

## Query and calculation

Expose a host-authorized free/busy query for explicit subjects or calendars and a required bounded `[ADR 0012](0012-calendar-availability-policy.md) extends this proposal for working/opening hours and overrides. Expand recurring series inside the query bounds, apply RDATE/EXDATE, moved occurrences and cancellations, then clip and merge blocking intervals. Include occurrences whose starts precede the window but whose durations overlap it. Preserve named-zone civil recurrence through DST. Interpret all-day boundaries using an explicit calendar availability zone, not the server's local zone; a subject with several calendars uses each calendar's defined zone. Zero-duration events occupy no interval under the proposed policy.

Use event transparency and status: transparent/cancelled events do not block; opaque confirmed events block. Proposed default treats tentative events as blocking but retains a tentative classification. Support busy, tentative and unavailable classification with a documented precedence for overlap; the exact mapping of host unavailable states is a policy contract. Recurrence overrides can change transparency/status. Store availability zone and blocking metadata with revisions; keep import/export mappings explicit.

For a subject with several contributing calendars, blocking bookings combine by union; optional summary free time intersects each calendar after its own rules, selected fallback and bookings under ADR 0012. Separate calendar results remain available under their own permissions. For a request asking when several subjects are all available, take the intersection of their known free intervals and require complete coverage for every subject. Group calendars can be queried directly; expanding a group into its members requires an explicit host policy and is not implied by an access association. Working/opening hours now belong to required RFC 7953 rule support. Room capacity, equipment quantities, buffers and automatic rejection of overlapping bookings remain separate policy decisions. Outside reported coverage, availability is unknown.

## Privacy and interoperability

Host policy distinguishes free/busy visibility from event-detail access. Return only intervals/classification to a free/busy-only caller, with no titles, descriptions, locations, attendee lists or source event IDs. Calendar query results and aggregate results must not omit hidden contributing calendars and label the remainder free; use a host-authorized complete busy projection or report unavailable coverage.

Provide iCalendar VFREEBUSY output for authorized bounded results in addition to the structured API. Under [RFC 5545](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.4), publish explicit UTC busy periods, not RRULE inside VFREEBUSY. Keep this projection separate from VEVENT subscription output. Supported iTIP VFREEBUSY publication/request/reply and iMIP transport are now first-release work under [ADR 0007](0007-scheduling-and-email.md). General file import of arbitrary VFREEBUSY, CalDAV scheduling/discovery and automatic external resource booking integration remain separate; free/busy export alone does not prove those behaviors.

Existing event-feed URLs do not automatically grant an availability-query endpoint. Proposed first release uses authenticated host access for structured queries/export; any future free/busy bearer URL must have an explicit independent scope, bounded projection and revocation policy. The existing subscription client matrix does not by itself prove native free/busy UI integration.

List-based availability search is a primary native service for host Flutter clients, not a requirement that subscription clients render free/busy UI. [ADR 0008](0008-module-clients-tasks-and-search.md) defines explicit per-target candidate search and common-free search with optional minimum duration, bounded window and per-target coverage. A caller can find available rooms from a list or shared meeting times for people plus resources.

## Consistency and acceptance

A free/busy response describes a snapshot, not a reservation. If exclusive booking is later required, check conflicts and commit the booking in one database transaction; a query followed by an unrelated write cannot guarantee exclusivity.

Approve subject kinds/catalog ownership, association semantics, all-day zones, blocking defaults, permission/coverage contract, group expansion, bounds and booking policy. Test user/room/venue/equipment targets, multiple calendars, adjacent/overlapping intervals, private events, status/transparency, recurring DST and exceptions, unknown/incomplete coverage, tenant isolation and snapshot consistency. Validate privacy-safe VFREEBUSY output separately from subscription-client behavior.
