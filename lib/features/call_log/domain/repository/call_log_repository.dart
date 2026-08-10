import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log_validation_snapshot.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';

abstract class CallLogRepository {
  Future<Result<CallLog>> getCallLog(int leadId);

  Future<Result<List<CallStatusOption>>> getCallStatusOptions(int leadId);

  /// Call log + current stage / write_date for stage-change validation.
  Future<Result<CallLogValidationSnapshot>> getValidationSnapshot(int leadId);

  Future<Result<void>> saveCallLog({
    required int leadId,
    required CallLog callLog,
  });
}
