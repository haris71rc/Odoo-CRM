import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/leads/data/datasource/lead_remote_datasource.dart';
import 'package:odoocrm/features/leads/data/mapper/lead_detail_mapper.dart';
import 'package:odoocrm/features/leads/data/mapper/lead_mapper.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/domain/repository/lead_repository.dart';

class LeadRepositoryImpl implements LeadRepository {
  LeadRepositoryImpl({
    required LeadRemoteDatasource datasource,
    LeadMapper leadMapper = const LeadMapper(),
    LeadDetailMapper detailMapper = const LeadDetailMapper(),
  })  : _datasource = datasource,
        _leadMapper = leadMapper,
        _detailMapper = detailMapper;

  final LeadRemoteDatasource _datasource;
  final LeadMapper _leadMapper;
  final LeadDetailMapper _detailMapper;

  @override
  Future<Result<List<LeadEntity>>> getLeads({
    DateTime? startDate,
    DateTime? endDate,
    int? assignedUserId,
    int? stageId,
    bool priorityOnly = false,
    bool openOnly = false,
    List<int> excludeStageIds = const [],
    int? excludePaidAdminId,
    List<int> excludePaidStageIds = const [],
    List<int> tagIds = const [],
  }) async {
    try {
      final dtos = await _datasource.searchRead(
        startDate: startDate,
        endDate: endDate,
        assignedUserId: assignedUserId,
        stageId: stageId,
        priorityOnly: priorityOnly,
        openOnly: openOnly,
        excludeStageIds: excludeStageIds,
        excludePaidAdminId: excludePaidAdminId,
        excludePaidStageIds: excludePaidStageIds,
        tagIds: tagIds,
      );
      return Success(_leadMapper.toEntityList(dtos));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<LeadDetailEntity>> getLeadDetail(int leadId) async {
    try {
      final dto = await _datasource.read(leadId);
      return Success(_detailMapper.toEntity(dto));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> assignToUser({
    required int leadId,
    required int userId,
  }) async {
    try {
      await _datasource.write(leadId, {'user_id': userId});
      return const Success(null);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateStage({
    required int leadId,
    required int stageId,
  }) async {
    try {
      await _datasource.write(leadId, {'stage_id': stageId});
      return const Success(null);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateRemark({
    required int leadId,
    required String description,
  }) async {
    try {
      await _datasource.write(leadId, {'description': description});
      return const Success(null);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
