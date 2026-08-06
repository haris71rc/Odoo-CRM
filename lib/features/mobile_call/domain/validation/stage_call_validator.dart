import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/stage_call_validation_data.dart';

/// Stage-change business rules based on MOBILE_CALL log notes.
class StageCallValidator {
  StageCallValidator._();

  static const unansweredStatuses = {
    'no_answer',
    'busy',
    'missed',
    'rejected',
  };

  static const leaveFollowUpMessage =
      'Please call the customer after moving to Follow-up before changing stage.';

  static bool isDoNotPicked(String? stageName) {
    final n =
        (stageName ?? '').toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return n.contains('do not pick') ||
        n.contains('do not picked') ||
        n == 'not picked' ||
        n.contains('not picked') ||
        n.contains('(dnp)') ||
        n.contains(' dnp') ||
        n.endsWith('dnp') ||
        n.contains('not connected');
  }

  /// Returns a snackbar message when the transition is blocked, otherwise null.
  static String? validate({
    required String? currentStageName,
    required String? targetStageName,
    required StageCallValidationData data,
    required int? currentUserId,
  }) {
    final currentFollowUp = LeadListFilters.isFollowUp(currentStageName);
    final targetFollowUp = LeadListFilters.isFollowUp(targetStageName);
    final targetDoNotPicked = isDoNotPicked(targetStageName);
    final latestCall = data.latestCall;
    final hasCall = latestCall != null;

    LatestMobileCallEntity? callAfterFollowUp;
    if (currentUserId != null) {
      callAfterFollowUp = data.latestCallByUserAfterFollowUp(currentUserId);
    }

    // Rule 2 — leaving Follow-up requires a call by the logged-in user
    // after the lead entered Follow-up (timestamp check).
    if (currentFollowUp && !targetFollowUp) {
      if (callAfterFollowUp == null) {
        return leaveFollowUpMessage;
      }
    }

    // Rule 1 — without any MOBILE_CALL, only Follow-up is allowed.
    if (!hasCall && !targetFollowUp) {
      return 'Please call the customer before changing stage.';
    }

    // Rule 3 — Do Not Picked requires an unanswered latest relevant call.
    if (targetDoNotPicked) {
      final relevant = callAfterFollowUp ?? latestCall;
      final status = relevant?.status.toLowerCase().trim();
      if (status == null || !unansweredStatuses.contains(status)) {
        return 'Lead can only be marked Do Not Picked after an unanswered call.';
      }
    }

    return null;
  }
}
