import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/quotations/data/datasource/quotation_remote_datasource.dart';
import 'package:odoocrm/features/quotations/domain/entities/quotation_result.dart';
import 'package:odoocrm/features/quotations/domain/repository/quotation_repository.dart';

class QuotationRepositoryImpl implements QuotationRepository {
  QuotationRepositoryImpl({required QuotationRemoteDatasource datasource})
      : _datasource = datasource;

  final QuotationRemoteDatasource _datasource;

  @override
  Future<Result<QuotationResult>> createQuotationForLead(int leadId) async {
    try {
      final result = await _datasource.createQuotationForLead(leadId);
      return Success(result);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
