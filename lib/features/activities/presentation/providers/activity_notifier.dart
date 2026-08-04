import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/activities/data/datasource/activity_remote_datasource.dart';
import 'package:odoocrm/features/activities/data/repository/activity_repository_impl.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_type_entity.dart';
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
    required int activityTypeId,
    required String summary,
    required int userId,
    String? note,
    required DateTime dateDeadline,
  }) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.createActivity(
      leadId: leadId,
      activityTypeId: activityTypeId,
      summary: summary,
      userId: userId,
      note: note,
      dateDeadline: dateDeadline,
    );

    if (result.isFailure) return result.failureOrNull!.message;

    ref.invalidateSelf();
    await future;
    return null;
  }

  Future<String?> completeActivity(int activityId) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.completeActivity(activityId);

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

@riverpod
class ActivityTypesNotifier extends _$ActivityTypesNotifier {
  @override
  FutureOr<List<ActivityTypeEntity>> build() async {
    final repository = ref.watch(activityRepositoryProvider);
    final result = await repository.getActivityTypes();

    return result.when(
      success: (types) => types,
      failure: (failure) => throw failure,
    );
  }
}
