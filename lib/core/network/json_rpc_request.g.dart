// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_rpc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JsonRpcRequest _$JsonRpcRequestFromJson(Map<String, dynamic> json) =>
    _JsonRpcRequest(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: json['params'] as Map<String, dynamic>,
      id: (json['id'] as num?)?.toInt() ?? null,
    );

Map<String, dynamic> _$JsonRpcRequestToJson(_JsonRpcRequest instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'params': instance.params,
      'id': instance.id,
    };
