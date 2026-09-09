import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_log_datasource.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_outbox.dart';
import 'package:odoocrm/features/call_log/domain/services/growth_call_log_service.dart';
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
