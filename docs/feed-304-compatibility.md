# Feed 304 compatibility on Serverpod 4.1.2

The 4.1.2 workspace's two-host feed smoke test observed a 304 response with
`Content-Length: 0` for a 692-byte selected representation. The response had
the correct ETag and no body. The test rejects this length: when a 304 includes
Content-Length, [RFC 9110 section 8.6](https://www.rfc-editor.org/rfc/rfc9110#section-8.6)
requires it to equal the length of the selected 200 response.

The module's route requests an empty stream with no length for 304. The
resolved Relic IO adapter does not send a body for 304, and Dart's HTTP server
then emits length zero. A separate local raw-socket probe reproduced the zero
header using default, nonpersistent, unknown-length, unbuffered and flushed
responses. Passing an empty stream to `dart:io` before close omitted the header,
but the Relic 2.0.0 adapter consumes rather than writes a body on 304. Relic's
response framing also excludes application-supplied Content-Length for 304,
so setting that header in the existing route does not fix the problem.

The strict feed assertion remains in place. A compatible upstream adapter or
another separately reviewed transport solution is required before claiming
that 4.1.2 passes this release gate. No raw-socket workaround, incorrect-header
exception, dependency fork or production proxy behavior is assumed here.
`dart run tool/host_smoke.dart --feeds-only` now reproduces the failure without
running unrelated feature journeys, using the configured synthetic test hosts.
The separate stale imported feed-schema snapshot warning is tracked in the
[upgrade record](serverpod-4.1.2-upgrade.md).
