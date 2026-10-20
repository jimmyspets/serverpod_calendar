# ADR 0032: ISO 8601 native week convention

Status: **ISO week numbering and Monday first day explicitly required by the maintainer; explicit non-Monday RFC WKST policy pending clarification**. Date: 2026-10-20.

## Confirmed native convention

Use ISO 8601 for native calendar week numbering and the first day of the week:

- Weeks run Monday through Sunday; weekday numbers are Monday 1 through Sunday 7.
- Week 1 contains January 4, equivalently the year's first Thursday, and has at least four days in the new year.
- An ISO week-numbering year has 52 or 53 weeks. Keep its year distinct from the Gregorian calendar year near New Year.
- For example, 2021-01-01 is Friday of ISO week 2020-W53, and 2024-12-30 is Monday of 2025-W01.

Native calendar presentation must use Monday as its first day and ISO week labels, rather than deriving either from device locale. The Flutter calendar GUI and a standalone ISO week-label API remain future work; do not claim they exist. The current core already numbers weekdays Monday 1 through Sunday 7 and defaults recurrence WKST to Monday. Its Monday-based week-number path is tested separately from alternate RFC starts.

Sources: [ISO 8601 overview](https://www.iso.org/iso-8601-date-and-time-format.html) identifies the standard; [Python's primary ISO calendar documentation](https://docs.python.org/3/library/datetime.html#datetime.date.isocalendar) explicitly describes the Monday/Thursday and week-year rules. These sources describe the convention, not complete project conformance to every ISO 8601 representation.

## RFC recurrence distinction and remaining clarification

RFC 5545 [section 3.3.10](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10) supports all WKST weekdays, and the previously selected recurrence profile implements them under [ADR 0031](0031-date-recurrence-week-numbers.md). When WKST is omitted, RFC 5545 defaults it to Monday (`WKST=MO`), matching the native ISO convention. `WKST` means the recurrence rule's week start: `WKST=MO` is Monday and `WKST=SU` is Sunday. It groups weeks for weekly INTERVAL/BYDAY rules and defines week boundaries for BYWEEKNO. It does not set a Flutter calendar's layout. A non-Monday WKST calculation is RFC rule-specific week numbering; it must not be described as ISO week numbering or change native calendar presentation.

The maintainer's newer ISO instruction takes precedence over older narrative guidance. Clarification has been requested on whether explicitly supplied non-Monday WKST values remain permitted rule-specific exceptions or must be rejected. Until resolved, the code still accepts them; no implementation restriction or silent conversion is claimed. Never silently replace a supplied WKST, because that can change recurrence dates.

## Boundaries and validation

The confirmed ISO convention does not widen date years 0001–9999 or named-zone calculations beyond civil years 1900–2037. The main README warning remains unchanged. No alternate calendar, arbitrary zone, parser or new interoperability claim is introduced.

This increment is documentation-only. Validate relative links, consecutive ADR numbering, requirement/RFC/roadmap consistency and changed-file scope. Existing 272 VM/Chrome test evidence includes Monday-based boundaries and a complete 400-year first/last-week membership comparison; those tests are previous evidence and are not rerun for text changes. A later code/profile change must adapt tests and record its own validation.
