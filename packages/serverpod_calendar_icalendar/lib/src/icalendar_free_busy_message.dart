part of 'icalendar_event_calendar.dart';

enum IcalendarFreeBusyMethod { publish, request, reply }

/// Untrusted scheduling data; never an authorized availability partition.
final class IcalendarFreeBusyMessage {
  IcalendarFreeBusyMessage._(
    this.source,
    this.productId,
    this.method,
    Iterable<IcalendarFreeBusyComponent> components,
  ) : components = List.unmodifiable(components);
  final IcalendarSyntaxDocument source;
  final String productId;
  final IcalendarFreeBusyMethod method;
  final List<IcalendarFreeBusyComponent> components;
}

final class IcalendarFreeBusyComponent {
  IcalendarFreeBusyComponent._({
    required this.source,
    required this.uid,
    required this.stamp,
    required this.window,
    required this.organizer,
    required this.metadata,
    required Iterable<String> attendees,
    required Iterable<IcalendarFreeBusyGroup> groups,
    required Iterable<IcalendarSchedulingRequestStatus> requestStatuses,
  }) : attendees = List.unmodifiable(attendees),
       groups = List.unmodifiable(groups),
       requestStatuses = List.unmodifiable(requestStatuses);
  final IcalendarSyntaxComponent source;
  final String uid;
  final DateTime stamp;
  final UtcWindow window;
  final IcalendarEventOrganizer organizer;
  final IcalendarEventMetadata metadata;
  final List<String> attendees;
  final List<IcalendarFreeBusyGroup> groups;
  final List<IcalendarSchedulingRequestStatus> requestStatuses;
}

/// Source grouping/order and nominal duration form remain intact.
final class IcalendarFreeBusyGroup {
  IcalendarFreeBusyGroup._(
    this.source,
    this.type,
    Iterable<TimedEventSpan> periods,
  ) : periods = List.unmodifiable(periods);
  final IcalendarSyntaxProperty source;
  final String? type;
  final List<TimedEventSpan> periods;

  /// RFC 5545's source classification, not evidence of authorized coverage.
  String get effectiveType =>
      const {
        'FREE',
        'BUSY',
        'BUSY-TENTATIVE',
        'BUSY-UNAVAILABLE',
      }.contains(type?.toUpperCase())
      ? type!.toUpperCase()
      : 'BUSY';
}

IcalendarFreeBusyMessage parseIcalendarFreeBusyMessage(
  List<int> bytes, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
  int maxComponents = 32,
  int maxPeriods = 1000,
}) => validateIcalendarFreeBusyMessage(
  parseIcalendarSyntax(bytes, limits: syntaxLimits),
  syntaxLimits: syntaxLimits,
  limits: limits,
  maxComponents: maxComponents,
  maxPeriods: maxPeriods,
);

/// Structural validation only: no lookup, correlation, query or automatic reply.
IcalendarFreeBusyMessage validateIcalendarFreeBusyMessage(
  IcalendarSyntaxDocument source, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
  int maxComponents = 32,
  int maxPeriods = 1000,
}) {
  limits.validate();
  RangeError.checkValueInInterval(maxComponents, 1, 1024, 'maxComponents');
  RangeError.checkValueInInterval(maxPeriods, 1, 100000, 'maxPeriods');
  serializeIcalendarSyntax(source, limits: syntaxLimits);
  return componentGuard(() {
    if (source.components.length != 1 ||
        source.components.single.canonicalName != 'VCALENDAR') {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    final calendar = source.components.single;
    final envelope = componentProperties(calendar, {
      'VERSION',
      'PRODID',
      'METHOD',
      'CALSCALE',
    });
    final version = requiredProperty(envelope, 'VERSION');
    componentParameters(version, {});
    if (version.value != '2.0') {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final producer = componentText(requiredProperty(envelope, 'PRODID'));
    if (producer.isEmpty) componentFail(IcalendarComponentError.invalidValue);
    final scale = envelope['CALSCALE']?.single;
    if (scale != null) {
      componentParameters(scale, {});
      if (componentToken(scale.value) != 'GREGORIAN') {
        componentFail(IcalendarComponentError.invalidValue);
      }
    }
    final methodProperty = requiredProperty(envelope, 'METHOD');
    componentParameters(methodProperty, {});
    final method = switch (componentToken(methodProperty.value)) {
      'PUBLISH' => IcalendarFreeBusyMethod.publish,
      'REQUEST' => IcalendarFreeBusyMethod.request,
      'REPLY' => IcalendarFreeBusyMethod.reply,
      _ => componentFail(IcalendarComponentError.unsupportedProperty),
    };
    final budget = ComponentBudget(limits);
    final result = <IcalendarFreeBusyComponent>[];
    var periods = 0;
    for (final component
        in calendar.entries.whereType<IcalendarSyntaxComponent>()) {
      if (component.canonicalName != 'VFREEBUSY' ||
          component.entries.any((e) => e is IcalendarSyntaxComponent)) {
        componentFail(IcalendarComponentError.unsupportedComponent);
      }
      if (result.length >= maxComponents ||
          method != IcalendarFreeBusyMethod.publish && result.isNotEmpty) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      final p = componentProperties(
        component,
        {
          'UID',
          'DTSTAMP',
          'DTSTART',
          'DTEND',
          'ORGANIZER',
          'COMMENT',
          'CONTACT',
          if (method != IcalendarFreeBusyMethod.publish) 'ATTENDEE',
          if (method != IcalendarFreeBusyMethod.request) ...['FREEBUSY', 'URL'],
          if (method == IcalendarFreeBusyMethod.reply) 'REQUEST-STATUS',
        },
        repeated: {'COMMENT', 'ATTENDEE', 'FREEBUSY', 'REQUEST-STATUS'},
      );
      final uid = componentText(requiredProperty(p, 'UID'));
      if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
      budget.eventMetadata(uid.runes.length);
      final stamp = componentUtc(requiredProperty(p, 'DTSTAMP'));
      TimedValue utc(IcalendarSyntaxProperty property, {bool end = false}) {
        componentParameters(property, {});
        if (!property.value.endsWith('Z')) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        return parseIcalendarDateTime(property.value, exclusiveEnd: end);
      }

      final start = utc(requiredProperty(p, 'DTSTART'));
      final end = utc(requiredProperty(p, 'DTEND'), end: true);
      final window = UtcWindow(start: start.instant, end: end.instant);
      final organizer = _eventParticipants(
        IcalendarSyntaxComponent('VEVENT', [requiredProperty(p, 'ORGANIZER')]),
        budget,
        isOverride: false,
      ).organizer!;
      final attendees = <String>[];
      for (final attendee in p['ATTENDEE'] ?? <IcalendarSyntaxProperty>[]) {
        if (attendees.length >= 64) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        // RFC 5545 3.8.4.1 forbids event attendee parameters in VFREEBUSY.
        componentParameters(attendee, {});
        componentUri(attendee.value);
        if (attendee.value.length > 1024) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        budget.eventMetadata(attendee.value.runes.length);
        attendees.add(attendee.value);
      }
      if (method == IcalendarFreeBusyMethod.request && attendees.isEmpty ||
          method == IcalendarFreeBusyMethod.reply && attendees.length != 1) {
        componentFail(IcalendarComponentError.missing);
      }
      final groups = <IcalendarFreeBusyGroup>[];
      for (final property in p['FREEBUSY'] ?? <IcalendarSyntaxProperty>[]) {
        final parameters = componentParameters(property, {'FBTYPE'});
        final type = parameters['FBTYPE'];
        if (type != null) {
          if (type.isEmpty ||
              type.length > 64 ||
              RegExp(r'[^A-Za-z0-9-]').hasMatch(type)) {
            componentFail(IcalendarComponentError.invalidValue);
          }
          budget.eventMetadata(type.runes.length);
        }
        final spans = <TimedEventSpan>[];
        for (final raw in property.value.split(',')) {
          if (++periods > maxPeriods) {
            componentFail(IcalendarComponentError.limitExceeded);
          }
          budget.explicitDate();
          budget.candidate();
          final fields = raw.split('/');
          if (fields.length != 2) {
            componentFail(IcalendarComponentError.invalidValue);
          }
          final from = utc(IcalendarSyntaxProperty('DTSTART', fields[0]));
          final to = fields[1];
          final isDuration =
              to.startsWith('P') || to.startsWith('+P') || to.startsWith('-P');
          spans.add(
            TimedEventSpan(
              start: from,
              end: isDuration
                  ? null
                  : utc(IcalendarSyntaxProperty('DTEND', to), end: true),
              duration: isDuration ? parseIcalendarDuration(to) : null,
            ),
          );
        }
        groups.add(IcalendarFreeBusyGroup._(property, type, spans));
      }
      result.add(
        IcalendarFreeBusyComponent._(
          source: component,
          uid: uid,
          stamp: stamp,
          window: window,
          organizer: organizer,
          attendees: attendees,
          groups: groups,
          metadata: _eventMetadata(component, budget),
          requestStatuses: _schedulingRequestStatuses(
            p['REQUEST-STATUS'] ?? [],
            budget,
          ),
        ),
      );
    }
    if (result.isEmpty) componentFail(IcalendarComponentError.missing);
    return IcalendarFreeBusyMessage._(source, producer, method, result);
  });
}

/// Re-emits source claims; never generates an authorized free/busy response.
Uint8List serializeIcalendarFreeBusyMessage(
  IcalendarFreeBusyMessage value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
}) => serializeIcalendarSyntax(value.source, limits: syntaxLimits);
