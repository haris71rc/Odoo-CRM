import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/call_log/data/datasource/pending_outbound_dial_store.dart';
import 'package:odoocrm/features/call_log/domain/services/outbound_dial_sync_service.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_log_providers.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_detail_notifier.dart';

final outboundDialSyncServiceProvider = Provider<OutboundDialSyncService>((ref) {
  ref.keepAlive();

  final service = OutboundDialSyncService(
    store: SecurePendingOutboundDialStore(ref.watch(secureStorageServiceProvider)),
    reader: ref.watch(deviceCallReaderProvider),
    isResumed: () =>
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
    statusOptions: (leadId) async {
      final result =
          await ref.read(callLogServiceProvider).getCallStatusOptions(leadId);
      return result.when(
        success: (options) => options,
        failure: (_) => const [],
      );
    },
    persist: (request) async {
      final user = ref.read(authNotifierProvider).valueOrNull;
      DateTime? createdAt;
      try {
        final lead =
            await ref.read(leadDetailNotifierProvider(request.leadId).future);
        createdAt = lead.createdDate;
      } catch (_) {}

      final saved = await ref.read(callLogServiceProvider).saveRecognizedOutbound(
            leadId: request.leadId,
            callEvent: request.callLog,
            leadCreatedAt: createdAt,
            salesperson: user?.name,
          );
      if (saved.isFailure) {
        return OutboundPersistResult(
          saved: false,
          message: saved.failureOrNull?.message,
        );
      }

      final detail = ref.read(leadDetailNotifierProvider(request.leadId).notifier);
      final assigned = await detail.autoAssignCaller(user?.id);
      final callLog = saved.valueOrNull ?? request.callLog;
      final moved = await detail.autoMoveToConnected(callLog);
      ref.invalidate(leadCallLogProvider(request.leadId));

      final String message;
      if (moved) {
        message = 'Call connected — stage set to Connected';
      } else if (assigned) {
        message = 'Call saved and assigned to you';
      } else {
        message = 'Call saved to lead';
      }
      return OutboundPersistResult(saved: true, message: message);
    },
  );

  final observer = _OutboundDialLifecycleObserver(service);
  WidgetsBinding.instance.addObserver(observer);
  Future<void>(() => service.hydrate(sync: true));
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
    service.dispose();
  });
  return service;
});

class _OutboundDialLifecycleObserver extends WidgetsBindingObserver {
  _OutboundDialLifecycleObserver(this._service);

  final OutboundDialSyncService _service;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _service.onLifecycle(resumed: state == AppLifecycleState.resumed);
  }
}
