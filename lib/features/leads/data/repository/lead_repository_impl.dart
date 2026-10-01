import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/call_log/data/datasource/call_log_remote_datasource.dart';
import 'package:odoocrm/features/leads/data/datasource/lead_remote_datasource.dart';
import 'package:odoocrm/features/leads/data/mapper/lead_detail_mapper.dart';
import 'package:odoocrm/features/leads/data/mapper/lead_mapper.dart';
import 'package:odoocrm/features/leads/domain/entities/duplicate_lead_candidate.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/domain/repository/lead_repository.dart';
import 'package:odoocrm/features/leads/domain/utils/duplicate_lead_matcher.dart';

class LeadRepositoryImpl implements LeadRepository {
  LeadRepositoryImpl({
    required LeadRemoteDatasource datasource,
    required CallLogRemoteDatasource callLogDatasource,
    LeadMapper leadMapper = const LeadMapper(),
    LeadDetailMapper detailMapper = const LeadDetailMapper(),
  }) : _datasource = datasource,
       _callLogDatasource = callLogDatasource,
       _leadMapper = leadMapper,
       _detailMapper = detailMapper;

  final LeadRemoteDatasource _datasource;
  final CallLogRemoteDatasource _callLogDatasource;
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
    List<int> dateExemptStageIds = const [],
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
        dateExemptStageIds: dateExemptStageIds,
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

  @override
  Future<Result<Set<int>>> findDuplicateLeadIds({
    int? assignedUserId,
    int? stageId,
    bool openOnly = false,
    List<int> excludeStageIds = const [],
    int? excludePaidAdminId,
    List<int> excludePaidStageIds = const [],
    List<int> tagIds = const [],
  }) async {
    try {
      final snapshots = await _datasource.searchPhoneSnapshots(
        assignedUserId: assignedUserId,
        stageId: stageId,
        openOnly: openOnly,
        excludeStageIds: excludeStageIds,
        excludePaidAdminId: excludePaidAdminId,
        excludePaidStageIds: excludePaidStageIds,
        tagIds: tagIds,
      );
      final candidates = [
        for (final snapshot in snapshots)
          DuplicateLeadCandidate(
            id: snapshot.id,
            phone: snapshot.phone,
            mobile: snapshot.mobile,
            createdDate: snapshot.createdDate,
          ),
      ];
      return Success(await _duplicateIdsFor(candidates));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isDuplicateLead({
    required int leadId,
    String? phone,
    String? mobile,
  }) async {
    try {
      final keys = DuplicateLeadMatcher.phoneKeys(phone, mobile);
      if (keys.isEmpty) return const Success(false);

      final snapshots = await _datasource.searchByPhoneKeys(keys.toList());
      final byId = <int, DuplicateLeadCandidate>{
        leadId: DuplicateLeadCandidate(
          id: leadId,
          phone: phone,
          mobile: mobile,
        ),
      };
      for (final snapshot in snapshots) {
        if (snapshot.id != leadId &&
            !DuplicateLeadMatcher.sharesAnyKey(
              phone: snapshot.phone,
              mobile: snapshot.mobile,
              keys: keys,
            )) {
          continue;
        }
        final existing = byId[snapshot.id];
        byId[snapshot.id] = DuplicateLeadCandidate(
          id: snapshot.id,
          phone: snapshot.phone ?? existing?.phone,
          mobile: snapshot.mobile ?? existing?.mobile,
          createdDate: snapshot.createdDate ?? existing?.createdDate,
        );
      }
      if (byId.length < 2) return const Success(false);

      final ids = await _duplicateIdsFor(byId.values);
      return Success(ids.contains(leadId));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  Future<Set<int>> _duplicateIdsFor(
    Iterable<DuplicateLeadCandidate> candidates,
  ) async {
    final sharedIds = DuplicateLeadMatcher.idsSharingNumber(candidates);
    if (sharedIds.isEmpty) return const {};

    final logs = await _callLogDatasource.fetchCallLogs(sharedIds.toList());
    final enriched = <DuplicateLeadCandidate>[
      for (final candidate in candidates)
        if (sharedIds.contains(candidate.id))
          DuplicateLeadCandidate(
            id: candidate.id,
            phone: candidate.phone,
            mobile: candidate.mobile,
            createdDate: candidate.createdDate,
            firstCallDate: logs[candidate.id]?.firstCallDate,
            totalOutboundCalls: logs[candidate.id]?.totalOutboundCalls ?? 0,
          ),
    ];
    return DuplicateLeadMatcher.duplicateIds(enriched);
  }
}
