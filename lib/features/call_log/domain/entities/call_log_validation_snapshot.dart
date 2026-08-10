import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';

/// Lead fields needed to validate a stage change against call data.
class CallLogValidationSnapshot {
  const CallLogValidationSnapshot({
    required this.callLog,
    this.stageName,
    this.writeDate,
  });

  final CallLog callLog;

  /// Current CRM stage name from Odoo (`stage_id`).
  final String? stageName;

  /// Lead `write_date` (UTC instant from Odoo). Used when chatter is stale
  /// right after moving into Follow-Up.
  final DateTime? writeDate;
}
