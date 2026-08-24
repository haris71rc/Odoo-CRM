import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/tags/data/datasource/tag_remote_datasource.dart';
import 'package:odoocrm/features/tags/data/repository/tag_repository_impl.dart';
import 'package:odoocrm/features/tags/domain/entities/lead_tag_entity.dart';
import 'package:odoocrm/features/tags/domain/entities/lead_temperature_tag.dart';
import 'package:odoocrm/features/tags/domain/repository/tag_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_providers.g.dart';

@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) {
  return TagRepositoryImpl(
    datasource: TagRemoteDatasource(ref.watch(dioClientProvider)),
  );
}

/// Cached HOT_LEAD / WARM_LEAD tags from Odoo (by name → id).
@Riverpod(keepAlive: true)
class LeadTemperatureTagsNotifier extends _$LeadTemperatureTagsNotifier {
  @override
  FutureOr<List<LeadTagEntity>> build() async {
    final isLoggedIn = ref.watch(authNotifierProvider).valueOrNull != null;
    if (!isLoggedIn) return const [];

    final result =
        await ref.watch(tagRepositoryProvider).getLeadTemperatureTags();
    return result.when(
      success: (tags) => tags,
      failure: (failure) => throw failure,
    );
  }

  /// Resolves selected temperature tags to Odoo `crm.tag` ids.
  List<int> resolveIds(Iterable<LeadTemperatureTag> selected) {
    final tags = state.valueOrNull ?? const <LeadTagEntity>[];
    if (tags.isEmpty || selected.isEmpty) return const [];

    final byName = <String, int>{
      for (final tag in tags) tag.name.trim().toUpperCase(): tag.id,
    };

    final ids = <int>[];
    for (final selectedTag in selected) {
      final id = byName[selectedTag.apiName];
      if (id != null) ids.add(id);
    }
    return ids;
  }
}
