import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/constants/app_environment.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/features/leads/data/dto/lead_detail_dto.dart';
import 'package:odoocrm/features/leads/data/dto/lead_dto.dart';
import 'package:odoocrm/features/leads/data/dto/lead_phone_snapshot.dart';
import 'package:odoocrm/features/leads/domain/entities/lost_reason.dart';

class LeadRemoteDatasource {
  LeadRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  static const _listFields = [
    'id',
    'name',
    'phone',
    'mobile',
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
    int? excludePaidAdminId,
    List<int> excludePaidStageIds = const [],
    List<int> tagIds = const [],
    List<int> dateExemptStageIds = const [],
  }) async {
    final domain = _searchDomain(
      startDate: startDate,
      endDate: endDate,
      assignedUserId: assignedUserId,
      stageId: stageId,
      openOnly: openOnly,
      excludeStageIds: excludeStageIds,
      excludePaidAdminId: excludePaidAdminId,
      excludePaidStageIds: excludePaidStageIds,
      tagIds: tagIds,
      dateExemptStageIds: dateExemptStageIds,
    );
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

  /// Same assignee, stage, and tag filters as [searchRead], without create date.
  ///
  /// Used to find an already-called lead that sits outside the list's date range.
  Future<List<LeadPhoneSnapshot>> searchPhoneSnapshots({
    int? assignedUserId,
    int? stageId,
    bool openOnly = false,
    List<int> excludeStageIds = const [],
    int? excludePaidAdminId,
    List<int> excludePaidStageIds = const [],
    List<int> tagIds = const [],
  }) {
    final domain = _searchDomain(
      assignedUserId: assignedUserId,
      stageId: stageId,
      openOnly: openOnly,
      excludeStageIds: excludeStageIds,
      excludePaidAdminId: excludePaidAdminId,
      excludePaidStageIds: excludePaidStageIds,
      tagIds: tagIds,
      includeCreateDate: false,
    );
    return _searchPhoneSnapshots(domain, limit: 5000);
  }

  /// Leads whose phone or mobile contains one of [keys] (last-10 fragments).
  Future<List<LeadPhoneSnapshot>> searchByPhoneKeys(List<String> keys) {
    final unique = keys
        .map((key) => key.trim())
        .where((key) => key.isNotEmpty)
        .toSet();
    if (unique.isEmpty) return Future.value(const []);

    final clauses = <List<dynamic>>[
      for (final key in unique) ...[
        ['phone', 'ilike', key],
        ['mobile', 'ilike', key],
      ],
    ];
    final domain = <dynamic>[
      ...AppEnvironment.baseDomain,
      ..._orDomain(clauses),
    ];
    return _searchPhoneSnapshots(domain, limit: 80);
  }

  Future<List<LeadPhoneSnapshot>> _searchPhoneSnapshots(
    List<dynamic> domain, {
    required int limit,
  }) async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.lead',
      method: 'search_read',
      args: [domain],
      kwargs: {
        'fields': const ['id', 'phone', 'mobile', 'create_date'],
        'order': 'create_date desc',
        'limit': limit,
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
        .map(
          (item) => LeadPhoneSnapshot.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  List<dynamic> _searchDomain({
    DateTime? startDate,
    DateTime? endDate,
    int? assignedUserId,
    int? stageId,
    bool openOnly = false,
    List<int> excludeStageIds = const [],
    int? excludePaidAdminId,
    List<int> excludePaidStageIds = const [],
    List<int> tagIds = const [],
    List<int> dateExemptStageIds = const [],
    bool includeCreateDate = true,
  }) {
    final extra = <List<dynamic>>[];

    if (assignedUserId != null) {
      extra.add(['user_id', '=', assignedUserId]);
    }

    if (stageId != null) {
      extra.add(['stage_id', '=', stageId]);
    }

    if (openOnly) {
      if (excludeStageIds.isNotEmpty) {
        extra.add(['stage_id', 'not in', excludeStageIds]);
      } else {
        extra.add(['stage_id.is_won', '=', false]);
        extra.add(['active', '=', true]);
      }
    }

    if (tagIds.isNotEmpty) {
      extra.add(['tag_ids', 'in', tagIds]);
    }

    return <dynamic>[
      ...AppEnvironment.mergeDomain(extra),
      if (includeCreateDate)
        ..._createDateDomain(
          startDate: startDate,
          endDate: endDate,
          dateExemptStageIds: dateExemptStageIds,
        ),
      if (excludePaidAdminId != null && excludePaidStageIds.isNotEmpty) ...[
        '!',
        '&',
        ['user_id', '=', excludePaidAdminId],
        ['stage_id', 'in', excludePaidStageIds],
      ],
    ];
  }

  static List<dynamic> _orDomain(List<List<dynamic>> clauses) {
    if (clauses.length <= 1) return clauses;
    return [for (var i = 0; i < clauses.length - 1; i++) '|', ...clauses];
  }

  /// Create-date clause. Follow-up stages are OR'd in so that section is not
  /// limited by the selected date range.
  static List<dynamic> _createDateDomain({
    DateTime? startDate,
    DateTime? endDate,
    List<int> dateExemptStageIds = const [],
  }) {
    if (startDate == null && endDate == null) return const [];

    final parts = <dynamic>[];
    if (startDate != null && endDate != null) parts.add('&');
    if (startDate != null) {
      parts.add(['create_date', '>=', DateFormatters.toApiDate(startDate)]);
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
      parts.add(['create_date', '<=', DateFormatters.toApiDate(endOfDay)]);
    }

    if (dateExemptStageIds.isEmpty) return parts;

    return [
      '|',
      ...parts,
      ['stage_id', 'in', dateExemptStageIds],
    ];
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

  Map<String, dynamic> _lostContext(int leadId, {int? userId}) => {
    'lang': 'en_US',
    'tz': 'Asia/Kolkata',
    'uid': ?userId,
    if (AppEnvironment.allowedCompanyIds.isNotEmpty)
      'allowed_company_ids': AppEnvironment.allowedCompanyIds,
    'active_model': 'crm.lead',
    'active_id': leadId,
    'active_ids': [leadId],
    'dialog_size': 'medium',
  };

  Future<List<LostReason>> searchLostReasons(int leadId, String query) async {
    final response = await _dioClient.postJsonRpc(
      '${AppConstants.callKwPath}/crm.lost.reason/name_search',
      JsonRpcRequest.callKw(
        model: 'crm.lost.reason',
        method: 'name_search',
        kwargs: {
          'name': query,
          'operator': 'ilike',
          'args': <dynamic>[],
          'limit': 8,
          'context': _lostContext(leadId),
        },
      ),
    );
    final rows = response['result'];
    if (rows is! List) {
      throw const ParsingFailure('Unexpected lost reasons response');
    }
    return [
      for (final row in rows)
        if (row is List && row.length >= 2 && row[0] is int)
          LostReason(id: row[0] as int, name: row[1].toString()),
    ];
  }

  Future<LostReasonPage> getLostReasons(
    int leadId, {
    required int offset,
  }) async {
    final response = await _dioClient.postJsonRpc(
      '${AppConstants.callKwPath}/crm.lost.reason/web_search_read',
      JsonRpcRequest.callKw(
        model: 'crm.lost.reason',
        method: 'web_search_read',
        kwargs: {
          'specification': {'name': <String, dynamic>{}},
          'offset': offset,
          'order': '',
          'limit': 80,
          'context': _lostContext(leadId),
          'count_limit': 10001,
          'domain': <dynamic>[],
        },
      ),
    );
    final result = response['result'];
    if (result is! Map || result['records'] is! List) {
      throw const ParsingFailure('Unexpected lost reasons page');
    }
    final rows = result['records'] as List;
    return LostReasonPage(
      records: [
        for (final row in rows)
          if (row is Map && row['id'] is int)
            LostReason(id: row['id'] as int, name: row['name'].toString()),
      ],
      total: (result['length'] as num?)?.toInt() ?? offset + rows.length,
    );
  }

  Future<void> markLost({
    required int leadId,
    required int reasonId,
    required String feedback,
    required int userId,
    required int lostStageId,
  }) async {
    final context = {
      ..._lostContext(leadId, userId: userId),
      'default_lead_ids': [leadId],
    };
    final saved = await _dioClient.postJsonRpc(
      '${AppConstants.callKwPath}/crm.lead.lost/web_save',
      JsonRpcRequest.callKw(
        model: 'crm.lead.lost',
        method: 'web_save',
        args: [
          <int>[],
          {
            'lead_ids': [
              [4, leadId],
            ],
            'lost_reason_id': reasonId,
            'lost_feedback': feedback.isEmpty
                ? false
                : '<div data-oe-version="1.2">${_escapeHtml(feedback)}</div>',
          },
        ],
        kwargs: {
          'context': context,
          'specification': {
            'lead_ids': <String, dynamic>{},
            'lost_reason_id': {
              'fields': {'display_name': <String, dynamic>{}},
            },
            'lost_feedback': <String, dynamic>{},
          },
        },
      ),
    );
    final records = saved['result'];
    if (records is! List ||
        records.isEmpty ||
        records.first is! Map ||
        (records.first as Map)['id'] is! int) {
      throw const ParsingFailure('Lost reason was not saved');
    }
    final wizardId = (records.first as Map)['id'] as int;
    await _dioClient.postJsonRpc(
      AppConstants.callButtonPath('crm.lead.lost', 'action_lost_reason_apply'),
      JsonRpcRequest.callButton(
        model: 'crm.lead.lost',
        method: 'action_lost_reason_apply',
        args: [
          [wizardId],
        ],
        kwargs: {'context': context},
      ),
    );
    await write(leadId, {'stage_id': lostStageId});
  }

  static String _escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
