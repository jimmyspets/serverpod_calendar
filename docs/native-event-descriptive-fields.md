# Native event priority, coordinates and resource labels

Accepted [ADR 0134](adr/0134-native-event-descriptive-fields.md) adds a bounded master editor and ordinary VEVENT interchange for these fields. The scoped local batch checks passed; see [the evidence record](scaffold-validation.md). The existing pure scheduling profile remains method-specific. No maps, geocoding, directory lookup or resource reservation is implied.

## Values and preservation

`priority` is independently optional and accepts 0–9. Absence and explicit zero remain distinct. This is event importance, separate from availability-rule precedence and reminder urgency.

`geographicPosition` contains a required latitude/longitude pair as exact decimal strings, each at most 64 characters including sign and decimal point. The grammar is an optional sign, one or more ASCII digits, and an optional point followed by one or more digits. Latitude must be within −90 to +90 and longitude within −180 to +180, checked with exact decimal arithmetic. Scientific notation, whitespace, partial pairs and excess precision that exceeds a boundary reject. Accepted signs, leading zeros, trailing zeros and negative zero are preserved without rounding. Coordinate fractions do not relax the library's whole-second calendar times or 1970–2099 date profile.

`resourceGroups` preserve separate ordered RESOURCES properties, decoded labels, duplicates, empty labels, optional LANGUAGE and ALTREP. The bounds are 32 groups, 64 labels combined and 4,096 Unicode code points per label, within existing aggregate metadata/payload limits. Each group has at least one label. An empty label differs from an absent property; an empty group list clears the properties. URI annotations are validated and stored without fetching them. Repeated groups follow verified [RFC 5545 erratum 2677](https://www.rfc-editor.org/errata/eid2677).

The values live in existing event source/protocol JSON. There is no duplicate copy in ordinary `CalendarEventContent`, no new SQL table/column/index and no migration. Older missing fields stay absent. Upgrade all participating hosts and regenerated clients together before accepting writes; mixed old/new metadata writers are outside this unpublished API profile. Other imported participants, references, attachments, alarms and metadata remain intact, and private import baselines remain private. Deletion removes these values with active event data.

## Editing and disclosure

The generated endpoint `calendarEvent.updateDescriptiveMetadata` accepts `CalendarEventDescriptiveRequest(eventId, expectedRevision, metadata)`. It replaces only this subset: null priority/coordinates clear those fields and an empty resource list clears the groups. It never changes timing, status, participants or alarms. Existing ordinary content edits retain the subset.

The server resolves actual scope, calendar and event, checks `updateEventDescriptiveMetadata` before revealing retained-component compatibility, validates the complete proposed protocol state, then rechecks authority before commit. The host sees immutable current and final proposed state. Source replacement also requires this operation when the subset changes on the master or an occurrence, including adding/removing an explicit matching occurrence property. Hosts may map the operation to their existing edit rules; it is independently decidable.

Coordinates use the existing location disclosure group; priority and resources have separate `CalendarEventFieldGroup` values. The host grants each through its existing read/list decisions. Withheld fields are absent and `disclosedGroups` describes the granted projection. No values enter free/busy summaries. Full authenticated export, replacements and scheduling require complete applicable field disclosure plus their existing independent source rights. Bearer-feed publication uses its separate continuing complete-projection policy; `CalendarPublicationRequest.requiredEventGroups` explicitly includes the new groups. That host policy must authorize every projected field before content or 304 responses.

Actual edits advance the master protocol version and publication generation. Identical normalized saves keep protocol versions and feed generation stable; accepted native writes retain their normal API revision/audit behavior. Imported baselines are never rewritten by native edits, so later source replacement detects local changes.

## Occurrences, scheduling and example

Ordinary VEVENT masters accept singular GEO/PRIORITY and repeated RESOURCES. Occurrence omission inherits; explicitly supplied values/groups must match the master in this bounded profile. Exact decimal spelling and group/annotation structure matter. Supplied occurrence presence survives round trips. Editing the master into conflict with retained explicit component metadata rejects atomically rather than deleting or rewriting it. Per-occurrence descriptive editors and differing-value profiles remain separate work.

Outgoing scheduling versions compare effective descriptive fields as well as own component fields. Changing inherited master metadata advances affected outgoing single/range versions even when they omit the properties. Unchanged components keep their versions; native inherited/source state remains unchanged. Existing collision floors, explicit legacy upgrade, stable retries, complete-message host approval and transaction fencing remain in force.

The optional event feed publishes the approved metadata deterministically with continuing full authority and new ETags after actual changes. Its stable publication UIDs and alarm exclusion remain unchanged. Byte-level tests do not establish external client rendering or mail interoperability.

The example offers a separate master editor for optional priority, exact coordinate text and grouped labels/language/alternative URI. Both coordinates must be supplied or cleared together. Each resource label has its own multiline field, preserving embedded newlines and empty labels without using a delimiter; removing a group clears it. Incomplete disclosure disables editing, and stale revisions require reloading. No network retrieval follows from stored coordinates or links.
