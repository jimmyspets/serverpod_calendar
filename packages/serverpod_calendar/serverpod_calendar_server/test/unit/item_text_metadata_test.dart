@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/item_text_metadata_values.dart';
import 'package:serverpod_calendar_server/src/task_source_values.dart';

void main() {
  test('native comment patches reject source-incompatible ALTREP without data loss', () {
    for (final uri in [
      'https://user:pass@example.invalid/',
      'https://example.invalid/%oops',
    ]) {
      expect(
        () => validateItemTextPatch(
          CalendarItemTextMetadataPatch(
            selectedFields: [CalendarItemTextMetadataField.comments],
            comments: [
              CalendarItemComment(
                value: 'Note',
                parameters: CalendarTextParameters(alternativeUri: uri),
              ),
            ],
          ),
        ),
        throwsArgumentError,
      );
    }
  });
  test('selected patch rejects contradictory fields and preserves immutable Unicode groups', () {
    final values = ['  Å 🧰  ', 'Same', 'Same'];
    final input = CalendarItemTextMetadataPatch(
      selectedFields: [CalendarItemTextMetadataField.categories],
      categoryGroups: [
        CalendarItemCategoryGroup(values: values, language: 'SV'),
      ],
    );
    final p = validateItemTextPatch(input);
    values.clear();
    expect(p.categoryGroups!.single.values, ['  Å 🧰  ', 'Same', 'Same']);
    expect(() => p.selectedFields.clear(), throwsUnsupportedError);
    expect(
      () => p.categoryGroups!.single.values.clear(),
      throwsUnsupportedError,
    );
    for (final bad in [
      CalendarItemTextMetadataPatch(selectedFields: []),
      CalendarItemTextMetadataPatch(
        selectedFields: [
          CalendarItemTextMetadataField.url,
          CalendarItemTextMetadataField.url,
        ],
      ),
      CalendarItemTextMetadataPatch(
        selectedFields: [CalendarItemTextMetadataField.comments],
      ),
      CalendarItemTextMetadataPatch(
        selectedFields: [CalendarItemTextMetadataField.url],
        comments: [],
      ),
      CalendarItemTextMetadataPatch(
        selectedFields: [CalendarItemTextMetadataField.url],
        url: 'https://user:pass@example.invalid/',
      ),
    ]) {
      expect(() => validateItemTextPatch(bad), throwsArgumentError);
    }
  });
  test('patch applies only selected metadata and preserves private source', () {
    final old = CalendarEventSourceMetadata(
      url: 'https://example.invalid/old',
      classification: 'PRIVATE',
      categoryGroups: [],
      comments: [],
      contacts: [CalendarEventSourceText(value: 'SECRET')],
    );
    final next = applyEventTextPatch(
      old,
      validateItemTextPatch(
        CalendarItemTextMetadataPatch(
          selectedFields: [CalendarItemTextMetadataField.comments],
          comments: [
            CalendarItemComment(
              value: '\n',
              parameters: CalendarTextParameters(
                language: 'sv',
                alternativeUri: 'cid:note@example.invalid',
              ),
            ),
          ],
        ),
      ),
    );
    expect(next!.url, old.url);
    expect(next.classification, 'PRIVATE');
    expect(next.contacts.single.value, 'SECRET');
    expect(next.comments.single.value, '\n');
  });
  test(
    'bounds and unsupported label annotations reject without truncating',
    () {
      for (final p in [
        CalendarItemTextMetadataPatch(
          selectedFields: [CalendarItemTextMetadataField.categories],
          categoryGroups: [
            CalendarItemCategoryGroup(values: [' ']),
          ],
        ),
        CalendarItemTextMetadataPatch(
          selectedFields: [CalendarItemTextMetadataField.categories],
          categoryGroups: [
            CalendarItemCategoryGroup(values: ['x' * 257]),
          ],
        ),
        CalendarItemTextMetadataPatch(
          selectedFields: [CalendarItemTextMetadataField.comments],
          comments: List.filled(33, CalendarItemComment(value: '')),
        ),
        CalendarItemTextMetadataPatch(
          selectedFields: [CalendarItemTextMetadataField.classification],
          classification: 'X-CUSTOM',
        ),
      ]) {
        expect(() => validateItemTextPatch(p), throwsA(anything));
      }
    },
  );
  test('derived changes protect matching occurrence presence independently of the master', () {
    final empty = eventTextMetadata(null),
        explicit = eventTextMetadata(
          CalendarEventSourceMetadata(
            url: 'https://example.invalid/',
            categoryGroups: [],
            comments: [],
            contacts: [],
          ),
        );
    final patch = itemTextChanges(
      {'master': explicit, 'single': empty},
      {'master': explicit, 'single': explicit},
    )!;
    expect(patch.selectedFields, [CalendarItemTextMetadataField.url]);
    expect(
      itemTextChanges(
        {'master': explicit, 'single': explicit},
        {'single': explicit, 'master': explicit},
      ),
      isNull,
    );
  });
  test('native metadata flag validates only explicit native state and never accepts source claims', () {
    final state = CalendarTaskSourceState(
      nativeMetadataOnly: true,
      master: CalendarTaskSourceComponent(
        version: CalendarTaskProtocolVersion(stamp: DateTime.utc(2026)),
        content: CalendarTaskContent(
          timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
        ),
        progress: CalendarTaskProgress(),
        metadata: emptyTaskSourceMetadata(),
      ),
      occurrences: [],
    );
    expect(
      validateTaskSourceState('synthetic', state).nativeMetadataOnly,
      isTrue,
    );
    expect(
      () => validateTaskSourceState(
        'synthetic',
        state.copyWith(nativeMetadataOnly: false),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateTaskSourceState(
        'synthetic',
        state.copyWith(
          master: state.master.copyWith(
            metadata: state.master.metadata.copyWith(
              contacts: [CalendarTaskSourceText(value: 'PRIVATE')],
            ),
          ),
        ),
      ),
      throwsArgumentError,
    );
  });
}
