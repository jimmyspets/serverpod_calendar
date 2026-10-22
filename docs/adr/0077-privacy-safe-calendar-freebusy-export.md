# ADR 0077: Privacy-safe per-calendar VFREEBUSY export

Status: **Accepted per-calendar-first scope and separate export authority; concrete mechanics under draft review**. Date: 2026-10-22.

The maintainer selected authenticated export for one calendar and a bounded window next. Unknown/incomplete coverage must reject export. A dedicated host export permission is required in addition to query/source-projection rights. Subject/common-free export and scheduling messages follow separately.

Reuse the existing complete booking/availability calculation under the durable scope transaction. Never build output from filtered event-detail lists. Serialize a complete validated partition to UTC start/end PERIODs, sorted chronologically with explicit BUSY, BUSY-TENTATIVE or BUSY-UNAVAILABLE classification. Omit free intervals only after proving complete coverage; an all-free result has no FREEBUSY properties. Bound the query to the existing 31-day/whole-second/1970–2099 profile and 1,000 partition intervals, with an independent 1 MiB output limit.

Emit one standalone VCALENDAR/VFREEBUSY snapshot with VERSION/PRODID, a fresh unrelated protocol UID, database-clock DTSTAMP and UTC window bounds. No calendar/event/rule IDs, names, counts, participants, organizer, URLs, recurrence or VTIMEZONE are emitted. UID identifies this generated snapshot, not a stored object or reusable scheduling identity. No METHOD, scheduling/mail action, feed URL or HTTP behavior is added. RFC 5545 describes an inclusive enclosing VFREEBUSY window; the module retains its half-open native calculation and emits the same enclosing bounds without subtracting a second or asserting extra coverage beyond the native end.

Authorize query/export on the actual calendar before calculation. Retain all actual source-projection requests and repeat their current checks plus parent query/export checks after serialization, then verify actor/scope/policy context before returning bytes. Module writes serialize across hosts; external policy checks retain the after-check revocation race. Source denial, unknown coverage, excess work or serialization failure returns no file, never an empty successful availability result. Export changes no database revision, timestamp or generation.

No schema change/reset is needed. Generate endpoint/client/test tools with the pinned CLI. Test complete partition and whole-second/profile/budget rejection, privacy/classification/ordering, independent authority and post-serialization denial, unchanged storage, committed cross-host updates and the Flutter generated-client export journey. Do not infer RFC 5546 or external-client interoperability from this slice.

Sources: [RFC 5545 VFREEBUSY](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.4), [FREEBUSY](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.2.6) and [FBTYPE](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.2.9).
