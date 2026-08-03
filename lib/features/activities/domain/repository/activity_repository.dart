import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';

abstract class ActivityRepository {
  Future<Result<List<ActivityEntity>>> getActivitiesForLead(int leadId);

  Future<Result<int>> createActivity({
    required int leadId,
    required String summary,
    String? note,
    DateTime? dateDeadline,
    int? activityTypeId,
  });
}
