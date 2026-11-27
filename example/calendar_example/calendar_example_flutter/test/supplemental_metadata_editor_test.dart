import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:calendar_example_flutter/supplemental_metadata_editor.dart';

void main() {
  testWidgets(
    'image links are not rendered and refresh unit edits are explicit',
    (tester) async {
      final key = GlobalKey<SupplementalMetadataEditorState>();
      var saves = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SupplementalMetadataEditor(
                key: key,
                busy: false,
                onSave: () {
                  saves++;
                },
                initial: cal.CalendarSupplementalMetadata(
                  categories: [
                    cal.CalendarCategory(value: ' Work ', language: 'SV'),
                  ],
                  images: [
                    cal.CalendarImageLink(
                      uri: 'https://example.invalid/a.png',
                      display: ['BADGE', 'X-PRIVATE'],
                    ),
                  ],
                  refreshHint: cal.CalendarRefreshHint(days: 1),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsNothing);
      expect(key.currentState!.value.categories.single.value, ' Work ');
      expect(key.currentState!.value.images.single.display, [
        'BADGE',
        'X-PRIVATE',
      ]);
      expect(key.currentState!.value.refreshHint!.days, 1);
      await tester.enterText(
        find.byKey(const Key('metadata-refresh-days')),
        '0',
      );
      await tester.enterText(
        find.byKey(const Key('metadata-refresh-hours')),
        '24',
      );
      expect(key.currentState!.value.refreshHint!.hours, 24);
      expect(key.currentState!.value.refreshHint!.days, 0);
      expect(saves, 0);
      final save = find.byKey(const Key('metadata-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pump();
      expect(saves, 1);
    },
  );
}
