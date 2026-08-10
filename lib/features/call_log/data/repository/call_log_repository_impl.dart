import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/call_log/data/datasource/call_log_remote_datasource.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log_validation_snapshot.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/repository/call_log_repository.dart';

class CallLogRepositoryImpl implements CallLogRepository {
  CallLogRepositoryImpl({required CallLogRemoteDatasource datasource})
      : _datasource = datasource;

  final CallLogRemoteDatasource _datasource;

  @override
  Future<Result<CallLog>> getCallLog(int leadId) async {
    try {
      final callLog = await _datasource.fetchCallLog(leadId);
      return Success(callLog);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CallStatusOption>>> getCallStatusOptions(int leadId) async {
    try {
      final options = await _datasource.fetchCallStatusOptions(leadId);
      return Success(options);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<CallLogValidationSnapshot>> getValidationSnapshot(
    int leadId,
  ) async {
    try {
      final snapshot = await _datasource.fetchValidationSnapshot(leadId);
      return Success(snapshot);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveCallLog({
    required int leadId,
    required CallLog callLog,
  }) async {
    try {
      await _datasource.saveCallLog(leadId: leadId, callLog: callLog);
      return const Success(null);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
