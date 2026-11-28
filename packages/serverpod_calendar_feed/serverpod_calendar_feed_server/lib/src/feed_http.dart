part of 'feed_module.dart';

final class CalendarFeedRepresentation {
  CalendarFeedRepresentation(Uint8List bytes)
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView(),
      etag = '"${sha256.convert(bytes)}"';
  final Uint8List bytes;
  final String etag;
}

Future<CalendarFeedRepresentation?> _feedRepresentation(
  Session session,
  _Runtime runtime,
  String token,
) async {
  if (token.length != 43 || !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)) {
    return null;
  }
  final digest = sha256.convert(utf8.encode(token)).toString();
  final credential = await CalendarFeedCredentialRecord.db.findFirstRow(
    session,
    where: (t) => t.digestVersion.equals(1) & t.digest.equals(digest),
  );
  if (credential == null || credential.revokedAt != null) return null;
  final identity = await CalendarFeedIdentityRecord.db.findById(
    session,
    credential.feedId,
  );
  if (identity == null || identity.deletedAt != null) return null;
  try {
    return await CalendarModule.publicationTransaction(
      session,
      identity.scopeKey,
      (port) async {
        final current = await CalendarFeedCredentialRecord.db.findById(
          session,
          credential.id!,
          transaction: port.transaction,
        );
        if (current == null ||
            current.revokedAt != null ||
            current.digestVersion != 1 ||
            current.digest != digest ||
            current.feedId != identity.id) {
          return null;
        }
        final feed = await _loadFeed(
          session,
          identity.scopeKey,
          current.feedId,
          port.transaction,
        );
        final eventBytes = await port.eventBytes(
          feed.settings.calendarIds,
          feed.data.authorityReference,
        );
        final root = parseIcalendarSyntax(eventBytes).components.single;
        final properties = <IcalendarSyntaxEntry>[
          IcalendarSyntaxProperty('UID', feed.data.protocolUid.toString()),
          IcalendarSyntaxProperty(
            'LAST-MODIFIED',
            serializeIcalendarDateTime(
              TimedValue.utc(feed.data.protocolModifiedAt),
            ),
          ),
        ];
        IcalendarSyntaxProperty text(
          String name,
          String value,
          String? language,
        ) => IcalendarSyntaxProperty(
          name,
          encodeIcalendarText(value),
          parameters: [
            if (language != null)
              IcalendarSyntaxParameter('LANGUAGE', [language]),
          ],
        );
        final metadata = feed.settings.protocolMetadata;
        if (metadata != null) {
          properties.addAll([
            for (final v in metadata.names) text('NAME', v.value, v.language),
            for (final v in metadata.descriptions)
              text('DESCRIPTION', v.value, v.language),
            if (metadata.color != null)
              IcalendarSyntaxProperty('COLOR', metadata.color!),
          ]);
        }
        final extra = feed.settings.supplementalMetadata;
        if (extra != null) {
          properties.addAll([
            if (extra.url != null) IcalendarSyntaxProperty('URL', extra.url!),
            for (final category in extra.categories)
              text('CATEGORIES', category.value, category.language),
            for (final image in extra.images)
              IcalendarSyntaxProperty(
                'IMAGE',
                image.uri,
                parameters: [
                  IcalendarSyntaxParameter('VALUE', ['URI']),
                  if (image.mediaType != null)
                    IcalendarSyntaxParameter('FMTTYPE', [image.mediaType!]),
                  if (image.display != null)
                    IcalendarSyntaxParameter('DISPLAY', image.display!),
                ],
              ),
            if (extra.refreshHint != null)
              IcalendarSyntaxProperty(
                'REFRESH-INTERVAL',
                serializeIcalendarDuration(
                  CalendarDuration(
                    weeks: extra.refreshHint!.weeks,
                    days: extra.refreshHint!.days,
                    hours: extra.refreshHint!.hours,
                    minutes: extra.refreshHint!.minutes,
                    seconds: extra.refreshHint!.seconds,
                  ),
                ),
                parameters: [
                  IcalendarSyntaxParameter('VALUE', ['DURATION']),
                ],
              ),
          ]);
        }
        final bytes = serializeIcalendarSyntax(
          IcalendarSyntaxDocument([
            IcalendarSyntaxComponent('VCALENDAR', [
              ...root.entries.whereType<IcalendarSyntaxProperty>(),
              ...properties,
              ...root.entries.whereType<IcalendarSyntaxComponent>(),
            ]),
          ]),
        );
        return CalendarFeedRepresentation(bytes);
      },
    );
  } on CalendarException catch (e) {
    if (e.code == CalendarFailureCode.accessDenied) return null;
    rethrow;
  } on CalendarFeedException catch (e) {
    if (e.code == CalendarFeedFailureCode.accessDenied) return null;
    rethrow;
  }
}

final class _Tag {
  const _Tag(this.value, this.weak);
  final String value;
  final bool weak;
}

final class _Tags {
  const _Tags(this.any, this.values);
  final bool any;
  final List<_Tag> values;
}

/// RFC 9110 entity-tag lists. Commas inside quoted opaque values are data;
/// backslashes are not escapes. Empty list members are bounded and ignored.
_Tags _parseTags(Iterable<String> lines) {
  final bounded = <String>[];
  var length = 0;
  for (final line in lines) {
    length += line.length + 1;
    if (bounded.length >= 64 || length > 8192) throw const FormatException();
    bounded.add(line);
  }
  final value = bounded.join(',');
  var i = 0;
  void whitespace() {
    while (i < value.length &&
        (value.codeUnitAt(i) == 32 || value.codeUnitAt(i) == 9)) {
      i++;
    }
  }

  whitespace();
  if (i < value.length && value[i] == '*') {
    i++;
    whitespace();
    if (i != value.length) throw const FormatException();
    return const _Tags(true, []);
  }
  final tags = <_Tag>[];
  var empty = 0;
  while (i < value.length) {
    whitespace();
    if (i == value.length) break;
    if (value[i] == ',') {
      if (++empty > 32) throw const FormatException();
      i++;
      continue;
    }
    var weak = false;
    if (value.startsWith('W/', i)) {
      weak = true;
      i += 2;
    }
    if (i >= value.length || value[i] != '"') throw const FormatException();
    final start = i++;
    while (i < value.length && value[i] != '"') {
      final c = value.codeUnitAt(i++);
      if (c != 0x21 && !(c >= 0x23 && c <= 0x7e) && !(c >= 0x80 && c <= 0xff)) {
        throw const FormatException();
      }
    }
    if (i == value.length || tags.length >= 64) throw const FormatException();
    tags.add(_Tag(value.substring(start, ++i), weak));
    whitespace();
    if (i == value.length) break;
    if (value[i++] != ',') throw const FormatException();
  }
  return _Tags(false, tags);
}

/// Apply only after current credential and complete publication authorization.
/// Returns 200, 304 or 412; malformed/budget-exceeding fields throw.
int calendarFeedConditionalStatus(
  String etag, {
  Iterable<String>? ifMatch,
  Iterable<String>? ifNoneMatch,
}) {
  if (ifMatch != null) {
    final tags = _parseTags(ifMatch);
    if (!tags.any && !tags.values.any((t) => !t.weak && t.value == etag)) {
      return 412;
    }
  }
  if (ifNoneMatch != null) {
    final tags = _parseTags(ifNoneMatch);
    if (tags.any || tags.values.any((t) => t.value == etag)) return 304;
  }
  return 200;
}

/// Register at /calendar-feed. Never invokes Route's URL-derived web session.
class CalendarFeedRoute extends Route {
  CalendarFeedRoute(this.pod, {this.mountPath = '/calendar-feed'})
    : super(methods: Method.values.toSet(), path: '/**') {
    if (!mountPath.startsWith('/') ||
        mountPath.endsWith('/') ||
        mountPath.contains('?') ||
        mountPath.contains('#')) {
      throw ArgumentError('Invalid feed mount path');
    }
    if (!calendarFeedLogRedactionEnabled(mountPath)) {
      throw StateError(
        'Wrap host startup with runWithCalendarFeedLogRedaction',
      );
    }
  }
  final Serverpod pod;
  final String mountPath;

  Response _error(int code, {bool method = false}) => Response(
    code,
    headers: Headers.fromMap({
      'cache-control': ['no-store'],
      'referrer-policy': ['no-referrer'],
      'x-content-type-options': ['nosniff'],
      if (method) 'allow': ['GET, HEAD'],
    }),
  );

  @override
  Future<Result> call(Request req) async {
    Session? session;
    try {
      if (!calendarFeedLogRedactionEnabled(mountPath)) return _error(503);
      final prefix = '$mountPath/';
      final path = req.url.path;
      if (req.url.hasQuery ||
          !path.startsWith(prefix) ||
          !path.endsWith('.ics')) {
        return _error(404);
      }
      final token = path.substring(prefix.length, path.length - 4);
      if (token.length != 43 ||
          !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)) {
        return _error(404);
      }
      final runtime = CalendarFeedModule._installed[pod];
      if (runtime == null) return _error(503);
      session = await pod.createSession(enableLogging: false);
      final representation = await _feedRepresentation(session, runtime, token);
      if (representation == null) return _error(404);
      if (req.method != Method.get && req.method != Method.head) {
        return _error(405, method: true);
      }
      final status = calendarFeedConditionalStatus(
        representation.etag,
        ifMatch: req.headers['if-match'],
        ifNoneMatch: req.headers['if-none-match'],
      );
      if (status == 412) return _error(412);
      final headers = Headers.fromMap({
        'etag': [representation.etag],
        'cache-control': [
          'private, no-cache, max-age=0, must-revalidate, no-transform',
        ],
        'referrer-policy': ['no-referrer'],
        'x-content-type-options': ['nosniff'],
        if (runtime.options.contentLanguage != null)
          'content-language': [runtime.options.contentLanguage!],
      });
      // HEAD preserves GET length; 304 omits length and carries no body.
      return Response(
        status,
        headers: headers,
        body: status == 304
            ? Body.fromDataStream(
                const Stream<Uint8List>.empty(),
                mimeType: null,
              )
            : req.method == Method.head
            ? Body.fromDataStream(
                const Stream<Uint8List>.empty(),
                contentLength: representation.bytes.length,
                mimeType: const MimeType('text', 'calendar'),
                encoding: utf8,
              )
            : Body.fromData(
                representation.bytes,
                mimeType: const MimeType('text', 'calendar'),
                encoding: utf8,
              ),
      );
    } on FormatException {
      return _error(400);
    } catch (_) {
      return _error(503);
    } finally {
      // Never attach the request or caught exception to a diagnostic context.
      // Closing must not allow a failure to reach the outer URI-aware reporter.
      try {
        await session?.close();
      } catch (_) {
        /* fail closed without request data */
      }
    }
  }

  @override
  FutureOr<Result> handleCall(Session session, Request request) => _error(503);
}
