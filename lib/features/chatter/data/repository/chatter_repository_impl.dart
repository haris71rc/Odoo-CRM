import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/chatter/data/datasource/chatter_remote_datasource.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';

class ChatterRepositoryImpl implements ChatterRepository {
  ChatterRepositoryImpl({
    required ChatterRemoteDatasource datasource,
  }) : _datasource = datasource;

  final ChatterRemoteDatasource _datasource;

  @override
  Future<Result<List<ChatterMessageEntity>>> getMessagesForLead(
    int leadId,
  ) async {
    try {
      final messages = await _datasource.fetchThreadMessagesForLead(leadId);
      return Success(messages);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logNote({
    required int leadId,
    required String body,
  }) async {
    try {
      await _datasource.postToThread(
        leadId: leadId,
        body: body,
        subtypeXmlid: 'mail.mt_note',
        emailAddSignature: false,
      );
      return const Success(null);
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
