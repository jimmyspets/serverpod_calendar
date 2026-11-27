/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_calendar_client/src/protocol/calendar_field_group.dart'
    as _ioi1smgh;
import 'package:serverpod_calendar_client/src/protocol/calendar_subject_view.dart'
    as _iad1u4rm;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_notifications_client/serverpod_notifications_client.dart'
    as _i9wvmat7;
import 'calendar_create_request.dart' as _i8chn2wc;
import 'calendar_exception.dart' as _ioicq9ju;
import 'calendar_failure_code.dart' as _i7h2f30k;
import 'calendar_field_group.dart' as _i73hgz1s;
import 'calendar_metadata_update_request.dart' as _i759fw3a;
import 'calendar_mutation_receipt.dart' as _iq0eskk0;
import 'calendar_no_rule_fallback.dart' as _itts4qyp;
import 'calendar_page.dart' as _i0jfcg0j;
import 'calendar_presentation_update_request.dart' as _i9m9yk5s;
import 'calendar_protocol_metadata.dart' as _itchuj1l;
import 'calendar_protocol_metadata_update_request.dart' as _iyawor89;
import 'calendar_settings_update_request.dart' as _i66us6t1;
import 'calendar_subject_action.dart' as _i41idnki;
import 'calendar_subject_change_request.dart' as _iuzjb8ji;
import 'calendar_subject_view.dart' as _ir7mv910;
import 'calendar_text_variant.dart' as _itcy22f3;
import 'calendar_view.dart' as _ivspd2q7;
export 'calendar_create_request.dart';
export 'calendar_exception.dart';
export 'calendar_failure_code.dart';
export 'calendar_field_group.dart';
export 'calendar_metadata_update_request.dart';
export 'calendar_mutation_receipt.dart';
export 'calendar_no_rule_fallback.dart';
export 'calendar_page.dart';
export 'calendar_presentation_update_request.dart';
export 'calendar_protocol_metadata.dart';
export 'calendar_protocol_metadata_update_request.dart';
export 'calendar_settings_update_request.dart';
export 'calendar_subject_action.dart';
export 'calendar_subject_change_request.dart';
export 'calendar_subject_view.dart';
export 'calendar_text_variant.dart';
export 'calendar_view.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_isc.SerializationManager> _hostProtocols = {};

  void registerHostProtocol(
    String projectName,
    _isc.SerializationManager protocol,
  ) {
    _hostProtocols.add(protocol);
  }

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('serverpod_calendar.')) return className;
    return className.substring(19);
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i8chn2wc.CalendarCreateRequest) {
      return _i8chn2wc.CalendarCreateRequest.fromJson(data) as T;
    }
    if (t == _ioicq9ju.CalendarException) {
      return _ioicq9ju.CalendarException.fromJson(data) as T;
    }
    if (t == _i7h2f30k.CalendarFailureCode) {
      return _i7h2f30k.CalendarFailureCode.fromJson(data) as T;
    }
    if (t == _i73hgz1s.CalendarFieldGroup) {
      return _i73hgz1s.CalendarFieldGroup.fromJson(data) as T;
    }
    if (t == _i759fw3a.CalendarMetadataUpdateRequest) {
      return _i759fw3a.CalendarMetadataUpdateRequest.fromJson(data) as T;
    }
    if (t == _iq0eskk0.CalendarMutationReceipt) {
      return _iq0eskk0.CalendarMutationReceipt.fromJson(data) as T;
    }
    if (t == _itts4qyp.CalendarNoRuleFallback) {
      return _itts4qyp.CalendarNoRuleFallback.fromJson(data) as T;
    }
    if (t == _i0jfcg0j.CalendarPage) {
      return _i0jfcg0j.CalendarPage.fromJson(data) as T;
    }
    if (t == _i9m9yk5s.CalendarPresentationUpdateRequest) {
      return _i9m9yk5s.CalendarPresentationUpdateRequest.fromJson(data) as T;
    }
    if (t == _itchuj1l.CalendarProtocolMetadata) {
      return _itchuj1l.CalendarProtocolMetadata.fromJson(data) as T;
    }
    if (t == _iyawor89.CalendarProtocolMetadataUpdateRequest) {
      return _iyawor89.CalendarProtocolMetadataUpdateRequest.fromJson(data)
          as T;
    }
    if (t == _i66us6t1.CalendarSettingsUpdateRequest) {
      return _i66us6t1.CalendarSettingsUpdateRequest.fromJson(data) as T;
    }
    if (t == _i41idnki.CalendarSubjectAction) {
      return _i41idnki.CalendarSubjectAction.fromJson(data) as T;
    }
    if (t == _iuzjb8ji.CalendarSubjectChangeRequest) {
      return _iuzjb8ji.CalendarSubjectChangeRequest.fromJson(data) as T;
    }
    if (t == _ir7mv910.CalendarSubjectView) {
      return _ir7mv910.CalendarSubjectView.fromJson(data) as T;
    }
    if (t == _itcy22f3.CalendarTextVariant) {
      return _itcy22f3.CalendarTextVariant.fromJson(data) as T;
    }
    if (t == _ivspd2q7.CalendarView) {
      return _ivspd2q7.CalendarView.fromJson(data) as T;
    }
    if (t == _isc.getType<_i8chn2wc.CalendarCreateRequest?>()) {
      return (data != null
              ? _i8chn2wc.CalendarCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ioicq9ju.CalendarException?>()) {
      return (data != null ? _ioicq9ju.CalendarException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7h2f30k.CalendarFailureCode?>()) {
      return (data != null
              ? _i7h2f30k.CalendarFailureCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i73hgz1s.CalendarFieldGroup?>()) {
      return (data != null ? _i73hgz1s.CalendarFieldGroup.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i759fw3a.CalendarMetadataUpdateRequest?>()) {
      return (data != null
              ? _i759fw3a.CalendarMetadataUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iq0eskk0.CalendarMutationReceipt?>()) {
      return (data != null
              ? _iq0eskk0.CalendarMutationReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_itts4qyp.CalendarNoRuleFallback?>()) {
      return (data != null
              ? _itts4qyp.CalendarNoRuleFallback.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i0jfcg0j.CalendarPage?>()) {
      return (data != null ? _i0jfcg0j.CalendarPage.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i9m9yk5s.CalendarPresentationUpdateRequest?>()) {
      return (data != null
              ? _i9m9yk5s.CalendarPresentationUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_itchuj1l.CalendarProtocolMetadata?>()) {
      return (data != null
              ? _itchuj1l.CalendarProtocolMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iyawor89.CalendarProtocolMetadataUpdateRequest?>()) {
      return (data != null
              ? _iyawor89.CalendarProtocolMetadataUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i66us6t1.CalendarSettingsUpdateRequest?>()) {
      return (data != null
              ? _i66us6t1.CalendarSettingsUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i41idnki.CalendarSubjectAction?>()) {
      return (data != null
              ? _i41idnki.CalendarSubjectAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iuzjb8ji.CalendarSubjectChangeRequest?>()) {
      return (data != null
              ? _iuzjb8ji.CalendarSubjectChangeRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ir7mv910.CalendarSubjectView?>()) {
      return (data != null
              ? _ir7mv910.CalendarSubjectView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_itcy22f3.CalendarTextVariant?>()) {
      return (data != null
              ? _itcy22f3.CalendarTextVariant.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ivspd2q7.CalendarView?>()) {
      return (data != null ? _ivspd2q7.CalendarView.fromJson(data) : null) as T;
    }
    if (t == List<_ivspd2q7.CalendarView>) {
      return (data as List)
              .map((e) => deserialize<_ivspd2q7.CalendarView>(e))
              .toList()
          as T;
    }
    if (t == List<_itcy22f3.CalendarTextVariant>) {
      return (data as List)
              .map((e) => deserialize<_itcy22f3.CalendarTextVariant>(e))
              .toList()
          as T;
    }
    if (t == List<_i73hgz1s.CalendarFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_i73hgz1s.CalendarFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_ioi1smgh.CalendarFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_ioi1smgh.CalendarFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_iad1u4rm.CalendarSubjectView>) {
      return (data as List)
              .map((e) => deserialize<_iad1u4rm.CalendarSubjectView>(e))
              .toList()
          as T;
    }
    try {
      return _i9wvmat7.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i8chn2wc.CalendarCreateRequest => 'CalendarCreateRequest',
      _ioicq9ju.CalendarException => 'CalendarException',
      _i7h2f30k.CalendarFailureCode => 'CalendarFailureCode',
      _i73hgz1s.CalendarFieldGroup => 'CalendarFieldGroup',
      _i759fw3a.CalendarMetadataUpdateRequest =>
        'CalendarMetadataUpdateRequest',
      _iq0eskk0.CalendarMutationReceipt => 'CalendarMutationReceipt',
      _itts4qyp.CalendarNoRuleFallback => 'CalendarNoRuleFallback',
      _i0jfcg0j.CalendarPage => 'CalendarPage',
      _i9m9yk5s.CalendarPresentationUpdateRequest =>
        'CalendarPresentationUpdateRequest',
      _itchuj1l.CalendarProtocolMetadata => 'CalendarProtocolMetadata',
      _iyawor89.CalendarProtocolMetadataUpdateRequest =>
        'CalendarProtocolMetadataUpdateRequest',
      _i66us6t1.CalendarSettingsUpdateRequest =>
        'CalendarSettingsUpdateRequest',
      _i41idnki.CalendarSubjectAction => 'CalendarSubjectAction',
      _iuzjb8ji.CalendarSubjectChangeRequest => 'CalendarSubjectChangeRequest',
      _ir7mv910.CalendarSubjectView => 'CalendarSubjectView',
      _itcy22f3.CalendarTextVariant => 'CalendarTextVariant',
      _ivspd2q7.CalendarView => 'CalendarView',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_calendar.',
        '',
      );
    }

    switch (data) {
      case _i8chn2wc.CalendarCreateRequest():
        return 'CalendarCreateRequest';
      case _ioicq9ju.CalendarException():
        return 'CalendarException';
      case _i7h2f30k.CalendarFailureCode():
        return 'CalendarFailureCode';
      case _i73hgz1s.CalendarFieldGroup():
        return 'CalendarFieldGroup';
      case _i759fw3a.CalendarMetadataUpdateRequest():
        return 'CalendarMetadataUpdateRequest';
      case _iq0eskk0.CalendarMutationReceipt():
        return 'CalendarMutationReceipt';
      case _itts4qyp.CalendarNoRuleFallback():
        return 'CalendarNoRuleFallback';
      case _i0jfcg0j.CalendarPage():
        return 'CalendarPage';
      case _i9m9yk5s.CalendarPresentationUpdateRequest():
        return 'CalendarPresentationUpdateRequest';
      case _itchuj1l.CalendarProtocolMetadata():
        return 'CalendarProtocolMetadata';
      case _iyawor89.CalendarProtocolMetadataUpdateRequest():
        return 'CalendarProtocolMetadataUpdateRequest';
      case _i66us6t1.CalendarSettingsUpdateRequest():
        return 'CalendarSettingsUpdateRequest';
      case _i41idnki.CalendarSubjectAction():
        return 'CalendarSubjectAction';
      case _iuzjb8ji.CalendarSubjectChangeRequest():
        return 'CalendarSubjectChangeRequest';
      case _ir7mv910.CalendarSubjectView():
        return 'CalendarSubjectView';
      case _itcy22f3.CalendarTextVariant():
        return 'CalendarTextVariant';
      case _ivspd2q7.CalendarView():
        return 'CalendarView';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CalendarCreateRequest') {
      return deserialize<_i8chn2wc.CalendarCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarException') {
      return deserialize<_ioicq9ju.CalendarException>(data['data']);
    }
    if (dataClassName == 'CalendarFailureCode') {
      return deserialize<_i7h2f30k.CalendarFailureCode>(data['data']);
    }
    if (dataClassName == 'CalendarFieldGroup') {
      return deserialize<_i73hgz1s.CalendarFieldGroup>(data['data']);
    }
    if (dataClassName == 'CalendarMetadataUpdateRequest') {
      return deserialize<_i759fw3a.CalendarMetadataUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarMutationReceipt') {
      return deserialize<_iq0eskk0.CalendarMutationReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarNoRuleFallback') {
      return deserialize<_itts4qyp.CalendarNoRuleFallback>(data['data']);
    }
    if (dataClassName == 'CalendarPage') {
      return deserialize<_i0jfcg0j.CalendarPage>(data['data']);
    }
    if (dataClassName == 'CalendarPresentationUpdateRequest') {
      return deserialize<_i9m9yk5s.CalendarPresentationUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarProtocolMetadata') {
      return deserialize<_itchuj1l.CalendarProtocolMetadata>(data['data']);
    }
    if (dataClassName == 'CalendarProtocolMetadataUpdateRequest') {
      return deserialize<_iyawor89.CalendarProtocolMetadataUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSettingsUpdateRequest') {
      return deserialize<_i66us6t1.CalendarSettingsUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectAction') {
      return deserialize<_i41idnki.CalendarSubjectAction>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectChangeRequest') {
      return deserialize<_iuzjb8ji.CalendarSubjectChangeRequest>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectView') {
      return deserialize<_ir7mv910.CalendarSubjectView>(data['data']);
    }
    if (dataClassName == 'CalendarTextVariant') {
      return deserialize<_itcy22f3.CalendarTextVariant>(data['data']);
    }
    if (dataClassName == 'CalendarView') {
      return deserialize<_ivspd2q7.CalendarView>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  Object? dynamicFieldToJson(
    Object? object, {
    bool forProtocol = false,
  }) {
    if ((object is List || object is Set || object is Map) ||
        getClassNameForObject(object) != null) {
      return super.dynamicFieldToJson(object, forProtocol: forProtocol);
    }
    for (final protocol in _hostProtocols) {
      final className = protocol.getClassNameForObject(object);
      if (className == null) continue;
      final host = protocol.getModuleName();
      final wrapped = {
        'className': className.contains('.') ? className : '$host.$className',
        'data': object,
      };
      return forProtocol
          ? _isc.SerializationManager.toEncodableForProtocol(wrapped)
          : _isc.SerializationManager.toEncodable(wrapped);
    }
    return super.dynamicFieldToJson(object, forProtocol: forProtocol);
  }

  @override
  dynamic deserializeDynamicFieldValue(Object? value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> || value['className'] is! String) {
      throw FormatException(
        'Dynamic fields are encoded as a Map with className and data, but got '
        '${value.runtimeType} instead.',
      );
    }
    final className = value['className'] as String;
    for (final protocol in _hostProtocols) {
      final host = protocol.getModuleName();
      final hostPrefix = '$host.';
      if (className.startsWith(hostPrefix)) {
        final strippedClassName = className.substring(hostPrefix.length);
        if (strippedClassName.contains('.')) {
          throw FormatException(
            'Dynamic field className must not use multiple prefixes: $className',
          );
        }
        final hostData = Map<String, dynamic>.from(value);
        hostData['className'] = strippedClassName;
        return protocol.deserializeByClassName(hostData);
      }
    }
    if (className.contains('.')) {
      for (final protocol in _hostProtocols) {
        try {
          return protocol.deserializeByClassName(value);
        } on _isc.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  String getModuleName() => 'serverpod_calendar';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i9wvmat7.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
