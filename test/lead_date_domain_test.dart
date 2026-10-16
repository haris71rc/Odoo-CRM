import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/features/leads/data/datasource/lead_remote_datasource.dart';

class _RecordingDioClient extends DioClient {
  _RecordingDioClient() : super(const FlutterSecureStorage());

  JsonRpcRequest? lastRequest;

  @override
  Future<Map<String, dynamic>> postJsonRpc(
    String path,
    JsonRpcRequest request,
  ) async {
    lastRequest = request;
    return {'result': <dynamic>[]};
  }
}

void main() {
  test('create-date domain sends local day bounds as UTC to Odoo', () async {
    final client = _RecordingDioClient();
    final start = DateTime(2026, 10, 16);
    final end = DateTime(2026, 10, 17);

    await LeadRemoteDatasource(client).searchRead(
      startDate: start,
      endDate: end,
      dateExemptStageIds: const [12],
    );

    final domain = (client.lastRequest!.params['args'] as List).first as List;
    expect(domain, [
      '|',
      '&',
      ['create_date', '>=', DateFormatters.toApiDate(start.toUtc())],
      [
        'create_date',
        '<=',
        DateFormatters.toApiDate(DateTime(2026, 10, 17, 23, 59, 59).toUtc()),
      ],
      [
        'stage_id',
        'in',
        [12],
      ],
    ]);
  });
}
