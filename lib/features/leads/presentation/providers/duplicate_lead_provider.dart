import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';

/// Lead ids that should show the Duplicate chip for the current list filters.
final duplicateLeadIdsProvider = FutureProvider<Set<int>>((ref) async {
  ref.keepAlive();
  await ref.watch(leadNotifierProvider.future);
  final params = await resolveLeadSearchParams(ref, watch: false);
  if (params == null) return const <int>{};

  final result = await ref
      .watch(leadRepositoryProvider)
      .findDuplicateLeadIds(
        assignedUserId: params.assignedUserId,
        stageId: params.stageId,
        openOnly: params.openOnly,
        excludeStageIds: params.excludeStageIds,
        excludePaidAdminId: params.excludePaidAdminId,
        excludePaidStageIds: params.excludePaidStageIds,
        tagIds: params.tagIds,
      );
  return result.valueOrNull ?? const <int>{};
});

/// True when [leadId] shares a number with a lead the salesperson already called.
final leadIsDuplicateProvider = FutureProvider.family<bool, int>((
  ref,
  leadId,
) async {
  final leads = await ref.watch(leadNotifierProvider.future);
  final listed = leads.any((lead) => lead.id == leadId);
  if (listed) {
    try {
      final ids = await ref.watch(duplicateLeadIdsProvider.future);
      return ids.contains(leadId);
    } catch (_) {
      // Fall through to a single-number lookup.
    }
  }

  final detail = await ref.read(leadRepositoryProvider).getLeadDetail(leadId);
  final lead = detail.valueOrNull;
  if (lead == null) return false;

  final result = await ref
      .read(leadRepositoryProvider)
      .isDuplicateLead(leadId: leadId, phone: lead.phone, mobile: lead.mobile);
  return result.valueOrNull ?? false;
});
