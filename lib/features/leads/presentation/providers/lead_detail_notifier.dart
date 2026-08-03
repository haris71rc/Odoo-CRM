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

  Future<String?> assignToMe(int userId) async {
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

  Future<String?> updateStage(int stageId) async {
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
