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
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_calendar_server/src/generated/calendar_alarm_view.dart'
    as _izvxtiv8;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_view.dart'
    as _i6fuga80;
import 'package:serverpod_calendar_server/src/generated/calendar_event_field_group.dart'
    as _il5gdr09;
import 'package:serverpod_calendar_server/src/generated/calendar_field_group.dart'
    as _i3d02yxy;
import 'package:serverpod_calendar_server/src/generated/calendar_invitation_response_activity_view.dart'
    as _icy7qc8h;
import 'package:serverpod_calendar_server/src/generated/calendar_invitation_source_view.dart'
    as _ifi5u0vl;
import 'package:serverpod_calendar_server/src/generated/calendar_invitation_view.dart'
    as _ienzv1fd;
import 'package:serverpod_calendar_server/src/generated/calendar_scheduling_reply_source_view.dart'
    as _ivnk0jd2;
import 'package:serverpod_calendar_server/src/generated/calendar_subject_view.dart'
    as _iwx7nyid;
import 'package:serverpod_calendar_server/src/generated/calendar_task_field_group.dart'
    as _ik0gz7r1;
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as _ik9lwgjh;
import 'calendar_alarm_action_kind.dart' as _ihv8htej;
import 'calendar_alarm_action_record.dart' as _ipt2851n;
import 'calendar_alarm_action_request.dart' as _ivvkdcds;
import 'calendar_alarm_action_view.dart' as _ixqjnkie;
import 'calendar_alarm_activity_kind.dart' as _ik5ajwd4;
import 'calendar_alarm_activity_page.dart' as _iruhg2yq;
import 'calendar_alarm_anchor.dart' as _iv448ru6;
import 'calendar_alarm_create_request.dart' as _iu47syqa;
import 'calendar_alarm_definition.dart' as _irif99jb;
import 'calendar_alarm_duration.dart' as _i1qnv8jf;
import 'calendar_alarm_firing_kind.dart' as _i8okwxwj;
import 'calendar_alarm_firing_record.dart' as _ihgh57kq;
import 'calendar_alarm_firing_state.dart' as _ihos0r46;
import 'calendar_alarm_firing_view.dart' as _i7xuciin;
import 'calendar_alarm_parent.dart' as _iiyuulin;
import 'calendar_alarm_parent_kind.dart' as _ig3zti62;
import 'calendar_alarm_plan_record.dart' as _iid4j1lu;
import 'calendar_alarm_plan_status.dart' as _irtomk7p;
import 'calendar_alarm_record.dart' as _iralscit;
import 'calendar_alarm_source_timings.dart' as _ig76ry9v;
import 'calendar_alarm_update_request.dart' as _im2lo7e9;
import 'calendar_alarm_view.dart' as _ie7u1nxa;
import 'calendar_availability_category_group.dart' as _iywbqexh;
import 'calendar_availability_class.dart' as _iucw7bzg;
import 'calendar_availability_content.dart' as _ifxxil5c;
import 'calendar_availability_create_request.dart' as _iwwk2w9d;
import 'calendar_availability_data_record.dart' as _ie9je6js;
import 'calendar_availability_export_request.dart' as _ipddbn84;
import 'calendar_availability_export_selection.dart' as _incs3y0d;
import 'calendar_availability_extension.dart' as _ip5gybl4;
import 'calendar_availability_import_baseline.dart' as _ivv22qfn;
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
import 'calendar_availability_record.dart' as _inwzhb5r;
import 'calendar_availability_replace_receipt.dart' as _iiw2d6as;
import 'calendar_availability_replace_request.dart' as _ir631vai;
import 'calendar_availability_replace_result.dart' as _itahk50i;
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
import 'calendar_cursor_record.dart' as _iptr9vfe;
import 'calendar_data_record.dart' as _ix6i00tg;
import 'calendar_event_by_day.dart' as _iq7751s4;
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_content.dart' as _id4cvk34;
import 'calendar_event_content_action.dart' as _ing6pwn6;
import 'calendar_event_content_field.dart' as _ipyf9yt3;
import 'calendar_event_create_request.dart' as _i0orp171;
import 'calendar_event_data_record.dart' as _i23wc83s;
import 'calendar_event_descriptive_metadata.dart' as _i0bvx67a;
import 'calendar_event_descriptive_request.dart' as _ibq0xtgn;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_event_export_request.dart' as _ifgpnp3a;
import 'calendar_event_export_selection.dart' as _ijug927r;
import 'calendar_event_field_group.dart' as _iftiwkuj;
import 'calendar_event_frequency.dart' as _i2q54gr5;
import 'calendar_event_future_override.dart' as _imbjv41e;
import 'calendar_event_geographic_position.dart' as _iloy79hd;
import 'calendar_event_import_baseline.dart' as _iblybidp;
import 'calendar_event_import_request.dart' as _ixo47kyf;
import 'calendar_event_import_result.dart' as _iduchdjm;
import 'calendar_event_occurrence.dart' as _isyqnyev;
import 'calendar_event_occurrence_action.dart' as _icnciyzp;
import 'calendar_event_occurrence_change.dart' as _i7imxrlz;
import 'calendar_event_occurrence_content.dart' as _io4uvjqi;
import 'calendar_event_occurrence_content_change.dart' as _iikl1ga8;
import 'calendar_event_occurrence_content_request.dart' as _iaip8d0d;
import 'calendar_event_occurrence_cursor_state.dart' as _ij33d3qn;
import 'calendar_event_occurrence_list_item.dart' as _i6x6hm0f;
import 'calendar_event_occurrence_list_query.dart' as _iayv5gu3;
import 'calendar_event_occurrence_page.dart' as _ifm4sinz;
import 'calendar_event_occurrence_preview.dart' as _i1a4s0rt;
import 'calendar_event_occurrence_protocol_version.dart' as _im5iu6ju;
import 'calendar_event_occurrence_query.dart' as _ivs4ir3j;
import 'calendar_event_origin.dart' as _ipbrznp8;
import 'calendar_event_override_protocol_state.dart' as _iml0c566;
import 'calendar_event_page.dart' as _iaayjmj1;
import 'calendar_event_protocol_state.dart' as _i8iqsbco;
import 'calendar_event_protocol_version.dart' as _iblfo3t0;
import 'calendar_event_receipt.dart' as _i500bvo7;
import 'calendar_event_record.dart' as _ilvoe14z;
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_replace_receipt.dart' as _ii1x02jx;
import 'calendar_event_replace_request.dart' as _ikx66n5r;
import 'calendar_event_replace_result.dart' as _ipzyec4h;
import 'calendar_event_resource_group.dart' as _iiajf89w;
import 'calendar_event_rule.dart' as _iovyzq1q;
import 'calendar_event_single_override.dart' as _iq1kxi25;
import 'calendar_event_source_alarm.dart' as _i4dai4jt;
import 'calendar_event_source_attachment.dart' as _i20i9qxn;
import 'calendar_event_source_category_group.dart' as _iui013s0;
import 'calendar_event_source_duration.dart' as _ie9apnqv;
import 'calendar_event_source_metadata.dart' as _ic57ts5d;
import 'calendar_event_source_participant.dart' as _iypom7ai;
import 'calendar_event_source_relationship.dart' as _iksc4ly9;
import 'calendar_event_source_text.dart' as _iwa6orjz;
import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_status_request.dart' as _i3kbbl30;
import 'calendar_event_text_metadata_request.dart' as _iswwug34;
import 'calendar_event_text_parameters.dart' as _isfojy12;
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
import 'calendar_identity_record.dart' as _ibccnfmr;
import 'calendar_image_link.dart' as _igf45b52;
import 'calendar_invitation_adoption_receipt.dart' as _ib1s0vrr;
import 'calendar_invitation_adoption_request.dart' as _imimov8l;
import 'calendar_invitation_application_record.dart' as _i29jhvb3;
import 'calendar_invitation_application_view.dart' as _i8svxjh1;
import 'calendar_invitation_apply_receipt.dart' as _ic2yh4ry;
import 'calendar_invitation_apply_request.dart' as _iivrx0vm;
import 'calendar_invitation_document.dart' as _iwcng7rp;
import 'calendar_invitation_link_record.dart' as _ibnm4ujx;
import 'calendar_invitation_occurrence_application_record.dart' as _i48y6d6c;
import 'calendar_invitation_occurrence_application_view.dart' as _i15b7t0e;
import 'calendar_invitation_occurrence_apply_receipt.dart' as _iyajy5op;
import 'calendar_invitation_occurrence_apply_request.dart' as _ioottw62;
import 'calendar_invitation_outcome.dart' as _i98zwsq8;
import 'calendar_invitation_receipt.dart' as _iy372k0z;
import 'calendar_invitation_receipt_record.dart' as _i1bc5dpy;
import 'calendar_invitation_record.dart' as _igigle43;
import 'calendar_invitation_response_activity_view.dart' as _ip5pithb;
import 'calendar_invitation_response_attempt_record.dart' as _i3vdxm7o;
import 'calendar_invitation_response_choice.dart' as _il64jj9v;
import 'calendar_invitation_response_delivery_state.dart' as _iw51ozry;
import 'calendar_invitation_response_receipt.dart' as _ig6twu0d;
import 'calendar_invitation_response_record.dart' as _iifvkijq;
import 'calendar_invitation_response_request.dart' as _iw3qnr12;
import 'calendar_invitation_response_state_record.dart' as _i5cgrgck;
import 'calendar_invitation_response_view.dart' as _irmbkh1p;
import 'calendar_invitation_source_kind.dart' as _ilccsff7;
import 'calendar_invitation_source_record.dart' as _i3yqoryt;
import 'calendar_invitation_source_view.dart' as _itix6re9;
import 'calendar_invitation_view.dart' as _ifs5c7mj;
import 'calendar_item_category_group.dart' as _i3iolgr8;
import 'calendar_item_comment.dart' as _itx19m90;
import 'calendar_item_text_metadata_field.dart' as _i12tuyl5;
import 'calendar_item_text_metadata_patch.dart' as _ikwi9ryb;
import 'calendar_metadata_update_request.dart' as _i759fw3a;
import 'calendar_mutation_receipt.dart' as _iq0eskk0;
import 'calendar_no_rule_fallback.dart' as _itts4qyp;
import 'calendar_page.dart' as _i0jfcg0j;
import 'calendar_presentation_update_request.dart' as _i9m9yk5s;
import 'calendar_protocol_identity.dart' as _iyrimg3m;
import 'calendar_protocol_metadata.dart' as _itchuj1l;
import 'calendar_protocol_metadata_update_request.dart' as _iyawor89;
import 'calendar_refresh_hint.dart' as _ifsfk5xq;
import 'calendar_scheduling_attempt_record.dart' as _i64utb1e;
import 'calendar_scheduling_attendee_response_record.dart' as _i577nx0c;
import 'calendar_scheduling_attendee_response_view.dart' as _itopoldj;
import 'calendar_scheduling_cancel_request.dart' as _i4uu6f5m;
import 'calendar_scheduling_delivery_record.dart' as _iuidcanh;
import 'calendar_scheduling_delivery_state.dart' as _it5jr5tm;
import 'calendar_scheduling_delivery_view.dart' as _i63ky642;
import 'calendar_scheduling_instance_responses_view.dart' as _i8yevrne;
import 'calendar_scheduling_meeting_record.dart' as _ihlqfuoo;
import 'calendar_scheduling_occurrence_cancel_request.dart' as _ia8x0otq;
import 'calendar_scheduling_occurrence_restore_request.dart' as _io2t7cny;
import 'calendar_scheduling_participation.dart' as _iot0xi24;
import 'calendar_scheduling_publication_kind.dart' as _il38fbb4;
import 'calendar_scheduling_publication_record.dart' as _ivo2647b;
import 'calendar_scheduling_receipt.dart' as _izftntkw;
import 'calendar_scheduling_reopen_request.dart' as _iv2f51nm;
import 'calendar_scheduling_reply_document.dart' as _iqen8jmy;
import 'calendar_scheduling_reply_outcome.dart' as _ikqvfn4d;
import 'calendar_scheduling_reply_receipt.dart' as _iwdevo6h;
import 'calendar_scheduling_reply_receipt_record.dart' as _i0njii35;
import 'calendar_scheduling_reply_source_record.dart' as _ia855khw;
import 'calendar_scheduling_reply_source_view.dart' as _i2peuvqu;
import 'calendar_scheduling_responses_view.dart' as _ixbxcx0r;
import 'calendar_scheduling_save_request.dart' as _icabxeyo;
import 'calendar_scheduling_view.dart' as _is73suzs;
import 'calendar_scope_record.dart' as _i9mvj7kq;
import 'calendar_settings_update_request.dart' as _i66us6t1;
import 'calendar_subject_action.dart' as _i41idnki;
import 'calendar_subject_availability.dart' as _imo3vsmf;
import 'calendar_subject_change_request.dart' as _iuzjb8ji;
import 'calendar_subject_record.dart' as _i76vfrve;
import 'calendar_subject_view.dart' as _ir7mv910;
import 'calendar_supplemental_metadata.dart' as _ixppc388;
import 'calendar_supplemental_metadata_update_request.dart' as _iqx8dg15;
import 'calendar_task_assignee.dart' as _ih5e3u6u;
import 'calendar_task_assignments_request.dart' as _ipa1soge;
import 'calendar_task_content.dart' as _if7nbvl8;
import 'calendar_task_content_action.dart' as _ihwe765g;
import 'calendar_task_content_field.dart' as _i496rta0;
import 'calendar_task_create_request.dart' as _iipxdkwq;
import 'calendar_task_data_record.dart' as _ic8eedzw;
import 'calendar_task_export_request.dart' as _i10340hl;
import 'calendar_task_export_selection.dart' as _i71mi7ri;
import 'calendar_task_field_group.dart' as _isemqyyv;
import 'calendar_task_history_entry.dart' as _idhalyap;
import 'calendar_task_history_page.dart' as _ibsdsx6x;
import 'calendar_task_history_query.dart' as _i1vdb6de;
import 'calendar_task_history_record.dart' as _i6c7wo1p;
import 'calendar_task_import_baseline.dart' as _iqsm27bn;
import 'calendar_task_import_request.dart' as _isw8fcv3;
import 'calendar_task_import_result.dart' as _izrxa9vy;
import 'calendar_task_occurrence.dart' as _isgg83d3;
import 'calendar_task_occurrence_content.dart' as _irmu5f0n;
import 'calendar_task_occurrence_content_change.dart' as _isfljanw;
import 'calendar_task_occurrence_content_request.dart' as _iw338tmt;
import 'calendar_task_occurrence_preview.dart' as _id9j5e7y;
import 'calendar_task_occurrence_progress_request.dart' as _irw24ank;
import 'calendar_task_occurrence_query.dart' as _ixy579wj;
import 'calendar_task_occurrence_record.dart' as _i3t5ry4r;
import 'calendar_task_occurrence_timing_request.dart' as _ii9v7kdj;
import 'calendar_task_page.dart' as _i276ujfk;
import 'calendar_task_progress.dart' as _ikcsq95s;
import 'calendar_task_progress_action.dart' as _i6s7yrua;
import 'calendar_task_progress_request.dart' as _in6zlsph;
import 'calendar_task_protocol_version.dart' as _iz9t6x1i;
import 'calendar_task_receipt.dart' as _im9usybn;
import 'calendar_task_record.dart' as _irbiaacf;
import 'calendar_task_replace_receipt.dart' as _ib5z6spp;
import 'calendar_task_replace_request.dart' as _ibpx2vjc;
import 'calendar_task_replace_result.dart' as _iyf2qeht;
import 'calendar_task_source_alarm.dart' as _i00avof0;
import 'calendar_task_source_attachment.dart' as _iuzk4pe3;
import 'calendar_task_source_category_group.dart' as _iic8eifm;
import 'calendar_task_source_component.dart' as _ivqadd6c;
import 'calendar_task_source_duration.dart' as _im8khkr9;
import 'calendar_task_source_metadata.dart' as _i76q6myt;
import 'calendar_task_source_participant.dart' as _iw6fme2j;
import 'calendar_task_source_relationship.dart' as _izyrs4yl;
import 'calendar_task_source_state.dart' as _it1pm24a;
import 'calendar_task_source_text.dart' as _i9mnuab5;
import 'calendar_task_status.dart' as _iiahrdev;
import 'calendar_task_text_metadata_request.dart' as _it8lhctx;
import 'calendar_task_time_kind.dart' as _ijhc2xsq;
import 'calendar_task_timing.dart' as _i9h8y8lg;
import 'calendar_task_update_request.dart' as _in7cuxyg;
import 'calendar_task_view.dart' as _ii3yrr21;
import 'calendar_text_parameters.dart' as _iffxqqc7;
import 'calendar_text_variant.dart' as _itcy22f3;
import 'calendar_view.dart' as _ivspd2q7;
export 'calendar_alarm_action_kind.dart';
export 'calendar_alarm_action_record.dart';
export 'calendar_alarm_action_request.dart';
export 'calendar_alarm_action_view.dart';
export 'calendar_alarm_activity_kind.dart';
export 'calendar_alarm_activity_page.dart';
export 'calendar_alarm_anchor.dart';
export 'calendar_alarm_create_request.dart';
export 'calendar_alarm_definition.dart';
export 'calendar_alarm_duration.dart';
export 'calendar_alarm_firing_kind.dart';
export 'calendar_alarm_firing_record.dart';
export 'calendar_alarm_firing_state.dart';
export 'calendar_alarm_firing_view.dart';
export 'calendar_alarm_parent.dart';
export 'calendar_alarm_parent_kind.dart';
export 'calendar_alarm_plan_record.dart';
export 'calendar_alarm_plan_status.dart';
export 'calendar_alarm_record.dart';
export 'calendar_alarm_source_timings.dart';
export 'calendar_alarm_update_request.dart';
export 'calendar_alarm_view.dart';
export 'calendar_availability_category_group.dart';
export 'calendar_availability_class.dart';
export 'calendar_availability_content.dart';
export 'calendar_availability_create_request.dart';
export 'calendar_availability_data_record.dart';
export 'calendar_availability_export_request.dart';
export 'calendar_availability_export_selection.dart';
export 'calendar_availability_extension.dart';
export 'calendar_availability_import_baseline.dart';
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
export 'calendar_availability_record.dart';
export 'calendar_availability_replace_receipt.dart';
export 'calendar_availability_replace_request.dart';
export 'calendar_availability_replace_result.dart';
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
export 'calendar_cursor_record.dart';
export 'calendar_data_record.dart';
export 'calendar_event_by_day.dart';
export 'calendar_event_civil.dart';
export 'calendar_event_content.dart';
export 'calendar_event_content_action.dart';
export 'calendar_event_content_field.dart';
export 'calendar_event_create_request.dart';
export 'calendar_event_data_record.dart';
export 'calendar_event_descriptive_metadata.dart';
export 'calendar_event_descriptive_request.dart';
export 'calendar_event_duration.dart';
export 'calendar_event_export_request.dart';
export 'calendar_event_export_selection.dart';
export 'calendar_event_field_group.dart';
export 'calendar_event_frequency.dart';
export 'calendar_event_future_override.dart';
export 'calendar_event_geographic_position.dart';
export 'calendar_event_import_baseline.dart';
export 'calendar_event_import_request.dart';
export 'calendar_event_import_result.dart';
export 'calendar_event_occurrence.dart';
export 'calendar_event_occurrence_action.dart';
export 'calendar_event_occurrence_change.dart';
export 'calendar_event_occurrence_content.dart';
export 'calendar_event_occurrence_content_change.dart';
export 'calendar_event_occurrence_content_request.dart';
export 'calendar_event_occurrence_cursor_state.dart';
export 'calendar_event_occurrence_list_item.dart';
export 'calendar_event_occurrence_list_query.dart';
export 'calendar_event_occurrence_page.dart';
export 'calendar_event_occurrence_preview.dart';
export 'calendar_event_occurrence_protocol_version.dart';
export 'calendar_event_occurrence_query.dart';
export 'calendar_event_origin.dart';
export 'calendar_event_override_protocol_state.dart';
export 'calendar_event_page.dart';
export 'calendar_event_protocol_state.dart';
export 'calendar_event_protocol_version.dart';
export 'calendar_event_receipt.dart';
export 'calendar_event_record.dart';
export 'calendar_event_recurrence.dart';
export 'calendar_event_replace_receipt.dart';
export 'calendar_event_replace_request.dart';
export 'calendar_event_replace_result.dart';
export 'calendar_event_resource_group.dart';
export 'calendar_event_rule.dart';
export 'calendar_event_single_override.dart';
export 'calendar_event_source_alarm.dart';
export 'calendar_event_source_attachment.dart';
export 'calendar_event_source_category_group.dart';
export 'calendar_event_source_duration.dart';
export 'calendar_event_source_metadata.dart';
export 'calendar_event_source_participant.dart';
export 'calendar_event_source_relationship.dart';
export 'calendar_event_source_text.dart';
export 'calendar_event_status.dart';
export 'calendar_event_status_request.dart';
export 'calendar_event_text_metadata_request.dart';
export 'calendar_event_text_parameters.dart';
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
export 'calendar_identity_record.dart';
export 'calendar_image_link.dart';
export 'calendar_invitation_adoption_receipt.dart';
export 'calendar_invitation_adoption_request.dart';
export 'calendar_invitation_application_record.dart';
export 'calendar_invitation_application_view.dart';
export 'calendar_invitation_apply_receipt.dart';
export 'calendar_invitation_apply_request.dart';
export 'calendar_invitation_document.dart';
export 'calendar_invitation_link_record.dart';
export 'calendar_invitation_occurrence_application_record.dart';
export 'calendar_invitation_occurrence_application_view.dart';
export 'calendar_invitation_occurrence_apply_receipt.dart';
export 'calendar_invitation_occurrence_apply_request.dart';
export 'calendar_invitation_outcome.dart';
export 'calendar_invitation_receipt.dart';
export 'calendar_invitation_receipt_record.dart';
export 'calendar_invitation_record.dart';
export 'calendar_invitation_response_activity_view.dart';
export 'calendar_invitation_response_attempt_record.dart';
export 'calendar_invitation_response_choice.dart';
export 'calendar_invitation_response_delivery_state.dart';
export 'calendar_invitation_response_receipt.dart';
export 'calendar_invitation_response_record.dart';
export 'calendar_invitation_response_request.dart';
export 'calendar_invitation_response_state_record.dart';
export 'calendar_invitation_response_view.dart';
export 'calendar_invitation_source_kind.dart';
export 'calendar_invitation_source_record.dart';
export 'calendar_invitation_source_view.dart';
export 'calendar_invitation_view.dart';
export 'calendar_item_category_group.dart';
export 'calendar_item_comment.dart';
export 'calendar_item_text_metadata_field.dart';
export 'calendar_item_text_metadata_patch.dart';
export 'calendar_metadata_update_request.dart';
export 'calendar_mutation_receipt.dart';
export 'calendar_no_rule_fallback.dart';
export 'calendar_page.dart';
export 'calendar_presentation_update_request.dart';
export 'calendar_protocol_identity.dart';
export 'calendar_protocol_metadata.dart';
export 'calendar_protocol_metadata_update_request.dart';
export 'calendar_refresh_hint.dart';
export 'calendar_scheduling_attempt_record.dart';
export 'calendar_scheduling_attendee_response_record.dart';
export 'calendar_scheduling_attendee_response_view.dart';
export 'calendar_scheduling_cancel_request.dart';
export 'calendar_scheduling_delivery_record.dart';
export 'calendar_scheduling_delivery_state.dart';
export 'calendar_scheduling_delivery_view.dart';
export 'calendar_scheduling_instance_responses_view.dart';
export 'calendar_scheduling_meeting_record.dart';
export 'calendar_scheduling_occurrence_cancel_request.dart';
export 'calendar_scheduling_occurrence_restore_request.dart';
export 'calendar_scheduling_participation.dart';
export 'calendar_scheduling_publication_kind.dart';
export 'calendar_scheduling_publication_record.dart';
export 'calendar_scheduling_receipt.dart';
export 'calendar_scheduling_reopen_request.dart';
export 'calendar_scheduling_reply_document.dart';
export 'calendar_scheduling_reply_outcome.dart';
export 'calendar_scheduling_reply_receipt.dart';
export 'calendar_scheduling_reply_receipt_record.dart';
export 'calendar_scheduling_reply_source_record.dart';
export 'calendar_scheduling_reply_source_view.dart';
export 'calendar_scheduling_responses_view.dart';
export 'calendar_scheduling_save_request.dart';
export 'calendar_scheduling_view.dart';
export 'calendar_scope_record.dart';
export 'calendar_settings_update_request.dart';
export 'calendar_subject_action.dart';
export 'calendar_subject_availability.dart';
export 'calendar_subject_change_request.dart';
export 'calendar_subject_record.dart';
export 'calendar_subject_view.dart';
export 'calendar_supplemental_metadata.dart';
export 'calendar_supplemental_metadata_update_request.dart';
export 'calendar_task_assignee.dart';
export 'calendar_task_assignments_request.dart';
export 'calendar_task_content.dart';
export 'calendar_task_content_action.dart';
export 'calendar_task_content_field.dart';
export 'calendar_task_create_request.dart';
export 'calendar_task_data_record.dart';
export 'calendar_task_export_request.dart';
export 'calendar_task_export_selection.dart';
export 'calendar_task_field_group.dart';
export 'calendar_task_history_entry.dart';
export 'calendar_task_history_page.dart';
export 'calendar_task_history_query.dart';
export 'calendar_task_history_record.dart';
export 'calendar_task_import_baseline.dart';
export 'calendar_task_import_request.dart';
export 'calendar_task_import_result.dart';
export 'calendar_task_occurrence.dart';
export 'calendar_task_occurrence_content.dart';
export 'calendar_task_occurrence_content_change.dart';
export 'calendar_task_occurrence_content_request.dart';
export 'calendar_task_occurrence_preview.dart';
export 'calendar_task_occurrence_progress_request.dart';
export 'calendar_task_occurrence_query.dart';
export 'calendar_task_occurrence_record.dart';
export 'calendar_task_occurrence_timing_request.dart';
export 'calendar_task_page.dart';
export 'calendar_task_progress.dart';
export 'calendar_task_progress_action.dart';
export 'calendar_task_progress_request.dart';
export 'calendar_task_protocol_version.dart';
export 'calendar_task_receipt.dart';
export 'calendar_task_record.dart';
export 'calendar_task_replace_receipt.dart';
export 'calendar_task_replace_request.dart';
export 'calendar_task_replace_result.dart';
export 'calendar_task_source_alarm.dart';
export 'calendar_task_source_attachment.dart';
export 'calendar_task_source_category_group.dart';
export 'calendar_task_source_component.dart';
export 'calendar_task_source_duration.dart';
export 'calendar_task_source_metadata.dart';
export 'calendar_task_source_participant.dart';
export 'calendar_task_source_relationship.dart';
export 'calendar_task_source_state.dart';
export 'calendar_task_source_text.dart';
export 'calendar_task_status.dart';
export 'calendar_task_text_metadata_request.dart';
export 'calendar_task_time_kind.dart';
export 'calendar_task_timing.dart';
export 'calendar_task_update_request.dart';
export 'calendar_task_view.dart';
export 'calendar_text_parameters.dart';
export 'calendar_text_variant.dart';
export 'calendar_view.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_is.SerializationManager> _hostProtocols = {};

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'serverpod_calendar_alarm',
      dartName: 'CalendarAlarmRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'parentKind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarAlarmParentKind',
        ),
        _isp.ColumnDefinition(
          name: 'parentId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'recipientNamespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'armed',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'generation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'definition',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarAlarmDefinition',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_alarm_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_private_parent_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'parentKind',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'parentId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientNamespace',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_alarm_action',
      dartName: 'CalendarAlarmActionRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'alarmId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'originalKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'resetAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'acknowledgedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'dismissedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'pendingSnoozeAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'snoozeRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_alarm_action_fk_0',
          columns: ['alarmId'],
          referenceTable: 'serverpod_calendar_alarm',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_action_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'alarmId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'originalKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_alarm_firing',
      dartName: 'CalendarAlarmFiringRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'alarmId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'generation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'originalKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarAlarmFiringKind',
        ),
        _isp.ColumnDefinition(
          name: 'repeatOrdinal',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'snoozeRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'dueAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarAlarmFiringState',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'attemptCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'acceptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'terminalAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseOwner',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseFence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_alarm_firing_fk_0',
          columns: ['alarmId'],
          referenceTable: 'serverpod_calendar_alarm',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_firing_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'alarmId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'generation',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'originalKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'kind',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'repeatOrdinal',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'snoozeRevision',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_firing_due_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'state',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextAttemptAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'leaseUntil',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_firing_terminal_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'terminalAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_alarm_plan',
      dartName: 'CalendarAlarmPlanRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'alarmId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'generation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'timingDigest',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'windowStart',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'windowEnd',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarAlarmPlanStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'dirty',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'nextScanAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'lastCompletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseOwner',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseFence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_alarm_plan_fk_0',
          columns: ['alarmId'],
          referenceTable: 'serverpod_calendar_alarm',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_plan_alarm_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'alarmId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_plan_due_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextScanAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'leaseUntil',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_alarm_plan_scope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_availability',
      dartName: 'CalendarAvailabilityRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_availability_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_availability_parent_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_availability_data',
      dartName: 'CalendarAvailabilityDataRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'availabilityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'protocolUid',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'uidDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'protocolState',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarAvailabilityProtocolState?',
        ),
        _isp.ColumnDefinition(
          name: 'importBaseline',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarAvailabilityImportBaseline?',
        ),
        _isp.ColumnDefinition(
          name: 'timingOverrides',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<protocol:CalendarAvailabilityOpeningEdits>?',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarAvailabilityContent',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_availability_data_fk_0',
          columns: ['availabilityId'],
          referenceTable: 'serverpod_calendar_availability',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_availability_data_fk_1',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_availability_data_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'availabilityId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_availability_data_uid_candidates',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'uidDigest',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_cursor',
      dartName: 'CalendarCursorRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'principalId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'policyRevision',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'dataRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'afterId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'pageSize',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'fieldGroups',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:CalendarFieldGroup>',
        ),
        _isp.ColumnDefinition(
          name: 'taskCalendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'taskFieldGroups',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<protocol:CalendarTaskFieldGroup>?',
        ),
        _isp.ColumnDefinition(
          name: 'eventCalendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'eventFieldGroups',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<protocol:CalendarEventFieldGroup>?',
        ),
        _isp.ColumnDefinition(
          name: 'eventOccurrenceState',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarEventOccurrenceCursorState?',
        ),
        _isp.ColumnDefinition(
          name: 'categoryFilter',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarCategoryFilter?',
        ),
        _isp.ColumnDefinition(
          name: 'alarmActivityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'alarmActivityKind',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:CalendarAlarmActivityKind?',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'taskHistoryTaskId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'taskHistoryOriginalKey',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'taskHistoryAfterRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_cursor_token_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_cursor_expiry_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_data',
      dartName: 'CalendarDataRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'protocolUid',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'color',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'availabilityZoneId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'noRuleFallback',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarNoRuleFallback',
        ),
        _isp.ColumnDefinition(
          name: 'protocolMetadata',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarProtocolMetadata?',
        ),
        _isp.ColumnDefinition(
          name: 'supplementalMetadata',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarSupplementalMetadata?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_data_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_data_protocol_uid_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'protocolUid',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_data_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_event',
      dartName: 'CalendarEventRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_event_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_event_parent_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_event_data',
      dartName: 'CalendarEventDataRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'eventId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'origin',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarEventOrigin',
          columnDefault: '\'unknown\'',
        ),
        _isp.ColumnDefinition(
          name: 'protocolUid',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'uidDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'protocolState',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarEventProtocolState?',
        ),
        _isp.ColumnDefinition(
          name: 'importBaseline',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarEventImportBaseline?',
        ),
        _isp.ColumnDefinition(
          name: 'timingOverrides',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarEventTimingOverrides?',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarEventContent',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_event_data_fk_0',
          columns: ['eventId'],
          referenceTable: 'serverpod_calendar_event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_event_data_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_event_data_uid_candidates',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'uidDigest',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_identity',
      dartName: 'CalendarIdentityRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_identity_scope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation',
      dartName: 'CalendarInvitationRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationSourceKind',
          columnDefault: '\'request\'',
        ),
        _isp.ColumnDefinition(
          name: 'recurring',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'correlationDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'targetKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'master\'',
        ),
        _isp.ColumnDefinition(
          name: 'originalStart',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarEventTiming?',
        ),
        _isp.ColumnDefinition(
          name: 'uid',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'organizer',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currentSourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'digest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'dismissedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_correlation_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'correlationDigest',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'targetKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_recipient_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_application',
      dartName: 'CalendarInvitationApplicationRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationSourceKind',
          columnDefault: '\'request\'',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'linkId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'invitationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'digest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'baselineDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'creationDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'invitationRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'appliedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'requestDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'resultId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_application_fk_0',
          columns: ['linkId'],
          referenceTable: 'serverpod_calendar_invitation_link',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_application_link_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'linkId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_link',
      dartName: 'CalendarInvitationLinkRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'uid',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'organizer',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'correlationDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'invitationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sourceDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'eventId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'requestDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'invitationRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'adoptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_link_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_link_fk_1',
          columns: ['eventId'],
          referenceTable: 'serverpod_calendar_event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_link_correlation_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'correlationDigest',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_link_original_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'invitationId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_link_event_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_occurrence_application',
      dartName: 'CalendarInvitationOccurrenceApplicationRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'linkId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'stateJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName:
              'serverpod_calendar_invitation_occurrence_application_fk_0',
          columns: ['linkId'],
          referenceTable: 'serverpod_calendar_invitation_link',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_occurrence_application_link_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'linkId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_receipt',
      dartName: 'CalendarInvitationReceiptRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ingressDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'originDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationOutcome',
        ),
        _isp.ColumnDefinition(
          name: 'entryRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_receipt_fk_0',
          columns: ['sourceId'],
          referenceTable: 'serverpod_calendar_invitation_source',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_receipt_key_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ingressDigest',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_receipt_source_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_receipt_expiry_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_response',
      dartName: 'CalendarInvitationResponseRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'stateId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'entryId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'commandId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'criteriaDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'request',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationResponseRequest',
        ),
        _isp.ColumnDefinition(
          name: 'receipt',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationResponseReceipt',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sourceRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sourceDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sourceSequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'sourceStamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'recipientAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'organizerAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'authorityRef',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'routeRef',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'generation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'choice',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationResponseChoice',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'payload',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payloadDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'byteCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationResponseDeliveryState',
          columnDefault: '\'queued\'',
        ),
        _isp.ColumnDefinition(
          name: 'attemptCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'leaseOwner',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseToken',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseFence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'terminalAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'resultCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_response_fk_0',
          columns: ['stateId'],
          referenceTable: 'serverpod_calendar_invitation_response_state',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_response_fk_1',
          columns: ['entryId'],
          referenceTable: 'serverpod_calendar_invitation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_response_fk_2',
          columns: ['sourceId'],
          referenceTable: 'serverpod_calendar_invitation_source',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_response_command_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'commandId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_response_due_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'terminalAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextAttemptAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'leaseUntil',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_response_recipient_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'stateId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_response_attempt',
      dartName: 'CalendarInvitationResponseAttemptRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'responseId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'attemptNumber',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'leaseToken',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'leaseFence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'startedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'finishedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'adapterReceipt',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'resultCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_response_attempt_fk_0',
          columns: ['responseId'],
          referenceTable: 'serverpod_calendar_invitation_response',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_response_attempt_number_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'responseId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'attemptNumber',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_response_state',
      dartName: 'CalendarInvitationResponseStateRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entryId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'recipientAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'latestResponseId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'lastStamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'choice',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationResponseChoice',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sourceRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sourceDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sourceSequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'sourceStamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationResponseDeliveryState',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_response_state_fk_0',
          columns: ['entryId'],
          referenceTable: 'serverpod_calendar_invitation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_response_state_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entryId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_response_state_scope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_invitation_source',
      dartName: 'CalendarInvitationSourceRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'entryId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'normalizedSource',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'byteCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'digest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarInvitationOutcome',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'inactiveAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_invitation_source_fk_0',
          columns: ['entryId'],
          referenceTable: 'serverpod_calendar_invitation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_source_digest_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entryId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'digest',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_invitation_source_entry_time_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entryId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'inactiveAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scheduling_attempt',
      dartName: 'CalendarSchedulingAttemptRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'attemptNumber',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'leaseToken',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'leaseFence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'startedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'finishedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'adapterReceipt',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'resultCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_scheduling_attempt_fk_0',
          columns: ['deliveryId'],
          referenceTable: 'serverpod_calendar_scheduling_delivery',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_attempt_number_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deliveryId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'attemptNumber',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scheduling_attendee_response',
      dartName: 'CalendarSchedulingAttendeeResponseRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'meetingId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'attendeeAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'targetKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'master\'',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'sourceParticipation',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:CalendarSchedulingParticipation?',
        ),
        _isp.ColumnDefinition(
          name: 'effectiveParticipation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarSchedulingParticipation',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName:
              'serverpod_calendar_scheduling_attendee_response_fk_0',
          columns: ['meetingId'],
          referenceTable: 'serverpod_calendar_scheduling_meeting',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName:
              'serverpod_calendar_scheduling_attendee_response_fk_1',
          columns: ['sourceId'],
          referenceTable: 'serverpod_calendar_scheduling_reply_source',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_attendee_response_address_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'meetingId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'attendeeAddress',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'targetKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_attendee_response_source_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_attendee_response_scope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scheduling_delivery',
      dartName: 'CalendarSchedulingDeliveryRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'publicationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'recipientAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'routeRef',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryKey',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarSchedulingDeliveryState',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'attemptCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'leaseOwner',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseToken',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseFence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'terminalAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'resultCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_scheduling_delivery_fk_0',
          columns: ['publicationId'],
          referenceTable: 'serverpod_calendar_scheduling_publication',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_delivery_recipient_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'publicationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientAddress',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_delivery_key_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deliveryKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_delivery_due_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'state',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextAttemptAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'leaseUntil',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_delivery_scope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'terminalAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scheduling_meeting',
      dartName: 'CalendarSchedulingMeetingRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'eventId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'organizerAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'authorityRef',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'generation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'latestPublicationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_scheduling_meeting_fk_0',
          columns: ['eventId'],
          referenceTable: 'serverpod_calendar_event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_meeting_event_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_meeting_scope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scheduling_publication',
      dartName: 'CalendarSchedulingPublicationRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'meetingId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'generation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'method',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'protocolUid',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'snapshot',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'projection',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payload',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payloadDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipients',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<String>',
        ),
        _isp.ColumnDefinition(
          name: 'commandId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'actorId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expectedRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'eventRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'completedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_scheduling_publication_fk_0',
          columns: ['meetingId'],
          referenceTable: 'serverpod_calendar_scheduling_meeting',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_publication_generation_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'meetingId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'generation',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_publication_command_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'commandId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_scheduling_publication_cleanup_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'completedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scheduling_reply_receipt',
      dartName: 'CalendarSchedulingReplyReceiptRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'meetingId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'ingressDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarSchedulingReplyOutcome',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_scheduling_reply_receipt_fk_0',
          columns: ['meetingId'],
          referenceTable: 'serverpod_calendar_scheduling_meeting',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_scheduling_reply_receipt_fk_1',
          columns: ['sourceId'],
          referenceTable: 'serverpod_calendar_scheduling_reply_source',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_reply_receipt_key_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'meetingId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ingressDigest',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_reply_receipt_source_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_reply_receipt_scope_time_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'receivedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scheduling_reply_source',
      dartName: 'CalendarSchedulingReplySourceRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'meetingId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'attendeeAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'targetKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'master\'',
        ),
        _isp.ColumnDefinition(
          name: 'originalStart',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarEventTiming?',
        ),
        _isp.ColumnDefinition(
          name: 'targetBasisKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'master\'',
        ),
        _isp.ColumnDefinition(
          name: 'digest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'normalizedSource',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'stamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'sourceParticipation',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:CalendarSchedulingParticipation?',
        ),
        _isp.ColumnDefinition(
          name: 'effectiveParticipation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarSchedulingParticipation',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarSchedulingReplyOutcome',
        ),
        _isp.ColumnDefinition(
          name: 'publishedSequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'publishedCancelled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'inactiveAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_scheduling_reply_source_fk_0',
          columns: ['meetingId'],
          referenceTable: 'serverpod_calendar_scheduling_meeting',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_reply_source_message_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'meetingId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'attendeeAddress',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'digest',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_reply_source_scope_inactive_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'inactiveAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_scope',
      dartName: 'CalendarScopeRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_scope_key_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_subject',
      dartName: 'CalendarSubjectRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'namespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'externalId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'contributesAvailability',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_subject_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_subject_tuple_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'namespace',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'kind',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'externalId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_task',
      dartName: 'CalendarTaskRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_task_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_task_parent_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_task_data',
      dartName: 'CalendarTaskDataRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'taskId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'protocolUid',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'uidDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'protocolVersion',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarTaskProtocolVersion',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarTaskContent',
        ),
        _isp.ColumnDefinition(
          name: 'progress',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarTaskProgress',
        ),
        _isp.ColumnDefinition(
          name: 'assignees',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:CalendarTaskAssignee>',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'hasRecordedProgress',
          columnType: _isp.ColumnType.boolean,
          isNullable: true,
          dartType: 'bool?',
        ),
        _isp.ColumnDefinition(
          name: 'sourceState',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarTaskSourceState?',
        ),
        _isp.ColumnDefinition(
          name: 'importBaseline',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarTaskImportBaseline?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_task_data_fk_0',
          columns: ['taskId'],
          referenceTable: 'serverpod_calendar_task',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_task_data_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'taskId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_task_data_uid_candidates',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'uidDigest',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_task_history',
      dartName: 'CalendarTaskHistoryRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'taskId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'originalKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'originalStart',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarEventTiming',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarTaskProgressAction',
        ),
        _isp.ColumnDefinition(
          name: 'before',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarTaskProgress',
        ),
        _isp.ColumnDefinition(
          name: 'after',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarTaskProgress',
        ),
        _isp.ColumnDefinition(
          name: 'recordedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_task_history_fk_0',
          columns: ['taskId'],
          referenceTable: 'serverpod_calendar_task',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_task_history_revision_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'taskId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_task_history_original_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'taskId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'originalKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_task_occurrence',
      dartName: 'CalendarTaskOccurrenceRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'taskId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'originalKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'originalStart',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarEventTiming',
        ),
        _isp.ColumnDefinition(
          name: 'replacementTiming',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarTaskTiming?',
        ),
        _isp.ColumnDefinition(
          name: 'futureTiming',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarTaskTiming?',
        ),
        _isp.ColumnDefinition(
          name: 'contentOverrides',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarTaskOccurrenceContent?',
        ),
        _isp.ColumnDefinition(
          name: 'progress',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarTaskProgress',
        ),
        _isp.ColumnDefinition(
          name: 'protocolVersion',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarTaskProtocolVersion?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_task_occurrence_fk_0',
          columns: ['taskId'],
          referenceTable: 'serverpod_calendar_task',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_task_occurrence_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'taskId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'originalKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._ik9lwgjh.Protocol.targetTableDefinitions,
  ];

  void registerHostProtocol(
    String projectName,
    _is.SerializationManager protocol,
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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ihv8htej.CalendarAlarmActionKind) {
      return _ihv8htej.CalendarAlarmActionKind.fromJson(data) as T;
    }
    if (t == _ipt2851n.CalendarAlarmActionRecord) {
      return _ipt2851n.CalendarAlarmActionRecord.fromJson(data) as T;
    }
    if (t == _ivvkdcds.CalendarAlarmActionRequest) {
      return _ivvkdcds.CalendarAlarmActionRequest.fromJson(data) as T;
    }
    if (t == _ixqjnkie.CalendarAlarmActionView) {
      return _ixqjnkie.CalendarAlarmActionView.fromJson(data) as T;
    }
    if (t == _ik5ajwd4.CalendarAlarmActivityKind) {
      return _ik5ajwd4.CalendarAlarmActivityKind.fromJson(data) as T;
    }
    if (t == _iruhg2yq.CalendarAlarmActivityPage) {
      return _iruhg2yq.CalendarAlarmActivityPage.fromJson(data) as T;
    }
    if (t == _iv448ru6.CalendarAlarmAnchor) {
      return _iv448ru6.CalendarAlarmAnchor.fromJson(data) as T;
    }
    if (t == _iu47syqa.CalendarAlarmCreateRequest) {
      return _iu47syqa.CalendarAlarmCreateRequest.fromJson(data) as T;
    }
    if (t == _irif99jb.CalendarAlarmDefinition) {
      return _irif99jb.CalendarAlarmDefinition.fromJson(data) as T;
    }
    if (t == _i1qnv8jf.CalendarAlarmDuration) {
      return _i1qnv8jf.CalendarAlarmDuration.fromJson(data) as T;
    }
    if (t == _i8okwxwj.CalendarAlarmFiringKind) {
      return _i8okwxwj.CalendarAlarmFiringKind.fromJson(data) as T;
    }
    if (t == _ihgh57kq.CalendarAlarmFiringRecord) {
      return _ihgh57kq.CalendarAlarmFiringRecord.fromJson(data) as T;
    }
    if (t == _ihos0r46.CalendarAlarmFiringState) {
      return _ihos0r46.CalendarAlarmFiringState.fromJson(data) as T;
    }
    if (t == _i7xuciin.CalendarAlarmFiringView) {
      return _i7xuciin.CalendarAlarmFiringView.fromJson(data) as T;
    }
    if (t == _iiyuulin.CalendarAlarmParent) {
      return _iiyuulin.CalendarAlarmParent.fromJson(data) as T;
    }
    if (t == _ig3zti62.CalendarAlarmParentKind) {
      return _ig3zti62.CalendarAlarmParentKind.fromJson(data) as T;
    }
    if (t == _iid4j1lu.CalendarAlarmPlanRecord) {
      return _iid4j1lu.CalendarAlarmPlanRecord.fromJson(data) as T;
    }
    if (t == _irtomk7p.CalendarAlarmPlanStatus) {
      return _irtomk7p.CalendarAlarmPlanStatus.fromJson(data) as T;
    }
    if (t == _iralscit.CalendarAlarmRecord) {
      return _iralscit.CalendarAlarmRecord.fromJson(data) as T;
    }
    if (t == _ig76ry9v.CalendarAlarmSourceTimings) {
      return _ig76ry9v.CalendarAlarmSourceTimings.fromJson(data) as T;
    }
    if (t == _im2lo7e9.CalendarAlarmUpdateRequest) {
      return _im2lo7e9.CalendarAlarmUpdateRequest.fromJson(data) as T;
    }
    if (t == _ie7u1nxa.CalendarAlarmView) {
      return _ie7u1nxa.CalendarAlarmView.fromJson(data) as T;
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
    if (t == _ie9je6js.CalendarAvailabilityDataRecord) {
      return _ie9je6js.CalendarAvailabilityDataRecord.fromJson(data) as T;
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
    if (t == _ivv22qfn.CalendarAvailabilityImportBaseline) {
      return _ivv22qfn.CalendarAvailabilityImportBaseline.fromJson(data) as T;
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
    if (t == _inwzhb5r.CalendarAvailabilityRecord) {
      return _inwzhb5r.CalendarAvailabilityRecord.fromJson(data) as T;
    }
    if (t == _iiw2d6as.CalendarAvailabilityReplaceReceipt) {
      return _iiw2d6as.CalendarAvailabilityReplaceReceipt.fromJson(data) as T;
    }
    if (t == _ir631vai.CalendarAvailabilityReplaceRequest) {
      return _ir631vai.CalendarAvailabilityReplaceRequest.fromJson(data) as T;
    }
    if (t == _itahk50i.CalendarAvailabilityReplaceResult) {
      return _itahk50i.CalendarAvailabilityReplaceResult.fromJson(data) as T;
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
    if (t == _iptr9vfe.CalendarCursorRecord) {
      return _iptr9vfe.CalendarCursorRecord.fromJson(data) as T;
    }
    if (t == _ix6i00tg.CalendarDataRecord) {
      return _ix6i00tg.CalendarDataRecord.fromJson(data) as T;
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
    if (t == _ing6pwn6.CalendarEventContentAction) {
      return _ing6pwn6.CalendarEventContentAction.fromJson(data) as T;
    }
    if (t == _ipyf9yt3.CalendarEventContentField) {
      return _ipyf9yt3.CalendarEventContentField.fromJson(data) as T;
    }
    if (t == _i0orp171.CalendarEventCreateRequest) {
      return _i0orp171.CalendarEventCreateRequest.fromJson(data) as T;
    }
    if (t == _i23wc83s.CalendarEventDataRecord) {
      return _i23wc83s.CalendarEventDataRecord.fromJson(data) as T;
    }
    if (t == _i0bvx67a.CalendarEventDescriptiveMetadata) {
      return _i0bvx67a.CalendarEventDescriptiveMetadata.fromJson(data) as T;
    }
    if (t == _ibq0xtgn.CalendarEventDescriptiveRequest) {
      return _ibq0xtgn.CalendarEventDescriptiveRequest.fromJson(data) as T;
    }
    if (t == _idn2i48l.CalendarEventDuration) {
      return _idn2i48l.CalendarEventDuration.fromJson(data) as T;
    }
    if (t == _ifgpnp3a.CalendarEventExportRequest) {
      return _ifgpnp3a.CalendarEventExportRequest.fromJson(data) as T;
    }
    if (t == _ijug927r.CalendarEventExportSelection) {
      return _ijug927r.CalendarEventExportSelection.fromJson(data) as T;
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
    if (t == _iloy79hd.CalendarEventGeographicPosition) {
      return _iloy79hd.CalendarEventGeographicPosition.fromJson(data) as T;
    }
    if (t == _iblybidp.CalendarEventImportBaseline) {
      return _iblybidp.CalendarEventImportBaseline.fromJson(data) as T;
    }
    if (t == _ixo47kyf.CalendarEventImportRequest) {
      return _ixo47kyf.CalendarEventImportRequest.fromJson(data) as T;
    }
    if (t == _iduchdjm.CalendarEventImportResult) {
      return _iduchdjm.CalendarEventImportResult.fromJson(data) as T;
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
    if (t == _io4uvjqi.CalendarEventOccurrenceContent) {
      return _io4uvjqi.CalendarEventOccurrenceContent.fromJson(data) as T;
    }
    if (t == _iikl1ga8.CalendarEventOccurrenceContentChange) {
      return _iikl1ga8.CalendarEventOccurrenceContentChange.fromJson(data) as T;
    }
    if (t == _iaip8d0d.CalendarEventOccurrenceContentRequest) {
      return _iaip8d0d.CalendarEventOccurrenceContentRequest.fromJson(data)
          as T;
    }
    if (t == _ij33d3qn.CalendarEventOccurrenceCursorState) {
      return _ij33d3qn.CalendarEventOccurrenceCursorState.fromJson(data) as T;
    }
    if (t == _i6x6hm0f.CalendarEventOccurrenceListItem) {
      return _i6x6hm0f.CalendarEventOccurrenceListItem.fromJson(data) as T;
    }
    if (t == _iayv5gu3.CalendarEventOccurrenceListQuery) {
      return _iayv5gu3.CalendarEventOccurrenceListQuery.fromJson(data) as T;
    }
    if (t == _ifm4sinz.CalendarEventOccurrencePage) {
      return _ifm4sinz.CalendarEventOccurrencePage.fromJson(data) as T;
    }
    if (t == _i1a4s0rt.CalendarEventOccurrencePreview) {
      return _i1a4s0rt.CalendarEventOccurrencePreview.fromJson(data) as T;
    }
    if (t == _im5iu6ju.CalendarEventOccurrenceProtocolVersion) {
      return _im5iu6ju.CalendarEventOccurrenceProtocolVersion.fromJson(data)
          as T;
    }
    if (t == _ivs4ir3j.CalendarEventOccurrenceQuery) {
      return _ivs4ir3j.CalendarEventOccurrenceQuery.fromJson(data) as T;
    }
    if (t == _ipbrznp8.CalendarEventOrigin) {
      return _ipbrznp8.CalendarEventOrigin.fromJson(data) as T;
    }
    if (t == _iml0c566.CalendarEventOverrideProtocolState) {
      return _iml0c566.CalendarEventOverrideProtocolState.fromJson(data) as T;
    }
    if (t == _iaayjmj1.CalendarEventPage) {
      return _iaayjmj1.CalendarEventPage.fromJson(data) as T;
    }
    if (t == _i8iqsbco.CalendarEventProtocolState) {
      return _i8iqsbco.CalendarEventProtocolState.fromJson(data) as T;
    }
    if (t == _iblfo3t0.CalendarEventProtocolVersion) {
      return _iblfo3t0.CalendarEventProtocolVersion.fromJson(data) as T;
    }
    if (t == _i500bvo7.CalendarEventReceipt) {
      return _i500bvo7.CalendarEventReceipt.fromJson(data) as T;
    }
    if (t == _ilvoe14z.CalendarEventRecord) {
      return _ilvoe14z.CalendarEventRecord.fromJson(data) as T;
    }
    if (t == _iqxs44bf.CalendarEventRecurrence) {
      return _iqxs44bf.CalendarEventRecurrence.fromJson(data) as T;
    }
    if (t == _ii1x02jx.CalendarEventReplaceReceipt) {
      return _ii1x02jx.CalendarEventReplaceReceipt.fromJson(data) as T;
    }
    if (t == _ikx66n5r.CalendarEventReplaceRequest) {
      return _ikx66n5r.CalendarEventReplaceRequest.fromJson(data) as T;
    }
    if (t == _ipzyec4h.CalendarEventReplaceResult) {
      return _ipzyec4h.CalendarEventReplaceResult.fromJson(data) as T;
    }
    if (t == _iiajf89w.CalendarEventResourceGroup) {
      return _iiajf89w.CalendarEventResourceGroup.fromJson(data) as T;
    }
    if (t == _iovyzq1q.CalendarEventRule) {
      return _iovyzq1q.CalendarEventRule.fromJson(data) as T;
    }
    if (t == _iq1kxi25.CalendarEventSingleOverride) {
      return _iq1kxi25.CalendarEventSingleOverride.fromJson(data) as T;
    }
    if (t == _i4dai4jt.CalendarEventSourceAlarm) {
      return _i4dai4jt.CalendarEventSourceAlarm.fromJson(data) as T;
    }
    if (t == _i20i9qxn.CalendarEventSourceAttachment) {
      return _i20i9qxn.CalendarEventSourceAttachment.fromJson(data) as T;
    }
    if (t == _iui013s0.CalendarEventSourceCategoryGroup) {
      return _iui013s0.CalendarEventSourceCategoryGroup.fromJson(data) as T;
    }
    if (t == _ie9apnqv.CalendarEventSourceDuration) {
      return _ie9apnqv.CalendarEventSourceDuration.fromJson(data) as T;
    }
    if (t == _ic57ts5d.CalendarEventSourceMetadata) {
      return _ic57ts5d.CalendarEventSourceMetadata.fromJson(data) as T;
    }
    if (t == _iypom7ai.CalendarEventSourceParticipant) {
      return _iypom7ai.CalendarEventSourceParticipant.fromJson(data) as T;
    }
    if (t == _iksc4ly9.CalendarEventSourceRelationship) {
      return _iksc4ly9.CalendarEventSourceRelationship.fromJson(data) as T;
    }
    if (t == _iwa6orjz.CalendarEventSourceText) {
      return _iwa6orjz.CalendarEventSourceText.fromJson(data) as T;
    }
    if (t == _ivzxk9bc.CalendarEventStatus) {
      return _ivzxk9bc.CalendarEventStatus.fromJson(data) as T;
    }
    if (t == _i3kbbl30.CalendarEventStatusRequest) {
      return _i3kbbl30.CalendarEventStatusRequest.fromJson(data) as T;
    }
    if (t == _iswwug34.CalendarEventTextMetadataRequest) {
      return _iswwug34.CalendarEventTextMetadataRequest.fromJson(data) as T;
    }
    if (t == _isfojy12.CalendarEventTextParameters) {
      return _isfojy12.CalendarEventTextParameters.fromJson(data) as T;
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
    if (t == _ibccnfmr.CalendarIdentityRecord) {
      return _ibccnfmr.CalendarIdentityRecord.fromJson(data) as T;
    }
    if (t == _igf45b52.CalendarImageLink) {
      return _igf45b52.CalendarImageLink.fromJson(data) as T;
    }
    if (t == _ib1s0vrr.CalendarInvitationAdoptionReceipt) {
      return _ib1s0vrr.CalendarInvitationAdoptionReceipt.fromJson(data) as T;
    }
    if (t == _imimov8l.CalendarInvitationAdoptionRequest) {
      return _imimov8l.CalendarInvitationAdoptionRequest.fromJson(data) as T;
    }
    if (t == _i29jhvb3.CalendarInvitationApplicationRecord) {
      return _i29jhvb3.CalendarInvitationApplicationRecord.fromJson(data) as T;
    }
    if (t == _i8svxjh1.CalendarInvitationApplicationView) {
      return _i8svxjh1.CalendarInvitationApplicationView.fromJson(data) as T;
    }
    if (t == _ic2yh4ry.CalendarInvitationApplyReceipt) {
      return _ic2yh4ry.CalendarInvitationApplyReceipt.fromJson(data) as T;
    }
    if (t == _iivrx0vm.CalendarInvitationApplyRequest) {
      return _iivrx0vm.CalendarInvitationApplyRequest.fromJson(data) as T;
    }
    if (t == _iwcng7rp.CalendarInvitationDocument) {
      return _iwcng7rp.CalendarInvitationDocument.fromJson(data) as T;
    }
    if (t == _ibnm4ujx.CalendarInvitationLinkRecord) {
      return _ibnm4ujx.CalendarInvitationLinkRecord.fromJson(data) as T;
    }
    if (t == _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord) {
      return _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord.fromJson(
            data,
          )
          as T;
    }
    if (t == _i15b7t0e.CalendarInvitationOccurrenceApplicationView) {
      return _i15b7t0e.CalendarInvitationOccurrenceApplicationView.fromJson(
            data,
          )
          as T;
    }
    if (t == _iyajy5op.CalendarInvitationOccurrenceApplyReceipt) {
      return _iyajy5op.CalendarInvitationOccurrenceApplyReceipt.fromJson(data)
          as T;
    }
    if (t == _ioottw62.CalendarInvitationOccurrenceApplyRequest) {
      return _ioottw62.CalendarInvitationOccurrenceApplyRequest.fromJson(data)
          as T;
    }
    if (t == _i98zwsq8.CalendarInvitationOutcome) {
      return _i98zwsq8.CalendarInvitationOutcome.fromJson(data) as T;
    }
    if (t == _iy372k0z.CalendarInvitationReceipt) {
      return _iy372k0z.CalendarInvitationReceipt.fromJson(data) as T;
    }
    if (t == _i1bc5dpy.CalendarInvitationReceiptRecord) {
      return _i1bc5dpy.CalendarInvitationReceiptRecord.fromJson(data) as T;
    }
    if (t == _igigle43.CalendarInvitationRecord) {
      return _igigle43.CalendarInvitationRecord.fromJson(data) as T;
    }
    if (t == _ip5pithb.CalendarInvitationResponseActivityView) {
      return _ip5pithb.CalendarInvitationResponseActivityView.fromJson(data)
          as T;
    }
    if (t == _i3vdxm7o.CalendarInvitationResponseAttemptRecord) {
      return _i3vdxm7o.CalendarInvitationResponseAttemptRecord.fromJson(data)
          as T;
    }
    if (t == _il64jj9v.CalendarInvitationResponseChoice) {
      return _il64jj9v.CalendarInvitationResponseChoice.fromJson(data) as T;
    }
    if (t == _iw51ozry.CalendarInvitationResponseDeliveryState) {
      return _iw51ozry.CalendarInvitationResponseDeliveryState.fromJson(data)
          as T;
    }
    if (t == _ig6twu0d.CalendarInvitationResponseReceipt) {
      return _ig6twu0d.CalendarInvitationResponseReceipt.fromJson(data) as T;
    }
    if (t == _iifvkijq.CalendarInvitationResponseRecord) {
      return _iifvkijq.CalendarInvitationResponseRecord.fromJson(data) as T;
    }
    if (t == _iw3qnr12.CalendarInvitationResponseRequest) {
      return _iw3qnr12.CalendarInvitationResponseRequest.fromJson(data) as T;
    }
    if (t == _i5cgrgck.CalendarInvitationResponseStateRecord) {
      return _i5cgrgck.CalendarInvitationResponseStateRecord.fromJson(data)
          as T;
    }
    if (t == _irmbkh1p.CalendarInvitationResponseView) {
      return _irmbkh1p.CalendarInvitationResponseView.fromJson(data) as T;
    }
    if (t == _ilccsff7.CalendarInvitationSourceKind) {
      return _ilccsff7.CalendarInvitationSourceKind.fromJson(data) as T;
    }
    if (t == _i3yqoryt.CalendarInvitationSourceRecord) {
      return _i3yqoryt.CalendarInvitationSourceRecord.fromJson(data) as T;
    }
    if (t == _itix6re9.CalendarInvitationSourceView) {
      return _itix6re9.CalendarInvitationSourceView.fromJson(data) as T;
    }
    if (t == _ifs5c7mj.CalendarInvitationView) {
      return _ifs5c7mj.CalendarInvitationView.fromJson(data) as T;
    }
    if (t == _i3iolgr8.CalendarItemCategoryGroup) {
      return _i3iolgr8.CalendarItemCategoryGroup.fromJson(data) as T;
    }
    if (t == _itx19m90.CalendarItemComment) {
      return _itx19m90.CalendarItemComment.fromJson(data) as T;
    }
    if (t == _i12tuyl5.CalendarItemTextMetadataField) {
      return _i12tuyl5.CalendarItemTextMetadataField.fromJson(data) as T;
    }
    if (t == _ikwi9ryb.CalendarItemTextMetadataPatch) {
      return _ikwi9ryb.CalendarItemTextMetadataPatch.fromJson(data) as T;
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
    if (t == _i64utb1e.CalendarSchedulingAttemptRecord) {
      return _i64utb1e.CalendarSchedulingAttemptRecord.fromJson(data) as T;
    }
    if (t == _i577nx0c.CalendarSchedulingAttendeeResponseRecord) {
      return _i577nx0c.CalendarSchedulingAttendeeResponseRecord.fromJson(data)
          as T;
    }
    if (t == _itopoldj.CalendarSchedulingAttendeeResponseView) {
      return _itopoldj.CalendarSchedulingAttendeeResponseView.fromJson(data)
          as T;
    }
    if (t == _i4uu6f5m.CalendarSchedulingCancelRequest) {
      return _i4uu6f5m.CalendarSchedulingCancelRequest.fromJson(data) as T;
    }
    if (t == _iuidcanh.CalendarSchedulingDeliveryRecord) {
      return _iuidcanh.CalendarSchedulingDeliveryRecord.fromJson(data) as T;
    }
    if (t == _it5jr5tm.CalendarSchedulingDeliveryState) {
      return _it5jr5tm.CalendarSchedulingDeliveryState.fromJson(data) as T;
    }
    if (t == _i63ky642.CalendarSchedulingDeliveryView) {
      return _i63ky642.CalendarSchedulingDeliveryView.fromJson(data) as T;
    }
    if (t == _i8yevrne.CalendarSchedulingInstanceResponsesView) {
      return _i8yevrne.CalendarSchedulingInstanceResponsesView.fromJson(data)
          as T;
    }
    if (t == _ihlqfuoo.CalendarSchedulingMeetingRecord) {
      return _ihlqfuoo.CalendarSchedulingMeetingRecord.fromJson(data) as T;
    }
    if (t == _ia8x0otq.CalendarSchedulingOccurrenceCancelRequest) {
      return _ia8x0otq.CalendarSchedulingOccurrenceCancelRequest.fromJson(data)
          as T;
    }
    if (t == _io2t7cny.CalendarSchedulingOccurrenceRestoreRequest) {
      return _io2t7cny.CalendarSchedulingOccurrenceRestoreRequest.fromJson(data)
          as T;
    }
    if (t == _iot0xi24.CalendarSchedulingParticipation) {
      return _iot0xi24.CalendarSchedulingParticipation.fromJson(data) as T;
    }
    if (t == _il38fbb4.CalendarSchedulingPublicationKind) {
      return _il38fbb4.CalendarSchedulingPublicationKind.fromJson(data) as T;
    }
    if (t == _ivo2647b.CalendarSchedulingPublicationRecord) {
      return _ivo2647b.CalendarSchedulingPublicationRecord.fromJson(data) as T;
    }
    if (t == _izftntkw.CalendarSchedulingReceipt) {
      return _izftntkw.CalendarSchedulingReceipt.fromJson(data) as T;
    }
    if (t == _iv2f51nm.CalendarSchedulingReopenRequest) {
      return _iv2f51nm.CalendarSchedulingReopenRequest.fromJson(data) as T;
    }
    if (t == _iqen8jmy.CalendarSchedulingReplyDocument) {
      return _iqen8jmy.CalendarSchedulingReplyDocument.fromJson(data) as T;
    }
    if (t == _ikqvfn4d.CalendarSchedulingReplyOutcome) {
      return _ikqvfn4d.CalendarSchedulingReplyOutcome.fromJson(data) as T;
    }
    if (t == _iwdevo6h.CalendarSchedulingReplyReceipt) {
      return _iwdevo6h.CalendarSchedulingReplyReceipt.fromJson(data) as T;
    }
    if (t == _i0njii35.CalendarSchedulingReplyReceiptRecord) {
      return _i0njii35.CalendarSchedulingReplyReceiptRecord.fromJson(data) as T;
    }
    if (t == _ia855khw.CalendarSchedulingReplySourceRecord) {
      return _ia855khw.CalendarSchedulingReplySourceRecord.fromJson(data) as T;
    }
    if (t == _i2peuvqu.CalendarSchedulingReplySourceView) {
      return _i2peuvqu.CalendarSchedulingReplySourceView.fromJson(data) as T;
    }
    if (t == _ixbxcx0r.CalendarSchedulingResponsesView) {
      return _ixbxcx0r.CalendarSchedulingResponsesView.fromJson(data) as T;
    }
    if (t == _icabxeyo.CalendarSchedulingSaveRequest) {
      return _icabxeyo.CalendarSchedulingSaveRequest.fromJson(data) as T;
    }
    if (t == _is73suzs.CalendarSchedulingView) {
      return _is73suzs.CalendarSchedulingView.fromJson(data) as T;
    }
    if (t == _i9mvj7kq.CalendarScopeRecord) {
      return _i9mvj7kq.CalendarScopeRecord.fromJson(data) as T;
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
    if (t == _i76vfrve.CalendarSubjectRecord) {
      return _i76vfrve.CalendarSubjectRecord.fromJson(data) as T;
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
    if (t == _ih5e3u6u.CalendarTaskAssignee) {
      return _ih5e3u6u.CalendarTaskAssignee.fromJson(data) as T;
    }
    if (t == _ipa1soge.CalendarTaskAssignmentsRequest) {
      return _ipa1soge.CalendarTaskAssignmentsRequest.fromJson(data) as T;
    }
    if (t == _if7nbvl8.CalendarTaskContent) {
      return _if7nbvl8.CalendarTaskContent.fromJson(data) as T;
    }
    if (t == _ihwe765g.CalendarTaskContentAction) {
      return _ihwe765g.CalendarTaskContentAction.fromJson(data) as T;
    }
    if (t == _i496rta0.CalendarTaskContentField) {
      return _i496rta0.CalendarTaskContentField.fromJson(data) as T;
    }
    if (t == _iipxdkwq.CalendarTaskCreateRequest) {
      return _iipxdkwq.CalendarTaskCreateRequest.fromJson(data) as T;
    }
    if (t == _ic8eedzw.CalendarTaskDataRecord) {
      return _ic8eedzw.CalendarTaskDataRecord.fromJson(data) as T;
    }
    if (t == _i10340hl.CalendarTaskExportRequest) {
      return _i10340hl.CalendarTaskExportRequest.fromJson(data) as T;
    }
    if (t == _i71mi7ri.CalendarTaskExportSelection) {
      return _i71mi7ri.CalendarTaskExportSelection.fromJson(data) as T;
    }
    if (t == _isemqyyv.CalendarTaskFieldGroup) {
      return _isemqyyv.CalendarTaskFieldGroup.fromJson(data) as T;
    }
    if (t == _idhalyap.CalendarTaskHistoryEntry) {
      return _idhalyap.CalendarTaskHistoryEntry.fromJson(data) as T;
    }
    if (t == _ibsdsx6x.CalendarTaskHistoryPage) {
      return _ibsdsx6x.CalendarTaskHistoryPage.fromJson(data) as T;
    }
    if (t == _i1vdb6de.CalendarTaskHistoryQuery) {
      return _i1vdb6de.CalendarTaskHistoryQuery.fromJson(data) as T;
    }
    if (t == _i6c7wo1p.CalendarTaskHistoryRecord) {
      return _i6c7wo1p.CalendarTaskHistoryRecord.fromJson(data) as T;
    }
    if (t == _iqsm27bn.CalendarTaskImportBaseline) {
      return _iqsm27bn.CalendarTaskImportBaseline.fromJson(data) as T;
    }
    if (t == _isw8fcv3.CalendarTaskImportRequest) {
      return _isw8fcv3.CalendarTaskImportRequest.fromJson(data) as T;
    }
    if (t == _izrxa9vy.CalendarTaskImportResult) {
      return _izrxa9vy.CalendarTaskImportResult.fromJson(data) as T;
    }
    if (t == _isgg83d3.CalendarTaskOccurrence) {
      return _isgg83d3.CalendarTaskOccurrence.fromJson(data) as T;
    }
    if (t == _irmu5f0n.CalendarTaskOccurrenceContent) {
      return _irmu5f0n.CalendarTaskOccurrenceContent.fromJson(data) as T;
    }
    if (t == _isfljanw.CalendarTaskOccurrenceContentChange) {
      return _isfljanw.CalendarTaskOccurrenceContentChange.fromJson(data) as T;
    }
    if (t == _iw338tmt.CalendarTaskOccurrenceContentRequest) {
      return _iw338tmt.CalendarTaskOccurrenceContentRequest.fromJson(data) as T;
    }
    if (t == _id9j5e7y.CalendarTaskOccurrencePreview) {
      return _id9j5e7y.CalendarTaskOccurrencePreview.fromJson(data) as T;
    }
    if (t == _irw24ank.CalendarTaskOccurrenceProgressRequest) {
      return _irw24ank.CalendarTaskOccurrenceProgressRequest.fromJson(data)
          as T;
    }
    if (t == _ixy579wj.CalendarTaskOccurrenceQuery) {
      return _ixy579wj.CalendarTaskOccurrenceQuery.fromJson(data) as T;
    }
    if (t == _i3t5ry4r.CalendarTaskOccurrenceRecord) {
      return _i3t5ry4r.CalendarTaskOccurrenceRecord.fromJson(data) as T;
    }
    if (t == _ii9v7kdj.CalendarTaskOccurrenceTimingRequest) {
      return _ii9v7kdj.CalendarTaskOccurrenceTimingRequest.fromJson(data) as T;
    }
    if (t == _i276ujfk.CalendarTaskPage) {
      return _i276ujfk.CalendarTaskPage.fromJson(data) as T;
    }
    if (t == _ikcsq95s.CalendarTaskProgress) {
      return _ikcsq95s.CalendarTaskProgress.fromJson(data) as T;
    }
    if (t == _i6s7yrua.CalendarTaskProgressAction) {
      return _i6s7yrua.CalendarTaskProgressAction.fromJson(data) as T;
    }
    if (t == _in6zlsph.CalendarTaskProgressRequest) {
      return _in6zlsph.CalendarTaskProgressRequest.fromJson(data) as T;
    }
    if (t == _iz9t6x1i.CalendarTaskProtocolVersion) {
      return _iz9t6x1i.CalendarTaskProtocolVersion.fromJson(data) as T;
    }
    if (t == _im9usybn.CalendarTaskReceipt) {
      return _im9usybn.CalendarTaskReceipt.fromJson(data) as T;
    }
    if (t == _irbiaacf.CalendarTaskRecord) {
      return _irbiaacf.CalendarTaskRecord.fromJson(data) as T;
    }
    if (t == _ib5z6spp.CalendarTaskReplaceReceipt) {
      return _ib5z6spp.CalendarTaskReplaceReceipt.fromJson(data) as T;
    }
    if (t == _ibpx2vjc.CalendarTaskReplaceRequest) {
      return _ibpx2vjc.CalendarTaskReplaceRequest.fromJson(data) as T;
    }
    if (t == _iyf2qeht.CalendarTaskReplaceResult) {
      return _iyf2qeht.CalendarTaskReplaceResult.fromJson(data) as T;
    }
    if (t == _i00avof0.CalendarTaskSourceAlarm) {
      return _i00avof0.CalendarTaskSourceAlarm.fromJson(data) as T;
    }
    if (t == _iuzk4pe3.CalendarTaskSourceAttachment) {
      return _iuzk4pe3.CalendarTaskSourceAttachment.fromJson(data) as T;
    }
    if (t == _iic8eifm.CalendarTaskSourceCategoryGroup) {
      return _iic8eifm.CalendarTaskSourceCategoryGroup.fromJson(data) as T;
    }
    if (t == _ivqadd6c.CalendarTaskSourceComponent) {
      return _ivqadd6c.CalendarTaskSourceComponent.fromJson(data) as T;
    }
    if (t == _im8khkr9.CalendarTaskSourceDuration) {
      return _im8khkr9.CalendarTaskSourceDuration.fromJson(data) as T;
    }
    if (t == _i76q6myt.CalendarTaskSourceMetadata) {
      return _i76q6myt.CalendarTaskSourceMetadata.fromJson(data) as T;
    }
    if (t == _iw6fme2j.CalendarTaskSourceParticipant) {
      return _iw6fme2j.CalendarTaskSourceParticipant.fromJson(data) as T;
    }
    if (t == _izyrs4yl.CalendarTaskSourceRelationship) {
      return _izyrs4yl.CalendarTaskSourceRelationship.fromJson(data) as T;
    }
    if (t == _it1pm24a.CalendarTaskSourceState) {
      return _it1pm24a.CalendarTaskSourceState.fromJson(data) as T;
    }
    if (t == _i9mnuab5.CalendarTaskSourceText) {
      return _i9mnuab5.CalendarTaskSourceText.fromJson(data) as T;
    }
    if (t == _iiahrdev.CalendarTaskStatus) {
      return _iiahrdev.CalendarTaskStatus.fromJson(data) as T;
    }
    if (t == _it8lhctx.CalendarTaskTextMetadataRequest) {
      return _it8lhctx.CalendarTaskTextMetadataRequest.fromJson(data) as T;
    }
    if (t == _ijhc2xsq.CalendarTaskTimeKind) {
      return _ijhc2xsq.CalendarTaskTimeKind.fromJson(data) as T;
    }
    if (t == _i9h8y8lg.CalendarTaskTiming) {
      return _i9h8y8lg.CalendarTaskTiming.fromJson(data) as T;
    }
    if (t == _in7cuxyg.CalendarTaskUpdateRequest) {
      return _in7cuxyg.CalendarTaskUpdateRequest.fromJson(data) as T;
    }
    if (t == _ii3yrr21.CalendarTaskView) {
      return _ii3yrr21.CalendarTaskView.fromJson(data) as T;
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
    if (t == _is.getType<_ihv8htej.CalendarAlarmActionKind?>()) {
      return (data != null
              ? _ihv8htej.CalendarAlarmActionKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipt2851n.CalendarAlarmActionRecord?>()) {
      return (data != null
              ? _ipt2851n.CalendarAlarmActionRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivvkdcds.CalendarAlarmActionRequest?>()) {
      return (data != null
              ? _ivvkdcds.CalendarAlarmActionRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixqjnkie.CalendarAlarmActionView?>()) {
      return (data != null
              ? _ixqjnkie.CalendarAlarmActionView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ik5ajwd4.CalendarAlarmActivityKind?>()) {
      return (data != null
              ? _ik5ajwd4.CalendarAlarmActivityKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iruhg2yq.CalendarAlarmActivityPage?>()) {
      return (data != null
              ? _iruhg2yq.CalendarAlarmActivityPage.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iv448ru6.CalendarAlarmAnchor?>()) {
      return (data != null
              ? _iv448ru6.CalendarAlarmAnchor.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iu47syqa.CalendarAlarmCreateRequest?>()) {
      return (data != null
              ? _iu47syqa.CalendarAlarmCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_irif99jb.CalendarAlarmDefinition?>()) {
      return (data != null
              ? _irif99jb.CalendarAlarmDefinition.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1qnv8jf.CalendarAlarmDuration?>()) {
      return (data != null
              ? _i1qnv8jf.CalendarAlarmDuration.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8okwxwj.CalendarAlarmFiringKind?>()) {
      return (data != null
              ? _i8okwxwj.CalendarAlarmFiringKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihgh57kq.CalendarAlarmFiringRecord?>()) {
      return (data != null
              ? _ihgh57kq.CalendarAlarmFiringRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihos0r46.CalendarAlarmFiringState?>()) {
      return (data != null
              ? _ihos0r46.CalendarAlarmFiringState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7xuciin.CalendarAlarmFiringView?>()) {
      return (data != null
              ? _i7xuciin.CalendarAlarmFiringView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iiyuulin.CalendarAlarmParent?>()) {
      return (data != null
              ? _iiyuulin.CalendarAlarmParent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ig3zti62.CalendarAlarmParentKind?>()) {
      return (data != null
              ? _ig3zti62.CalendarAlarmParentKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iid4j1lu.CalendarAlarmPlanRecord?>()) {
      return (data != null
              ? _iid4j1lu.CalendarAlarmPlanRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_irtomk7p.CalendarAlarmPlanStatus?>()) {
      return (data != null
              ? _irtomk7p.CalendarAlarmPlanStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iralscit.CalendarAlarmRecord?>()) {
      return (data != null
              ? _iralscit.CalendarAlarmRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ig76ry9v.CalendarAlarmSourceTimings?>()) {
      return (data != null
              ? _ig76ry9v.CalendarAlarmSourceTimings.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_im2lo7e9.CalendarAlarmUpdateRequest?>()) {
      return (data != null
              ? _im2lo7e9.CalendarAlarmUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ie7u1nxa.CalendarAlarmView?>()) {
      return (data != null ? _ie7u1nxa.CalendarAlarmView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iywbqexh.CalendarAvailabilityCategoryGroup?>()) {
      return (data != null
              ? _iywbqexh.CalendarAvailabilityCategoryGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iucw7bzg.CalendarAvailabilityClass?>()) {
      return (data != null
              ? _iucw7bzg.CalendarAvailabilityClass.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifxxil5c.CalendarAvailabilityContent?>()) {
      return (data != null
              ? _ifxxil5c.CalendarAvailabilityContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwwk2w9d.CalendarAvailabilityCreateRequest?>()) {
      return (data != null
              ? _iwwk2w9d.CalendarAvailabilityCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ie9je6js.CalendarAvailabilityDataRecord?>()) {
      return (data != null
              ? _ie9je6js.CalendarAvailabilityDataRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipddbn84.CalendarAvailabilityExportRequest?>()) {
      return (data != null
              ? _ipddbn84.CalendarAvailabilityExportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_incs3y0d.CalendarAvailabilityExportSelection?>()) {
      return (data != null
              ? _incs3y0d.CalendarAvailabilityExportSelection.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ip5gybl4.CalendarAvailabilityExtension?>()) {
      return (data != null
              ? _ip5gybl4.CalendarAvailabilityExtension.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivv22qfn.CalendarAvailabilityImportBaseline?>()) {
      return (data != null
              ? _ivv22qfn.CalendarAvailabilityImportBaseline.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6rm14nf.CalendarAvailabilityImportRequest?>()) {
      return (data != null
              ? _i6rm14nf.CalendarAvailabilityImportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iyvmsn4t.CalendarAvailabilityImportResult?>()) {
      return (data != null
              ? _iyvmsn4t.CalendarAvailabilityImportResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7tpo82q.CalendarAvailabilityOccurrenceChange?>()) {
      return (data != null
              ? _i7tpo82q.CalendarAvailabilityOccurrenceChange.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_inpm99jj.CalendarAvailabilityOccurrencePreview?>()) {
      return (data != null
              ? _inpm99jj.CalendarAvailabilityOccurrencePreview.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iv6wf0pl.CalendarAvailabilityOccurrenceQuery?>()) {
      return (data != null
              ? _iv6wf0pl.CalendarAvailabilityOccurrenceQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8tf9h36.CalendarAvailabilityOpening?>()) {
      return (data != null
              ? _i8tf9h36.CalendarAvailabilityOpening.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_id5ke9r5.CalendarAvailabilityOpeningEdits?>()) {
      return (data != null
              ? _id5ke9r5.CalendarAvailabilityOpeningEdits.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState?>()) {
      return (data != null
              ? _ix3hb3ib.CalendarAvailabilityOpeningProtocolState.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_i5oc0nlo.CalendarAvailabilityOrganizer?>()) {
      return (data != null
              ? _i5oc0nlo.CalendarAvailabilityOrganizer.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_i33h9mr5.CalendarAvailabilityOverrideProtocolState?>()) {
      return (data != null
              ? _i33h9mr5.CalendarAvailabilityOverrideProtocolState.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_ib9yzivj.CalendarAvailabilityProtocolState?>()) {
      return (data != null
              ? _ib9yzivj.CalendarAvailabilityProtocolState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_is1luycx.CalendarAvailabilityReceipt?>()) {
      return (data != null
              ? _is1luycx.CalendarAvailabilityReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_inwzhb5r.CalendarAvailabilityRecord?>()) {
      return (data != null
              ? _inwzhb5r.CalendarAvailabilityRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iiw2d6as.CalendarAvailabilityReplaceReceipt?>()) {
      return (data != null
              ? _iiw2d6as.CalendarAvailabilityReplaceReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ir631vai.CalendarAvailabilityReplaceRequest?>()) {
      return (data != null
              ? _ir631vai.CalendarAvailabilityReplaceRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itahk50i.CalendarAvailabilityReplaceResult?>()) {
      return (data != null
              ? _itahk50i.CalendarAvailabilityReplaceResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iam4llos.CalendarAvailabilitySearchMode?>()) {
      return (data != null
              ? _iam4llos.CalendarAvailabilitySearchMode.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idixoqjq.CalendarAvailabilitySearchQuery?>()) {
      return (data != null
              ? _idixoqjq.CalendarAvailabilitySearchQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i99fx1rw.CalendarAvailabilitySearchView?>()) {
      return (data != null
              ? _i99fx1rw.CalendarAvailabilitySearchView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i45h4t8f.CalendarAvailabilitySlot?>()) {
      return (data != null
              ? _i45h4t8f.CalendarAvailabilitySlot.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i15w6qdl.CalendarAvailabilitySourceMetadata?>()) {
      return (data != null
              ? _i15w6qdl.CalendarAvailabilitySourceMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwbqbnec.CalendarAvailabilityTarget?>()) {
      return (data != null
              ? _iwbqbnec.CalendarAvailabilityTarget.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itw42wa3.CalendarAvailabilityText?>()) {
      return (data != null
              ? _itw42wa3.CalendarAvailabilityText.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipbm7ji7.CalendarAvailabilityTextParameters?>()) {
      return (data != null
              ? _ipbm7ji7.CalendarAvailabilityTextParameters.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_igv5u6jv.CalendarAvailabilityUpdateRequest?>()) {
      return (data != null
              ? _igv5u6jv.CalendarAvailabilityUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izmf6fpk.CalendarAvailabilityView?>()) {
      return (data != null
              ? _izmf6fpk.CalendarAvailabilityView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_icnza73c.CalendarCategory?>()) {
      return (data != null ? _icnza73c.CalendarCategory.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9j129by.CalendarCategoryFilter?>()) {
      return (data != null
              ? _i9j129by.CalendarCategoryFilter.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8chn2wc.CalendarCreateRequest?>()) {
      return (data != null
              ? _i8chn2wc.CalendarCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iptr9vfe.CalendarCursorRecord?>()) {
      return (data != null
              ? _iptr9vfe.CalendarCursorRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ix6i00tg.CalendarDataRecord?>()) {
      return (data != null ? _ix6i00tg.CalendarDataRecord.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iq7751s4.CalendarEventByDay?>()) {
      return (data != null ? _iq7751s4.CalendarEventByDay.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i1bb5k1r.CalendarEventCivil?>()) {
      return (data != null ? _i1bb5k1r.CalendarEventCivil.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_id4cvk34.CalendarEventContent?>()) {
      return (data != null
              ? _id4cvk34.CalendarEventContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ing6pwn6.CalendarEventContentAction?>()) {
      return (data != null
              ? _ing6pwn6.CalendarEventContentAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipyf9yt3.CalendarEventContentField?>()) {
      return (data != null
              ? _ipyf9yt3.CalendarEventContentField.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0orp171.CalendarEventCreateRequest?>()) {
      return (data != null
              ? _i0orp171.CalendarEventCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i23wc83s.CalendarEventDataRecord?>()) {
      return (data != null
              ? _i23wc83s.CalendarEventDataRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0bvx67a.CalendarEventDescriptiveMetadata?>()) {
      return (data != null
              ? _i0bvx67a.CalendarEventDescriptiveMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibq0xtgn.CalendarEventDescriptiveRequest?>()) {
      return (data != null
              ? _ibq0xtgn.CalendarEventDescriptiveRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idn2i48l.CalendarEventDuration?>()) {
      return (data != null
              ? _idn2i48l.CalendarEventDuration.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifgpnp3a.CalendarEventExportRequest?>()) {
      return (data != null
              ? _ifgpnp3a.CalendarEventExportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ijug927r.CalendarEventExportSelection?>()) {
      return (data != null
              ? _ijug927r.CalendarEventExportSelection.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iftiwkuj.CalendarEventFieldGroup?>()) {
      return (data != null
              ? _iftiwkuj.CalendarEventFieldGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i2q54gr5.CalendarEventFrequency?>()) {
      return (data != null
              ? _i2q54gr5.CalendarEventFrequency.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_imbjv41e.CalendarEventFutureOverride?>()) {
      return (data != null
              ? _imbjv41e.CalendarEventFutureOverride.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iloy79hd.CalendarEventGeographicPosition?>()) {
      return (data != null
              ? _iloy79hd.CalendarEventGeographicPosition.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iblybidp.CalendarEventImportBaseline?>()) {
      return (data != null
              ? _iblybidp.CalendarEventImportBaseline.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixo47kyf.CalendarEventImportRequest?>()) {
      return (data != null
              ? _ixo47kyf.CalendarEventImportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iduchdjm.CalendarEventImportResult?>()) {
      return (data != null
              ? _iduchdjm.CalendarEventImportResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_isyqnyev.CalendarEventOccurrence?>()) {
      return (data != null
              ? _isyqnyev.CalendarEventOccurrence.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_icnciyzp.CalendarEventOccurrenceAction?>()) {
      return (data != null
              ? _icnciyzp.CalendarEventOccurrenceAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7imxrlz.CalendarEventOccurrenceChange?>()) {
      return (data != null
              ? _i7imxrlz.CalendarEventOccurrenceChange.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_io4uvjqi.CalendarEventOccurrenceContent?>()) {
      return (data != null
              ? _io4uvjqi.CalendarEventOccurrenceContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iikl1ga8.CalendarEventOccurrenceContentChange?>()) {
      return (data != null
              ? _iikl1ga8.CalendarEventOccurrenceContentChange.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iaip8d0d.CalendarEventOccurrenceContentRequest?>()) {
      return (data != null
              ? _iaip8d0d.CalendarEventOccurrenceContentRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ij33d3qn.CalendarEventOccurrenceCursorState?>()) {
      return (data != null
              ? _ij33d3qn.CalendarEventOccurrenceCursorState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6x6hm0f.CalendarEventOccurrenceListItem?>()) {
      return (data != null
              ? _i6x6hm0f.CalendarEventOccurrenceListItem.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iayv5gu3.CalendarEventOccurrenceListQuery?>()) {
      return (data != null
              ? _iayv5gu3.CalendarEventOccurrenceListQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifm4sinz.CalendarEventOccurrencePage?>()) {
      return (data != null
              ? _ifm4sinz.CalendarEventOccurrencePage.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1a4s0rt.CalendarEventOccurrencePreview?>()) {
      return (data != null
              ? _i1a4s0rt.CalendarEventOccurrencePreview.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_im5iu6ju.CalendarEventOccurrenceProtocolVersion?>()) {
      return (data != null
              ? _im5iu6ju.CalendarEventOccurrenceProtocolVersion.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivs4ir3j.CalendarEventOccurrenceQuery?>()) {
      return (data != null
              ? _ivs4ir3j.CalendarEventOccurrenceQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipbrznp8.CalendarEventOrigin?>()) {
      return (data != null
              ? _ipbrznp8.CalendarEventOrigin.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iml0c566.CalendarEventOverrideProtocolState?>()) {
      return (data != null
              ? _iml0c566.CalendarEventOverrideProtocolState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iaayjmj1.CalendarEventPage?>()) {
      return (data != null ? _iaayjmj1.CalendarEventPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8iqsbco.CalendarEventProtocolState?>()) {
      return (data != null
              ? _i8iqsbco.CalendarEventProtocolState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iblfo3t0.CalendarEventProtocolVersion?>()) {
      return (data != null
              ? _iblfo3t0.CalendarEventProtocolVersion.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i500bvo7.CalendarEventReceipt?>()) {
      return (data != null
              ? _i500bvo7.CalendarEventReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ilvoe14z.CalendarEventRecord?>()) {
      return (data != null
              ? _ilvoe14z.CalendarEventRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqxs44bf.CalendarEventRecurrence?>()) {
      return (data != null
              ? _iqxs44bf.CalendarEventRecurrence.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ii1x02jx.CalendarEventReplaceReceipt?>()) {
      return (data != null
              ? _ii1x02jx.CalendarEventReplaceReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ikx66n5r.CalendarEventReplaceRequest?>()) {
      return (data != null
              ? _ikx66n5r.CalendarEventReplaceRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipzyec4h.CalendarEventReplaceResult?>()) {
      return (data != null
              ? _ipzyec4h.CalendarEventReplaceResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iiajf89w.CalendarEventResourceGroup?>()) {
      return (data != null
              ? _iiajf89w.CalendarEventResourceGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iovyzq1q.CalendarEventRule?>()) {
      return (data != null ? _iovyzq1q.CalendarEventRule.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iq1kxi25.CalendarEventSingleOverride?>()) {
      return (data != null
              ? _iq1kxi25.CalendarEventSingleOverride.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i4dai4jt.CalendarEventSourceAlarm?>()) {
      return (data != null
              ? _i4dai4jt.CalendarEventSourceAlarm.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i20i9qxn.CalendarEventSourceAttachment?>()) {
      return (data != null
              ? _i20i9qxn.CalendarEventSourceAttachment.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iui013s0.CalendarEventSourceCategoryGroup?>()) {
      return (data != null
              ? _iui013s0.CalendarEventSourceCategoryGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ie9apnqv.CalendarEventSourceDuration?>()) {
      return (data != null
              ? _ie9apnqv.CalendarEventSourceDuration.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ic57ts5d.CalendarEventSourceMetadata?>()) {
      return (data != null
              ? _ic57ts5d.CalendarEventSourceMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iypom7ai.CalendarEventSourceParticipant?>()) {
      return (data != null
              ? _iypom7ai.CalendarEventSourceParticipant.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iksc4ly9.CalendarEventSourceRelationship?>()) {
      return (data != null
              ? _iksc4ly9.CalendarEventSourceRelationship.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwa6orjz.CalendarEventSourceText?>()) {
      return (data != null
              ? _iwa6orjz.CalendarEventSourceText.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivzxk9bc.CalendarEventStatus?>()) {
      return (data != null
              ? _ivzxk9bc.CalendarEventStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3kbbl30.CalendarEventStatusRequest?>()) {
      return (data != null
              ? _i3kbbl30.CalendarEventStatusRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iswwug34.CalendarEventTextMetadataRequest?>()) {
      return (data != null
              ? _iswwug34.CalendarEventTextMetadataRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_isfojy12.CalendarEventTextParameters?>()) {
      return (data != null
              ? _isfojy12.CalendarEventTextParameters.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idbnuf6y.CalendarEventTimeKind?>()) {
      return (data != null
              ? _idbnuf6y.CalendarEventTimeKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ieswiaty.CalendarEventTiming?>()) {
      return (data != null
              ? _ieswiaty.CalendarEventTiming.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ijijze99.CalendarEventTimingOverrides?>()) {
      return (data != null
              ? _ijijze99.CalendarEventTimingOverrides.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwjkdwy7.CalendarEventTransparency?>()) {
      return (data != null
              ? _iwjkdwy7.CalendarEventTransparency.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3ofr0ug.CalendarEventUpdateRequest?>()) {
      return (data != null
              ? _i3ofr0ug.CalendarEventUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqr733fy.CalendarEventView?>()) {
      return (data != null ? _iqr733fy.CalendarEventView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ioicq9ju.CalendarException?>()) {
      return (data != null ? _ioicq9ju.CalendarException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i7h2f30k.CalendarFailureCode?>()) {
      return (data != null
              ? _i7h2f30k.CalendarFailureCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i73hgz1s.CalendarFieldGroup?>()) {
      return (data != null ? _i73hgz1s.CalendarFieldGroup.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ia3n9q23.CalendarFreeBusyCoverage?>()) {
      return (data != null
              ? _ia3n9q23.CalendarFreeBusyCoverage.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izms466b.CalendarFreeBusyKind?>()) {
      return (data != null
              ? _izms466b.CalendarFreeBusyKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i82zcrxb.CalendarFreeBusyPeriod?>()) {
      return (data != null
              ? _i82zcrxb.CalendarFreeBusyPeriod.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idid5g6i.CalendarFreeBusyQuery?>()) {
      return (data != null
              ? _idid5g6i.CalendarFreeBusyQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3b615hg.CalendarFreeBusyView?>()) {
      return (data != null
              ? _i3b615hg.CalendarFreeBusyView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibccnfmr.CalendarIdentityRecord?>()) {
      return (data != null
              ? _ibccnfmr.CalendarIdentityRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_igf45b52.CalendarImageLink?>()) {
      return (data != null ? _igf45b52.CalendarImageLink.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ib1s0vrr.CalendarInvitationAdoptionReceipt?>()) {
      return (data != null
              ? _ib1s0vrr.CalendarInvitationAdoptionReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_imimov8l.CalendarInvitationAdoptionRequest?>()) {
      return (data != null
              ? _imimov8l.CalendarInvitationAdoptionRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i29jhvb3.CalendarInvitationApplicationRecord?>()) {
      return (data != null
              ? _i29jhvb3.CalendarInvitationApplicationRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8svxjh1.CalendarInvitationApplicationView?>()) {
      return (data != null
              ? _i8svxjh1.CalendarInvitationApplicationView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ic2yh4ry.CalendarInvitationApplyReceipt?>()) {
      return (data != null
              ? _ic2yh4ry.CalendarInvitationApplyReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iivrx0vm.CalendarInvitationApplyRequest?>()) {
      return (data != null
              ? _iivrx0vm.CalendarInvitationApplyRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwcng7rp.CalendarInvitationDocument?>()) {
      return (data != null
              ? _iwcng7rp.CalendarInvitationDocument.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibnm4ujx.CalendarInvitationLinkRecord?>()) {
      return (data != null
              ? _ibnm4ujx.CalendarInvitationLinkRecord.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is
            .getType<
              _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord?
            >()) {
      return (data != null
              ? _i48y6d6c
                    .CalendarInvitationOccurrenceApplicationRecord.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t ==
        _is.getType<_i15b7t0e.CalendarInvitationOccurrenceApplicationView?>()) {
      return (data != null
              ? _i15b7t0e.CalendarInvitationOccurrenceApplicationView.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t ==
        _is.getType<_iyajy5op.CalendarInvitationOccurrenceApplyReceipt?>()) {
      return (data != null
              ? _iyajy5op.CalendarInvitationOccurrenceApplyReceipt.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t ==
        _is.getType<_ioottw62.CalendarInvitationOccurrenceApplyRequest?>()) {
      return (data != null
              ? _ioottw62.CalendarInvitationOccurrenceApplyRequest.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_i98zwsq8.CalendarInvitationOutcome?>()) {
      return (data != null
              ? _i98zwsq8.CalendarInvitationOutcome.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iy372k0z.CalendarInvitationReceipt?>()) {
      return (data != null
              ? _iy372k0z.CalendarInvitationReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1bc5dpy.CalendarInvitationReceiptRecord?>()) {
      return (data != null
              ? _i1bc5dpy.CalendarInvitationReceiptRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_igigle43.CalendarInvitationRecord?>()) {
      return (data != null
              ? _igigle43.CalendarInvitationRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ip5pithb.CalendarInvitationResponseActivityView?>()) {
      return (data != null
              ? _ip5pithb.CalendarInvitationResponseActivityView.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_i3vdxm7o.CalendarInvitationResponseAttemptRecord?>()) {
      return (data != null
              ? _i3vdxm7o.CalendarInvitationResponseAttemptRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_il64jj9v.CalendarInvitationResponseChoice?>()) {
      return (data != null
              ? _il64jj9v.CalendarInvitationResponseChoice.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_iw51ozry.CalendarInvitationResponseDeliveryState?>()) {
      return (data != null
              ? _iw51ozry.CalendarInvitationResponseDeliveryState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ig6twu0d.CalendarInvitationResponseReceipt?>()) {
      return (data != null
              ? _ig6twu0d.CalendarInvitationResponseReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iifvkijq.CalendarInvitationResponseRecord?>()) {
      return (data != null
              ? _iifvkijq.CalendarInvitationResponseRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iw3qnr12.CalendarInvitationResponseRequest?>()) {
      return (data != null
              ? _iw3qnr12.CalendarInvitationResponseRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i5cgrgck.CalendarInvitationResponseStateRecord?>()) {
      return (data != null
              ? _i5cgrgck.CalendarInvitationResponseStateRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_irmbkh1p.CalendarInvitationResponseView?>()) {
      return (data != null
              ? _irmbkh1p.CalendarInvitationResponseView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ilccsff7.CalendarInvitationSourceKind?>()) {
      return (data != null
              ? _ilccsff7.CalendarInvitationSourceKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3yqoryt.CalendarInvitationSourceRecord?>()) {
      return (data != null
              ? _i3yqoryt.CalendarInvitationSourceRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itix6re9.CalendarInvitationSourceView?>()) {
      return (data != null
              ? _itix6re9.CalendarInvitationSourceView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifs5c7mj.CalendarInvitationView?>()) {
      return (data != null
              ? _ifs5c7mj.CalendarInvitationView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3iolgr8.CalendarItemCategoryGroup?>()) {
      return (data != null
              ? _i3iolgr8.CalendarItemCategoryGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itx19m90.CalendarItemComment?>()) {
      return (data != null
              ? _itx19m90.CalendarItemComment.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i12tuyl5.CalendarItemTextMetadataField?>()) {
      return (data != null
              ? _i12tuyl5.CalendarItemTextMetadataField.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ikwi9ryb.CalendarItemTextMetadataPatch?>()) {
      return (data != null
              ? _ikwi9ryb.CalendarItemTextMetadataPatch.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i759fw3a.CalendarMetadataUpdateRequest?>()) {
      return (data != null
              ? _i759fw3a.CalendarMetadataUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iq0eskk0.CalendarMutationReceipt?>()) {
      return (data != null
              ? _iq0eskk0.CalendarMutationReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itts4qyp.CalendarNoRuleFallback?>()) {
      return (data != null
              ? _itts4qyp.CalendarNoRuleFallback.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0jfcg0j.CalendarPage?>()) {
      return (data != null ? _i0jfcg0j.CalendarPage.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i9m9yk5s.CalendarPresentationUpdateRequest?>()) {
      return (data != null
              ? _i9m9yk5s.CalendarPresentationUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iyrimg3m.CalendarProtocolIdentity?>()) {
      return (data != null
              ? _iyrimg3m.CalendarProtocolIdentity.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itchuj1l.CalendarProtocolMetadata?>()) {
      return (data != null
              ? _itchuj1l.CalendarProtocolMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iyawor89.CalendarProtocolMetadataUpdateRequest?>()) {
      return (data != null
              ? _iyawor89.CalendarProtocolMetadataUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifsfk5xq.CalendarRefreshHint?>()) {
      return (data != null
              ? _ifsfk5xq.CalendarRefreshHint.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i64utb1e.CalendarSchedulingAttemptRecord?>()) {
      return (data != null
              ? _i64utb1e.CalendarSchedulingAttemptRecord.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_i577nx0c.CalendarSchedulingAttendeeResponseRecord?>()) {
      return (data != null
              ? _i577nx0c.CalendarSchedulingAttendeeResponseRecord.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_itopoldj.CalendarSchedulingAttendeeResponseView?>()) {
      return (data != null
              ? _itopoldj.CalendarSchedulingAttendeeResponseView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i4uu6f5m.CalendarSchedulingCancelRequest?>()) {
      return (data != null
              ? _i4uu6f5m.CalendarSchedulingCancelRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iuidcanh.CalendarSchedulingDeliveryRecord?>()) {
      return (data != null
              ? _iuidcanh.CalendarSchedulingDeliveryRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_it5jr5tm.CalendarSchedulingDeliveryState?>()) {
      return (data != null
              ? _it5jr5tm.CalendarSchedulingDeliveryState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i63ky642.CalendarSchedulingDeliveryView?>()) {
      return (data != null
              ? _i63ky642.CalendarSchedulingDeliveryView.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_i8yevrne.CalendarSchedulingInstanceResponsesView?>()) {
      return (data != null
              ? _i8yevrne.CalendarSchedulingInstanceResponsesView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihlqfuoo.CalendarSchedulingMeetingRecord?>()) {
      return (data != null
              ? _ihlqfuoo.CalendarSchedulingMeetingRecord.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_ia8x0otq.CalendarSchedulingOccurrenceCancelRequest?>()) {
      return (data != null
              ? _ia8x0otq.CalendarSchedulingOccurrenceCancelRequest.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t ==
        _is.getType<_io2t7cny.CalendarSchedulingOccurrenceRestoreRequest?>()) {
      return (data != null
              ? _io2t7cny.CalendarSchedulingOccurrenceRestoreRequest.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_iot0xi24.CalendarSchedulingParticipation?>()) {
      return (data != null
              ? _iot0xi24.CalendarSchedulingParticipation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_il38fbb4.CalendarSchedulingPublicationKind?>()) {
      return (data != null
              ? _il38fbb4.CalendarSchedulingPublicationKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivo2647b.CalendarSchedulingPublicationRecord?>()) {
      return (data != null
              ? _ivo2647b.CalendarSchedulingPublicationRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izftntkw.CalendarSchedulingReceipt?>()) {
      return (data != null
              ? _izftntkw.CalendarSchedulingReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iv2f51nm.CalendarSchedulingReopenRequest?>()) {
      return (data != null
              ? _iv2f51nm.CalendarSchedulingReopenRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqen8jmy.CalendarSchedulingReplyDocument?>()) {
      return (data != null
              ? _iqen8jmy.CalendarSchedulingReplyDocument.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ikqvfn4d.CalendarSchedulingReplyOutcome?>()) {
      return (data != null
              ? _ikqvfn4d.CalendarSchedulingReplyOutcome.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwdevo6h.CalendarSchedulingReplyReceipt?>()) {
      return (data != null
              ? _iwdevo6h.CalendarSchedulingReplyReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0njii35.CalendarSchedulingReplyReceiptRecord?>()) {
      return (data != null
              ? _i0njii35.CalendarSchedulingReplyReceiptRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ia855khw.CalendarSchedulingReplySourceRecord?>()) {
      return (data != null
              ? _ia855khw.CalendarSchedulingReplySourceRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i2peuvqu.CalendarSchedulingReplySourceView?>()) {
      return (data != null
              ? _i2peuvqu.CalendarSchedulingReplySourceView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixbxcx0r.CalendarSchedulingResponsesView?>()) {
      return (data != null
              ? _ixbxcx0r.CalendarSchedulingResponsesView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_icabxeyo.CalendarSchedulingSaveRequest?>()) {
      return (data != null
              ? _icabxeyo.CalendarSchedulingSaveRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_is73suzs.CalendarSchedulingView?>()) {
      return (data != null
              ? _is73suzs.CalendarSchedulingView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9mvj7kq.CalendarScopeRecord?>()) {
      return (data != null
              ? _i9mvj7kq.CalendarScopeRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i66us6t1.CalendarSettingsUpdateRequest?>()) {
      return (data != null
              ? _i66us6t1.CalendarSettingsUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i41idnki.CalendarSubjectAction?>()) {
      return (data != null
              ? _i41idnki.CalendarSubjectAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_imo3vsmf.CalendarSubjectAvailability?>()) {
      return (data != null
              ? _imo3vsmf.CalendarSubjectAvailability.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iuzjb8ji.CalendarSubjectChangeRequest?>()) {
      return (data != null
              ? _iuzjb8ji.CalendarSubjectChangeRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i76vfrve.CalendarSubjectRecord?>()) {
      return (data != null
              ? _i76vfrve.CalendarSubjectRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ir7mv910.CalendarSubjectView?>()) {
      return (data != null
              ? _ir7mv910.CalendarSubjectView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixppc388.CalendarSupplementalMetadata?>()) {
      return (data != null
              ? _ixppc388.CalendarSupplementalMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_iqx8dg15.CalendarSupplementalMetadataUpdateRequest?>()) {
      return (data != null
              ? _iqx8dg15.CalendarSupplementalMetadataUpdateRequest.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_ih5e3u6u.CalendarTaskAssignee?>()) {
      return (data != null
              ? _ih5e3u6u.CalendarTaskAssignee.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipa1soge.CalendarTaskAssignmentsRequest?>()) {
      return (data != null
              ? _ipa1soge.CalendarTaskAssignmentsRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_if7nbvl8.CalendarTaskContent?>()) {
      return (data != null
              ? _if7nbvl8.CalendarTaskContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihwe765g.CalendarTaskContentAction?>()) {
      return (data != null
              ? _ihwe765g.CalendarTaskContentAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i496rta0.CalendarTaskContentField?>()) {
      return (data != null
              ? _i496rta0.CalendarTaskContentField.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iipxdkwq.CalendarTaskCreateRequest?>()) {
      return (data != null
              ? _iipxdkwq.CalendarTaskCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ic8eedzw.CalendarTaskDataRecord?>()) {
      return (data != null
              ? _ic8eedzw.CalendarTaskDataRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i10340hl.CalendarTaskExportRequest?>()) {
      return (data != null
              ? _i10340hl.CalendarTaskExportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i71mi7ri.CalendarTaskExportSelection?>()) {
      return (data != null
              ? _i71mi7ri.CalendarTaskExportSelection.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_isemqyyv.CalendarTaskFieldGroup?>()) {
      return (data != null
              ? _isemqyyv.CalendarTaskFieldGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idhalyap.CalendarTaskHistoryEntry?>()) {
      return (data != null
              ? _idhalyap.CalendarTaskHistoryEntry.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibsdsx6x.CalendarTaskHistoryPage?>()) {
      return (data != null
              ? _ibsdsx6x.CalendarTaskHistoryPage.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1vdb6de.CalendarTaskHistoryQuery?>()) {
      return (data != null
              ? _i1vdb6de.CalendarTaskHistoryQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6c7wo1p.CalendarTaskHistoryRecord?>()) {
      return (data != null
              ? _i6c7wo1p.CalendarTaskHistoryRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqsm27bn.CalendarTaskImportBaseline?>()) {
      return (data != null
              ? _iqsm27bn.CalendarTaskImportBaseline.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_isw8fcv3.CalendarTaskImportRequest?>()) {
      return (data != null
              ? _isw8fcv3.CalendarTaskImportRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izrxa9vy.CalendarTaskImportResult?>()) {
      return (data != null
              ? _izrxa9vy.CalendarTaskImportResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_isgg83d3.CalendarTaskOccurrence?>()) {
      return (data != null
              ? _isgg83d3.CalendarTaskOccurrence.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_irmu5f0n.CalendarTaskOccurrenceContent?>()) {
      return (data != null
              ? _irmu5f0n.CalendarTaskOccurrenceContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_isfljanw.CalendarTaskOccurrenceContentChange?>()) {
      return (data != null
              ? _isfljanw.CalendarTaskOccurrenceContentChange.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iw338tmt.CalendarTaskOccurrenceContentRequest?>()) {
      return (data != null
              ? _iw338tmt.CalendarTaskOccurrenceContentRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_id9j5e7y.CalendarTaskOccurrencePreview?>()) {
      return (data != null
              ? _id9j5e7y.CalendarTaskOccurrencePreview.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_irw24ank.CalendarTaskOccurrenceProgressRequest?>()) {
      return (data != null
              ? _irw24ank.CalendarTaskOccurrenceProgressRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixy579wj.CalendarTaskOccurrenceQuery?>()) {
      return (data != null
              ? _ixy579wj.CalendarTaskOccurrenceQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3t5ry4r.CalendarTaskOccurrenceRecord?>()) {
      return (data != null
              ? _i3t5ry4r.CalendarTaskOccurrenceRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ii9v7kdj.CalendarTaskOccurrenceTimingRequest?>()) {
      return (data != null
              ? _ii9v7kdj.CalendarTaskOccurrenceTimingRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i276ujfk.CalendarTaskPage?>()) {
      return (data != null ? _i276ujfk.CalendarTaskPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikcsq95s.CalendarTaskProgress?>()) {
      return (data != null
              ? _ikcsq95s.CalendarTaskProgress.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6s7yrua.CalendarTaskProgressAction?>()) {
      return (data != null
              ? _i6s7yrua.CalendarTaskProgressAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_in6zlsph.CalendarTaskProgressRequest?>()) {
      return (data != null
              ? _in6zlsph.CalendarTaskProgressRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iz9t6x1i.CalendarTaskProtocolVersion?>()) {
      return (data != null
              ? _iz9t6x1i.CalendarTaskProtocolVersion.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_im9usybn.CalendarTaskReceipt?>()) {
      return (data != null
              ? _im9usybn.CalendarTaskReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_irbiaacf.CalendarTaskRecord?>()) {
      return (data != null ? _irbiaacf.CalendarTaskRecord.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ib5z6spp.CalendarTaskReplaceReceipt?>()) {
      return (data != null
              ? _ib5z6spp.CalendarTaskReplaceReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibpx2vjc.CalendarTaskReplaceRequest?>()) {
      return (data != null
              ? _ibpx2vjc.CalendarTaskReplaceRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iyf2qeht.CalendarTaskReplaceResult?>()) {
      return (data != null
              ? _iyf2qeht.CalendarTaskReplaceResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i00avof0.CalendarTaskSourceAlarm?>()) {
      return (data != null
              ? _i00avof0.CalendarTaskSourceAlarm.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iuzk4pe3.CalendarTaskSourceAttachment?>()) {
      return (data != null
              ? _iuzk4pe3.CalendarTaskSourceAttachment.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iic8eifm.CalendarTaskSourceCategoryGroup?>()) {
      return (data != null
              ? _iic8eifm.CalendarTaskSourceCategoryGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivqadd6c.CalendarTaskSourceComponent?>()) {
      return (data != null
              ? _ivqadd6c.CalendarTaskSourceComponent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_im8khkr9.CalendarTaskSourceDuration?>()) {
      return (data != null
              ? _im8khkr9.CalendarTaskSourceDuration.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i76q6myt.CalendarTaskSourceMetadata?>()) {
      return (data != null
              ? _i76q6myt.CalendarTaskSourceMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iw6fme2j.CalendarTaskSourceParticipant?>()) {
      return (data != null
              ? _iw6fme2j.CalendarTaskSourceParticipant.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izyrs4yl.CalendarTaskSourceRelationship?>()) {
      return (data != null
              ? _izyrs4yl.CalendarTaskSourceRelationship.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_it1pm24a.CalendarTaskSourceState?>()) {
      return (data != null
              ? _it1pm24a.CalendarTaskSourceState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9mnuab5.CalendarTaskSourceText?>()) {
      return (data != null
              ? _i9mnuab5.CalendarTaskSourceText.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iiahrdev.CalendarTaskStatus?>()) {
      return (data != null ? _iiahrdev.CalendarTaskStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_it8lhctx.CalendarTaskTextMetadataRequest?>()) {
      return (data != null
              ? _it8lhctx.CalendarTaskTextMetadataRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ijhc2xsq.CalendarTaskTimeKind?>()) {
      return (data != null
              ? _ijhc2xsq.CalendarTaskTimeKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9h8y8lg.CalendarTaskTiming?>()) {
      return (data != null ? _i9h8y8lg.CalendarTaskTiming.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_in7cuxyg.CalendarTaskUpdateRequest?>()) {
      return (data != null
              ? _in7cuxyg.CalendarTaskUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ii3yrr21.CalendarTaskView?>()) {
      return (data != null ? _ii3yrr21.CalendarTaskView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iffxqqc7.CalendarTextParameters?>()) {
      return (data != null
              ? _iffxqqc7.CalendarTextParameters.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itcy22f3.CalendarTextVariant?>()) {
      return (data != null
              ? _itcy22f3.CalendarTextVariant.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivspd2q7.CalendarView?>()) {
      return (data != null ? _ivspd2q7.CalendarView.fromJson(data) : null) as T;
    }
    if (t == List<_i7xuciin.CalendarAlarmFiringView>) {
      return (data as List)
              .map((e) => deserialize<_i7xuciin.CalendarAlarmFiringView>(e))
              .toList()
          as T;
    }
    if (t == List<_ixqjnkie.CalendarAlarmActionView>) {
      return (data as List)
              .map((e) => deserialize<_ixqjnkie.CalendarAlarmActionView>(e))
              .toList()
          as T;
    }
    if (t == List<_irif99jb.CalendarAlarmDefinition>) {
      return (data as List)
              .map((e) => deserialize<_irif99jb.CalendarAlarmDefinition>(e))
              .toList()
          as T;
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
    if (t == _is.getType<List<String>?>()) {
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
    if (t == _is.getType<List<_ip5gybl4.CalendarAvailabilityExtension>?>()) {
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
        _is.getType<List<_iywbqexh.CalendarAvailabilityCategoryGroup>?>()) {
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
    if (t == _is.getType<List<_itw42wa3.CalendarAvailabilityText>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_itw42wa3.CalendarAvailabilityText>(e),
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
    if (t == _is.getType<List<_id5ke9r5.CalendarAvailabilityOpeningEdits>?>()) {
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
    if (t == _is.getType<List<_ieswiaty.CalendarEventTiming>?>()) {
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
        _is
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
    if (t == List<_iiw2d6as.CalendarAvailabilityReplaceReceipt>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_iiw2d6as.CalendarAvailabilityReplaceReceipt>(
                      e,
                    ),
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
    if (t == _is.getType<List<_iffxqqc7.CalendarTextParameters?>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_iffxqqc7.CalendarTextParameters?>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i73hgz1s.CalendarFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_i73hgz1s.CalendarFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_isemqyyv.CalendarTaskFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_isemqyyv.CalendarTaskFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_isemqyyv.CalendarTaskFieldGroup>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_isemqyyv.CalendarTaskFieldGroup>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_iftiwkuj.CalendarEventFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_iftiwkuj.CalendarEventFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_iftiwkuj.CalendarEventFieldGroup>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_iftiwkuj.CalendarEventFieldGroup>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_iiajf89w.CalendarEventResourceGroup>) {
      return (data as List)
              .map((e) => deserialize<_iiajf89w.CalendarEventResourceGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_ijug927r.CalendarEventExportSelection>) {
      return (data as List)
              .map(
                (e) => deserialize<_ijug927r.CalendarEventExportSelection>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_i500bvo7.CalendarEventReceipt>) {
      return (data as List)
              .map((e) => deserialize<_i500bvo7.CalendarEventReceipt>(e))
              .toList()
          as T;
    }
    if (t == List<_iikl1ga8.CalendarEventOccurrenceContentChange>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_iikl1ga8.CalendarEventOccurrenceContentChange>(
                      e,
                    ),
              )
              .toList()
          as T;
    }
    if (t == List<_i6x6hm0f.CalendarEventOccurrenceListItem>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_i6x6hm0f.CalendarEventOccurrenceListItem>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_iqr733fy.CalendarEventView>) {
      return (data as List)
              .map((e) => deserialize<_iqr733fy.CalendarEventView>(e))
              .toList()
          as T;
    }
    if (t == List<_iml0c566.CalendarEventOverrideProtocolState>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_iml0c566.CalendarEventOverrideProtocolState>(
                      e,
                    ),
              )
              .toList()
          as T;
    }
    if (t == List<_ii1x02jx.CalendarEventReplaceReceipt>) {
      return (data as List)
              .map((e) => deserialize<_ii1x02jx.CalendarEventReplaceReceipt>(e))
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
    if (t == List<_iui013s0.CalendarEventSourceCategoryGroup>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_iui013s0.CalendarEventSourceCategoryGroup>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_iwa6orjz.CalendarEventSourceText>) {
      return (data as List)
              .map((e) => deserialize<_iwa6orjz.CalendarEventSourceText>(e))
              .toList()
          as T;
    }
    if (t == List<_iypom7ai.CalendarEventSourceParticipant>) {
      return (data as List)
              .map(
                (e) => deserialize<_iypom7ai.CalendarEventSourceParticipant>(e),
              )
              .toList()
          as T;
    }
    if (t == _is.getType<List<_iypom7ai.CalendarEventSourceParticipant>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<_iypom7ai.CalendarEventSourceParticipant>(
                            e,
                          ),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_iksc4ly9.CalendarEventSourceRelationship>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_iksc4ly9.CalendarEventSourceRelationship>(e),
              )
              .toList()
          as T;
    }
    if (t == _is.getType<List<_iksc4ly9.CalendarEventSourceRelationship>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<
                            _iksc4ly9.CalendarEventSourceRelationship
                          >(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i20i9qxn.CalendarEventSourceAttachment>) {
      return (data as List)
              .map(
                (e) => deserialize<_i20i9qxn.CalendarEventSourceAttachment>(e),
              )
              .toList()
          as T;
    }
    if (t == _is.getType<List<_i20i9qxn.CalendarEventSourceAttachment>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<_i20i9qxn.CalendarEventSourceAttachment>(
                            e,
                          ),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i4dai4jt.CalendarEventSourceAlarm>) {
      return (data as List)
              .map((e) => deserialize<_i4dai4jt.CalendarEventSourceAlarm>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_i4dai4jt.CalendarEventSourceAlarm>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_i4dai4jt.CalendarEventSourceAlarm>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == _is.getType<List<_iiajf89w.CalendarEventResourceGroup>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<_iiajf89w.CalendarEventResourceGroup>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == Map<String, List<String>>) {
      return (data as Map).map(
            (k, v) =>
                MapEntry(deserialize<String>(k), deserialize<List<String>>(v)),
          )
          as T;
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
    if (t == List<_im5iu6ju.CalendarEventOccurrenceProtocolVersion>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      _im5iu6ju.CalendarEventOccurrenceProtocolVersion
                    >(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _is
            .getType<
              List<_im5iu6ju.CalendarEventOccurrenceProtocolVersion>?
            >()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<
                            _im5iu6ju.CalendarEventOccurrenceProtocolVersion
                          >(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i3iolgr8.CalendarItemCategoryGroup>) {
      return (data as List)
              .map((e) => deserialize<_i3iolgr8.CalendarItemCategoryGroup>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_i3iolgr8.CalendarItemCategoryGroup>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) =>
                          deserialize<_i3iolgr8.CalendarItemCategoryGroup>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_itx19m90.CalendarItemComment>) {
      return (data as List)
              .map((e) => deserialize<_itx19m90.CalendarItemComment>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_itx19m90.CalendarItemComment>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_itx19m90.CalendarItemComment>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i82zcrxb.CalendarFreeBusyPeriod>) {
      return (data as List)
              .map((e) => deserialize<_i82zcrxb.CalendarFreeBusyPeriod>(e))
              .toList()
          as T;
    }
    if (t == List<_i12tuyl5.CalendarItemTextMetadataField>) {
      return (data as List)
              .map(
                (e) => deserialize<_i12tuyl5.CalendarItemTextMetadataField>(e),
              )
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
    if (t == List<_itopoldj.CalendarSchedulingAttendeeResponseView>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      _itopoldj.CalendarSchedulingAttendeeResponseView
                    >(e),
              )
              .toList()
          as T;
    }
    if (t == List<_i63ky642.CalendarSchedulingDeliveryView>) {
      return (data as List)
              .map(
                (e) => deserialize<_i63ky642.CalendarSchedulingDeliveryView>(e),
              )
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
    if (t == List<_ih5e3u6u.CalendarTaskAssignee>) {
      return (data as List)
              .map((e) => deserialize<_ih5e3u6u.CalendarTaskAssignee>(e))
              .toList()
          as T;
    }
    if (t == List<_i71mi7ri.CalendarTaskExportSelection>) {
      return (data as List)
              .map((e) => deserialize<_i71mi7ri.CalendarTaskExportSelection>(e))
              .toList()
          as T;
    }
    if (t == List<_idhalyap.CalendarTaskHistoryEntry>) {
      return (data as List)
              .map((e) => deserialize<_idhalyap.CalendarTaskHistoryEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_im9usybn.CalendarTaskReceipt>) {
      return (data as List)
              .map((e) => deserialize<_im9usybn.CalendarTaskReceipt>(e))
              .toList()
          as T;
    }
    if (t == List<_isfljanw.CalendarTaskOccurrenceContentChange>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_isfljanw.CalendarTaskOccurrenceContentChange>(
                      e,
                    ),
              )
              .toList()
          as T;
    }
    if (t == List<_isgg83d3.CalendarTaskOccurrence>) {
      return (data as List)
              .map((e) => deserialize<_isgg83d3.CalendarTaskOccurrence>(e))
              .toList()
          as T;
    }
    if (t == List<_ii3yrr21.CalendarTaskView>) {
      return (data as List)
              .map((e) => deserialize<_ii3yrr21.CalendarTaskView>(e))
              .toList()
          as T;
    }
    if (t == List<_ib5z6spp.CalendarTaskReplaceReceipt>) {
      return (data as List)
              .map((e) => deserialize<_ib5z6spp.CalendarTaskReplaceReceipt>(e))
              .toList()
          as T;
    }
    if (t == List<_iic8eifm.CalendarTaskSourceCategoryGroup>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_iic8eifm.CalendarTaskSourceCategoryGroup>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_i9mnuab5.CalendarTaskSourceText>) {
      return (data as List)
              .map((e) => deserialize<_i9mnuab5.CalendarTaskSourceText>(e))
              .toList()
          as T;
    }
    if (t == List<_iw6fme2j.CalendarTaskSourceParticipant>) {
      return (data as List)
              .map(
                (e) => deserialize<_iw6fme2j.CalendarTaskSourceParticipant>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_izyrs4yl.CalendarTaskSourceRelationship>) {
      return (data as List)
              .map(
                (e) => deserialize<_izyrs4yl.CalendarTaskSourceRelationship>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_iuzk4pe3.CalendarTaskSourceAttachment>) {
      return (data as List)
              .map(
                (e) => deserialize<_iuzk4pe3.CalendarTaskSourceAttachment>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_i00avof0.CalendarTaskSourceAlarm>) {
      return (data as List)
              .map((e) => deserialize<_i00avof0.CalendarTaskSourceAlarm>(e))
              .toList()
          as T;
    }
    if (t == List<_ivqadd6c.CalendarTaskSourceComponent>) {
      return (data as List)
              .map((e) => deserialize<_ivqadd6c.CalendarTaskSourceComponent>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_ih5e3u6u.CalendarTaskAssignee>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ih5e3u6u.CalendarTaskAssignee>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_izvxtiv8.CalendarAlarmView>) {
      return (data as List)
              .map((e) => deserialize<_izvxtiv8.CalendarAlarmView>(e))
              .toList()
          as T;
    }
    if (t == List<_i6fuga80.CalendarAvailabilityView>) {
      return (data as List)
              .map((e) => deserialize<_i6fuga80.CalendarAvailabilityView>(e))
              .toList()
          as T;
    }
    if (t == List<_i3d02yxy.CalendarFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_i3d02yxy.CalendarFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_iwx7nyid.CalendarSubjectView>) {
      return (data as List)
              .map((e) => deserialize<_iwx7nyid.CalendarSubjectView>(e))
              .toList()
          as T;
    }
    if (t == List<_ivnk0jd2.CalendarSchedulingReplySourceView>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<_ivnk0jd2.CalendarSchedulingReplySourceView>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_il5gdr09.CalendarEventFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_il5gdr09.CalendarEventFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_ienzv1fd.CalendarInvitationView>) {
      return (data as List)
              .map((e) => deserialize<_ienzv1fd.CalendarInvitationView>(e))
              .toList()
          as T;
    }
    if (t == List<_ifi5u0vl.CalendarInvitationSourceView>) {
      return (data as List)
              .map(
                (e) => deserialize<_ifi5u0vl.CalendarInvitationSourceView>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_icy7qc8h.CalendarInvitationResponseActivityView>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      _icy7qc8h.CalendarInvitationResponseActivityView
                    >(e),
              )
              .toList()
          as T;
    }
    if (t == List<_ik0gz7r1.CalendarTaskFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_ik0gz7r1.CalendarTaskFieldGroup>(e))
              .toList()
          as T;
    }
    try {
      return _ik9lwgjh.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ihv8htej.CalendarAlarmActionKind => 'CalendarAlarmActionKind',
      _ipt2851n.CalendarAlarmActionRecord => 'CalendarAlarmActionRecord',
      _ivvkdcds.CalendarAlarmActionRequest => 'CalendarAlarmActionRequest',
      _ixqjnkie.CalendarAlarmActionView => 'CalendarAlarmActionView',
      _ik5ajwd4.CalendarAlarmActivityKind => 'CalendarAlarmActivityKind',
      _iruhg2yq.CalendarAlarmActivityPage => 'CalendarAlarmActivityPage',
      _iv448ru6.CalendarAlarmAnchor => 'CalendarAlarmAnchor',
      _iu47syqa.CalendarAlarmCreateRequest => 'CalendarAlarmCreateRequest',
      _irif99jb.CalendarAlarmDefinition => 'CalendarAlarmDefinition',
      _i1qnv8jf.CalendarAlarmDuration => 'CalendarAlarmDuration',
      _i8okwxwj.CalendarAlarmFiringKind => 'CalendarAlarmFiringKind',
      _ihgh57kq.CalendarAlarmFiringRecord => 'CalendarAlarmFiringRecord',
      _ihos0r46.CalendarAlarmFiringState => 'CalendarAlarmFiringState',
      _i7xuciin.CalendarAlarmFiringView => 'CalendarAlarmFiringView',
      _iiyuulin.CalendarAlarmParent => 'CalendarAlarmParent',
      _ig3zti62.CalendarAlarmParentKind => 'CalendarAlarmParentKind',
      _iid4j1lu.CalendarAlarmPlanRecord => 'CalendarAlarmPlanRecord',
      _irtomk7p.CalendarAlarmPlanStatus => 'CalendarAlarmPlanStatus',
      _iralscit.CalendarAlarmRecord => 'CalendarAlarmRecord',
      _ig76ry9v.CalendarAlarmSourceTimings => 'CalendarAlarmSourceTimings',
      _im2lo7e9.CalendarAlarmUpdateRequest => 'CalendarAlarmUpdateRequest',
      _ie7u1nxa.CalendarAlarmView => 'CalendarAlarmView',
      _iywbqexh.CalendarAvailabilityCategoryGroup =>
        'CalendarAvailabilityCategoryGroup',
      _iucw7bzg.CalendarAvailabilityClass => 'CalendarAvailabilityClass',
      _ifxxil5c.CalendarAvailabilityContent => 'CalendarAvailabilityContent',
      _iwwk2w9d.CalendarAvailabilityCreateRequest =>
        'CalendarAvailabilityCreateRequest',
      _ie9je6js.CalendarAvailabilityDataRecord =>
        'CalendarAvailabilityDataRecord',
      _ipddbn84.CalendarAvailabilityExportRequest =>
        'CalendarAvailabilityExportRequest',
      _incs3y0d.CalendarAvailabilityExportSelection =>
        'CalendarAvailabilityExportSelection',
      _ip5gybl4.CalendarAvailabilityExtension =>
        'CalendarAvailabilityExtension',
      _ivv22qfn.CalendarAvailabilityImportBaseline =>
        'CalendarAvailabilityImportBaseline',
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
      _inwzhb5r.CalendarAvailabilityRecord => 'CalendarAvailabilityRecord',
      _iiw2d6as.CalendarAvailabilityReplaceReceipt =>
        'CalendarAvailabilityReplaceReceipt',
      _ir631vai.CalendarAvailabilityReplaceRequest =>
        'CalendarAvailabilityReplaceRequest',
      _itahk50i.CalendarAvailabilityReplaceResult =>
        'CalendarAvailabilityReplaceResult',
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
      _iptr9vfe.CalendarCursorRecord => 'CalendarCursorRecord',
      _ix6i00tg.CalendarDataRecord => 'CalendarDataRecord',
      _iq7751s4.CalendarEventByDay => 'CalendarEventByDay',
      _i1bb5k1r.CalendarEventCivil => 'CalendarEventCivil',
      _id4cvk34.CalendarEventContent => 'CalendarEventContent',
      _ing6pwn6.CalendarEventContentAction => 'CalendarEventContentAction',
      _ipyf9yt3.CalendarEventContentField => 'CalendarEventContentField',
      _i0orp171.CalendarEventCreateRequest => 'CalendarEventCreateRequest',
      _i23wc83s.CalendarEventDataRecord => 'CalendarEventDataRecord',
      _i0bvx67a.CalendarEventDescriptiveMetadata =>
        'CalendarEventDescriptiveMetadata',
      _ibq0xtgn.CalendarEventDescriptiveRequest =>
        'CalendarEventDescriptiveRequest',
      _idn2i48l.CalendarEventDuration => 'CalendarEventDuration',
      _ifgpnp3a.CalendarEventExportRequest => 'CalendarEventExportRequest',
      _ijug927r.CalendarEventExportSelection => 'CalendarEventExportSelection',
      _iftiwkuj.CalendarEventFieldGroup => 'CalendarEventFieldGroup',
      _i2q54gr5.CalendarEventFrequency => 'CalendarEventFrequency',
      _imbjv41e.CalendarEventFutureOverride => 'CalendarEventFutureOverride',
      _iloy79hd.CalendarEventGeographicPosition =>
        'CalendarEventGeographicPosition',
      _iblybidp.CalendarEventImportBaseline => 'CalendarEventImportBaseline',
      _ixo47kyf.CalendarEventImportRequest => 'CalendarEventImportRequest',
      _iduchdjm.CalendarEventImportResult => 'CalendarEventImportResult',
      _isyqnyev.CalendarEventOccurrence => 'CalendarEventOccurrence',
      _icnciyzp.CalendarEventOccurrenceAction =>
        'CalendarEventOccurrenceAction',
      _i7imxrlz.CalendarEventOccurrenceChange =>
        'CalendarEventOccurrenceChange',
      _io4uvjqi.CalendarEventOccurrenceContent =>
        'CalendarEventOccurrenceContent',
      _iikl1ga8.CalendarEventOccurrenceContentChange =>
        'CalendarEventOccurrenceContentChange',
      _iaip8d0d.CalendarEventOccurrenceContentRequest =>
        'CalendarEventOccurrenceContentRequest',
      _ij33d3qn.CalendarEventOccurrenceCursorState =>
        'CalendarEventOccurrenceCursorState',
      _i6x6hm0f.CalendarEventOccurrenceListItem =>
        'CalendarEventOccurrenceListItem',
      _iayv5gu3.CalendarEventOccurrenceListQuery =>
        'CalendarEventOccurrenceListQuery',
      _ifm4sinz.CalendarEventOccurrencePage => 'CalendarEventOccurrencePage',
      _i1a4s0rt.CalendarEventOccurrencePreview =>
        'CalendarEventOccurrencePreview',
      _im5iu6ju.CalendarEventOccurrenceProtocolVersion =>
        'CalendarEventOccurrenceProtocolVersion',
      _ivs4ir3j.CalendarEventOccurrenceQuery => 'CalendarEventOccurrenceQuery',
      _ipbrznp8.CalendarEventOrigin => 'CalendarEventOrigin',
      _iml0c566.CalendarEventOverrideProtocolState =>
        'CalendarEventOverrideProtocolState',
      _iaayjmj1.CalendarEventPage => 'CalendarEventPage',
      _i8iqsbco.CalendarEventProtocolState => 'CalendarEventProtocolState',
      _iblfo3t0.CalendarEventProtocolVersion => 'CalendarEventProtocolVersion',
      _i500bvo7.CalendarEventReceipt => 'CalendarEventReceipt',
      _ilvoe14z.CalendarEventRecord => 'CalendarEventRecord',
      _iqxs44bf.CalendarEventRecurrence => 'CalendarEventRecurrence',
      _ii1x02jx.CalendarEventReplaceReceipt => 'CalendarEventReplaceReceipt',
      _ikx66n5r.CalendarEventReplaceRequest => 'CalendarEventReplaceRequest',
      _ipzyec4h.CalendarEventReplaceResult => 'CalendarEventReplaceResult',
      _iiajf89w.CalendarEventResourceGroup => 'CalendarEventResourceGroup',
      _iovyzq1q.CalendarEventRule => 'CalendarEventRule',
      _iq1kxi25.CalendarEventSingleOverride => 'CalendarEventSingleOverride',
      _i4dai4jt.CalendarEventSourceAlarm => 'CalendarEventSourceAlarm',
      _i20i9qxn.CalendarEventSourceAttachment =>
        'CalendarEventSourceAttachment',
      _iui013s0.CalendarEventSourceCategoryGroup =>
        'CalendarEventSourceCategoryGroup',
      _ie9apnqv.CalendarEventSourceDuration => 'CalendarEventSourceDuration',
      _ic57ts5d.CalendarEventSourceMetadata => 'CalendarEventSourceMetadata',
      _iypom7ai.CalendarEventSourceParticipant =>
        'CalendarEventSourceParticipant',
      _iksc4ly9.CalendarEventSourceRelationship =>
        'CalendarEventSourceRelationship',
      _iwa6orjz.CalendarEventSourceText => 'CalendarEventSourceText',
      _ivzxk9bc.CalendarEventStatus => 'CalendarEventStatus',
      _i3kbbl30.CalendarEventStatusRequest => 'CalendarEventStatusRequest',
      _iswwug34.CalendarEventTextMetadataRequest =>
        'CalendarEventTextMetadataRequest',
      _isfojy12.CalendarEventTextParameters => 'CalendarEventTextParameters',
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
      _ibccnfmr.CalendarIdentityRecord => 'CalendarIdentityRecord',
      _igf45b52.CalendarImageLink => 'CalendarImageLink',
      _ib1s0vrr.CalendarInvitationAdoptionReceipt =>
        'CalendarInvitationAdoptionReceipt',
      _imimov8l.CalendarInvitationAdoptionRequest =>
        'CalendarInvitationAdoptionRequest',
      _i29jhvb3.CalendarInvitationApplicationRecord =>
        'CalendarInvitationApplicationRecord',
      _i8svxjh1.CalendarInvitationApplicationView =>
        'CalendarInvitationApplicationView',
      _ic2yh4ry.CalendarInvitationApplyReceipt =>
        'CalendarInvitationApplyReceipt',
      _iivrx0vm.CalendarInvitationApplyRequest =>
        'CalendarInvitationApplyRequest',
      _iwcng7rp.CalendarInvitationDocument => 'CalendarInvitationDocument',
      _ibnm4ujx.CalendarInvitationLinkRecord => 'CalendarInvitationLinkRecord',
      _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord =>
        'CalendarInvitationOccurrenceApplicationRecord',
      _i15b7t0e.CalendarInvitationOccurrenceApplicationView =>
        'CalendarInvitationOccurrenceApplicationView',
      _iyajy5op.CalendarInvitationOccurrenceApplyReceipt =>
        'CalendarInvitationOccurrenceApplyReceipt',
      _ioottw62.CalendarInvitationOccurrenceApplyRequest =>
        'CalendarInvitationOccurrenceApplyRequest',
      _i98zwsq8.CalendarInvitationOutcome => 'CalendarInvitationOutcome',
      _iy372k0z.CalendarInvitationReceipt => 'CalendarInvitationReceipt',
      _i1bc5dpy.CalendarInvitationReceiptRecord =>
        'CalendarInvitationReceiptRecord',
      _igigle43.CalendarInvitationRecord => 'CalendarInvitationRecord',
      _ip5pithb.CalendarInvitationResponseActivityView =>
        'CalendarInvitationResponseActivityView',
      _i3vdxm7o.CalendarInvitationResponseAttemptRecord =>
        'CalendarInvitationResponseAttemptRecord',
      _il64jj9v.CalendarInvitationResponseChoice =>
        'CalendarInvitationResponseChoice',
      _iw51ozry.CalendarInvitationResponseDeliveryState =>
        'CalendarInvitationResponseDeliveryState',
      _ig6twu0d.CalendarInvitationResponseReceipt =>
        'CalendarInvitationResponseReceipt',
      _iifvkijq.CalendarInvitationResponseRecord =>
        'CalendarInvitationResponseRecord',
      _iw3qnr12.CalendarInvitationResponseRequest =>
        'CalendarInvitationResponseRequest',
      _i5cgrgck.CalendarInvitationResponseStateRecord =>
        'CalendarInvitationResponseStateRecord',
      _irmbkh1p.CalendarInvitationResponseView =>
        'CalendarInvitationResponseView',
      _ilccsff7.CalendarInvitationSourceKind => 'CalendarInvitationSourceKind',
      _i3yqoryt.CalendarInvitationSourceRecord =>
        'CalendarInvitationSourceRecord',
      _itix6re9.CalendarInvitationSourceView => 'CalendarInvitationSourceView',
      _ifs5c7mj.CalendarInvitationView => 'CalendarInvitationView',
      _i3iolgr8.CalendarItemCategoryGroup => 'CalendarItemCategoryGroup',
      _itx19m90.CalendarItemComment => 'CalendarItemComment',
      _i12tuyl5.CalendarItemTextMetadataField =>
        'CalendarItemTextMetadataField',
      _ikwi9ryb.CalendarItemTextMetadataPatch =>
        'CalendarItemTextMetadataPatch',
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
      _i64utb1e.CalendarSchedulingAttemptRecord =>
        'CalendarSchedulingAttemptRecord',
      _i577nx0c.CalendarSchedulingAttendeeResponseRecord =>
        'CalendarSchedulingAttendeeResponseRecord',
      _itopoldj.CalendarSchedulingAttendeeResponseView =>
        'CalendarSchedulingAttendeeResponseView',
      _i4uu6f5m.CalendarSchedulingCancelRequest =>
        'CalendarSchedulingCancelRequest',
      _iuidcanh.CalendarSchedulingDeliveryRecord =>
        'CalendarSchedulingDeliveryRecord',
      _it5jr5tm.CalendarSchedulingDeliveryState =>
        'CalendarSchedulingDeliveryState',
      _i63ky642.CalendarSchedulingDeliveryView =>
        'CalendarSchedulingDeliveryView',
      _i8yevrne.CalendarSchedulingInstanceResponsesView =>
        'CalendarSchedulingInstanceResponsesView',
      _ihlqfuoo.CalendarSchedulingMeetingRecord =>
        'CalendarSchedulingMeetingRecord',
      _ia8x0otq.CalendarSchedulingOccurrenceCancelRequest =>
        'CalendarSchedulingOccurrenceCancelRequest',
      _io2t7cny.CalendarSchedulingOccurrenceRestoreRequest =>
        'CalendarSchedulingOccurrenceRestoreRequest',
      _iot0xi24.CalendarSchedulingParticipation =>
        'CalendarSchedulingParticipation',
      _il38fbb4.CalendarSchedulingPublicationKind =>
        'CalendarSchedulingPublicationKind',
      _ivo2647b.CalendarSchedulingPublicationRecord =>
        'CalendarSchedulingPublicationRecord',
      _izftntkw.CalendarSchedulingReceipt => 'CalendarSchedulingReceipt',
      _iv2f51nm.CalendarSchedulingReopenRequest =>
        'CalendarSchedulingReopenRequest',
      _iqen8jmy.CalendarSchedulingReplyDocument =>
        'CalendarSchedulingReplyDocument',
      _ikqvfn4d.CalendarSchedulingReplyOutcome =>
        'CalendarSchedulingReplyOutcome',
      _iwdevo6h.CalendarSchedulingReplyReceipt =>
        'CalendarSchedulingReplyReceipt',
      _i0njii35.CalendarSchedulingReplyReceiptRecord =>
        'CalendarSchedulingReplyReceiptRecord',
      _ia855khw.CalendarSchedulingReplySourceRecord =>
        'CalendarSchedulingReplySourceRecord',
      _i2peuvqu.CalendarSchedulingReplySourceView =>
        'CalendarSchedulingReplySourceView',
      _ixbxcx0r.CalendarSchedulingResponsesView =>
        'CalendarSchedulingResponsesView',
      _icabxeyo.CalendarSchedulingSaveRequest =>
        'CalendarSchedulingSaveRequest',
      _is73suzs.CalendarSchedulingView => 'CalendarSchedulingView',
      _i9mvj7kq.CalendarScopeRecord => 'CalendarScopeRecord',
      _i66us6t1.CalendarSettingsUpdateRequest =>
        'CalendarSettingsUpdateRequest',
      _i41idnki.CalendarSubjectAction => 'CalendarSubjectAction',
      _imo3vsmf.CalendarSubjectAvailability => 'CalendarSubjectAvailability',
      _iuzjb8ji.CalendarSubjectChangeRequest => 'CalendarSubjectChangeRequest',
      _i76vfrve.CalendarSubjectRecord => 'CalendarSubjectRecord',
      _ir7mv910.CalendarSubjectView => 'CalendarSubjectView',
      _ixppc388.CalendarSupplementalMetadata => 'CalendarSupplementalMetadata',
      _iqx8dg15.CalendarSupplementalMetadataUpdateRequest =>
        'CalendarSupplementalMetadataUpdateRequest',
      _ih5e3u6u.CalendarTaskAssignee => 'CalendarTaskAssignee',
      _ipa1soge.CalendarTaskAssignmentsRequest =>
        'CalendarTaskAssignmentsRequest',
      _if7nbvl8.CalendarTaskContent => 'CalendarTaskContent',
      _ihwe765g.CalendarTaskContentAction => 'CalendarTaskContentAction',
      _i496rta0.CalendarTaskContentField => 'CalendarTaskContentField',
      _iipxdkwq.CalendarTaskCreateRequest => 'CalendarTaskCreateRequest',
      _ic8eedzw.CalendarTaskDataRecord => 'CalendarTaskDataRecord',
      _i10340hl.CalendarTaskExportRequest => 'CalendarTaskExportRequest',
      _i71mi7ri.CalendarTaskExportSelection => 'CalendarTaskExportSelection',
      _isemqyyv.CalendarTaskFieldGroup => 'CalendarTaskFieldGroup',
      _idhalyap.CalendarTaskHistoryEntry => 'CalendarTaskHistoryEntry',
      _ibsdsx6x.CalendarTaskHistoryPage => 'CalendarTaskHistoryPage',
      _i1vdb6de.CalendarTaskHistoryQuery => 'CalendarTaskHistoryQuery',
      _i6c7wo1p.CalendarTaskHistoryRecord => 'CalendarTaskHistoryRecord',
      _iqsm27bn.CalendarTaskImportBaseline => 'CalendarTaskImportBaseline',
      _isw8fcv3.CalendarTaskImportRequest => 'CalendarTaskImportRequest',
      _izrxa9vy.CalendarTaskImportResult => 'CalendarTaskImportResult',
      _isgg83d3.CalendarTaskOccurrence => 'CalendarTaskOccurrence',
      _irmu5f0n.CalendarTaskOccurrenceContent =>
        'CalendarTaskOccurrenceContent',
      _isfljanw.CalendarTaskOccurrenceContentChange =>
        'CalendarTaskOccurrenceContentChange',
      _iw338tmt.CalendarTaskOccurrenceContentRequest =>
        'CalendarTaskOccurrenceContentRequest',
      _id9j5e7y.CalendarTaskOccurrencePreview =>
        'CalendarTaskOccurrencePreview',
      _irw24ank.CalendarTaskOccurrenceProgressRequest =>
        'CalendarTaskOccurrenceProgressRequest',
      _ixy579wj.CalendarTaskOccurrenceQuery => 'CalendarTaskOccurrenceQuery',
      _i3t5ry4r.CalendarTaskOccurrenceRecord => 'CalendarTaskOccurrenceRecord',
      _ii9v7kdj.CalendarTaskOccurrenceTimingRequest =>
        'CalendarTaskOccurrenceTimingRequest',
      _i276ujfk.CalendarTaskPage => 'CalendarTaskPage',
      _ikcsq95s.CalendarTaskProgress => 'CalendarTaskProgress',
      _i6s7yrua.CalendarTaskProgressAction => 'CalendarTaskProgressAction',
      _in6zlsph.CalendarTaskProgressRequest => 'CalendarTaskProgressRequest',
      _iz9t6x1i.CalendarTaskProtocolVersion => 'CalendarTaskProtocolVersion',
      _im9usybn.CalendarTaskReceipt => 'CalendarTaskReceipt',
      _irbiaacf.CalendarTaskRecord => 'CalendarTaskRecord',
      _ib5z6spp.CalendarTaskReplaceReceipt => 'CalendarTaskReplaceReceipt',
      _ibpx2vjc.CalendarTaskReplaceRequest => 'CalendarTaskReplaceRequest',
      _iyf2qeht.CalendarTaskReplaceResult => 'CalendarTaskReplaceResult',
      _i00avof0.CalendarTaskSourceAlarm => 'CalendarTaskSourceAlarm',
      _iuzk4pe3.CalendarTaskSourceAttachment => 'CalendarTaskSourceAttachment',
      _iic8eifm.CalendarTaskSourceCategoryGroup =>
        'CalendarTaskSourceCategoryGroup',
      _ivqadd6c.CalendarTaskSourceComponent => 'CalendarTaskSourceComponent',
      _im8khkr9.CalendarTaskSourceDuration => 'CalendarTaskSourceDuration',
      _i76q6myt.CalendarTaskSourceMetadata => 'CalendarTaskSourceMetadata',
      _iw6fme2j.CalendarTaskSourceParticipant =>
        'CalendarTaskSourceParticipant',
      _izyrs4yl.CalendarTaskSourceRelationship =>
        'CalendarTaskSourceRelationship',
      _it1pm24a.CalendarTaskSourceState => 'CalendarTaskSourceState',
      _i9mnuab5.CalendarTaskSourceText => 'CalendarTaskSourceText',
      _iiahrdev.CalendarTaskStatus => 'CalendarTaskStatus',
      _it8lhctx.CalendarTaskTextMetadataRequest =>
        'CalendarTaskTextMetadataRequest',
      _ijhc2xsq.CalendarTaskTimeKind => 'CalendarTaskTimeKind',
      _i9h8y8lg.CalendarTaskTiming => 'CalendarTaskTiming',
      _in7cuxyg.CalendarTaskUpdateRequest => 'CalendarTaskUpdateRequest',
      _ii3yrr21.CalendarTaskView => 'CalendarTaskView',
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
      case _ihv8htej.CalendarAlarmActionKind():
        return 'CalendarAlarmActionKind';
      case _ipt2851n.CalendarAlarmActionRecord():
        return 'CalendarAlarmActionRecord';
      case _ivvkdcds.CalendarAlarmActionRequest():
        return 'CalendarAlarmActionRequest';
      case _ixqjnkie.CalendarAlarmActionView():
        return 'CalendarAlarmActionView';
      case _ik5ajwd4.CalendarAlarmActivityKind():
        return 'CalendarAlarmActivityKind';
      case _iruhg2yq.CalendarAlarmActivityPage():
        return 'CalendarAlarmActivityPage';
      case _iv448ru6.CalendarAlarmAnchor():
        return 'CalendarAlarmAnchor';
      case _iu47syqa.CalendarAlarmCreateRequest():
        return 'CalendarAlarmCreateRequest';
      case _irif99jb.CalendarAlarmDefinition():
        return 'CalendarAlarmDefinition';
      case _i1qnv8jf.CalendarAlarmDuration():
        return 'CalendarAlarmDuration';
      case _i8okwxwj.CalendarAlarmFiringKind():
        return 'CalendarAlarmFiringKind';
      case _ihgh57kq.CalendarAlarmFiringRecord():
        return 'CalendarAlarmFiringRecord';
      case _ihos0r46.CalendarAlarmFiringState():
        return 'CalendarAlarmFiringState';
      case _i7xuciin.CalendarAlarmFiringView():
        return 'CalendarAlarmFiringView';
      case _iiyuulin.CalendarAlarmParent():
        return 'CalendarAlarmParent';
      case _ig3zti62.CalendarAlarmParentKind():
        return 'CalendarAlarmParentKind';
      case _iid4j1lu.CalendarAlarmPlanRecord():
        return 'CalendarAlarmPlanRecord';
      case _irtomk7p.CalendarAlarmPlanStatus():
        return 'CalendarAlarmPlanStatus';
      case _iralscit.CalendarAlarmRecord():
        return 'CalendarAlarmRecord';
      case _ig76ry9v.CalendarAlarmSourceTimings():
        return 'CalendarAlarmSourceTimings';
      case _im2lo7e9.CalendarAlarmUpdateRequest():
        return 'CalendarAlarmUpdateRequest';
      case _ie7u1nxa.CalendarAlarmView():
        return 'CalendarAlarmView';
      case _iywbqexh.CalendarAvailabilityCategoryGroup():
        return 'CalendarAvailabilityCategoryGroup';
      case _iucw7bzg.CalendarAvailabilityClass():
        return 'CalendarAvailabilityClass';
      case _ifxxil5c.CalendarAvailabilityContent():
        return 'CalendarAvailabilityContent';
      case _iwwk2w9d.CalendarAvailabilityCreateRequest():
        return 'CalendarAvailabilityCreateRequest';
      case _ie9je6js.CalendarAvailabilityDataRecord():
        return 'CalendarAvailabilityDataRecord';
      case _ipddbn84.CalendarAvailabilityExportRequest():
        return 'CalendarAvailabilityExportRequest';
      case _incs3y0d.CalendarAvailabilityExportSelection():
        return 'CalendarAvailabilityExportSelection';
      case _ip5gybl4.CalendarAvailabilityExtension():
        return 'CalendarAvailabilityExtension';
      case _ivv22qfn.CalendarAvailabilityImportBaseline():
        return 'CalendarAvailabilityImportBaseline';
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
      case _inwzhb5r.CalendarAvailabilityRecord():
        return 'CalendarAvailabilityRecord';
      case _iiw2d6as.CalendarAvailabilityReplaceReceipt():
        return 'CalendarAvailabilityReplaceReceipt';
      case _ir631vai.CalendarAvailabilityReplaceRequest():
        return 'CalendarAvailabilityReplaceRequest';
      case _itahk50i.CalendarAvailabilityReplaceResult():
        return 'CalendarAvailabilityReplaceResult';
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
      case _iptr9vfe.CalendarCursorRecord():
        return 'CalendarCursorRecord';
      case _ix6i00tg.CalendarDataRecord():
        return 'CalendarDataRecord';
      case _iq7751s4.CalendarEventByDay():
        return 'CalendarEventByDay';
      case _i1bb5k1r.CalendarEventCivil():
        return 'CalendarEventCivil';
      case _id4cvk34.CalendarEventContent():
        return 'CalendarEventContent';
      case _ing6pwn6.CalendarEventContentAction():
        return 'CalendarEventContentAction';
      case _ipyf9yt3.CalendarEventContentField():
        return 'CalendarEventContentField';
      case _i0orp171.CalendarEventCreateRequest():
        return 'CalendarEventCreateRequest';
      case _i23wc83s.CalendarEventDataRecord():
        return 'CalendarEventDataRecord';
      case _i0bvx67a.CalendarEventDescriptiveMetadata():
        return 'CalendarEventDescriptiveMetadata';
      case _ibq0xtgn.CalendarEventDescriptiveRequest():
        return 'CalendarEventDescriptiveRequest';
      case _idn2i48l.CalendarEventDuration():
        return 'CalendarEventDuration';
      case _ifgpnp3a.CalendarEventExportRequest():
        return 'CalendarEventExportRequest';
      case _ijug927r.CalendarEventExportSelection():
        return 'CalendarEventExportSelection';
      case _iftiwkuj.CalendarEventFieldGroup():
        return 'CalendarEventFieldGroup';
      case _i2q54gr5.CalendarEventFrequency():
        return 'CalendarEventFrequency';
      case _imbjv41e.CalendarEventFutureOverride():
        return 'CalendarEventFutureOverride';
      case _iloy79hd.CalendarEventGeographicPosition():
        return 'CalendarEventGeographicPosition';
      case _iblybidp.CalendarEventImportBaseline():
        return 'CalendarEventImportBaseline';
      case _ixo47kyf.CalendarEventImportRequest():
        return 'CalendarEventImportRequest';
      case _iduchdjm.CalendarEventImportResult():
        return 'CalendarEventImportResult';
      case _isyqnyev.CalendarEventOccurrence():
        return 'CalendarEventOccurrence';
      case _icnciyzp.CalendarEventOccurrenceAction():
        return 'CalendarEventOccurrenceAction';
      case _i7imxrlz.CalendarEventOccurrenceChange():
        return 'CalendarEventOccurrenceChange';
      case _io4uvjqi.CalendarEventOccurrenceContent():
        return 'CalendarEventOccurrenceContent';
      case _iikl1ga8.CalendarEventOccurrenceContentChange():
        return 'CalendarEventOccurrenceContentChange';
      case _iaip8d0d.CalendarEventOccurrenceContentRequest():
        return 'CalendarEventOccurrenceContentRequest';
      case _ij33d3qn.CalendarEventOccurrenceCursorState():
        return 'CalendarEventOccurrenceCursorState';
      case _i6x6hm0f.CalendarEventOccurrenceListItem():
        return 'CalendarEventOccurrenceListItem';
      case _iayv5gu3.CalendarEventOccurrenceListQuery():
        return 'CalendarEventOccurrenceListQuery';
      case _ifm4sinz.CalendarEventOccurrencePage():
        return 'CalendarEventOccurrencePage';
      case _i1a4s0rt.CalendarEventOccurrencePreview():
        return 'CalendarEventOccurrencePreview';
      case _im5iu6ju.CalendarEventOccurrenceProtocolVersion():
        return 'CalendarEventOccurrenceProtocolVersion';
      case _ivs4ir3j.CalendarEventOccurrenceQuery():
        return 'CalendarEventOccurrenceQuery';
      case _ipbrznp8.CalendarEventOrigin():
        return 'CalendarEventOrigin';
      case _iml0c566.CalendarEventOverrideProtocolState():
        return 'CalendarEventOverrideProtocolState';
      case _iaayjmj1.CalendarEventPage():
        return 'CalendarEventPage';
      case _i8iqsbco.CalendarEventProtocolState():
        return 'CalendarEventProtocolState';
      case _iblfo3t0.CalendarEventProtocolVersion():
        return 'CalendarEventProtocolVersion';
      case _i500bvo7.CalendarEventReceipt():
        return 'CalendarEventReceipt';
      case _ilvoe14z.CalendarEventRecord():
        return 'CalendarEventRecord';
      case _iqxs44bf.CalendarEventRecurrence():
        return 'CalendarEventRecurrence';
      case _ii1x02jx.CalendarEventReplaceReceipt():
        return 'CalendarEventReplaceReceipt';
      case _ikx66n5r.CalendarEventReplaceRequest():
        return 'CalendarEventReplaceRequest';
      case _ipzyec4h.CalendarEventReplaceResult():
        return 'CalendarEventReplaceResult';
      case _iiajf89w.CalendarEventResourceGroup():
        return 'CalendarEventResourceGroup';
      case _iovyzq1q.CalendarEventRule():
        return 'CalendarEventRule';
      case _iq1kxi25.CalendarEventSingleOverride():
        return 'CalendarEventSingleOverride';
      case _i4dai4jt.CalendarEventSourceAlarm():
        return 'CalendarEventSourceAlarm';
      case _i20i9qxn.CalendarEventSourceAttachment():
        return 'CalendarEventSourceAttachment';
      case _iui013s0.CalendarEventSourceCategoryGroup():
        return 'CalendarEventSourceCategoryGroup';
      case _ie9apnqv.CalendarEventSourceDuration():
        return 'CalendarEventSourceDuration';
      case _ic57ts5d.CalendarEventSourceMetadata():
        return 'CalendarEventSourceMetadata';
      case _iypom7ai.CalendarEventSourceParticipant():
        return 'CalendarEventSourceParticipant';
      case _iksc4ly9.CalendarEventSourceRelationship():
        return 'CalendarEventSourceRelationship';
      case _iwa6orjz.CalendarEventSourceText():
        return 'CalendarEventSourceText';
      case _ivzxk9bc.CalendarEventStatus():
        return 'CalendarEventStatus';
      case _i3kbbl30.CalendarEventStatusRequest():
        return 'CalendarEventStatusRequest';
      case _iswwug34.CalendarEventTextMetadataRequest():
        return 'CalendarEventTextMetadataRequest';
      case _isfojy12.CalendarEventTextParameters():
        return 'CalendarEventTextParameters';
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
      case _ibccnfmr.CalendarIdentityRecord():
        return 'CalendarIdentityRecord';
      case _igf45b52.CalendarImageLink():
        return 'CalendarImageLink';
      case _ib1s0vrr.CalendarInvitationAdoptionReceipt():
        return 'CalendarInvitationAdoptionReceipt';
      case _imimov8l.CalendarInvitationAdoptionRequest():
        return 'CalendarInvitationAdoptionRequest';
      case _i29jhvb3.CalendarInvitationApplicationRecord():
        return 'CalendarInvitationApplicationRecord';
      case _i8svxjh1.CalendarInvitationApplicationView():
        return 'CalendarInvitationApplicationView';
      case _ic2yh4ry.CalendarInvitationApplyReceipt():
        return 'CalendarInvitationApplyReceipt';
      case _iivrx0vm.CalendarInvitationApplyRequest():
        return 'CalendarInvitationApplyRequest';
      case _iwcng7rp.CalendarInvitationDocument():
        return 'CalendarInvitationDocument';
      case _ibnm4ujx.CalendarInvitationLinkRecord():
        return 'CalendarInvitationLinkRecord';
      case _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord():
        return 'CalendarInvitationOccurrenceApplicationRecord';
      case _i15b7t0e.CalendarInvitationOccurrenceApplicationView():
        return 'CalendarInvitationOccurrenceApplicationView';
      case _iyajy5op.CalendarInvitationOccurrenceApplyReceipt():
        return 'CalendarInvitationOccurrenceApplyReceipt';
      case _ioottw62.CalendarInvitationOccurrenceApplyRequest():
        return 'CalendarInvitationOccurrenceApplyRequest';
      case _i98zwsq8.CalendarInvitationOutcome():
        return 'CalendarInvitationOutcome';
      case _iy372k0z.CalendarInvitationReceipt():
        return 'CalendarInvitationReceipt';
      case _i1bc5dpy.CalendarInvitationReceiptRecord():
        return 'CalendarInvitationReceiptRecord';
      case _igigle43.CalendarInvitationRecord():
        return 'CalendarInvitationRecord';
      case _ip5pithb.CalendarInvitationResponseActivityView():
        return 'CalendarInvitationResponseActivityView';
      case _i3vdxm7o.CalendarInvitationResponseAttemptRecord():
        return 'CalendarInvitationResponseAttemptRecord';
      case _il64jj9v.CalendarInvitationResponseChoice():
        return 'CalendarInvitationResponseChoice';
      case _iw51ozry.CalendarInvitationResponseDeliveryState():
        return 'CalendarInvitationResponseDeliveryState';
      case _ig6twu0d.CalendarInvitationResponseReceipt():
        return 'CalendarInvitationResponseReceipt';
      case _iifvkijq.CalendarInvitationResponseRecord():
        return 'CalendarInvitationResponseRecord';
      case _iw3qnr12.CalendarInvitationResponseRequest():
        return 'CalendarInvitationResponseRequest';
      case _i5cgrgck.CalendarInvitationResponseStateRecord():
        return 'CalendarInvitationResponseStateRecord';
      case _irmbkh1p.CalendarInvitationResponseView():
        return 'CalendarInvitationResponseView';
      case _ilccsff7.CalendarInvitationSourceKind():
        return 'CalendarInvitationSourceKind';
      case _i3yqoryt.CalendarInvitationSourceRecord():
        return 'CalendarInvitationSourceRecord';
      case _itix6re9.CalendarInvitationSourceView():
        return 'CalendarInvitationSourceView';
      case _ifs5c7mj.CalendarInvitationView():
        return 'CalendarInvitationView';
      case _i3iolgr8.CalendarItemCategoryGroup():
        return 'CalendarItemCategoryGroup';
      case _itx19m90.CalendarItemComment():
        return 'CalendarItemComment';
      case _i12tuyl5.CalendarItemTextMetadataField():
        return 'CalendarItemTextMetadataField';
      case _ikwi9ryb.CalendarItemTextMetadataPatch():
        return 'CalendarItemTextMetadataPatch';
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
      case _i64utb1e.CalendarSchedulingAttemptRecord():
        return 'CalendarSchedulingAttemptRecord';
      case _i577nx0c.CalendarSchedulingAttendeeResponseRecord():
        return 'CalendarSchedulingAttendeeResponseRecord';
      case _itopoldj.CalendarSchedulingAttendeeResponseView():
        return 'CalendarSchedulingAttendeeResponseView';
      case _i4uu6f5m.CalendarSchedulingCancelRequest():
        return 'CalendarSchedulingCancelRequest';
      case _iuidcanh.CalendarSchedulingDeliveryRecord():
        return 'CalendarSchedulingDeliveryRecord';
      case _it5jr5tm.CalendarSchedulingDeliveryState():
        return 'CalendarSchedulingDeliveryState';
      case _i63ky642.CalendarSchedulingDeliveryView():
        return 'CalendarSchedulingDeliveryView';
      case _i8yevrne.CalendarSchedulingInstanceResponsesView():
        return 'CalendarSchedulingInstanceResponsesView';
      case _ihlqfuoo.CalendarSchedulingMeetingRecord():
        return 'CalendarSchedulingMeetingRecord';
      case _ia8x0otq.CalendarSchedulingOccurrenceCancelRequest():
        return 'CalendarSchedulingOccurrenceCancelRequest';
      case _io2t7cny.CalendarSchedulingOccurrenceRestoreRequest():
        return 'CalendarSchedulingOccurrenceRestoreRequest';
      case _iot0xi24.CalendarSchedulingParticipation():
        return 'CalendarSchedulingParticipation';
      case _il38fbb4.CalendarSchedulingPublicationKind():
        return 'CalendarSchedulingPublicationKind';
      case _ivo2647b.CalendarSchedulingPublicationRecord():
        return 'CalendarSchedulingPublicationRecord';
      case _izftntkw.CalendarSchedulingReceipt():
        return 'CalendarSchedulingReceipt';
      case _iv2f51nm.CalendarSchedulingReopenRequest():
        return 'CalendarSchedulingReopenRequest';
      case _iqen8jmy.CalendarSchedulingReplyDocument():
        return 'CalendarSchedulingReplyDocument';
      case _ikqvfn4d.CalendarSchedulingReplyOutcome():
        return 'CalendarSchedulingReplyOutcome';
      case _iwdevo6h.CalendarSchedulingReplyReceipt():
        return 'CalendarSchedulingReplyReceipt';
      case _i0njii35.CalendarSchedulingReplyReceiptRecord():
        return 'CalendarSchedulingReplyReceiptRecord';
      case _ia855khw.CalendarSchedulingReplySourceRecord():
        return 'CalendarSchedulingReplySourceRecord';
      case _i2peuvqu.CalendarSchedulingReplySourceView():
        return 'CalendarSchedulingReplySourceView';
      case _ixbxcx0r.CalendarSchedulingResponsesView():
        return 'CalendarSchedulingResponsesView';
      case _icabxeyo.CalendarSchedulingSaveRequest():
        return 'CalendarSchedulingSaveRequest';
      case _is73suzs.CalendarSchedulingView():
        return 'CalendarSchedulingView';
      case _i9mvj7kq.CalendarScopeRecord():
        return 'CalendarScopeRecord';
      case _i66us6t1.CalendarSettingsUpdateRequest():
        return 'CalendarSettingsUpdateRequest';
      case _i41idnki.CalendarSubjectAction():
        return 'CalendarSubjectAction';
      case _imo3vsmf.CalendarSubjectAvailability():
        return 'CalendarSubjectAvailability';
      case _iuzjb8ji.CalendarSubjectChangeRequest():
        return 'CalendarSubjectChangeRequest';
      case _i76vfrve.CalendarSubjectRecord():
        return 'CalendarSubjectRecord';
      case _ir7mv910.CalendarSubjectView():
        return 'CalendarSubjectView';
      case _ixppc388.CalendarSupplementalMetadata():
        return 'CalendarSupplementalMetadata';
      case _iqx8dg15.CalendarSupplementalMetadataUpdateRequest():
        return 'CalendarSupplementalMetadataUpdateRequest';
      case _ih5e3u6u.CalendarTaskAssignee():
        return 'CalendarTaskAssignee';
      case _ipa1soge.CalendarTaskAssignmentsRequest():
        return 'CalendarTaskAssignmentsRequest';
      case _if7nbvl8.CalendarTaskContent():
        return 'CalendarTaskContent';
      case _ihwe765g.CalendarTaskContentAction():
        return 'CalendarTaskContentAction';
      case _i496rta0.CalendarTaskContentField():
        return 'CalendarTaskContentField';
      case _iipxdkwq.CalendarTaskCreateRequest():
        return 'CalendarTaskCreateRequest';
      case _ic8eedzw.CalendarTaskDataRecord():
        return 'CalendarTaskDataRecord';
      case _i10340hl.CalendarTaskExportRequest():
        return 'CalendarTaskExportRequest';
      case _i71mi7ri.CalendarTaskExportSelection():
        return 'CalendarTaskExportSelection';
      case _isemqyyv.CalendarTaskFieldGroup():
        return 'CalendarTaskFieldGroup';
      case _idhalyap.CalendarTaskHistoryEntry():
        return 'CalendarTaskHistoryEntry';
      case _ibsdsx6x.CalendarTaskHistoryPage():
        return 'CalendarTaskHistoryPage';
      case _i1vdb6de.CalendarTaskHistoryQuery():
        return 'CalendarTaskHistoryQuery';
      case _i6c7wo1p.CalendarTaskHistoryRecord():
        return 'CalendarTaskHistoryRecord';
      case _iqsm27bn.CalendarTaskImportBaseline():
        return 'CalendarTaskImportBaseline';
      case _isw8fcv3.CalendarTaskImportRequest():
        return 'CalendarTaskImportRequest';
      case _izrxa9vy.CalendarTaskImportResult():
        return 'CalendarTaskImportResult';
      case _isgg83d3.CalendarTaskOccurrence():
        return 'CalendarTaskOccurrence';
      case _irmu5f0n.CalendarTaskOccurrenceContent():
        return 'CalendarTaskOccurrenceContent';
      case _isfljanw.CalendarTaskOccurrenceContentChange():
        return 'CalendarTaskOccurrenceContentChange';
      case _iw338tmt.CalendarTaskOccurrenceContentRequest():
        return 'CalendarTaskOccurrenceContentRequest';
      case _id9j5e7y.CalendarTaskOccurrencePreview():
        return 'CalendarTaskOccurrencePreview';
      case _irw24ank.CalendarTaskOccurrenceProgressRequest():
        return 'CalendarTaskOccurrenceProgressRequest';
      case _ixy579wj.CalendarTaskOccurrenceQuery():
        return 'CalendarTaskOccurrenceQuery';
      case _i3t5ry4r.CalendarTaskOccurrenceRecord():
        return 'CalendarTaskOccurrenceRecord';
      case _ii9v7kdj.CalendarTaskOccurrenceTimingRequest():
        return 'CalendarTaskOccurrenceTimingRequest';
      case _i276ujfk.CalendarTaskPage():
        return 'CalendarTaskPage';
      case _ikcsq95s.CalendarTaskProgress():
        return 'CalendarTaskProgress';
      case _i6s7yrua.CalendarTaskProgressAction():
        return 'CalendarTaskProgressAction';
      case _in6zlsph.CalendarTaskProgressRequest():
        return 'CalendarTaskProgressRequest';
      case _iz9t6x1i.CalendarTaskProtocolVersion():
        return 'CalendarTaskProtocolVersion';
      case _im9usybn.CalendarTaskReceipt():
        return 'CalendarTaskReceipt';
      case _irbiaacf.CalendarTaskRecord():
        return 'CalendarTaskRecord';
      case _ib5z6spp.CalendarTaskReplaceReceipt():
        return 'CalendarTaskReplaceReceipt';
      case _ibpx2vjc.CalendarTaskReplaceRequest():
        return 'CalendarTaskReplaceRequest';
      case _iyf2qeht.CalendarTaskReplaceResult():
        return 'CalendarTaskReplaceResult';
      case _i00avof0.CalendarTaskSourceAlarm():
        return 'CalendarTaskSourceAlarm';
      case _iuzk4pe3.CalendarTaskSourceAttachment():
        return 'CalendarTaskSourceAttachment';
      case _iic8eifm.CalendarTaskSourceCategoryGroup():
        return 'CalendarTaskSourceCategoryGroup';
      case _ivqadd6c.CalendarTaskSourceComponent():
        return 'CalendarTaskSourceComponent';
      case _im8khkr9.CalendarTaskSourceDuration():
        return 'CalendarTaskSourceDuration';
      case _i76q6myt.CalendarTaskSourceMetadata():
        return 'CalendarTaskSourceMetadata';
      case _iw6fme2j.CalendarTaskSourceParticipant():
        return 'CalendarTaskSourceParticipant';
      case _izyrs4yl.CalendarTaskSourceRelationship():
        return 'CalendarTaskSourceRelationship';
      case _it1pm24a.CalendarTaskSourceState():
        return 'CalendarTaskSourceState';
      case _i9mnuab5.CalendarTaskSourceText():
        return 'CalendarTaskSourceText';
      case _iiahrdev.CalendarTaskStatus():
        return 'CalendarTaskStatus';
      case _it8lhctx.CalendarTaskTextMetadataRequest():
        return 'CalendarTaskTextMetadataRequest';
      case _ijhc2xsq.CalendarTaskTimeKind():
        return 'CalendarTaskTimeKind';
      case _i9h8y8lg.CalendarTaskTiming():
        return 'CalendarTaskTiming';
      case _in7cuxyg.CalendarTaskUpdateRequest():
        return 'CalendarTaskUpdateRequest';
      case _ii3yrr21.CalendarTaskView():
        return 'CalendarTaskView';
      case _iffxqqc7.CalendarTextParameters():
        return 'CalendarTextParameters';
      case _itcy22f3.CalendarTextVariant():
        return 'CalendarTextVariant';
      case _ivspd2q7.CalendarView():
        return 'CalendarView';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CalendarAlarmActionKind') {
      return deserialize<_ihv8htej.CalendarAlarmActionKind>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmActionRecord') {
      return deserialize<_ipt2851n.CalendarAlarmActionRecord>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmActionRequest') {
      return deserialize<_ivvkdcds.CalendarAlarmActionRequest>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmActionView') {
      return deserialize<_ixqjnkie.CalendarAlarmActionView>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmActivityKind') {
      return deserialize<_ik5ajwd4.CalendarAlarmActivityKind>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmActivityPage') {
      return deserialize<_iruhg2yq.CalendarAlarmActivityPage>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmAnchor') {
      return deserialize<_iv448ru6.CalendarAlarmAnchor>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmCreateRequest') {
      return deserialize<_iu47syqa.CalendarAlarmCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmDefinition') {
      return deserialize<_irif99jb.CalendarAlarmDefinition>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmDuration') {
      return deserialize<_i1qnv8jf.CalendarAlarmDuration>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmFiringKind') {
      return deserialize<_i8okwxwj.CalendarAlarmFiringKind>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmFiringRecord') {
      return deserialize<_ihgh57kq.CalendarAlarmFiringRecord>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmFiringState') {
      return deserialize<_ihos0r46.CalendarAlarmFiringState>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmFiringView') {
      return deserialize<_i7xuciin.CalendarAlarmFiringView>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmParent') {
      return deserialize<_iiyuulin.CalendarAlarmParent>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmParentKind') {
      return deserialize<_ig3zti62.CalendarAlarmParentKind>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmPlanRecord') {
      return deserialize<_iid4j1lu.CalendarAlarmPlanRecord>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmPlanStatus') {
      return deserialize<_irtomk7p.CalendarAlarmPlanStatus>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmRecord') {
      return deserialize<_iralscit.CalendarAlarmRecord>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmSourceTimings') {
      return deserialize<_ig76ry9v.CalendarAlarmSourceTimings>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmUpdateRequest') {
      return deserialize<_im2lo7e9.CalendarAlarmUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarAlarmView') {
      return deserialize<_ie7u1nxa.CalendarAlarmView>(data['data']);
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
    if (dataClassName == 'CalendarAvailabilityDataRecord') {
      return deserialize<_ie9je6js.CalendarAvailabilityDataRecord>(
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
    if (dataClassName == 'CalendarAvailabilityImportBaseline') {
      return deserialize<_ivv22qfn.CalendarAvailabilityImportBaseline>(
        data['data'],
      );
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
    if (dataClassName == 'CalendarAvailabilityRecord') {
      return deserialize<_inwzhb5r.CalendarAvailabilityRecord>(data['data']);
    }
    if (dataClassName == 'CalendarAvailabilityReplaceReceipt') {
      return deserialize<_iiw2d6as.CalendarAvailabilityReplaceReceipt>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityReplaceRequest') {
      return deserialize<_ir631vai.CalendarAvailabilityReplaceRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarAvailabilityReplaceResult') {
      return deserialize<_itahk50i.CalendarAvailabilityReplaceResult>(
        data['data'],
      );
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
    if (dataClassName == 'CalendarCursorRecord') {
      return deserialize<_iptr9vfe.CalendarCursorRecord>(data['data']);
    }
    if (dataClassName == 'CalendarDataRecord') {
      return deserialize<_ix6i00tg.CalendarDataRecord>(data['data']);
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
    if (dataClassName == 'CalendarEventContentAction') {
      return deserialize<_ing6pwn6.CalendarEventContentAction>(data['data']);
    }
    if (dataClassName == 'CalendarEventContentField') {
      return deserialize<_ipyf9yt3.CalendarEventContentField>(data['data']);
    }
    if (dataClassName == 'CalendarEventCreateRequest') {
      return deserialize<_i0orp171.CalendarEventCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventDataRecord') {
      return deserialize<_i23wc83s.CalendarEventDataRecord>(data['data']);
    }
    if (dataClassName == 'CalendarEventDescriptiveMetadata') {
      return deserialize<_i0bvx67a.CalendarEventDescriptiveMetadata>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventDescriptiveRequest') {
      return deserialize<_ibq0xtgn.CalendarEventDescriptiveRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventDuration') {
      return deserialize<_idn2i48l.CalendarEventDuration>(data['data']);
    }
    if (dataClassName == 'CalendarEventExportRequest') {
      return deserialize<_ifgpnp3a.CalendarEventExportRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventExportSelection') {
      return deserialize<_ijug927r.CalendarEventExportSelection>(data['data']);
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
    if (dataClassName == 'CalendarEventGeographicPosition') {
      return deserialize<_iloy79hd.CalendarEventGeographicPosition>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventImportBaseline') {
      return deserialize<_iblybidp.CalendarEventImportBaseline>(data['data']);
    }
    if (dataClassName == 'CalendarEventImportRequest') {
      return deserialize<_ixo47kyf.CalendarEventImportRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventImportResult') {
      return deserialize<_iduchdjm.CalendarEventImportResult>(data['data']);
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
    if (dataClassName == 'CalendarEventOccurrenceContent') {
      return deserialize<_io4uvjqi.CalendarEventOccurrenceContent>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceContentChange') {
      return deserialize<_iikl1ga8.CalendarEventOccurrenceContentChange>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceContentRequest') {
      return deserialize<_iaip8d0d.CalendarEventOccurrenceContentRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceCursorState') {
      return deserialize<_ij33d3qn.CalendarEventOccurrenceCursorState>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceListItem') {
      return deserialize<_i6x6hm0f.CalendarEventOccurrenceListItem>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceListQuery') {
      return deserialize<_iayv5gu3.CalendarEventOccurrenceListQuery>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrencePage') {
      return deserialize<_ifm4sinz.CalendarEventOccurrencePage>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrencePreview') {
      return deserialize<_i1a4s0rt.CalendarEventOccurrencePreview>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceProtocolVersion') {
      return deserialize<_im5iu6ju.CalendarEventOccurrenceProtocolVersion>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceQuery') {
      return deserialize<_ivs4ir3j.CalendarEventOccurrenceQuery>(data['data']);
    }
    if (dataClassName == 'CalendarEventOrigin') {
      return deserialize<_ipbrznp8.CalendarEventOrigin>(data['data']);
    }
    if (dataClassName == 'CalendarEventOverrideProtocolState') {
      return deserialize<_iml0c566.CalendarEventOverrideProtocolState>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventPage') {
      return deserialize<_iaayjmj1.CalendarEventPage>(data['data']);
    }
    if (dataClassName == 'CalendarEventProtocolState') {
      return deserialize<_i8iqsbco.CalendarEventProtocolState>(data['data']);
    }
    if (dataClassName == 'CalendarEventProtocolVersion') {
      return deserialize<_iblfo3t0.CalendarEventProtocolVersion>(data['data']);
    }
    if (dataClassName == 'CalendarEventReceipt') {
      return deserialize<_i500bvo7.CalendarEventReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarEventRecord') {
      return deserialize<_ilvoe14z.CalendarEventRecord>(data['data']);
    }
    if (dataClassName == 'CalendarEventRecurrence') {
      return deserialize<_iqxs44bf.CalendarEventRecurrence>(data['data']);
    }
    if (dataClassName == 'CalendarEventReplaceReceipt') {
      return deserialize<_ii1x02jx.CalendarEventReplaceReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarEventReplaceRequest') {
      return deserialize<_ikx66n5r.CalendarEventReplaceRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventReplaceResult') {
      return deserialize<_ipzyec4h.CalendarEventReplaceResult>(data['data']);
    }
    if (dataClassName == 'CalendarEventResourceGroup') {
      return deserialize<_iiajf89w.CalendarEventResourceGroup>(data['data']);
    }
    if (dataClassName == 'CalendarEventRule') {
      return deserialize<_iovyzq1q.CalendarEventRule>(data['data']);
    }
    if (dataClassName == 'CalendarEventSingleOverride') {
      return deserialize<_iq1kxi25.CalendarEventSingleOverride>(data['data']);
    }
    if (dataClassName == 'CalendarEventSourceAlarm') {
      return deserialize<_i4dai4jt.CalendarEventSourceAlarm>(data['data']);
    }
    if (dataClassName == 'CalendarEventSourceAttachment') {
      return deserialize<_i20i9qxn.CalendarEventSourceAttachment>(data['data']);
    }
    if (dataClassName == 'CalendarEventSourceCategoryGroup') {
      return deserialize<_iui013s0.CalendarEventSourceCategoryGroup>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventSourceDuration') {
      return deserialize<_ie9apnqv.CalendarEventSourceDuration>(data['data']);
    }
    if (dataClassName == 'CalendarEventSourceMetadata') {
      return deserialize<_ic57ts5d.CalendarEventSourceMetadata>(data['data']);
    }
    if (dataClassName == 'CalendarEventSourceParticipant') {
      return deserialize<_iypom7ai.CalendarEventSourceParticipant>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventSourceRelationship') {
      return deserialize<_iksc4ly9.CalendarEventSourceRelationship>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventSourceText') {
      return deserialize<_iwa6orjz.CalendarEventSourceText>(data['data']);
    }
    if (dataClassName == 'CalendarEventStatus') {
      return deserialize<_ivzxk9bc.CalendarEventStatus>(data['data']);
    }
    if (dataClassName == 'CalendarEventStatusRequest') {
      return deserialize<_i3kbbl30.CalendarEventStatusRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventTextMetadataRequest') {
      return deserialize<_iswwug34.CalendarEventTextMetadataRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventTextParameters') {
      return deserialize<_isfojy12.CalendarEventTextParameters>(data['data']);
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
    if (dataClassName == 'CalendarIdentityRecord') {
      return deserialize<_ibccnfmr.CalendarIdentityRecord>(data['data']);
    }
    if (dataClassName == 'CalendarImageLink') {
      return deserialize<_igf45b52.CalendarImageLink>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationAdoptionReceipt') {
      return deserialize<_ib1s0vrr.CalendarInvitationAdoptionReceipt>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationAdoptionRequest') {
      return deserialize<_imimov8l.CalendarInvitationAdoptionRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationApplicationRecord') {
      return deserialize<_i29jhvb3.CalendarInvitationApplicationRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationApplicationView') {
      return deserialize<_i8svxjh1.CalendarInvitationApplicationView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationApplyReceipt') {
      return deserialize<_ic2yh4ry.CalendarInvitationApplyReceipt>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationApplyRequest') {
      return deserialize<_iivrx0vm.CalendarInvitationApplyRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationDocument') {
      return deserialize<_iwcng7rp.CalendarInvitationDocument>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationLinkRecord') {
      return deserialize<_ibnm4ujx.CalendarInvitationLinkRecord>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationOccurrenceApplicationRecord') {
      return deserialize<
        _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord
      >(data['data']);
    }
    if (dataClassName == 'CalendarInvitationOccurrenceApplicationView') {
      return deserialize<_i15b7t0e.CalendarInvitationOccurrenceApplicationView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationOccurrenceApplyReceipt') {
      return deserialize<_iyajy5op.CalendarInvitationOccurrenceApplyReceipt>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationOccurrenceApplyRequest') {
      return deserialize<_ioottw62.CalendarInvitationOccurrenceApplyRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationOutcome') {
      return deserialize<_i98zwsq8.CalendarInvitationOutcome>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationReceipt') {
      return deserialize<_iy372k0z.CalendarInvitationReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationReceiptRecord') {
      return deserialize<_i1bc5dpy.CalendarInvitationReceiptRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationRecord') {
      return deserialize<_igigle43.CalendarInvitationRecord>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationResponseActivityView') {
      return deserialize<_ip5pithb.CalendarInvitationResponseActivityView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseAttemptRecord') {
      return deserialize<_i3vdxm7o.CalendarInvitationResponseAttemptRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseChoice') {
      return deserialize<_il64jj9v.CalendarInvitationResponseChoice>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseDeliveryState') {
      return deserialize<_iw51ozry.CalendarInvitationResponseDeliveryState>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseReceipt') {
      return deserialize<_ig6twu0d.CalendarInvitationResponseReceipt>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseRecord') {
      return deserialize<_iifvkijq.CalendarInvitationResponseRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseRequest') {
      return deserialize<_iw3qnr12.CalendarInvitationResponseRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseStateRecord') {
      return deserialize<_i5cgrgck.CalendarInvitationResponseStateRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationResponseView') {
      return deserialize<_irmbkh1p.CalendarInvitationResponseView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationSourceKind') {
      return deserialize<_ilccsff7.CalendarInvitationSourceKind>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationSourceRecord') {
      return deserialize<_i3yqoryt.CalendarInvitationSourceRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarInvitationSourceView') {
      return deserialize<_itix6re9.CalendarInvitationSourceView>(data['data']);
    }
    if (dataClassName == 'CalendarInvitationView') {
      return deserialize<_ifs5c7mj.CalendarInvitationView>(data['data']);
    }
    if (dataClassName == 'CalendarItemCategoryGroup') {
      return deserialize<_i3iolgr8.CalendarItemCategoryGroup>(data['data']);
    }
    if (dataClassName == 'CalendarItemComment') {
      return deserialize<_itx19m90.CalendarItemComment>(data['data']);
    }
    if (dataClassName == 'CalendarItemTextMetadataField') {
      return deserialize<_i12tuyl5.CalendarItemTextMetadataField>(data['data']);
    }
    if (dataClassName == 'CalendarItemTextMetadataPatch') {
      return deserialize<_ikwi9ryb.CalendarItemTextMetadataPatch>(data['data']);
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
    if (dataClassName == 'CalendarSchedulingAttemptRecord') {
      return deserialize<_i64utb1e.CalendarSchedulingAttemptRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingAttendeeResponseRecord') {
      return deserialize<_i577nx0c.CalendarSchedulingAttendeeResponseRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingAttendeeResponseView') {
      return deserialize<_itopoldj.CalendarSchedulingAttendeeResponseView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingCancelRequest') {
      return deserialize<_i4uu6f5m.CalendarSchedulingCancelRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingDeliveryRecord') {
      return deserialize<_iuidcanh.CalendarSchedulingDeliveryRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingDeliveryState') {
      return deserialize<_it5jr5tm.CalendarSchedulingDeliveryState>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingDeliveryView') {
      return deserialize<_i63ky642.CalendarSchedulingDeliveryView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingInstanceResponsesView') {
      return deserialize<_i8yevrne.CalendarSchedulingInstanceResponsesView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingMeetingRecord') {
      return deserialize<_ihlqfuoo.CalendarSchedulingMeetingRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingOccurrenceCancelRequest') {
      return deserialize<_ia8x0otq.CalendarSchedulingOccurrenceCancelRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingOccurrenceRestoreRequest') {
      return deserialize<_io2t7cny.CalendarSchedulingOccurrenceRestoreRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingParticipation') {
      return deserialize<_iot0xi24.CalendarSchedulingParticipation>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingPublicationKind') {
      return deserialize<_il38fbb4.CalendarSchedulingPublicationKind>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingPublicationRecord') {
      return deserialize<_ivo2647b.CalendarSchedulingPublicationRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingReceipt') {
      return deserialize<_izftntkw.CalendarSchedulingReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarSchedulingReopenRequest') {
      return deserialize<_iv2f51nm.CalendarSchedulingReopenRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingReplyDocument') {
      return deserialize<_iqen8jmy.CalendarSchedulingReplyDocument>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingReplyOutcome') {
      return deserialize<_ikqvfn4d.CalendarSchedulingReplyOutcome>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingReplyReceipt') {
      return deserialize<_iwdevo6h.CalendarSchedulingReplyReceipt>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingReplyReceiptRecord') {
      return deserialize<_i0njii35.CalendarSchedulingReplyReceiptRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingReplySourceRecord') {
      return deserialize<_ia855khw.CalendarSchedulingReplySourceRecord>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingReplySourceView') {
      return deserialize<_i2peuvqu.CalendarSchedulingReplySourceView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingResponsesView') {
      return deserialize<_ixbxcx0r.CalendarSchedulingResponsesView>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarSchedulingSaveRequest') {
      return deserialize<_icabxeyo.CalendarSchedulingSaveRequest>(data['data']);
    }
    if (dataClassName == 'CalendarSchedulingView') {
      return deserialize<_is73suzs.CalendarSchedulingView>(data['data']);
    }
    if (dataClassName == 'CalendarScopeRecord') {
      return deserialize<_i9mvj7kq.CalendarScopeRecord>(data['data']);
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
    if (dataClassName == 'CalendarSubjectRecord') {
      return deserialize<_i76vfrve.CalendarSubjectRecord>(data['data']);
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
    if (dataClassName == 'CalendarTaskAssignee') {
      return deserialize<_ih5e3u6u.CalendarTaskAssignee>(data['data']);
    }
    if (dataClassName == 'CalendarTaskAssignmentsRequest') {
      return deserialize<_ipa1soge.CalendarTaskAssignmentsRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskContent') {
      return deserialize<_if7nbvl8.CalendarTaskContent>(data['data']);
    }
    if (dataClassName == 'CalendarTaskContentAction') {
      return deserialize<_ihwe765g.CalendarTaskContentAction>(data['data']);
    }
    if (dataClassName == 'CalendarTaskContentField') {
      return deserialize<_i496rta0.CalendarTaskContentField>(data['data']);
    }
    if (dataClassName == 'CalendarTaskCreateRequest') {
      return deserialize<_iipxdkwq.CalendarTaskCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarTaskDataRecord') {
      return deserialize<_ic8eedzw.CalendarTaskDataRecord>(data['data']);
    }
    if (dataClassName == 'CalendarTaskExportRequest') {
      return deserialize<_i10340hl.CalendarTaskExportRequest>(data['data']);
    }
    if (dataClassName == 'CalendarTaskExportSelection') {
      return deserialize<_i71mi7ri.CalendarTaskExportSelection>(data['data']);
    }
    if (dataClassName == 'CalendarTaskFieldGroup') {
      return deserialize<_isemqyyv.CalendarTaskFieldGroup>(data['data']);
    }
    if (dataClassName == 'CalendarTaskHistoryEntry') {
      return deserialize<_idhalyap.CalendarTaskHistoryEntry>(data['data']);
    }
    if (dataClassName == 'CalendarTaskHistoryPage') {
      return deserialize<_ibsdsx6x.CalendarTaskHistoryPage>(data['data']);
    }
    if (dataClassName == 'CalendarTaskHistoryQuery') {
      return deserialize<_i1vdb6de.CalendarTaskHistoryQuery>(data['data']);
    }
    if (dataClassName == 'CalendarTaskHistoryRecord') {
      return deserialize<_i6c7wo1p.CalendarTaskHistoryRecord>(data['data']);
    }
    if (dataClassName == 'CalendarTaskImportBaseline') {
      return deserialize<_iqsm27bn.CalendarTaskImportBaseline>(data['data']);
    }
    if (dataClassName == 'CalendarTaskImportRequest') {
      return deserialize<_isw8fcv3.CalendarTaskImportRequest>(data['data']);
    }
    if (dataClassName == 'CalendarTaskImportResult') {
      return deserialize<_izrxa9vy.CalendarTaskImportResult>(data['data']);
    }
    if (dataClassName == 'CalendarTaskOccurrence') {
      return deserialize<_isgg83d3.CalendarTaskOccurrence>(data['data']);
    }
    if (dataClassName == 'CalendarTaskOccurrenceContent') {
      return deserialize<_irmu5f0n.CalendarTaskOccurrenceContent>(data['data']);
    }
    if (dataClassName == 'CalendarTaskOccurrenceContentChange') {
      return deserialize<_isfljanw.CalendarTaskOccurrenceContentChange>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskOccurrenceContentRequest') {
      return deserialize<_iw338tmt.CalendarTaskOccurrenceContentRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskOccurrencePreview') {
      return deserialize<_id9j5e7y.CalendarTaskOccurrencePreview>(data['data']);
    }
    if (dataClassName == 'CalendarTaskOccurrenceProgressRequest') {
      return deserialize<_irw24ank.CalendarTaskOccurrenceProgressRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskOccurrenceQuery') {
      return deserialize<_ixy579wj.CalendarTaskOccurrenceQuery>(data['data']);
    }
    if (dataClassName == 'CalendarTaskOccurrenceRecord') {
      return deserialize<_i3t5ry4r.CalendarTaskOccurrenceRecord>(data['data']);
    }
    if (dataClassName == 'CalendarTaskOccurrenceTimingRequest') {
      return deserialize<_ii9v7kdj.CalendarTaskOccurrenceTimingRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskPage') {
      return deserialize<_i276ujfk.CalendarTaskPage>(data['data']);
    }
    if (dataClassName == 'CalendarTaskProgress') {
      return deserialize<_ikcsq95s.CalendarTaskProgress>(data['data']);
    }
    if (dataClassName == 'CalendarTaskProgressAction') {
      return deserialize<_i6s7yrua.CalendarTaskProgressAction>(data['data']);
    }
    if (dataClassName == 'CalendarTaskProgressRequest') {
      return deserialize<_in6zlsph.CalendarTaskProgressRequest>(data['data']);
    }
    if (dataClassName == 'CalendarTaskProtocolVersion') {
      return deserialize<_iz9t6x1i.CalendarTaskProtocolVersion>(data['data']);
    }
    if (dataClassName == 'CalendarTaskReceipt') {
      return deserialize<_im9usybn.CalendarTaskReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarTaskRecord') {
      return deserialize<_irbiaacf.CalendarTaskRecord>(data['data']);
    }
    if (dataClassName == 'CalendarTaskReplaceReceipt') {
      return deserialize<_ib5z6spp.CalendarTaskReplaceReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarTaskReplaceRequest') {
      return deserialize<_ibpx2vjc.CalendarTaskReplaceRequest>(data['data']);
    }
    if (dataClassName == 'CalendarTaskReplaceResult') {
      return deserialize<_iyf2qeht.CalendarTaskReplaceResult>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceAlarm') {
      return deserialize<_i00avof0.CalendarTaskSourceAlarm>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceAttachment') {
      return deserialize<_iuzk4pe3.CalendarTaskSourceAttachment>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceCategoryGroup') {
      return deserialize<_iic8eifm.CalendarTaskSourceCategoryGroup>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskSourceComponent') {
      return deserialize<_ivqadd6c.CalendarTaskSourceComponent>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceDuration') {
      return deserialize<_im8khkr9.CalendarTaskSourceDuration>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceMetadata') {
      return deserialize<_i76q6myt.CalendarTaskSourceMetadata>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceParticipant') {
      return deserialize<_iw6fme2j.CalendarTaskSourceParticipant>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceRelationship') {
      return deserialize<_izyrs4yl.CalendarTaskSourceRelationship>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskSourceState') {
      return deserialize<_it1pm24a.CalendarTaskSourceState>(data['data']);
    }
    if (dataClassName == 'CalendarTaskSourceText') {
      return deserialize<_i9mnuab5.CalendarTaskSourceText>(data['data']);
    }
    if (dataClassName == 'CalendarTaskStatus') {
      return deserialize<_iiahrdev.CalendarTaskStatus>(data['data']);
    }
    if (dataClassName == 'CalendarTaskTextMetadataRequest') {
      return deserialize<_it8lhctx.CalendarTaskTextMetadataRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTaskTimeKind') {
      return deserialize<_ijhc2xsq.CalendarTaskTimeKind>(data['data']);
    }
    if (dataClassName == 'CalendarTaskTiming') {
      return deserialize<_i9h8y8lg.CalendarTaskTiming>(data['data']);
    }
    if (dataClassName == 'CalendarTaskUpdateRequest') {
      return deserialize<_in7cuxyg.CalendarTaskUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarTaskView') {
      return deserialize<_ii3yrr21.CalendarTaskView>(data['data']);
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
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
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
          ? _is.SerializationManager.toEncodableForProtocol(wrapped)
          : _is.SerializationManager.toEncodable(wrapped);
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
        } on _is.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _ik9lwgjh.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ipt2851n.CalendarAlarmActionRecord:
        return _ipt2851n.CalendarAlarmActionRecord.t;
      case _ihgh57kq.CalendarAlarmFiringRecord:
        return _ihgh57kq.CalendarAlarmFiringRecord.t;
      case _iid4j1lu.CalendarAlarmPlanRecord:
        return _iid4j1lu.CalendarAlarmPlanRecord.t;
      case _iralscit.CalendarAlarmRecord:
        return _iralscit.CalendarAlarmRecord.t;
      case _ie9je6js.CalendarAvailabilityDataRecord:
        return _ie9je6js.CalendarAvailabilityDataRecord.t;
      case _inwzhb5r.CalendarAvailabilityRecord:
        return _inwzhb5r.CalendarAvailabilityRecord.t;
      case _iptr9vfe.CalendarCursorRecord:
        return _iptr9vfe.CalendarCursorRecord.t;
      case _ix6i00tg.CalendarDataRecord:
        return _ix6i00tg.CalendarDataRecord.t;
      case _i23wc83s.CalendarEventDataRecord:
        return _i23wc83s.CalendarEventDataRecord.t;
      case _ilvoe14z.CalendarEventRecord:
        return _ilvoe14z.CalendarEventRecord.t;
      case _ibccnfmr.CalendarIdentityRecord:
        return _ibccnfmr.CalendarIdentityRecord.t;
      case _i29jhvb3.CalendarInvitationApplicationRecord:
        return _i29jhvb3.CalendarInvitationApplicationRecord.t;
      case _ibnm4ujx.CalendarInvitationLinkRecord:
        return _ibnm4ujx.CalendarInvitationLinkRecord.t;
      case _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord:
        return _i48y6d6c.CalendarInvitationOccurrenceApplicationRecord.t;
      case _i1bc5dpy.CalendarInvitationReceiptRecord:
        return _i1bc5dpy.CalendarInvitationReceiptRecord.t;
      case _igigle43.CalendarInvitationRecord:
        return _igigle43.CalendarInvitationRecord.t;
      case _i3vdxm7o.CalendarInvitationResponseAttemptRecord:
        return _i3vdxm7o.CalendarInvitationResponseAttemptRecord.t;
      case _iifvkijq.CalendarInvitationResponseRecord:
        return _iifvkijq.CalendarInvitationResponseRecord.t;
      case _i5cgrgck.CalendarInvitationResponseStateRecord:
        return _i5cgrgck.CalendarInvitationResponseStateRecord.t;
      case _i3yqoryt.CalendarInvitationSourceRecord:
        return _i3yqoryt.CalendarInvitationSourceRecord.t;
      case _i64utb1e.CalendarSchedulingAttemptRecord:
        return _i64utb1e.CalendarSchedulingAttemptRecord.t;
      case _i577nx0c.CalendarSchedulingAttendeeResponseRecord:
        return _i577nx0c.CalendarSchedulingAttendeeResponseRecord.t;
      case _iuidcanh.CalendarSchedulingDeliveryRecord:
        return _iuidcanh.CalendarSchedulingDeliveryRecord.t;
      case _ihlqfuoo.CalendarSchedulingMeetingRecord:
        return _ihlqfuoo.CalendarSchedulingMeetingRecord.t;
      case _ivo2647b.CalendarSchedulingPublicationRecord:
        return _ivo2647b.CalendarSchedulingPublicationRecord.t;
      case _i0njii35.CalendarSchedulingReplyReceiptRecord:
        return _i0njii35.CalendarSchedulingReplyReceiptRecord.t;
      case _ia855khw.CalendarSchedulingReplySourceRecord:
        return _ia855khw.CalendarSchedulingReplySourceRecord.t;
      case _i9mvj7kq.CalendarScopeRecord:
        return _i9mvj7kq.CalendarScopeRecord.t;
      case _i76vfrve.CalendarSubjectRecord:
        return _i76vfrve.CalendarSubjectRecord.t;
      case _ic8eedzw.CalendarTaskDataRecord:
        return _ic8eedzw.CalendarTaskDataRecord.t;
      case _i6c7wo1p.CalendarTaskHistoryRecord:
        return _i6c7wo1p.CalendarTaskHistoryRecord.t;
      case _i3t5ry4r.CalendarTaskOccurrenceRecord:
        return _i3t5ry4r.CalendarTaskOccurrenceRecord.t;
      case _irbiaacf.CalendarTaskRecord:
        return _irbiaacf.CalendarTaskRecord.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _ik9lwgjh.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
