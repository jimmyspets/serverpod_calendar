# Serverpod module

This project is a Serverpod module: a reusable package with server code (`serverpod_calendar_server`) and client code (`serverpod_calendar_client`) that other Serverpod projects add as a dependency. A module is not a runnable server, so there is no `serverpod start` and no `serverpod` MCP here.

Working loop, run from `serverpod_calendar_server`:

- Add models (`.spy.yaml`) and endpoints under `lib/src/`.
- `serverpod generate` after every change to a model or an endpoint.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). The migration ships with the module and is applied by the projects that depend on it.
- `dart analyze` and `dart format`.
- `dart test` to run the tests. Module behavior is initially exercised through the real example host and generated clients with isolated Docker test storage. Use the root local-check scripts; the standalone module template config is not the example integration environment.

Prefix table names with the module name (for example `serverpod_calendar_orders`) so they cannot collide with the tables of the projects that use this module.

NEVER edit generated code. `serverpod_calendar_server/lib/src/generated/` and the whole `serverpod_calendar_client` package are rewritten by the code generator. Change the models, the endpoints or `lib/serverpod_calendar_server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Projects that depend on this module reference its types as `module:serverpod_calendar:MyType`, where `serverpod_calendar` is the `nickname` in `config/generator.yaml`.

This is the serverpod_calendar scaffold. Native calendar CRUD/association endpoints, host-policy enforcement and module migrations now exist under docs/adr/0049-first-calendar-crud-implementation.md. Other domain behavior and delivery semantics are pending; follow the root requirements and model review gates.

Native description/RGB and scoped decoded NAME/DESCRIPTION/COLOR metadata extend this slice under root docs/adr/0050-calendar-presentation-and-protocol-text.md. Preserve separate permissions/groups and native/protocol values; immutable adapter validation is not wire parsing or feed support.


ADR 0122's first non-recurring REQUEST workflow, four scheduling tables, origin enum, retention and worker defaults have explicit maintainer approval. The optional scheduling host/transport ports and trusted maintenance entry point are scoped in ../../docs/native-organizer-scheduling.md. Keep immutable publication bytes separate from local edits, reauthorize exact payload/recipients before dispatch and use database leases/fencing. Do not infer native origin from a missing import baseline. Real mail, recurring runtime, cancellation and inbound reconciliation remain separate requirements.


ADR 0123's explicit non-recurring cancellation/reopening batch is approved. Keep cancelled native drafts distinct from the outgoing published snapshot, expose both in trusted host context and retain independent cancellation/lifecycle authority. A local reopen sends nothing and does not withdraw an eligible published CANCEL; a newer explicit REQUEST supersedes it. Reuse the existing delivery tables/retention and keep bound deletion/recurrence/source replacement restrictions. See ../../docs/native-organizer-scheduling.md.


Accepted ADR 0124 extends the existing scheduling runtime to recurring masters with source RRULE/RDATE/EXDATE/PERIOD meaning. Keep bound recurring/non-recurring mode changes blocked, permit validated local pattern edits and retain native orphan checks. New REQUEST publication rejects stored occurrence state; retained exact retries and whole-series cancellation preserve full native overrides/protocol checkpoints. Both ordinary and dedicated host contexts receive those proposed overrides. Outgoing snapshots stay single masters, with no new schema/DTO/retention. See ../../docs/native-organizer-scheduling.md.

Accepted ADR 0126 supersedes that master-only REQUEST boundary for representable supported occurrence bundles. Preserve independent outgoing versions in bounded v2 private checkpoints using existing columns, canonical/native source state and inheritance, complete-message `authorizeMessage` checks, published identity retention and cancellation/reopening floors. Revalidate the entire immutable payload and ledger before retries; keep legacy master-only checkpoint reads and reject malformed/unknown versions. Follow-series content without faithful timing, single/future identity collisions, cancellation and published-removal/reset cases remain unsupported. No new table/migration or real mail is introduced.

Accepted ADR 0127 extends this with v3 retained-original reset projections. Derive complete current single/future timing and selected text in an ephemeral outgoing copy, preserving canonical absence, inheritance and source versions. Persist bounded typed projection markers with the independent ledger in existing columns; read legacy/v2 snapshots without inventing reset history. Validate membership in combined bounded scans, retain end/duration forms and reject unencodable fold ends. Keep immutable retries, host full-message disclosure and self-contained cancellation/reopening ledgers. Clearing native overrides must not omit published originals; removed membership, kind changes, first unrepresentable content-only state and instance cancellation remain unsupported.
