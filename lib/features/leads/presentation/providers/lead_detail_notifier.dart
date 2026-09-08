import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/utils/connected_call_rule.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_log_providers.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';
import 'package:odoocrm/features/stages/presentation/providers/stage_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lead_detail_notifier.g.dart';

@riverpod
class LeadDetailNotifier extends _$LeadDetailNotifier {
  @override
  FutureOr<LeadDetailEntity> build(int leadId) async {
    final repository = ref.watch(leadRepositoryProvider);
    final result = await repository.getLeadDetail(leadId);

    return result.when(
      success: (lead) => lead,
      failure: (failure) => throw failure,
    );
  }

  Future<String?> assignToMe(int userId) => assignToUser(userId);

  Future<String?> assignToUser(int userId) async {
    final repository = ref.read(leadRepositoryProvider);
    final result = await repository.assignToUser(
      leadId: leadId,
      userId: userId,
    );

    if (result.isFailure) return result.failureOrNull!.message;

    ref.invalidateSelf();
    await future;
    return null;
  }

  /// Assigns the lead to [userId] when that user exists and is not already
  /// the salesperson. Used after the logged-in user has called the lead.
  ///
  /// Returns `true` when assignment was applied successfully.
  Future<bool> autoAssignCaller(int? userId) async {
    if (userId == null) return false;

    final lead = state.valueOrNull ?? await future;
    if (lead.assignedUser?.id == userId) return false;

    final error = await assignToUser(userId);
    if (error != null) return false;

    ref.invalidate(leadNotifierProvider);
    return true;
  }

  /// Moves the lead to Connected after a picked call lasting ≥ 3 seconds.
  ///
  /// DNP / missed / failed calls do not promote. Skips later pipeline stages
  /// (Follow-Up, Proposal, Won, Lost). Re-reads the lead from Odoo so a stale
  /// local stage cannot overwrite Follow-Up.
  Future<bool> autoMoveToConnected(CallLog callEvent) async {
    if (!ConnectedCallRule.callWasMade(callEvent)) {
      return false;
    }

    final repository = ref.read(leadRepositoryProvider);
    final freshResult = await repository.getLeadDetail(leadId);
    final lead = freshResult.when(
      success: (value) => value,
      failure: (_) => state.valueOrNull,
    );
    if (lead == null) {
      return false;
    }

    final stageName = lead.stage?.name;
    if (!ConnectedCallRule.shouldMoveToConnected(stageName)) {
      return false;
    }

    final stages = await ref.read(stageNotifierProvider.future);
    final connectedStageId = LeadListFilters.findConnectedStageId(stages);
    if (connectedStageId == null) return false;
    if (lead.stage?.id == connectedStageId) return false;

    final result = await repository.updateStage(
      leadId: leadId,
      stageId: connectedStageId,
    );
    if (result.isFailure) return false;

    ref.invalidateSelf();
    ref.invalidate(leadNotifierProvider);
    await future;
    return true;
  }

  Future<String?> updateStage(
    int stageId, {
    String? targetStageName,
  }) async {
    final lead = state.valueOrNull;
    if (lead != null && lead.stage?.id == stageId) {
      return null;
    }

    final validation = await ref.read(callLogServiceProvider).validateStageChange(
          leadId: leadId,
          currentStageName: lead?.stage?.name,
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

  Future<String?> updateRemark(String description) async {
    final repository = ref.read(leadRepositoryProvider);
    final result = await repository.updateRemark(
      leadId: leadId,
      description: description,
    );

    if (result.isFailure) return result.failureOrNull!.message;

    ref.invalidateSelf();
    await future;
    return null;
  }

  Future<void> refresh() async {
    ref.invalidate(leadCallLogProvider(leadId));
    ref.invalidateSelf();
    await future;
  }
}
