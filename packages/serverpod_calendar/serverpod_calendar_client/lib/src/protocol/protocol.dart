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
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_view.dart'
    as _imwdhk62;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_field_group.dart'
    as _icxx5h8a;
import 'package:serverpod_calendar_client/src/protocol/calendar_field_group.dart'
    as _ioi1smgh;
import 'package:serverpod_calendar_client/src/protocol/calendar_subject_view.dart'
    as _iad1u4rm;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_notifications_client/serverpod_notifications_client.dart'
    as _i9wvmat7;
import 'calendar_availability_category_group.dart' as _iywbqexh;
import 'calendar_availability_class.dart' as _iucw7bzg;
import 'calendar_availability_content.dart' as _ifxxil5c;
import 'calendar_availability_create_request.dart' as _iwwk2w9d;
import 'calendar_availability_export_request.dart' as _ipddbn84;
import 'calendar_availability_export_selection.dart' as _incs3y0d;
import 'calendar_availability_extension.dart' as _ip5gybl4;
import 'calendar_availability_import_request.dart' as _i6rm14nf;
import 'calendar_availability_import_result.dart' as _iyvmsn4t;
import 'calendar_availability_occurrence_change.dart' as _i7tpo82q;
import 'calendar_availability_occurrence_preview.dart' as _inpm99jj;
import 'calendar_availability_occurrence_query.dart' as _iv6wf0pl;
import 'calendar_availability_opening.dart' as _i8tf9h36;
import 'calendar_availability_opening_edits.dart' as _id5ke9r5;
import 'calendar_availability_opening_protocol_state.dart' as _ix3hb3ib;
import 'calendar_availability_organizer.dart' as _i5oc0nlo;
import 'calendar_availability_override_protocol_state.dart' as _i33h9mr5;
import 'calendar_availability_protocol_state.dart' as _ib9yzivj;
import 'calendar_availability_receipt.dart' as _is1luycx;
import 'calendar_availability_search_mode.dart' as _iam4llos;
import 'calendar_availability_search_query.dart' as _idixoqjq;
import 'calendar_availability_search_view.dart' as _i99fx1rw;
import 'calendar_availability_slot.dart' as _i45h4t8f;
import 'calendar_availability_source_metadata.dart' as _i15w6qdl;
import 'calendar_availability_target.dart' as _iwbqbnec;
import 'calendar_availability_text.dart' as _itw42wa3;
import 'calendar_availability_text_parameters.dart' as _ipbm7ji7;
import 'calendar_availability_update_request.dart' as _igv5u6jv;
import 'calendar_availability_view.dart' as _izmf6fpk;
import 'calendar_category.dart' as _icnza73c;
import 'calendar_category_filter.dart' as _i9j129by;
import 'calendar_create_request.dart' as _i8chn2wc;
import 'calendar_event_by_day.dart' as _iq7751s4;
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_content.dart' as _id4cvk34;
import 'calendar_event_create_request.dart' as _i0orp171;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_event_field_group.dart' as _iftiwkuj;
import 'calendar_event_frequency.dart' as _i2q54gr5;
import 'calendar_event_future_override.dart' as _imbjv41e;
import 'calendar_event_occurrence.dart' as _isyqnyev;
import 'calendar_event_occurrence_action.dart' as _icnciyzp;
import 'calendar_event_occurrence_change.dart' as _i7imxrlz;
import 'calendar_event_occurrence_preview.dart' as _i1a4s0rt;
import 'calendar_event_occurrence_query.dart' as _ivs4ir3j;
import 'calendar_event_page.dart' as _iaayjmj1;
import 'calendar_event_receipt.dart' as _i500bvo7;
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_rule.dart' as _iovyzq1q;
import 'calendar_event_single_override.dart' as _iq1kxi25;
import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_status_request.dart' as _i3kbbl30;
import 'calendar_event_time_kind.dart' as _idbnuf6y;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_event_timing_overrides.dart' as _ijijze99;
import 'calendar_event_transparency.dart' as _iwjkdwy7;
import 'calendar_event_update_request.dart' as _i3ofr0ug;
import 'calendar_event_view.dart' as _iqr733fy;
import 'calendar_exception.dart' as _ioicq9ju;
import 'calendar_failure_code.dart' as _i7h2f30k;
import 'calendar_field_group.dart' as _i73hgz1s;
import 'calendar_free_busy_coverage.dart' as _ia3n9q23;
import 'calendar_free_busy_kind.dart' as _izms466b;
import 'calendar_free_busy_period.dart' as _i82zcrxb;
import 'calendar_free_busy_query.dart' as _idid5g6i;
import 'calendar_free_busy_view.dart' as _i3b615hg;
import 'calendar_image_link.dart' as _igf45b52;
import 'calendar_metadata_update_request.dart' as _i759fw3a;
import 'calendar_mutation_receipt.dart' as _iq0eskk0;
import 'calendar_no_rule_fallback.dart' as _itts4qyp;
import 'calendar_page.dart' as _i0jfcg0j;
import 'calendar_presentation_update_request.dart' as _i9m9yk5s;
import 'calendar_protocol_identity.dart' as _iyrimg3m;
import 'calendar_protocol_metadata.dart' as _itchuj1l;
import 'calendar_protocol_metadata_update_request.dart' as _iyawor89;
import 'calendar_refresh_hint.dart' as _ifsfk5xq;
import 'calendar_settings_update_request.dart' as _i66us6t1;
import 'calendar_subject_action.dart' as _i41idnki;
import 'calendar_subject_availability.dart' as _imo3vsmf;
import 'calendar_subject_change_request.dart' as _iuzjb8ji;
import 'calendar_subject_view.dart' as _ir7mv910;
import 'calendar_supplemental_metadata.dart' as _ixppc388;
import 'calendar_supplemental_metadata_update_request.dart' as _iqx8dg15;
import 'calendar_text_parameters.dart' as _iffxqqc7;
import 'calendar_text_variant.dart' as _itcy22f3;
import 'calendar_view.dart' as _ivspd2q7;
export 'calendar_availability_category_group.dart';
export 'calendar_availability_class.dart';
export 'calendar_availability_content.dart';
export 'calendar_availability_create_request.dart';
export 'calendar_availability_export_request.dart';
export 'calendar_availability_export_selection.dart';
export 'calendar_availability_extension.dart';
export 'calendar_availability_import_request.dart';
export 'calendar_availability_import_result.dart';
export 'calendar_availability_occurrence_change.dart';
export 'calendar_availability_occurrence_preview.dart';
export 'calendar_availability_occurrence_query.dart';
export 'calendar_availability_opening.dart';
export 'calendar_availability_opening_edits.dart';
export 'calendar_availability_opening_protocol_state.dart';
export 'calendar_availability_organizer.dart';
export 'calendar_availability_override_protocol_state.dart';
export 'calendar_availability_protocol_state.dart';
export 'calendar_availability_receipt.dart';
export 'calendar_availability_search_mode.dart';
export 'calendar_availability_search_query.dart';
export 'calendar_availability_search_view.dart';
export 'calendar_availability_slot.dart';
export 'calendar_availability_source_metadata.dart';
export 'calendar_availability_target.dart';
export 'calendar_availability_text.dart';
export 'calendar_availability_text_parameters.dart';
export 'calendar_availability_update_request.dart';
export 'calendar_availability_view.dart';
export 'calendar_category.dart';
export 'calendar_category_filter.dart';
export 'calendar_create_request.dart';
export 'calendar_event_by_day.dart';
export 'calendar_event_civil.dart';
export 'calendar_event_content.dart';
export 'calendar_event_create_request.dart';
export 'calendar_event_duration.dart';
export 'calendar_event_field_group.dart';
export 'calendar_event_frequency.dart';
export 'calendar_event_future_override.dart';
export 'calendar_event_occurrence.dart';
export 'calendar_event_occurrence_action.dart';
export 'calendar_event_occurrence_change.dart';
export 'calendar_event_occurrence_preview.dart';
export 'calendar_event_occurrence_query.dart';
export 'calendar_event_page.dart';
export 'calendar_event_receipt.dart';
export 'calendar_event_recurrence.dart';
export 'calendar_event_rule.dart';
export 'calendar_event_single_override.dart';
export 'calendar_event_status.dart';
export 'calendar_event_status_request.dart';
export 'calendar_event_time_kind.dart';
export 'calendar_event_timing.dart';
export 'calendar_event_timing_overrides.dart';
export 'calendar_event_transparency.dart';
export 'calendar_event_update_request.dart';
export 'calendar_event_view.dart';
export 'calendar_exception.dart';
export 'calendar_failure_code.dart';
export 'calendar_field_group.dart';
export 'calendar_free_busy_coverage.dart';
export 'calendar_free_busy_kind.dart';
export 'calendar_free_busy_period.dart';
export 'calendar_free_busy_query.dart';
export 'calendar_free_busy_view.dart';
export 'calendar_image_link.dart';
export 'calendar_metadata_update_request.dart';
export 'calendar_mutation_receipt.dart';
export 'calendar_no_rule_fallback.dart';
export 'calendar_page.dart';
export 'calendar_presentation_update_request.dart';
export 'calendar_protocol_identity.dart';
export 'calendar_protocol_metadata.dart';
export 'calendar_protocol_metadata_update_request.dart';
export 'calendar_refresh_hint.dart';
export 'calendar_settings_update_request.dart';
export 'calendar_subject_action.dart';
export 'calendar_subject_availability.dart';
export 'calendar_subject_change_request.dart';
export 'calendar_subject_view.dart';
export 'calendar_supplemental_metadata.dart';
export 'calendar_supplemental_metadata_update_request.dart';
export 'calendar_text_parameters.dart';
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

    if (t == _iywbqexh.CalendarAvailabilityCategoryGroup) {
      return _iywbqexh.CalendarAvailabilityCategoryGroup.fromJson(data) as T;
    }
    if (t == _iucw7bzg.CalendarAvailabilityClass) {
      return _iucw7bzg.CalendarAvailabilityClass.fromJson(data) as T;
    }
    if (t == _ifxxil5c.CalendarAvailabilityContent) {
      return _ifxxil5c.CalendarAvailabilityContent.fromJson(data) as T;
    }
    if (t == _iwwk2w9d.CalendarAvailabilityCreateRequest) {
      return _iwwk2w9d.CalendarAvailabilityCreateRequest.fromJson(data) as T;
    }
    if (t == _ipddbn84.CalendarAvailabilityExportRequest) {
      return _ipddbn84.CalendarAvailabilityExportRequest.fromJson(data) as T;
    }
    if (t == _incs3y0d.CalendarAvailabilityExportSelection) {
      return _incs3y0d.CalendarAvailabilityExportSelection.fromJson(data) as T;
    }
    if (t == _ip5gybl4.CalendarAvailabilityExtension) {
      return _ip5gybl4.CalendarAvailabilityExtension.fromJson(data) as T;
    }
    if (t == _i6rm14nf.CalendarAvailabilityImportRequest) {
      return _i6rm14nf.CalendarAvailabilityImportRequest.fromJson(data) as T;
    }
    if (t == _iyvmsn4t.CalendarAvailabilityImportResult) {
      return _iyvmsn4t.CalendarAvailabilityImportResult.fromJson(data) as T;
    }
    if (t == _i7tpo82q.CalendarAvailabilityOccurrenceChange) {
      return _i7tpo82q.CalendarAvailabilityOccurrenceChange.fromJson(data) as T;
    }
    if (t == _inpm99jj.CalendarAvailabilityOccurrencePreview) {
      return _inpm99jj.CalendarAvailabilityOccurrencePreview.fromJson(data)
          as T;
    }
    if (t == _iv6wf0pl.CalendarAvailabilityOccurrenceQuery) {
      return _iv6wf0pl.CalendarAvailabilityOccurrenceQuery.fromJson(data) as T;
    }
    if (t == _i8tf9h36.CalendarAvailabilityOpening) {
      return _i8tf9h36.CalendarAvailabilityOpening.fromJson(data) as T;
    }
    if (t == _id5ke9r5.CalendarAvailabilityOpeningEdits) {
      return _id5ke9r5.CalendarAvailabilityOpeningEdits.fromJson(data) as T;
    }
    if (t == _ix3hb3ib.CalendarAvailabilityOpeningProtocolState) {
      return _ix3hb3ib.CalendarAvailabilityOpeningProtocolState.fromJson(data)
          as T;
    }
    if (t == _i5oc0nlo.CalendarAvailabilityOrganizer) {
      return _i5oc0nlo.CalendarAvailabilityOrganizer.fromJson(data) as T;
    }
    if (t == _i33h9mr5.CalendarAvailabilityOverrideProtocolState) {
      return _i33h9mr5.CalendarAvailabilityOverrideProtocolState.fromJson(data)
          as T;
    }
    if (t == _ib9yzivj.CalendarAvailabilityProtocolState) {
      return _ib9yzivj.CalendarAvailabilityProtocolState.fromJson(data) as T;
    }
    if (t == _is1luycx.CalendarAvailabilityReceipt) {
      return _is1luycx.CalendarAvailabilityReceipt.fromJson(data) as T;
    }
    if (t == _iam4llos.CalendarAvailabilitySearchMode) {
      return _iam4llos.CalendarAvailabilitySearchMode.fromJson(data) as T;
    }
    if (t == _idixoqjq.CalendarAvailabilitySearchQuery) {
      return _idixoqjq.CalendarAvailabilitySearchQuery.fromJson(data) as T;
    }
    if (t == _i99fx1rw.CalendarAvailabilitySearchView) {
      return _i99fx1rw.CalendarAvailabilitySearchView.fromJson(data) as T;
    }
    if (t == _i45h4t8f.CalendarAvailabilitySlot) {
      return _i45h4t8f.CalendarAvailabilitySlot.fromJson(data) as T;
    }
    if (t == _i15w6qdl.CalendarAvailabilitySourceMetadata) {
      return _i15w6qdl.CalendarAvailabilitySourceMetadata.fromJson(data) as T;
    }
    if (t == _iwbqbnec.CalendarAvailabilityTarget) {
      return _iwbqbnec.CalendarAvailabilityTarget.fromJson(data) as T;
    }
    if (t == _itw42wa3.CalendarAvailabilityText) {
      return _itw42wa3.CalendarAvailabilityText.fromJson(data) as T;
    }
    if (t == _ipbm7ji7.CalendarAvailabilityTextParameters) {
      return _ipbm7ji7.CalendarAvailabilityTextParameters.fromJson(data) as T;
    }
    if (t == _igv5u6jv.CalendarAvailabilityUpdateRequest) {
      return _igv5u6jv.CalendarAvailabilityUpdateRequest.fromJson(data) as T;
    }
    if (t == _izmf6fpk.CalendarAvailabilityView) {
      return _izmf6fpk.CalendarAvailabilityView.fromJson(data) as T;
    }
    if (t == _icnza73c.CalendarCategory) {
      return _icnza73c.CalendarCategory.fromJson(data) as T;
    }
    if (t == _i9j129by.CalendarCategoryFilter) {
      return _i9j129by.CalendarCategoryFilter.fromJson(data) as T;
    }
    if (t == _i8chn2wc.CalendarCreateRequest) {
      return _i8chn2wc.CalendarCreateRequest.fromJson(data) as T;
    }
    if (t == _iq7751s4.CalendarEventByDay) {
      return _iq7751s4.CalendarEventByDay.fromJson(data) as T;
    }
    if (t == _i1bb5k1r.CalendarEventCivil) {
      return _i1bb5k1r.CalendarEventCivil.fromJson(data) as T;
    }
    if (t == _id4cvk34.CalendarEventContent) {
      return _id4cvk34.CalendarEventContent.fromJson(data) as T;
    }
    if (t == _i0orp171.CalendarEventCreateRequest) {
      return _i0orp171.CalendarEventCreateRequest.fromJson(data) as T;
    }
    if (t == _idn2i48l.CalendarEventDuration) {
      return _idn2i48l.CalendarEventDuration.fromJson(data) as T;
    }
    if (t == _iftiwkuj.CalendarEventFieldGroup) {
      return _iftiwkuj.CalendarEventFieldGroup.fromJson(data) as T;
    }
    if (t == _i2q54gr5.CalendarEventFrequency) {
      return _i2q54gr5.CalendarEventFrequency.fromJson(data) as T;
    }
    if (t == _imbjv41e.CalendarEventFutureOverride) {
      return _imbjv41e.CalendarEventFutureOverride.fromJson(data) as T;
    }
    if (t == _isyqnyev.CalendarEventOccurrence) {
      return _isyqnyev.CalendarEventOccurrence.fromJson(data) as T;
    }
    if (t == _icnciyzp.CalendarEventOccurrenceAction) {
      return _icnciyzp.CalendarEventOccurrenceAction.fromJson(data) as T;
    }
    if (t == _i7imxrlz.CalendarEventOccurrenceChange) {
      return _i7imxrlz.CalendarEventOccurrenceChange.fromJson(data) as T;
    }
    if (t == _i1a4s0rt.CalendarEventOccurrencePreview) {
      return _i1a4s0rt.CalendarEventOccurrencePreview.fromJson(data) as T;
    }
    if (t == _ivs4ir3j.CalendarEventOccurrenceQuery) {
      return _ivs4ir3j.CalendarEventOccurrenceQuery.fromJson(data) as T;
    }
    if (t == _iaayjmj1.CalendarEventPage) {
      return _iaayjmj1.CalendarEventPage.fromJson(data) as T;
    }
    if (t == _i500bvo7.CalendarEventReceipt) {
      return _i500bvo7.CalendarEventReceipt.fromJson(data) as T;
    }
    if (t == _iqxs44bf.CalendarEventRecurrence) {
      return _iqxs44bf.CalendarEventRecurrence.fromJson(data) as T;
    }
    if (t == _iovyzq1q.CalendarEventRule) {
      return _iovyzq1q.CalendarEventRule.fromJson(data) as T;
    }
    if (t == _iq1kxi25.CalendarEventSingleOverride) {
      return _iq1kxi25.CalendarEventSingleOverride.fromJson(data) as T;
    }
    if (t == _ivzxk9bc.CalendarEventStatus) {
      return _ivzxk9bc.CalendarEventStatus.fromJson(data) as T;
    }
    if (t == _i3kbbl30.CalendarEventStatusRequest) {
      return _i3kbbl30.CalendarEventStatusRequest.fromJson(data) as T;
    }
    if (t == _idbnuf6y.CalendarEventTimeKind) {
      return _idbnuf6y.CalendarEventTimeKind.fromJson(data) as T;
    }
    if (t == _ieswiaty.CalendarEventTiming) {
      return _ieswiaty.CalendarEventTiming.fromJson(data) as T;
    }
    if (t == _ijijze99.CalendarEventTimingOverrides) {
      return _ijijze99.CalendarEventTimingOverrides.fromJson(data) as T;
    }
    if (t == _iwjkdwy7.CalendarEventTransparency) {
      return _iwjkdwy7.CalendarEventTransparency.fromJson(data) as T;
    }
    if (t == _i3ofr0ug.CalendarEventUpdateRequest) {
      return _i3ofr0ug.CalendarEventUpdateRequest.fromJson(data) as T;
    }
    if (t == _iqr733fy.CalendarEventView) {
      return _iqr733fy.CalendarEventView.fromJson(data) as T;
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
    if (t == _ia3n9q23.CalendarFreeBusyCoverage) {
      return _ia3n9q23.CalendarFreeBusyCoverage.fromJson(data) as T;
    }
    if (t == _izms466b.CalendarFreeBusyKind) {
      return _izms466b.CalendarFreeBusyKind.fromJson(data) as T;
    }
    if (t == _i82zcrxb.CalendarFreeBusyPeriod) {
      return _i82zcrxb.CalendarFreeBusyPeriod.fromJson(data) as T;
    }
    if (t == _idid5g6i.CalendarFreeBusyQuery) {
      return _idid5g6i.CalendarFreeBusyQuery.fromJson(data) as T;
    }
    if (t == _i3b615hg.CalendarFreeBusyView) {
      return _i3b615hg.CalendarFreeBusyView.fromJson(data) as T;
    }
    if (t == _igf45b52.CalendarImageLink) {
      return _igf45b52.CalendarImageLink.fromJson(data) as T;
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
    if (t == _iyrimg3m.CalendarProtocolIdentity) {
      return _iyrimg3m.CalendarProtocolIdentity.fromJson(data) as T;
    }
    if (t == _itchuj1l.CalendarProtocolMetadata) {
      return _itchuj1l.CalendarProtocolMetadata.fromJson(data) as T;
    }
    if (t == _iyawor89.CalendarProtocolMetadataUpdateRequest) {
      return _iyawor89.CalendarProtocolMetadataUpdateRequest.fromJson(data)
          as T;
    }
    if (t == _ifsfk5xq.CalendarRefreshHint) {
      return _ifsfk5xq.CalendarRefreshHint.fromJson(data) as T;
    }
    if (t == _i66us6t1.CalendarSettingsUpdateRequest) {
      return _i66us6t1.CalendarSettingsUpdateRequest.fromJson(data) as T;
    }
    if (t == _i41idnki.CalendarSubjectAction) {
      return _i41idnki.CalendarSubjectAction.fromJson(data) as T;
    }
    if (t == _imo3vsmf.CalendarSubjectAvailability) {
      return _imo3vsmf.CalendarSubjectAvailability.fromJson(data) as T;
    }
    if (t == _iuzjb8ji.CalendarSubjectChangeRequest) {
      return _iuzjb8ji.CalendarSubjectChangeRequest.fromJson(data) as T;
    }
    if (t == _ir7mv910.CalendarSubjectView) {
      return _ir7mv910.CalendarSubjectView.fromJson(data) as T;
    }
    if (t == _ixppc388.CalendarSupplementalMetadata) {
      return _ixppc388.CalendarSupplementalMetadata.fromJson(data) as T;
    }
    if (t == _iqx8dg15.CalendarSupplementalMetadataUpdateRequest) {
      return _iqx8dg15.CalendarSupplementalMetadataUpdateRequest.fromJson(data)
          as T;
    }
    if (t == _iffxqqc7.CalendarTextParameters) {
      return _iffxqqc7.CalendarTextParameters.fromJson(data) as T;
    }
    if (t == _itcy22f3.CalendarTextVariant) {
      return _itcy22f3.CalendarTextVariant.fromJson(data) as T;
    }
    if (t == _ivspd2q7.CalendarView) {
      return _ivspd2q7.CalendarView.fromJson(data) as T;
    }
    if (t == _isc.getType<_iywbqexh.CalendarAvailabilityCategoryGroup?>()) {
      return (data != null
              ? _iywbqexh.CalendarAvailabilityCategoryGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iucw7bzg.CalendarAvailabilityClass?>()) {
      return (data != null
              ? _iucw7bzg.CalendarAvailabilityClass.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ifxxil5c.CalendarAvailabilityContent?>()) {
      return (data != null
              ? _ifxxil5c.CalendarAvailabilityContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iwwk2w9d.CalendarAvailabilityCreateRequest?>()) {
      return (data != null
              ? _iwwk2w9d.CalendarAvailabilityCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ipddbn84.CalendarAvailabilityExportRequest?>()) {
      return (data != null
              ? _ipddbn84.CalendarAvailabilityExportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_incs3y0d.CalendarAvailabilityExportSelection?>()) {
      return (data != null
              ? _incs3y0d.CalendarAvailabilityExportSelection.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ip5gybl4.CalendarAvailabilityExtension?>()) {
      return (data != null
              ? _ip5gybl4.CalendarAvailabilityExtension.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i6rm14nf.CalendarAvailabilityImportRequest?>()) {
      return (data != null
              ? _i6rm14nf.CalendarAvailabilityImportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iyvmsn4t.CalendarAvailabilityImportResult?>()) {
      return (data != null
              ? _iyvmsn4t.CalendarAvailabilityImportResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7tpo82q.CalendarAvailabilityOccurrenceChange?>()) {
      return (data != null
              ? _i7tpo82q.CalendarAvailabilityOccurrenceChange.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_inpm99jj.CalendarAvailabilityOccurrencePreview?>()) {
      return (data != null
              ? _inpm99jj.CalendarAvailabilityOccurrencePreview.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iv6wf0pl.CalendarAvailabilityOccurrenceQuery?>()) {
      return (data != null
              ? _iv6wf0pl.CalendarAvailabilityOccurrenceQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8tf9h36.CalendarAvailabilityOpening?>()) {
      return (data != null
              ? _i8tf9h36.CalendarAvailabilityOpening.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_id5ke9r5.CalendarAvailabilityOpeningEdits?>()) {
      return (data != null
              ? _id5ke9r5.CalendarAvailabilityOpeningEdits.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _isc.getType<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState?>()) {
      return (data != null
              ? _ix3hb3ib.CalendarAvailabilityOpeningProtocolState.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _isc.getType<_i5oc0nlo.CalendarAvailabilityOrganizer?>()) {
      return (data != null
              ? _i5oc0nlo.CalendarAvailabilityOrganizer.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _isc.getType<_i33h9mr5.CalendarAvailabilityOverrideProtocolState?>()) {
      return (data != null
              ? _i33h9mr5.CalendarAvailabilityOverrideProtocolState.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _isc.getType<_ib9yzivj.CalendarAvailabilityProtocolState?>()) {
      return (data != null
              ? _ib9yzivj.CalendarAvailabilityProtocolState.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_is1luycx.CalendarAvailabilityReceipt?>()) {
      return (data != null
              ? _is1luycx.CalendarAvailabilityReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iam4llos.CalendarAvailabilitySearchMode?>()) {
      return (data != null
              ? _iam4llos.CalendarAvailabilitySearchMode.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_idixoqjq.CalendarAvailabilitySearchQuery?>()) {
      return (data != null
              ? _idixoqjq.CalendarAvailabilitySearchQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i99fx1rw.CalendarAvailabilitySearchView?>()) {
      return (data != null
              ? _i99fx1rw.CalendarAvailabilitySearchView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i45h4t8f.CalendarAvailabilitySlot?>()) {
      return (data != null
              ? _i45h4t8f.CalendarAvailabilitySlot.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i15w6qdl.CalendarAvailabilitySourceMetadata?>()) {
      return (data != null
              ? _i15w6qdl.CalendarAvailabilitySourceMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iwbqbnec.CalendarAvailabilityTarget?>()) {
      return (data != null
              ? _iwbqbnec.CalendarAvailabilityTarget.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_itw42wa3.CalendarAvailabilityText?>()) {
      return (data != null
              ? _itw42wa3.CalendarAvailabilityText.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ipbm7ji7.CalendarAvailabilityTextParameters?>()) {
      return (data != null
              ? _ipbm7ji7.CalendarAvailabilityTextParameters.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_igv5u6jv.CalendarAvailabilityUpdateRequest?>()) {
      return (data != null
              ? _igv5u6jv.CalendarAvailabilityUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_izmf6fpk.CalendarAvailabilityView?>()) {
      return (data != null
              ? _izmf6fpk.CalendarAvailabilityView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_icnza73c.CalendarCategory?>()) {
      return (data != null ? _icnza73c.CalendarCategory.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i9j129by.CalendarCategoryFilter?>()) {
      return (data != null
              ? _i9j129by.CalendarCategoryFilter.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8chn2wc.CalendarCreateRequest?>()) {
      return (data != null
              ? _i8chn2wc.CalendarCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iq7751s4.CalendarEventByDay?>()) {
      return (data != null ? _iq7751s4.CalendarEventByDay.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i1bb5k1r.CalendarEventCivil?>()) {
      return (data != null ? _i1bb5k1r.CalendarEventCivil.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_id4cvk34.CalendarEventContent?>()) {
      return (data != null
              ? _id4cvk34.CalendarEventContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i0orp171.CalendarEventCreateRequest?>()) {
      return (data != null
              ? _i0orp171.CalendarEventCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_idn2i48l.CalendarEventDuration?>()) {
      return (data != null
              ? _idn2i48l.CalendarEventDuration.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iftiwkuj.CalendarEventFieldGroup?>()) {
      return (data != null
              ? _iftiwkuj.CalendarEventFieldGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i2q54gr5.CalendarEventFrequency?>()) {
      return (data != null
              ? _i2q54gr5.CalendarEventFrequency.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_imbjv41e.CalendarEventFutureOverride?>()) {
      return (data != null
              ? _imbjv41e.CalendarEventFutureOverride.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_isyqnyev.CalendarEventOccurrence?>()) {
      return (data != null
              ? _isyqnyev.CalendarEventOccurrence.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_icnciyzp.CalendarEventOccurrenceAction?>()) {
      return (data != null
              ? _icnciyzp.CalendarEventOccurrenceAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7imxrlz.CalendarEventOccurrenceChange?>()) {
      return (data != null
              ? _i7imxrlz.CalendarEventOccurrenceChange.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i1a4s0rt.CalendarEventOccurrencePreview?>()) {
      return (data != null
              ? _i1a4s0rt.CalendarEventOccurrencePreview.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ivs4ir3j.CalendarEventOccurrenceQuery?>()) {
      return (data != null
              ? _ivs4ir3j.CalendarEventOccurrenceQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iaayjmj1.CalendarEventPage?>()) {
      return (data != null ? _iaayjmj1.CalendarEventPage.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i500bvo7.CalendarEventReceipt?>()) {
      return (data != null
              ? _i500bvo7.CalendarEventReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iqxs44bf.CalendarEventRecurrence?>()) {
      return (data != null
              ? _iqxs44bf.CalendarEventRecurrence.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iovyzq1q.CalendarEventRule?>()) {
      return (data != null ? _iovyzq1q.CalendarEventRule.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iq1kxi25.CalendarEventSingleOverride?>()) {
      return (data != null
              ? _iq1kxi25.CalendarEventSingleOverride.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ivzxk9bc.CalendarEventStatus?>()) {
      return (data != null
              ? _ivzxk9bc.CalendarEventStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i3kbbl30.CalendarEventStatusRequest?>()) {
      return (data != null
              ? _i3kbbl30.CalendarEventStatusRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_idbnuf6y.CalendarEventTimeKind?>()) {
      return (data != null
              ? _idbnuf6y.CalendarEventTimeKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ieswiaty.CalendarEventTiming?>()) {
      return (data != null
              ? _ieswiaty.CalendarEventTiming.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ijijze99.CalendarEventTimingOverrides?>()) {
      return (data != null
              ? _ijijze99.CalendarEventTimingOverrides.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iwjkdwy7.CalendarEventTransparency?>()) {
      return (data != null
              ? _iwjkdwy7.CalendarEventTransparency.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i3ofr0ug.CalendarEventUpdateRequest?>()) {
      return (data != null
              ? _i3ofr0ug.CalendarEventUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iqr733fy.CalendarEventView?>()) {
      return (data != null ? _iqr733fy.CalendarEventView.fromJson(data) : null)
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
    if (t == _isc.getType<_ia3n9q23.CalendarFreeBusyCoverage?>()) {
      return (data != null
              ? _ia3n9q23.CalendarFreeBusyCoverage.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_izms466b.CalendarFreeBusyKind?>()) {
      return (data != null
              ? _izms466b.CalendarFreeBusyKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i82zcrxb.CalendarFreeBusyPeriod?>()) {
      return (data != null
              ? _i82zcrxb.CalendarFreeBusyPeriod.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_idid5g6i.CalendarFreeBusyQuery?>()) {
      return (data != null
              ? _idid5g6i.CalendarFreeBusyQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i3b615hg.CalendarFreeBusyView?>()) {
      return (data != null
              ? _i3b615hg.CalendarFreeBusyView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_igf45b52.CalendarImageLink?>()) {
      return (data != null ? _igf45b52.CalendarImageLink.fromJson(data) : null)
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
    if (t == _isc.getType<_iyrimg3m.CalendarProtocolIdentity?>()) {
      return (data != null
              ? _iyrimg3m.CalendarProtocolIdentity.fromJson(data)
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
    if (t == _isc.getType<_ifsfk5xq.CalendarRefreshHint?>()) {
      return (data != null
              ? _ifsfk5xq.CalendarRefreshHint.fromJson(data)
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
    if (t == _isc.getType<_imo3vsmf.CalendarSubjectAvailability?>()) {
      return (data != null
              ? _imo3vsmf.CalendarSubjectAvailability.fromJson(data)
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
    if (t == _isc.getType<_ixppc388.CalendarSupplementalMetadata?>()) {
      return (data != null
              ? _ixppc388.CalendarSupplementalMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _isc.getType<_iqx8dg15.CalendarSupplementalMetadataUpdateRequest?>()) {
      return (data != null
              ? _iqx8dg15.CalendarSupplementalMetadataUpdateRequest.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _isc.getType<_iffxqqc7.CalendarTextParameters?>()) {
      return (data != null
              ? _iffxqqc7.CalendarTextParameters.fromJson(data)
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
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i8tf9h36.CalendarAvailabilityOpening>) {
      return (data as List)
              .map((e) => deserialize<_i8tf9h36.CalendarAvailabilityOpening>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_ip5gybl4.CalendarAvailabilityExtension>) {
      return (data as List)
              .map(
                (e) => deserialize<_ip5gybl4.CalendarAvailabilityExtension>(e),
              )
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ip5gybl4.CalendarAvailabilityExtension>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<_ip5gybl4.CalendarAvailabilityExtension>(
                            e,
                          ),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_iywbqexh.CalendarAvailabilityCategoryGroup>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_iywbqexh.CalendarAvailabilityCategoryGroup>(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _isc.getType<List<_iywbqexh.CalendarAvailabilityCategoryGroup>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<
                            _iywbqexh.CalendarAvailabilityCategoryGroup
                          >(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_itw42wa3.CalendarAvailabilityText>) {
      return (data as List)
              .map((e) => deserialize<_itw42wa3.CalendarAvailabilityText>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_itw42wa3.CalendarAvailabilityText>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_itw42wa3.CalendarAvailabilityText>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_incs3y0d.CalendarAvailabilityExportSelection>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_incs3y0d.CalendarAvailabilityExportSelection>(
                      e,
                    ),
              )
              .toList()
          as T;
    }
    if (t == List<_is1luycx.CalendarAvailabilityReceipt>) {
      return (data as List)
              .map((e) => deserialize<_is1luycx.CalendarAvailabilityReceipt>(e))
              .toList()
          as T;
    }
    if (t == List<_isyqnyev.CalendarEventOccurrence>) {
      return (data as List)
              .map((e) => deserialize<_isyqnyev.CalendarEventOccurrence>(e))
              .toList()
          as T;
    }
    if (t == List<_ieswiaty.CalendarEventTiming>) {
      return (data as List)
              .map((e) => deserialize<_ieswiaty.CalendarEventTiming>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ieswiaty.CalendarEventTiming>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ieswiaty.CalendarEventTiming>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      _i33h9mr5.CalendarAvailabilityOverrideProtocolState
                    >(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _isc
            .getType<
              List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>?
            >()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<
                            _i33h9mr5.CalendarAvailabilityOverrideProtocolState
                          >(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      _ix3hb3ib.CalendarAvailabilityOpeningProtocolState
                    >(e),
              )
              .toList()
          as T;
    }
    if (t == List<_iwbqbnec.CalendarAvailabilityTarget>) {
      return (data as List)
              .map((e) => deserialize<_iwbqbnec.CalendarAvailabilityTarget>(e))
              .toList()
          as T;
    }
    if (t == List<_imo3vsmf.CalendarSubjectAvailability>) {
      return (data as List)
              .map((e) => deserialize<_imo3vsmf.CalendarSubjectAvailability>(e))
              .toList()
          as T;
    }
    if (t == List<_i45h4t8f.CalendarAvailabilitySlot>) {
      return (data as List)
              .map((e) => deserialize<_i45h4t8f.CalendarAvailabilitySlot>(e))
              .toList()
          as T;
    }
    if (t == List<_iffxqqc7.CalendarTextParameters?>) {
      return (data as List)
              .map((e) => deserialize<_iffxqqc7.CalendarTextParameters?>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_iffxqqc7.CalendarTextParameters?>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_iffxqqc7.CalendarTextParameters?>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_id5ke9r5.CalendarAvailabilityOpeningEdits>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_id5ke9r5.CalendarAvailabilityOpeningEdits>(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _isc.getType<List<_id5ke9r5.CalendarAvailabilityOpeningEdits>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<
                            _id5ke9r5.CalendarAvailabilityOpeningEdits
                          >(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_iqr733fy.CalendarEventView>) {
      return (data as List)
              .map((e) => deserialize<_iqr733fy.CalendarEventView>(e))
              .toList()
          as T;
    }
    if (t == List<_iq7751s4.CalendarEventByDay>) {
      return (data as List)
              .map((e) => deserialize<_iq7751s4.CalendarEventByDay>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_iq1kxi25.CalendarEventSingleOverride>) {
      return (data as List)
              .map((e) => deserialize<_iq1kxi25.CalendarEventSingleOverride>(e))
              .toList()
          as T;
    }
    if (t == List<_imbjv41e.CalendarEventFutureOverride>) {
      return (data as List)
              .map((e) => deserialize<_imbjv41e.CalendarEventFutureOverride>(e))
              .toList()
          as T;
    }
    if (t == List<_iftiwkuj.CalendarEventFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_iftiwkuj.CalendarEventFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_i82zcrxb.CalendarFreeBusyPeriod>) {
      return (data as List)
              .map((e) => deserialize<_i82zcrxb.CalendarFreeBusyPeriod>(e))
              .toList()
          as T;
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
    if (t == List<_icnza73c.CalendarCategory>) {
      return (data as List)
              .map((e) => deserialize<_icnza73c.CalendarCategory>(e))
              .toList()
          as T;
    }
    if (t == List<_igf45b52.CalendarImageLink>) {
      return (data as List)
              .map((e) => deserialize<_igf45b52.CalendarImageLink>(e))
              .toList()
          as T;
    }
    if (t == List<_i73hgz1s.CalendarFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_i73hgz1s.CalendarFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_imwdhk62.CalendarAvailabilityView>) {
      return (data as List)
              .map((e) => deserialize<_imwdhk62.CalendarAvailabilityView>(e))
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
    if (t == List<_icxx5h8a.CalendarEventFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_icxx5h8a.CalendarEventFieldGroup>(e))
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
      _iywbqexh.CalendarAvailabilityCategoryGroup =>
        'CalendarAvailabilityCategoryGroup',
      _iucw7bzg.CalendarAvailabilityClass => 'CalendarAvailabilityClass',
      _ifxxil5c.CalendarAvailabilityContent => 'CalendarAvailabilityContent',
      _iwwk2w9d.CalendarAvailabilityCreateRequest =>
        'CalendarAvailabilityCreateRequest',
      _ipddbn84.CalendarAvailabilityExportRequest =>
        'CalendarAvailabilityExportRequest',
      _incs3y0d.CalendarAvailabilityExportSelection =>
        'CalendarAvailabilityExportSelection',
      _ip5gybl4.CalendarAvailabilityExtension =>
        'CalendarAvailabilityExtension',
      _i6rm14nf.CalendarAvailabilityImportRequest =>
        'CalendarAvailabilityImportRequest',
      _iyvmsn4t.CalendarAvailabilityImportResult =>
        'CalendarAvailabilityImportResult',
      _i7tpo82q.CalendarAvailabilityOccurrenceChange =>
        'CalendarAvailabilityOccurrenceChange',
      _inpm99jj.CalendarAvailabilityOccurrencePreview =>
        'CalendarAvailabilityOccurrencePreview',
      _iv6wf0pl.CalendarAvailabilityOccurrenceQuery =>
        'CalendarAvailabilityOccurrenceQuery',
      _i8tf9h36.CalendarAvailabilityOpening => 'CalendarAvailabilityOpening',
      _id5ke9r5.CalendarAvailabilityOpeningEdits =>
        'CalendarAvailabilityOpeningEdits',
      _ix3hb3ib.CalendarAvailabilityOpeningProtocolState =>
        'CalendarAvailabilityOpeningProtocolState',
      _i5oc0nlo.CalendarAvailabilityOrganizer =>
        'CalendarAvailabilityOrganizer',
      _i33h9mr5.CalendarAvailabilityOverrideProtocolState =>
        'CalendarAvailabilityOverrideProtocolState',
      _ib9yzivj.CalendarAvailabilityProtocolState =>
        'CalendarAvailabilityProtocolState',
      _is1luycx.CalendarAvailabilityReceipt => 'CalendarAvailabilityReceipt',
      _iam4llos.CalendarAvailabilitySearchMode =>
        'CalendarAvailabilitySearchMode',
      _idixoqjq.CalendarAvailabilitySearchQuery =>
        'CalendarAvailabilitySearchQuery',
      _i99fx1rw.CalendarAvailabilitySearchView =>
        'CalendarAvailabilitySearchView',
      _i45h4t8f.CalendarAvailabilitySlot => 'CalendarAvailabilitySlot',
      _i15w6qdl.CalendarAvailabilitySourceMetadata =>
        'CalendarAvailabilitySourceMetadata',
      _iwbqbnec.CalendarAvailabilityTarget => 'CalendarAvailabilityTarget',
      _itw42wa3.CalendarAvailabilityText => 'CalendarAvailabilityText',
      _ipbm7ji7.CalendarAvailabilityTextParameters =>
        'CalendarAvailabilityTextParameters',
      _igv5u6jv.CalendarAvailabilityUpdateRequest =>
        'CalendarAvailabilityUpdateRequest',
      _izmf6fpk.CalendarAvailabilityView => 'CalendarAvailabilityView',
      _icnza73c.CalendarCategory => 'CalendarCategory',
      _i9j129by.CalendarCategoryFilter => 'CalendarCategoryFilter',
      _i8chn2wc.CalendarCreateRequest => 'CalendarCreateRequest',
      _iq7751s4.CalendarEventByDay => 'CalendarEventByDay',
      _i1bb5k1r.CalendarEventCivil => 'CalendarEventCivil',
      _id4cvk34.CalendarEventContent => 'CalendarEventContent',
      _i0orp171.CalendarEventCreateRequest => 'CalendarEventCreateRequest',
      _idn2i48l.CalendarEventDuration => 'CalendarEventDuration',
      _iftiwkuj.CalendarEventFieldGroup => 'CalendarEventFieldGroup',
      _i2q54gr5.CalendarEventFrequency => 'CalendarEventFrequency',
      _imbjv41e.CalendarEventFutureOverride => 'CalendarEventFutureOverride',
      _isyqnyev.CalendarEventOccurrence => 'CalendarEventOccurrence',
      _icnciyzp.CalendarEventOccurrenceAction =>
        'CalendarEventOccurrenceAction',
      _i7imxrlz.CalendarEventOccurrenceChange =>
        'CalendarEventOccurrenceChange',
      _i1a4s0rt.CalendarEventOccurrencePreview =>
        'CalendarEventOccurrencePreview',
      _ivs4ir3j.CalendarEventOccurrenceQuery => 'CalendarEventOccurrenceQuery',
      _iaayjmj1.CalendarEventPage => 'CalendarEventPage',
      _i500bvo7.CalendarEventReceipt => 'CalendarEventReceipt',
      _iqxs44bf.CalendarEventRecurrence => 'CalendarEventRecurrence',
      _iovyzq1q.CalendarEventRule => 'CalendarEventRule',
      _iq1kxi25.CalendarEventSingleOverride => 'CalendarEventSingleOverride',
      _ivzxk9bc.CalendarEventStatus => 'CalendarEventStatus',
      _i3kbbl30.CalendarEventStatusRequest => 'CalendarEventStatusRequest',
      _idbnuf6y.CalendarEventTimeKind => 'CalendarEventTimeKind',
      _ieswiaty.CalendarEventTiming => 'CalendarEventTiming',
      _ijijze99.CalendarEventTimingOverrides => 'CalendarEventTimingOverrides',
      _iwjkdwy7.CalendarEventTransparency => 'CalendarEventTransparency',
      _i3ofr0ug.CalendarEventUpdateRequest => 'CalendarEventUpdateRequest',
      _iqr733fy.CalendarEventView => 'CalendarEventView',
      _ioicq9ju.CalendarException => 'CalendarException',
      _i7h2f30k.CalendarFailureCode => 'CalendarFailureCode',
      _i73hgz1s.CalendarFieldGroup => 'CalendarFieldGroup',
      _ia3n9q23.CalendarFreeBusyCoverage => 'CalendarFreeBusyCoverage',
      _izms466b.CalendarFreeBusyKind => 'CalendarFreeBusyKind',
      _i82zcrxb.CalendarFreeBusyPeriod => 'CalendarFreeBusyPeriod',
      _idid5g6i.CalendarFreeBusyQuery => 'CalendarFreeBusyQuery',
      _i3b615hg.CalendarFreeBusyView => 'CalendarFreeBusyView',
      _igf45b52.CalendarImageLink => 'CalendarImageLink',
      _i759fw3a.CalendarMetadataUpdateRequest =>
        'CalendarMetadataUpdateRequest',
      _iq0eskk0.CalendarMutationReceipt => 'CalendarMutationReceipt',
      _itts4qyp.CalendarNoRuleFallback => 'CalendarNoRuleFallback',
      _i0jfcg0j.CalendarPage => 'CalendarPage',
      _i9m9yk5s.CalendarPresentationUpdateRequest =>
        'CalendarPresentationUpdateRequest',
      _iyrimg3m.CalendarProtocolIdentity => 'CalendarProtocolIdentity',
      _itchuj1l.CalendarProtocolMetadata => 'CalendarProtocolMetadata',
      _iyawor89.CalendarProtocolMetadataUpdateRequest =>
        'CalendarProtocolMetadataUpdateRequest',
      _ifsfk5xq.CalendarRefreshHint => 'CalendarRefreshHint',
      _i66us6t1.CalendarSettingsUpdateRequest =>
        'CalendarSettingsUpdateRequest',
      _i41idnki.CalendarSubjectAction => 'CalendarSubjectAction',
      _imo3vsmf.CalendarSubjectAvailability => 'CalendarSubjectAvailability',
      _iuzjb8ji.CalendarSubjectChangeRequest => 'CalendarSubjectChangeRequest',
      _ir7mv910.CalendarSubjectView => 'CalendarSubjectView',
      _ixppc388.CalendarSupplementalMetadata => 'CalendarSupplementalMetadata',
      _iqx8dg15.CalendarSupplementalMetadataUpdateRequest =>
        'CalendarSupplementalMetadataUpdateRequest',
      _iffxqqc7.CalendarTextParameters => 'CalendarTextParameters',
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
      case _iywbqexh.CalendarAvailabilityCategoryGroup():
        return 'CalendarAvailabilityCategoryGroup';
      case _iucw7bzg.CalendarAvailabilityClass():
        return 'CalendarAvailabilityClass';
      case _ifxxil5c.CalendarAvailabilityContent():
        return 'CalendarAvailabilityContent';
      case _iwwk2w9d.CalendarAvailabilityCreateRequest():
        return 'CalendarAvailabilityCreateRequest';
      case _ipddbn84.CalendarAvailabilityExportRequest():
        return 'CalendarAvailabilityExportRequest';
      case _incs3y0d.CalendarAvailabilityExportSelection():
        return 'CalendarAvailabilityExportSelection';
      case _ip5gybl4.CalendarAvailabilityExtension():
        return 'CalendarAvailabilityExtension';
      case _i6rm14nf.CalendarAvailabilityImportRequest():
        return 'CalendarAvailabilityImportRequest';
      case _iyvmsn4t.CalendarAvailabilityImportResult():
        return 'CalendarAvailabilityImportResult';
      case _i7tpo82q.CalendarAvailabilityOccurrenceChange():
        return 'CalendarAvailabilityOccurrenceChange';
      case _inpm99jj.CalendarAvailabilityOccurrencePreview():
        return 'CalendarAvailabilityOccurrencePreview';
      case _iv6wf0pl.CalendarAvailabilityOccurrenceQuery():
        return 'CalendarAvailabilityOccurrenceQuery';
      case _i8tf9h36.CalendarAvailabilityOpening():
        return 'CalendarAvailabilityOpening';
      case _id5ke9r5.CalendarAvailabilityOpeningEdits():
        return 'CalendarAvailabilityOpeningEdits';
      case _ix3hb3ib.CalendarAvailabilityOpeningProtocolState():
        return 'CalendarAvailabilityOpeningProtocolState';
      case _i5oc0nlo.CalendarAvailabilityOrganizer():
        return 'CalendarAvailabilityOrganizer';
      case _i33h9mr5.CalendarAvailabilityOverrideProtocolState():
        return 'CalendarAvailabilityOverrideProtocolState';
      case _ib9yzivj.CalendarAvailabilityProtocolState():
        return 'CalendarAvailabilityProtocolState';
      case _is1luycx.CalendarAvailabilityReceipt():
        return 'CalendarAvailabilityReceipt';
      case _iam4llos.CalendarAvailabilitySearchMode():
        return 'CalendarAvailabilitySearchMode';
      case _idixoqjq.CalendarAvailabilitySearchQuery():
        return 'CalendarAvailabilitySearchQuery';
      case _i99fx1rw.CalendarAvailabilitySearchView():
        return 'CalendarAvailabilitySearchView';
      case _i45h4t8f.CalendarAvailabilitySlot():
        return 'CalendarAvailabilitySlot';
      case _i15w6qdl.CalendarAvailabilitySourceMetadata():
        return 'CalendarAvailabilitySourceMetadata';
      case _iwbqbnec.CalendarAvailabilityTarget():
        return 'CalendarAvailabilityTarget';
      case _itw42wa3.CalendarAvailabilityText():
        return 'CalendarAvailabilityText';
      case _ipbm7ji7.CalendarAvailabilityTextParameters():
        return 'CalendarAvailabilityTextParameters';
      case _igv5u6jv.CalendarAvailabilityUpdateRequest():
        return 'CalendarAvailabilityUpdateRequest';
      case _izmf6fpk.CalendarAvailabilityView():
        return 'CalendarAvailabilityView';
      case _icnza73c.CalendarCategory():
        return 'CalendarCategory';
      case _i9j129by.CalendarCategoryFilter():
        return 'CalendarCategoryFilter';
      case _i8chn2wc.CalendarCreateRequest():
        return 'CalendarCreateRequest';
      case _iq7751s4.CalendarEventByDay():
        return 'CalendarEventByDay';
      case _i1bb5k1r.CalendarEventCivil():
        return 'CalendarEventCivil';
      case _id4cvk34.CalendarEventContent():
        return 'CalendarEventContent';
      case _i0orp171.CalendarEventCreateRequest():
        return 'CalendarEventCreateRequest';
      case _idn2i48l.CalendarEventDuration():
        return 'CalendarEventDuration';
      case _iftiwkuj.CalendarEventFieldGroup():
        return 'CalendarEventFieldGroup';
      case _i2q54gr5.CalendarEventFrequency():
        return 'CalendarEventFrequency';
      case _imbjv41e.CalendarEventFutureOverride():
        return 'CalendarEventFutureOverride';
      case _isyqnyev.CalendarEventOccurrence():
        return 'CalendarEventOccurrence';
      case _icnciyzp.CalendarEventOccurrenceAction():
        return 'CalendarEventOccurrenceAction';
      case _i7imxrlz.CalendarEventOccurrenceChange():
        return 'CalendarEventOccurrenceChange';
      case _i1a4s0rt.CalendarEventOccurrencePreview():
        return 'CalendarEventOccurrencePreview';
      case _ivs4ir3j.CalendarEventOccurrenceQuery():
        return 'CalendarEventOccurrenceQuery';
      case _iaayjmj1.CalendarEventPage():
        return 'CalendarEventPage';
      case _i500bvo7.CalendarEventReceipt():
        return 'CalendarEventReceipt';
      case _iqxs44bf.CalendarEventRecurrence():
        return 'CalendarEventRecurrence';
      case _iovyzq1q.CalendarEventRule():
        return 'CalendarEventRule';
      case _iq1kxi25.CalendarEventSingleOverride():
        return 'CalendarEventSingleOverride';
      case _ivzxk9bc.CalendarEventStatus():
        return 'CalendarEventStatus';
      case _i3kbbl30.CalendarEventStatusRequest():
        return 'CalendarEventStatusRequest';
      case _idbnuf6y.CalendarEventTimeKind():
        return 'CalendarEventTimeKind';
      case _ieswiaty.CalendarEventTiming():
        return 'CalendarEventTiming';
      case _ijijze99.CalendarEventTimingOverrides():
        return 'CalendarEventTimingOverrides';
      case _iwjkdwy7.CalendarEventTransparency():
        return 'CalendarEventTransparency';
      case _i3ofr0ug.CalendarEventUpdateRequest():
        return 'CalendarEventUpdateRequest';
      case _iqr733fy.CalendarEventView():
        return 'CalendarEventView';
      case _ioicq9ju.CalendarException():
        return 'CalendarException';
      case _i7h2f30k.CalendarFailureCode():
        return 'CalendarFailureCode';
      case _i73hgz1s.CalendarFieldGroup():
        return 'CalendarFieldGroup';
      case _ia3n9q23.CalendarFreeBusyCoverage():
        return 'CalendarFreeBusyCoverage';
      case _izms466b.CalendarFreeBusyKind():
        return 'CalendarFreeBusyKind';
      case _i82zcrxb.CalendarFreeBusyPeriod():
        return 'CalendarFreeBusyPeriod';
      case _idid5g6i.CalendarFreeBusyQuery():
        return 'CalendarFreeBusyQuery';
      case _i3b615hg.CalendarFreeBusyView():
        return 'CalendarFreeBusyView';
      case _igf45b52.CalendarImageLink():
        return 'CalendarImageLink';
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
      case _iyrimg3m.CalendarProtocolIdentity():
        return 'CalendarProtocolIdentity';
      case _itchuj1l.CalendarProtocolMetadata():
        return 'CalendarProtocolMetadata';
      case _iyawor89.CalendarProtocolMetadataUpdateRequest():
        return 'CalendarProtocolMetadataUpdateRequest';
      case _ifsfk5xq.CalendarRefreshHint():
        return 'CalendarRefreshHint';
      case _i66us6t1.CalendarSettingsUpdateRequest():
        return 'CalendarSettingsUpdateRequest';
      case _i41idnki.CalendarSubjectAction():
        return 'CalendarSubjectAction';
      case _imo3vsmf.CalendarSubjectAvailability():
        return 'CalendarSubjectAvailability';
      case _iuzjb8ji.CalendarSubjectChangeRequest():
        return 'CalendarSubjectChangeRequest';
      case _ir7mv910.CalendarSubjectView():
        return 'CalendarSubjectView';
      case _ixppc388.CalendarSupplementalMetadata():
        return 'CalendarSupplementalMetadata';
      case _iqx8dg15.CalendarSupplementalMetadataUpdateRequest():
        return 'CalendarSupplementalMetadataUpdateRequest';
      case _iffxqqc7.CalendarTextParameters():
        return 'CalendarTextParameters';
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
    if (dataClassName == 'CalendarAvailabilityCategoryGroup') {
      return deserialize<_iywbqexh.CalendarAvailabilityCategoryGroup>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityClass') {
      return deserialize<_iucw7bzg.CalendarAvailabilityClass>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityContent') {
      return deserialize<_ifxxil5c.CalendarAvailabilityContent>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityCreateRequest') {
      return deserialize<_iwwk2w9d.CalendarAvailabilityCreateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityExportRequest') {
      return deserialize<_ipddbn84.CalendarAvailabilityExportRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityExportSelection') {
      return deserialize<_incs3y0d.CalendarAvailabilityExportSelection>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityExtension') {
      return deserialize<_ip5gybl4.CalendarAvailabilityExtension>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityImportRequest') {
      return deserialize<_i6rm14nf.CalendarAvailabilityImportRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityImportResult') {
      return deserialize<_iyvmsn4t.CalendarAvailabilityImportResult>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityOccurrenceChange') {
      return deserialize<_i7tpo82q.CalendarAvailabilityOccurrenceChange>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityOccurrencePreview') {
      return deserialize<_inpm99jj.CalendarAvailabilityOccurrencePreview>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityOccurrenceQuery') {
      return deserialize<_iv6wf0pl.CalendarAvailabilityOccurrenceQuery>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityOpening') {
      return deserialize<_i8tf9h36.CalendarAvailabilityOpening>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityOpeningEdits') {
      return deserialize<_id5ke9r5.CalendarAvailabilityOpeningEdits>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityOpeningProtocolState') {
      return deserialize<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityOrganizer') {
      return deserialize<_i5oc0nlo.CalendarAvailabilityOrganizer>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityOverrideProtocolState') {
      return deserialize<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityProtocolState') {
      return deserialize<_ib9yzivj.CalendarAvailabilityProtocolState>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityReceipt') {
      return deserialize<_is1luycx.CalendarAvailabilityReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilitySearchMode') {
      return deserialize<_iam4llos.CalendarAvailabilitySearchMode>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilitySearchQuery') {
      return deserialize<_idixoqjq.CalendarAvailabilitySearchQuery>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilitySearchView') {
      return deserialize<_i99fx1rw.CalendarAvailabilitySearchView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilitySlot') {
      return deserialize<_i45h4t8f.CalendarAvailabilitySlot>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilitySourceMetadata') {
      return deserialize<_i15w6qdl.CalendarAvailabilitySourceMetadata>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityTarget') {
      return deserialize<_iwbqbnec.CalendarAvailabilityTarget>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityText') {
      return deserialize<_itw42wa3.CalendarAvailabilityText>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityTextParameters') {
      return deserialize<_ipbm7ji7.CalendarAvailabilityTextParameters>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityUpdateRequest') {
      return deserialize<_igv5u6jv.CalendarAvailabilityUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityView') {
      return deserialize<_izmf6fpk.CalendarAvailabilityView>(data['data']);
    }
    if (dataClassName == 'CalendarCategory') {
      return deserialize<_icnza73c.CalendarCategory>(data['data']);
    }
    if (dataClassName == 'CalendarCategoryFilter') {
      return deserialize<_i9j129by.CalendarCategoryFilter>(data['data']);
    }
    if (dataClassName == 'CalendarCreateRequest') {
      return deserialize<_i8chn2wc.CalendarCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventByDay') {
      return deserialize<_iq7751s4.CalendarEventByDay>(data['data']);
    }
    if (dataClassName == 'CalendarEventCivil') {
      return deserialize<_i1bb5k1r.CalendarEventCivil>(data['data']);
    }
    if (dataClassName == 'CalendarEventContent') {
      return deserialize<_id4cvk34.CalendarEventContent>(data['data']);
    }
    if (dataClassName == 'CalendarEventCreateRequest') {
      return deserialize<_i0orp171.CalendarEventCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventDuration') {
      return deserialize<_idn2i48l.CalendarEventDuration>(data['data']);
    }
    if (dataClassName == 'CalendarEventFieldGroup') {
      return deserialize<_iftiwkuj.CalendarEventFieldGroup>(data['data']);
    }
    if (dataClassName == 'CalendarEventFrequency') {
      return deserialize<_i2q54gr5.CalendarEventFrequency>(data['data']);
    }
    if (dataClassName == 'CalendarEventFutureOverride') {
      return deserialize<_imbjv41e.CalendarEventFutureOverride>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrence') {
      return deserialize<_isyqnyev.CalendarEventOccurrence>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrenceAction') {
      return deserialize<_icnciyzp.CalendarEventOccurrenceAction>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrenceChange') {
      return deserialize<_i7imxrlz.CalendarEventOccurrenceChange>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrencePreview') {
      return deserialize<_i1a4s0rt.CalendarEventOccurrencePreview>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceQuery') {
      return deserialize<_ivs4ir3j.CalendarEventOccurrenceQuery>(data['data']);
    }
    if (dataClassName == 'CalendarEventPage') {
      return deserialize<_iaayjmj1.CalendarEventPage>(data['data']);
    }
    if (dataClassName == 'CalendarEventReceipt') {
      return deserialize<_i500bvo7.CalendarEventReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarEventRecurrence') {
      return deserialize<_iqxs44bf.CalendarEventRecurrence>(data['data']);
    }
    if (dataClassName == 'CalendarEventRule') {
      return deserialize<_iovyzq1q.CalendarEventRule>(data['data']);
    }
    if (dataClassName == 'CalendarEventSingleOverride') {
      return deserialize<_iq1kxi25.CalendarEventSingleOverride>(data['data']);
    }
    if (dataClassName == 'CalendarEventStatus') {
      return deserialize<_ivzxk9bc.CalendarEventStatus>(data['data']);
    }
    if (dataClassName == 'CalendarEventStatusRequest') {
      return deserialize<_i3kbbl30.CalendarEventStatusRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventTimeKind') {
      return deserialize<_idbnuf6y.CalendarEventTimeKind>(data['data']);
    }
    if (dataClassName == 'CalendarEventTiming') {
      return deserialize<_ieswiaty.CalendarEventTiming>(data['data']);
    }
    if (dataClassName == 'CalendarEventTimingOverrides') {
      return deserialize<_ijijze99.CalendarEventTimingOverrides>(data['data']);
    }
    if (dataClassName == 'CalendarEventTransparency') {
      return deserialize<_iwjkdwy7.CalendarEventTransparency>(data['data']);
    }
    if (dataClassName == 'CalendarEventUpdateRequest') {
      return deserialize<_i3ofr0ug.CalendarEventUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventView') {
      return deserialize<_iqr733fy.CalendarEventView>(data['data']);
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
    if (dataClassName == 'CalendarFreeBusyCoverage') {
      return deserialize<_ia3n9q23.CalendarFreeBusyCoverage>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyKind') {
      return deserialize<_izms466b.CalendarFreeBusyKind>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyPeriod') {
      return deserialize<_i82zcrxb.CalendarFreeBusyPeriod>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyQuery') {
      return deserialize<_idid5g6i.CalendarFreeBusyQuery>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyView') {
      return deserialize<_i3b615hg.CalendarFreeBusyView>(data['data']);
    }
    if (dataClassName == 'CalendarImageLink') {
      return deserialize<_igf45b52.CalendarImageLink>(data['data']);
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
    if (dataClassName == 'CalendarProtocolIdentity') {
      return deserialize<_iyrimg3m.CalendarProtocolIdentity>(data['data']);
    }
    if (dataClassName == 'CalendarProtocolMetadata') {
      return deserialize<_itchuj1l.CalendarProtocolMetadata>(data['data']);
    }
    if (dataClassName == 'CalendarProtocolMetadataUpdateRequest') {
      return deserialize<_iyawor89.CalendarProtocolMetadataUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarRefreshHint') {
      return deserialize<_ifsfk5xq.CalendarRefreshHint>(data['data']);
    }
    if (dataClassName == 'CalendarSettingsUpdateRequest') {
      return deserialize<_i66us6t1.CalendarSettingsUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectAction') {
      return deserialize<_i41idnki.CalendarSubjectAction>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectAvailability') {
      return deserialize<_imo3vsmf.CalendarSubjectAvailability>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectChangeRequest') {
      return deserialize<_iuzjb8ji.CalendarSubjectChangeRequest>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectView') {
      return deserialize<_ir7mv910.CalendarSubjectView>(data['data']);
    }
    if (dataClassName == 'CalendarSupplementalMetadata') {
      return deserialize<_ixppc388.CalendarSupplementalMetadata>(data['data']);
    }
    if (dataClassName == 'CalendarSupplementalMetadataUpdateRequest') {
      return deserialize<_iqx8dg15.CalendarSupplementalMetadataUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTextParameters') {
      return deserialize<_iffxqqc7.CalendarTextParameters>(data['data']);
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
