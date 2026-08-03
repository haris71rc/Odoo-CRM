import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/stages/data/datasource/stage_remote_datasource.dart';
import 'package:odoocrm/features/stages/data/repository/stage_repository_impl.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';
import 'package:odoocrm/features/stages/domain/repository/stage_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_notifier.g.dart';

@Riverpod(keepAlive: true)
StageRepository stageRepository(Ref ref) {
  return StageRepositoryImpl(
    datasource: StageRemoteDatasource(ref.watch(dioClientProvider)),
  );
}

@riverpod
class StageNotifier extends _$StageNotifier {
  @override
  FutureOr<List<StageEntity>> build() async {
    final repository = ref.watch(stageRepositoryProvider);
    final result = await repository.getStages();

    return result.when(
      success: (stages) => stages,
      failure: (failure) => throw failure,
    );
  }
}
