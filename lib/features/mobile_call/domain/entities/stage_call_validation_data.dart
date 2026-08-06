import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';

/// Snapshot used to validate CRM stage changes against mobile call logs.
class StageCallValidationData {
  const StageCallValidationData({
    required this.latestCall,
    required this.mobileCalls,
    this.followUpEnteredAt,
    this.followUpEnteredMessageId,
  });

  /// Newest MOBILE_CALL on the lead (any user).
  final LatestMobileCallEntity? latestCall;

  /// All parsed MOBILE_CALL entries, newest first.
  final List<LatestMobileCallEntity> mobileCalls;

  /// When the lead most recently entered a Follow-up stage (from chatter).
  final DateTime? followUpEnteredAt;

  /// `mail.message` id of that Follow-up stage-change note.
  final int? followUpEnteredMessageId;

  /// Latest call by [userId] that happened *after* entering Follow-up.
  ///
  /// Prefers `mail.message` id ordering (reliable). Falls back to Odoo
  /// `loggedAt` vs Follow-up entry time. Dialer JSON timestamps are ignored
  /// for this check because they can disagree with chatter order.
  LatestMobileCallEntity? latestCallByUserAfterFollowUp(int userId) {
    final followUpMessageId = followUpEnteredMessageId;
    final followUpAt = followUpEnteredAt;

    // Without a known Follow-up entry, do not treat older calls as valid.
    if (followUpMessageId == null && followUpAt == null) {
      return null;
    }

    for (final call in mobileCalls) {
      if (call.userId != userId) continue;
      if (!_isAfterFollowUp(call, followUpMessageId, followUpAt)) continue;
      return call;
    }
    return null;
  }

  bool _isAfterFollowUp(
    LatestMobileCallEntity call,
    int? followUpMessageId,
    DateTime? followUpAt,
  ) {
    // Primary: message id grows over time in Odoo.
    if (followUpMessageId != null && call.messageId != null) {
      return call.messageId! > followUpMessageId;
    }

    // Fallback: compare Log Note post time vs Follow-up tracking time.
    if (followUpAt != null && call.loggedAt != null) {
      return call.loggedAt!.isAfter(followUpAt);
    }

    return false;
  }
}
