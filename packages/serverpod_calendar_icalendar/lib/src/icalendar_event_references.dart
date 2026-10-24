part of 'icalendar_event_calendar.dart';

/// An unresolved source UID reference, never a native graph edge or grant.
final class IcalendarEventRelationship {
  IcalendarEventRelationship._(this.source, this.targetUid, this.relationType);
  final IcalendarSyntaxProperty source;
  final String targetUid;
  final String? relationType;
  String get effectiveRelationType => relationType ?? 'PARENT';
}

/// An inert file reference. The declared media type does not verify contents.
final class IcalendarEventAttachment {
  IcalendarEventAttachment._(this.source, this.mediaType);
  final IcalendarSyntaxProperty source;
  String get uri => source.value;
  final String? mediaType;
}

final class IcalendarEventReferences {
  IcalendarEventReferences._(
    Iterable<IcalendarEventRelationship> relationships,
    Iterable<IcalendarEventAttachment> attachments,
  ) : relationships = List.unmodifiable(relationships),
      attachments = List.unmodifiable(attachments);
  final List<IcalendarEventRelationship> relationships;
  final List<IcalendarEventAttachment> attachments;
}

IcalendarEventReferences _eventReferences(
  IcalendarSyntaxComponent source,
  ComponentBudget budget,
) {
  final relationships = <IcalendarEventRelationship>[],
      attachments = <IcalendarEventAttachment>[];
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
      budget.eventMetadata(
        target.runes.length + (parameters['RELTYPE']?.runes.length ?? 0),
      );
      relationships.add(IcalendarEventRelationship._(p, target, type));
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
      budget.eventMetadata(p.value.runes.length + (media?.runes.length ?? 0));
      attachments.add(IcalendarEventAttachment._(p, media));
    }
  }
  return IcalendarEventReferences._(relationships, attachments);
}

void _matchingEventReferences(
  IcalendarEventReferences master,
  IcalendarEventReferences override,
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

IcalendarEventReferences _inheritedEventReferences(
  IcalendarEventReferences master,
  IcalendarEventReferences override,
) => IcalendarEventReferences._(
  override.relationships.isEmpty
      ? master.relationships
      : override.relationships,
  override.attachments.isEmpty ? master.attachments : override.attachments,
);

/// Decode only bounded reference properties; never resolve or fetch targets.
IcalendarEventReferences decodeIcalendarEventReferences(
  List<IcalendarSyntaxProperty> source,
) => componentGuard(() {
  if (source.any((p) => !{'RELATED-TO', 'ATTACH'}.contains(p.canonicalName))) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
  return _eventReferences(
    IcalendarSyntaxComponent('VEVENT', source),
    ComponentBudget(const IcalendarComponentLimits()),
  );
});
