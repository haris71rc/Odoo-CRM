import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/activities/data/datasource/activity_remote_datasource.dart';
import 'package:odoocrm/features/activities/data/repository/activity_repository_impl.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';
import 'package:odoocrm/features/activities/domain/repository/activity_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_notifier.g.dart';

@Riverpod(keepAlive: true)
ActivityRepository activityRepository(Ref ref) {
  return ActivityRepositoryImpl(
    datasource: ActivityRemoteDatasource(ref.watch(dioClientProvider)),
  );
}

@riverpod
class ActivityNotifier extends _$ActivityNotifier {
  @override
  FutureOr<List<ActivityEntity>> build(int leadId) async {
    final repository = ref.watch(activityRepositoryProvider);
    final result = await repository.getActivitiesForLead(leadId);

    return result.when(
      success: (activities) => activities,
      failure: (failure) => throw failure,
    );
  }

  Future<String?> createActivity({
    required String summary,
    String? note,
    DateTime? dateDeadline,
  }) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.createActivity(
      leadId: leadId,
      summary: summary,
      note: note,
      dateDeadline: dateDeadline,
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
