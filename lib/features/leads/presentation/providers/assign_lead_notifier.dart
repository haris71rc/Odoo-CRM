import 'package:odoocrm/features/leads/presentation/providers/lead_detail_notifier.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assign_lead_notifier.g.dart';

@riverpod
class AssignLeadNotifier extends _$AssignLeadNotifier {
  @override
  FutureOr<void> build(int leadId) {}

  Future<String?> assign({required int userId}) async {
    state = const AsyncLoading();

    final detailNotifier =
        ref.read(leadDetailNotifierProvider(leadId).notifier);
    final error = await detailNotifier.assignToUser(userId);

    if (error != null) {
      state = AsyncError(error, StackTrace.current);
      return error;
    }

    ref.invalidate(leadNotifierProvider);
    state = const AsyncData(null);
    return null;
  }
}
