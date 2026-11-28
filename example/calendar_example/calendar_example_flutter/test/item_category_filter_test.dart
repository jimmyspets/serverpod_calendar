import 'package:calendar_example_flutter/item_category_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

void main() {
  testWidgets(
    'exact category and language Apply Clear preserve spelling and reject blank',
    (tester) async {
      final queries = <cal.CalendarCategoryFilter?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCategoryFilter(
              prefix: 'item',
              busy: false,
              onApply: queries.add,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('item-category-apply')));
      await tester.pump();
      expect(queries, isEmpty);
      expect(find.byKey(const Key('item-category-error')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('item-category-value')),
        '  Å, 🧰  ',
      );
      await tester.enterText(
        find.byKey(const Key('item-category-language')),
        'SV',
      );
      await tester.tap(find.byKey(const Key('item-category-apply')));
      await tester.pump();
      expect(queries.single!.value, '  Å, 🧰  ');
      expect(queries.single!.language, 'SV');
      await tester.tap(find.byKey(const Key('item-category-clear')));
      await tester.pump();
      expect(queries.last, isNull);
      expect(find.byKey(const Key('item-category-error')), findsNothing);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('item-category-value')))
            .controller!
            .text,
        isEmpty,
      );
    },
  );
}
