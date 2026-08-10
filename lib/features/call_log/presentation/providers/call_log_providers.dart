import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/call_log/data/datasource/call_log_remote_datasource.dart';
import 'package:odoocrm/features/call_log/data/repository/call_log_repository_impl.dart';
import 'package:odoocrm/features/call_log/data/services/device_call_reader.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/repository/call_log_repository.dart';
import 'package:odoocrm/features/call_log/domain/services/call_log_service.dart';
import 'package:odoocrm/features/chatter/presentation/providers/chatter_notifier.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_detail_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'call_log_providers.g.dart';

@Riverpod(keepAlive: true)
CallLogRepository callLogRepository(Ref ref) {
  return CallLogRepositoryImpl(
    datasource: CallLogRemoteDatasource(
      dioClient: ref.watch(dioClientProvider),
      secureStorage: ref.watch(secureStorageServiceProvider),
    ),
  );
}

@Riverpod(keepAlive: true)
CallLogService callLogService(Ref ref) {
  return CallLogService(
    repository: ref.watch(callLogRepositoryProvider),
    chatterRepository: ref.watch(chatterRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
DeviceCallReader deviceCallReader(Ref ref) {
  return const DeviceCallReader();
}

/// Prefetched when Lead Detail opens. Also syncs inbound calls from device.
@riverpod
Future<CallLog> leadCallLog(Ref ref, int leadId) async {
  final service = ref.watch(callLogServiceProvider);
  final result = await service.getCallLog(leadId);
  var callLog = result.when(
    success: (value) => value,
    failure: (_) => const CallLog(),
  );

  final reader = ref.read(deviceCallReaderProvider);
  if (reader.isSupported) {
    try {
      final lead = await ref.read(leadDetailNotifierProvider(leadId).future);
      final phone = lead.phone ?? lead.mobile;
      if (phone != null && phone.isNotEmpty) {
        final inbound = await reader.countInboundCalls(
          phone: phone,
          since: lead.createdDate,
        );
        if (inbound != null) {
          final syncResult = await service.syncInboundCalls(
            leadId: leadId,
            deviceInboundCount: inbound,
          );
          if (syncResult.isSuccess) {
            callLog = syncResult.valueOrNull ?? callLog;
          }
        }
      }
    } catch (_) {
      // Lead detail may still be loading; return call log without inbound sync.
    }
  }

  return callLog;
}

/// Call Status tag options from Odoo `lead_properties` for this lead.
@riverpod
Future<List<CallStatusOption>> callStatusOptions(Ref ref, int leadId) async {
  final result =
      await ref.watch(callLogServiceProvider).getCallStatusOptions(leadId);
  return result.when(
    success: (options) => options,
    failure: (_) => const [
      CallStatusOption(key: 'picked', label: 'Picked'),
      CallStatusOption(key: 'dnp', label: 'DNP'),
      CallStatusOption(key: 'busy', label: 'Busy'),
      CallStatusOption(key: 'hanged_up', label: 'Hanged Up'),
      CallStatusOption(key: 'missed', label: 'Missed'),
      CallStatusOption(key: 'call_failed', label: 'Call Failed'),
    ],
  );
}
