import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:calendar_example_flutter/protocol_metadata_editor.dart';

void main() {
  testWidgets(
    'copy is explicit, preserves translated variants and saves only on request',
    (tester) async {
      final key = GlobalKey<ProtocolMetadataEditorState>();
      var saves = 0;
      var nativeName = 'Native A';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProtocolMetadataEditor(
                key: key,
                initial: cal.CalendarProtocolMetadata(
                  names: [
                    cal.CalendarTextVariant(
                      value: 'Original Swedish',
                      language: 'sv',
                    ),
                  ],
                  descriptions: [],
                ),
                busy: false,
                nativeName: () => nativeName,
                nativeDescription: () => '  Native notes\n',
                onSave: () {
                  saves++;
                },
              ),
            ),
          ),
        ),
      );
      nativeName = 'Native B';
      await tester.pump();
      expect(key.currentState!.value.names.single.value, 'Original Swedish');
      final copy = find.byKey(const Key('protocol-copy-name'));
      await tester.ensureVisible(copy);
      await tester.tap(copy);
      await tester.pump();
      expect(saves, 0);
      expect(key.currentState!.value.names.first.value, 'Native B');
      expect(key.currentState!.value.names.last.value, 'Original Swedish');
      expect(key.currentState!.value.names.last.language, 'sv');
      final descriptionCopy = find.byKey(
        const Key('protocol-copy-description'),
      );
      await tester.ensureVisible(descriptionCopy);
      await tester.tap(descriptionCopy);
      await tester.pump();
      expect(
        key.currentState!.value.descriptions.single.value,
        '  Native notes\n',
      );
      final save = find.byKey(const Key('protocol-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pump();
      expect(saves, 1);
      key.currentState!.reset(
        cal.CalendarProtocolMetadata(names: [], descriptions: []),
      );
      await tester.pump();
      expect(key.currentState!.value.names, isEmpty);
      expect(key.currentState!.value.descriptions, isEmpty);
      expect(key.currentState!.value.color, isNull);
    },
  );
}
