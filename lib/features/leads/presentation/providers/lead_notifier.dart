import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_log_providers.dart';
import 'package:odoocrm/features/leads/data/datasource/lead_remote_datasource.dart';
import 'package:odoocrm/features/leads/data/repository/lead_repository_impl.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_date_filter.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/domain/repository/lead_repository.dart';
import 'package:odoocrm/features/leads/domain/utils/lead_date_range.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';
import 'package:odoocrm/features/stages/presentation/providers/stage_notifier.dart';
import 'package:odoocrm/features/tags/domain/entities/lead_temperature_tag.dart';
import 'package:odoocrm/features/tags/presentation/providers/tag_providers.dart';
import 'package:odoocrm/features/users/presentation/providers/users_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lead_notifier.g.dart';

enum LeadPipelineTab { all, mine, followup, won, lost }

@Riverpod(keepAlive: true)
LeadRepository leadRepository(Ref ref) {
  return LeadRepositoryImpl(
    datasource: LeadRemoteDatasource(ref.watch(dioClientProvider)),
  );
}

/// Server-side params that should trigger a leads refetch.
typedef LeadServerFilterKey = ({
  LeadDateFilter? dateFilter,
  DateTime? customStartDate,
  DateTime? customEndDate,
  int? assignedUserId,
  int? stageId,
  bool todayMine,
  bool untouched,
  bool priorityOnly,
  bool openOnly,
  bool paid,
  List<LeadTemperatureTag> temperatureTags,
});

/// Applied lead list filters (Odoo domain + local pipeline/search).
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
    this.paid = false,
    this.temperatureTags = const {},
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

  /// When true, hides Paid leads (Won/Lost assigned to Administrator).
  final bool paid;

  /// Selected HOT_LEAD / WARM_LEAD filters (multi-select).
  final Set<LeadTemperatureTag> temperatureTags;

  bool get assignedToMeOnly => pipelineTab == LeadPipelineTab.mine;

  int get localFilterCount {
    var count = 0;
    if (todayMine) count++;
    if (untouched) count++;
    // if (priorityOnly) count++;
    if (openOnly) count++;
    if (paid) count++;
    if (dateFilter != null) count++;
    if (assignedUserId != null) count++;
    if (stageId != null) count++;
    count += temperatureTags.length;
    return count;
  }

  bool get hasActiveServerFilters {
    return dateFilter != null ||
        assignedUserId != null ||
        stageId != null ||
        todayMine ||
        untouched ||
        // priorityOnly ||
        openOnly ||
        paid ||
        temperatureTags.isNotEmpty;
  }

  LeadServerFilterKey get serverFilterKey {
    final tags = temperatureTags.toList()
      ..sort((a, b) => a.apiName.compareTo(b.apiName));
    return (
      dateFilter: dateFilter,
      customStartDate: customStartDate,
      customEndDate: customEndDate,
      assignedUserId: assignedUserId,
      stageId: stageId,
      todayMine: todayMine,
      untouched: untouched,
      priorityOnly: false, // disabled
      openOnly: openOnly,
      paid: paid,
      temperatureTags: tags,
    );
  }

  LeadDateRange? get resolvedDateRange => LeadDateRange.resolve(
        filter: dateFilter,
        customStart: customStartDate,
        customEnd: customEndDate,
      );

  String? get dateFilterLabel {
    if (dateFilter == null) return null;
    return dateFilter!.label;
  }

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
    bool? paid,
    Set<LeadTemperatureTag>? temperatureTags,
    bool clearDateFilter = false,
    bool clearCustomDates = false,
    bool clearAssignedUser = false,
    bool clearStage = false,
    bool clearTemperatureTags = false,
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
      paid: paid ?? this.paid,
      temperatureTags: clearTemperatureTags
          ? const {}
          : (temperatureTags ?? this.temperatureTags),
    );
  }
}

@Riverpod(keepAlive: true)
class LeadFilterNotifier extends _$LeadFilterNotifier {
  @override
  LeadFilterState build() => const LeadFilterState(paid: true);

  void setSearch(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setPipelineTab(LeadPipelineTab tab) {
    // Keep date / assignee / stage filters when switching segments.
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
        final next = !state.todayMine;
        state = state.copyWith(
          todayMine: next,
          // Assigned-to-me-today uses logged-in user + create_date today.
          clearAssignedUser: next,
          clearDateFilter: next,
          clearCustomDates: next,
        );
      case 'untouched':
        final next = !state.untouched;
        state = state.copyWith(
          untouched: next,
          clearStage: next,
        );
      // case 'priority':
      //   state = state.copyWith(priorityOnly: !state.priorityOnly);
      case 'open':
        state = state.copyWith(openOnly: !state.openOnly);
      case 'paid':
        state = state.copyWith(paid: !state.paid);
      case 'hot':
        _toggleTemperatureTag(LeadTemperatureTag.hot);
      case 'warm':
        _toggleTemperatureTag(LeadTemperatureTag.warm);
    }
  }

  void toggleTemperatureTag(LeadTemperatureTag tag) {
    _toggleTemperatureTag(tag);
  }

  void _toggleTemperatureTag(LeadTemperatureTag tag) {
    final next = Set<LeadTemperatureTag>.from(state.temperatureTags);
    if (!next.add(tag)) next.remove(tag);
    state = state.copyWith(temperatureTags: next);
  }

  void clearLocalFilters() {
    state = state.copyWith(
      todayMine: false,
      untouched: false,
      priorityOnly: false,
      openOnly: false,
      paid: false,
      clearDateFilter: true,
      clearCustomDates: true,
      clearAssignedUser: true,
      clearStage: true,
      clearTemperatureTags: true,
    );
  }

  void clearDateFilter() {
    state = state.copyWith(clearDateFilter: true, clearCustomDates: true);
  }

  void clearAssignedUser() {
    state = state.copyWith(clearAssignedUser: true);
  }

  void clearStage() {
    state = state.copyWith(clearStage: true);
  }

  void clearTemperatureTags() {
    state = state.copyWith(clearTemperatureTags: true);
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
    bool? paid,
    Set<LeadTemperatureTag>? temperatureTags,
  }) {
    var nextTodayMine = todayMine ?? state.todayMine;
    var nextUserId = assignedUserId;
    var nextUserName = assignedUserName;

    // Assigned-to-me-today owns the assignee + date; drop explicit assignee/date.
    if (nextTodayMine) {
      nextUserId = null;
      nextUserName = null;
    }

    var nextTab = state.pipelineTab;
    if (stageId != null &&
        (nextTab == LeadPipelineTab.followup ||
            nextTab == LeadPipelineTab.won ||
            nextTab == LeadPipelineTab.lost)) {
      nextTab = LeadPipelineTab.all;
    }

    // Untouched uses New Prospect stage; drop an explicit stage picker value
    // so domains don't conflict on stage_id.
    final nextUntouched = untouched ?? state.untouched;
    final nextStageId = nextUntouched ? null : stageId;
    final nextStageName = nextUntouched ? null : stageName;
    if (nextUntouched &&
        (nextTab == LeadPipelineTab.followup ||
            nextTab == LeadPipelineTab.won ||
            nextTab == LeadPipelineTab.lost)) {
      nextTab = LeadPipelineTab.all;
    }

    state = LeadFilterState(
      searchQuery: state.searchQuery,
      pipelineTab: nextTab,
      dateFilter: nextTodayMine ? null : dateFilter,
      customStartDate: nextTodayMine
          ? null
          : (dateFilter == LeadDateFilter.custom ? customStartDate : null),
      customEndDate: nextTodayMine
          ? null
          : (dateFilter == LeadDateFilter.custom ? customEndDate : null),
      assignedUserId: nextUserId,
      assignedUserName: nextUserName,
      stageId: nextStageId,
      stageName: nextStageName,
      todayMine: nextTodayMine,
      untouched: nextUntouched,
      priorityOnly: priorityOnly ?? state.priorityOnly,
      openOnly: openOnly ?? state.openOnly,
      paid: paid ?? state.paid,
      temperatureTags: temperatureTags ?? state.temperatureTags,
    );
  }

  void resetFilters() {
    state = LeadFilterState(
      searchQuery: state.searchQuery,
      pipelineTab: state.pipelineTab,
    );
  }
}

@Riverpod(keepAlive: true)
class LeadNotifier extends _$LeadNotifier {
  @override
  FutureOr<List<LeadEntity>> build() async {
    final serverKey = ref.watch(
      leadFilterNotifierProvider.select((f) => f.serverFilterKey),
    );
    final currentUserId = ref.watch(
      authNotifierProvider.select((a) => a.valueOrNull?.id),
    );
    final repository = ref.watch(leadRepositoryProvider);

    if (currentUserId == null) return const [];

    var range = LeadDateRange.resolve(
      filter: serverKey.dateFilter,
      customStart: serverKey.customStartDate,
      customEnd: serverKey.customEndDate,
    );

    var assignedUserId = serverKey.assignedUserId;

    // Assigned to me today → logged-in user + create_date = today.
    if (serverKey.todayMine) {
      assignedUserId = currentUserId;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      range = LeadDateRange(
        start: today,
        end: DateTime(today.year, today.month, today.day, 23, 59, 59),
      );
    }

    List<int> excludeStageIds = const [];
    int? stageId = serverKey.stageId;

    if (serverKey.untouched || serverKey.openOnly) {
      final stages = await ref.watch(stageNotifierProvider.future);

      if (serverKey.untouched) {
        // Untouched = still in New Prospect / New Prospects stage.
        stageId = LeadListFilters.findNewProspectStageId(stages);
        if (stageId == null) return const [];
      }

      if (serverKey.openOnly) {
        excludeStageIds = stages
            .where(
              (s) =>
                  s.isWon == true ||
                  LeadListFilters.isWon(s.name) ||
                  LeadListFilters.isLost(s.name),
            )
            .map((s) => s.id)
            .toList();
      }
    }

    int? excludePaidAdminId;
    List<int> excludePaidStageIds = const [];
    if (serverKey.paid) {
      final users = await ref.watch(usersNotifierProvider.future);
      final adminId = LeadListFilters.findAdministratorUserId(users);
      if (adminId != null) {
        final stages = await ref.watch(stageNotifierProvider.future);
        final stageIds = LeadListFilters.findWonOrLostStageIds(stages);
        if (stageIds.isNotEmpty) {
          excludePaidAdminId = adminId;
          excludePaidStageIds = stageIds;
        }
      }
    }

    List<int> tagIds = const [];
    if (serverKey.temperatureTags.isNotEmpty) {
      try {
        await ref.watch(leadTemperatureTagsNotifierProvider.future);
      } catch (_) {
        // Tag metadata unavailable — skip tag domain rather than crashing.
      }
      tagIds = ref
          .read(leadTemperatureTagsNotifierProvider.notifier)
          .resolveIds(serverKey.temperatureTags);
      // Selected tags exist in state but none resolved → empty result.
      if (tagIds.isEmpty) return const [];
    }

    final result = await repository.getLeads(
      startDate: range?.start,
      endDate: range?.end,
      assignedUserId: assignedUserId,
      stageId: stageId,
      // priorityOnly: serverKey.priorityOnly, // disabled
      priorityOnly: false,
      openOnly: serverKey.openOnly,
      excludeStageIds: excludeStageIds,
      excludePaidAdminId: excludePaidAdminId,
      excludePaidStageIds: excludePaidStageIds,
      tagIds: tagIds,
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
    String? currentStageName,
    String? targetStageName,
  }) async {
    final validation = await ref.read(callLogServiceProvider).validateStageChange(
          leadId: leadId,
          currentStageName: currentStageName,
          targetStageName: targetStageName,
        );

    if (validation.isFailure) {
      return validation.failureOrNull!.message;
    }

    final validationError = validation.valueOrNull;
    if (validationError != null) return validationError;

    final repository = ref.read(leadRepositoryProvider);
    final result = await repository.updateStage(
      leadId: leadId,
      stageId: stageId,
    );
    if (result.isFailure) return result.failureOrNull!.message;
    ref.invalidate(leadCallLogProvider(leadId));
    ref.invalidateSelf();
    await future;
    return null;
  }
}
