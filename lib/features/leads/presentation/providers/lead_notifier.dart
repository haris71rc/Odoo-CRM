import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/leads/data/datasource/lead_remote_datasource.dart';
import 'package:odoocrm/features/leads/data/repository/lead_repository_impl.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/domain/repository/lead_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lead_notifier.g.dart';

@Riverpod(keepAlive: true)
LeadRepository leadRepository(Ref ref) {
  return LeadRepositoryImpl(
    datasource: LeadRemoteDatasource(ref.watch(dioClientProvider)),
  );
}

class LeadListQuery {
  const LeadListQuery({
    this.searchQuery = '',
    this.assignedToMeOnly = false,
    this.startDate,
    this.endDate,
  });

  final String searchQuery;
  final bool assignedToMeOnly;
  final DateTime? startDate;
  final DateTime? endDate;

  LeadListQuery copyWith({
    String? searchQuery,
    bool? assignedToMeOnly,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return LeadListQuery(
      searchQuery: searchQuery ?? this.searchQuery,
      assignedToMeOnly: assignedToMeOnly ?? this.assignedToMeOnly,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}

@riverpod
class LeadFilterNotifier extends _$LeadFilterNotifier {
  @override
  LeadListQuery build() => const LeadListQuery();

  void setSearch(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setAssignedToMe(bool value) {
    state = state.copyWith(assignedToMeOnly: value);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void resetDates() {
    state = state.copyWith(clearDates: true);
  }
}

@riverpod
class LeadNotifier extends _$LeadNotifier {
  @override
  FutureOr<List<LeadEntity>> build() async {
    final filter = ref.watch(leadFilterNotifierProvider);
    final repository = ref.watch(leadRepositoryProvider);
    final result = await repository.getLeads(
      startDate: filter.startDate,
      endDate: filter.endDate,
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
