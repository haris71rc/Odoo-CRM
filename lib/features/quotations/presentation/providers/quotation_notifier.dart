import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_detail_notifier.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/quotations/data/datasource/quotation_remote_datasource.dart';
import 'package:odoocrm/features/quotations/data/repository/quotation_repository_impl.dart';
import 'package:odoocrm/features/quotations/domain/entities/quotation_result.dart';
import 'package:odoocrm/features/quotations/domain/repository/quotation_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quotation_notifier.g.dart';

@Riverpod(keepAlive: true)
QuotationRepository quotationRepository(Ref ref) {
  return QuotationRepositoryImpl(
    datasource: QuotationRemoteDatasource(
      dioClient: ref.watch(dioClientProvider),
      secureStorage: ref.watch(secureStorageServiceProvider),
    ),
  );
}

@Riverpod(keepAlive: true)
class QuotationNotifier extends _$QuotationNotifier {
  @override
  FutureOr<QuotationResult?> build(int leadId) => null;

  /// Runs the Odoo quotation initialization flow for this lead.
  /// The datasource also moves the lead to Proposal/Proposition.
  ///
  /// Returns `null` on success, or an error message on failure.
  Future<String?> createQuotation() async {
    if (state.isLoading) {
      return 'Quotation creation already in progress';
    }

    state = const AsyncLoading();
    final repository = ref.read(quotationRepositoryProvider);
    final result = await repository.createQuotationForLead(leadId);

    if (result.isFailure) {
      state = const AsyncData(null);
      return result.failureOrNull!.message;
    }

    final quotation = result.valueOrNull!;
    state = AsyncData(quotation);

    ref.invalidate(leadDetailNotifierProvider(leadId));
    ref.invalidate(leadNotifierProvider);
    await ref.read(leadDetailNotifierProvider(leadId).future);

    return null;
  }
}
