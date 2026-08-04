// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_rpc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JsonRpcRequest _$JsonRpcRequestFromJson(Map<String, dynamic> json) =>
    _JsonRpcRequest(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      method: json['method'] as String? ?? 'call',
      params: json['params'] as Map<String, dynamic>,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JsonRpcRequestToJson(_JsonRpcRequest instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'method': instance.method,
      'params': instance.params,
      'id': instance.id,
    };
