/// Helpers for preparing phone numbers for dialers and WhatsApp deep links.
abstract final class PhoneNumberUtils {
  PhoneNumberUtils._();

  /// Strips spaces, dashes, parentheses, and plus signs.
  ///
  /// Example: `+91 98765-43210` → `919876543210`
  static String normalize(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
  }

  /// Returns a non-empty normalized number, or `null` when unusable.
  static String? normalizeOrNull(String? phone) {
    if (phone == null) return null;
    final normalized = normalize(phone.trim());
    if (normalized.isEmpty) return null;
    return normalized;
  }

  static bool isValid(String? phone) => normalizeOrNull(phone) != null;
}
