# serverpod_calendar

A reusable calendar module intended for Serverpod projects, providing calendar, free/busy, availability-search, scheduling, task and alarm services. Host Flutter clients provide most of the GUI.

**Calendar system:** Gregorian only. Recurring events and tasks are included; time zones initially use known named zones with validated matching definitions.

**Platform target:** Serverpod 4.x and later. The initial scaffold pins Serverpod 4.0.4, Flutter 3.47.7 and Dart 3.13.5; additional supported versions require separate verification.

**Status:** executable workspace/authentication scaffold with a tested pure Dart [UTC-window foundation](docs/temporal-core.md); calendar domain services are not implemented yet. The example provides seeded host authentication and generated-client connection checks for the calendar/notification module skeletons. First-release scope remains planned; see the [development guide](docs/development.md), [scaffolding plan](docs/scaffolding-plan.md) and [validation evidence](docs/scaffold-validation.md). Detailed domain designs remain under review. This repository retains its Apache 2.0 [license](LICENSE).

## Start here

- [Documentation index](docs/README.md)
- [First-project requirements](docs/requirements.md)
- [Architecture and module boundaries](docs/architecture.md)
- [Proposed model catalog](docs/models.md)
- [Local example setup and checks](docs/development.md)
- [iCalendar compatibility scope](docs/compatibility.md)
- [RFC property and feature coverage](docs/rfc/README.md)
- [Delivery plan and acceptance checks](docs/roadmap.md)
- [Proposed architecture decisions](docs/adr/README.md)
- [Discussion migration and source gaps](docs/discussion-migration.md)
- [Contributor and agent guidance](AGENTS.md)

The first release centers on authenticated Serverpod APIs and generated Dart clients for Flutter applications, including events, tasks, alarms with a reusable notification boundary and connected Flutter streaming example, scheduling, named zones/recurrence and availability search across lists of people or rooms. Read-only iCalendar subscription feeds expose a documented subset for Apple Calendar on iOS, Google Calendar and Microsoft Outlook; their feature sets do not constrain the module. A feed can publish one or several calendars through multiple independently revocable, long random URLs, with ETag support and no subscriber password. Authenticated host APIs manage calendars, events and publication. Calendars can reference users, groups, rooms, venues and equipment through external subject links. Free/busy queries show available or booked intervals across their calendars, with privacy-aware access. The host owns identities, membership and authorization; resource catalog integration is also proposed at the host boundary. These are requirements awaiting implementation and client verification.

See the [architecture](docs/architecture.md) for the proposed relationship diagram and the [compatibility profile](docs/compatibility.md) for release evidence. First-release scope also includes RFC 7953 availability rules, iTIP scheduling and a restricted iMIP-compatible email profile (S/MIME signatures/encryption deferred; no complete RFC 6047 conformance claim); see the [standards matrix](docs/standards.md). Calendar descriptions target RFC 7986; RFC 9074 has a selected time-based personal alarm profile; RFCs 9073/9253 have selected scoped metadata profiles under [ADR 0014](docs/adr/0014-rfc-extension-decisions.md); detailed alarm lifecycle/wire constraints remain pending, while proximity and arbitrary audio/email actions are deferred. The [alarm boundary proposal](docs/adr/0009-alarms-and-notification-boundaries.md) separates calendar timing/state, reusable notification delivery and Flutter platform integration. VTODO scheduling over iTIP and email is deferred; native tasks, standalone VTODO import/export and task alarms/notifications remain in scope. See [ADR 0011](docs/adr/0011-defer-vtodo-scheduling.md). CalDAV and general upstream-provider synchronization remain separate scope.

The example host/Flutter app must also serve as the automated integration-test application. The module must work with multiple concurrently active Serverpod instances, with cross-instance consistency, durable background-work coordination and recovery tested under [ADR 0018](docs/adr/0018-automated-example-and-multiple-instances.md).

Pinned tools and local setup/run/check commands are documented in the [development guide](docs/development.md). This is the initial workspace/authentication milestone; the complete calendar first release and its client compatibility remain unimplemented and unverified.

## Repository formatting

[Git attributes](.gitattributes) keep text files in LF format on macOS and Windows, overriding platform-specific automatic line-ending conversion. Windows `.bat`/`.cmd` scripts use CRLF on checkout. `.ics` fixtures retain their original bytes for protocol testing. [EditorConfig](.editorconfig) sets UTF-8, two-space indentation and matching editor defaults; intentional Markdown trailing spaces are preserved. No global Git configuration changes are needed.
