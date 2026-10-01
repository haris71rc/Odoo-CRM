/// Server-side lead query shared by the list and duplicate detection.
class LeadSearchParams {
  const LeadSearchParams({
    this.startDate,
    this.endDate,
    this.assignedUserId,
    this.stageId,
    this.openOnly = false,
    this.excludeStageIds = const [],
    this.excludePaidAdminId,
    this.excludePaidStageIds = const [],
    this.tagIds = const [],
    this.dateExemptStageIds = const [],
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final int? assignedUserId;
  final int? stageId;
  final bool openOnly;
  final List<int> excludeStageIds;
  final int? excludePaidAdminId;
  final List<int> excludePaidStageIds;
  final List<int> tagIds;
  final List<int> dateExemptStageIds;
}
