import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/features/activities/data/dto/activity_dto.dart';

class ActivityRemoteDatasource {
  ActivityRemoteDatasource(this._dioClient);

  final DioClient _dioClient;
  int? _crmLeadModelId;

  Future<List<ActivityDto>> searchReadForLead(int leadId) async {
    final request = JsonRpcRequest.callKw(
      model: 'mail.activity',
      method: 'search_read',
      args: [
        [
          ['res_model', '=', 'crm.lead'],
          ['res_id', '=', leadId],
        ],
      ],
      kwargs: const {
        'fields': [
          'id',
          'summary',
          'note',
          'date_deadline',
          'activity_type_id',
          'state',
          'user_id',
        ],
        'order': 'date_deadline asc',
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List) {
      throw const ParsingFailure('Unexpected activities response');
    }

    return result
        .map(
          (item) =>
              ActivityDto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<int> _resolveCrmLeadModelId() async {
    if (_crmLeadModelId != null) return _crmLeadModelId!;

    final request = JsonRpcRequest.callKw(
      model: 'ir.model',
      method: 'search_read',
      args: [
        [
          ['model', '=', 'crm.lead'],
        ],
      ],
      kwargs: const {
        'fields': ['id'],
        'limit': 1,
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List || result.isEmpty) {
      throw const ApiFailure('Unable to resolve crm.lead model id');
    }

    final id = (result.first as Map)['id'];
    if (id is! int) {
      throw const ParsingFailure('Invalid ir.model id');
    }

    _crmLeadModelId = id;
    return id;
  }

  Future<int> create({
    required int leadId,
    required String summary,
    String? note,
    DateTime? dateDeadline,
    int? activityTypeId,
  }) async {
    final modelId = await _resolveCrmLeadModelId();

    final values = <String, dynamic>{
      'res_model_id': modelId,
      'res_id': leadId,
      'summary': summary,
      'note': ?note,
      if (dateDeadline != null)
        'date_deadline':
            DateFormatters.toApiDate(dateDeadline).split(' ').first,
      'activity_type_id': ?activityTypeId,
    };

    final request = JsonRpcRequest.callKw(
      model: 'mail.activity',
      method: 'create',
      args: [values],
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is int) return result;
    throw const ParsingFailure('Unexpected create activity response');
  }
}
