import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/features/stages/data/dto/stage_dto.dart';

class StageRemoteDatasource {
  StageRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  Future<List<StageDto>> searchRead() async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.stage',
      method: 'search_read',
      args: const [<List<dynamic>>[]],
      kwargs: const {
        'fields': ['id', 'name', 'sequence', 'is_won'],
        'order': 'sequence asc',
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List) {
      throw const ParsingFailure('Unexpected stages response');
    }

    return result
        .map(
          (item) => StageDto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
