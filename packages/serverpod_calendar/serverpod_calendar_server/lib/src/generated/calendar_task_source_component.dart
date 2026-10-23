/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;
import 'calendar_event_text_parameters.dart' as _isfojy12;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_content.dart' as _if7nbvl8;
import 'calendar_task_progress.dart' as _ikcsq95s;
import 'calendar_task_protocol_version.dart' as _iz9t6x1i;
import 'calendar_task_source_metadata.dart' as _i76q6myt;

@_is.immutable
abstract class CalendarTaskSourceComponent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceComponent._({
    this.originalStart,
    required this.version,
    required this.content,
    required this.progress,
    this.textParameters,
    required this.metadata,
  });

  const factory CalendarTaskSourceComponent({
    _ieswiaty.CalendarEventTiming? originalStart,
    required _iz9t6x1i.CalendarTaskProtocolVersion version,
    required _if7nbvl8.CalendarTaskContent content,
    required _ikcsq95s.CalendarTaskProgress progress,
    _isfojy12.CalendarEventTextParameters? textParameters,
    required _i76q6myt.CalendarTaskSourceMetadata metadata,
  }) = _CalendarTaskSourceComponentImpl;

  factory CalendarTaskSourceComponent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceComponent(
      originalStart: jsonSerialization['originalStart'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['originalStart'],
            ),
      version: _ix00hwbf.Protocol()
          .deserialize<_iz9t6x1i.CalendarTaskProtocolVersion>(
            jsonSerialization['version'],
          ),
      content: _ix00hwbf.Protocol().deserialize<_if7nbvl8.CalendarTaskContent>(
        jsonSerialization['content'],
      ),
      progress: _ix00hwbf.Protocol()
          .deserialize<_ikcsq95s.CalendarTaskProgress>(
            jsonSerialization['progress'],
          ),
      textParameters: jsonSerialization['textParameters'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_isfojy12.CalendarEventTextParameters>(
                  jsonSerialization['textParameters'],
                ),
      metadata: _ix00hwbf.Protocol()
          .deserialize<_i76q6myt.CalendarTaskSourceMetadata>(
            jsonSerialization['metadata'],
          ),
    );
  }

  final _ieswiaty.CalendarEventTiming? originalStart;

  final _iz9t6x1i.CalendarTaskProtocolVersion version;

  final _if7nbvl8.CalendarTaskContent content;

  final _ikcsq95s.CalendarTaskProgress progress;

  final _isfojy12.CalendarEventTextParameters? textParameters;

  final _i76q6myt.CalendarTaskSourceMetadata metadata;

  /// Returns a shallow copy of this [CalendarTaskSourceComponent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceComponent copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _iz9t6x1i.CalendarTaskProtocolVersion? version,
    _if7nbvl8.CalendarTaskContent? content,
    _ikcsq95s.CalendarTaskProgress? progress,
    _isfojy12.CalendarEventTextParameters? textParameters,
    _i76q6myt.CalendarTaskSourceMetadata? metadata,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskSourceComponent &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.version,
                  version,
                ) ||
                other.version == version) &&
            (identical(
                  other.content,
                  content,
                ) ||
                other.content == content) &&
            (identical(
                  other.progress,
                  progress,
                ) ||
                other.progress == progress) &&
            (identical(
                  other.textParameters,
                  textParameters,
                ) ||
                other.textParameters == textParameters) &&
            (identical(
                  other.metadata,
                  metadata,
                ) ||
                other.metadata == metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      version,
      content,
      progress,
      textParameters,
      metadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceComponent',
      if (originalStart != null) 'originalStart': originalStart?.toJson(),
      'version': version.toJson(),
      'content': content.toJson(),
      'progress': progress.toJson(),
      if (textParameters != null) 'textParameters': textParameters?.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskSourceComponentImpl extends CalendarTaskSourceComponent {
  const _CalendarTaskSourceComponentImpl({
    _ieswiaty.CalendarEventTiming? originalStart,
    required _iz9t6x1i.CalendarTaskProtocolVersion version,
    required _if7nbvl8.CalendarTaskContent content,
    required _ikcsq95s.CalendarTaskProgress progress,
    _isfojy12.CalendarEventTextParameters? textParameters,
    required _i76q6myt.CalendarTaskSourceMetadata metadata,
  }) : super._(
         originalStart: originalStart,
         version: version,
         content: content,
         progress: progress,
         textParameters: textParameters,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceComponent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceComponent copyWith({
    Object? originalStart = _Undefined,
    _iz9t6x1i.CalendarTaskProtocolVersion? version,
    _if7nbvl8.CalendarTaskContent? content,
    _ikcsq95s.CalendarTaskProgress? progress,
    Object? textParameters = _Undefined,
    _i76q6myt.CalendarTaskSourceMetadata? metadata,
  }) {
    return CalendarTaskSourceComponent(
      originalStart: originalStart is _ieswiaty.CalendarEventTiming?
          ? originalStart
          : this.originalStart?.copyWith(),
      version: version ?? this.version.copyWith(),
      content: content ?? this.content.copyWith(),
      progress: progress ?? this.progress.copyWith(),
      textParameters: textParameters is _isfojy12.CalendarEventTextParameters?
          ? textParameters
          : this.textParameters?.copyWith(),
      metadata: metadata ?? this.metadata.copyWith(),
    );
  }
}
