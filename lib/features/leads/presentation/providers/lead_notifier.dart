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
    this.assignedToMeOnly = false,
    this.dateFilter,
    this.customStartDate,
    this.customEndDate,
    this.assignedUserId,
    this.assignedUserName,
    this.stageId,
    this.stageName,
  });

  final String searchQuery;
  final bool assignedToMeOnly;
  final LeadDateFilter? dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final int? assignedUserId;
  final String? assignedUserName;
  final int? stageId;
  final String? stageName;

  bool get hasActiveServerFilters {
    return dateFilter != null ||
        assignedUserId != null ||
        stageId != null;
  }

  LeadDateRange? get resolvedDateRange => LeadDateRange.resolve(
        filter: dateFilter,
        customStart: customStartDate,
        customEnd: customEndDate,
      );

  LeadFilterState copyWith({
    String? searchQuery,
    bool? assignedToMeOnly,
    LeadDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    int? assignedUserId,
    String? assignedUserName,
    int? stageId,
    String? stageName,
    bool clearDateFilter = false,
    bool clearCustomDates = false,
    bool clearAssignedUser = false,
    bool clearStage = false,
  }) {
    return LeadFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      assignedToMeOnly: assignedToMeOnly ?? this.assignedToMeOnly,
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

  void setAssignedToMe(bool value) {
    state = state.copyWith(assignedToMeOnly: value);
  }

  void applyFilters({
    LeadDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    int? assignedUserId,
    String? assignedUserName,
    int? stageId,
    String? stageName,
  }) {
    state = LeadFilterState(
      searchQuery: state.searchQuery,
      assignedToMeOnly: state.assignedToMeOnly,
      dateFilter: dateFilter,
      customStartDate: customStartDate,
      customEndDate: customEndDate,
      assignedUserId: assignedUserId,
      assignedUserName: assignedUserName,
      stageId: stageId,
      stageName: stageName,
    );
  }

  void resetFilters() {
    state = LeadFilterState(
      searchQuery: state.searchQuery,
      assignedToMeOnly: state.assignedToMeOnly,
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
}
