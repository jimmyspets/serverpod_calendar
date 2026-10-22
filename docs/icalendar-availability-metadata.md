# Availability publication metadata wire profile

The pure RFC 7953 adapter now supports the bounded metadata profile under [ADR 0070](adr/0070-availability-wire-metadata.md), extending [timing/composition adaptation](icalendar-availability-adapter.md). This is source validation and preservation, not authenticated database import or authorized publication. Native storage, host approval and wire source data remain distinct.

## Legal contexts and source preservation

VAVAILABILITY accepts one ORGANIZER, URL and CLASS. AVAILABLE rejects those properties. Both contexts accept repeated CATEGORIES, COMMENT and CONTACT, plus registered private X-properties. Existing SUMMARY/DESCRIPTION/LOCATION annotations remain unchanged.

`IcalendarAvailabilityDefinition.metadata` and each `IcalendarAvailable.metadata` expose immutable decoded values. Their original source components retain property spelling, grouping, ordering and annotations for deterministic source serialization. Repeated category groups retain their separate value lists, LANGUAGE, duplicates and order. Escaped commas are decoded after list splitting. COMMENT and CONTACT retain separate TEXT values with optional LANGUAGE/ALTREP; CATEGORIES permits LANGUAGE only. CONTACT is source-only: there is no new native contact editor or storage mapping. Future import must preserve or explicitly reject shapes that native storage cannot represent; it must never silently flatten them.

ORGANIZER retains a raw absolute ASCII calendar-address URI, optional CN, LANGUAGE and DIR. LANGUAGE requires CN in this profile. CN uses parameter decoding, not TEXT unescaping. SENT-BY and other unprofiled parameters reject. DIR and ALTREP are validated absolute ASCII URIs; nothing is fetched. Parsing an organizer never grants ownership, approves an address or sends invitations. Future native import/export must perform the dedicated current host approval checks independently.

URL is an absolute HTTP/HTTPS URI without user information. CLASS accepts PUBLIC, PRIVATE or CONFIDENTIAL only; it never grants permissions. URI values are preserved without TEXT unescaping or silent repair. No URL loading, image loading, mail delivery or polling follows from any metadata.

## Trusted private-property registry

Pass an optional `IcalendarAvailabilityExtensionRegistry` to parse/validate. The default registry is empty. Trusted application code supplies registrations with an X-name, definition/opening contexts and a pure decoded-TEXT predicate. Registry entries and context sets are snapshotted. At most 32 unique case-insensitive names are allowed; names are bounded ASCII X-segments of at most 64 characters. Input cannot register extensions.

Each registered name appears at most once per component, carries one decoded TEXT value and accepts no parameters. Wrong contexts, unknown X-properties and unprofiled IANA properties reject. A false predicate returns invalidValue; a thrown predicate returns extensionValidationUnavailable without leaking the callback exception or source contents. Callbacks must be pure: validation may reach an opening before a later parent fails. They do not execute extension behavior or substitute for host authorization.

For example, trusted host configuration can select a single private label:

```dart
final registry = IcalendarAvailabilityExtensionRegistry([
  IcalendarAvailabilityExtensionRegistration(
    name: 'X-DEMO-LABEL',
    contexts: {IcalendarAvailabilityExtensionContext.definition},
    validateText: (value) => value == 'synthetic',
  ),
]);
final calendar = parseIcalendarAvailabilityCalendar(
  bytes,
  extensions: registry,
);
```

This predicate only validates decoded source TEXT. Authenticated import must still run its separate host authorization and approval checks.

Source serialization preserves previously validated data. It does not rerun a changed registry or current host policy. A future authorized export/publication path must revalidate its applicable current registry and permissions; retaining a parsed object is not a continuing publication grant.

## Overrides and limits

Timing-only overrides inherit omitted metadata from the in-file master. Explicit category/comment/contact groups must match the complete master group list, including order, decoded values and annotations. Explicit private properties must match the corresponding master name/value. Differences reject rather than becoming content overrides. Actual override source retains omission; inherited values are not fabricated in its source metadata view. Timing projection and availability composition are unchanged.

The bounded editing/wire profile is stricter than general RFC TEXT grammar: categories are nonblank single-line values of at most 256 Unicode code points, with at most 64 raw values per component. COMMENT and CONTACT each allow 32 properties per component, each at most 4096 code points. Private values allow 4096 code points each and at most 32 names. Organizer addresses allow 1024 ASCII characters; CN allows 4096 code points; shared absolute URI validation caps DIR/ALTREP at 4096 characters. Existing basic-text and syntax/input limits also apply.

A new `maxAvailabilityMetadataCodePoints` default of 65536 applies across the entire calendar, including all definitions, opening masters and overrides. It counts decoded basic text, repeated values, annotations, URI/address/class values and private names/values before callbacks; duplicates count. Identity, temporal and recurrence input retain their separate existing limits. Trusted configuration may change positive limits within the existing hard maximum. This aggregate budget is independent of native per-definition editing budgets. Failures return no partially adapted calendar or projection.

## Evidence and remaining work

Focused tests cover legal contexts, escaping/group preservation, annotations, registry snapshots and failures, override inheritance/differences, aggregate and per-property bounds, sanitized late failure and unchanged composition. See [validation evidence](scaffold-validation.md) for actual broader checks. This adds no tables, migration, generated clients, scheduling, feeds or external-client compatibility.

The maintainer selected create-only authenticated availability import next, rejecting existing protocol UIDs. Import design must settle authority, atomicity, source preservation and reconciliation boundaries before implementation. Updates remain a separate batch.

## Selected storage/import follow-up

The maintainer confirmed extending native storage before import rather than rejecting supported metadata/UID/PERIOD shapes. [ADR 0071](adr/0071-create-only-availability-import.md) and [the proposed contract](availability-import.md) also record destination-calendar active UID conflicts and preserved initial source protocol versions. The pure adapter does not itself provide these storage or import guarantees.

## Implemented storage follow-up

[ADR 0072](adr/0072-source-preserving-availability-storage.md) and [the implementation guide](availability-storage.md) supersede storage-pending wording for the scoped prerequisite/native behaviors. They document exact UID/group/CONTACT/PERIOD and component-version representations, retention, policy context, query caps and upgrade behavior. Authenticated import remains pending; conversion is not authorization or publication.
