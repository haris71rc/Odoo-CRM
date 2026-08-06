import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/stage_call_validation_data.dart';
import 'package:odoocrm/features/mobile_call/domain/validation/stage_call_validator.dart';
import 'package:odoocrm/features/mobile_call/presentation/providers/mobile_call_providers.dart';
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

  /// Validates mobile-call rules, then writes `stage_id` via existing Odoo API.
  Future<String?> updateStage(
    int stageId, {
    String? targetStageName,
  }) async {
    final lead = state.valueOrNull;
    if (lead != null && lead.stage?.id == stageId) {
      return null;
    }

    final currentUserId = ref.read(authNotifierProvider).valueOrNull?.id;
    final mobileCallRepository = ref.read(mobileCallRepositoryProvider);
    final validationResult =
        await mobileCallRepository.fetchStageCallValidationData(leadId);
    if (validationResult.isFailure) {
      return validationResult.failureOrNull!.message;
    }

    final validationError = StageCallValidator.validate(
      currentStageName: lead?.stage?.name,
      targetStageName: targetStageName,
      data: validationResult.valueOrNull ??
          const StageCallValidationData(latestCall: null, mobileCalls: []),
      currentUserId: currentUserId,
    );
    if (validationError != null) return validationError;

    final repository = ref.read(leadRepositoryProvider);
    final result = await repository.updateStage(
      leadId: leadId,
      stageId: stageId,
    );

    if (result.isFailure) return result.failureOrNull!.message;

    ref.invalidate(latestMobileCallProvider(leadId));
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
    ref.invalidateSelf();
    await future;
  }
}
