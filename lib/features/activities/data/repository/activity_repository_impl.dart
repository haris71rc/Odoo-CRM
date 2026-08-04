import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/activities/data/datasource/activity_remote_datasource.dart';
import 'package:odoocrm/features/activities/data/mapper/activity_mapper.dart';
import 'package:odoocrm/features/activities/data/mapper/activity_type_mapper.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_type_entity.dart';
import 'package:odoocrm/features/activities/domain/repository/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl({
    required ActivityRemoteDatasource datasource,
    ActivityMapper mapper = const ActivityMapper(),
    ActivityTypeMapper typeMapper = const ActivityTypeMapper(),
  })  : _datasource = datasource,
        _mapper = mapper,
        _typeMapper = typeMapper;

  final ActivityRemoteDatasource _datasource;
  final ActivityMapper _mapper;
  final ActivityTypeMapper _typeMapper;

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
  Future<Result<List<ActivityTypeEntity>>> getActivityTypes() async {
    try {
      final dtos = await _datasource.searchReadActivityTypes();
      return Success(_typeMapper.toEntityList(dtos));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createActivity({
    required int leadId,
    required int activityTypeId,
    required String summary,
    required int userId,
    String? note,
    required DateTime dateDeadline,
  }) async {
    try {
      final id = await _datasource.create(
        leadId: leadId,
        activityTypeId: activityTypeId,
        summary: summary,
        userId: userId,
        note: note,
        dateDeadline: dateDeadline,
      );
      return Success(id);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> completeActivity(int activityId) async {
    try {
      await _datasource.actionFeedback(activityId: activityId);
      return const Success(null);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
