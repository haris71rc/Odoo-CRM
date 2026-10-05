import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_log_datasource.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_outbox.dart';
import 'package:odoocrm/features/call_log/data/datasource/inbound_call_sync_store.dart';
import 'package:odoocrm/features/call_log/data/services/device_call_reader.dart';
import 'package:odoocrm/features/call_log/domain/services/growth_call_log_service.dart';
import 'package:odoocrm/features/call_log/domain/services/inbound_call_sync_service.dart';
import 'package:odoocrm/features/call_log/domain/utils/inbound_lead_match.dart';
import 'package:odoocrm/features/leads/data/datasource/lead_remote_datasource.dart';
import 'package:odoocrm/features/leads/domain/utils/duplicate_lead_matcher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'growth_call_log_providers.g.dart';

@Riverpod(keepAlive: true)
GrowthCallLogService growthCallLogService(Ref ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final service = GrowthCallLogService(
    datasource: GrowthCallLogDatasource(),
    secureStorage: secureStorage,
    outbox: GrowthCallOutbox(secureStorage),
  );
  ref.onDispose(service.dispose);
  return service;
}

@Riverpod(keepAlive: true)
InboundCallSyncStore inboundCallSyncStore(Ref ref) {
  return InboundCallSyncStore(ref.watch(secureStorageServiceProvider));
}

@Riverpod(keepAlive: true)
InboundCallSyncService inboundCallSyncService(Ref ref) {
  return InboundCallSyncService(
    deviceCallReader: const DeviceCallReader(),
    growthCallLogService: ref.watch(growthCallLogServiceProvider),
    syncStore: ref.watch(inboundCallSyncStoreProvider),
    resolveLeadId: (phone) async {
      final key = DuplicateLeadMatcher.keyOf(phone);
      if (key == null) return null;
      final snapshots = await LeadRemoteDatasource(
        ref.read(dioClientProvider),
      ).searchByPhoneKeys([key]);
      return InboundLeadMatch.pick(
        phone: phone,
        leads: [
          for (final snapshot in snapshots)
            InboundLeadCandidate(
              id: snapshot.id,
              phone: snapshot.phone,
              mobile: snapshot.mobile,
              createdDate: snapshot.createdDate,
            ),
        ],
      );
    },
  );
}

