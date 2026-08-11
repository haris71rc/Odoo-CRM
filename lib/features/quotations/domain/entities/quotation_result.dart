/// Domain result returned after initializing a sale.order quotation in Odoo.
class QuotationResult {
  const QuotationResult({
    required this.quotationId,
    this.quotationNumber,
    this.success = true,
    this.alreadyExisted = false,
  });

  final int quotationId;
  final String? quotationNumber;
  final bool success;
  final bool alreadyExisted;
}
