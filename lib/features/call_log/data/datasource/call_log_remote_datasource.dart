import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/constants/app_environment.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/call_log/data/parser/lead_properties_parser.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log_validation_snapshot.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';

class CallLogRemoteDatasource {
  CallLogRemoteDatasource({
    required DioClient dioClient,
    required SecureStorageService secureStorage,
    LeadPropertiesParser parser = const LeadPropertiesParser(),
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage,
        _parser = parser;

  final DioClient _dioClient;
  final SecureStorageService _secureStorage;
  final LeadPropertiesParser _parser;

  static const _readFields = [
    'lead_properties',
    'stage_id',
    'user_id',
    'write_date',
  ];

  Future<List<CallStatusOption>> fetchCallStatusOptions(int leadId) async {
    final raw = await readLeadPropertiesRaw(leadId);
    return _parser.parseCallStatusOptions(raw);
  }

  Future<CallLog> fetchCallLog(int leadId) async {
    final record = await _readLeadRecord(leadId);
    return _parser.parse(record['lead_properties']).callLog;
  }

  Future<CallLogValidationSnapshot> fetchValidationSnapshot(int leadId) async {
    final record = await _readLeadRecord(leadId);
    final stage = OdooFieldParser.asMany2One(record['stage_id']);
    return CallLogValidationSnapshot(
      callLog: _parser.parse(record['lead_properties']).callLog,
      stageName: stage?.name,
      writeDate: OdooFieldParser.asDateTime(record['write_date']),
    );
  }

  Future<dynamic> readLeadPropertiesRaw(int leadId) async {
    final record = await _readLeadRecord(leadId);
    return record['lead_properties'];
  }

  Future<void> saveCallLog({
    required int leadId,
    required CallLog callLog,
  }) async {
    final existing = await readLeadPropertiesRaw(leadId);
    final merged = _parser.mergeCallLogForWrite(existing, callLog);

    final uid = await _secureStorage.getUid();
    if (uid == null) {
      throw const AuthFailure('No authenticated user');
    }

    final request = JsonRpcRequest.webSave(
      model: 'crm.lead',
      recordIds: [leadId],
      values: {'lead_properties': merged},
      uid: uid,
      allowedCompanyIds: AppEnvironment.allowedCompanyIds,
      specification: {
        'id': <String, dynamic>{},
        'lead_properties': <String, dynamic>{},
      },
    );

    await _dioClient.postJsonRpc(AppConstants.callKwPath, request);
  }

  Future<Map<String, dynamic>> _readLeadRecord(int leadId) async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.lead',
      method: 'read',
      args: [
        [leadId],
        _readFields,
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

    return Map<String, dynamic>.from(result.first as Map);
  }
}
