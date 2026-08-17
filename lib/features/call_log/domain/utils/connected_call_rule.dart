import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';

/// Android connected-call promotion: move the lead to Connected only when
/// the conversation actually connected and lasted more than 2 seconds.
class ConnectedCallRule {
  ConnectedCallRule._();

  /// Talk time must be strictly greater than this (missed / DNP stay put).
  static const minDurationSeconds = 2;

  static const _notConnectedStatuses = {
    'missed',
    'dnp',
    'not_picked',
    'notpicked',
    'busy',
    'call_failed',
    'failed',
    'rejected',
    'blocked',
  };

  /// True when Android talk time is over 2s and the call was not missed/DNP.
  static bool isConnectedConversation({
    required String? duration,
    String? status,
  }) {
    final seconds = CallLogDuration.parseToSeconds(duration);
    if (seconds <= minDurationSeconds) return false;

    final normalized = (status ?? '').toLowerCase().trim();
    if (normalized.isEmpty) return true;
    return !_notConnectedStatuses.contains(normalized);
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
