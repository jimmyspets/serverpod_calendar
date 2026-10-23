part of 'icalendar_event_calendar.dart';

/// An unresolved source UID reference, never a native graph edge or grant.
final class IcalendarTaskRelationship {
  IcalendarTaskRelationship._(this.source, this.targetUid, this.relationType);
  final IcalendarSyntaxProperty source;
  final String targetUid;
  final String? relationType;
  String get effectiveRelationType => relationType ?? 'PARENT';
}

/// An inert file reference. The declared media type does not verify contents.
final class IcalendarTaskAttachment {
  IcalendarTaskAttachment._(this.source, this.mediaType);
  final IcalendarSyntaxProperty source;
  String get uri => source.value;
  final String? mediaType;
}

final class IcalendarTaskReferences {
  IcalendarTaskReferences._(
    Iterable<IcalendarTaskRelationship> relationships,
    Iterable<IcalendarTaskAttachment> attachments,
  ) : relationships = List.unmodifiable(relationships),
      attachments = List.unmodifiable(attachments);
  final List<IcalendarTaskRelationship> relationships;
  final List<IcalendarTaskAttachment> attachments;
}

IcalendarTaskReferences _taskReferences(
  IcalendarSyntaxComponent source,
  ComponentBudget budget,
) {
  final relationships = <IcalendarTaskRelationship>[],
      attachments = <IcalendarTaskAttachment>[];
  for (final p in source.entries.whereType<IcalendarSyntaxProperty>()) {
    if (p.canonicalName == 'RELATED-TO') {
      if (relationships.length >= 64) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      final parameters = componentParameters(p, {'RELTYPE'});
      final target = componentText(p, parameters: {'RELTYPE'});
      if (target.isEmpty) componentFail(IcalendarComponentError.invalidValue);
      final type = parameters['RELTYPE'] == null
          ? null
          : componentToken(parameters['RELTYPE']!);
      if (type != null && !{'PARENT', 'CHILD', 'SIBLING'}.contains(type)) {
        componentFail(IcalendarComponentError.unsupportedParameter);
      }
      budget.taskMetadata(
        target.runes.length + (parameters['RELTYPE']?.runes.length ?? 0),
      );
      relationships.add(IcalendarTaskRelationship._(p, target, type));
    } else if (p.canonicalName == 'ATTACH') {
      if (attachments.length >= 64) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      final parameters = componentParameters(p, {'VALUE', 'FMTTYPE'});
      if (parameters['VALUE'] != null &&
          componentToken(parameters['VALUE']!) != 'URI') {
        componentFail(IcalendarComponentError.unsupportedProperty);
      }
      componentUri(p.value);
      if (Uri.parse(p.value).scheme == 'data') {
        componentFail(IcalendarComponentError.unsupportedProperty);
      }
      final media = parameters['FMTTYPE'];
      if (media != null) {
        final match = RegExp(
          r"^[A-Za-z0-9!#$%&'+.^_`|~-]+/[A-Za-z0-9!#$%&'+.^_`|~-]+$",
        ).firstMatch(media);
        if (media.length > 127 || match == null || match.end != media.length) {
          componentFail(IcalendarComponentError.invalidValue);
        }
      }
      budget.taskMetadata(p.value.runes.length + (media?.runes.length ?? 0));
      attachments.add(IcalendarTaskAttachment._(p, media));
    }
  }
  return IcalendarTaskReferences._(relationships, attachments);
}

void _matchingTaskReferences(
  IcalendarTaskReferences master,
  IcalendarTaskReferences override,
) {
  bool sameList<T>(List<T> a, List<T> b, bool Function(T, T) same) =>
      a.isEmpty ||
      (a.length == b.length &&
          List.generate(a.length, (i) => same(a[i], b[i])).every((v) => v));
  if (!sameList(
        override.relationships,
        master.relationships,
        (a, b) =>
            a.targetUid == b.targetUid &&
            a.effectiveRelationType == b.effectiveRelationType,
      ) ||
      !sameList(
        override.attachments,
        master.attachments,
        (a, b) =>
            a.uri == b.uri &&
            a.mediaType?.toLowerCase() == b.mediaType?.toLowerCase(),
      )) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
}

IcalendarTaskReferences _inheritedTaskReferences(
  IcalendarTaskReferences master,
  IcalendarTaskReferences override,
) => IcalendarTaskReferences._(
  override.relationships.isEmpty
      ? master.relationships
      : override.relationships,
  override.attachments.isEmpty ? master.attachments : override.attachments,
);
