import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/features/chatter/presentation/providers/chatter_notifier.dart';
import 'package:odoocrm/features/mobile_call/data/repository/mobile_call_repository_impl.dart';
import 'package:odoocrm/features/mobile_call/data/services/call_log_reader.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';
import 'package:odoocrm/features/mobile_call/domain/repository/mobile_call_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mobile_call_providers.g.dart';

@Riverpod(keepAlive: true)
MobileCallRepository mobileCallRepository(Ref ref) {
  return MobileCallRepositoryImpl(
    chatterRepository: ref.watch(chatterRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
CallLogReader callLogReader(Ref ref) {
  return const CallLogReader();
}

/// Prefetches the latest MOBILE_CALL log when Lead Detail opens.
@riverpod
Future<LatestMobileCallEntity?> latestMobileCall(Ref ref, int leadId) async {
  final repository = ref.watch(mobileCallRepositoryProvider);
  final result = await repository.fetchLatestMobileCall(leadId);
  return result.when(
    success: (call) => call,
    failure: (_) => null,
  );
}
