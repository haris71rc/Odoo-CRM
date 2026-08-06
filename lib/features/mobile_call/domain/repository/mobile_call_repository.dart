import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/stage_call_validation_data.dart';

abstract class MobileCallRepository {
  /// Creates a Log Note on the lead with human + machine-readable call data.
  Future<Result<void>> createMobileCallLog({
    required int leadId,
    required LatestMobileCallEntity call,
  });

  /// Fetches chatter for the lead and returns the newest MOBILE_CALL entry.
  Future<Result<LatestMobileCallEntity?>> fetchLatestMobileCall(int leadId);

  /// Fetches chatter and builds validation data (calls + Follow-up entry time).
  Future<Result<StageCallValidationData>> fetchStageCallValidationData(
    int leadId,
  );
}
