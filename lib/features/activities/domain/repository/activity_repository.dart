import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_type_entity.dart';

abstract class ActivityRepository {
  Future<Result<List<ActivityEntity>>> getActivitiesForLead(int leadId);

  Future<Result<List<ActivityTypeEntity>>> getActivityTypes();

  Future<Result<int>> createActivity({
    required int leadId,
    required int activityTypeId,
    required String summary,
    required int userId,
    String? note,
    required DateTime dateDeadline,
  });

  Future<Result<void>> completeActivity(int activityId);
}
