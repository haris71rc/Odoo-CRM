import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';

/// Auto-move the lead to Connected only after a real picked conversation.
///
/// DNP, missed, call failed, busy, etc. never promote. The latest call must
/// be tagged as picked/answered **and** last at least [minDurationSeconds].
class ConnectedCallRule {
  ConnectedCallRule._();

  /// Minimum talk time (seconds) required before auto-moving to Connected.
  static const minDurationSeconds = 3;

  /// True when the latest call was picked/answered with enough talk time.
  static bool isConnectedConversation({
    required String? duration,
    String? status,
  }) {
    if (!isPickedStatus(status)) return false;
    return CallLogDuration.parseToSeconds(duration) >= minDurationSeconds;
  }

  /// Convenience overload for a full [CallLog] row (uses latest call fields).
  ///
  /// Odoo only stores total duration, so after a round-trip [CallLog.duration]
  /// is often null. For a single outbound call, [CallLog.totalDuration] is a
  /// safe stand-in for the latest talk time.
  static bool callWasMade(CallLog callLog) {
    return isConnectedConversation(
      duration: _effectiveLatestDuration(callLog),
      status: callLog.status,
    );
  }

  static String? _effectiveLatestDuration(CallLog callLog) {
    if (callLog.duration != null && callLog.duration!.trim().isNotEmpty) {
      return callLog.duration;
    }
    final outbound = callLog.totalOutboundCalls ?? 0;
    if (outbound <= 1) return callLog.totalDuration;
    return null;
  }

  /// True for picked / answered tags; false for DNP, failed, missed, etc.
  static bool isPickedStatus(String? status) {
    if (status == null) return false;
    final normalized =
        status.trim().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    if (normalized.isEmpty) return false;

    const notPicked = {
      'dnp',
      'not_picked',
      'notpicked',
      'no_answer',
      'busy',
      'missed',
      'rejected',
      'failed',
      'call_failed',
      'hanged_up',
      'hangedup',
    };
    if (notPicked.contains(normalized)) return false;

    if (normalized == 'picked' ||
        normalized == 'answered' ||
        normalized == 'connected') {
      return true;
    }
    // Custom Odoo keys such as `call_picked` / `answered_call`.
    if (normalized.contains('pick') && !normalized.contains('not')) {
      return true;
    }
    if (normalized.contains('answer')) return true;
    return false;
  }

  /// Auto-promote only from early stages (New Prospect, DNP, …).
  /// Later pipeline stages stay where they are.
  static bool shouldMoveToConnected(String? currentStageName) {
    if (LeadListFilters.isConnectedStage(currentStageName)) return false;
    if (LeadListFilters.isWon(currentStageName)) return false;
    if (LeadListFilters.isLost(currentStageName)) return false;
    if (LeadListFilters.isProposalStage(currentStageName)) return false;
    if (LeadListFilters.isFollowUp(currentStageName)) return false;
    return true;
  }
}
