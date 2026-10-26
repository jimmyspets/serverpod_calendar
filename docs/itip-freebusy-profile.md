# Pure VFREEBUSY scheduling profile

Status: scoped pure implementation under [ADR 0121](adr/0121-pure-freebusy-scheduling-messages.md); concrete mechanics remain draft review material. Focused tests and selected broader batch checks passed. This is independent of the [pure event-message adapter](itip-message-profile.md), [authorized snapshot output](freebusy-export.md) and any future mail/reconciliation service.

The iCalendar package exposes `parseIcalendarFreeBusyMessage`, `validateIcalendarFreeBusyMessage` and `serializeIcalendarFreeBusyMessage`. Each immutable `IcalendarFreeBusyMessage` contains its source tree, product ID, method and explicit component list. A component retains source UID/stamp/window, unverified organizer/attendee addresses, text/link metadata, grouped periods and result claims. No component implicitly selects a native calendar or person.

The method tables follow [RFC 5546 section 3.3](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.3), with explicit narrower limits:

| Method | Components | Attendees | Busy periods | Other constraints |
| --- | --- | --- | --- | --- |
| PUBLISH | One or more | Forbidden | Optional | No REQUEST-STATUS |
| REQUEST | Exactly one | One or more | Forbidden | No URL or REQUEST-STATUS |
| REPLY | Exactly one | Exactly one | Optional | REQUEST-STATUS and URL permitted |

Every component requires a nonempty UID, UTC DTSTAMP, ORGANIZER and increasing UTC DTSTART/DTEND. CONTACT is optional and singular; COMMENT repeats, retaining language/alternative-representation annotations. URL follows the existing absolute HTTP/HTTPS profile without credentials. Organizer annotations are source data; VFREEBUSY attendees accept no parameters under [RFC 5545 section 3.8.4.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.1). Nothing is fetched or sent. Duplicate singleton properties reject. VTIMEZONE, nested components, SEQUENCE, recurrence, event/task properties, arbitrary extension properties and unsupported parameters reject.

FREEBUSY retains each source property group and comma-separated list. `IcalendarFreeBusyGroup.periods` contains UTC `TimedEventSpan` values preserving explicit end versus nominal positive duration. Source order, overlaps and duplicates remain intact. Periods outside the advertised window are preserved, never silently clipped. All bounds still obey whole-second `[1970,2100)` timing, with only explicit exclusive endpoints permitted at 2100 midnight; duration calculations must also remain within that endpoint. No recurrence expansion occurs here.

An omitted FBTYPE remains null, distinct from explicit BUSY. Standard values are interpreted case-insensitively without rewriting source spelling. Bounded unknown FBTYPE tokens are preserved and have source-level effective type BUSY under [RFC 5545 section 3.2.9](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.2.9). This token rule does not enable arbitrary extension properties. FREE remains an untrusted claim, not an authorized free interval. REQUEST-STATUS uses the existing bounded numeric/text source codec; success/failure codes execute no action.

Default ceilings are 32 published components, 1,000 total explicit periods and 64 attendees per component. Component/period ceilings can be configured within finite bounds; shared syntax, metadata, explicit-value and candidate-work budgets apply to the whole envelope. Validation also bounds manually built syntax trees. Serialization deterministically quotes/folds the retained source without inventing identity, versions, periods, response text or delivery.

A parsed request causes no lookup or automatic reply. Reconciliation must later verify the sender/recipient, matching request, requested window, current host/source authority, disclosure, freshness and coverage. A successful or empty reply does not prove that a window is free. The existing authenticated snapshot service continues to require complete authorized calculation, a bounded 31-day window and privacy-safe output; these source codecs do not relax it. Standalone VFREEBUSY file import remains deferred. No mail, stored scheduling transition or external-client interoperability is established by these tests.
