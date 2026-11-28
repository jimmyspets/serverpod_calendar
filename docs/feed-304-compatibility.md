# Feed 304 compatibility on Serverpod 4.1.2

The 4.1.2 workspace's two-host feed smoke test observed a 304 response with
`Content-Length: 0` for a 692-byte selected representation. The response had
the correct ETag and no body. The test originally rejected this length: when a 304 includes
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

The two-host feed smoke test now accepts this specific zero length for
Serverpod 4.1.2 with `relic_io` 2.0.1 under
[calendar issue #209](https://github.com/jimmyspets/serverpod_calendar/issues/209).
The wire behavior is tracked in
[Relic issue #454](https://github.com/serverpod/relic/issues/454).
As of 2026-11-28, the upstream issue is open and the newest published
`relic_io` version is 2.0.1.
[Published versions](https://pub.dev/packages/relic_io/versions)

## Adapter candidate and local validation

In the Relic I/O response writer, the 304 path can commit the response head
through a fresh empty stream after consuming the handler body. Shared framing
still sets the response headers and disables chunking as appropriate. The
adapter-specific change inside the existing body suppression branch is:

```dart
body.consume();
if (statusCode == HttpStatus.notModified) {
  await httpResponse.addStream(const Stream<List<int>>.empty());
}
```

On 2026-11-28, an isolated checkout at `f6c2994` used a path override of
`relic_io` 2.0.1 with this patch. The rest of the lockfile resolved to the
same packages. The Serverpod 4.1.2 host built and the strict
`dart run tool/host_smoke.dart --feeds-only` passed on two synthetic hosts
after removing the test exception in that checkout. The conditional response
omitted Content-Length and returned the matching ETag and zero body bytes
for a 692-byte selected representation. The run also passed HEAD,
revocation, publication withdrawal and competing writes. The first attempt
passed the 304 assertion and stopped at the publisher-withdrawal fixture
because the isolated checkout lacked the synthetic Compose configuration.
The complete rerun used that configuration.

The candidate is ready for dependency review. The checked-in lockfile and
temporary feed-test exception remain on the released packages until a
compatible release or a reviewed immutable patch is adopted.

After adopting a compatible fix, remove the version-specific test exception
and run `dart run tool/host_smoke.dart --feeds-only` on the two synthetic hosts.
The smoke test requires the matching ETag, no body and either an absent
Content-Length or the length of the corresponding 200 response. Run the full
repository checks on the same revision. The [current upgrade record](serverpod-4.1-upgrade.md#serverpod-412)
lists the results obtained with the exception.
