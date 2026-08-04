import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/features/activities/data/dto/activity_dto.dart';
import 'package:odoocrm/features/activities/data/dto/activity_type_dto.dart';

class ActivityRemoteDatasource {
  ActivityRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

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
          'user_id',
          'state',
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

  Future<List<ActivityTypeDto>> searchReadActivityTypes() async {
    final request = JsonRpcRequest.callKw(
      model: 'mail.activity.type',
      method: 'search_read',
      args: const [<List<dynamic>>[]],
      kwargs: const {
        'fields': [
          'id',
          'name',
          'icon',
          'delay_count',
          'delay_unit',
        ],
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List) {
      throw const ParsingFailure('Unexpected activity types response');
    }

    return result
        .map(
          (item) => ActivityTypeDto.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<int> create({
    required int leadId,
    required int activityTypeId,
    required String summary,
    required int userId,
    String? note,
    required DateTime dateDeadline,
  }) async {
    final values = <String, dynamic>{
      'res_model': 'crm.lead',
      'res_id': leadId,
      'activity_type_id': activityTypeId,
      'summary': summary,
      'date_deadline': DateFormatters.toApiDate(dateDeadline).split(' ').first,
      'user_id': userId,
      if (note != null && note.isNotEmpty) 'note': note,
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

  Future<void> actionFeedback({
    required int activityId,
    String feedback = 'Completed',
  }) async {
    final request = JsonRpcRequest.callKw(
      model: 'mail.activity',
      method: 'action_feedback',
      args: [
        [activityId],
      ],
      kwargs: {
        'feedback': feedback,
      },
    );

    await _dioClient.postJsonRpc(AppConstants.callKwPath, request);
  }
}
