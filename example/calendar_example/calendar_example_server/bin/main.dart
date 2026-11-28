import 'package:calendar_example_server/server.dart' as server;
import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart';

Future<void> main(List<String> args) =>
    runWithCalendarFeedLogRedaction(() => server.run(args));
