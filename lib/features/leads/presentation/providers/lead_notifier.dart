import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/leads/data/datasource/lead_remote_datasource.dart';
import 'package:odoocrm/features/leads/data/repository/lead_repository_impl.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_date_filter.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/domain/repository/lead_repository.dart';
import 'package:odoocrm/features/leads/domain/utils/lead_date_range.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lead_notifier.g.dart';

enum LeadPipelineTab { all, mine, followup, won, lost }

@Riverpod(keepAlive: true)
LeadRepository leadRepository(Ref ref) {
  return LeadRepositoryImpl(
    datasource: LeadRemoteDatasource(ref.watch(dioClientProvider)),
  );
}

/// Applied lead list filters (server-side date / user / stage + local search).
class LeadFilterState {
  const LeadFilterState({
    this.searchQuery = '',
    this.pipelineTab = LeadPipelineTab.all,
    this.dateFilter,
    this.customStartDate,
    this.customEndDate,
    this.assignedUserId,
    this.assignedUserName,
    this.stageId,
    this.stageName,
    this.todayMine = false,
    this.untouched = false,
    this.priorityOnly = false,
    this.openOnly = false,
  });

  final String searchQuery;
  final LeadPipelineTab pipelineTab;
  final LeadDateFilter? dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final int? assignedUserId;
  final String? assignedUserName;
  final int? stageId;
  final String? stageName;
  final bool todayMine;
  final bool untouched;
  final bool priorityOnly;
  final bool openOnly;

  bool get assignedToMeOnly => pipelineTab == LeadPipelineTab.mine;

  int get localFilterCount {
    var count = 0;
    if (todayMine) count++;
    if (untouched) count++;
    if (priorityOnly) count++;
    if (openOnly) count++;
    if (dateFilter != null) count++;
    if (assignedUserId != null) count++;
    if (stageId != null) count++;
    return count;
  }

  bool get hasActiveServerFilters {
    return dateFilter != null || assignedUserId != null || stageId != null;
  }

  LeadDateRange? get resolvedDateRange => LeadDateRange.resolve(
        filter: dateFilter,
        customStart: customStartDate,
        customEnd: customEndDate,
      );

  LeadFilterState copyWith({
    String? searchQuery,
    LeadPipelineTab? pipelineTab,
    LeadDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    int? assignedUserId,
    String? assignedUserName,
    int? stageId,
    String? stageName,
    bool? todayMine,
    bool? untouched,
    bool? priorityOnly,
    bool? openOnly,
    bool clearDateFilter = false,
    bool clearCustomDates = false,
    bool clearAssignedUser = false,
    bool clearStage = false,
  }) {
    return LeadFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      pipelineTab: pipelineTab ?? this.pipelineTab,
      dateFilter: clearDateFilter ? null : (dateFilter ?? this.dateFilter),
      customStartDate:
          clearCustomDates ? null : (customStartDate ?? this.customStartDate),
      customEndDate:
          clearCustomDates ? null : (customEndDate ?? this.customEndDate),
      assignedUserId:
          clearAssignedUser ? null : (assignedUserId ?? this.assignedUserId),
      assignedUserName: clearAssignedUser
          ? null
          : (assignedUserName ?? this.assignedUserName),
      stageId: clearStage ? null : (stageId ?? this.stageId),
      stageName: clearStage ? null : (stageName ?? this.stageName),
      todayMine: todayMine ?? this.todayMine,
      untouched: untouched ?? this.untouched,
      priorityOnly: priorityOnly ?? this.priorityOnly,
      openOnly: openOnly ?? this.openOnly,
    );
  }
}

@riverpod
class LeadFilterNotifier extends _$LeadFilterNotifier {
  @override
  LeadFilterState build() => const LeadFilterState();

  void setSearch(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setPipelineTab(LeadPipelineTab tab) {
    state = state.copyWith(pipelineTab: tab);
  }

  void setAssignedToMe(bool value) {
    state = state.copyWith(
      pipelineTab: value ? LeadPipelineTab.mine : LeadPipelineTab.all,
    );
  }

  void toggleLocalFilter(String key) {
    switch (key) {
      case 'todayMine':
        state = state.copyWith(todayMine: !state.todayMine);
      case 'untouched':
        state = state.copyWith(untouched: !state.untouched);
      case 'priority':
        state = state.copyWith(priorityOnly: !state.priorityOnly);
      case 'open':
        state = state.copyWith(openOnly: !state.openOnly);
    }
  }

  void clearLocalFilters() {
    state = state.copyWith(
      todayMine: false,
      untouched: false,
      priorityOnly: false,
      openOnly: false,
      clearDateFilter: true,
      clearCustomDates: true,
      clearAssignedUser: true,
      clearStage: true,
    );
  }

  void applyFilters({
    LeadDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    int? assignedUserId,
    String? assignedUserName,
    int? stageId,
    String? stageName,
    bool? todayMine,
    bool? untouched,
    bool? priorityOnly,
    bool? openOnly,
  }) {
    state = LeadFilterState(
      searchQuery: state.searchQuery,
      pipelineTab: state.pipelineTab,
      dateFilter: dateFilter,
      customStartDate: customStartDate,
      customEndDate: customEndDate,
      assignedUserId: assignedUserId,
      assignedUserName: assignedUserName,
      stageId: stageId,
      stageName: stageName,
      todayMine: todayMine ?? state.todayMine,
      untouched: untouched ?? state.untouched,
      priorityOnly: priorityOnly ?? state.priorityOnly,
      openOnly: openOnly ?? state.openOnly,
    );
  }

  void resetFilters() {
    state = LeadFilterState(
      searchQuery: state.searchQuery,
      pipelineTab: state.pipelineTab,
    );
  }
}

@riverpod
class LeadNotifier extends _$LeadNotifier {
  @override
  FutureOr<List<LeadEntity>> build() async {
    final filter = ref.watch(leadFilterNotifierProvider);
    final repository = ref.watch(leadRepositoryProvider);
    final range = filter.resolvedDateRange;

    final result = await repository.getLeads(
      startDate: range?.start,
      endDate: range?.end,
      assignedUserId: filter.assignedUserId,
      stageId: filter.stageId,
    );

    return result.when(
      success: (leads) => leads,
      failure: (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<String?> updateStage({
    required int leadId,
    required int stageId,
  }) async {
    final repository = ref.read(leadRepositoryProvider);
    final result = await repository.updateStage(
      leadId: leadId,
      stageId: stageId,
    );
    if (result.isFailure) return result.failureOrNull!.message;
    ref.invalidateSelf();
    await future;
    return null;
  }
}
