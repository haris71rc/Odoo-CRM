import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/activities/data/datasource/activity_remote_datasource.dart';
import 'package:odoocrm/features/activities/data/mapper/activity_mapper.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';
import 'package:odoocrm/features/activities/domain/repository/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl({
    required ActivityRemoteDatasource datasource,
    ActivityMapper mapper = const ActivityMapper(),
  })  : _datasource = datasource,
        _mapper = mapper;

  final ActivityRemoteDatasource _datasource;
  final ActivityMapper _mapper;

  @override
  Future<Result<List<ActivityEntity>>> getActivitiesForLead(int leadId) async {
    try {
      final dtos = await _datasource.searchReadForLead(leadId);
      return Success(_mapper.toEntityList(dtos));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createActivity({
    required int leadId,
    required String summary,
    String? note,
    DateTime? dateDeadline,
    int? activityTypeId,
  }) async {
    try {
      final id = await _datasource.create(
        leadId: leadId,
        summary: summary,
        note: note,
        dateDeadline: dateDeadline,
        activityTypeId: activityTypeId,
      );
      return Success(id);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
