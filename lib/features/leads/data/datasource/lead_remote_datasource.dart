import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/constants/app_environment.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/features/leads/data/dto/lead_detail_dto.dart';
import 'package:odoocrm/features/leads/data/dto/lead_dto.dart';

class LeadRemoteDatasource {
  LeadRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  static const _listFields = [
    'id',
    'name',
    'phone',
    'partner_name',
    'stage_id',
    'user_id',
    'priority',
    'create_date',
    'write_date',
  ];

  static const _detailFields = [
    'id',
    'name',
    'partner_name',
    'phone',
    'mobile',
    'email_from',
    'street',
    'city',
    'state_id',
    'country_id',
    'zip',
    'description',
    'stage_id',
    'user_id',
    'team_id',
    'priority',
    'create_date',
    'write_date',
    'expected_revenue',
    'probability',
    'tag_ids',
  ];

  Future<List<LeadDto>> searchRead({
    DateTime? startDate,
    DateTime? endDate,
    int? assignedUserId,
    int? stageId,
    bool priorityOnly = false,
    bool openOnly = false,
    List<int> excludeStageIds = const [],
    List<int> tagIds = const [],
  }) async {
    final extra = <List<dynamic>>[];

    if (assignedUserId != null) {
      extra.add(['user_id', '=', assignedUserId]);
    }

    if (stageId != null) {
      extra.add(['stage_id', '=', stageId]);
    }

    if (startDate != null) {
      extra.add(['create_date', '>=', DateFormatters.toApiDate(startDate)]);
    }
    if (endDate != null) {
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      extra.add(['create_date', '<=', DateFormatters.toApiDate(endOfDay)]);
    }

    // // High priority temporarily disabled.
    // if (priorityOnly) {
    //   // DigiLawyer Odoo crm.lead.priority selection: "0" Normal, "1" High
    //   extra.add(['priority', '=', '1']);
    // }

    if (openOnly) {
      if (excludeStageIds.isNotEmpty) {
        extra.add(['stage_id', 'not in', excludeStageIds]);
      } else {
        extra.add(['stage_id.is_won', '=', false]);
        extra.add(['active', '=', true]);
      }
    }

    // HOT_LEAD / WARM_LEAD (OR within the list; AND with other filters).
    if (tagIds.isNotEmpty) {
      extra.add(['tag_ids', 'in', tagIds]);
    }

    final domain = AppEnvironment.mergeDomain(extra);
    // ignore: avoid_print
    print('[LeadRemoteDatasource] crm.lead search_read domain: $domain');

    final request = JsonRpcRequest.callKw(
      model: 'crm.lead',
      method: 'search_read',
      args: [domain],
      kwargs: {
        'fields': _listFields,
        'order': 'create_date desc',
        'limit': 5000,
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List) {
      throw const ParsingFailure('Unexpected leads response');
    }

    return result
        .map((item) => LeadDto.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<LeadDetailDto> read(int leadId) async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.lead',
      method: 'read',
      args: [
        [leadId],
        _detailFields,
      ],
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List || result.isEmpty) {
      throw const ApiFailure('Lead not found');
    }

    return LeadDetailDto.fromJson(
      Map<String, dynamic>.from(result.first as Map),
    );
  }

  Future<void> write(int leadId, Map<String, dynamic> values) async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.lead',
      method: 'write',
      args: [
        [leadId],
        values,
      ],
    );

    await _dioClient.postJsonRpc(AppConstants.callKwPath, request);
  }
}
