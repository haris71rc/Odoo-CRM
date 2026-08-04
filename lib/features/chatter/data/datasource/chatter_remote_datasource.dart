import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/constants/app_environment.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/chatter/data/parser/chatter_store_parser.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';

class ChatterRemoteDatasource {
  ChatterRemoteDatasource({
    required DioClient dioClient,
    required SecureStorageService secureStorage,
    ChatterStoreParser storeParser = const ChatterStoreParser(),
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage,
        _storeParser = storeParser;

  final DioClient _dioClient;
  final SecureStorageService _secureStorage;
  final ChatterStoreParser _storeParser;

  /// Uses the same endpoint as Odoo web chatter so tracking values and
  /// message metadata match the web UI.
  Future<List<ChatterMessageEntity>> fetchThreadMessagesForLead(int leadId) async {
    final request = JsonRpcRequest.mailThreadMessages(
      threadId: leadId,
      threadModel: 'crm.lead',
      limit: 100,
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.mailThreadMessagesPath,
      request,
    );

    final result = response['result'];
    if (result is! Map) {
      throw const ParsingFailure('Unexpected chatter response');
    }

    return _storeParser.parse(Map<String, dynamic>.from(result));
  }

  /// Posts via Odoo web chatter endpoint: `/mail/message/post`.
  Future<void> postToThread({
    required int leadId,
    required String body,
    required String subtypeXmlid,
    bool emailAddSignature = true,
  }) async {
    final uid = await _secureStorage.getUid();
    if (uid == null) {
      throw const AuthFailure('No authenticated user');
    }

    final request = JsonRpcRequest.mailMessagePost(
      threadId: leadId,
      threadModel: 'crm.lead',
      body: body.trim(),
      subtypeXmlid: subtypeXmlid,
      uid: uid,
      allowedCompanyIds: AppEnvironment.allowedCompanyIds,
      emailAddSignature: emailAddSignature,
      messageType: 'comment',
    );

    await _dioClient.postJsonRpc(
      AppConstants.mailMessagePostPath,
      request,
    );
  }
}
