# Timezone calculation limits and database updates

Current profile: [ADR 0041](adr/0041-whole-second-1970-2100-profile.md). Keep `timezone` 0.11.2; this project does not use `time_machine2` at runtime or to generate data.

## Supported meaning and horizon

Ordinary calendar dates are **1970-01-01 inclusive to 2100-01-01 exclusive**. Precision is whole seconds. The final ordinary date is 2099-12-31. The explicit 2100-01-01 midnight boundary exists only for exclusive event/query ends. Named-zone conversion can place these valid local boundaries into UTC in 1969 or 2100; generated calculation data therefore covers **1969-12-30T00:00:00Z to 2100-01-03T00:00:00Z exclusive**. This padding does not extend ordinary storage acceptance.

Generated transitions after 2037 use the selected IANA rules, including future recurring rules, calculated by IANA's own compiler. They are not guessed from past offsets. A government can change future rules; current output is conditional on the pinned data version. Some historical records deliberately use unknown `-00` offsets. Such periods and the unknown-only Factory entry fail explicitly. Failures must never become free time, skipped content or a partial successful feed.

Exact case-sensitive names and aliases are retained. Do not guess Windows names, abbreviations or spelling/case. Explicit gaps use the pre-gap offset, folds use their first instant, and generated recurrence gaps are omitted without consuming COUNT. Nominal calendar days remain different from 24 elapsed hours. The resolver's immutable tables do not alter the host's global timezone registry.

## Reproducible generation

The runtime artifact is generated source at `packages/serverpod_calendar_core/lib/src/bounded_timezone_data.dart`. Never hand-edit its payload. `toolchain.json` records the package/IANA/profile versions, archive SHA-256 values, padded coverage and serialized TZF SHA-256.

Prerequisites: pinned Dart SDK; Linux or WSL with Python 3.9+ (`zoneinfo`), a C99 compiler and GNU make. The generator builds **the pinned IANA zic compiler**, not the distribution's possibly older timezone compiler. Archives/intermediate files/build products stay under ignored `.local/timezone-build`. Compiler sources and compiled zone files use release-specific subdirectories so an update cannot retain removed aliases from an older release.

From repository root in PowerShell:

```powershell
wsl --exec sh -c 'cd /mnt/k/sources/serverpod_calendar && python3 tool/build_timezone_source.py'
& K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe run packages/serverpod_calendar_core/tool/encode_timezone_data.dart
Get-FileHash .local/timezone-build/bounded.tzf -Algorithm SHA256
```

Adapt the repository/SDK mount paths to your checkout. On Linux, run `python3 tool/build_timezone_source.py`, then the pinned `dart run` encoder from repository root.

The Python step verifies tzcode/tzdata archives before extracting only top-level regular files, builds zic, compiles the padded horizon and verifies explicit TZif boundary transitions. It also generates the test reference using Python's separate TZif reader. The Dart step constructs `timezone` locations, serializes them, checks round-trip zone count and emits embedded data/version metadata. It intentionally does not apply the dependency's first-transition sentinel filtering. The decoder/serializer are internal package APIs: changing the package pin requires checking format compatibility and the whole generation/validation workflow.

The reference fixture covers January and July of all 130 supported years across 597 usable names (155,220 samples), including explicitly unknown periods. Additional tests check exact transitions and non-hour changes. Two data generations with the same pins must produce identical runtime/reference artifacts and the recorded checksum. These checks do not prove legislation cannot change.

## Updating to another IANA release

1. Preserve the previous intermediate tables/version for comparison. Obtain the desired IANA **tzcode and tzdata** archives from the official releases site. Verify the chosen release and archive integrity against independently obtained release information; never replace a failed checksum with a newly downloaded checksum merely to make generation succeed.
2. Update `VERSION` and both archive SHA-256 pins in `tool/build_timezone_source.py`. Keep the generated horizon unchanged unless a separately approved profile change requires it. Update the IANA/archive/profile metadata in `toolchain.json` consistently. Do not edit upstream dependency files or generated payloads.
3. Run both generation commands. Record the generated TZF checksum in `toolchain.json`. Regenerate twice and check byte-for-byte stability, including formatting of the reference fixture. Review added/removed aliases, unknown-offset changes and offset/transition changes, especially after 2037. A new expected digest alone is not an explanation of a change.
4. Run focused date/zone/profile tests, then the complete core VM/Chrome suites and workspace format/analysis checks. Exercise 1970/2099, the exclusive endpoint, UTC spillover, DST gaps/folds, negative/half-hour changes and affected zones. When stored module features exist, run their integration and multi-instance checks too.
5. Update release notes, the ADR/profile/version documentation and compatibility evidence. Commit the generator/pins, runtime data and reference fixture together. Deployment must make one intended data version consistent across hosts/workers; mixed-version calculation results must not silently overwrite one another.
6. Before publishing or dispatching affected future work, compare old/new projections. Preserve authoritative named-zone local fields, exact zone identity and original recurrence IDs; recompute UTC projections from those fields. Recheck booking conflicts and rebuild affected availability/feed output/ETags. Invalidate and recreate superseded pending alarms/outbound work transactionally with generation/revision checks. Do not blindly move an explicitly UTC event to preserve a local clock reading.
7. Persist the version used for derived data, coordinate recalculation across hosts, and define rollback of projections/pending work if deployment is reverted. Already delivered notifications or exported calendar data cannot simply be recalled. Durable upgrade/recalculation and these module workflows remain required future implementation, not functionality supplied by the core package.

Source archives are available from [IANA releases](https://data.iana.org/time-zones/releases/). [RFC 9636](https://www.rfc-editor.org/rfc/rfc9636.html#section-3.3) describes future-rule information in TZif. This repository retains its Apache 2.0 LICENSE; IANA source/data provenance is recorded in the pins and generated header.

## Imported definition comparison

The first [VEVENT/VTIMEZONE adapter](icalendar-event-adapter.md) under [ADR 0065](adr/0065-first-vevent-wire-adapter.md) compares entire normalized offset functions through NamedZoneResolver.calendarProfileSnapshot over fixed UTC [1969-12-31, 2100-01-02). This is calculation-only edge padding; ordinary event dates stay [1970-01-01, 2100-01-01), with the existing explicit endpoint exception. Validation-only earlier seeds do not widen storage. Unknown rules still fail, and a correct modern/event-date-limited definition may reject because full-history agreement is required. Metadata labels do not determine offsets; imported rules never update the database automatically.

After a pinned-data update, revalidate accepted source definitions and recalculate derived projections before trusting their old version evidence. The update/generation procedure above is unchanged; do not hand-edit the generated payload. Database persistence/import upgrade coordination remains a later layer.
