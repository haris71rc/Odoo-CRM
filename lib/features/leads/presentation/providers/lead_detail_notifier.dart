import 'package:odoocrm/features/call_log/presentation/providers/call_log_providers.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
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
