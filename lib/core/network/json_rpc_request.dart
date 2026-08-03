import 'package:freezed_annotation/freezed_annotation.dart';

part 'json_rpc_request.freezed.dart';
part 'json_rpc_request.g.dart';

@freezed
abstract class JsonRpcRequest with _$JsonRpcRequest {
  const factory JsonRpcRequest({
    @Default('2.0') String jsonrpc,
    required Map<String, dynamic> params,
    @Default(null) int? id,
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
}
