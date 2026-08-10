import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/features/tags/domain/entities/lead_temperature_tag.dart';

class TagRemoteDatasource {
  TagRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  /// Loads temperature tags by exact name (`HOT_LEAD`, `WARM_LEAD`).
  Future<List<Map<String, dynamic>>> searchLeadTemperatureTags() async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.tag',
      method: 'search_read',
      args: [
        [
          ['name', 'in', LeadTemperatureTag.temperatureApiNames],
        ],
      ],
      kwargs: const {
        'fields': ['id', 'name', 'color'],
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List) {
      throw const ParsingFailure('Unexpected crm.tag response');
    }

    return result
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
