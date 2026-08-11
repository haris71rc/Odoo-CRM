import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/quotations/domain/entities/quotation_result.dart';

abstract class QuotationRepository {
  /// Initializes a sale.order quotation for [leadId] using Odoo's
  /// existing CRM quotation workflow.
  Future<Result<QuotationResult>> createQuotationForLead(int leadId);
}
