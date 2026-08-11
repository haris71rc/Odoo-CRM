import 'package:freezed_annotation/freezed_annotation.dart';

part 'json_rpc_request.freezed.dart';
part 'json_rpc_request.g.dart';

@freezed
abstract class JsonRpcRequest with _$JsonRpcRequest {
  const factory JsonRpcRequest({
    @Default('2.0') String jsonrpc,
    @Default('call') String method,
    required Map<String, dynamic> params,
    int? id,
  }) = _JsonRpcRequest;

  factory JsonRpcRequest.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcRequestFromJson(json);

  factory JsonRpcRequest.callKw({
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) {
    return JsonRpcRequest(
      params: {
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs,
      },
    );
  }

  /// Matches Odoo web button RPC: `POST /web/dataset/call_button/<model>/<method>`.
  factory JsonRpcRequest.callButton({
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) {
    return JsonRpcRequest(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      params: {
        'args': args,
        'kwargs': kwargs,
        'method': method,
        'model': model,
      },
    );
  }

  factory JsonRpcRequest.authenticate({
    required String db,
    required String login,
    required String password,
  }) {
    return JsonRpcRequest(
      params: {
        'db': db,
        'login': login,
        'password': password,
      },
    );
  }

  /// Matches Odoo web chatter: `POST /mail/thread/messages`.
  factory JsonRpcRequest.mailThreadMessages({
    required int threadId,
    required String threadModel,
    int limit = 100,
  }) {
    return JsonRpcRequest(
      params: {
        'thread_id': threadId,
        'thread_model': threadModel,
        'limit': limit,
      },
    );
  }

  /// Matches Odoo web chatter: `POST /mail/message/post`.
  factory JsonRpcRequest.mailMessagePost({
    required int threadId,
    required String threadModel,
    required String body,
    required String subtypeXmlid,
    required int uid,
    List<int> allowedCompanyIds = const [],
    bool emailAddSignature = true,
    String messageType = 'comment',
    String lang = 'en_US',
    String tz = 'Asia/Kolkata',
  }) {
    final context = <String, dynamic>{
      'lang': lang,
      'tz': tz,
      'uid': uid,
      'mail_post_autofollow': true,
      if (allowedCompanyIds.isNotEmpty)
        'allowed_company_ids': allowedCompanyIds,
    };

    return JsonRpcRequest(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      params: {
        'context': context,
        'post_data': {
          'body': body,
          'email_add_signature': emailAddSignature,
          'message_type': messageType,
          'subtype_xmlid': subtypeXmlid,
        },
        'thread_id': threadId,
        'thread_model': threadModel,
      },
    );
  }

  /// Odoo form save used for `lead_properties` updates.
  factory JsonRpcRequest.webSave({
    required String model,
    required List<int> recordIds,
    required Map<String, dynamic> values,
    required int uid,
    List<int> allowedCompanyIds = const [],
    Map<String, dynamic>? specification,
    String lang = 'en_US',
    String tz = 'Asia/Kolkata',
  }) {
    final context = <String, dynamic>{
      'lang': lang,
      'tz': tz,
      'uid': uid,
      if (allowedCompanyIds.isNotEmpty)
        'allowed_company_ids': allowedCompanyIds,
    };

    return JsonRpcRequest(
      params: {
        'model': model,
        'method': 'web_save',
        'args': [recordIds, values],
        'kwargs': {
          'context': context,
          if (specification != null) 'specification': specification,
        },
      },
    );
  }
}
