import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_date_filter.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';
import 'package:odoocrm/features/leads/domain/utils/lead_date_range.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';

void main() {
  final range = LeadDateRange(
    start: DateTime(2026, 9, 1),
    end: DateTime(2026, 9, 30, 23, 59, 59),
  );
  const filter = LeadFilterState(dateFilter: LeadDateFilter.thisMonth);

  LeadEntity lead({
    required int id,
    required String stage,
    required DateTime created,
  }) {
    return LeadEntity(
      id: id,
      name: 'Lead $id',
      stage: NamedRefEntity(id: 1, name: stage),
      createdDate: created,
    );
  }

  final leads = [
    lead(id: 1, stage: 'New Prospects', created: DateTime(2026, 9, 10)),
    lead(id: 3, stage: 'Follow-up', created: DateTime(2026, 8, 1)),
    lead(id: 4, stage: 'Follow-up', created: DateTime(2026, 9, 15)),
  ];

  test('follow-up tab keeps leads outside the date range', () {
    final result = LeadListFilters.apply(
      leads: leads,
      filter: filter,
      currentUserId: 1,
      pipelineOverride: LeadPipelineTab.followup,
      dateRange: range,
    );

    expect(result.map((l) => l.id), [3, 4]);
  });

  test('other tabs keep the date filter for follow-up leads', () {
    final result = LeadListFilters.apply(
      leads: leads,
      filter: filter,
      currentUserId: 1,
      pipelineOverride: LeadPipelineTab.all,
      dateRange: range,
    );

    expect(result.map((l) => l.id), [1, 4]);
  });
}
