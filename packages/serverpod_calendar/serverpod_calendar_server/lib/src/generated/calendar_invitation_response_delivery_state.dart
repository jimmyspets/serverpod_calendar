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

enum CalendarInvitationResponseDeliveryState implements _is.SerializableModel {
  queued,
  retrying,
  claimed,
  accepted,
  withdrawn,
  expired,
  failed;

  static CalendarInvitationResponseDeliveryState fromJson(String name) {
    switch (name) {
      case 'queued':
        return CalendarInvitationResponseDeliveryState.queued;
      case 'retrying':
        return CalendarInvitationResponseDeliveryState.retrying;
      case 'claimed':
        return CalendarInvitationResponseDeliveryState.claimed;
      case 'accepted':
        return CalendarInvitationResponseDeliveryState.accepted;
      case 'withdrawn':
        return CalendarInvitationResponseDeliveryState.withdrawn;
      case 'expired':
        return CalendarInvitationResponseDeliveryState.expired;
      case 'failed':
        return CalendarInvitationResponseDeliveryState.failed;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "CalendarInvitationResponseDeliveryState"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
