# Exceptional range restoration validation

Results below describe local checks on the pinned Dart, Flutter and Serverpod versions. They are not evidence of external calendar-client interoperability, real mail delivery or hosted CI readiness.

- Focused VM tests covered bounded DATE, UTC and named-zone searches and aliases; EXDATE, PERIOD and COUNT; DST gaps and folds; moved exceptions and inherited content; retained cancellations; component collisions; the 2099 boundary; byte/work limits; and complete REQUEST validation. The public-library REQUEST test passed all **26 tests**, and the subsequent occurrence-status omission regression passed separately.
- `dart analyze --fatal-infos` passed for the workspace after the source-status fix. The complete core VM and Chrome suites passed **540 tests each**; the iCalendar VM and Chrome suites passed **642 each**. After the source-status fix, the calendar module unit suites passed **788 VM** and **31 Chrome** tests; the additional occurrence-status regression ran separately.
- `python tool/check_docs.py` passed with 4,051 relative links and consecutive ADRs 0001–0186.
- The Serverpod MCP hot-reload attempt reported that the example server was not running. No live reload result is claimed.
- The full repository check started before the final optional-text refinement, so it cannot establish exact-final-source success even if it passes. An exact-commit hosted run remains required before readiness.
