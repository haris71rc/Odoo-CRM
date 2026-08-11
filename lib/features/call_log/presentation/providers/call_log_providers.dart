import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
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

bool _hasNewOutboundCall(CallLog before, CallLog after) {
  final beforeOutbound = before.totalOutboundCalls ?? 0;
  final afterOutbound = after.totalOutboundCalls ?? 0;
  if (afterOutbound > beforeOutbound) return true;
  if (after.lastCallDate == null) return false;
  return after.lastCallDate != before.lastCallDate;
}

/// Prefetched when Lead Detail opens.
///
/// Also syncs dialer-made calls from the Android call log into Odoo so calls
/// placed outside the CRM Call button still update Call Log / stage rules.
/// When a new outbound call is synced, auto-assigns the lead to the logged-in
/// user if they exist and are not already the salesperson.
@riverpod
Future<CallLog> leadCallLog(Ref ref, int leadId) async {
  final service = ref.watch(callLogServiceProvider);
  final result = await service.getCallLog(leadId);
  var callLog = result.when(
    success: (value) => value,
    failure: (_) => const CallLog(),
  );

  final reader = ref.read(deviceCallReaderProvider);
  if (!reader.isSupported) return callLog;

  try {
    final lead = await ref.read(leadDetailNotifierProvider(leadId).future);
    final phone = lead.phone ?? lead.mobile;
    if (phone == null || phone.isEmpty) return callLog;

    final statusOptions = await ref.read(callStatusOptionsProvider(leadId).future);
    final deviceCalls = await reader.findCallsForLead(
      phone: phone,
      since: lead.createdDate,
      statusOptions: statusOptions,
    );

    if (deviceCalls.isEmpty) return callLog;

    final previous = callLog;
    final syncResult = await service.syncFromDevice(
      leadId: leadId,
      deviceCalls: deviceCalls,
      leadCreatedAt: lead.createdDate,
    );

    if (syncResult.isSuccess) {
      callLog = syncResult.valueOrNull ?? callLog;
      if (_hasNewOutboundCall(previous, callLog)) {
        final currentUser = ref.read(authNotifierProvider).valueOrNull;
        await ref
            .read(leadDetailNotifierProvider(leadId).notifier)
            .autoAssignCaller(currentUser?.id);
      }
    }
  } catch (_) {
    // Lead detail / permission may fail; keep Odoo call log as-is.
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
