import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/item_text_metadata_editor.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

void main() {
  testWidgets(
    'editor only exposes granted fields and does not dirty imported annotations on load',
    (tester) async {
      final client = Client('http://localhost/');
      addTearDown(client.close);
      await tester.pumpWidget(
        MaterialApp(
          home: ItemTextMetadataEditor(
            client: client,
            event: cal.CalendarEventView(
              id: const cal.Uuid().v4obj(),
              calendarId: const cal.Uuid().v4obj(),
              revision: 1,
              disclosedGroups: [cal.CalendarEventFieldGroup.comments],
              comments: [
                cal.CalendarItemComment(
                  value: 'First\nSecond',
                  parameters: cal.CalendarTextParameters(
                    language: 'SV',
                    alternativeUri: 'cid:note@example.invalid',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('item-text-url')), findsNothing);
      expect(find.byKey(const Key('item-text-class')), findsNothing);
      expect(find.byKey(const Key('item-category-add')), findsNothing);
      final text = find.byKey(const Key('item-comment-value-0'));
      expect(tester.widget<TextField>(text).controller!.text, 'First\nSecond');
      final save = find.byKey(const Key('item-text-save'));
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.ensureVisible(text);
      await tester.pumpAndSettle();
      await tester.enterText(text, '');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('item-comment-language-0')))
            .controller!
            .text,
        'SV',
      );
    },
  );
}
