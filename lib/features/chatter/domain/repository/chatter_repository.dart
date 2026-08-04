import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';

abstract class ChatterRepository {
  Future<Result<List<ChatterMessageEntity>>> getMessagesForLead(int leadId);

  Future<Result<void>> logNote({
    required int leadId,
    required String body,
  });
}
