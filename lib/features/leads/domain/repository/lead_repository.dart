import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';

abstract class LeadRepository {
  Future<Result<List<LeadEntity>>> getLeads({
    DateTime? startDate,
    DateTime? endDate,
    int? assignedUserId,
    int? stageId,
    bool priorityOnly = false,
    bool openOnly = false,
    List<int> excludeStageIds = const [],
    int? excludePaidAdminId,
    List<int> excludePaidStageIds = const [],
    List<int> tagIds = const [],
    List<int> dateExemptStageIds = const [],
  });

  Future<Result<LeadDetailEntity>> getLeadDetail(int leadId);

  Future<Result<void>> assignToUser({required int leadId, required int userId});

  Future<Result<void>> updateStage({required int leadId, required int stageId});

  Future<Result<void>> updateRemark({
    required int leadId,
    required String description,
  });

  /// Leads that share a number with one the salesperson already called.
  ///
  /// Uses the same assignee, stage, and tag filters as [getLeads], without the
  /// create-date window, so a call outside the current range still counts.
  Future<Result<Set<int>>> findDuplicateLeadIds({
    int? assignedUserId,
    int? stageId,
    bool openOnly = false,
    List<int> excludeStageIds = const [],
    int? excludePaidAdminId,
    List<int> excludePaidStageIds = const [],
    List<int> tagIds = const [],
  });

  /// Whether [leadId] is a duplicate of another lead with the same number.
  Future<Result<bool>> isDuplicateLead({
    required int leadId,
    String? phone,
    String? mobile,
  });
}
