import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/chatter/data/datasource/chatter_remote_datasource.dart';
import 'package:odoocrm/features/chatter/data/repository/chatter_repository_impl.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chatter_notifier.g.dart';

@Riverpod(keepAlive: true)
ChatterRepository chatterRepository(Ref ref) {
  return ChatterRepositoryImpl(
    datasource: ChatterRemoteDatasource(
      dioClient: ref.watch(dioClientProvider),
      secureStorage: ref.watch(secureStorageServiceProvider),
    ),
  );
}

@riverpod
class ChatterNotifier extends _$ChatterNotifier {
  @override
  FutureOr<List<ChatterMessageEntity>> build(int leadId) async {
    final repository = ref.watch(chatterRepositoryProvider);
    final result = await repository.getMessagesForLead(leadId);

    return result.when(
      success: (messages) => messages,
      failure: (failure) => throw failure,
    );
  }

  Future<String?> logNote(String body) async {
    final repository = ref.read(chatterRepositoryProvider);
    final result = await repository.logNote(leadId: leadId, body: body);

    if (result.isFailure) return result.failureOrNull!.message;

    ref.invalidateSelf();
    await future;
    return null;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
